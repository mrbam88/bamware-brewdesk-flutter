# Play Content rating (IARC) questionnaire — answer key

Play Console → App content → Content ratings uses the IARC questionnaire.
Answers below are based on the app as built in this repo — a venue-finder
utility with no user-generated content, no chat/messaging, and no
in-app purchases. Category to select in the questionnaire: **Reference,
News, or Educational** if offered, otherwise **Utility / Productivity** —
the questionnaire's own category picker vocabulary can drift between IARC
versions, so this is a best-effort pointer, not a guaranteed exact label
(verify at fill-time, owner: Bilal).

## Violence

- Does the app contain realistic or cartoon violence? **No.**
- Depictions of blood/gore? **No.**

## Sexual content / nudity

- Any sexual content or nudity? **No.**

## Profanity / crude humor

- Any profanity or crude humor? **No.**

## Controlled substances

- References to alcohol, tobacco, or drugs? **No.** (Café/coffee-shop
  discovery does not reference alcohol or drug use; it is a laptop-work
  venue finder, not a bar/nightlife app.)

## Gambling

- Simulated gambling or references to real-money gambling? **No.**

## User interaction

- Does the app allow users to interact with each other (chat, share
  content, etc.)? **No.** There is no account system, messaging, or social
  feature in this build. (Community features are explicitly out of scope
  for this release — tracked separately, DO-NOT-BUILD pre-approval per
  `STATE.md`.)
- Does the app share the user's physical location with other users, or
  allow the user to broadcast location publicly? **No.** Location is used
  only to rank venues for the requesting device; see
  `docs/play/DATA-SAFETY.md`.
- Does the app allow users to share personal information with other
  users? **No.**

## User-generated content

- Does the app contain or allow user-generated content (UGC) that other
  users can see? **No.**

## Digital purchases

- Does the app allow purchase of digital goods? **No.** Free, accountless,
  no in-app purchases, no subscriptions, no ads.

## Miscellaneous

- Does the app share the user's location? **No** (see User interaction).
- Does the app allow the user to purchase real-world goods/services? **No.**
- Does the app contain any unrated/user-generated web content (e.g. an
  embedded browser)? **No.** `url_launcher` opens the OS browser/maps app
  for directions and the privacy-policy link — it hands off to the system,
  it does not embed a WebView.

## Expected outcome

Given all "No" answers above, the expected IARC rating is the most
permissive tier offered per territory (e.g. **Everyone** / **PEGI 3** /
**USK 0**, region-dependent) — the questionnaire computes the final rating
automatically; this doc is the input, not the output. No owner action
needed unless a future build adds chat, UGC, or purchases, in which case
this file must be re-answered before re-submitting.
