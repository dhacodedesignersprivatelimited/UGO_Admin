import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/admin_scaffold.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../admin_panel_dependencies.dart';
import '../../core/admin_panel_session.dart';
import '../../modules/driver/view_models/driver_module_view_model.dart';
import '../widgets/feature_tile.dart';
import '../widgets/module_intro_card.dart';

class DriverModuleHubScreen extends StatefulWidget {
  const DriverModuleHubScreen({super.key});

  static const String routeName = 'adminDriverHub';
  static const String routePath = '/admin/drivers';

  @override
  State<DriverModuleHubScreen> createState() => _DriverModuleHubScreenState();
}

class _DriverModuleHubScreenState extends State<DriverModuleHubScreen> {
  DriverModuleViewModel? _vm;
  bool _wired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _wired = true;
    final deps = context.read<AdminPanelDependencies>();
    _vm = DriverModuleViewModel(
      repository: deps.drivers,
      principal: demoAdminPrincipal(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm?.refresh());
  }

  @override
  void dispose() {
    _vm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;
    if (vm == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return ChangeNotifierProvider.value(
      value: vm,
      child: AdminScaffold(
        title: 'Driver operations',
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
                    title: 'Driver management',
                    description:
                        'Onboarding, KYC, vehicles, earnings, and safety controls — wired through repositories so REST swaps stay isolated.',
                    accentIcon: Icons.local_taxi_rounded,
                  ),
                  const SizedBox(height: 20),
                  FeatureTile(
                    icon: Icons.groups_rounded,
                    title: 'Driver roster',
                    subtitle: 'Search, block, and open legacy detail screens.',
                    onTap: () => context.pushNamed(DriversWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.fact_check_rounded,
                    title: 'KYC queue',
                    subtitle: 'Approve or reject onboarding documents.',
                    onTap: () => context.pushNamed(DriverKycListWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.directions_car_filled_rounded,
                    title: 'Vehicles & catalog',
                    subtitle: 'Types, subtypes, and assignments.',
                    onTap: () => context.pushNamed(VehiclesListWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.payments_rounded,
                    title: 'Payouts & wallet',
                    subtitle: 'Withdraw approvals and ledgers.',
                    onTap: () => context.pushNamed(DriverPayoutsWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.insights_rounded,
                    title: 'Earnings analytics',
                    subtitle: 'Driver-level revenue trends.',
                    onTap: () => context.pushNamed(EarningsWidget.routeName),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Live preview (mock API)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Consumer<DriverModuleViewModel>(
                    builder: (context, vm, _) {
                      final state = vm.driversState;
                      if (state.isLoading) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      if (state.isFailure) {
                        return Text(state.message ?? 'Failed to load');
                      }
                      final items = state.data ?? const [];
                      return Column(
                        children: items
                            .map(
                              (d) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(d.displayName),
                                subtitle: Text('${d.vehicleLabel} · ${d.presence.name}'),
                                trailing: vm.canTogglePresence && d.presence.name != 'blocked'
                                    ? TextButton(
                                        onPressed: () => vm.blockDriver(d.id),
                                        child: const Text('Block'),
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
