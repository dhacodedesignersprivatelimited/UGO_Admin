import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/network/api_config.dart';
import '/shared/widgets/safe_network_avatar.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';

class DriverWalletsScreen extends ConsumerStatefulWidget {
  const DriverWalletsScreen({super.key});

  static String routeName = 'DriverWalletsScreen';
  static String routePath = '/driver-wallets';

  @override
  ConsumerState<DriverWalletsScreen> createState() => _DriverWalletsScreenState();
}

class _DriverWalletsScreenState extends ConsumerState<DriverWalletsScreen> {
  late Future<ApiCallResponse> _driversFuture;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  void _fetchDrivers() {
    setState(() {
      _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      color: theme.primaryBackground,
      child: FutureBuilder<ApiCallResponse>(
        future: _driversFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: theme.primary));
          }

          final response = snapshot.data!;
          final drivers = GetDriversCall.data(response.jsonBody)?.toList() ?? [];

          if (drivers.isEmpty) {
            return Center(
              child: Text(
                'No driver wallets found',
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _fetchDrivers(),
            color: theme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: drivers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = drivers[index];
                final firstName = getJsonField(d, r'''$.first_name''')?.toString() ?? '';
                final lastName = getJsonField(d, r'''$.last_name''')?.toString() ?? '';
                final name = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : 'Unknown Driver';
                final phone = getJsonField(d, r'''$.mobile_number''')?.toString() ?? 'No phone';
                final img = getJsonField(d, r'''$.profile_image''')?.toString();

                // Extract wallet balance (graceful fallback)
                final walletBalanceRaw = getJsonField(d, r'''$.wallet_balance''') ?? 
                                         getJsonField(d, r'''$.wallet.balance''') ?? 0;
                final walletBalance = double.tryParse(walletBalanceRaw.toString()) ?? 0.0;

                final isNegative = walletBalance < 0;

                return Container(
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.alternate),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: SafeNetworkAvatar(
                      imageUrl: img != null && img.isNotEmpty && img != 'null'
                          ? (img.startsWith('http') ? img : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}')
                          : '',
                      radius: 24,
                    ),
                    title: Text(
                      name,
                      style: theme.titleMedium.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                      ),
                    ),
                    subtitle: Text(
                      phone,
                      style: theme.bodySmall.override(color: theme.secondaryText),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Balance',
                          style: theme.labelSmall.override(
                            font: GoogleFonts.inter(),
                            color: theme.secondaryText,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '₹${walletBalance.toStringAsFixed(2)}',
                          style: theme.titleMedium.override(
                            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                            color: isNegative ? theme.error : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to driver details or transaction history
                      // final dId = getJsonField(d, r'''$.id''');
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
