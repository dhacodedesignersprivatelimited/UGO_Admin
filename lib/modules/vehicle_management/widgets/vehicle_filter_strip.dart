import 'package:flutter/material.dart';

import '/modules/dashboard/view/dashboard_tokens.dart';
import '../models/vehicle_type_entry.dart';

class VehicleFilterStrip extends StatelessWidget {
  const VehicleFilterStrip({
    super.key,
    required this.searchController,
    required this.vehicleTypes,
    required this.filterTypeId,
    required this.hasActiveFilter,
    required this.onSearchChanged,
    required this.onTypeFilterChanged,
    required this.onClearFilters,
  });

  final TextEditingController searchController;
  final List<VehicleTypeEntry> vehicleTypes;
  final int? filterTypeId;
  final bool hasActiveFilter;
  final VoidCallback onSearchChanged;
  final ValueChanged<int?> onTypeFilterChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;

        final searchField = TextField(
          controller: searchController,
          onChanged: (_) => onSearchChanged(),
          decoration: InputDecoration(
            hintText: 'Search by vehicle name...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged();
                    },
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
        );

        final filterField = DropdownButtonFormField<int?>(
          value: filterTypeId,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: const Text('All Types'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Types')),
            ...vehicleTypes.map(
              (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
            ),
          ],
          onChanged: onTypeFilterChanged,
        );

        final clearButton = hasActiveFilter
            ? Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: DashboardTokens.primaryOrange,
                  ),
                ),
              )
            : const SizedBox.shrink();

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              filterField,
              if (hasActiveFilter) const SizedBox(height: 6),
              clearButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 10),
            SizedBox(width: 220, child: filterField),
            if (hasActiveFilter) ...[
              const SizedBox(width: 8),
              clearButton,
            ],
          ],
        );
      },
    );
  }
}
