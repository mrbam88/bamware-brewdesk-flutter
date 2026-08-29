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

Visual direction: `docs/design/BrewDeskDesignSpecv1.pdf`.

Play submission prep and runbook: `docs/play/`.
