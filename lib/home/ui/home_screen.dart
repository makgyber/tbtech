import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtech/auth/services/api_auth_service.dart';
import 'package:tbtech/auth/services/auth_service.dart';
import 'package:tbtech/utils/connectivity.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userName;

  Future<void> _loadData() async {
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
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
      body: Center(
        child: Text('Welcome $_userName! You are authenticated.'),
      ),
    );
  }
}