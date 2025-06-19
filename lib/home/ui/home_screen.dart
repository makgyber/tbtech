import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtech/auth/services/api_auth_service.dart';
import 'package:tbtech/auth/services/auth_service.dart';
import 'package:tbtech/job_orders/repositories/job_orders_repository.dart';
import 'package:tbtech/utils/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:tbtech/widgets/greeter.dart';
import 'package:tbtech/widgets/home_button_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userName;
  var _joCounter = 0;


  Future<void> _loadUserData() async {
    final nameProvider = ref.read(apiAuthServiceProvider);
    String? savedUserName = await nameProvider.getUserName();
    setState(() {
      if (savedUserName != null) {
        _userName = savedUserName;
      }
    });
  }

  @override
  void initState()  {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final formatter = DateFormat("EEEE, MMMM d");
    final visitDate = formatter.format(DateTime.now());
    final jobOrderCount = ref.watch(jobOrderCounterProvider).value;
    final joDaoProvider = ref.watch(jobOrderDaoProvider);
    final joRepository = ref.watch(jobOrderRepositoryProvider);


    final textTheme = Theme.of(context).textTheme;
    final colorScheme= Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Chip(
              avatar: Icon(isOnline ? Icons.wifi : Icons.wifi_off,
                          color: isOnline ? Colors.green : Colors.red),
              label: Text(isOnline ? 'Online' : 'Offline'),
              backgroundColor: isOnline ? Colors.green.shade100 : Colors.red.shade100,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authServiceProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Greeter(name: _userName!, dateToday: visitDate),
            const Divider(height: 32.0, thickness: 1, color: Colors.blueGrey,),

            HomeButtonSection(children: [
                ButtonWithText(color: Colors.grey, icon: Icons.delete, label: 'DELETE', onTap: () {
                  joDaoProvider?.deleteAllJobOrders();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted $jobOrderCount items.')),
                  );
                }),
                ButtonWithText(color: Colors.green, icon: Icons.cached, label: 'REFRESH', onTap: () {
                  joRepository!.fetchAndCacheJobOrders(visitDate: visitDate, forceRefresh: true);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You have $jobOrderCount items.')),
                  );
                },),
                ButtonWithText(color: Colors.blueGrey, icon: Icons.share, label: 'SHARE', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You have $jobOrderCount items.')),
                  );
                }),
            ]),

            const Divider(height: 12.0, thickness: 1, color: Colors.blueGrey),

            _buildInfoCard(
              context: context,
              icon: Icons.traffic,
              title: 'Job Orders ',
              value: jobOrderCount.toString(),
              color: Colors.white70,
              onTap: () {
                GoRouter.of(context).push("/job_orders");
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String value,
  required Color color,
  VoidCallback? onTap,
}) {
  final textTheme = Theme.of(context).textTheme;
  final colorScheme = Theme.of(context).colorScheme;

  return Card(
    elevation: 0.4,
    color: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 36.0, color: Colors.grey),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}