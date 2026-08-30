import 'package:flutter/material.dart';

import 'package:brewdesk/core/theme/app_theme.dart';
import 'package:brewdesk/features/onboarding/presentation/onboarding_gate.dart';
import 'package:brewdesk/features/shell/presentation/app_shell.dart';
import 'package:brewdesk/l10n/app_localizations.dart';

// LEARN: with DI in the provider graph, the app root is pure composition —
// no dependency fields, no drilling. Compare this widget's git history:
// it used to carry three repositories it never used itself, purely to pass
// them along (the classic prop-drilling symptom).
class BrewDeskApp extends StatelessWidget {
  const BrewDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrewDesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingGate(child: AppShell()),
    );
  }
}
