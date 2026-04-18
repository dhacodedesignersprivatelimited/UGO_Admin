import 'package:flutter/material.dart';

class RideStatusChip extends StatelessWidget {
  final String status;

  const RideStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.orange;

    if (status == "Completed") color = Colors.green;
    if (status == "Cancelled") color = Colors.red;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: color)),
    );
  }
}