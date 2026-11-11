// What a platform-connected screen shows: the pairing code; the timetable
// (classroom and lobby) or the staff room's substitutions, with when it last
// updated and an honest banner whenever it is not live; a clock outside its
// hours. Drills always show.
//
// Look: "Forest night" (lib/themes/design_system.dart). The school's own
// colour is a guest: a 3 px rule on its brand strip, the edge of its cards
// and the top of its notice bar, never the background.
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../screens/timetable_carousel_screen.dart';
import '../themes/design_system.dart';
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

  /// The small label over the date: the room a classroom screen hangs in, or the whole school.
  String? _eyebrowFor(DisplayController controller) {
    final mode = controller.mode;
    if (mode == ScreenMode.classroom) return controller.feed?.roomName;
    if (mode == ScreenMode.lobby) return 'Whole school';
    return null;
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
              backgroundColor: DesignSystem.background,
              body: Center(child: CircularProgressIndicator(color: DesignSystem.primary)),
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
            // The cards, notices and connection banner sit under the timetable, not over it, so
            // they never cover a lesson. They are laid out for a 1920 px wide screen and scaled
            // down on a narrower one, like the rest of the layout.
            // Text drawn over the timetable sits outside its Scaffold: give it the app's text style.
            return Material(
              color: DesignSystem.background,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: staffRoom
                            ? StaffRoomScreen(controller: controller)
                            : TimetableCarouselScreen(key: const ValueKey('timetable'), eyebrow: _eyebrowFor(controller)),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) => FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: math.max(constraints.maxWidth, 1920.0),
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
                        ),
                      ),
                    ],
                  ),
                  // When the screen cannot confirm the alert status, its amber bar needs the whole width at the top.
                  if (!staffRoom && branding != null && branding.schoolName.isNotEmpty && !controller.alertStatusUnknown)
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
                      top: 6,
                      right: 16,
                      child: Transform.scale(
                        scale: DesignSystem.scaleFor(MediaQuery.sizeOf(context).width),
                        alignment: Alignment.topRight,
                        child: LastUpdatedBadge(controller: controller),
                      ),
                    ),
                ],
              ),
            );
        }
      },
    );
  }
}

/// Notices from the school, one line each: a bar on the popover colour, with the
/// school's own colour (when it has one) as a 3 px rule on top and gold otherwise.
class NoticeBar extends StatelessWidget {
  final List<ScreenNotice> notices;
  final Color? colour;
  const NoticeBar({super.key, required this.notices, this.colour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
      decoration: BoxDecoration(
        color: DesignSystem.popover,
        border: Border(top: BorderSide(color: DesignSystem.guest(colour) ?? DesignSystem.gold, width: 3)),
      ),
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
                    style: DesignSystem.sans(size: 24, weight: FontWeight.w700, color: DesignSystem.primary),
                  ),
                  TextSpan(text: n.body),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DesignSystem.sans(size: 24, height: 1.35),
            ),
        ],
      ),
    );
  }
}

/// The school's logo and name at the top of every screen: a card with a hairline
/// border, the name in serif, and the school's own colour as a 3 px bar at its foot.
class BrandStrip extends StatelessWidget {
  final ScreenBranding branding;
  final Uint8List? logo;
  const BrandStrip({super.key, required this.branding, this.logo});

  @override
  Widget build(BuildContext context) {
    final colour = DesignSystem.guest(branding.primaryColor) ?? DesignSystem.gold;
    return Container(
      key: const ValueKey('brand-strip'),
      clipBehavior: Clip.antiAlias,
      decoration: DesignSystem.cardDecoration(),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (logo != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                      child: Image.memory(logo!, width: 44, height: 44, fit: BoxFit.contain, gaplessPlayback: true),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        branding.schoolName,
                        style: DesignSystem.serif(size: 26, height: 1.2),
                      ),
                      if (branding.tagline != null)
                        Text(
                          branding.tagline!,
                          style: DesignSystem.sans(size: 16, color: DesignSystem.mutedForeground),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 3, color: colour),
          ],
        ),
      ),
    );
  }
}

/// Paired, but the school's plan does not include DigiBoard screens.
class NotActiveScreen extends StatelessWidget {
  const NotActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'DigiBoard is not active for this school.',
                      style: DesignSystem.serif(size: 48, height: 1.3),
                    ),
                    TextSpan(
                      text: '\nPlease contact the school office.',
                      style: DesignSystem.sans(size: 30, color: DesignSystem.mutedForeground, height: 1.8),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(width: DesignSystem.ruleWidth, height: DesignSystem.ruleHeight, color: DesignSystem.gold),
            ],
          ),
        ),
      ),
    );
  }
}

/// The honest line at the foot of the screen whenever it is not live: offline
/// with today's saved timetable, not updated, or nothing to show. Information
/// (offline, not updated) is blue-green with a rule in the info colour; nothing
/// to show is red. Ivory text on both, over 11:1.
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
    final rule = unavailable ? DesignSystem.destructive : DesignSystem.info;
    return Container(
      key: const ValueKey('connection-banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
      decoration: BoxDecoration(
        color: unavailable ? DesignSystem.dangerSoft : DesignSystem.infoSoft,
        border: Border(top: BorderSide(color: rule, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(unavailable ? Icons.error_outline_rounded : Icons.cloud_off_rounded, color: rule, size: 28),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              unavailable
                  ? 'Timetable unavailable: no connection, and no saved timetable for today.'
                  : offline
                  ? 'Offline: showing today\'s saved timetable$time. Changes made since then are not shown.'
                  : 'Not updated since $at: this screen cannot confirm it is up to date. Changes made since then are not shown.',
              textAlign: TextAlign.center,
              style: DesignSystem.sans(size: 22, weight: FontWeight.w700, height: 1.3),
            ),
          ),
        ],
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
      backgroundColor: DesignSystem.background,
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
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    decoration: DesignSystem.cardDecoration(color: DesignSystem.dangerSoft, borderColor: DesignSystem.destructive),
                    child: Text(
                      'This screen was removed by the school. Ask an administrator to pair it again.',
                      style: DesignSystem.sans(size: 24, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
                Text(
                  'Pair this screen',
                  style: DesignSystem.serif(size: 56, height: 1.2),
                ),
                const SizedBox(height: 16),
                Container(width: DesignSystem.ruleWidth, height: DesignSystem.ruleHeight, color: DesignSystem.gold),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
                  decoration: DesignSystem.cardDecoration(),
                  child: Text(
                    pairing?.code ?? 'Connecting…',
                    key: const ValueKey('pairing-code'),
                    style: DesignSystem.serif(size: 112, color: DesignSystem.primary, letterSpacing: 12, figures: true),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  pairing == null
                      ? 'Waiting for a connection to Shiksha Tantra.'
                      : 'In the Shiksha Tantra admin, open Screens, choose Add screen, and enter this code.\nThe code changes every 10 minutes.',
                  textAlign: TextAlign.center,
                  style: DesignSystem.sans(size: 26, color: DesignSystem.mutedForeground, height: 1.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
