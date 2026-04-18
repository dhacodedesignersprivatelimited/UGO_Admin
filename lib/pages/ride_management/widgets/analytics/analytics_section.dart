import 'package:flutter/material.dart';

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text("Ride Statistics",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _row("Total Distance", "2456 km"),
          _row("Total Duration", "48h"),
          _row("Average Fare", "₹114"),
          _row("Cancellation Rate", "6.8%"),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title),
          Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}