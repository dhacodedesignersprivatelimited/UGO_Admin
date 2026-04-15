import 'package:flutter/material.dart';

class WalletFiltersBar extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(String)? onTypeChange; // all / credit / debit
  final Function(String)? onStatusChange; // pending / success / failed

  const WalletFiltersBar({
    super.key,
    this.onSearch,
    this.onTypeChange,
    this.onStatusChange,
  });

  @override
  State<WalletFiltersBar> createState() => _WalletFiltersBarState();
}

class _WalletFiltersBarState extends State<WalletFiltersBar> {
  String selectedType = "all";
  String selectedStatus = "all";

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🔍 SEARCH BAR
        TextField(
          controller: _searchController,
          onChanged: (value) {
            if (widget.onSearch != null) widget.onSearch!(value);
          },
          decoration: InputDecoration(
            hintText: "Search by name, phone, ID...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// TYPE FILTER (All / Credit / Debit)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip("All", "all"),
              _buildChip("Credit", "credit"),
              _buildChip("Debit", "debit"),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// STATUS FILTER (optional)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatusChip("All", "all"),
              _buildStatusChip("Pending", "pending"),
              _buildStatusChip("Success", "success"),
              _buildStatusChip("Failed", "failed"),
            ],
          ),
        ),
      ],
    );
  }

  /// TYPE CHIP
  Widget _buildChip(String label, String value) {
    final isSelected = selectedType == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => selectedType = value);
          if (widget.onTypeChange != null) {
            widget.onTypeChange!(value);
          }
        },
        selectedColor: Colors.orange.shade200,
      ),
    );
  }

  /// STATUS CHIP
  Widget _buildStatusChip(String label, String value) {
    final isSelected = selectedStatus == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => selectedStatus = value);
          if (widget.onStatusChange != null) {
            widget.onStatusChange!(value);
          }
        },
        selectedColor: Colors.blue.shade200,
      ),
    );
  }
}