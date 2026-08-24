# AGENTS.md - bamware-brewdesk-flutter

Read `../bamware-ai/AGENTS.md` first. It is the Bamware system map and source
of truth for contracts, security, spend, and shipping rules.

## What this is

BrewDesk's Flutter/Android client. It consumes the same private Venue Engine as
the native SwiftUI app, but shares no UI implementation code.

- API authority: `../bamware-venue-engine/src/schema.ts` and
  `../bamware-ai/docs/brewdesk-mvp-contract.md`
- Product vocabulary: `CONTEXT.md`
- Visual north star: `docs/design/BrewDeskDesignSpecv1.pdf`
- Android application id: `io.bamware.brewdesk`

Any Venue Engine response-shape change must update both BrewDesk clients and
`bamware-ai/docs/contracts.md` in coordinated PRs.

## Agent skills

### Issue tracker

Issues and specs live in `mrbam88/bamware-brewdesk-flutter` GitHub Issues and
are also fielded on Bamware Project 2. See `docs/agents/issue-tracker.md`.

### Triage labels

Use the five default engineering-skill labels. See
`docs/agents/triage-labels.md`.

### Domain docs

This is a single-context repo with root `CONTEXT.md` and ADRs under
`docs/adr/`. See `docs/agents/domain.md`.
