import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '/core/network/api_config.dart';

/// Server-Sent Events for `/api/admins/finance/events/stream` with Bearer auth (Flutter-friendly).
class AdminFinanceEventsSseClient {
  AdminFinanceEventsSseClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;
  StreamSubscription<String>? _lineSub;

  /// [sinceId] replays persisted events before live stream (backend-supported).
  /// Returns whether the HTTP stream was opened (listen active until [disconnect]).
  Future<bool> connect({
    required String token,
    int sinceId = 0,
    required void Function(Map<String, dynamic> event) onEvent,
    void Function(Object error)? onError,
  }) async {
    await disconnect();
    final uri = Uri.parse('${ApiConfig.apiBase}/admins/finance/events/stream').replace(
      queryParameters: {'since_id': '$sinceId'},
    );
    final req = http.Request('GET', uri)..headers['Authorization'] = 'Bearer $token';
    final streamed = await _client.send(req);
    if (streamed.statusCode != 200) {
      onError?.call(Exception('SSE HTTP ${streamed.statusCode}'));
      return false;
    }
    final lines = streamed.stream.transform(utf8.decoder).transform(const LineSplitter());
    _lineSub = lines.listen(
      (line) {
        if (line.startsWith('data:')) {
          final raw = line.startsWith('data: ') ? line.substring(6) : line.substring(5);
          try {
            final decoded = json.decode(raw.trim());
            if (decoded is Map<String, dynamic>) {
              onEvent(decoded);
            } else if (decoded is Map) {
              onEvent(Map<String, dynamic>.from(decoded));
            }
          } catch (_) {}
        }
      },
      onError: onError,
      cancelOnError: false,
    );
    return true;
  }

  Future<void> disconnect() async {
    await _lineSub?.cancel();
    _lineSub = null;
  }

  void close() {
    disconnect();
    _client.close();
  }
}
