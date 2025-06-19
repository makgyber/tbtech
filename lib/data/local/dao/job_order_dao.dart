import 'package:floor/floor.dart';
import 'package:tbtech/models/job_order.dart';

@dao
abstract class JobOrderDao {
  @Query('SELECT * FROM job_orders WHERE id = :id')
  Future<JobOrder?> getJobOrderById(int id);

  @Query('SELECT * FROM job_orders')
  Future<List<JobOrder>> getAllJobOrders();

  @Query('SELECT * FROM job_orders WHERE targetDate LIKE :visitDate')
  Future<List<JobOrder>> getAllJobOrdersByTargetDate(String visitDate);

  @Query('SELECT * FROM job_orders WHERE targetDate LIKE :targetDate')
  Stream<List<JobOrder>> getAllJobOrdersByTargetDateAsStream(String targetDate);

  @Query('SELECT * FROM job_orders')
  Stream<List<JobOrder>> getAllJobOrdersAsStream();

  @Query('SELECT DISTINCT COUNT(message) FROM job_orders')
  Stream<int?> getUniqueMessagesCountAsStream();

  @Query('SELECT * FROM job_orders WHERE status = :status')
  Stream<List<JobOrder>> getAllJobOrdersByStatusAsStream(String status);

  @Query('UPDATE OR ABORT job_orders SET type = :type WHERE id = :id')
  Future<int?> updateTypeById(String type, int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertJobOrder(JobOrder jobOrder);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertJobOrders(List<JobOrder> jobOrders);

  @update
  Future<void> updateJobOrder(JobOrder jobOrder);

  @update
  Future<void> updateJobOrders(List<JobOrder> jobOrder);

  @delete
  Future<void> deleteJobOrder(JobOrder jobOrder);

  @Query('DELETE FROM job_orders')
  Future<void> deleteAllJobOrders();

  @Query('SELECT COUNT(*) FROM job_orders')
  Stream<int?> getJobOrdersCountStream();
}