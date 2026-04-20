import 'package:flutter/material.dart';

import 'chip_filter.dart';
import 'date_filter.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final narrow = w < 480;
        final pad = w < 360 ? 10.0 : 14.0;

        final dateRow = narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DateFilter(text: 'Start Date'),
                  SizedBox(height: w < 340 ? 8 : 10),
                  const DateFilter(text: 'End Date'),
                  SizedBox(height: w < 340 ? 8 : 10),
                  const DateFilter(text: 'Status'),
                ],
              )
            : Row(
                children: [
                  const Expanded(child: DateFilter(text: 'Start Date')),
                  SizedBox(width: w < 400 ? 8 : 10),
                  const Expanded(child: DateFilter(text: 'End Date')),
                  SizedBox(width: w < 400 ? 8 : 10),
                  const Expanded(child: DateFilter(text: 'Status')),
                ],
              );

        final actionRow = narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChipFilter(label: 'Payments'),
                      ChipFilter(label: 'Drivers'),
                    ],
                  ),
                  SizedBox(height: w < 340 ? 8 : 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Filter'),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  const ChipFilter(label: 'Payments'),
                  const SizedBox(width: 8),
                  const ChipFilter(label: 'Drivers'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Filter'),
                  ),
                ],
              );

        return Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              dateRow,
              SizedBox(height: w < 340 ? 8 : 10),
              actionRow,
            ],
          ),
        );
      },
    );
  }
}
