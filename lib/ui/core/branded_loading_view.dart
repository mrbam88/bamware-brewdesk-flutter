import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_theme.dart';

/// Full-bleed branded loading state (brewdesk-flutter#33): what the app
/// shows in the gap between the native launch surface (Android splash,
/// shipped in #4 — untouched by this widget) and the first real content
/// paint, most commonly the discovery map. Deep green background, the
/// BrewDesk wordmark styled like onboarding's serif headline
/// ([OnboardingFlow]'s `data.title` text style), and a subtle progress
/// ring rather than a busy spinner.
///
/// This widget is purely presentational — it has no opinion on *when* it
/// should be shown or for how long. Callers that flip between this and
/// real content should hold it on screen for a minimum duration (see
/// `discovery_screen.dart`'s branded-loading debounce) so a fast load
/// never flashes it for a single frame.
class BrandedLoadingView extends StatelessWidget {
  const BrandedLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: AppColors.deepGreen,
      child: Semantics(
        label: l10n.brandedLoadingLabel,
        container: true,
        // The wordmark and progress ring below are decorative once the
        // Semantics label above announces the loading state — excluding
        // them keeps a screen reader from also reading out the wordmark
        // text as a second, redundant announcement.
        child: ExcludeSemantics(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.appNameWordmark,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    color: AppColors.cream,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.sage),
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
