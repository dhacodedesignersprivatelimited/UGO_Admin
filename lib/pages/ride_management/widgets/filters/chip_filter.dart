import 'package:flutter/material.dart';

class ChipFilter extends StatelessWidget {
  final String label;

  const ChipFilter({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }
}