import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass container — the Flutter counterpart of iOS's
/// `brewDeskGlass` (brewdesk-flutter#30). A backdrop blur under a
/// theme-aware translucent surface tint with a hairline highlight border,
/// so map content reads through chrome the way it does on iOS 26.
///
/// Perf rule: `BackdropFilter` forces a saveLayer over everything behind
/// it, which is expensive over live map tiles. Glass belongs on the few
/// standing chrome surfaces only (header card, shelf, action dock, filter
/// menu, tab bar) — never inside scrolling list items, and never stacked
/// glass-on-glass.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.opacity = 0.55,
    this.sigma = 22,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// Tint strength over the blur; lower = glassier, higher = more solid.
  /// Field feedback (2026-08-30, Pixel): 0.72+ read as a solid gray card —
  /// the blur has to visibly do the work, so defaults now sit low enough
  /// that map detail moves under the chrome.
  final double opacity;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
