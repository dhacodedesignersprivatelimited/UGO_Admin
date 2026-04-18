import 'package:flutter/material.dart';
import '../../models/ride_model.dart';
import 'ride_status_chip.dart';

class RideCard extends StatelessWidget {
  final RideModel ride;

  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(child: Icon(Icons.person)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ride.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${ride.pickup} → ${ride.drop}",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          RideStatusChip(status: ride.status),
        ],
      ),
    );
  }
}