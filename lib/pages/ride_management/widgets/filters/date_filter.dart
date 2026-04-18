import 'package:flutter/material.dart';

class DateFilter extends StatelessWidget {
  final String text;

  const DateFilter({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text),
    );
  }
}