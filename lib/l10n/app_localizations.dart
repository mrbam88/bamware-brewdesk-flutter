import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// All-caps brand wordmark shown on the onboarding header. Not translated per-locale.
  ///
  /// In en, this message translates to:
  /// **'BREWDESK'**
  String get appNameWordmark;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @tierGreat.
  ///
  /// In en, this message translates to:
  /// **'great'**
  String get tierGreat;

  /// No description provided for @tierGood.
  ///
  /// In en, this message translates to:
  /// **'good'**
  String get tierGood;

  /// No description provided for @tierMixed.
  ///
  /// In en, this message translates to:
  /// **'mixed'**
  String get tierMixed;

  /// No description provided for @tierWeak.
  ///
  /// In en, this message translates to:
  /// **'weak'**
  String get tierWeak;

  /// No description provided for @anyOption.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyOption;

  /// Two short fragments joined by a middot separator.
  ///
  /// In en, this message translates to:
  /// **'{a} · {b}'**
  String dotJoin(String a, String b);

  /// No description provided for @filtersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTooltip;

  /// No description provided for @filtersLaptopFriendly.
  ///
  /// In en, this message translates to:
  /// **'Laptop friendly'**
  String get filtersLaptopFriendly;

  /// No description provided for @filtersWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get filtersWifiTitle;

  /// No description provided for @filtersWifiOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get filtersWifiOk;

  /// No description provided for @filtersWifiFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get filtersWifiFast;

  /// No description provided for @filtersOutletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Outlets'**
  String get filtersOutletsTitle;

  /// No description provided for @filtersOutletsSome.
  ///
  /// In en, this message translates to:
  /// **'Some'**
  String get filtersOutletsSome;

  /// No description provided for @filtersOutletsPlenty.
  ///
  /// In en, this message translates to:
  /// **'Plenty'**
  String get filtersOutletsPlenty;

  /// No description provided for @filtersVenueTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Venue type'**
  String get filtersVenueTypeTitle;

  /// No description provided for @filtersVenueTypeCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get filtersVenueTypeCafe;

  /// No description provided for @filtersVenueTypeLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get filtersVenueTypeLibrary;

  /// No description provided for @filtersVenueTypePark.
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get filtersVenueTypePark;

  /// Reset button label naming how many filters are active. Always plural, even for 0 or 1 — matches existing widget-test expectations.
  ///
  /// In en, this message translates to:
  /// **'Reset {count} filters'**
  String filtersResetCount(int count);

  /// No description provided for @whatNumbersMean.
  ///
  /// In en, this message translates to:
  /// **'What the numbers mean'**
  String get whatNumbersMean;

  /// No description provided for @workFitCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'WORK FIT'**
  String get workFitCaptionLabel;

  /// No description provided for @discoveryUseMyLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get discoveryUseMyLocationTooltip;

  /// No description provided for @discoverySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search work spots'**
  String get discoverySearchHint;

  /// No description provided for @discoveryVisibleOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{visible} of {total} spots'**
  String discoveryVisibleOfTotal(int visible, int total);

  /// No description provided for @discoveryBaselineBanner.
  ///
  /// In en, this message translates to:
  /// **'OSM baseline · details are still being researched'**
  String get discoveryBaselineBanner;

  /// No description provided for @discoveryEmptyView.
  ///
  /// In en, this message translates to:
  /// **'No spots in this view.'**
  String get discoveryEmptyView;

  /// No description provided for @discoveryClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get discoveryClearFilters;

  /// No description provided for @discoveryScoresShowWorkFit.
  ///
  /// In en, this message translates to:
  /// **'Scores show Work Fit'**
  String get discoveryScoresShowWorkFit;

  /// Shelf header count. Always plural, even for 0 or 1 — matches discoveryVisibleOfTotal's convention.
  ///
  /// In en, this message translates to:
  /// **'{count} spots in view'**
  String discoveryShelfSpotsInView(int count);

  /// No description provided for @discoveryDragForMapHint.
  ///
  /// In en, this message translates to:
  /// **'Drag for map'**
  String get discoveryDragForMapHint;

  /// No description provided for @discoveryTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get discoveryTryAgain;

  /// No description provided for @discoveryErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. We\'ll try again once you\'re back online.'**
  String get discoveryErrorOffline;

  /// No description provided for @discoveryErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We could not reach the spot service. Check your connection and try again.'**
  String get discoveryErrorGeneric;

  /// No description provided for @methodologyTitle.
  ///
  /// In en, this message translates to:
  /// **'How Work Fit works'**
  String get methodologyTitle;

  /// No description provided for @methodologyWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What we measure'**
  String get methodologyWhatTitle;

  /// No description provided for @methodologyWhatBody.
  ///
  /// In en, this message translates to:
  /// **'Five attributes per spot: laptop policy, seating, Wi-Fi, outlets, and noise — plus outdoor seating as a bonus. Every claim comes from AI web research, curated data, or a site visit.'**
  String get methodologyWhatBody;

  /// No description provided for @methodologyWeightsTitle.
  ///
  /// In en, this message translates to:
  /// **'How the score is weighted'**
  String get methodologyWeightsTitle;

  /// No description provided for @methodologyWeightsBody.
  ///
  /// In en, this message translates to:
  /// **'Laptop policy dominates (35%), then seating (25%), Wi-Fi (15%), outlets (15%), noise (10%); outdoor seating adds up to +5. The fastest Wi-Fi in the world is worthless where laptops are banned. Above roughly 25 Mbps, extra speed stops mattering — only genuinely slow Wi-Fi punishes hard.'**
  String get methodologyWeightsBody;

  /// No description provided for @methodologyProvenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Why every claim shows its source'**
  String get methodologyProvenanceTitle;

  /// No description provided for @methodologyProvenanceBody.
  ///
  /// In en, this message translates to:
  /// **'A claim moves the score in proportion to how much we believe it; the rest is anchored to a neutral prior. An unverified guess barely moves a ranking. That is why every claim shows its source, confidence, and date — and the seal appears only when a human stands behind it.'**
  String get methodologyProvenanceBody;

  /// No description provided for @methodologyDecayTitle.
  ///
  /// In en, this message translates to:
  /// **'Fresh beats stale'**
  String get methodologyDecayTitle;

  /// No description provided for @methodologyDecayBody.
  ///
  /// In en, this message translates to:
  /// **'Confidence halves every 90 days. A six-month-old observation is a quarter as persuasive as a fresh one — that is what keeps the dataset from quietly rotting into confident fiction.'**
  String get methodologyDecayBody;

  /// No description provided for @methodologyUnknownsTitle.
  ///
  /// In en, this message translates to:
  /// **'Honest unknowns'**
  String get methodologyUnknownsTitle;

  /// No description provided for @methodologyUnknownsBody.
  ///
  /// In en, this message translates to:
  /// **'\"Unknown\" is a first-class value: we never guess. Multiple observations of one attribute combine by their median, and corroboration raises confidence — capped at 95%. We never claim certainty.'**
  String get methodologyUnknownsBody;

  /// No description provided for @methodologyDataOriginsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where the data comes from'**
  String get methodologyDataOriginsTitle;

  /// No description provided for @methodologyOriginCuratedLabel.
  ///
  /// In en, this message translates to:
  /// **'Curated'**
  String get methodologyOriginCuratedLabel;

  /// No description provided for @methodologyOriginCuratedBody.
  ///
  /// In en, this message translates to:
  /// **'Entered or checked by a human.'**
  String get methodologyOriginCuratedBody;

  /// No description provided for @methodologyOriginOsmLabel.
  ///
  /// In en, this message translates to:
  /// **'OSM baseline'**
  String get methodologyOriginOsmLabel;

  /// No description provided for @methodologyOriginOsmBody.
  ///
  /// In en, this message translates to:
  /// **'A real OpenStreetMap listing with intentionally shallow workability data, not yet deeply researched.'**
  String get methodologyOriginOsmBody;

  /// No description provided for @methodologyOriginAgentLabel.
  ///
  /// In en, this message translates to:
  /// **'Agent researched'**
  String get methodologyOriginAgentLabel;

  /// No description provided for @methodologyOriginAgentBody.
  ///
  /// In en, this message translates to:
  /// **'Found by AI web research and labeled as an estimate.'**
  String get methodologyOriginAgentBody;

  /// No description provided for @onboardingPage1Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'WORK, WITHOUT THE GUESSWORK'**
  String get onboardingPage1Eyebrow;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Your next desk might serve espresso.'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Body.
  ///
  /// In en, this message translates to:
  /// **'Find nearby spots where the Wi-Fi works, outlets exist, and opening a laptop is actually welcome.'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'THE SIGNALS THAT MATTER'**
  String get onboardingPage2Eyebrow;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Know before you order.'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'Compare noise, Wi-Fi, outlets, and laptop policy instead of digging through hundreds of reviews.'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'HONEST BY DESIGN'**
  String get onboardingPage3Eyebrow;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Every score shows its work.'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'Measured facts lead. Estimates stay labeled. Sources and verification dates show how much to trust.'**
  String get onboardingPage3Body;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingFindMyWorkSpot.
  ///
  /// In en, this message translates to:
  /// **'Find my work spot'**
  String get onboardingFindMyWorkSpot;

  /// Page indicator, e.g. '01 / 03'. Format is locale-invariant (matches iOS, which leaves this string untranslated).
  ///
  /// In en, this message translates to:
  /// **'0{page} / 0{total}'**
  String onboardingPageIndicator(int page, int total);

  /// No description provided for @locationIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Start where you are.'**
  String get locationIntroTitle;

  /// No description provided for @locationIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Your location finds spots nearby. It is never included in a public report.'**
  String get locationIntroBody;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @useUnionSquareInstead.
  ///
  /// In en, this message translates to:
  /// **'Use Union Square instead'**
  String get useUnionSquareInstead;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get profileTitle;

  /// No description provided for @profileHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your city is your office.'**
  String get profileHeroTitle;

  /// No description provided for @profileHeroBody.
  ///
  /// In en, this message translates to:
  /// **'BrewDesk researches Wi-Fi, seating, outlets, noise, and laptop policy so you can choose a spot with confidence.'**
  String get profileHeroBody;

  /// No description provided for @profileAccountlessTitle.
  ///
  /// In en, this message translates to:
  /// **'Accountless by design'**
  String get profileAccountlessTitle;

  /// No description provided for @profileAccountlessBody.
  ///
  /// In en, this message translates to:
  /// **'Your saved spots stay on this device. Location is used only to find nearby places.'**
  String get profileAccountlessBody;

  /// No description provided for @profileTransparentTitle.
  ///
  /// In en, this message translates to:
  /// **'Transparent research'**
  String get profileTransparentTitle;

  /// No description provided for @profileTransparentBody.
  ///
  /// In en, this message translates to:
  /// **'Every workability fact carries its source. Estimates are labeled instead of presented as verified.'**
  String get profileTransparentBody;

  /// No description provided for @profileMoreThanCafesTitle.
  ///
  /// In en, this message translates to:
  /// **'Built for more than cafes'**
  String get profileMoreThanCafesTitle;

  /// No description provided for @profileMoreThanCafesBody.
  ///
  /// In en, this message translates to:
  /// **'Libraries, parks, malls, and other practical work spots belong here too.'**
  String get profileMoreThanCafesBody;

  /// No description provided for @profileHowScoringWorks.
  ///
  /// In en, this message translates to:
  /// **'How scoring works'**
  String get profileHowScoringWorks;

  /// No description provided for @profileAboutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAboutSectionTitle;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get profileTermsOfUse;

  /// No description provided for @profileOpenSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get profileOpenSourceLicenses;

  /// No description provided for @profileVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersionLabel;

  /// No description provided for @navSpots.
  ///
  /// In en, this message translates to:
  /// **'Spots'**
  String get navSpots;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @savedImportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import from Google Takeout'**
  String get savedImportTooltip;

  /// No description provided for @savedImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get savedImportAction;

  /// No description provided for @savedFileReadError.
  ///
  /// In en, this message translates to:
  /// **'That file couldn\'t be read.'**
  String get savedFileReadError;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your next work spot'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks stay on this device. No account required.'**
  String get savedEmptyBody;

  /// No description provided for @savedBrowseNearby.
  ///
  /// In en, this message translates to:
  /// **'Browse nearby'**
  String get savedBrowseNearby;

  /// No description provided for @savedFailedRowMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this saved spot.'**
  String get savedFailedRowMessage;

  /// No description provided for @savedRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get savedRemove;

  /// No description provided for @takeoutResultSummary.
  ///
  /// In en, this message translates to:
  /// **'{matched} matched · {unmatched} not in BrewDesk yet'**
  String takeoutResultSummary(int matched, int unmatched);

  /// No description provided for @takeoutConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Matched spots are saved to BrewDesk when you confirm.'**
  String get takeoutConfirmHint;

  /// No description provided for @takeoutNotInBrewDeskYet.
  ///
  /// In en, this message translates to:
  /// **'Not in BrewDesk yet'**
  String get takeoutNotInBrewDeskYet;

  /// No description provided for @venueDetailWorkabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Workability'**
  String get venueDetailWorkabilityTitle;

  /// No description provided for @venueDetailWhatWeKnowTitle.
  ///
  /// In en, this message translates to:
  /// **'What we know'**
  String get venueDetailWhatWeKnowTitle;

  /// No description provided for @venueDetailClaimLaptopPolicy.
  ///
  /// In en, this message translates to:
  /// **'Laptop policy'**
  String get venueDetailClaimLaptopPolicy;

  /// No description provided for @venueDetailClaimNoise.
  ///
  /// In en, this message translates to:
  /// **'Noise'**
  String get venueDetailClaimNoise;

  /// No description provided for @venueDetailClaimSeating.
  ///
  /// In en, this message translates to:
  /// **'Seating'**
  String get venueDetailClaimSeating;

  /// No description provided for @venueDetailOsmDescription.
  ///
  /// In en, this message translates to:
  /// **'This is a real OpenStreetMap listing. Workability details have not been deeply researched yet.'**
  String get venueDetailOsmDescription;

  /// No description provided for @venueDetailResearchedDescription.
  ///
  /// In en, this message translates to:
  /// **'This spot combines public-source research with transparent claim-level provenance.'**
  String get venueDetailResearchedDescription;

  /// No description provided for @venueDetailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String venueDetailUpdated(String date);

  /// No description provided for @venueDetailDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get venueDetailDirections;

  /// No description provided for @venueDetailRemoveFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get venueDetailRemoveFromSaved;

  /// No description provided for @venueDetailSaveSpot.
  ///
  /// In en, this message translates to:
  /// **'Save spot'**
  String get venueDetailSaveSpot;

  /// No description provided for @venueDetailShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get venueDetailShare;

  /// Shelf/saved venue card's short provenance line — rendered only when the venue has a known observation date (house rule: unknown/optional data renders nothing).
  ///
  /// In en, this message translates to:
  /// **'Updated {date} · {source}'**
  String venueCardProvenance(String date, String source);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
