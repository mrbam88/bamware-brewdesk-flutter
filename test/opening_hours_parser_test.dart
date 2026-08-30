// Unit tests for OpeningHoursParser (brewdesk#28): the two supported OSM
// "Days HH:MM-HH:MM" fixture shapes, plus a garbage string proving the
// house rule — any parse doubt falls back to the raw string, never guessed.
//
// intl's DateFormat needs its locale symbol tables loaded before use outside
// a widget tree (a MaterialApp with GlobalMaterialLocalizations does this
// for free at runtime); a plain Dart unit test does it explicitly here.

import 'package:brewdesk/domain/use_cases/opening_hours_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _en = Locale('en');

// intl formats a clock time like "6:30 AM" with a narrow no-break space
// (U+202F) before the AM/PM marker, not a plain ASCII space.
const _nnbsp = ' ';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  test('fixture shape 1: comma-day and range-day rules both parse', () {
    final rows = OpeningHoursParser.parse(
      'Mo-Fr 06:30-19:00; Su,Sa 07:00-19:00',
      _en,
    );

    expect(rows, isNotNull);
    expect(rows, hasLength(2));
    expect(rows![0].dayLabel, 'Mon–Fri');
    expect(rows[0].timeLabel, '6:30${_nnbsp}AM – 7:00${_nnbsp}PM');
    expect(rows[1].dayLabel, 'Sun, Sat');
    expect(rows[1].timeLabel, '7:00${_nnbsp}AM – 7:00${_nnbsp}PM');
  });

  test('fixture shape 2: a single-day rule alongside a range rule', () {
    final rows = OpeningHoursParser.parse(
      'Mo-Fr 08:00-17:00; Sa 09:00-13:00',
      _en,
    );

    expect(rows, isNotNull);
    expect(rows, hasLength(2));
    expect(rows![0].dayLabel, 'Mon–Fri');
    expect(rows[0].timeLabel, '8:00${_nnbsp}AM – 5:00${_nnbsp}PM');
    expect(rows[1].dayLabel, 'Sat');
    expect(rows[1].timeLabel, '9:00${_nnbsp}AM – 1:00${_nnbsp}PM');
  });

  test('a garbage string falls back — parse returns null', () {
    expect(OpeningHoursParser.parse('24/7', _en), isNull);
    expect(OpeningHoursParser.parse('Mo-Fr off', _en), isNull);
    expect(OpeningHoursParser.parse('not hours at all', _en), isNull);
    expect(OpeningHoursParser.parse('', _en), isNull);
  });

  test('an overnight span is outside the supported subset', () {
    expect(OpeningHoursParser.parse('Mo-Su 22:00-02:00', _en), isNull);
  });

  test('an unrecognized day token falls back', () {
    expect(OpeningHoursParser.parse('Xx 09:00-17:00', _en), isNull);
  });
}
