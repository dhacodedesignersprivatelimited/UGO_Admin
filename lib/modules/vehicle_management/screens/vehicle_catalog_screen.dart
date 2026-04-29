import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/index.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '../models/admin_vehicle_row.dart';
import '../view_models/vehicle_catalog_notifier.dart';
import '../view_models/vehicle_catalog_state.dart';
import '../widgets/vehicle_filter_strip.dart';
import '../widgets/vehicle_stats_row.dart';
import '../widgets/vehicle_type_section.dart';

class VehicleCatalogScreen extends ConsumerStatefulWidget {
  const VehicleCatalogScreen({super.key});

  @override
  ConsumerState<VehicleCatalogScreen> createState() =>
      _VehicleCatalogScreenState();
}

class _VehicleCatalogScreenState extends ConsumerState<VehicleCatalogScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(vehicleCatalogProvider.notifier).load());
    _searchController.addListener(() {
      ref
          .read(vehicleCatalogProvider.notifier)
          .setSearchQuery(_searchController.text);
    });

    // Always open this page at the top, even when browser scroll position is reused.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleCatalogProvider);
    final notifier = ref.read(vehicleCatalogProvider.notifier);

    // Keep search controller in sync with state (e.g. after clearFilters).
    if (_searchController.text != state.searchQuery) {
      _searchController.text = state.searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return AdminPopScope(
      child: Scaffold(
        drawer: buildAdminDrawer(context),
        backgroundColor: DashboardTokens.pageBackground ?? const Color(0xFFF4F6FA),
        appBar: AppBar(
          backgroundColor: DashboardTokens.primaryOrange,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          title: Text(
            'Vehicle Fleet Management',
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: notifier.load,
              icon: const Icon(Icons.refresh_rounded, size: 24),
              tooltip: 'Refresh Catalog',
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushNamedAuth(AddVehicleWidget.routeName, context.mounted),
          backgroundColor: DashboardTokens.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            'Add Vehicle',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
        body: _buildBody(context, state, notifier),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      VehicleCatalogState state,
      VehicleCatalogNotifier notifier,
      ) {
    final theme = FlutterFlowTheme.of(context);

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.primary,
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.car_crash_rounded, size: 52, color: theme.error),
              ),
              const SizedBox(height: 20),
              Text(
                'Failed to load catalog',
                style: GoogleFonts.interTight(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: theme.secondaryText),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: notifier.load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Retry Connection', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: DashboardTokens.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: DashboardTokens.primaryOrange,
      onRefresh: notifier.load,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header row ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fleet Overview',
                        style: GoogleFonts.interTight(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => context.pushNamedAuth(AddVehicleTypeWidget.routeName, context.mounted),
                        icon: const Icon(Icons.category_rounded, size: 16),
                        label: Text('Add Category', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        style: FilledButton.styleFrom(
                          backgroundColor: DashboardTokens.primaryOrange.withValues(alpha: 0.1),
                          foregroundColor: DashboardTokens.primaryOrange,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Stats ────────────────────────────────────────────
                  VehicleStatsRow(
                    totalTypes: state.totalTypes,
                    totalSubVehicles: state.totalSubVehicles,
                  ),
                  const SizedBox(height: 24),

                  // ── Filter strip ─────────────────────────────────────
                  VehicleFilterStrip(
                    searchController: _searchController,
                    vehicleTypes: state.vehicleTypes,
                    filterTypeId: state.filterTypeId,
                    hasActiveFilter: state.hasActiveFilter,
                    onSearchChanged: () => notifier.setSearchQuery(_searchController.text),
                    onTypeFilterChanged: notifier.setFilterTypeId,
                    onClearFilters: () {
                      _searchController.clear();
                      notifier.clearFilters();
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Vehicle type sections ────────────────────────────
                  if (state.vehicleTypes.isEmpty)
                    _emptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'No vehicle types configured',
                      message: 'Start building your fleet by adding your first vehicle category.',
                    )
                  else if (state.filteredTypes.isEmpty)
                    _emptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matches found',
                      message: 'Adjust your search or filter settings to find what you are looking for.',
                    )
                  else
                    ...state.filteredTypes.map(
                          (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: VehicleTypeSection(
                          entry: entry,
                          actionVehicleIds: state.actionVehicleIds,
                          onEdit: (v) => _showEditDialog(context, v, notifier),
                          onSetPricing: (v) => _showPricingDialog(context, v, notifier),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs (Upgraded SaaS UI) ──────────────────────────────────────────────

  InputDecoration _dialogInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: Colors.black45),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DashboardTokens.primaryOrange, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context,
      AdminVehicleRow vehicle,
      VehicleCatalogNotifier notifier,
      ) async {
    final nameCtrl = TextEditingController(text: vehicle.name);
    final seatingCtrl = TextEditingController(text: vehicle.seatingCapacity.toString());
    final luggageCtrl = TextEditingController(text: vehicle.luggageCapacity.toString());

    bool submitting = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Edit Vehicle Details',
                            style: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
                          onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameCtrl,
                          decoration: _dialogInputDecoration('Vehicle Name', Icons.directions_car_rounded),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: seatingCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _dialogInputDecoration('Seats', Icons.airline_seat_recline_normal_rounded),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: luggageCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _dialogInputDecoration('Bags', Icons.work_outline_rounded),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                          child: Text('Cancel', style: GoogleFonts.inter(color: Colors.black54)),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: submitting
                              ? null
                              : () async {
                            setDialogState(() => submitting = true);
                            final ok = await notifier.updateVehicle(
                              vehicleId: vehicle.id,
                              vehicleName: nameCtrl.text.trim(),
                              seatingCapacity: int.tryParse(seatingCtrl.text.trim()),
                              luggageCapacity: int.tryParse(luggageCtrl.text.trim()),
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok ? 'Vehicle updated successfully!' : 'Update failed — please retry.'),
                                  backgroundColor: ok ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: DashboardTokens.primaryOrange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: submitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    nameCtrl.dispose();
    seatingCtrl.dispose();
    luggageCtrl.dispose();
  }

  Future<void> _showPricingDialog(
      BuildContext context,
      AdminVehicleRow vehicle,
      VehicleCatalogNotifier notifier,
      ) async {
    String formatNum(num? value, {required num fallback}) {
      final v = value ?? fallback;
      return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
    }

    final startCtrl = TextEditingController(text: (vehicle.baseKmStart ?? 0).toString());
    final endCtrl = TextEditingController(text: (vehicle.baseKmEnd ?? 5).toString());
    final fareCtrl = TextEditingController(text: formatNum(vehicle.baseFare, fallback: 50));
    final kmCtrl = TextEditingController(text: formatNum(vehicle.pricePerKm, fallback: 15));

    bool submitting = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pricing Configuration',
                                style: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicle.name,
                                style: GoogleFonts.inter(fontSize: 13, color: DashboardTokens.primaryOrange, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
                          onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: startCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _dialogInputDecoration('Base KM Start', Icons.social_distance_rounded),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.arrow_right_alt_rounded, color: Colors.black38),
                            ),
                            Expanded(
                              child: TextField(
                                controller: endCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _dialogInputDecoration('Base KM End', Icons.flag_rounded),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: fareCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _dialogInputDecoration('Base Fare (₹)', Icons.payments_rounded),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: kmCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _dialogInputDecoration('Price / KM (₹)', Icons.add_road_rounded),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                          child: Text('Cancel', style: GoogleFonts.inter(color: Colors.black54)),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: submitting
                              ? null
                              : () async {
                            final parsedStart = int.tryParse(startCtrl.text.trim());
                            final parsedEnd = int.tryParse(endCtrl.text.trim());
                            final parsedFare = num.tryParse(fareCtrl.text.trim());
                            final parsedPerKm = num.tryParse(kmCtrl.text.trim());

                            if (parsedStart == null || parsedEnd == null || parsedFare == null || parsedPerKm == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter valid numeric values for all fields.')),
                                );
                              }
                              return;
                            }

                            if (parsedEnd < parsedStart) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Base KM End must be greater than or equal to Base KM Start.')),
                                );
                              }
                              return;
                            }

                            if (parsedFare < 0 || parsedPerKm < 0) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Fares cannot be negative.')),
                                );
                              }
                              return;
                            }

                            setDialogState(() => submitting = true);
                            final ok = await notifier.setPricing(
                              vehicleId: vehicle.id,
                              baseKmStart: parsedStart,
                              baseKmEnd: parsedEnd,
                              baseFare: parsedFare,
                              pricePerKm: parsedPerKm,
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              final failureMessage = notifier.lastActionError ?? 'Failed to save pricing — retry.';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok ? 'Pricing updated successfully!' : failureMessage),
                                  backgroundColor: ok ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: DashboardTokens.primaryOrange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: submitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('Update Pricing', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    startCtrl.dispose();
    endCtrl.dispose();
    fareCtrl.dispose();
    kmCtrl.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _emptyState({required IconData icon, required String title, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, size: 56, color: Colors.black26),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.interTight(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}