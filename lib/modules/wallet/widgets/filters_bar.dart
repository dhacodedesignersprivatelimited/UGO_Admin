import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';

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
    if (oldWidget.initialType != widget.initialType) selectedType = widget.initialType;
    if (oldWidget.initialDriverId != widget.initialDriverId) selectedDriverId = widget.initialDriverId;
    if (oldWidget.initialDateRange != widget.initialDateRange) selectedDateRange = widget.initialDateRange;
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

  bool get _hasActiveFilters =>
      selectedType != 'all' ||
      selectedDriverId != null ||
      selectedDateRange != null ||
      _searchController.text.isNotEmpty;

  void _applyFilters() {
    widget.onTypeChange?.call(selectedType);
    widget.onDriverChange?.call(selectedDriverId);
    widget.onDateRangeChange?.call(selectedDateRange);
    widget.onSearch?.call(_searchController.text);
  }

  void _resetFilters() {
    setState(() {
      selectedType = 'all';
      selectedDriverId = null;
      selectedDateRange = null;
      _searchController.clear();
    });
    widget.onTypeChange?.call('all');
    widget.onDriverChange?.call(null);
    widget.onDateRangeChange?.call(null);
    widget.onSearch?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
        boxShadow: DashboardTokens.cardShadow,
      ),
      child: Column(
        children: [
          // Row 1: Date range | Type | Driver | (Reset All)
          Row(
            children: [
              Expanded(child: _dateRangeField()),
              const SizedBox(width: 8),
              Expanded(child: _typeDropdown()),
              const SizedBox(width: 8),
              Expanded(child: _driverDropdown()),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset all'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Search | Filter button
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(fontSize: 13),
                  onChanged: (v) => widget.onSearch?.call(v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 18),
                    hintText: 'Search transactions...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardTokens.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.filter_alt_outlined, size: 16),
                  label: const Text('Filter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateRangeField() {
    final label = selectedDateRange == null
        ? 'Select Date'
        : '${DateFormat('dd/MM').format(selectedDateRange!.start)}'
            ' - ${DateFormat('dd/MM').format(selectedDateRange!.end)}';
    return InkWell(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE3E3E3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _typeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black45),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
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
      ),
    );
  }

  Widget _driverDropdown() {
    String driverLabel(Map<String, dynamic> d) {
      final fn = d['first_name']?.toString().trim() ?? '';
      final ln = d['last_name']?.toString().trim() ?? '';
      final full = '$fn $ln'.trim();
      return full.isNotEmpty ? full : 'Driver #${d['id'] ?? ''}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedDriverId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black45),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('All Drivers', overflow: TextOverflow.ellipsis),
            ),
            ...widget.drivers.map(
              (d) => DropdownMenuItem<int?>(
                value: _toInt(d['id']),
                child: Text(driverLabel(d), overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => selectedDriverId = value);
            widget.onDriverChange?.call(value);
          },
        ),
      ),
    );
  }

  static int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? '');
  }
}
