# BrewDesk Flutter

Android-first Flutter client for BrewDesk, the researched WFH-spot finder.

## MVP

- Device-aware map and nearby venue discovery
- Search and practical workability filters
- Work Fit scores with researched vs OSM-baseline coverage
- Venue details, photos with attribution, and walking directions
- Accountless on-device saved spots
- Light and dark Material 3 themes

The app consumes `https://venuekit-ashen.vercel.app`. The API contract remains
owned by `bamware-venue-engine`; this repo is a hand-declared client and must be
updated alongside any service response-shape change.

## Cold-start snapshot

`assets/venue_snapshot.json` bundles the top 50 NYC venues by Work Fit so the
first frame paints instantly, before the app has heard back from the network
(#12). `VenueRepository.coldStart()` serves it the moment the cache is empty,
then swaps in live results as they arrive; if the live call fails, the
snapshot stays visible with a "showing bundled data" note instead of leaving
the screen empty.

Refresh it from the production Venue Engine before a release when the dataset
has moved:

```bash
scripts/refresh-venue-snapshot.sh
```

Requires `curl` and `python3`. It writes `assets/venue_snapshot.json` and
fails if the result is 200KB or larger — commit the refreshed file.

## Run

```bash
flutter pub get
flutter run
```

## Verify

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Visual direction: `docs/design/BrewDeskDesignSpecv1.pdf`. The Android launcher
icon and launch background are generated from
`android/app/src/icon-source/generate_launcher_icon.py` (Pillow, no pubspec
dependency) — rerun it after any brand-color change and commit the regenerated
`mipmap-*/ic_launcher.png` densities.

Play submission prep and runbook: `submission/docs/`.
