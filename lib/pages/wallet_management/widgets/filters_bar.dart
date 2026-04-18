import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletFiltersBar extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(String)? onTypeChange; // all / credit / debit
  final Function(int?)? onDriverChange;
  final Function(DateTimeRange?)? onDateRangeChange;
  final List<Map<String, dynamic>> drivers;
  final String initialType;
  final int? initialDriverId;
  final DateTimeRange? initialDateRange;
  final String initialSearch;

  const WalletFiltersBar({
    super.key,
    this.onSearch,
    this.onTypeChange,
    this.onDriverChange,
    this.onDateRangeChange,
    this.drivers = const [],
    this.initialType = 'all',
    this.initialDriverId,
    this.initialDateRange,
    this.initialSearch = '',
  });

  @override
  State<WalletFiltersBar> createState() => _WalletFiltersBarState();
}

class _WalletFiltersBarState extends State<WalletFiltersBar> {
  late String selectedType;
  int? selectedDriverId;
  DateTimeRange? selectedDateRange;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType;
    selectedDriverId = widget.initialDriverId;
    selectedDateRange = widget.initialDateRange;
    _searchController.text = widget.initialSearch;
  }

  @override
  void didUpdateWidget(covariant WalletFiltersBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialType != widget.initialType) {
      selectedType = widget.initialType;
    }
    if (oldWidget.initialDriverId != widget.initialDriverId) {
      selectedDriverId = widget.initialDriverId;
    }
    if (oldWidget.initialDateRange != widget.initialDateRange) {
      selectedDateRange = widget.initialDateRange;
    }
    if (oldWidget.initialSearch != widget.initialSearch &&
        _searchController.text != widget.initialSearch) {
      _searchController.text = widget.initialSearch;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _dateRangeField(),
            const SizedBox(width: 10),
            _typeDropdown(),
            const SizedBox(width: 10),
            _driverDropdown(),
            const SizedBox(width: 10),
            _searchField(),
            const SizedBox(width: 10),
            _filterButton(),
          ],
        ),
      ),
    );
  }

  Widget _dateRangeField() {
    final label = selectedDateRange == null
        ? 'Last 30 days'
        : '${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)}'
            '  -  ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}';
    return SizedBox(
      width: 210,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(now.year - 2),
            lastDate: DateTime(now.year + 1),
            initialDateRange: selectedDateRange,
          );
          if (picked == null) return;
          setState(() => selectedDateRange = picked);
          widget.onDateRangeChange?.call(picked);
        },
        child: InputDecorator(
          decoration: _decoration(
            suffixIcon: const Icon(Icons.calendar_month_outlined, size: 18),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _typeDropdown() {
    return SizedBox(
      width: 140,
      child: DropdownButtonFormField<String>(
        value: selectedType,
        decoration: _decoration(),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('All Types')),
          DropdownMenuItem(value: 'credit', child: Text('Credit')),
          DropdownMenuItem(value: 'debit', child: Text('Debit')),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() => selectedType = value);
          widget.onTypeChange?.call(value);
        },
      ),
    );
  }

  Widget _driverDropdown() {
    String driverLabel(Map<String, dynamic> d) {
      final fn = d['first_name']?.toString().trim() ?? '';
      final ln = d['last_name']?.toString().trim() ?? '';
      final full = '$fn $ln'.trim();
      if (full.isNotEmpty) return full;
      return 'Driver #${d['id'] ?? ''}';
    }

    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<int?>(
        value: selectedDriverId,
        isExpanded: true,
        decoration: _decoration(),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('All Drivers', overflow: TextOverflow.ellipsis),
          ),
          ...widget.drivers.map(
            (d) => DropdownMenuItem<int?>(
              value: _toInt(d['id']),
              child: Text(
                driverLabel(d),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() => selectedDriverId = value);
          widget.onDriverChange?.call(value);
        },
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => widget.onSearch?.call(value),
        decoration: _decoration(
          hintText: 'Search transactions...',
          suffixIcon: const Icon(Icons.search, size: 18),
        ),
      ),
    );
  }

  Widget _filterButton() {
    return SizedBox(
      height: 40,
      child: FilledButton.icon(
        onPressed: () {
          widget.onTypeChange?.call(selectedType);
          widget.onDriverChange?.call(selectedDriverId);
          widget.onDateRangeChange?.call(selectedDateRange);
          widget.onSearch?.call(_searchController.text);
        },
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1F2937),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        icon: const Icon(Icons.filter_alt_outlined, size: 16),
        label: const Text('Filter'),
      ),
    );
  }

  InputDecoration _decoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }

  static int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? '');
  }
}