# stay-on-target — Skill Design Spec

## Problem

When building client projects, scope drift happens at every stage — during planning and during implementation. Ideas that feel like improvements ("aha, this would be cool") lead to wasted work on features the client never asked for. Common patterns include adding auth/onboarding when not requested, reimagining delivery mechanisms, and stacking features mid-build.

This skill provides collaborative guardrails that keep both the user and Claude focused on the client's actual objectives.

## Overview

`stay-on-target` is a standalone skill that:

1. Locks in client objectives at the start of a project
2. Actively detects and intervenes on scope drift during implementation
3. Learns personal drift patterns over time to get proactively sharper
4. Supports multiple users with independent drift profiles

## Design Principles

- **Collaborative, not authoritarian** — constraints apply to both user and Claude equally
- **Structured evaluation, not hard blocks** — a quick three-question filter, not a gate that prevents work
- **Self-learning** — drift patterns are tracked and used to anticipate future drift
- **Ideas aren't killed, they're parked** — off-scope ideas go to a parking lot for potential Phase 2 conversations

---

## Section 1: Objective Lock-In Phase

Invoked at the start of a project.

### Steps

1. **Capture the raw ask** — Prompt the user to paste the client's actual words (email, Slack message, brief, verbal summary). Saved verbatim as the source of truth.

2. **Identify the session driver** — Ask who is driving this build session (e.g., "Who's driving this build — Ryan or [partner]?"). Load the corresponding drift profile.

3. **Distill objectives** — Collaboratively boil the raw ask down to 3-5 numbered objectives. Each must be a concrete, verifiable deliverable.

   Example:
   ```
   Raw ask: "I need a virtual staging app where agents can upload photos
   and get consistent staged versions back"

   Objectives:
   1. Photo upload functionality
   2. AI-powered virtual staging of uploaded photos
   3. Visual consistency across staged photos
   4. Simple UI for real estate agents (non-technical users)
   ```

4. **Save the objective ledger** — Write to `docs/objectives.md` in the project repo containing both the raw ask and the distilled objectives list.

5. **Initialize drift pattern check** — Read the current user's drift pattern memory file. Flag any known tendencies relevant to this project type. Example:
   > "Heads up: on past projects you've tended to add auth/onboarding when it wasn't requested. This client didn't ask for login — flagging it now so we're both aware."

---

## Section 2: Active Drift Detection During Implementation

Once objectives are locked in, the skill runs continuously with two trigger points.

### Trigger 1: New Work Proposal

Whenever either party suggests adding something — "let's also build X," "it would be cool if," "we should add" — the three-question filter fires:

1. **Did the client ask for this?** → Check against the raw ask
2. **Does this serve one of the distilled objectives?** → Check the numbered list
3. **If we skip this entirely, does the deliverable still meet the client's need?** → If yes, it's scope creep

**If No / No / Yes** → Call it out explicitly:
> "Off-target. This doesn't map to any of the client's objectives. Parking it in `parked-ideas.md`. Back to [current objective]."

**If gray area** (e.g., No / Partially / Maybe) → Claude states why the item is ambiguous (one sentence), then asks for a yes/no decision. User responds. No extended debate — deliberate decision, move on.

### Trigger 2: Task Boundary Check

After completing each implementation step, before starting the next:

- **On track:**
  > "Just finished [X]. Next up is [Y]. Still on target — this maps to objective #2."

- **Drift detected:**
  > "Hold on — the next thing on our list is [Y], but I'm not seeing how it connects to the objectives. Should we re-evaluate?"

### Preemptive Drift Anticipation

Based on the user's known drift patterns, proactively flag before drift happens:
> "We're about to build the frontend. Reminder: no login/onboarding is in scope. Just the upload and staging flow."

This fires when the current work context matches a known drift trigger (e.g., "starting frontend work" is a known trigger for auth creep).

---

## Section 3: Self-Learning Drift Pattern System

The skill maintains a personal drift profile per user that evolves over time.

### What Gets Tracked

- **Drift category** — The type of addition attempted (auth, scraping, extra UI, delivery mechanism change, feature stacking, etc.)
- **Trigger context** — What was happening when drift occurred (building frontend, discussing architecture, mid-implementation momentum)
- **Frequency** — How often this pattern repeats across projects
- **Growth** — If a pattern stops appearing, note that too

### Storage

Per-user memory files in user-level Claude memory (cross-project, not repo-scoped):

- `~/.claude/projects/<user>/memory/feedback_drift_patterns_ryan.md`
- `~/.claude/projects/<user>/memory/feedback_drift_patterns_[partner].md`

Example content:
```markdown
---
name: drift_patterns_ryan
description: Ryan's recurring scope drift tendencies across client projects
type: feedback
---

Known drift patterns (last updated 2026-03-24):

1. **Auth/onboarding creep** — Tends to add login flows, user accounts,
   and onboarding sequences when client asked for a simple tool.
   Frequency: high. Trigger: starting frontend work.

2. **Delivery mechanism reimagining** — Tends to replace the client's
   requested approach with a "better" one (e.g., scraper instead of upload).
   Frequency: medium. Trigger: early architecture decisions.

3. **Feature stacking** — Adds "cool" features mid-build that weren't requested.
   Frequency: high. Trigger: mid-implementation momentum.
```

### How Patterns Are Used

- **At objective lock-in** — Scan patterns and give preemptive warnings relevant to the project type
- **During implementation** — Pattern-matched drift gets flagged faster and more specifically than generic drift
- **Over time** — Profile reflects growth, not just habits

### When Patterns Update

- When a drift moment is caught and parked (new pattern or frequency bump)
- At the end of a project or significant milestone (retrospective update)
- New users start with a blank profile that learns organically

---

## Section 4: Parked Ideas System

Off-scope ideas are captured, not discarded.

### Per-Project File

`docs/parked-ideas.md` in the project repo:

```markdown
# Parked Ideas

Ideas that came up during implementation but are outside current scope.
Potential Phase 2 conversation starters with the client.

## From 2026-03-24
- [ ] Login/auth system for agent accounts
  - Proposed by: Ryan
  - Why it came up: Suggested during frontend build
  - Client value: Could be useful if they want multi-agent access
  - Mapped objective: None currently

- [ ] Automated photo scraping from MLS listings
  - Proposed by: Ryan
  - Why it came up: Thought it would save agents time
  - Client value: High, but not what they asked for
  - Mapped objective: None currently
```

### What Makes This Useful

- **Client value note** on each idea — ready for Phase 2 pitch conversations
- **Checkboxes** — track which ideas have been discussed with the client
- **Attribution** — who proposed it (relevant for multi-user)
- **Lives in the repo** — travels with the project, not scattered in notes or memory

---

## Section 5: Multi-User Support

The skill supports multiple users with independent drift profiles.

### Session Identification

At objective lock-in, the skill asks who is driving the build session. This determines which drift profile to load.

### Per-User Drift Profiles

Each user gets their own memory file:
- `feedback_drift_patterns_ryan.md`
- `feedback_drift_patterns_[partner].md`

Profiles are fully independent. Ryan's known patterns don't fire for his partner and vice versa. New users start with a blank profile.

### Shared Project Artifacts

These remain shared across all users on a project:
- `docs/objectives.md` — one source of truth
- `docs/parked-ideas.md` — shared, with attribution per entry
- The three-question filter — identical evaluation for everyone

---

## Section 6: Objective Amendments

Clients change their minds. When new input arrives mid-build that changes scope:

1. **Capture the new input verbatim** — same as initial lock-in, paste the client's actual words
2. **Update `docs/objectives.md`** — add the new objective(s) under a dated changelog section, preserving the original objectives for reference
3. **Re-run the distillation** — update the numbered objectives list to reflect the new scope
4. **Reset the filter baseline** — the three-question filter now evaluates against the updated objectives

This prevents the skill from flagging legitimate client requests as drift.

---

## Section 7: User Override Handling

When the filter flags something as off-target and the user says "I know, build it anyway":

- **Respect the override** — proceed with the work without further resistance
- **Log it to the drift profile** — record the override with a note: what was overridden, why the user chose to proceed, and the context
- **Do not nag** — one flag is enough. The skill is a co-pilot, not a gatekeeper

Overrides are valuable learning data. If a user consistently overrides a certain type of flag, the pattern may need recalibration — or it may reveal a new type of drift that the user hasn't recognized yet. Either way, the data is captured.

---

## Section 8: End-of-Session Retrospective

At the end of a project or significant milestone, the skill prompts a brief drift retrospective:

> "Before we wrap up — quick drift check. During this build:
> - [N] items were caught and parked
> - [N] items were overridden
> - [List any new drift patterns observed]
>
> Want me to update your drift profile?"

If the user approves, the drift profile memory file is updated with new patterns, frequency adjustments, or growth notes (patterns that didn't appear this time).

This is prompted — not automatic — so the user can skip it if the session was straightforward.

---

## Skill Implementation

### Skill File

The skill is a markdown file with frontmatter, located in the user's skills directory (e.g., managed via superpowers or a custom skills path). It is purely prompt-driven — no MCP tools or background processes.

### How "Continuous Detection" Works

Once invoked, the skill injects its instructions (the objective ledger, the three-question filter, the user's drift profile, and the detection triggers) into the conversation context. Claude evaluates every subsequent message against these instructions as part of its normal response generation. There is no background process — the skill works by shaping how Claude processes each message within the active session.

### Frontmatter

```yaml
name: stay-on-target
description: Lock in client objectives, detect scope drift during implementation, and learn personal drift patterns over time. Use when starting client work, beginning implementation, or when scope creep is suspected.
```

### Trigger Conditions

- User explicitly invokes the skill
- Starting client work or implementation on a project with defined objectives
- Composable with brainstorming, writing-plans, executing-plans, or any implementation skill
- Can be invoked mid-project if objectives weren't set at the start

---

## Drift Profile Storage

Drift profiles are **cross-project** — they track patterns across all client work, not just one repo. They are stored in user-level Claude memory (e.g., `~/.claude/projects/-Users-ryanhaugland/memory/`) so they persist across projects.

| File | Location | Purpose |
|------|----------|---------|
| Objective ledger | `docs/objectives.md` (per project repo) | Raw ask + distilled objectives |
| Parked ideas | `docs/parked-ideas.md` (per project repo) | Off-scope ideas with client value notes |
| Drift profile | `~/.claude/projects/<user>/memory/feedback_drift_patterns_<name>.md` (per user, cross-project) | Personal drift patterns and tendencies |

---

## Three-Question Filter — All Cases

| Q1: Client ask? | Q2: Serves objective? | Q3: Skip = still meets need? | Action |
|---|---|---|---|
| Yes | Yes | N/A | **Proceed** — no commentary needed |
| No | Yes | No | **Proceed** — it serves the objective even if client didn't say it explicitly |
| No | No | Yes | **Off-target** — park it, redirect to current objective |
| No | Partially | Maybe | **Gray area** — Claude states why it's ambiguous (one sentence), asks for a yes/no decision, user responds. No extended debate. |
| No | No | No | **Possible gap in objectives** — the deliverable may be incomplete. Trigger the amendment flow (Section 6) if the gap is confirmed. |
