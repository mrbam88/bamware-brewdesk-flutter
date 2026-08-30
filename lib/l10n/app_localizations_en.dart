// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appNameWordmark => 'BREWDESK';

  @override
  String get brandedLoadingLabel => 'Loading BrewDesk';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get tierGreat => 'great';

  @override
  String get tierGood => 'good';

  @override
  String get tierMixed => 'mixed';

  @override
  String get tierWeak => 'weak';

  @override
  String get anyOption => 'Any';

  @override
  String dotJoin(String a, String b) {
    return '$a · $b';
  }

  @override
  String get filtersTooltip => 'Filters';

  @override
  String get filtersLaptopFriendly => 'Laptop friendly';

  @override
  String get filtersWifiTitle => 'Wi-Fi';

  @override
  String get filtersWifiOk => 'OK';

  @override
  String get filtersWifiFast => 'Fast';

  @override
  String get filtersOutletsTitle => 'Outlets';

  @override
  String get filtersOutletsSome => 'Some';

  @override
  String get filtersOutletsPlenty => 'Plenty';

  @override
  String get filtersVenueTypeTitle => 'Venue type';

  @override
  String get filtersVenueTypeCafe => 'Cafe';

  @override
  String get filtersVenueTypeLibrary => 'Library';

  @override
  String get filtersVenueTypePark => 'Park';

  @override
  String filtersResetCount(int count) {
    return 'Reset $count filters';
  }

  @override
  String get whatNumbersMean => 'What the numbers mean';

  @override
  String get workFitCaptionLabel => 'WORK FIT';

  @override
  String get discoveryUseMyLocationTooltip => 'Use my location';

  @override
  String get discoverySearchHint => 'Search work spots';

  @override
  String discoveryVisibleOfTotal(int visible, int total) {
    return '$visible of $total spots';
  }

  @override
  String get discoveryBaselineBanner =>
      'OSM baseline · details are still being researched';

  @override
  String get discoveryEmptyView => 'No spots in this view.';

  @override
  String get discoveryClearFilters => 'Clear filters';

  @override
  String get discoveryScoresShowWorkFit => 'Scores show Work Fit';

  @override
  String discoveryShelfSpotsInView(int count) {
    return '$count spots in view';
  }

  @override
  String get discoveryDragForMapHint => 'Drag for map';

  @override
  String get discoveryTryAgain => 'Try again';

  @override
  String get discoveryErrorOffline =>
      'You\'re offline. We\'ll try again once you\'re back online.';

  @override
  String get discoveryErrorGeneric =>
      'We could not reach the spot service. Check your connection and try again.';

  @override
  String get methodologyTitle => 'How Work Fit works';

  @override
  String get methodologyWhatTitle => 'What we measure';

  @override
  String get methodologyWhatBody =>
      'Five attributes per spot: laptop policy, seating, Wi-Fi, outlets, and noise — plus outdoor seating as a bonus. Every claim comes from AI web research, curated data, or a site visit.';

  @override
  String get methodologyWeightsTitle => 'How the score is weighted';

  @override
  String get methodologyWeightsBody =>
      'Laptop policy dominates (35%), then seating (25%), Wi-Fi (15%), outlets (15%), noise (10%); outdoor seating adds up to +5. The fastest Wi-Fi in the world is worthless where laptops are banned. Above roughly 25 Mbps, extra speed stops mattering — only genuinely slow Wi-Fi punishes hard.';

  @override
  String get methodologyProvenanceTitle => 'Why every claim shows its source';

  @override
  String get methodologyProvenanceBody =>
      'A claim moves the score in proportion to how much we believe it; the rest is anchored to a neutral prior. An unverified guess barely moves a ranking. That is why every claim shows its source, confidence, and date — and the seal appears only when a human stands behind it.';

  @override
  String get methodologyDecayTitle => 'Fresh beats stale';

  @override
  String get methodologyDecayBody =>
      'Confidence halves every 90 days. A six-month-old observation is a quarter as persuasive as a fresh one — that is what keeps the dataset from quietly rotting into confident fiction.';

  @override
  String get methodologyUnknownsTitle => 'Honest unknowns';

  @override
  String get methodologyUnknownsBody =>
      '\"Unknown\" is a first-class value: we never guess. Multiple observations of one attribute combine by their median, and corroboration raises confidence — capped at 95%. We never claim certainty.';

  @override
  String get methodologyDataOriginsTitle => 'Where the data comes from';

  @override
  String get methodologyOriginCuratedLabel => 'Curated';

  @override
  String get methodologyOriginCuratedBody => 'Entered or checked by a human.';

  @override
  String get methodologyOriginOsmLabel => 'OSM baseline';

  @override
  String get methodologyOriginOsmBody =>
      'A real OpenStreetMap listing with intentionally shallow workability data, not yet deeply researched.';

  @override
  String get methodologyOriginAgentLabel => 'Agent researched';

  @override
  String get methodologyOriginAgentBody =>
      'Found by AI web research and labeled as an estimate.';

  @override
  String get onboardingPage1Eyebrow => 'WORK, WITHOUT THE GUESSWORK';

  @override
  String get onboardingPage1Title => 'Your next desk might serve espresso.';

  @override
  String get onboardingPage1Body =>
      'Find nearby spots where the Wi-Fi works, outlets exist, and opening a laptop is actually welcome.';

  @override
  String get onboardingPage2Eyebrow => 'THE SIGNALS THAT MATTER';

  @override
  String get onboardingPage2Title => 'Know before you order.';

  @override
  String get onboardingPage2Body =>
      'Compare noise, Wi-Fi, outlets, and laptop policy instead of digging through hundreds of reviews.';

  @override
  String get onboardingPage3Eyebrow => 'HONEST BY DESIGN';

  @override
  String get onboardingPage3Title => 'Every score shows its work.';

  @override
  String get onboardingPage3Body =>
      'Measured facts lead. Estimates stay labeled. Sources and verification dates show how much to trust.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingFindMyWorkSpot => 'Find my work spot';

  @override
  String onboardingPageIndicator(int page, int total) {
    return '0$page / 0$total';
  }

  @override
  String get locationIntroTitle => 'Start where you are.';

  @override
  String get locationIntroBody =>
      'Your location finds spots nearby. It is never included in a public report.';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get useUnionSquareInstead => 'Use Union Square instead';

  @override
  String get profileTitle => 'You';

  @override
  String get profileHeroTitle => 'Your city is your office.';

  @override
  String get profileHeroBody =>
      'BrewDesk researches Wi-Fi, seating, outlets, noise, and laptop policy so you can choose a spot with confidence.';

  @override
  String get profileAccountlessTitle => 'Accountless by design';

  @override
  String get profileAccountlessBody =>
      'Your saved spots stay on this device. Location is used only to find nearby places.';

  @override
  String get profileTransparentTitle => 'Transparent research';

  @override
  String get profileTransparentBody =>
      'Every workability fact carries its source. Estimates are labeled instead of presented as verified.';

  @override
  String get profileMoreThanCafesTitle => 'Built for more than cafes';

  @override
  String get profileMoreThanCafesBody =>
      'Libraries, parks, malls, and other practical work spots belong here too.';

  @override
  String get profileHowScoringWorks => 'How scoring works';

  @override
  String get profileAboutSectionTitle => 'About';

  @override
  String get profileSupport => 'Support';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileTermsOfUse => 'Terms of Use';

  @override
  String get profileOpenSourceLicenses => 'Open-source licenses';

  @override
  String get profileVersionLabel => 'Version';

  @override
  String get navSpots => 'Spots';

  @override
  String get navSaved => 'Saved';

  @override
  String get navYou => 'You';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedImportTooltip => 'Import from Google Takeout';

  @override
  String get savedImportAction => 'Import';

  @override
  String get savedFileReadError => 'That file couldn\'t be read.';

  @override
  String get savedEmptyTitle => 'Save your next work spot';

  @override
  String get savedEmptyBody =>
      'Bookmarks stay on this device. No account required.';

  @override
  String get savedBrowseNearby => 'Browse nearby';

  @override
  String get savedFailedRowMessage => 'Couldn\'t load this saved spot.';

  @override
  String get savedRemove => 'Remove';

  @override
  String takeoutResultSummary(int matched, int unmatched) {
    return '$matched matched · $unmatched not in BrewDesk yet';
  }

  @override
  String get takeoutConfirmHint =>
      'Matched spots are saved to BrewDesk when you confirm.';

  @override
  String get takeoutNotInBrewDeskYet => 'Not in BrewDesk yet';

  @override
  String get venueDetailWorkabilityTitle => 'Workability';

  @override
  String get venueDetailWhatWeKnowTitle => 'What we know';

  @override
  String get venueDetailClaimLaptopPolicy => 'Laptop policy';

  @override
  String get venueDetailClaimNoise => 'Noise';

  @override
  String get venueDetailClaimSeating => 'Seating';

  @override
  String get venueDetailOsmDescription =>
      'This is a real OpenStreetMap listing. Workability details have not been deeply researched yet.';

  @override
  String get venueDetailResearchedDescription =>
      'This spot combines public-source research with transparent claim-level provenance.';

  @override
  String venueDetailUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get venueDetailDirections => 'Directions';

  @override
  String get venueDetailRemoveFromSaved => 'Remove from saved';

  @override
  String get venueDetailSaveSpot => 'Save spot';

  @override
  String get venueDetailShare => 'Share';

  @override
  String venueCardProvenance(String date, String source) {
    return 'Updated $date · $source';
  }
}
