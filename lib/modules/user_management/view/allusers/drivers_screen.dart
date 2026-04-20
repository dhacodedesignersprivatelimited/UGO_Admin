import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/network/api_config.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/safe_network_avatar.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  static String routeName = 'DriversScreen';

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  late Future<ApiCallResponse> _driversFuture;
  final Set<int> _updatingActiveIds = {};

  @override
  void initState() {
    super.initState();
    _driversFuture = GetDriversCall.call(
      token: currentAuthenticationToken,
    );
  }

  Future<void> _refreshDrivers() async {
    setState(() {
      _driversFuture = GetDriversCall.call(
        token: currentAuthenticationToken,
      );
    });
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  Future<void> _updateActiveStatus(int driverId, bool value) async {
    if (_updatingActiveIds.contains(driverId)) return;

    setState(() => _updatingActiveIds.add(driverId));

    final res = await UpdateDriverCall.call(
      id: driverId,
      token: currentAuthenticationToken,
      isActive: value,
    );

    setState(() => _updatingActiveIds.remove(driverId));

    if (res.succeeded) {
      await _refreshDrivers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      child: Scaffold(
      drawer: buildAdminDrawer(context),
      appBar: AppBar(
        title: const Text("Drivers"),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: FutureBuilder<ApiCallResponse>(
        future: _driversFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = GetDriversCall.data(snapshot.data!.jsonBody) ?? [];

          return RefreshIndicator(
            onRefresh: _refreshDrivers,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final d = list[index];

                final name =
                    "${getJsonField(d, r'''$.first_name''') ?? ''} ${getJsonField(d, r'''$.last_name''') ?? ''}";
                final phone =
                    getJsonField(d, r'''$.mobile_number''')?.toString() ?? '';
                final vehicle =
                    getJsonField(d, r'''$.vehicle_number''')?.toString() ??
                        'No Vehicle';
                final img =
                getJsonField(d, r'''$.profile_image''')?.toString();
                final id = castToType<int>(getJsonField(d, r'''$.id'''));

                final active = _parseBool(
                    getJsonField(d, r'''$.is_active'''));

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SafeNetworkAvatar(
                        imageUrl: img ?? '',
                        radius: 28,
                      ),
                      const SizedBox(width: 12),

                      /// INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(phone),
                            Text(vehicle),
                          ],
                        ),
                      ),

                      /// SWITCH
                      Switch(
                        value: active,
                        onChanged: id == null
                            ? null
                            : (val) => _updateActiveStatus(id, val),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }
}