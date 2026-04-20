import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/index.dart';
import 'package:google_fonts/google_fonts.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '../view_model/driver_management_view_model.dart';
import '../widgets/document_verification_section.dart';
import '../widgets/driver_filter_strip.dart';
import '../widgets/driver_stats_cards.dart';
import '../widgets/driver_table.dart';
import '../widgets/pending_approvals_section.dart';

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  late final DriverManagementViewModel _vm;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = DriverManagementViewModel();
    _vm.load().then((_) {
      if (!mounted) return;
      _searchController.text = _vm.searchQuery;
    });
    _searchController.addListener(() {
      _vm.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<DriverManagementViewModel>(
        builder: (context, vm, _) {
          return AdminPopScope(
            child: Scaffold(
              drawer: buildAdminDrawer(context),
              backgroundColor: DashboardTokens.pageBackground,
              appBar: AppBar(
                backgroundColor: DashboardTokens.primaryOrange,
                foregroundColor: Colors.white,
                centerTitle: true,
                title: const Text('DRIVER MANAGEMENT', style: TextStyle(fontWeight: FontWeight.w700)),
                actions: [IconButton(onPressed: vm.load, icon: const Icon(Icons.refresh))],
              ),
              body: _buildBody(context, vm),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleApproval(
    DriverManagementViewModel vm,
    int driverId, {
    required bool approve,
  }) async {
    final ok = approve ? await vm.approveDriver(driverId) : await vm.rejectDriver(driverId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (approve ? 'Driver approved successfully' : 'Driver rejected successfully')
              : 'Could not update driver verification status',
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DriverManagementViewModel vm) {
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary),
      );
    }
    if (vm.errorMessage != null) {
      return Center(
        child: FilledButton(onPressed: vm.load, child: const Text('Retry')),
      );
    }

    return RefreshIndicator(
      color: DashboardTokens.primaryOrange,
      onRefresh: vm.load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Updated ${dateTimeFormat("relative", DateTime.now())}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => context.pushNamedAuth(AddDriverWidget.routeName, context.mounted),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3C132),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Add Driver'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DriverStatsCards(
                        total: vm.totalDrivers,
                        active: vm.activeDrivers,
                        online: vm.onlineDrivers,
                        pending: vm.pendingDrivers,
                        blocked: vm.blockedDrivers,
                      ),
                      const SizedBox(height: 16),
                      DriverFilterStrip(
                        searchController: _searchController,
                        onFilterTap: () => vm.setSearchQuery(_searchController.text),
                        onClearTap: () {
                          if (_searchController.text.isEmpty) return;
                          _searchController.clear();
                          vm.setSearchQuery('');
                        },
                        hasActiveSearch: vm.searchQuery.trim().isNotEmpty,
                        onResetAllTap: () {
                          _searchController.clear();
                          vm.resetAllTableState();
                        },
                        showResetAll: vm.hasNonDefaultTableState,
                      ),
                      const SizedBox(height: 16),
                      DriverTable(
                        activeTab: vm.tab,
                        tabCounts: {
                          DriverManagementTab.all: vm.totalDrivers,
                          DriverManagementTab.active: vm.activeDrivers,
                          DriverManagementTab.online: vm.onlineDrivers,
                          DriverManagementTab.pending: vm.pendingDrivers,
                          DriverManagementTab.blocked: vm.blockedDrivers,
                        },
                        rows: vm.pagedDrivers,
                        startDisplay: vm.startDisplay,
                        endDisplay: vm.endDisplay,
                        totalRows: vm.filteredDrivers.length,
                        onViewDriver: (id) => context.pushNamedAuth(
                          DriverDetailsWidget.routeName,
                          context.mounted,
                          queryParameters: {'driverId': '$id'},
                        ),
                        onViewDocuments: (id) => context.pushNamedAuth(
                          DriverDetailsWidget.routeName,
                          context.mounted,
                          queryParameters: {
                            'driverId': '$id',
                            'openDocuments': 'true',
                          },
                        ),
                        onTabChanged: (tab) {
                          vm.setTab(tab);
                          if (_searchController.text != vm.searchQuery) {
                            _searchController.text = vm.searchQuery;
                          }
                        },
                        onPreviousPage: vm.previousPage,
                        onNextPage: vm.nextPage,
                        onPageSelected: vm.setPage,
                        canPrevious: vm.clampedPage > 1,
                        canNext: vm.clampedPage < vm.totalPages,
                        currentPage: vm.clampedPage,
                        totalPages: vm.totalPages,
                        loadingDriverIds: vm.actionDriverIds,
                        onApprove: (id) => _handleApproval(vm, id, approve: true),
                        onReject: (id) => _handleApproval(vm, id, approve: false),
                        pageSize: vm.pageSize,
                        onPageSizeChanged: vm.setPageSize,
                        pageSizeOptions: DriverManagementViewModel.pageSizeOptions,
                      ),
                      const SizedBox(height: 16),
                      PendingApprovalsSection(
                        pendingCount: vm.pendingDrivers,
                        rows: vm.topPending,
                        loadingDriverIds: vm.actionDriverIds,
                        onApprove: (id) => _handleApproval(vm, id, approve: true),
                        onReject: (id) => _handleApproval(vm, id, approve: false),
                      ),
                      const SizedBox(height: 16),
                      DocumentVerificationSection(
                        total: vm.totalDrivers,
                        drivingLicense: vm.verifiedDrivingLicense,
                        rcBook: vm.verifiedRcBook,
                        aadhaar: vm.verifiedAadhaar,
                        profilePhoto: vm.verifiedProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
