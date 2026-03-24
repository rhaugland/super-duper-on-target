# stay-on-target Client Perspective — Design Spec

## Problem

The stay-on-target skill catches scope drift (building things the client didn't ask for) but doesn't verify the inverse: that what you built actually matches what the client pictured. You can stay perfectly on-target and still deliver something that doesn't feel right to the client — wrong flow, unexpected complexity, missing a quality they assumed was obvious.

## Overview

Two additions to the existing skill:

1. **Client expectations capture** — During Phase 1 objective lock-in, also capture what the client expects to *experience* (not just what to build). Plain-language statements scaled to project complexity.
2. **Pre-delivery client walkthrough** — Before handoff, Claude role-plays as the client and walks through the build against captured expectations. Flags mismatches without unilaterally adding scope.

## Design Principles

- Extend, don't rewrite — two small additions to the existing flow
- Scale to project size — lightweight for simple projects, scenario-based for complex ones
- Flag, don't block — mismatches are surfaced, not auto-fixed (fixing would be drift)
- One walkthrough, not a loop — runs once before delivery

---

## Section 1: Client Expectations Capture

### When

After distilling objectives in Phase 1 (new step 4b, after saving to `docs/objectives.md`).

### What to Capture

Extract 2-5 plain-language statements about what the client expects to *experience*. These describe what it should feel like to use the deliverable — not what to build (that's objectives).

Focus on:
- What the user does (flow/interaction)
- What they don't have to do (implicit constraints like "no login")
- How it should feel (speed, simplicity, device)
- Anything the client explicitly mentioned about the experience

### Format — Simple Projects

For straightforward deliverables (single flow, clear scope):

```markdown
## Client Expectations
- Upload a photo, pick a style, see the staged result — no account needed
- Works on phone (client mentioned "agents in the field")
- Fast — client said "quick turnaround," interpret as under 30 seconds
```

### Format — Complex Projects

For projects with multiple user paths or flows, upgrade critical expectations to scenario format:

```markdown
## Client Expectations
### Core flow: Book an appointment
Agent opens link → sees available slots → picks one → confirms → gets email confirmation

### Core flow: Cancel/reschedule
Agent clicks link in confirmation email → cancel or pick new slot

### General
- No login required
- Mobile-friendly
```

### Scaling Rule

- 1-2 flows → experience-level statements (short form)
- 3+ flows or multiple user types → scenario format for critical paths, short form for the rest

### Insufficient Signal

If the raw ask doesn't contain enough experience-level clues (e.g., "build me a website"), Claude states assumptions explicitly and marks them as inferred:

```markdown
## Client Expectations
- Simple, clean interface *(inferred — client didn't specify)*
- Works in a browser, no install *(inferred — "website" implies this)*
```

The human confirms or corrects these before lock-in. Inferred expectations are lower-confidence — the walkthrough should weight client-stated expectations more heavily.

### Expectation Amendment

When the Objective Amendment Flow fires (new client input), also review and update `## Client Expectations` if the amendment changes the expected experience. Log the change in the objectives changelog.

### Storage

Saved to `docs/objectives.md` under a new `## Client Expectations` section, directly below the distilled objectives.

---

## Section 2: Pre-Delivery Client Walkthrough

### When

Triggered when the human explicitly requests delivery review or says they're ready to deliver. Not triggered automatically. Not triggered mid-build.

**Sequencing:** Walkthrough runs first (it's about the deliverable). The Phase 3 end-of-session retrospective runs after (it's about the session and drift patterns). These are independent — walkthrough checks the build, retrospective checks the process.

### How It Works

Claude role-plays as the client (grounded in the raw ask — who they are, what they asked for, their context) and walks through the build, checking each captured expectation.

### Output Format

```markdown
## Client Walkthrough

**Role:** [Client description, e.g., "Real estate agent who wants virtual staging for listings"]

### Expectation Check
| # | Expectation | Met? | Severity | Notes |
|---|------------|------|----------|-------|
| 1 | Upload photo, pick style, see result | ✅ | — | Clean 3-click flow |
| 2 | No account needed | ✅ | — | — |
| 3 | Works on mobile | ⚠️ | Minor | Layout breaks below 400px |
| 4 | Under 30 seconds | ✅ | — | ~8s in testing |

### Client Reaction
> "This is what I asked for. I can see my agents using this between showings. The mobile thing needs a fix but otherwise ship it."

### Gaps Found
- Mobile responsive issue (flag to human for decision)
```

### Rules

- **One check, not a loop.** Runs once before delivery.
- **Flag, don't block.** Mismatches are surfaced to the human — don't unilaterally add scope to fix them. That would be drift. If any expectation is fully unmet (❌ Critical), explicitly call it out as a potential delivery risk before the human decides to ship.
- **Severity scale:** `—` (met), `Minor` (partially met, cosmetic), `Major` (partially met, functional gap), `Critical` (fully unmet).
- **Stay in character.** The client reaction is Claude's role-play output synthesized from the expectation results, not a real quote. Include only when 3+ expectations were checked; skip for inline format.
- **Scale format to project.** If expectations used short form (1-2 flows), use inline format: "Expectations met: ✅ ✅ ⚠️". If expectations used scenario format (3+ flows), use the full walkthrough table.

---

## Section 3: Integration with Existing Skill

### SKILL.md Changes

**Phase 1 — add step 4b:**
After "Save to `docs/objectives.md`", add: "Distill 2-5 client expectations from the raw ask. Save to `docs/objectives.md` under `## Client Expectations`. Scale format to project complexity."

**New section — Client Walkthrough:**
Add between Phase 2 (Active Drift Detection) and Phase 3 (Drift Pattern Learning) as its own top-level section (not numbered as a "Phase" — it's a checkpoint, not a continuous phase).

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

## Changelog
| Date | Change | Source |
|------|--------|--------|
```

### No Changes To

- Three-question filter (unchanged)
- Drift event logging (unchanged)
- Dashboard (unchanged)
- Drift profiles (unchanged)
- Parked ideas (unchanged)
- Multi-user support (unchanged)
- Startup display (unchanged)

### Scope

This is a lightweight addition — two focused sections that reference each other.
