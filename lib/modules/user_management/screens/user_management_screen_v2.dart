import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/index.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '../view_models/user_management_notifier.dart';
import '../view_models/user_management_state.dart';
import '../widgets/user_filter_strip_v2.dart';
import '../widgets/user_stats_cards_v2.dart';
import '../widgets/user_table_v2.dart';

class UserManagementScreenV2 extends ConsumerStatefulWidget {
  const UserManagementScreenV2({super.key});

  @override
  ConsumerState<UserManagementScreenV2> createState() =>
      _UserManagementScreenV2State();
}

class _UserManagementScreenV2State extends ConsumerState<UserManagementScreenV2> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userManagementNotifierProvider.notifier).load();
    });
    _searchController.addListener(() {
      ref
          .read(userManagementNotifierProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userManagementNotifierProvider);
    final notifier = ref.read(userManagementNotifierProvider.notifier);

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
            'USER MANAGEMENT',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              onPressed: notifier.load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _buildBody(context, state, notifier),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserManagementState state,
    UserManagementNotifier notifier,
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
              const Icon(Icons.error_outline_rounded, size: 52, color: Color(0xFFC62828)),
              const SizedBox(height: 16),
              const Text(
                'Failed to load users',
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        children: [
          Center(
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
                        onPressed: () => context.pushNamedAuth(
                          AddUserWidget.routeName,
                          context.mounted,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3C132),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Add User'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  UserStatsCardsV2(
                    total: state.totalUsers,
                    active: state.activeUsers,
                    blocked: state.blockedUsers,
                  ),
                  const SizedBox(height: 16),
                  UserFilterStripV2(
                    searchController: _searchController,
                    onFilterTap: () =>
                        notifier.setSearchQuery(_searchController.text),
                    onClearTap: () {
                      if (_searchController.text.isEmpty) return;
                      _searchController.clear();
                      notifier.setSearchQuery('');
                    },
                    hasActiveSearch: state.searchQuery.trim().isNotEmpty,
                    onResetAllTap: () {
                      _searchController.clear();
                      notifier.resetAllTableState();
                    },
                    showResetAll: state.hasNonDefaultTableState,
                  ),
                  const SizedBox(height: 16),
                  UserTableV2(
                    activeTab: state.tab,
                    tabCounts: {
                      UserManagementTab.all: state.totalUsers,
                      UserManagementTab.active: state.activeUsers,
                      UserManagementTab.blocked: state.blockedUsers,
                    },
                    rows: state.pagedUsers,
                    startDisplay: state.startDisplay,
                    endDisplay: state.endDisplay,
                    totalRows: state.filteredUsers.length,
                    onViewUser: (id) => context.pushNamedAuth(
                      UserDetailsWidget.routeName,
                      context.mounted,
                      queryParameters: {'userId': '$id'},
                    ),
                    onTabChanged: notifier.setTab,
                    onPreviousPage: notifier.previousPage,
                    onNextPage: notifier.nextPage,
                    onPageSelected: notifier.setPage,
                    canPrevious: state.clampedPage > 1,
                    canNext: state.clampedPage < state.totalPages,
                    currentPage: state.clampedPage,
                    totalPages: state.totalPages,
                    loadingUserIds: state.actionUserIds,
                    onBlock: (id) async {
                      final ok = await notifier.toggleBlockUser(id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'User status updated successfully'
                                : 'Could not update user status',
                          ),
                        ),
                      );
                    },
                    pageSize: state.pageSize,
                    onPageSizeChanged: notifier.setPageSize,
                    pageSizeOptions: UserManagementState.pageSizeOptions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
