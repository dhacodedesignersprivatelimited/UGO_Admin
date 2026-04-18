import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/admin_scaffold.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../admin_panel_dependencies.dart';
import '../../core/admin_panel_session.dart';
import '../../modules/user/view_models/user_module_view_model.dart';
import '../widgets/feature_tile.dart';
import '../widgets/module_intro_card.dart';

class UserModuleHubScreen extends StatefulWidget {
  const UserModuleHubScreen({super.key});

  static const String routeName = 'adminUserHub';
  static const String routePath = '/admin/users';

  @override
  State<UserModuleHubScreen> createState() => _UserModuleHubScreenState();
}

class _UserModuleHubScreenState extends State<UserModuleHubScreen> {
  UserModuleViewModel? _vm;
  bool _wired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _wired = true;
    final deps = context.read<AdminPanelDependencies>();
    _vm = UserModuleViewModel(
      repository: deps.users,
      principal: demoAdminPrincipal(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm?.refreshRiders();
      _vm?.refreshComplaints();
    });
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
        title: 'Rider operations',
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
                    title: 'User (rider) management',
                    description:
                        'Identity, wallet, complaints, and promos stay in the rider module. Each surface reads through repositories, not widgets.',
                    accentIcon: Icons.groups_2_rounded,
                  ),
                  const SizedBox(height: 20),
                  FeatureTile(
                    icon: Icons.list_alt_rounded,
                    title: 'All riders',
                    subtitle: 'Legacy list with filters and deep links.',
                    onTap: () => context.pushNamed(AllusersWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.block_rounded,
                    title: 'Blocked accounts',
                    subtitle: 'Safety and fraud workflows.',
                    onTap: () => context.pushNamed(BlockedUsersWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Complaints',
                    subtitle: 'Ticket queue with assignment hooks.',
                    onTap: () => context.pushNamed(UserComplaintsWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.local_offer_rounded,
                    title: 'Promo codes',
                    subtitle: 'Create, pause, and audit redemptions.',
                    onTap: () => context.pushNamed(PromoCodesWidget.routeName),
                  ),
                  const SizedBox(height: 12),
                  FeatureTile(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Wallet management',
                    subtitle: 'Rider balances and reconciliations.',
                    onTap: () => context.pushNamed(WalletManagementWidget.routeName),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Complaints (mock)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Consumer<UserModuleViewModel>(
                    builder: (context, vm, _) {
                      final state = vm.complaintsState;
                      if (state.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: LinearProgressIndicator(),
                        );
                      }
                      final items = state.data ?? const [];
                      if (items.isEmpty) {
                        return const Text('No complaints');
                      }
                      return Column(
                        children: items
                            .map(
                              (c) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(c.subject),
                                subtitle: Text(c.status.name),
                                trailing: vm.canManageComplaints
                                    ? TextButton(
                                        onPressed: () => vm.resolveComplaint(c.id),
                                        child: const Text('Resolve'),
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
