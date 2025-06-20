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
    DateFormat timeFormat = DateFormat('h:mm a');
    final jobOrders = ref.watch(jobOrdersStreamProvider(formatter.format(visitDate!)));

    return Scaffold(
      appBar: AppBar(
        title: Text(visitDate != null
            ? 'Job orders from ${formatter.format(visitDate!)}'
            : 'Job orders today',),
        elevation: 2,
        foregroundColor: Colors.blueGrey,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.date_range_outlined),
              onPressed: _selectDate),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(4),
          child: //Container(),

          jobOrders.when(
              data: (data) {
                return RefreshIndicator(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                            color: Colors.white,
                            shadowColor: Colors.blueGrey,
                            elevation: 0.2,
                            margin: const EdgeInsets.all(2.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                    ListTile(
                                      leading: Container(
                                              constraints: const BoxConstraints(
                                              minWidth: 100,
                                            ),
                                            padding: const EdgeInsets.all(2.0),
                                            // color: Colors.grey[100],
                                            child: Text(
                                              timeFormat.format(DateTime.parse(data[index].targetDate).toLocal()),
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.blueGrey,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
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
                                        context.push("/job_order/$jobId");
                                      },
                                    ),
                                ]
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


