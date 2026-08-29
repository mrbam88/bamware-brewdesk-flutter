import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/app_theme.dart';
import '../methodology/methodology_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.work_outline_rounded,
                  color: AppColors.cream,
                  size: 34,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.profileHeroTitle,
                  style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.profileHeroBody,
                  style: const TextStyle(color: AppColors.cream, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _InfoTile(
            icon: Icons.lock_outline_rounded,
            title: l10n.profileAccountlessTitle,
            subtitle: l10n.profileAccountlessBody,
          ),
          _InfoTile(
            icon: Icons.fact_check_outlined,
            title: l10n.profileTransparentTitle,
            subtitle: l10n.profileTransparentBody,
          ),
          _InfoTile(
            icon: Icons.public_rounded,
            title: l10n.profileMoreThanCafesTitle,
            subtitle: l10n.profileMoreThanCafesBody,
          ),
          const SizedBox(height: 6),
          _NavTile(
            icon: Icons.insights_rounded,
            title: l10n.profileHowScoringWorks,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MethodologyScreen()),
            ),
          ),
          const SizedBox(height: 18),
          const _AboutSection(),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
      ),
    );
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

/// Support/legal/version rows (brewdesk-flutter#9). Mirrors the iOS You
/// tab's About section — Support, Privacy Policy, Terms of Use, open-source
/// licenses, and the real package version.
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  static final Uri _supportUri = Uri.parse(
    'https://bamware.io/brewdesk/support',
  );
  static final Uri _privacyUri = Uri.parse(
    'https://bamware.io/brewdesk/privacy',
  );
  static final Uri _termsUri = Uri.parse('https://bamware.io/brewdesk/terms');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.profileAboutSectionTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          _AboutRow(
            icon: Icons.mail_outline_rounded,
            label: l10n.profileSupport,
            onTap: () => launchUrl(_supportUri),
          ),
          _AboutRow(
            icon: Icons.privacy_tip_outlined,
            label: l10n.profilePrivacyPolicy,
            onTap: () => launchUrl(_privacyUri),
          ),
          _AboutRow(
            icon: Icons.gavel_outlined,
            label: l10n.profileTermsOfUse,
            onTap: () => launchUrl(_termsUri),
          ),
          _AboutRow(
            icon: Icons.description_outlined,
            label: l10n.profileOpenSourceLicenses,
            onTap: () =>
                showLicensePage(context: context, applicationName: 'BrewDesk'),
          ),
          const _VersionRow(),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          final label = info == null
              ? '…'
              : '${info.version} (${info.buildNumber})';
          return Row(
            children: [
              Text(
                l10n.profileVersionLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
