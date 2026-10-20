// What a platform screen draws around (or instead of) the timetable: when it
// last updated, cards, the staff room's substitutions, the off-hours clock,
// and drills on screens that do not show the timetable.
import 'package:flutter/material.dart';
import 'display_controller.dart';
import 'display_models.dart';

String _hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "Updated 09:12", or, when the screen cannot say it is up to date, "Not updated since 09:12".
class LastUpdatedBadge extends StatelessWidget {
  final DisplayController controller;
  const LastUpdatedBadge({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final at = controller.lastUpdated;
    if (at == null) return const SizedBox.shrink();
    final stale = controller.isStale;
    return Container(
      key: const ValueKey('last-updated'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: stale ? Colors.amber.shade700 : Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stale ? Icons.history_rounded : Icons.circle, size: stale ? 18 : 10, color: stale ? Colors.black : Colors.greenAccent),
          const SizedBox(width: 8),
          Text(
            stale ? 'Not updated since ${_hhmm(at)}' : 'Updated ${_hhmm(at)}',
            style: TextStyle(color: stale ? Colors.black : Colors.white70, fontSize: stale ? 16 : 13, fontWeight: stale ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Up to three cards in a row: events, announcements and other modules' cards.
class CardsStrip extends StatelessWidget {
  final List<ScreenCard> cards;
  final Color? colour;
  const CardsStrip({super.key, required this.cards, this.colour});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in cards.take(3)) ...[
            Expanded(child: CardTile(card: c, colour: colour)),
            if (c != cards.take(3).last) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

/// One card. Events get a date line; every other type is drawn from its labelled lines.
class CardTile extends StatelessWidget {
  final ScreenCard card;
  final Color? colour;
  const CardTile({super.key, required this.card, this.colour});

  @override
  Widget build(BuildContext context) {
    final isEvent = card.type == 'screens.event';
    final title = isEvent ? card.text('title') ?? '' : card.heading;
    final lines = isEvent
        ? card.lines.where((l) => !const {'Kind', 'Title'}.contains(l.label)).toList()
        : card.lines;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: colour ?? Colors.orangeAccent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEvent ? (card.text('kind') == 'announcement' ? 'ANNOUNCEMENT' : card.heading.toUpperCase()) : card.heading.toUpperCase(),
            style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          if (isEvent)
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          for (final l in lines.take(4))
            Text(
              isEvent && const {'Details'}.contains(l.label) ? l.text : '${l.label}: ${l.text}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
        ],
      ),
    );
  }
}

/// A drill (or "alert status unavailable") for screens that do not show the
/// timetable screen's own alert banner: the staff room and off hours.
class AlertStrip extends StatelessWidget {
  final DisplayController controller;
  const AlertStrip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final alerts = controller.alerts;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in alerts)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            color: a.severity == 'emergency' ? Colors.red.shade900 : a.severity == 'warning' ? Colors.orange.shade900 : Colors.blue.shade900,
            child: Text(
              a.displayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        if (controller.alertStatusUnknown)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
            color: Colors.amber.shade800,
            child: const Text(
              'Alert status unavailable: this screen cannot reach the school server. Follow staff instructions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

/// Outside the screen's hours: a clock and the school's name, or almost nothing.
class OffHoursScreen extends StatelessWidget {
  final DisplayController controller;
  const OffHoursScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final now = controller.now();
    final dim = controller.feed?.hours.offDisplay == 'dim';
    final school = controller.branding?.schoolName ?? '';
    return Scaffold(
      key: const ValueKey('off-hours'),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hhmm(now),
                  style: TextStyle(color: dim ? Colors.white24 : Colors.white, fontSize: dim ? 40 : 140, fontWeight: FontWeight.w200),
                ),
                if (!dim && school.isNotEmpty)
                  Text(school, style: const TextStyle(color: Colors.white54, fontSize: 28)),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: AlertStrip(controller: controller)),
        ],
      ),
    );
  }
}

/// The staff room: today's substitutions still to come (staff names allowed
/// here, never anything about a student), staff notices and events.
class StaffRoomScreen extends StatelessWidget {
  final DisplayController controller;
  const StaffRoomScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final now = controller.now();
    final cards = controller.cards;
    final subs = cards.where((c) => c.type == 'timetable.substitution').toList();
    final others = cards.where((c) => c.type != 'timetable.substitution').toList();
    final notices = controller.notices;
    final school = controller.branding?.schoolName ?? '';
    const head = TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w700);
    const cell = TextStyle(color: Colors.white, fontSize: 20);
    return Scaffold(
      key: const ValueKey('staff-room'),
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 32, 40, 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        school.isEmpty ? 'Staff room' : '$school · Staff room',
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(_hhmm(now), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w200)),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Today's substitutions", style: TextStyle(color: Colors.amberAccent, fontSize: 24, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            if (subs.isEmpty)
                              const Text('No substitutions still to come today.', style: TextStyle(color: Colors.white70, fontSize: 20))
                            else
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Table(
                                    columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(1.4), 2: FlexColumnWidth(1.6), 3: FlexColumnWidth(2), 4: FlexColumnWidth(2), 5: FlexColumnWidth(1.4)},
                                    children: [
                                      const TableRow(children: [
                                        Text('When', style: head),
                                        Text('Class', style: head),
                                        Text('Subject', style: head),
                                        Text('Covered by', style: head),
                                        Text('Instead of', style: head),
                                        Text('Room', style: head),
                                      ]),
                                      for (final s in subs)
                                        TableRow(children: [
                                          Text('${(s.text('startsAt') ?? '').padRight(5).substring(0, 5)} ${s.text('period') ?? ''}', style: cell),
                                          Text('${s.text('className') ?? ''} ${s.text('section') ?? ''}', style: cell),
                                          Text(s.text('subject') ?? '', style: cell),
                                          Text(s.text('teacher') ?? '—', style: cell.copyWith(fontWeight: FontWeight.w700)),
                                          Text(s.text('absentTeacher') ?? '—', style: cell),
                                          Text(s.text('room') ?? '', style: cell),
                                        ]),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 2,
                        child: ListView(
                          children: [
                            for (final n in notices.take(4))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text.rich(
                                  TextSpan(children: [
                                    TextSpan(text: '${n.title}\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                    TextSpan(text: n.body),
                                  ]),
                                  style: const TextStyle(color: Colors.white, fontSize: 17),
                                ),
                              ),
                            for (final c in others.take(4))
                              Padding(padding: const EdgeInsets.only(bottom: 12), child: CardTile(card: c, colour: controller.branding?.primaryColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: AlertStrip(controller: controller)),
        ],
      ),
    );
  }
}
