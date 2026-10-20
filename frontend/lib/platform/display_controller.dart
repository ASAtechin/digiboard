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

  /// Paired, but the school's plan does not include DigiBoard screens.
  notActive,
}

class DisplayController extends ChangeNotifier {
  static const tokenKey = 'platform.deviceToken';
  static const feedKey = 'platform.cachedFeed';
  static const savedAtKey = 'platform.cachedAt';
  static const appVersion = '2.2.0';
  static const logoKey = 'platform.logo';
  static const logoVersionKey = 'platform.logoVersion';

  final PlatformClient client;
  final DisplayStore store;
  final DateTime Function() now;

  DisplayController({
    required this.client,
    required this.store,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now {
    startedAt = this.now();
  }

  /// When the app started, for the admin's screen health.
  late final DateTime startedAt;

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

  /// Notices still trustworthy: each leaves the screen when its own expiry
  /// passes without a newer feed (they can be withdrawn at any moment).
  List<ScreenNotice> get notices {
    final f = feed;
    if (!_showingFeed || f == null || !_alive(f.lifetimeOf('notices'))) return const [];
    return f.notices.where((n) => _alive(f.lifetimeUntil(n.expiresAt))).toList();
  }

  /// Cards (events, substitutions, other modules' cards) that have not expired.
  List<ScreenCard> get cards {
    final f = feed;
    if (!_showingFeed || f == null) return const [];
    return f.cards.where((c) => _alive(f.lifetimeOf(c.type)) && _alive(f.lifetimeUntil(c.expiresAt))).toList();
  }

  bool get _showingFeed => status == DisplayStatus.live || status == DisplayStatus.offlineCached;

  /// How long ago the feed on screen arrived, on this screen's clock.
  Duration? get age => savedAt == null ? null : now().difference(savedAt!);

  bool _alive(Duration? lifetime) => lifetime == null || age == null || age! < lifetime;

  /// When the content on screen last came from the platform.
  DateTime? get lastUpdated => feed == null ? null : savedAt;

  /// True when the screen cannot say its content is up to date: offline, or
  /// no newer feed within the time the last one was good for.
  bool get isStale {
    final f = feed;
    if (f == null || savedAt == null) return false;
    return status == DisplayStatus.offlineCached || age! > f.freshFor;
  }

  ScreenMode? get mode => feed?.mode;

  /// Inside the screen's on hours (decided on this screen's clock). Without a feed it stays on.
  bool get onHours => feed?.hours.isOn(now()) ?? true;

  /// What the screen shows now, as the admin's health table names it.
  String get shownState {
    switch (status) {
      case DisplayStatus.notActive:
        return 'not_active';
      case DisplayStatus.unavailable:
        return 'unavailable';
      case DisplayStatus.offlineCached:
        return onHours ? 'offline_cached' : 'off_hours';
      case DisplayStatus.live:
        if (!onHours) return 'off_hours';
        return isStale ? 'stale' : 'live';
      case DisplayStatus.starting:
      case DisplayStatus.pairing:
        return 'unavailable';
    }
  }

  /// One line on what the screen shows, for the admin.
  String get shownSummary {
    final f = feed;
    switch (shownState) {
      case 'not_active':
        return "DigiBoard is not in this school's plan";
      case 'unavailable':
        return 'Timetable unavailable: offline, nothing saved for today';
      case 'off_hours':
        return 'Off hours: ${f?.hours.offDisplay == 'dim' ? 'dimmed' : 'clock'}';
    }
    final parts = <String>[f?.summary ?? '${lectures.length} lessons today'];
    if (f != null && (notices.length < f.notices.length || cards.length < f.cards.length)) {
      parts.add('expired notices or cards taken off');
    }
    final saved = lastUpdated;
    if (isStale && saved != null) {
      parts.add('not updated since ${saved.hour.toString().padLeft(2, '0')}:${saved.minute.toString().padLeft(2, '0')}');
    }
    final text = parts.join(' · ');
    return text.length > 200 ? text.substring(0, 200) : text;
  }
  bool _disposed = false;

  bool get isPaired => _token != null;

  /// The school's logo, fetched when its version changes and kept for offline use.
  Uint8List? logo;
  String? _logoVersion;

  ScreenBranding? get branding => feed?.branding;

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
    } on ScreenRevoked {
      await _forget(token);
      return;
    } on ModuleNotEnabled {
      // Not the school's plan: keep the credential, show why, and check again later.
      feed = null;
      status = DisplayStatus.notActive;
      _schedule(const Duration(minutes: 5));
    } on PlatformUnreachable {
      await _useSaved();
      _schedule(const Duration(seconds: 30));
    }
    _notify();
    // Every refresh reports what the screen shows; when the platform is unreachable it fails quietly.
    if (_token == token) unawaited(_heartbeat(token));
    if (status == DisplayStatus.live) unawaited(_refreshLogo(token));
  }

  Future<void> _refreshLogo(String token) async {
    final version = feed?.branding.logoVersion;
    if (version == _logoVersion && (logo != null || version == null)) return;
    if (version == null) {
      logo = null;
      _logoVersion = null;
      await store.delete(logoKey);
      await store.delete(logoVersionKey);
      _notify();
      return;
    }
    try {
      final bytes = await client.fetchLogo(token);
      logo = bytes;
      _logoVersion = version;
      if (bytes != null) {
        await store.write(logoKey, base64.encode(bytes));
        await store.write(logoVersionKey, version);
      }
      _notify();
    } on ScreenRevoked {
      await _forget(token);
    } on PlatformUnreachable {
      // Keep the logo we have; try again on the next refresh.
    }
  }

  Future<void> _readSavedLogo() async {
    if (logo != null) return;
    final saved = await store.read(logoKey);
    if (saved == null) return;
    try {
      logo = base64.decode(saved);
      _logoVersion = await store.read(logoVersionKey);
    } catch (_) {
      logo = null;
    }
  }

  /// Offline: today's saved feed is still right for today; any other day's is not.
  Future<void> _useSaved() async {
    await _readSavedLogo();
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

  Future<void> _heartbeat(String token) async {
    final state = shownState;
    try {
      await client.heartbeat(
        token,
        status: switch (status) {
          DisplayStatus.live => 'live',
          DisplayStatus.offlineCached => 'offline_cached',
          _ => 'unavailable',
        },
        appVersion: appVersion,
        state: state,
        mode: feed == null ? null : modeName(feed!.mode),
        contentHash: feed?.contentHash,
        summary: shownSummary,
        startedAt: startedAt,
        screenTime: now(),
      );
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
    logo = null;
    _logoVersion = null;
    wasRevoked = true;
    status = DisplayStatus.pairing;
    _refreshTimer?.cancel();
    _notify();
    final done = () async {
      await store.delete(tokenKey);
      await store.delete(feedKey);
      await store.delete(savedAtKey);
      await store.delete(logoKey);
      await store.delete(logoVersionKey);
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
