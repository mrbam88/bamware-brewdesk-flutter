import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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

/// Copy is resolved from [AppLocalizations] at build time via the selector
/// functions below — this list is a top-level const built once, before any
/// BuildContext exists, so it cannot hold resolved strings directly.
class _OnboardingPageData {
  const _OnboardingPageData({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String Function(AppLocalizations l10n) eyebrow;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) body;
  final IconData icon;
}

const _pages = [
  _OnboardingPageData(
    eyebrow: _page1Eyebrow,
    title: _page1Title,
    body: _page1Body,
    icon: Icons.local_cafe_rounded,
  ),
  _OnboardingPageData(
    eyebrow: _page2Eyebrow,
    title: _page2Title,
    body: _page2Body,
    icon: Icons.insights_rounded,
  ),
  _OnboardingPageData(
    eyebrow: _page3Eyebrow,
    title: _page3Title,
    body: _page3Body,
    icon: Icons.verified_rounded,
  ),
];

String _page1Eyebrow(AppLocalizations l10n) => l10n.onboardingPage1Eyebrow;
String _page1Title(AppLocalizations l10n) => l10n.onboardingPage1Title;
String _page1Body(AppLocalizations l10n) => l10n.onboardingPage1Body;
String _page2Eyebrow(AppLocalizations l10n) => l10n.onboardingPage2Eyebrow;
String _page2Title(AppLocalizations l10n) => l10n.onboardingPage2Title;
String _page2Body(AppLocalizations l10n) => l10n.onboardingPage2Body;
String _page3Eyebrow(AppLocalizations l10n) => l10n.onboardingPage3Eyebrow;
String _page3Title(AppLocalizations l10n) => l10n.onboardingPage3Title;
String _page3Body(AppLocalizations l10n) => l10n.onboardingPage3Body;

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
    final l10n = AppLocalizations.of(context)!;
    final isLastPage = _page == _pages.length - 1;
    final pageIndicator = l10n.onboardingPageIndicator(
      _page + 1,
      _pages.length,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text(
                    l10n.appNameWordmark,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    pageIndicator,
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
                    child: Text(
                      isLastPage
                          ? l10n.onboardingFindMyWorkSpot
                          : l10n.onboardingContinue,
                    ),
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
    final l10n = AppLocalizations.of(context)!;
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
            data.eyebrow(l10n),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w900, color: AppColors.green),
          ),
          const SizedBox(height: 8),
          Text(
            data.title(l10n),
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            data.body(l10n),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
