---
name: stay-on-target
description: Use when starting client work, beginning implementation on a project with defined objectives, or when scope creep is suspected. Also use when you catch yourself thinking "it would be cool if" or "we should also add" during a build.
---

# Stay on Target

Collaborative guardrails that keep both you and your human partner focused on the client's actual objectives. Core principle: **every addition must pass a three-question filter against the client's raw ask.**

## Startup Display

When this skill is invoked, display instructions before starting objective lock-in.

### Detect User Type

Check if `drift-log-{driver}.json` exists in `~/.claude/skills/stay-on-target/`. Driver name is always lowercased.

- **File exists** → returning user → show Cheat Sheet
- **File does not exist** → first-time user → show Walkthrough

### First-Time Walkthrough

Display:

> **Welcome to Stay on Target.**
>
> This skill keeps you and Claude focused on what the client actually asked for.
>
> **How it works:**
> 1. You paste the client's exact ask. We distill 3-5 concrete objectives and capture what the client expects to experience.
> 2. Every new idea gets checked: Did the client ask for it? Does it serve an objective? Can we skip it?
> 3. Off-target ideas get parked for a Phase 2 conversation — not lost, just deferred.
> 4. Over time, the skill learns your personal drift patterns and warns you earlier.
>
> Let's start with objective lock-in.

### Returning User Cheat Sheet

Display:

> ── Stay on Target ─────────────────────
> Filter: (1) Client ask? (2) Serves objective? (3) Skip OK?
> No/No/Yes → Park it. Gray area → Ask yes/no.
>
> Your patterns:
>   ⚠ {pattern 1} ({frequency}) — triggers during {context}
>   ⚠ {pattern 2} ({frequency}) — triggers during {context}
>   ⚠ {pattern 3} ({frequency}) — triggers during {context}
>
> Dashboard: `~/.claude/skills/stay-on-target/dashboard-{driver}.html`
> Ready for objective lock-in.
> ───────────────────────────────────────

Detection uses the drift log file. Pattern details for display are pulled from the driver's drift profile memory file (`feedback_drift_patterns_{name}.md`). Show top 3 by frequency.

## Phase 1: Objective Lock-In

1. **Get raw client ask.** Ask human to paste the client's exact words. No paraphrasing.
2. **Identify session driver.** Who's building? Record name for drift profile tracking.
3. **Distill 3-5 numbered concrete objectives** from the raw ask. Only what the client asked for. Nothing implied, nothing "obvious."
4. **Save to `docs/objectives.md`** using template below.
4b. **Distill client expectations.** Extract 2-5 plain-language statements about what the client expects to *experience* — not what to build (that's objectives), but what it should feel like to use.
    - **Simple projects** (1-2 flows): short-form statements. E.g., "Upload a photo, see result — no account needed."
    - **Complex projects** (3+ flows): scenario format for critical paths. E.g., "Agent opens link → picks slot → confirms → gets email."
    - **Insufficient signal**: if the raw ask lacks experience clues, state assumptions and mark as `*(inferred)*`. Human confirms before lock-in.
    - Save to `docs/objectives.md` under `## Client Expectations`, directly below Distilled Objectives.
5. **Read driver's drift profile** from memory (e.g., `feedback_drift_patterns_{name}.md`). Give preemptive warnings based on known patterns.

## Phase 2: Active Drift Detection

Before implementing anything not explicitly in the objectives, run the **three-question filter**:

- **Q1:** Did the client ask for this?
- **Q2:** Does this serve a distilled objective?
- **Q3:** If we skip this, does the deliverable still meet the client's need?

### Case Matrix

| Q1 | Q2 | Q3 | Action |
|----|----|----|--------|
| Yes | Yes | N/A | Proceed, no commentary |
| No | Yes | No | Proceed, serves objective |
| No | No | Yes | **Off-target.** Park it in `docs/parked-ideas.md` |
| No | Partial | Maybe | **Gray area.** State one sentence why ambiguous, ask human yes/no |
| No | No | No | **Possible gap.** Trigger objective amendment flow |

### Drift Event Logging

After every filter evaluation (park, override, gray area resolution, or preemptive warning), append one line to `~/.claude/skills/stay-on-target/drift-log-{driver}.json`:

```json
{"date":"YYYY-MM-DD","time":"HH:MM","project":"project-name","suggestion":"what was proposed","category":"drift-category","trigger_context":"what was happening","result":"parked|overridden|gray-yes|gray-no|warned","driver":"name"}
```

Driver names are always lowercased. If the file doesn't exist, create it. Categories are free-form strings — use descriptive names like `auth-creep`, `feature-stacking`, `over-engineering`, `delivery-reimagining`.

### Task Boundary Check

On each new task or subtask, silently classify: **on-track** or **drift detected**. If drift detected, run the filter aloud before proceeding.

### Preemptive Anticipation

If driver has known drift patterns (from memory), flag likely drift triggers before they occur. One short warning, not a lecture.

## Client Walkthrough

Pre-delivery checkpoint. Triggered when the human explicitly requests delivery review or says they're ready to deliver. Not triggered automatically.

**Sequencing:** Walkthrough runs first (checks the build). Phase 3 retrospective runs after (checks the process).

### How It Works

Claude role-plays as the client (grounded in the raw ask — who they are, what they asked for, their context) and checks each captured expectation from `docs/objectives.md`.

### Output Format — Full (3+ expectations, scenario format)

```markdown
## Client Walkthrough

**Role:** [Client description from raw ask]

### Expectation Check
| # | Expectation | Met? | Severity | Notes |
|---|------------|------|----------|-------|
| 1 | [expectation] | ✅/⚠️/❌ | —/Minor/Major/Critical | [details] |

### Client Reaction
> [Synthesized reaction in character as the client]

### Gaps Found
- [Gap] (flag to human for decision)
```

### Output Format — Inline (1-2 expectations, short form)

> Expectations met: ✅ ✅ ⚠️ (mobile layout needs responsive pass — flagging for your call)

### Rules

- **One check, not a loop.** Runs once before delivery.
- **Flag, don't block.** Mismatches are surfaced — don't add scope to fix them. That would be drift. If any expectation is ❌ Critical, call it out as a delivery risk.
- **Severity:** `—` (met), `Minor` (cosmetic), `Major` (functional gap), `Critical` (fully unmet).
- **Stay in character.** Client reaction is role-play, not a real quote. Include only for full format.
- **Scale format to project.** Short-form expectations → inline output. Scenario expectations → full table.
- **Weigh stated over inferred.** Expectations marked *(inferred)* are lower-confidence — a miss on a stated expectation is more significant than a miss on an inferred one.

## Phase 3: Drift Pattern Learning

### What to Track

- **Category** of drift (UI polish, architecture astronaut, feature creep, etc.)
- **Trigger context** (what was being built when drift occurred)
- **Frequency** (how often this category appears)
- **Overrides** (did human override the filter? how often?)
- **Growth** (is this pattern increasing or decreasing?)

### Storage

Per-user memory files: `feedback_drift_patterns_{username}.md`. Shared objectives and parked ideas use attribution.

### End-of-Session Retrospective

Prompt at session end:

> **Drift retrospective:** {N} items filtered. {M} parked, {K} overridden. New patterns observed: {list}. Want me to update your drift profile?

### Objective Amendment Flow

When new client input arrives: capture verbatim, update `docs/objectives.md` changelog, re-distill objectives, review and update `## Client Expectations` if the amendment changes the expected experience, reset filter against new list.

## User Override

Human says "do it anyway" — respect it. Log override in drift profile. Don't nag. One flag is enough. Move on.

## Red Flags

Drift signal phrases — run the filter immediately when you hear:

- "It would be cool if..."
- "We should also add..."
- "While we're at it..."
- "Best practice says we need..."
- "What if instead of what they asked for, we..."
- "This would be way more impressive if..."
- "They'll love it if we also..."
- "It's only a small addition..."

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "It's best practice" | Best practice for whom? Not in the client's ask. |
| "It would only take 30 minutes" | 30 minutes stolen from objectives. |
| "They'll be impressed" | They'll be impressed when you deliver on time. |
| "It's a better experience" | Better by whose definition? |
| "We need this for security" | Flag it to client, don't unilaterally add scope. |
| "While we're here anyway" | You're here to build objectives. |

## File Templates

### `docs/objectives.md`

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

### `docs/parked-ideas.md`

```markdown
# Parked Ideas

## From {date}
- [ ] **[Idea]**
  - Proposed by: {name}
  - Why it came up: {context}
  - Client value: {assessment}
  - Mapped objective: None
```

## Multi-User Support

Each user gets their own drift profile (`feedback_drift_patterns_{name}.md`). Profiles are fully independent — one user's known patterns must never fire warnings for a different user. The objective ledger (`docs/objectives.md`) and parked ideas (`docs/parked-ideas.md`) are shared across users with attribution on all entries.

## Dashboard

Per-user static HTML dashboard at `~/.claude/skills/stay-on-target/dashboard-{driver}.html`.

### When to Generate

Generate the dashboard **on demand only** — when the user says "show my dashboard", "update my dashboard", or similar. Do NOT regenerate on every skill invocation.

### How to Generate

1. Read `~/.claude/skills/stay-on-target/drift-log-{driver}.json` (JSONL — one JSON object per line)
2. Skip any malformed lines
3. Embed all valid events as a JS array in a self-contained HTML file
4. Compute stats: total events, unique projects, category counts, parked vs overridden ratio
5. Write to `~/.claude/skills/stay-on-target/dashboard-{driver}.html`
6. Tell the user: "Dashboard updated. Open: `~/.claude/skills/stay-on-target/dashboard-{driver}.html`"

### Empty State

If the log file is missing or empty, generate a valid dashboard with the message: "No drift events yet. Start a session with /stay-on-target to begin tracking."
