# stay-on-target Dashboard & Startup Enhancements — Design Spec

## Problem

The stay-on-target skill works but has two gaps: (1) users don't get a reminder of how the skill works when they invoke it, and (2) there's no visibility into drift patterns and history over time. Users want to see their tendencies and a feed of all drift events across sessions.

## Overview

Two enhancements to the existing stay-on-target skill:

1. **Adaptive startup instructions** — first-time users see a full walkthrough, returning users see a compact cheat sheet with their patterns
2. **Local drift dashboard** — a per-user static HTML file showing drift pattern summaries and a chronological event feed, seeded with dummy data

## Design Principles

- No servers, no dependencies — static HTML generated from data files
- Per-user everything — each user gets their own dashboard and log
- Minimal additions to the existing skill — extend, don't rewrite

---

## Section 1: Adaptive Startup Instructions

### Detection

When the skill is invoked, check if `feedback_drift_patterns_{name}.md` exists in Claude memory for the current driver.

- **Exists** → returning user → show compact cheat sheet
- **Does not exist** → first-time user → show full walkthrough

### First-Time User Walkthrough

Display a clear, scannable overview:
- What the skill does (one sentence)
- The three phases: objective lock-in, active drift detection, pattern learning
- The three-question filter with a brief example
- How parked ideas work
- How the drift profile learns over time
- Then proceed to objective lock-in as normal

### Returning User Cheat Sheet

Display a compact block before objective lock-in:

```
── Stay on Target ─────────────────────
Filter: (1) Client ask? (2) Serves objective? (3) Skip OK?
No/No/Yes → Park it. Gray area → Ask yes/no.

Your patterns:
  ⚠ Auth/onboarding creep (high) — triggers during frontend
  ⚠ Feature stacking (high) — triggers mid-implementation
  ⚠ Over-engineering (high) — triggers at kickoff

Ready for objective lock-in.
───────────────────────────────────────
```

Patterns are pulled from the driver's drift profile. Show top 3 by frequency. Then proceed to objective lock-in.

---

## Section 2: Drift Event Logging

### Log File

Per-user JSON file: `~/.claude/skills/stay-on-target/drift-log-{name}.json`

One JSON object per line (JSONL format).

### Event Schema

```json
{
  "date": "2026-03-24",
  "time": "14:32",
  "project": "virtual-staging",
  "suggestion": "Add MLS scraper to pull photos automatically",
  "category": "delivery-reimagining",
  "trigger_context": "architecture planning",
  "result": "parked",
  "driver": "ryan"
}
```

### When Events Are Logged

- **Park** — filter returned off-target, idea was parked. Result: `parked`
- **Override** — filter returned off-target, user said "build it anyway". Result: `overridden`
- **Gray area resolved yes** — ambiguous case, resolved to proceed. Result: `gray-yes`
- **Gray area resolved no** — ambiguous case, resolved to skip. Result: `gray-no`
- **Preemptive warning fired** — known pattern flagged before drift happened. Result: `warned`

The skill appends to this file as part of its normal drift detection flow. No extra action from the user.

---

## Section 3: Dashboard

### File Location

Per-user static HTML: `~/.claude/skills/stay-on-target/dashboard-{name}.html`

Ryan gets `dashboard-ryan.html`. Partner gets `dashboard-{partner}.html`. Each contains only their own data.

### Generation

The skill generates/regenerates the dashboard:
- On skill invocation (if log data exists)
- On demand when user asks to see the dashboard

Data from the JSON log is read and embedded directly into the HTML at generation time. No live server or external data fetching needed.

### Layout

**Top bar:**
- User name
- Total sessions tracked (distinct project count from log)
- "Last updated" timestamp
- Stats row: total drifts caught, % parked vs overridden, most common pattern

**Left panel — Drift Pattern Summary:**
- Each known pattern as a card: category name, frequency badge (high/medium/low), trigger context
- Count of times each pattern has fired (from log data)
- Trend indicator (increasing/decreasing/stable based on recent vs older events)

**Right panel — Drift Event Feed:**
- Chronological feed, newest first
- Each entry: date, project name, suggestion text, category tag, result badge
- Color-coded results: parked (neutral/gray), overridden (amber), warned (blue/subtle)
- Filterable by category and result type via simple JS toggles

### Design

- Vanilla HTML/CSS/JS, no frameworks
- Clean, minimal aesthetic
- Responsive — works on any screen size
- Self-contained single file (CSS and JS inline)

---

## Section 4: Dummy Data Seeding

### Purpose

Seed Ryan's log file and dashboard with realistic dummy data so the dashboard demonstrates all visual states on first use.

### Seed Data

~15-20 events across 4-5 fictional projects, spread over the last 30 days:

| Project | Suggestion | Category | Result |
|---------|-----------|----------|--------|
| virtual-staging | MLS scraper for auto photo import | delivery-reimagining | parked |
| virtual-staging | Login system for agents | auth-creep | parked |
| virtual-staging | Agent onboarding flow | auth-creep | parked |
| virtual-staging | Batch processing queue | over-engineering | parked |
| client-crm | Email integration from contact cards | feature-stacking | overridden |
| client-crm | Analytics dashboard | feature-stacking | parked |
| client-crm | Role-based access control | auth-creep | parked |
| client-crm | Full audit logging | over-engineering | parked |
| warranty-form | Chatbot replacement for form | delivery-reimagining | parked |
| warranty-form | AI auto-classification of issues | feature-stacking | gray-yes |
| warranty-form | Photo enhancement before submission | feature-stacking | parked |
| team-dashboard | Auth system | auth-creep | warned |
| team-dashboard | Role-based access | auth-creep | parked |
| team-dashboard | Slack integration for updates | feature-stacking | parked |
| team-dashboard | Real-time WebSocket updates | over-engineering | parked |
| booking-app | Waitlist for full slots | feature-stacking | parked |
| booking-app | SMS confirmation notifications | feature-stacking | parked |
| booking-app | Calendar sync integration | feature-stacking | gray-no |
| booking-app | Multi-location support | over-engineering | warned |

Distribution: heavy on auth-creep and feature-stacking (matches Ryan's profile), lighter on delivery-reimagining.

---

## Changes to Existing Skill

### SKILL.md Updates

Add to Phase 2 (Active Drift Detection):
- After each filter evaluation, append event to `drift-log-{driver}.json`

Add new section:
- **Startup Display** — instructions for adaptive cheat sheet vs walkthrough

### New Files

| File | Purpose |
|------|---------|
| `~/.claude/skills/stay-on-target/drift-log-{name}.json` | Per-user drift event log (JSONL) |
| `~/.claude/skills/stay-on-target/dashboard-{name}.html` | Per-user static dashboard |

### No Changes To

- Drift profile memory files (they stay as pattern summaries)
- Objective ledger or parked ideas (per-project, unchanged)
- Three-question filter logic (unchanged)

---

## Implementation Notes

### File-Write Mechanics

The skill is prompt-driven. All file operations (JSONL append, HTML generation) use Claude's standard file-writing tools (Write tool for new files, Edit tool for appends). This is the same mechanism already used for writing `docs/objectives.md` and `docs/parked-ideas.md`. No MCP tools or background processes.

### JSONL Append Pattern

After each filter evaluation in Phase 2, Claude appends one JSON line to `drift-log-{driver}.json` using the Write/Edit tool. If the file doesn't exist (first drift event for a new user), create it. The seed step pre-creates Ryan's file with dummy data.

### Dashboard Regeneration

The dashboard is regenerated **on demand only** — when the user asks to see it (e.g., "show me my dashboard" or "update my dashboard"). It is NOT regenerated on every skill invocation, to avoid adding latency to the startup flow. The skill mentions the dashboard exists during the startup cheat sheet if log data is present.

### Returning User Detection

Check for the drift log file (`drift-log-{name}.json`) rather than the drift profile memory file. The log file is written to on every drift event and is a more reliable signal of prior usage than the profile (which requires explicit approval to update).

### Driver Name Normalization

Driver names are lowercased before use in all file paths and log entries. "Ryan", "RYAN", and "ryan" all resolve to `drift-log-ryan.json`.

### Category Taxonomy

Drift categories are free-form strings. The dashboard groups by whatever strings appear in the log. The canonical categories from Ryan's profile are: `auth-creep`, `delivery-reimagining`, `feature-stacking`, `over-engineering`. New categories can emerge organically.

### Error Handling

- Dashboard generator skips malformed JSONL lines rather than failing
- Empty log file produces a valid dashboard with an empty state (message: "No drift events yet")
- Missing log file at dashboard generation time produces the empty state
