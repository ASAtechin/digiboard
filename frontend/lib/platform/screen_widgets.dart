// What a platform screen draws around (or instead of) the timetable: when it
// last updated, cards, the staff room's substitutions, the off-hours clock,
// and drills on screens that do not show the timetable.
//
// Look: "Forest night" (lib/themes/design_system.dart). Cards are hairline-
// bordered panels on the card colour; headings are serif; status colours keep
// their meaning (amber: cannot confirm, red: emergency or nothing to show).
import 'package:flutter/material.dart';
import '../themes/design_system.dart';
import 'display_controller.dart';
import 'display_models.dart';

String _hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "Updated 09:12", or, when the screen cannot say it is up to date, "Not updated since 09:12".
/// The calm one is a hairline pill with a green dot; the other is amber with black text (10:1).
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
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: stale ? 6 : 5),
      decoration: BoxDecoration(
        color: stale ? DesignSystem.alertAmber : DesignSystem.card,
        borderRadius: BorderRadius.circular(100),
        border: stale ? null : Border.all(color: DesignSystem.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stale)
            const Icon(Icons.history_rounded, size: 22, color: DesignSystem.onAlertAmber)
          else
            Container(width: 10, height: 10, decoration: const BoxDecoration(color: DesignSystem.success, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(
            stale ? 'Not updated since ${_hhmm(at)}' : 'Updated ${_hhmm(at)}',
            style: DesignSystem.sans(
              size: stale ? 20 : 18,
              weight: stale ? FontWeight.w700 : FontWeight.w400,
              color: stale ? DesignSystem.onAlertAmber : DesignSystem.mutedForeground,
            ),
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
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in cards.take(3)) ...[
            Flexible(
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500), child: CardTile(card: c, colour: colour)),
            ),
            if (c != cards.take(3).last) const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }
}

/// One card. Events get a date line; every other type is drawn from its labelled lines.
/// A hairline-bordered panel with a 4 px rule down its left edge (the school's colour when it
/// has one, gold otherwise), an eyebrow, a serif title and the lines in sans.
class CardTile extends StatelessWidget {
  final ScreenCard card;
  final Color? colour;

  /// Smaller type and padding, for lists that must fit a screen's height (the staff room).
  final bool dense;
  const CardTile({super.key, required this.card, this.colour, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final isEvent = card.type == 'screens.event';
    final title = isEvent ? card.text('title') ?? '' : card.heading;
    final lines = isEvent
        ? card.lines.where((l) => !const {'Kind', 'Title'}.contains(l.label)).toList()
        : card.lines;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: DesignSystem.cardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: DesignSystem.guest(colour) ?? DesignSystem.gold),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, dense ? 9 : 12, 16, dense ? 9 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEvent ? (card.text('kind') == 'announcement' ? 'ANNOUNCEMENT' : card.heading.toUpperCase()) : card.heading.toUpperCase(),
                      style: DesignSystem.eyebrow(size: dense ? 14 : 15),
                    ),
                    if (isEvent)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 2),
                        child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: DesignSystem.serif(size: dense ? 22 : 24, height: 1.25)),
                      ),
                    for (final l in lines.take(4))
                      Text(
                        isEvent && const {'Details'}.contains(l.label) ? l.text : '${l.label}: ${l.text}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: DesignSystem.sans(size: dense ? 17 : 18, height: 1.35),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A drill (or "alert status unavailable") for screens that do not show the
/// timetable screen's own alert banner: the staff room and off hours.
/// Emergency is red with white text, a warning is amber with black text, anything else
/// is a calm info bar; "cannot confirm" is amber. Every pair is over 4.5:1.
class AlertStrip extends StatelessWidget {
  final DisplayController controller;
  const AlertStrip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final alerts = controller.alerts;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in alerts) _alert(a),
        if (controller.alertStatusUnknown)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
            color: DesignSystem.alertAmber,
            child: Text(
              'Alert status unavailable: this screen cannot reach the school server. Follow staff instructions.',
              textAlign: TextAlign.center,
              style: DesignSystem.sans(size: 22, weight: FontWeight.w700, color: DesignSystem.onAlertAmber, height: 1.25),
            ),
          ),
      ],
    );
  }

  Widget _alert(ScreenAlert a) {
    final emergency = a.severity == 'emergency';
    final warning = a.severity == 'warning';
    final foreground = emergency
        ? DesignSystem.onEmergency
        : warning
        ? DesignSystem.onAlertAmber
        : DesignSystem.ink;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      decoration: BoxDecoration(
        color: emergency
            ? DesignSystem.emergency
            : warning
            ? DesignSystem.alertAmber
            : DesignSystem.infoSoft,
        border: emergency || warning ? null : const Border(bottom: BorderSide(color: DesignSystem.info, width: 4)),
      ),
      child: Text(
        a.displayMessage,
        textAlign: TextAlign.center,
        style: DesignSystem.sans(size: 32, weight: FontWeight.w700, color: foreground, height: 1.2),
      ),
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
    final s = DesignSystem.scaleFor(MediaQuery.sizeOf(context).width);
    return Scaffold(
      key: const ValueKey('off-hours'),
      // "Almost nothing" stays black, so the panel gives off no light; the clock is the forest night.
      backgroundColor: dim ? Colors.black : DesignSystem.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hhmm(now),
                  style: DesignSystem.display(size: (dim ? 48 : 168) * s, color: dim ? DesignSystem.dimText : DesignSystem.ink, height: 1.1),
                ),
                if (!dim && school.isNotEmpty) ...[
                  SizedBox(height: 16 * s),
                  Container(width: DesignSystem.ruleWidth * s, height: DesignSystem.ruleHeight, color: DesignSystem.gold),
                  SizedBox(height: 24 * s),
                  Text(school, style: DesignSystem.serif(size: 40 * s, color: DesignSystem.mutedForeground)),
                ],
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
    final s = DesignSystem.scaleFor(MediaQuery.sizeOf(context).width);
    final head = DesignSystem.eyebrow(size: 18 * s, color: DesignSystem.mutedForeground).copyWith(letterSpacing: 0.4);
    final cell = DesignSystem.sans(size: 24 * s, height: 1.3);
    Widget padded(Widget w) => Padding(padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s), child: w);
    return Scaffold(
      key: const ValueKey('staff-room'),
      backgroundColor: DesignSystem.background,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(40 * s, 48 * s, 40 * s, 32 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            school.isEmpty ? 'Staff room' : '$school · Staff room',
                            style: DesignSystem.serif(size: 48 * s, height: 1.15, letterSpacing: -0.5 * s),
                          ),
                          SizedBox(height: 12 * s),
                          Container(width: DesignSystem.ruleWidth * s, height: DesignSystem.ruleHeight, color: DesignSystem.gold),
                        ],
                      ),
                    ),
                    Text(_hhmm(now), style: DesignSystem.display(size: 60 * s, height: 1.1)),
                  ],
                ),
                SizedBox(height: 28 * s),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Today's substitutions", style: DesignSystem.serif(size: 32 * s)),
                            SizedBox(height: 14 * s),
                            if (subs.isEmpty)
                              Text('No substitutions still to come today.', style: DesignSystem.sans(size: 24 * s, color: DesignSystem.mutedForeground))
                            else
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: DesignSystem.cardDecoration(),
                                    child: Table(
                                      columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(1.4), 2: FlexColumnWidth(1.6), 3: FlexColumnWidth(2), 4: FlexColumnWidth(2), 5: FlexColumnWidth(1.4)},
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      border: const TableBorder(horizontalInside: BorderSide(color: DesignSystem.border)),
                                      children: [
                                        TableRow(
                                          decoration: const BoxDecoration(color: DesignSystem.muted),
                                          children: [
                                            padded(Text('When', style: head)),
                                            padded(Text('Class', style: head)),
                                            padded(Text('Subject', style: head)),
                                            padded(Text('Covered by', style: head)),
                                            padded(Text('Instead of', style: head)),
                                            padded(Text('Room', style: head)),
                                          ],
                                        ),
                                        for (final sub in subs)
                                          TableRow(children: [
                                            padded(Text('${(sub.text('startsAt') ?? '').padRight(5).substring(0, 5)} ${sub.text('period') ?? ''}', style: cell)),
                                            padded(Text('${sub.text('className') ?? ''} ${sub.text('section') ?? ''}', style: cell)),
                                            padded(Text(sub.text('subject') ?? '', style: cell)),
                                            padded(Text(sub.text('teacher') ?? '—', style: cell.copyWith(fontWeight: FontWeight.w700, color: DesignSystem.primary))),
                                            padded(Text(sub.text('absentTeacher') ?? '—', style: cell)),
                                            padded(Text(sub.text('room') ?? '', style: cell)),
                                          ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 32 * s),
                      Expanded(
                        flex: 2,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            for (final n in notices.take(4))
                              Padding(
                                padding: EdgeInsets.only(bottom: 10 * s),
                                child: _NoticePanel(notice: n, colour: controller.branding?.primaryColor, scale: s),
                              ),
                            for (final c in others.take(4))
                              Padding(padding: EdgeInsets.only(bottom: 10 * s), child: CardTile(card: c, colour: controller.branding?.primaryColor, dense: true)),
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

/// A staff notice: a hairline-bordered panel with a rule down its left edge, the title in gold.
class _NoticePanel extends StatelessWidget {
  final ScreenNotice notice;
  final Color? colour;
  final double scale;
  const _NoticePanel({required this.notice, required this.colour, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: DesignSystem.cardDecoration(color: DesignSystem.popover),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: DesignSystem.guest(colour) ?? DesignSystem.gold),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 10 * scale),
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '${notice.title}\n', style: DesignSystem.serif(size: 24 * scale, color: DesignSystem.primary, height: 1.25)),
                    TextSpan(text: notice.body),
                  ]),
                  style: DesignSystem.sans(size: 20 * scale, height: 1.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
