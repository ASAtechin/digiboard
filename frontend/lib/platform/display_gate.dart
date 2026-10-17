// What a platform-connected screen shows: the pairing code, or the timetable
// with an honest banner whenever it is not live.
import 'package:flutter/material.dart';
import '../screens/timetable_carousel_screen.dart';
import 'display_controller.dart';

class DisplayGate extends StatelessWidget {
  final DisplayController controller;
  const DisplayGate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
          case DisplayStatus.live:
          case DisplayStatus.offlineCached:
          case DisplayStatus.unavailable:
            return Stack(
              children: [
                const TimetableCarouselScreen(key: ValueKey('timetable')),
                if (controller.status != DisplayStatus.live)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ConnectionBanner(controller: controller),
                  ),
              ],
            );
        }
      },
    );
  }
}

class ConnectionBanner extends StatelessWidget {
  final DisplayController controller;
  const ConnectionBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final offline = controller.status == DisplayStatus.offlineCached;
    final saved = controller.savedAt;
    final time = saved == null
        ? ''
        : ' (saved ${saved.hour.toString().padLeft(2, '0')}:${saved.minute.toString().padLeft(2, '0')})';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
      color: offline ? Colors.blueGrey.shade700 : Colors.red.shade800,
      child: Text(
        offline
            ? 'Offline: showing today\'s saved timetable$time. Changes made since then are not shown.'
            : 'Timetable unavailable: no connection, and no saved timetable for today.',
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
