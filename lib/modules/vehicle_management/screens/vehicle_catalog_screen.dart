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
        backgroundColor: DashboardTokens.pageBackground,
        appBar: AppBar(
          backgroundColor: DashboardTokens.primaryOrange,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'VEHICLE MANAGEMENT',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              onPressed: notifier.load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushNamedAuth(
              AddVehicleWidget.routeName, context.mounted),
          backgroundColor: DashboardTokens.primaryOrange,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Vehicle'),
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
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: FlutterFlowTheme.of(context).primary,
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
              const Icon(Icons.error_outline_rounded,
                  size: 52, color: Color(0xFFC62828)),
              const SizedBox(height: 16),
              const Text(
                'Failed to load vehicle catalog',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: notifier.load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: DashboardTokens.primaryOrange,
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header row ───────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${state.totalTypes} type${state.totalTypes != 1 ? 's' : ''}'
                          ' · ${state.totalSubVehicles} vehicle${state.totalSubVehicles != 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.pushNamedAuth(
                            AddVehicleTypeWidget.routeName, context.mounted),
                        icon: const Icon(Icons.add_circle_outline, size: 16),
                        label: const Text('Add Type'),
                        style: TextButton.styleFrom(
                          foregroundColor: DashboardTokens.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Stats ────────────────────────────────────────────
                  VehicleStatsRow(
                    totalTypes: state.totalTypes,
                    totalSubVehicles: state.totalSubVehicles,
                  ),
                  const SizedBox(height: 16),

                  // ── Filter strip ─────────────────────────────────────
                  VehicleFilterStrip(
                    searchController: _searchController,
                    vehicleTypes: state.vehicleTypes,
                    filterTypeId: state.filterTypeId,
                    hasActiveFilter: state.hasActiveFilter,
                    onSearchChanged: () =>
                        notifier.setSearchQuery(_searchController.text),
                    onTypeFilterChanged: notifier.setFilterTypeId,
                    onClearFilters: () {
                      _searchController.clear();
                      notifier.clearFilters();
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Vehicle type sections ────────────────────────────
                  if (state.vehicleTypes.isEmpty)
                    _emptyState(
                      icon: Icons.directions_car_outlined,
                      message:
                          'No vehicle types yet.\nTap "Add Type" to get started.',
                    )
                  else if (state.filteredTypes.isEmpty)
                    _emptyState(
                      icon: Icons.search_off_rounded,
                      message: 'No vehicles match your filter.',
                    )
                  else
                    ...state.filteredTypes.map(
                      (entry) => VehicleTypeSection(
                        entry: entry,
                        actionVehicleIds: state.actionVehicleIds,
                        onEdit: (v) => _showEditDialog(context, v, notifier),
                        onSetPricing: (v) =>
                            _showPricingDialog(context, v, notifier),
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

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<void> _showEditDialog(
    BuildContext context,
    AdminVehicleRow vehicle,
    VehicleCatalogNotifier notifier,
  ) async {
    final nameCtrl = TextEditingController(text: vehicle.name);
    final seatingCtrl =
        TextEditingController(text: vehicle.seatingCapacity.toString());
    final luggageCtrl =
        TextEditingController(text: vehicle.luggageCapacity.toString());

    bool submitting = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(
              'Edit – ${vehicle.name}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: seatingCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Seats',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: luggageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Bags',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: submitting
                    ? null
                    : () async {
                        setDialogState(() => submitting = true);
                        final ok = await notifier.updateVehicle(
                          vehicleId: vehicle.id,
                          vehicleName: nameCtrl.text.trim(),
                          seatingCapacity:
                              int.tryParse(seatingCtrl.text.trim()),
                          luggageCapacity:
                              int.tryParse(luggageCtrl.text.trim()),
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? 'Vehicle updated!'
                                  : 'Update failed — please retry.'),
                            ),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: DashboardTokens.primaryOrange,
                ),
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
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

    final startCtrl = TextEditingController(
      text: (vehicle.baseKmStart ?? 0).toString(),
    );
    final endCtrl = TextEditingController(
      text: (vehicle.baseKmEnd ?? 5).toString(),
    );
    final fareCtrl = TextEditingController(
      text: formatNum(vehicle.baseFare, fallback: 50),
    );
    final kmCtrl = TextEditingController(
      text: formatNum(vehicle.pricePerKm, fallback: 15),
    );

    bool submitting = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(
              'Set Pricing – ${vehicle.name}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Base KM Start',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: endCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Base KM End',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fareCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Base Fare (₹)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: kmCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Price / KM (₹)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: submitting
                    ? null
                    : () async {
                        final parsedStart = int.tryParse(startCtrl.text.trim());
                        final parsedEnd = int.tryParse(endCtrl.text.trim());
                        final parsedFare = num.tryParse(fareCtrl.text.trim());
                        final parsedPerKm = num.tryParse(kmCtrl.text.trim());

                        if (parsedStart == null ||
                            parsedEnd == null ||
                            parsedFare == null ||
                            parsedPerKm == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Enter valid numeric pricing values.'),
                              ),
                            );
                          }
                          return;
                        }

                        if (parsedEnd < parsedStart) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Base KM End must be greater than or equal to Base KM Start.'),
                              ),
                            );
                          }
                          return;
                        }

                        if (parsedFare < 0 || parsedPerKm < 0) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Base Fare and Price / KM must be non-negative.'),
                              ),
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
                          final failureMessage = notifier.lastActionError ??
                              'Failed to save pricing — retry.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(ok ? 'Pricing saved!' : failureMessage),
                            ),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: DashboardTokens.primaryOrange,
                ),
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Set Pricing'),
              ),
            ],
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

  Widget _emptyState({required IconData icon, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
