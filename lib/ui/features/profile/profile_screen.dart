import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  color: AppColors.cream,
                  size: 34,
                ),
                SizedBox(height: 16),
                Text(
                  'Your city is your office.',
                  style: TextStyle(
                    color: AppColors.cream,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'BrewDesk researches Wi-Fi, seating, outlets, noise, and laptop policy so you can choose a spot with confidence.',
                  style: TextStyle(color: AppColors.cream, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _InfoTile(
            icon: Icons.lock_outline_rounded,
            title: 'Accountless by design',
            subtitle: 'Your saved spots stay on this device. Location is used only to find nearby places.',
          ),
          const _InfoTile(
            icon: Icons.fact_check_outlined,
            title: 'Transparent research',
            subtitle: 'Every workability fact carries its source. Estimates are labeled instead of presented as verified.',
          ),
          const _InfoTile(
            icon: Icons.public_rounded,
            title: 'Built for more than cafes',
            subtitle: 'Libraries, parks, malls, and other practical work spots belong here too.',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                launchUrl(Uri.parse('https://bamware.io/brewdesk/privacy')),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Privacy policy'),
          ),
          const SizedBox(height: 8),
          Text(
            'BrewDesk Android MVP · Data from BrewDesk research and OpenStreetMap contributors.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
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
