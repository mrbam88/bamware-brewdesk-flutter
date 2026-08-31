# Play submission runbook (Human-only — ticket #5)

Ordered checklist for Bilal. Everything an agent could prepare without a
Console account or spend is already done (this ticket, #15); everything
below needs the Play Console account, a $25 one-time registration fee, or a
real signing key, so it stays Human-only.

## 1. Register the Play Console account

- Sign up at https://play.google.com/console/signup — **$25 one-time fee**
  (spend gate: this crosses the "quote-and-confirm" line in `AGENTS.md`,
  but it's a known, fixed, one-time Google fee, not a discretionary run —
  confirm you're ready before paying).
- Complete developer identity verification (Google may take up to 48h).

## 2. Generate the upload keystore (never done by an agent)

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

- Store `~/upload-keystore.jks` somewhere durable and backed up (password
  manager attachment, encrypted backup). **Losing it forfeits your ability
  to update this app under `io.bamware.brewdesk` — Google cannot recover or
  reset an upload key.**
- Copy `android/key.properties.template` to `android/key.properties` and
  fill in the real `storePassword`, `keyPassword`, `keyAlias`, and absolute
  `storeFile` path. This file is gitignored (`android/.gitignore`) — never
  commit it, and gitleaks will fail the build if a key value leaks into a
  tracked file.

## 3. Build the real signed AAB

```bash
bundle install                      # once — installs fastlane (root Gemfile)
bundle exec fastlane android aab
```

With `android/key.properties` present, `android/app/build.gradle.kts`
automatically switches the release `signingConfig` from the debug key to
your upload key (see the `hasKeystoreProperties` check). Verify it actually
signed with your key, not the debug key:

```bash
jarsigner -verify -verbose -certs \
  build/app/outputs/bundle/release/app-release.aab
```

Look for your own certificate DN in the output, not the Android Debug
placeholder.

## 4. Create the app in Play Console

- App name: see `submission/docs/LISTING.md`.
- Default language: en-US.
- App or game: **App**. Free or paid: **Free**.
- Declarations: not a government app, not primarily for children, no ads
  (confirm still true at submission time — this build has no ad SDK).

## 5. App content section

- **Data safety** — transcribe `submission/docs/DATA-SAFETY.md`. Resolve its one
  open item (venue-engine location-logging retention) before submitting.
- **Content rating** — run the IARC questionnaire using
  `submission/docs/CONTENT-RATING.md` as the answer key.
- **Target audience and content** — general audience, not designed for
  children.
- **News apps / COVID-19 apps / government apps** — No to all.
- **Data deletion** (if the ephemeral-processing answer in DATA-SAFETY.md
  changes to "collected and stored") — add a deletion path before this
  step; otherwise not applicable.

## 6. Store listing

- Fill title, short description, full description, category, and contact
  details from `submission/docs/LISTING.md`. Two open decisions live there
  (category confirmation, contact email) — resolve both before publishing.
- App icon (512×512) and feature graphic (1024×500): **blocked** — this
  repo still ships Flutter's default template launcher icon, not BrewDesk
  branding. Replace `android/app/src/main/res/mipmap-*/ic_launcher.png`
  (and add the two Play-only marketing graphics) before this step; out of
  scope for #15 alongside screenshots.
- Screenshots: out of scope for #15 per its issue body ("need final UI") —
  needs its own pass once the UI is final.

## 7. Countries and pricing

- BrewDesk's dataset is NYC-only (`README.md`, `submission/docs/LISTING.md`
  description). **Decision needed:** restrict initial distribution to the
  US (recommended — avoids confusing installs from users the dataset can't
  serve) or release worldwide. Not decided by this ticket; pick a country
  list at this step.
- Pricing: Free (matches "FREE AND ACCOUNTLESS" in the listing copy).

## 8. Internal testing track (first upload: Console UI)

- Create the Internal testing track, add your own email (and any other
  early testers) to the tester list.
- Upload the signed AAB from step 3 **through the Console UI** — Google
  requires the app record's very first bundle to arrive that way.
- Roll out to internal testing and install via the opt-in link to confirm
  the signed build installs and runs before wider distribution.

## 8b. Wire fastlane for every upload after the first

- Google Cloud console → create a service account, grant it access in Play
  Console (Users and permissions → Invite new user → its email → Release
  permission), create a JSON key, store it OUTSIDE the repo.
- `export SUPPLY_JSON_KEY=/absolute/path/to/key.json` (shell profile or
  password manager).
- From then on, per release: bump `version:`'s `+N` in `pubspec.yaml`, add
  `submission/metadata/android/en-US/changelogs/<N>.txt`, and run
  `bundle exec fastlane android internal`. Listing/graphics changes ship
  separately with `bundle exec fastlane android listing`.

## 9. Submit for review

- Once internal testing confirms the build, promote through Play's normal
  track progression (internal → closed/open testing → production) at your
  own pace — this ticket does not decide that cadence.
- Play review is typically hours, not Apple's multi-day 4.3 risk profile;
  no equivalent rejection-response pack exists yet for Play because none
  has been needed. If a rejection happens, log it in `bamware-ai/STATE.md`
  the way the Baat 4.3(b) rejection was logged, so the pattern is captured.

## Version scheme reference

`android/app/build.gradle.kts` reads `versionCode`/`versionName` from
`pubspec.yaml`'s `version: X.Y.Z+N`. `versionName` (`X.Y.Z`) is semantic —
bump it however feels right per release. `versionCode` (`N`, after the
`+`) must strictly increase on **every** artifact uploaded to Play,
including internal-testing-only builds — it never resets, is never
reused, and Play will reject an upload whose versionCode does not exceed
the previous one. Current: `1.0.0+1` (`pubspec.yaml`).
