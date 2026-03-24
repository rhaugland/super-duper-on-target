# stay-on-target Quality Tiers — Design Spec

## Problem

The stay-on-target skill catches scope drift (building the wrong things) and verifies client expectations (building the right things) but doesn't address a third failure mode: rushing. When time anxiety kicks in, the builder skips design decisions, cuts corners on craft, and avoids iteration — shipping work that functions but doesn't meet their own quality bar. The deliverable works but feels rough, generic, or unfinished.

## Overview

Two additions to the existing skill:

1. **Quality commitment** — During Phase 1 objective lock-in, the builder picks a quality tier (Craft, Functional, or Prototype) with an optional reference. This is a one-word commitment that takes 2 seconds and calibrates all quality enforcement.
2. **Rushing detection** — During Phase 2, the skill watches for rushing signal phrases and intervenes based on the committed tier. Craft gets firm intervention, Functional gets a nudge, Prototype stays silent.

## Design Principles

- Extend, don't rewrite — two small additions to the existing flow
- One-word commitment, not a questionnaire — minimize friction at project start
- Mirror, not a gate — interventions remind the builder of their own standard, they don't block work
- Calibrated enforcement — the tier determines how aggressively the skill intervenes
- Respect overrides — one flag is enough, then move on

---

## Section 1: Quality Commitment

### When

After capturing client expectations in Phase 1 (new step 4c, after step 4b).

### What to Capture

A single quality tier with an optional reference:

- **Craft** — Design matters. Iterate on how things look and feel, not just whether they work. Ask "is this good?" before moving on. Refinement is not wasted time.
- **Functional** — Solid and clean. Good defaults, consistent patterns, no rough edges. Don't obsess, but don't cut corners.
- **Prototype** — Speed is the point. Get it working. Polish is explicitly deferred.

### Optional Reference

After picking a tier, the builder can optionally add a reference that anchors what "good" means for this project:

- "Craft — think Linear"
- "Functional — clean like Stripe docs"
- "Prototype — just a demo for Thursday"

The reference is not required. The tier alone is sufficient to calibrate enforcement.

### Format

```markdown
## Quality Tier
**Tier:** Craft
**Reference:** Think Linear — clean, intentional, every detail matters
```

Or minimal:

```markdown
## Quality Tier
**Tier:** Functional
```

### Prompt

Ask: "Quality tier for this project — Craft, Functional, or Prototype? Optional: add a reference for what 'good' looks like."

### Default

If the builder declines to choose or skips the question, default to **Functional**. This is the middle ground — quality enforcement is active but not aggressive.

### Tier Change

The builder can change their tier at any time. Update `docs/objectives.md`, log the change in the Changelog, and confirm the new tier aloud. No further ceremony.

### Missing Tier (Existing Projects)

If the skill is invoked on a returning session where `docs/objectives.md` exists but has no `## Quality Tier` section, prompt for the tier before proceeding. If the builder declines, default to Functional.

### Storage

Saved to `docs/objectives.md` under a new `## Quality Tier` section, after Client Expectations and before Changelog.

---

## Section 2: Rushing Detection

### When

Continuously during Phase 2 (Active Drift Detection), alongside the existing drift detection.

### Rushing Signal Phrases

Flag when the builder says:

- "Just make it work"
- "Good enough"
- "We can polish later"
- "The client won't notice"
- "Let's just ship it"
- "I don't want to overthink this"
- "It's fine, let's move on" / "It's fine for now"
- "We're running out of time"

These are the quality equivalent of drift signal phrases like "it would be cool if." Evaluate in context — "it's fine" as genuine acceptance is not a rushing signal; "it's fine, let's move on" while skipping iteration is.

### Tier-Based Response

| Tier | Response |
|------|----------|
| Craft | **Stop.** "You committed to craft. Before moving on: is this something you'd be proud to show?" |
| Functional | **Nudge.** "Quick check — is this clean and consistent, or are you cutting a corner?" |
| Prototype | **Silent.** Speed is the commitment. Don't intervene on quality. |

### Rules

- **One intervention per signal.** Same as drift detection — flag it once, don't lecture.
- **Respect overrides.** If the builder says "I know, move on" — respect it. Don't nag.
- **Mirror, not a gate.** The intervention isn't "slow down." It's "you already know what good looks like. Does this meet your own bar?"
- **Don't log to drift log.** Rushing signals are a quality concern, not a drift event. They don't go in the drift log or dashboard.

---

## Section 3: Integration with Existing Skill

### SKILL.md Changes

**Phase 1 — add step 4c:**
After step 4b (client expectations), add: "Set quality tier: Craft, Functional, or Prototype. Optional reference. Save to `docs/objectives.md` under `## Quality Tier`."

**Phase 2 — add Quality Check subsection:**
After Task Boundary Check, add the rushing signal phrases and tier-based response table.

**Template update — replace existing `docs/objectives.md` template with:**

```markdown
# Project Objectives

## Raw Client Ask
> [Paste exact client words here]

## Distilled Objectives
1. [Objective]
2. [Objective]
3. [Objective]

## Client Expectations
- [What the client expects to experience]
- [Implicit constraints — e.g., "no login needed"]
- [Quality expectations — e.g., "fast, mobile-friendly"]

## Quality Tier
**Tier:** Craft | Functional | Prototype
**Reference:** (optional)

## Changelog
| Date | Change | Source |
|------|--------|--------|
```

**Startup cheat sheet update:**
Add the quality tier after the Filter line and before "Your patterns." Display format:

```
> Tier: {tier} — "{reference}"
```

Or without reference:

```
> Tier: {tier}
```

### No Changes To

- Three-question filter (unchanged — scope, not quality)
- Client Walkthrough (unchanged)
- Drift event logging (unchanged — rushing is not drift)
- Dashboard (unchanged)
- Drift profiles (unchanged)
- Multi-user support (unchanged — each user picks their own tier per project)

### Scope

This is a lightweight addition — one new step, one new subsection, one template update, one cheat sheet line.
