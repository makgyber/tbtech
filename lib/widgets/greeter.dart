import 'package:flutter/material.dart';

class Greeter extends StatelessWidget {
  const Greeter({super.key, required this.name, required this.dateToday});

  final String name;
  final String dateToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateToday, style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 24,
                )
                ),
                Text(name, style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  )
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}