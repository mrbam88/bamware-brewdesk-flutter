# submission/ — everything Play-submission-related, in one place

House rule (Bilal, 2026-08-30): anything related to store submission —
graphics, assets, metadata, instructions — lives HERE, in the app repo,
and ships through **fastlane** (consistent with the dating app and the
SwiftUI BrewDesk). The rails themselves are `fastlane/Fastfile` at the
repo root (the standard fastlane location); this folder is the content
they ship.

## Layout

| Path | What |
|---|---|
| `docs/SUBMISSION-RUNBOOK.md` | The ordered human checklist (ticket #5): Console account, keystore, first upload |
| `docs/LISTING.md` | Listing copy source-of-truth + the two open decisions (category, contact email) |
| `docs/DATA-SAFETY.md` | Answer key for Play's Data safety form |
| `docs/CONTENT-RATING.md` | Answer key for the IARC questionnaire |
| `metadata/android/en-US/` | Listing-as-code in fastlane supply's layout (see below) |

`metadata/android/en-US/`:
- `title.txt`, `short_description.txt`, `full_description.txt` — synced
  from `docs/LISTING.md` (edit LISTING.md first, then mirror here)
- `changelogs/<versionCode>.txt` — one file per uploaded versionCode
  (pubspec's `+N`); Play rejects reused codes
- `images/icon.png` (512×512), `images/featureGraphic.png` (1024×500),
  `images/phoneScreenshots/*.png` — pending ticket #38

The app ships an es locale; an `es-US/` listing translation is an optional
follow-up (copywriting, not plumbing).

## Lanes

```bash
bundle install               # once — installs fastlane (Gemfile at root)
bundle exec fastlane android aab       # build the signed release AAB only
bundle exec fastlane android internal  # build + upload to internal testing
bundle exec fastlane android listing   # push metadata + graphics + screenshots
```

Requirements:
- `android/key.properties` + upload keystore (runbook step 2) — the AAB
  must be release-signed or Play rejects it.
- `SUPPLY_JSON_KEY` env var = path to a Play service-account JSON with
  release permission (runbook has the provisioning steps). Never commit it.
- **First time only:** the app record and the very first AAB go through the
  Play Console UI (Google requires it); fastlane owns every upload after
  that. `internal` uploads the binary only; `listing` owns store copy — the
  split means a build can never accidentally rewrite the listing.
