import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtech/models/job_order.dart';
import 'package:tbtech/job_orders/services/api_service.dart';
import 'package:tbtech/data/local/dao/job_order_dao.dart'; // Your Floor DAO
import 'package:tbtech/data/local/app_database.dart';  // Your Floor Database
import 'package:tbtech/errors/exceptions.dart';

class JobOrderRepository {
  final ApiService _apiService;
  final JobOrderDao _jobOrderDao;

  JobOrderRepository(this._apiService, this._jobOrderDao);

  // Fetches jobOrders from API, saves them to local DB (using Floor), then returns them.
  Future<List<JobOrder>> fetchAndCacheJobOrders({required String visitDate, bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.get("auth_token");
    try {
      print("Fetching jobOrders from API (Floor)...");
      final remoteJobOrders = await _apiService.fetchJobOrders(token.toString(), visitDate);
      if (remoteJobOrders.isNotEmpty) {
        if (forceRefresh) {
          await _jobOrderDao.deleteAllJobOrders(); // Clear old data using DAO
        }
        await _jobOrderDao.insertJobOrders(remoteJobOrders); // Save/update in DB using DAO
        print("${remoteJobOrders.length} jobOrders fetched and cached via Floor.");
        return remoteJobOrders;
      }
      return _jobOrderDao.getAllJobOrdersByTargetDate('$visitDate%'); // Fallback to local if API returns empty
    } on NetworkException catch (e) {
      print("Network error (Floor): ${e.message}. Attempting to load from local DB.");
      return _jobOrderDao.getAllJobOrdersByTargetDate('$visitDate%'); // Return cached data on network error
    } on ApiException catch (e) {
      print("API Exception (Floor): ${e.message}. Could not fetch fresh data.");
      var localJobOrders = await _jobOrderDao.getAllJobOrdersByTargetDate(visitDate);
      if (localJobOrders.isNotEmpty) return localJobOrders;
      rethrow;
    } catch (e) {
      print("Unexpected error in fetchAndCacheJobOrders (Floor): $e");
      rethrow;
    }
  }

  // Get jobOrders primarily from local DB; fallback to network if DB is empty
  Future<List<JobOrder>> getJobOrders(String visitDate) async {
    final localJobOrders = await _jobOrderDao.getAllJobOrdersByTargetDate('$visitDate%');
    if (localJobOrders.isNotEmpty) {
      print("Loaded ${localJobOrders.length} jobOrders from local DB (Floor).");
      return localJobOrders;
    } else {
      print("No jobOrders in local DB (Floor). Fetching from API...");
      return fetchAndCacheJobOrders(visitDate: visitDate);
    }
  }

  Stream<List<JobOrder>> getJobOrdersStream(String targetDate) async* {
    // return _jobOrderDao.getAllJobOrdersByTargetDateAsStream('$targetDate%');
    yield await getJobOrders(targetDate);
  }

  Future<JobOrder?> getJobOrderById(int id) async {
    return _jobOrderDao.getJobOrderById(id);
  }

  Future<void> clearLocalJobOrders() async {
    await _jobOrderDao.deleteAllJobOrders();
  }

  Stream<int> getJobOrdersCountStream() {
    // Map the nullable stream to a non-nullable one with a default
    return _jobOrderDao.getJobOrdersCountStream().map((count) => count ?? 0);
  }
}

// --- Riverpod Providers ---
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Provider for the Floor database instance
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  // This ensures the database is built only once
  return await $FloorAppDatabase
      .databaseBuilder('app_floor_database.db')
      .build();
});

// Provider for the JobOrderDao, depends on the AppDatabase
final jobOrderDaoProvider = Provider<JobOrderDao?>((ref) {
  // Watch the appDatabaseProvider. When it has data (database is ready), return the dao.
  return ref.watch(appDatabaseProvider).asData?.value.jobOrderDao;
});


final jobOrderRepositoryProvider = Provider<JobOrderRepository?>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final jobOrderDao = ref.watch(jobOrderDaoProvider);

  if (jobOrderDao != null) { // Only create repository if DAO is available
    return JobOrderRepository(apiService, jobOrderDao);
  }
  return null; // Return null if DAO (and thus database) isn't ready
});


// Provider to fetch jobOrders (Future-based for one-time fetch)
final jobOrdersFutureProvider = FutureProvider.autoDispose.family<List<JobOrder>, String>((ref, visitDate) async {
  final repository = ref.watch(jobOrderRepositoryProvider);
  if (repository == null) {
    // Handle case where repository isn't ready (e.g., database still initializing)
    // You could throw an error, return an empty list, or wait.
    // For simplicity, we'll throw, but a loading state is better.
    // This scenario should be brief if appDatabaseProvider resolves quickly.
    print("JobOrderRepository not ready yet in jobOrdersFutureProvider.");
    return []; // Or throw Exception("Repository not ready");
  }
  return repository.getJobOrders(visitDate);
});

// Provider for the stream of jobOrders (for reactive updates from DB)
final jobOrdersStreamProvider = StreamProvider.autoDispose.family<List<JobOrder>, String>((ref, targetDate) {
  final repository = ref.watch(jobOrderRepositoryProvider);
  return repository?.getJobOrdersStream(targetDate) ?? Stream.empty();
});

final jobOrderCounterProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(jobOrderRepositoryProvider);
  if (repo == null) {
    return Stream.value(0);
  }
  return repo.getJobOrdersCountStream();
});