// HTTP calls a screen makes to the Shiksha Tantra platform.
//
// The one rule that matters: a 401 means this screen's credential was revoked;
// anything else that fails (no network, timeout, server error) means "offline",
// and the screen keeps showing what it already has.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'display_models.dart';

class ScreenRevoked implements Exception {
  @override
  String toString() => 'This screen has been removed by the school.';
}

class PlatformUnreachable implements Exception {
  final String reason;
  PlatformUnreachable(this.reason);
  @override
  String toString() => 'Platform unreachable: $reason';
}

class PairingRequest {
  final String code;
  final String pollToken;
  final DateTime expiresAt;
  final int pollIntervalSeconds;
  PairingRequest(
    this.code,
    this.pollToken,
    this.expiresAt,
    this.pollIntervalSeconds,
  );
}

/// Result of polling a pairing request: still waiting, expired, or paired with a credential.
class PairingPoll {
  final String status; // pending | paired | expired | invalid
  final String? deviceToken;
  PairingPoll(this.status, [this.deviceToken]);
}

class PlatformClient {
  final String baseUrl; // e.g. https://api.example.com/v1
  final http.Client http_;
  final Duration timeout;

  PlatformClient(
    this.baseUrl, {
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : http_ = client ?? http.Client();

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw PlatformUnreachable('timeout');
    } catch (e) {
      if (e is PlatformUnreachable) rethrow;
      throw PlatformUnreachable(e.toString());
    }
  }

  Map<String, dynamic> _json(http.Response r) {
    final body = json.decode(r.body);
    if (body is! Map<String, dynamic>) {
      throw PlatformUnreachable('unexpected response');
    }
    return body;
  }

  Future<PairingRequest> startPairing() async {
    final r = await _send(() => http_.post(_uri('/device/pairing')));
    if (r.statusCode != 201) {
      throw PlatformUnreachable('pairing HTTP ${r.statusCode}');
    }
    final b = _json(r);
    return PairingRequest(
      b['code'] as String,
      b['pollToken'] as String,
      DateTime.parse(b['expiresAt'] as String),
      (b['pollIntervalSeconds'] as num?)?.toInt() ?? 3,
    );
  }

  Future<PairingPoll> pollPairing(String pollToken) async {
    final r = await _send(
      () => http_.post(
        _uri('/device/pairing/poll'),
        headers: {'content-type': 'application/json'},
        body: json.encode({'pollToken': pollToken}),
      ),
    );
    if (r.statusCode == 202) return PairingPoll('pending');
    if (r.statusCode == 200) {
      return PairingPoll('paired', _json(r)['deviceToken'] as String?);
    }
    if (r.statusCode == 410) {
      return PairingPoll(_json(r)['status']?.toString() ?? 'expired');
    }
    throw PlatformUnreachable('poll HTTP ${r.statusCode}');
  }

  Future<DisplayFeed> fetchFeed(String deviceToken) async {
    final r = await _send(
      () => http_.get(
        _uri('/display/feed'),
        headers: {'authorization': 'Bearer $deviceToken'},
      ),
    );
    if (r.statusCode == 401) throw ScreenRevoked();
    if (r.statusCode != 200) {
      throw PlatformUnreachable('feed HTTP ${r.statusCode}');
    }
    return DisplayFeed.fromJson(_json(r));
  }

  Future<void> heartbeat(
    String deviceToken, {
    required String status,
    String? appVersion,
  }) async {
    final r = await _send(
      () => http_.post(
        _uri('/display/heartbeat'),
        headers: {
          'authorization': 'Bearer $deviceToken',
          'content-type': 'application/json',
        },
        body: json.encode({
          'status': status,
          if (appVersion != null) 'appVersion': appVersion,
        }),
      ),
    );
    if (r.statusCode == 401) throw ScreenRevoked();
    if (r.statusCode != 200) {
      throw PlatformUnreachable('heartbeat HTTP ${r.statusCode}');
    }
  }
}
