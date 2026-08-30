import 'package:flutter/widgets.dart' show Locale;
import 'package:intl/intl.dart';

/// One parsed opening-hours rule, already formatted for display: which days
/// it covers (as grouped in the source string) and its single time span.
class OpeningHoursRow {
  const OpeningHoursRow({required this.dayLabel, required this.timeLabel});

  final String dayLabel;
  final String timeLabel;
}

/// Conservative parser for the `;`-separated `Days HH:MM-HH:MM` subset of OSM
/// `opening_hours` syntax the venue engine serves in `Venue.hoursRaw`
/// (brewdesk#28), e.g. `"Mo-Fr 06:30-19:00; Su,Sa 07:00-19:00"`.
///
/// Design rule (matching the iOS `OpeningHours` parser): a wrong open/closed
/// claim is worse than no claim, so [parse] returns `null` for ANYTHING
/// outside this narrow subset — `24/7`, `off`/`closed`, overnight spans,
/// multiple time spans per rule, unrecognized day tokens — and the caller
/// falls back to showing the raw string unchanged. This never guesses.
///
/// Supported grammar (rules separated by `;`):
///
///     rule    = dayspec " " HH:MM "-" HH:MM
///     dayspec = daypart ("," daypart)*      e.g. "Mo-Fr,Su"
///     daypart = DAY | DAY "-" DAY
///
/// Day and time tokens are translated one-for-one into the display string —
/// this deliberately does not reorder or recombine days across rules, so the
/// output always traces back to exactly what the source said.
abstract final class OpeningHoursParser {
  static const _dayTokens = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  static List<OpeningHoursRow>? parse(String raw, Locale locale) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final localeName = locale.toString();
    final rows = <OpeningHoursRow>[];
    for (final rulePart in trimmed.split(';')) {
      final rule = rulePart.trim();
      if (rule.isEmpty) continue; // tolerate a trailing ";"

      final parts = rule.split(RegExp(r'\s+'));
      if (parts.length != 2) return null;

      final dayLabel = _dayLabel(parts[0], localeName);
      if (dayLabel == null) return null;

      final timeLabel = _timeLabel(parts[1], localeName);
      if (timeLabel == null) return null;

      rows.add(OpeningHoursRow(dayLabel: dayLabel, timeLabel: timeLabel));
    }
    return rows.isEmpty ? null : rows;
  }

  static String? _dayLabel(String dayspec, String localeName) {
    final labels = <String>[];
    for (final token in dayspec.split(',')) {
      if (token.isEmpty) return null;
      final bounds = token.split('-');
      switch (bounds.length) {
        case 1:
          final day = _dayIndex(bounds[0]);
          if (day == null) return null;
          labels.add(_weekday(day, localeName));
        case 2:
          final start = _dayIndex(bounds[0]);
          final end = _dayIndex(bounds[1]);
          if (start == null || end == null) return null;
          labels.add(
            '${_weekday(start, localeName)}–${_weekday(end, localeName)}',
          );
        default:
          return null;
      }
    }
    return labels.join(', ');
  }

  static int? _dayIndex(String token) {
    final index = _dayTokens.indexOf(token);
    return index == -1 ? null : index;
  }

  /// 2024-01-01 was a Monday, so `mondayIndex` days later lands on the
  /// matching weekday — a fixed reference date immune to the calendar year.
  static String _weekday(int mondayIndex, String localeName) =>
      DateFormat.E(localeName).format(DateTime(2024, 1, 1 + mondayIndex));

  static String? _timeLabel(String timespec, String localeName) {
    final bounds = timespec.split('-');
    if (bounds.length != 2) return null;
    final start = _minutes(bounds[0]);
    final end = _minutes(bounds[1]);
    if (start == null || end == null || start >= end) return null;
    return '${_clock(start, localeName)} – ${_clock(end, localeName)}';
  }

  /// "HH:MM" → minutes since midnight, or `null` outside the supported
  /// subset (two-digit minutes, 00:00–23:59 — a bare "24:00" close is not
  /// part of this narrow grammar).
  static int? _minutes(String text) {
    final parts = text.split(':');
    if (parts.length != 2 || parts[1].length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
  }

  /// Locale-driven clock display ("6:30 AM" en / "06:30" 24-hour locales) on
  /// a fixed reference date — only the hour/minute matter.
  static String _clock(int minutes, String localeName) =>
      DateFormat.jm(localeName)
          .format(DateTime(2024, 1, 1, minutes ~/ 60, minutes % 60));
}
