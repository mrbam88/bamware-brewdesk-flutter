import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'location_intro_screen.dart';

/// Three onboarding pages mirroring the iOS copy (why BrewDesk exists, which
/// signals matter, and how scoring stays honest), followed by the location
/// intro step. Calls [onComplete] once the whole flow finishes.
///
/// See [LocationIntroScreen] for what the `bool` argument to [onComplete]
/// means.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onComplete});

  final ValueChanged<bool> onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
}

const _pages = [
  _OnboardingPageData(
    eyebrow: 'WORK, WITHOUT THE GUESSWORK',
    title: 'Your next desk might serve espresso.',
    body:
        'Find nearby spots where the Wi-Fi works, outlets exist, and '
        'opening a laptop is actually welcome.',
    icon: Icons.local_cafe_rounded,
  ),
  _OnboardingPageData(
    eyebrow: 'THE SIGNALS THAT MATTER',
    title: 'Know before you order.',
    body:
        'Compare noise, Wi-Fi, outlets, and laptop policy instead of '
        'digging through hundreds of reviews.',
    icon: Icons.insights_rounded,
  ),
  _OnboardingPageData(
    eyebrow: 'HONEST BY DESIGN',
    title: 'Every score shows its work.',
    body:
        'Measured facts lead. Estimates stay labeled. Sources and '
        'verification dates show how much to trust.',
    icon: Icons.verified_rounded,
  ),
];

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  bool _showLocationIntro = false;
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_page == _pages.length - 1) {
      setState(() => _showLocationIntro = true);
      return;
    }
    _pageController.animateToPage(
      _page + 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showLocationIntro) {
      return LocationIntroScreen(onComplete: widget.onComplete);
    }
    final isLastPage = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text(
                    'BREWDESK',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '0${_page + 1} / 0${_pages.length}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) =>
                    _OnboardingPageView(data: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 30 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? AppColors.green
                            : AppColors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continue,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(isLastPage ? 'Find my work spot' : 'Continue'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(data.icon, size: 84, color: AppColors.cream),
          ),
          const SizedBox(height: 24),
          Text(
            data.eyebrow,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w900, color: AppColors.green),
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            data.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
