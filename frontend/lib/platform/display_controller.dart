// The screen's state: pairing, live, offline with today's saved timetable,
// unavailable, or revoked. Screens read lessons from here.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/lecture.dart';
import 'display_models.dart';
import 'display_store.dart';
import 'platform_client.dart';

enum DisplayStatus {
  starting,

  /// Showing a code for staff to enter in the admin.
  pairing,

  /// Data confirmed by the platform within the last refresh.
  live,

  /// The platform cannot be reached; showing today's saved timetable.
  offlineCached,

  /// The platform cannot be reached and nothing saved is for today.
  unavailable,
}

class DisplayController extends ChangeNotifier {
  static const tokenKey = 'platform.deviceToken';
  static const feedKey = 'platform.cachedFeed';
  static const savedAtKey = 'platform.cachedAt';
  static const appVersion = '2.0.0';

  final PlatformClient client;
  final DisplayStore store;
  final DateTime Function() now;

  DisplayController({
    required this.client,
    required this.store,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  DisplayStatus status = DisplayStatus.starting;
  PairingRequest? pairing;

  /// Set when this screen was revoked, until it is paired again.
  bool wasRevoked = false;
  DisplayFeed? feed;
  DateTime? savedAt;
  String? _token;
  Timer? _refreshTimer;
  Timer? _pollTimer;
  Timer? _alertTimer;

  /// The alerts last confirmed by the platform, and until when that confirmation holds.
  List<ScreenAlert> alerts = const [];
  DateTime? _alertsTrustedUntil;

  /// True unless a recent answer from the platform confirms the alert status.
  /// Silence is never an all-clear (COM-F04, INV-7).
  bool get alertStatusUnknown =>
      _alertsTrustedUntil == null || now().isAfter(_alertsTrustedUntil!);

  List<ScreenNotice> get notices =>
      (status == DisplayStatus.live || status == DisplayStatus.offlineCached) &&
          feed != null
      ? feed!.notices
      : const [];
  bool _disposed = false;

  bool get isPaired => _token != null;

  /// Today's lessons, or none when nothing trustworthy is available.
  List<Lecture> get lectures =>
      (status == DisplayStatus.live || status == DisplayStatus.offlineCached) &&
          feed != null
      ? feed!.toLectures()
      : const [];

  Future<void> start() async {
    _token = await store.read(tokenKey);
    if (_token == null) {
      await beginPairing();
    } else {
      await refresh();
      await pollAlerts();
    }
  }

  // --- Alerts ---

  Future<void> pollAlerts() async {
    final token = _token;
    _alertTimer?.cancel();
    if (token == null || _disposed) return;
    var next = const Duration(seconds: 10);
    try {
      final answer = await client.fetchAlerts(token);
      alerts = answer.alerts;
      _alertsTrustedUntil = now().add(answer.lifetime);
      next = Duration(seconds: answer.pollAfterSeconds);
    } on ScreenRevoked {
      await _forget(token);
      return;
    } on PlatformUnreachable {
      // Keep showing the last confirmed alerts; alertStatusUnknown turns true once they are no longer trustworthy.
    }
    _notify();
    if (!_disposed && _token != null) _alertTimer = Timer(next, pollAlerts);
  }

  // --- Pairing ---

  Future<void> beginPairing() async {
    _pollTimer?.cancel();
    try {
      pairing = await client.startPairing();
      status = DisplayStatus.pairing;
      _notify();
      _pollTimer = Timer.periodic(
        Duration(seconds: pairing!.pollIntervalSeconds),
        (_) => pollPairing(),
      );
    } on PlatformUnreachable {
      pairing = null;
      status = DisplayStatus.pairing;
      _notify();
      _pollTimer = Timer(const Duration(seconds: 10), beginPairing);
    }
  }

  Future<void> pollPairing() async {
    final request = pairing;
    if (request == null) return;
    try {
      final result = await client.pollPairing(request.pollToken);
      if (result.status == 'paired' && result.deviceToken != null) {
        _pollTimer?.cancel();
        _token = result.deviceToken;
        await store.write(tokenKey, _token!);
        pairing = null;
        wasRevoked = false;
        await refresh();
        await pollAlerts();
      } else if (result.status != 'pending' ||
          now().isAfter(request.expiresAt)) {
        await beginPairing();
      }
    } on PlatformUnreachable {
      // Keep the code on screen and try again on the next tick.
    }
  }

  // --- Feed ---

  Future<void> refresh() async {
    final token = _token;
    if (token == null) return beginPairing();
    _refreshTimer?.cancel();
    try {
      final fresh = await client.fetchFeed(token);
      feed = fresh;
      savedAt = now();
      await store.write(feedKey, json.encode(fresh.raw));
      await store.write(savedAtKey, savedAt!.toIso8601String());
      status = DisplayStatus.live;
      _schedule(Duration(seconds: fresh.refreshAfterSeconds));
      unawaited(_heartbeat(token, 'live'));
    } on ScreenRevoked {
      await _forget(token);
      return;
    } on PlatformUnreachable {
      await _useSaved();
      _schedule(const Duration(seconds: 30));
    }
    _notify();
  }

  /// Offline: today's saved feed is still right for today; any other day's is not.
  Future<void> _useSaved() async {
    final saved = feed ?? await _readSaved();
    final today = localDateString(now());
    if (saved != null && saved.date == today) {
      feed = saved;
      savedAt ??= DateTime.tryParse(await store.read(savedAtKey) ?? '');
      status = DisplayStatus.offlineCached;
    } else {
      feed = null;
      status = DisplayStatus.unavailable;
    }
  }

  Future<DisplayFeed?> _readSaved() async {
    final text = await store.read(feedKey);
    if (text == null) return null;
    try {
      return DisplayFeed.fromJson(json.decode(text) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _heartbeat(String token, String state) async {
    try {
      await client.heartbeat(token, status: state, appVersion: appVersion);
    } on ScreenRevoked {
      await _forget(token);
      _notify();
    } on PlatformUnreachable {
      // The next feed refresh decides whether we are offline.
    }
  }

  Future<void>? _forgetting;

  /// Revoked: drop the credential and everything saved, then ask to be paired again.
  /// A refresh and a heartbeat may both hear "revoked"; they share one forget
  /// and one new pairing. The screen stops showing data immediately.
  Future<void> _forget(String revokedToken) {
    final inFlight = _forgetting;
    if (inFlight != null) return inFlight;
    if (_token != revokedToken) return Future.value();
    _token = null;
    feed = null;
    savedAt = null;
    pairing = null;
    alerts = const [];
    _alertsTrustedUntil = null;
    _alertTimer?.cancel();
    wasRevoked = true;
    status = DisplayStatus.pairing;
    _refreshTimer?.cancel();
    _notify();
    final done = () async {
      await store.delete(tokenKey);
      await store.delete(feedKey);
      await store.delete(savedAtKey);
      await beginPairing();
    }();
    _forgetting = done.whenComplete(() => _forgetting = null);
    return _forgetting!;
  }

  void _schedule(Duration after) {
    _refreshTimer?.cancel();
    if (_disposed) return;
    _refreshTimer = Timer(after, refresh);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    _pollTimer?.cancel();
    _alertTimer?.cancel();
    super.dispose();
  }
}
