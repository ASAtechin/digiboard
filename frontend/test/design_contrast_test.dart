// The Forest night colours: every pair of text and background the screens use
// is at least 4.5:1 (WCAG AA), and the school's own colour always shows up.
import 'package:digiboard_app/themes/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the contrast helper uses the WCAG formula', () {
    expect(DesignSystem.contrastRatio(Colors.white, Colors.black), closeTo(21, 0.01));
    expect(DesignSystem.contrastRatio(Colors.white, Colors.white), closeTo(1, 0.001));
    // The grey on white that WCAG itself quotes as 4.54:1.
    expect(DesignSystem.contrastRatio(const Color(0xFF767676), Colors.white), closeTo(4.54, 0.01));
  });

  test('every pair of text and background on the screens is at least 4.5:1', () {
    const surfaces = {
      'background': DesignSystem.background,
      'card': DesignSystem.card,
      'popover': DesignSystem.popover,
      'muted': DesignSystem.muted,
    };
    final pairs = <String, (Color, Color)>{
      for (final s in surfaces.entries) ...{
        'ink on ${s.key}': (DesignSystem.ink, s.value),
        'mutedForeground on ${s.key}': (DesignSystem.mutedForeground, s.value),
        'gold (primary) on ${s.key}': (DesignSystem.primary, s.value),
      },
      'accentForeground on accent': (DesignSystem.accentForeground, DesignSystem.accent),
      'primaryForeground on primary': (DesignSystem.primaryForeground, DesignSystem.primary),
      'success on successSoft': (DesignSystem.success, DesignSystem.successSoft),
      'success on card': (DesignSystem.success, DesignSystem.card),
      'warning on warningSoft': (DesignSystem.warning, DesignSystem.warningSoft),
      'info on infoSoft': (DesignSystem.info, DesignSystem.infoSoft),
      'destructive on dangerSoft': (DesignSystem.destructive, DesignSystem.dangerSoft),
      'ink on infoSoft (offline banner)': (DesignSystem.ink, DesignSystem.infoSoft),
      'ink on dangerSoft (unavailable banner)': (DesignSystem.ink, DesignSystem.dangerSoft),
      'ink on warningSoft': (DesignSystem.ink, DesignSystem.warningSoft),
      'white on emergency (drill)': (DesignSystem.onEmergency, DesignSystem.emergency),
      'black on amber (warning drill, "not updated", "alert status unavailable")': (DesignSystem.onAlertAmber, DesignSystem.alertAmber),
      'dim clock on the forest background': (DesignSystem.dimText, DesignSystem.background),
      'dim clock on black': (DesignSystem.dimText, Colors.black),
    };
    for (final e in pairs.entries) {
      final ratio = DesignSystem.contrastRatio(e.value.$1, e.value.$2);
      expect(ratio, greaterThanOrEqualTo(4.5), reason: '${e.key} is only ${ratio.toStringAsFixed(2)}:1');
    }
  });

  test('a lesson card beside the current one keeps its text at 4.5:1 at the quietest it is drawn', () {
    final card = Color.alphaBlend(DesignSystem.card.withValues(alpha: DesignSystem.fadedOpacity), DesignSystem.background);
    for (final text in [DesignSystem.ink, DesignSystem.primary]) {
      final faded = Color.alphaBlend(text.withValues(alpha: DesignSystem.fadedOpacity), DesignSystem.background);
      expect(DesignSystem.contrastRatio(faded, card), greaterThanOrEqualTo(4.5));
    }
  });

  test('the school\'s own colour is a guest: it shows up on the forest background, whatever it is', () {
    expect(DesignSystem.guest(null), isNull);
    for (final colour in const [Color(0xFF1E3A8A), Color(0xFF0F766E), Color(0xFF8B1D2C), Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFF0F1914)]) {
      final guest = DesignSystem.guest(colour)!;
      expect(DesignSystem.contrastRatio(guest, DesignSystem.background), greaterThanOrEqualTo(3), reason: '$colour');
    }
    // A colour that already shows up is left alone.
    expect(DesignSystem.guest(const Color(0xFF8B1D2C)), isNot(const Color(0xFF8B1D2C)), reason: 'a dark red does not show on forest night, so it is lightened');
    expect(DesignSystem.guest(const Color(0xFFE5C46F)), const Color(0xFFE5C46F));
  });
}
