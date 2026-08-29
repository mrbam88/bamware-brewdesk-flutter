# Play Data safety form — answer key

Filled in from the app's actual behavior as of this repo, verified in
`lib/data/services/venue_api.dart`, `lib/data/services/location_service.dart`,
`lib/data/services/saved_venues_service.dart`, and the network calls in
`lib/ui/features/discovery/discovery_screen.dart` (2026-08-28). Mirrors the
iOS "data not collected"-adjacent story truthfully for what the Android
client actually does — it is not a copy-paste of the iOS answer, because
Android's permission model (foreground fine + coarse location) differs from
iOS's.

This is the answer key for the form at Play Console → App content → Data
safety. Structure and question wording verified against [Google's Data
safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469)
and the [ephemeral-processing exemption](https://support.google.com/googleplay/android-developer/answer/10787469)
(2026-08-28).

## What the app actually does with data

- `VenueApi.search()` POSTs `{lat, lng, radius_m, limit}` to
  `https://venuekit-ashen.vercel.app/v1/venues/search` once per discovery
  load/refresh. This is the only place device location leaves the device.
- `LocationService.currentLocation()` requests fine location
  (`LocationAccuracy.medium`) via `geolocator`. If permission is denied or
  location is off, the app falls back to browsing the full NYC dataset
  (README: "Rank nearby cafés with your location, or browse all of NYC
  without granting it").
- The in-app search box (`discovery_screen.dart`) filters the
  already-fetched venue list on-device. No search text is sent to any
  server — there is no `search` query param or text field in `VenueApi`.
- Saved spots (`SavedVenuesService`) are venue IDs written to
  `SharedPreferences` only. They never leave the device — no account, no
  sync endpoint.
- Map tiles load from `https://tile.openstreetmap.org` (OSM's standard tile
  server), which receives the visible map viewport per OSM's own tile
  usage, not from this app's own backend.
- No analytics, crash-reporting, or advertising SDK is in `pubspec.yaml`
  (dependencies: `http`, `flutter_map`, `latlong2`, `shared_preferences`,
  `geolocator`, `url_launcher`, `cupertino_icons` only). No accounts, no
  sign-in, no user-generated content.

## Section: Does your app collect or share any of the required user data types?

**Answer: Yes** (location, for app functionality).

## Location

| Field | Approximate location | Precise location |
|---|---|---|
| Collected? | Yes | Yes |
| Shared with third parties? | No | No |
| Processing | Ephemeral — see note | Ephemeral — see note |
| Optional or required? | Optional (app works fully without it) | Optional |
| Purpose | App functionality | App functionality |

**Ephemeral-processing note:** each search request sends the device's
current lat/lng to the venue engine in memory, to rank/filter venues for
that one request, and the README's product claim is "BrewDesk keeps no
location history." This matches Google's own weather-app example of
ephemeral use. **Decision needed before submitting (owner: Bilal, backend
is `bamware-venue-engine`):** confirm the venue engine does not persist
raw request coordinates in access logs beyond routine, short-lived
operational logging. If it does, declare precise + approximate location as
**collected and stored**, purpose **App functionality**, instead of
ephemeral. This repo (the Flutter client) cannot verify server-side
retention — only the venue-engine owner can.

## Personal info

Not collected. No name, email, address, phone number, or user IDs are
requested or transmitted — there is no account system.

## Financial info

Not collected. No payments, in-app purchases, or subscriptions exist.

## Messages, Photos and videos, Audio files, Files and docs, Calendar, Contacts, Health and fitness

Not collected. The app displays venue photos served by the venue engine
(sourced from Google Places/OSM upstream, per `bamware-venue-engine`); it
does not collect the user's own photos, files, contacts, or health data.

## App activity

Not collected. In-app search/filtering is local-only (see above) — no
search history, app interactions, or other user-generated content are
transmitted off-device. Saved-spot IDs stay in on-device
`SharedPreferences` and, per Google's on-device-only exemption, do not need
to be declared as collected.

## Web browsing, App info and performance, Device or other IDs

Not collected. No crash/diagnostics SDK, no device identifiers are read or
transmitted.

## Security practices section

- **Is all of the user data collected by your app encrypted in transit?**
  Yes — the venue engine call is HTTPS (`https://venuekit-ashen.vercel.app`)
  and OSM tiles load over HTTPS.
- **Do you provide a way for users to request that their data is
  deleted?** Not applicable in the strict sense — there is no account and
  no server-side user data to delete. If the ephemeral-processing decision
  above lands on "collected and stored," this answer must change and a
  deletion path must be added before submission.
- **Data safety practices independently validated against a global
  security standard?** No.

## Owner for the one open decision

Bilal, before filling the Play Console form: confirm venue-engine request
logging retention (see Ephemeral-processing note above), then this file's
Location table is final as written.
