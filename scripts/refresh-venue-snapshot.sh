#!/bin/sh
# Refresh the bundled cold-start snapshot (#12) from the production Venue
# Engine. Top 50 by Work Fit around the coverage anchor (Union Square), with
# distance_m and googlePlaceId stripped since they are relative to a live
# query, not this file. Run before a release when the dataset has moved;
# commit the result. Ported from bamware-brewdesk's
# scripts/refresh-venue-snapshot.sh.
set -eu
cd "$(dirname "$0")/.."
URL='https://venuekit-ashen.vercel.app/v1/venues?lat=40.7359&lng=-73.9911&radius_m=2500&sort=work_score&limit=50'
OUT='assets/venue_snapshot.json'
curl -fsS "$URL" | python3 -c '
import json, sys, datetime
url = sys.argv[1]
d = json.load(sys.stdin)
venues = [{k: v for k, v in venue.items() if k not in ("distance_m", "googlePlaceId")} for venue in d["venues"]]
lines = ",\n".join("    " + json.dumps(v, ensure_ascii=False, separators=(",", ":")) for v in venues)
now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
print("{\n  \"source\": %s,\n  \"capturedAt\": %s,\n  \"note\": \"Bundled cold-start snapshot (#12). distance_m stripped: distances are relative to the live query, not this file. Refresh with scripts/refresh-venue-snapshot.sh.\",\n  \"count\": %d,\n  \"venues\": [\n%s\n  ]\n}" % (json.dumps(url), json.dumps(now), len(venues), lines))
' "$URL" > "$OUT"
bytes=$(wc -c < "$OUT" | tr -d ' ')
echo "wrote $OUT ($bytes bytes)"
if [ "$bytes" -ge 204800 ]; then
  echo "ERROR: snapshot is $bytes bytes, over the 200KB (204800 byte) budget" >&2
  exit 1
fi
