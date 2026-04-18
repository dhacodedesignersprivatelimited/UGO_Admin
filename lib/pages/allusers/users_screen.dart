import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/components/admin_pop_scope.dart';
import '/components/safe_network_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  static String routeName = 'UsersScreen';

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<ApiCallResponse> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = AllUsersCall.call(
      token: currentAuthenticationToken,
    );
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = AllUsersCall.call(
        token: currentAuthenticationToken,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      child: Scaffold(
      drawer: buildAdminDrawer(context),
      appBar: AppBar(
        title: const Text("Users"),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: FutureBuilder<ApiCallResponse>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list =
              AllUsersCall.usersdata(snapshot.data!.jsonBody) ?? [];

          return RefreshIndicator(
            onRefresh: _refreshUsers,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final u = list[index];

                final name =
                    getJsonField(u, r'''$.name''')?.toString() ?? '';
                final phone =
                    getJsonField(u, r'''$.mobile_number''')?.toString() ?? '';
                final email =
                    getJsonField(u, r'''$.email''')?.toString() ?? '';
                final img =
                getJsonField(u, r'''$.profile_image''')?.toString();

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
                        radius: 26,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(phone),
                            if (email.isNotEmpty) Text(email),
                          ],
                        ),
                      ),

                      const Icon(Icons.chevron_right)
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