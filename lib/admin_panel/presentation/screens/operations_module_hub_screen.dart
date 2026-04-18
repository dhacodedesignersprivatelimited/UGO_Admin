import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/admin_scaffold.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/ride_management/screens/ride_management_screen.dart';
import '../../admin_panel_dependencies.dart';
import '../../core/admin_panel_session.dart';
import '../../data/models/domain_enums.dart';
import '../../modules/common/view_models/dashboard_analytics_view_model.dart';
import '../../modules/common/view_models/finance_hub_view_model.dart';
import '../../modules/common/view_models/operations_hub_view_model.dart';
import '../widgets/feature_tile.dart';
import '../widgets/module_intro_card.dart';

class OperationsModuleHubScreen extends StatefulWidget {
  const OperationsModuleHubScreen({super.key});

  static const String routeName = 'adminOpsHub';
  static const String routePath = '/admin/operations';

  @override
  State<OperationsModuleHubScreen> createState() => _OperationsModuleHubScreenState();
}

class _OperationsModuleHubScreenState extends State<OperationsModuleHubScreen> {
  OperationsHubViewModel? _ridesVm;
  DashboardAnalyticsViewModel? _analyticsVm;
  FinanceHubViewModel? _financeVm;
  bool _wired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _wired = true;
    final deps = context.read<AdminPanelDependencies>();
    final principal = demoAdminPrincipal();
    _ridesVm = OperationsHubViewModel(repository: deps.rides, principal: principal);
    _analyticsVm =
        DashboardAnalyticsViewModel(repository: deps.analytics, principal: principal);
    _financeVm = FinanceHubViewModel(repository: deps.finance, principal: principal);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ridesVm?.refresh();
      _analyticsVm?.refresh();
      _financeVm?.refresh();
    });
  }

  @override
  void dispose() {
    _ridesVm?.dispose();
    _analyticsVm?.dispose();
    _financeVm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ridesVm = _ridesVm;
    final analyticsVm = _analyticsVm;
    final financeVm = _financeVm;
    if (ridesVm == null || analyticsVm == null || financeVm == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ridesVm),
        ChangeNotifierProvider.value(value: analyticsVm),
        ChangeNotifierProvider.value(value: financeVm),
      ],
      child: AdminScaffold(
        title: 'Control room',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ModuleIntroCard(
                    title: 'Operations & finance',
                    description:
                        'Live rides, dispatch, finance approvals, and global pricing. ViewModels use the same HTTP admin APIs as the legacy drawer when you are signed in.',
                    accentIcon: Icons.hub_rounded,
                  ),
                  const SizedBox(height: 20),
                  FeatureTile(
                    icon: Icons.dashboard_customize_rounded,
                    title: 'Executive dashboard',
                    subtitle: 'KPIs, charts, and quick actions.',
                    onTap: () => context.pushNamed(DashboardScreen.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.map_rounded,
                    title: 'Live map',
                    subtitle: 'Fleet heatmap and ride tracking.',
                    onTap: () => context.pushNamed(LiveDriverMapWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.alt_route_rounded,
                    title: 'Ride management',
                    subtitle: 'Assign, reassign, cancel, audit.',
                    onTap: () => context.pushNamed(RideManagementScreen.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    subtitle: 'Broadcast and transactional pushes.',
                    onTap: () => context.pushNamed(NotificationsWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.tune_rounded,
                    title: 'Fare & surge',
                    subtitle: 'Global fare tables and surge bands.',
                    onTap: () => context.pushNamed(FareSurgeSettingsWidget.routeName),
                  ),
                  const SizedBox(height: 24),
                  Text('Signals (dashboard API)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Consumer<DashboardAnalyticsViewModel>(
                    builder: (context, vm, _) {
                      final state = vm.analyticsState;
                      if (state.isLoading) {
                        return const LinearProgressIndicator();
                      }
                      final data = state.data;
                      if (data == null) {
                        return Text(state.message ?? 'No analytics');
                      }
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: data.metrics
                            .map(
                              (m) => Chip(
                                avatar: Icon(
                                  m.trendUp ? Icons.trending_up : Icons.trending_down,
                                  size: 18,
                                ),
                                label: Text('${m.title}: ${m.value}'),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Active rides (sample)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Consumer<OperationsHubViewModel>(
                    builder: (context, vm, _) {
                      final rides = vm.ridesState.data ?? const [];
                      if (rides.isEmpty) {
                        return const Text('No rides');
                      }
                      return Column(
                        children: rides
                            .map(
                              (r) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('${r.pickupLabel} → ${r.dropLabel}'),
                                subtitle: Text('${r.status.name} · ${r.driverName}'),
                                trailing: vm.canManageRides && r.driverName == 'Unassigned'
                                    ? TextButton(
                                        onPressed: () => vm.quickAssign(r.id, 'd1'),
                                        child: const Text('Assign'),
                                      )
                                    : null,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Withdraw queue', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Consumer<FinanceHubViewModel>(
                    builder: (context, vm, _) {
                      final items = vm.withdrawalsState.data ?? const [];
                      if (items.isEmpty) {
                        return const Text('No pending withdrawals');
                      }
                      return Column(
                        children: items
                            .map(
                              (w) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(w.driverName),
                                subtitle: Text('₹${w.amount.toStringAsFixed(0)} · ${w.status.name}'),
                                trailing: vm.canApprove && w.status == WithdrawalStatus.pending
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () => vm.reject(w.id),
                                            child: const Text('Reject'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => vm.approve(w.id),
                                            child: const Text('Approve'),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
