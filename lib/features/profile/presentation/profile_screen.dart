import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/methodology/presentation/methodology_screen.dart';
import 'package:brewdesk/features/profile/presentation/about_screen.dart';

/// The You tab (brewdesk-flutter#32): a compact, Atly-style profile list.
/// The hero card, honesty cards, and Support/Privacy/Terms/license/version
/// content that used to splash across this surface now live behind the
/// About row in [AboutScreen] — a detail nav, not front-page content.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.shareApp});

  /// Test seam: overrides the default [SharePlus] call so widget tests
  /// don't hit a real platform channel.
  final Future<void> Function(String text)? shareApp;

  static const _shareText =
      'BrewDesk — find your next work spot: https://bamware.io/brewdesk';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // #120 account card slot
          _NavTile(
            icon: Icons.insights_rounded,
            title: l10n.profileHowScoringWorks,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MethodologyScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _NavTile(
            icon: Icons.ios_share_rounded,
            title: l10n.profileShareApp,
            onTap: _shareTheApp,
          ),
          const SizedBox(height: 10),
          _NavTile(
            icon: Icons.info_outline_rounded,
            title: l10n.profileAboutTitle,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }

  Future<void> _shareTheApp() {
    final share = shareApp ?? _defaultShare;
    return share(_shareText);
  }

  Future<void> _defaultShare(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
