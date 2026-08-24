# BrewDesk Flutter domain terms

- **Claim / provenance:** each venue fact carries a value and source. Unknown
  and estimated facts must stay visibly honest.
- **Work Fit:** the Venue Engine's 0-100 `workScore`, not a review rating.
- **Coverage:** response-level `researched`, `baseline`, or `none`. Baseline
  spots are real OSM listings with intentionally shallow workability data.
- **Shelf:** the draggable discovery list over the map. It stays inside the
  Discover tab so bottom navigation remains reachable.
- **Saved spot:** a venue id persisted locally with `SharedPreferences`. The
  MVP has no account or cross-device sync.
