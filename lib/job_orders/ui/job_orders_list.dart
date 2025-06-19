import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tbtech/job_orders/repositories/job_orders_repository.dart';

class JobOrdersListScreen extends ConsumerStatefulWidget {
  const JobOrdersListScreen({super.key});

  @override
  ConsumerState<JobOrdersListScreen> createState() => _JobOrdersListScreenState();
}

class _JobOrdersListScreenState extends ConsumerState<JobOrdersListScreen> {
  DateTime? visitDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(Duration(days: 30)),
        lastDate: DateTime.now()
    );

    setState(() {
      if (pickedDate != null) {
        visitDate = pickedDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    final jobOrders = ref.watch(jobOrdersStreamProvider(formatter.format(visitDate!)));

    return Scaffold(
      appBar: AppBar(
        title: Text(visitDate != null
            ? 'Job orders from ${formatter.format(visitDate!)}'
            : 'Job orders today',),
        elevation: 2,
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.date_range_outlined),
              onPressed: _selectDate),
          // IconButton(icon: Icon(Icons.exit_to_app),
          //     onPressed: () {
          //       _auth.logOut();
          //     })
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: //Container(),

          jobOrders.when(
              data: (data) {
                return RefreshIndicator(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            // padding: const EdgeInsets.all(8.0),
                            color: Colors.green.shade50,
                            shadowColor: Colors.green.shade600,
                            elevation: 2,
                            margin: const EdgeInsets.all(4.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.adb),
                                  title: Text(data[index].clientName),
                                  subtitle: Text(data[index].shortAddress??"no address provided"),
                                  trailing: Column(
                                      children: [
                                        Text(data[index].code),
                                        Text(data[index].status),
                                        Text(data[index].site??"no site provided"),
                                      ]
                                  ),
                                  onTap: () {
                                    debugPrint('Card tapped. {$index}');
                                    String jobId = data[index].id.toString();
                                    context.push("/jobOrder/$jobId");
                                  },
                                ),

                                // Text(data[index].job_order_type),
                              ],
                            ),
                          );
                        }
                    ),
                    onRefresh: () async {
                      ref.refresh(jobOrdersStreamProvider(formatter.format(visitDate!)));
                    }
                );
              },
              loading: ()=> CircularProgressIndicator(),
              error: (e, trace) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
                return null;
              }

          )

      ),

    );
  }
}


