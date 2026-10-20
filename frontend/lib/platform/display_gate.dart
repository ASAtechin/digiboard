// What a platform-connected screen shows: the pairing code; the timetable
// (classroom and lobby) or the staff room's substitutions, with when it last
// updated and an honest banner whenever it is not live; a clock outside its
// hours. Drills always show.
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../screens/timetable_carousel_screen.dart';
import 'display_controller.dart';
import 'display_models.dart';
import 'screen_widgets.dart';

class DisplayGate extends StatefulWidget {
  final DisplayController controller;
  const DisplayGate({super.key, required this.controller});

  @override
  State<DisplayGate> createState() => _DisplayGateState();
}

class _DisplayGateState extends State<DisplayGate> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Staleness, expiry and on and off hours change with time, between the platform's answers.
    _tick = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        switch (controller.status) {
          case DisplayStatus.starting:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case DisplayStatus.pairing:
            return PairingScreen(controller: controller);
          case DisplayStatus.notActive:
            return const NotActiveScreen();
          case DisplayStatus.live:
          case DisplayStatus.offlineCached:
          case DisplayStatus.unavailable:
            // During a drill nothing may cover the alert, and it shows at any hour.
            final calm = controller.alerts.isEmpty;
            if (calm && !controller.onHours) return OffHoursScreen(controller: controller);
            final notices = calm ? controller.notices : const <ScreenNotice>[];
            final branding = calm ? controller.branding : null;
            final staffRoom = controller.mode == ScreenMode.staffRoom;
            final cards = calm ? controller.cards.where((c) => c.type != 'timetable.substitution').toList() : const <ScreenCard>[];
            return Stack(
              children: [
                if (staffRoom)
                  StaffRoomScreen(controller: controller)
                else
                  const TimetableCarouselScreen(key: ValueKey('timetable')),
                if (!staffRoom && branding != null && branding.schoolName.isNotEmpty)
                  Positioned(
                    top: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: BrandStrip(branding: branding, logo: controller.logo),
                    ),
                  ),
                if (calm)
                  Positioned(
                    top: 4,
                    right: 16,
                    child: LastUpdatedBadge(controller: controller),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!staffRoom) CardsStrip(cards: cards, colour: branding?.primaryColor),
                      if (!staffRoom && notices.isNotEmpty) NoticeBar(notices: notices, colour: branding?.primaryColor),
                      if (controller.status != DisplayStatus.live || controller.isStale)
                        ConnectionBanner(controller: controller),
                    ],
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}

/// Notices from the school, one line each.
class NoticeBar extends StatelessWidget {
  final List<ScreenNotice> notices;
  final Color? colour;
  const NoticeBar({super.key, required this.notices, this.colour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
      color: (colour ?? const Color(0xFF1E3A8A)).withValues(alpha: 0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final n in notices.take(3))
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${n.title}  ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: n.body),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
        ],
      ),
    );
  }
}

/// The school's logo and name at the top of every screen, in its own colour.
class BrandStrip extends StatelessWidget {
  final ScreenBranding branding;
  final Uint8List? logo;
  const BrandStrip({super.key, required this.branding, this.logo});

  @override
  Widget build(BuildContext context) {
    final colour = branding.primaryColor ?? Colors.white24;
    return Container(
      key: const ValueKey('brand-strip'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: colour, width: 3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(logo!, width: 40, height: 40, fit: BoxFit.contain, gaplessPlayback: true),
            ),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                branding.schoolName,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              if (branding.tagline != null)
                Text(
                  branding.tagline!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paired, but the school's plan does not include DigiBoard screens.
class NotActiveScreen extends StatelessWidget {
  const NotActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Text(
            'DigiBoard is not active for this school.\nPlease contact the school office.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 32, height: 1.5),
          ),
        ),
      ),
    );
  }
}

class ConnectionBanner extends StatelessWidget {
  final DisplayController controller;
  const ConnectionBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final offline = controller.status == DisplayStatus.offlineCached;
    final unavailable = controller.status == DisplayStatus.unavailable;
    final saved = controller.savedAt;
    final at = saved == null ? '' : '${saved.hour.toString().padLeft(2, '0')}:${saved.minute.toString().padLeft(2, '0')}';
    final time = saved == null ? '' : ' (saved $at)';
    return Container(
      key: const ValueKey('connection-banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
      color: unavailable ? Colors.red.shade800 : Colors.blueGrey.shade700,
      child: Text(
        unavailable
            ? 'Timetable unavailable: no connection, and no saved timetable for today.'
            : offline
            ? 'Offline: showing today\'s saved timetable$time. Changes made since then are not shown.'
            : 'Not updated since $at: this screen cannot confirm it is up to date. Changes made since then are not shown.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PairingScreen extends StatelessWidget {
  final DisplayController controller;
  const PairingScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final pairing = controller.pairing;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          // Scales down to fit any screen size; signage is usually 1920x1080.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.wasRevoked) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.shade800,
                    child: const Text(
                      'This screen was removed by the school. Ask an administrator to pair it again.',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                const Text(
                  'Pair this screen',
                  style: TextStyle(color: Colors.white70, fontSize: 28),
                ),
                const SizedBox(height: 24),
                Text(
                  pairing?.code ?? 'Connecting…',
                  key: const ValueKey('pairing-code'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  pairing == null
                      ? 'Waiting for a connection to Shiksha Tantra.'
                      : 'In the Shiksha Tantra admin, open Screens, choose Add screen, and enter this code.\nThe code changes every 10 minutes.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
