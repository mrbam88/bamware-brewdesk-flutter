import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:brewdesk/core/theme/app_theme.dart';
import 'package:brewdesk/features/venues/presentation/venue_widgets.dart';

/// Rasterizes the score-forward capsule (the `VenueScorePin` look from the
/// flutter#6 visual pass) into marker bitmaps for the Google map. Google
/// markers can't host widgets, so each distinct (score, density) pin is
/// drawn once with Canvas + TextPainter and cached; a 100-venue viewport
/// shares a handful of bitmaps.
class ScorePinRenderer {
  final Map<String, BitmapDescriptor> _cache = {};

  Future<BitmapDescriptor> descriptorFor(int score, double dpr) async {
    final key = '$score@$dpr';
    final cached = _cache[key];
    if (cached != null) return cached;

    const height = 30.0;
    const stroke = 1.5;
    const fontSize = 13.0;

    final text = TextPainter(
      text: TextSpan(
        text: score.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontFamily: AppFonts.label,
          fontWeight: FontWeight.w700,
          fontVariations: AppFonts.wght(700),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final width = (text.width + 20).clamp(44.0, 72.0);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(dpr);
    final rect = Rect.fromLTWH(
      stroke,
      stroke,
      width - stroke * 2,
      height - stroke * 2,
    );
    final capsule = RRect.fromRectAndRadius(
      rect,
      Radius.circular(height / 2),
    );
    canvas.drawRRect(capsule, Paint()..color = scoreColor(score));
    canvas.drawRRect(
      capsule,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    text.paint(
      canvas,
      Offset((width - text.width) / 2, (height - text.height) / 2),
    );

    final image = await recorder.endRecording().toImage(
      (width * dpr).ceil(),
      (height * dpr).ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
    _cache[key] = descriptor;
    return descriptor;
  }
}
