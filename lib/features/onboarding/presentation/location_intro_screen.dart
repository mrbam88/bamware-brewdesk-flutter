import 'package:flutter/material.dart';

import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/core/theme/app_theme.dart';

/// Explains why BrewDesk asks for location before ever showing the OS
/// prompt, then offers a real, no-prompt way out.
///
/// [onComplete] is called with `true` for "Use my location" — the caller is
/// expected to let the real device location service run, which is what
/// triggers the OS prompt — and `false` for "Use Union Square instead",
/// where the caller must never touch a location API.
class LocationIntroScreen extends StatelessWidget {
  const LocationIntroScreen({super.key, required this.onComplete});

  final ValueChanged<bool> onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 64,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.locationIntroTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.locationIntroBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => onComplete(true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(l10n.useMyLocation),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => onComplete(false),
                    child: Text(l10n.useUnionSquareInstead),
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
