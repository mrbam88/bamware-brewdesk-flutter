# Play Store listing copy

Ported from `~/code/bamware-brewdesk/fastlane/metadata/en-US/` (the ASC
listing), truthfully adapted for Play's field names/limits. No claims were
invented — everything below is either verbatim from the source files or a
direct trim of them. Source files read: `name.txt`, `subtitle.txt`,
`description.txt`, `keywords.txt`, `promotional_text.txt`, `privacy_url.txt`,
`support_url.txt` (2026-08-28).

## App name (Play limit: 30 characters)

```
BrewDesk — WFH Cafés
```

20 characters. Verbatim from ASC `name.txt`.

## Short description (Play limit: 80 characters)

```
NYC WFH cafés, with evidence
```

28 characters. Verbatim from ASC `subtitle.txt` — it already reads like a
Play short description and needs no further trimming.

## Full description (Play limit: 4000 characters)

```
Know why a café fits your workday — before you order.

BrewDesk is built for one job: working from cafés in New York City. It evaluates laptop policy first (including cafés that limit or discourage laptops — shown openly, never hidden), then seating, Wi-Fi, outlets, and noise. Every claim displays its source, its confidence, and the date it was last updated. Estimates stay labeled instead of pretending to be facts.

SEE THE EVIDENCE
• Every card carries an "updated" stamp — when the data was checked and where it came from
• A human-verified seal appears only when a person stands behind a claim
• "How Work Fit is scored" explains the entire formula inside the app — weights, confidence, and the 90-day freshness decay. No black boxes.

BUILT FOR LAPTOP WORK
• Laptop policy up front: friendly, time-limited, weekend rules, or discouraged — filter for it
• Seating and outlet filters for actually getting work done
• Wi-Fi rated honestly: above ~25 Mbps more speed stops mattering, so we say so
• 2,000+ cafés across New York City with a transparent Work Fit score

BRING YOUR OWN SPOTS
Import your saved places from Google Maps (Takeout file) — matched on-device, never uploaded.

LOCATION IS OPTIONAL
Rank nearby cafés with your location, or browse all of NYC without granting it. Outside New York? You'll still see the full dataset. BrewDesk keeps no location history.

FREE AND ACCOUNTLESS
No account, subscription, advertising, analytics, or tracking.

Café conditions change. BrewDesk shows freshness and sourcing so you can judge the evidence — but always confirm important details with the venue.

Venue data combines curated research, OpenStreetMap, and labeled estimates. © OpenStreetMap contributors.
```

Verbatim from ASC `description.txt`, ~1,450 characters — well under Play's
4,000-character limit. One line held back deliberately: the "Import your
saved places" Google Maps Takeout claim is present in this build's README
feature list and is accurate for this repo — kept as-is.

## Category

**Recommendation: Maps & Navigation.** No `category.txt` exists in the ASC
source to port (App Store and Play use different category taxonomies
entirely, so there was nothing to port either way) — **this is a decision
the spec didn't cover, owner: Bilal.** Reasoning for the recommendation:
the app's primary interaction is a map with location-ranked pins
(`CafeMapScreen`/discovery flow), which fits Play's "Maps & Navigation"
better than "Travel & Local" (aimed at trip planning) or "Food & Drink"
(aimed at menus/delivery, and BrewDesk explicitly is not about food).
Confirm at submission time — this is a single-select field and changing it
later re-triggers review.

## Contact details

- **Website:** `https://bamware.io/brewdesk/support` — verified live
  (`curl -o /dev/null -w '%{http_code}'` → `200`, 2026-08-28).
- **Privacy policy URL:** `https://bamware.io/brewdesk/privacy` — verified
  live (`curl -o /dev/null -w '%{http_code}'` → `200`, 2026-08-28).
- **Email:** Play Console requires a contact email shown to users on the
  store listing. No `email.txt` exists in the ASC source, and this repo has
  no authority to decide whether Bilal's personal address or a dedicated
  support alias goes public on the Play Store listing. **Decision needed,
  owner: Bilal** — pick the address at submission time in Play Console →
  Store settings → Contact details.
- **Phone:** optional in Play Console; not set (ASC source has no phone
  number either).

## Keywords / tags

Play has no direct keywords field (unlike App Store), but the short/full
description above already carries the ASC `keywords.txt` terms naturally
(nyc, wfh, cafe, wifi, laptop, outlets, seating, remote work, coffee shop,
work friendly) for Play's description-text search indexing.

## Graphics not covered here

App icon (512×512), feature graphic (1024×500), and phone/tablet
screenshots are out of scope per issue #15 ("Screenshots (need final UI)")
— tracked separately. Note for the runbook: the repo currently ships
Flutter's default template launcher icon
(`android/app/src/main/res/mipmap-*/ic_launcher.png`), not BrewDesk
branding; that needs a real icon before the Play Console listing can be
completed, not just before screenshots.
