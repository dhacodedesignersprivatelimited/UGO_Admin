import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/index.dart';
import 'package:google_fonts/google_fonts.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '../view_model/user_management_view_model.dart';
import '../widgets/user_filter_strip.dart';
import '../widgets/user_stats_cards.dart';
import '../widgets/user_table.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late final UserManagementViewModel _vm;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = UserManagementViewModel();
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
      child: Consumer<UserManagementViewModel>(
        builder: (context, vm, _) {
          return AdminPopScope(
            child: Scaffold(
              drawer: buildAdminDrawer(context),
              backgroundColor: DashboardTokens.pageBackground,
              appBar: AppBar(
                backgroundColor: DashboardTokens.primaryOrange,
                foregroundColor: Colors.white,
                centerTitle: true,
                title: const Text('USER MANAGEMENT', style: TextStyle(fontWeight: FontWeight.w700)),
                actions: [IconButton(onPressed: vm.load, icon: const Icon(Icons.refresh))],
              ),
              body: _buildBody(context, vm),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserManagementViewModel vm) {
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
                            onPressed: () => context.pushNamedAuth(AddUserWidget.routeName, context.mounted),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3C132),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Add User'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      UserStatsCards(
                        total: vm.totalUsers,
                        active: vm.activeUsers,
                        blocked: vm.blockedUsers,
                      ),
                      const SizedBox(height: 16),
                      UserFilterStrip(
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
                      UserTable(
                        activeTab: vm.tab,
                        tabCounts: {
                          UserManagementTab.all: vm.totalUsers,
                          UserManagementTab.active: vm.activeUsers,
                          UserManagementTab.blocked: vm.blockedUsers,
                        },
                        rows: vm.pagedUsers,
                        startDisplay: vm.startDisplay,
                        endDisplay: vm.endDisplay,
                        totalRows: vm.totalUsers,
                        onViewUser: (id) => context.pushNamedAuth(
                          UserDetailsWidget.routeName,
                          context.mounted,
                          queryParameters: {'userId': '$id'},
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
                        canPrevious: vm.page > 1,
                        canNext: vm.page < vm.totalPages,
                        currentPage: vm.page,
                        totalPages: vm.totalPages,
                        loadingUserIds: vm.actionUserIds,
                        onBlock: (id) => _handleBlock(vm, id),
                        pageSize: vm.pageSize,
                        onPageSizeChanged: vm.setPageSize,
                        pageSizeOptions: UserManagementViewModel.pageSizeOptions,
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

  Future<void> _handleBlock(UserManagementViewModel vm, int userId) async {
    final ok = await vm.toggleBlockUser(userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'User blocked successfully' : 'Could not block user'),
      ),
    );
  }
}