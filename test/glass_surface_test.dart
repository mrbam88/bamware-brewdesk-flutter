import 'package:brewdesk/core/theme/app_theme.dart';
import 'package:brewdesk/core/widgets/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GlassSurface renders its child over a backdrop blur', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: GlassSurface(
          borderRadius: BorderRadius.circular(12),
          child: const Text('through glass'),
        ),
      ),
    );
    expect(find.text('through glass'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('GlassSurface tints from the dark theme surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const GlassSurface(child: SizedBox(width: 40, height: 40)),
      ),
    );
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(GlassSurface),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color!.a, closeTo(0.3, 0.01));
  });
}
