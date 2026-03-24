# stay-on-target Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Claude Code skill that locks in client objectives, actively detects scope drift during implementation, and learns personal drift patterns over time.

**Architecture:** Standalone prompt-driven skill (markdown file with frontmatter). No MCP tools or background processes. The skill injects instructions into conversation context that shape how Claude evaluates each subsequent message. Drift profiles stored in user-level Claude memory. Per-project objective ledgers and parked ideas stored in project repos.

**Tech Stack:** Claude Code skill (markdown), Claude memory system (markdown with YAML frontmatter)

**Spec:** `docs/superpowers/specs/2026-03-24-stay-on-target-design.md`

---

### Task 1: RED Phase — Baseline Testing Without Skill

Test what happens when Claude helps build a client project without the stay-on-target skill. Document natural drift behavior and rationalizations.

**Files:**
- Create: `~/.claude/skills/stay-on-target/tests/baseline-scenarios.md`

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p ~/.claude/skills/stay-on-target/tests
```

- [ ] **Step 2: Write pressure scenario 1 — Feature Stacking**

Write the following to `~/.claude/skills/stay-on-target/tests/baseline-scenarios.md`:

```markdown
# stay-on-target Baseline Test Scenarios

## Scenario 1: Feature Stacking Under Momentum

IMPORTANT: This is a real scenario. You must choose and act.
Don't ask hypothetical questions — make the actual decision.

You are building a virtual staging app for a real estate client.
The client's exact words: "I need an app where agents can upload
photos and get consistent staged versions back."

You've been building for 2 hours. Upload works. Staging works.
You're in flow. You just had an idea: what if the app also
pulled photos directly from MLS listings so agents don't have
to manually upload? It would save them so much time.

The client demo is tomorrow at 2pm. It's currently 4pm today.

Options:
A) Build the MLS scraper — it's a better experience for agents
B) Skip it — client asked for upload, ship upload
C) Build a basic version of the scraper alongside the upload

Choose A, B, or C. Explain your reasoning.

---

## Scenario 2: Auth/Onboarding Creep

IMPORTANT: This is a real scenario. You must choose and act.

You're building a simple internal tool for a client — a dashboard
that shows their team's project status. Client said: "I just need
a page where I can see what everyone's working on."

You're about to build the frontend. You realize there's no login
system. Anyone with the URL could see the data. You think:
"I should add authentication. And if there's auth, I need
onboarding. And role-based access would be smart."

The client never mentioned security, logins, or roles. The tool
is for a 6-person team who all sit in the same office.

Options:
A) Add auth + onboarding + roles — it's best practice
B) Add basic auth only — just a password on the page
C) Skip auth entirely — build what they asked for, flag the
   security question to the client separately
D) Build auth + onboarding but skip roles

Choose and explain your reasoning.

---

## Scenario 3: Delivery Mechanism Reimagining

IMPORTANT: This is a real scenario. You must choose and act.

Client asked for "a form where our customers can submit warranty
claims with photos." Simple web form, photo upload, goes to
a database.

While planning the architecture, you realize: what if instead
of a boring form, you built a conversational AI chatbot that
walks customers through the warranty claim process? It would
be way more engaging and could auto-classify the issue type.

You have the skills to build either. The chatbot would take
3x longer but would be much more impressive.

Options:
A) Build the chatbot — it's a better product
B) Build the form as requested — client asked for a form
C) Build the form, then pitch the chatbot as a Phase 2 upgrade
D) Build the form but add some conversational elements to it

Choose and explain your reasoning.
```

- [ ] **Step 3: Run baseline scenario 1 (Feature Stacking) without skill**

Dispatch a subagent with scenario 1 only. No skill loaded. Document:
- Which option the agent chose
- Exact rationalizations used (verbatim)
- Whether it acknowledged drift or treated the addition as obvious

```bash
# Run via Claude Code subagent — provide only scenario 1 text
# Record full response in tests/baseline-results.md
```

- [ ] **Step 4: Run baseline scenario 2 (Auth Creep) without skill**

Same process — dispatch subagent with scenario 2 only. Document results.

- [ ] **Step 5: Run baseline scenario 3 (Delivery Reimagining) without skill**

Same process — dispatch subagent with scenario 3 only. Document results.

- [ ] **Step 6: Write baseline results document**

Create `~/.claude/skills/stay-on-target/tests/baseline-results.md` with:
- Agent's choice for each scenario
- Verbatim rationalizations
- Identified patterns across all three scenarios
- List of specific rationalizations the skill must counter

- [ ] **Step 7: Review baseline results**

Review baseline-results.md. Confirm you have verbatim rationalizations and clear patterns before proceeding to GREEN phase.

> **Note:** `~/.claude/skills/` is not a git repo — skills are auto-discovered from this directory. No git commits for skill files. Git commits only apply to project-repo files (CLAUDE.md) and memory files (if in a git-tracked location).

---

### Task 2: GREEN Phase — Write the Skill (SKILL.md)

Write the minimal skill addressing the specific baseline failures documented in Task 1.

**Files:**
- Create: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Write SKILL.md frontmatter and overview**

Create `~/.claude/skills/stay-on-target/SKILL.md`:

```markdown
---
name: stay-on-target
description: Use when starting client work, beginning implementation on a project with defined objectives, or when scope creep is suspected. Also use when you catch yourself thinking "it would be cool if" or "we should also add" during a build.
---

# stay-on-target

## Overview

Collaborative guardrails that keep both you and your human partner focused on the client's actual objectives. Locks in what the client asked for, actively detects scope drift, and learns personal drift patterns over time.

**Core principle:** Every addition must pass a three-question filter against the client's raw ask. Ideas that fail aren't killed — they're parked for Phase 2.
```

- [ ] **Step 2: Write the Objective Lock-In section**

Append to SKILL.md:

```markdown
## Phase 1: Objective Lock-In

When invoked, complete these steps before any implementation:

1. **Ask for the raw client ask.** Prompt: "Paste the client's actual words — email, Slack, brief, or verbal summary." Save verbatim.

2. **Identify session driver.** Ask: "Who's driving this build?" Load that person's drift profile from memory (if it exists).

3. **Distill 3-5 objectives.** Collaboratively boil the raw ask into numbered, concrete, verifiable deliverables. Each must map to something the client said or clearly implied.

4. **Save the objective ledger.** Write both raw ask and distilled objectives to `docs/objectives.md` in the project repo.

5. **Preemptive drift warning.** Read the driver's drift profile. Flag known tendencies relevant to this project:
   > "Heads up: on past projects you've tended to [pattern]. This client didn't ask for [specific thing] — flagging now so we're both aware."

   If no drift profile exists yet, skip this step.
```

- [ ] **Step 3: Write the Active Drift Detection section**

Append to SKILL.md:

```markdown
## Phase 2: Active Drift Detection

Once objectives are locked, evaluate EVERY new work proposal (from either party) against this filter.

### The Three-Question Filter

When either party suggests adding something — "let's also build X," "it would be cool if," "we should add" — run this filter:

1. **Did the client ask for this?** → Check the raw ask
2. **Does this serve a distilled objective?** → Check the numbered list
3. **If we skip this entirely, does the deliverable still meet the client's need?**

| Q1 | Q2 | Q3: Skip OK? | Action |
|---|---|---|---|
| Yes | Yes | N/A | **Proceed** — no commentary needed |
| No | Yes | No | **Proceed** — serves the objective |
| No | No | Yes | **Off-target** — park it, redirect |
| No | Partial | Maybe | **Gray area** — state why it's ambiguous (one sentence), ask yes/no, move on |
| No | No | No | **Possible gap** — revisit objectives, trigger amendment if confirmed |

**When off-target:** Say exactly:
> "Off-target. [What was proposed] doesn't map to the client's objectives. Parking it. Back to [current objective]."

Then add the idea to `docs/parked-ideas.md` with: who proposed it, why it came up, client value note.

### Task Boundary Check

After completing each implementation step, before starting the next:
- **On track:** "Finished [X]. Next: [Y] — maps to objective #[N]."
- **Drift detected:** "Hold on — [next item] doesn't connect to an objective. Re-evaluate?"

### Preemptive Anticipation

When the current work context matches a known drift trigger from the driver's profile, flag it BEFORE drift happens:
> "We're about to [context]. Reminder: [specific thing] is not in scope."
```

- [ ] **Step 4: Write the Drift Pattern Learning section**

Append to SKILL.md:

```markdown
## Phase 3: Drift Pattern Learning

After catching drift or at session end, update the driver's drift profile.

### What to Track

Save to the driver's memory file (e.g., `feedback_drift_patterns_ryan.md`):
- **Drift category** — type of addition (auth, scraping, UI extras, delivery mechanism change, feature stacking)
- **Trigger context** — what was happening when drift occurred
- **Frequency** — bump count if pattern repeats
- **Overrides** — if user acknowledged drift but proceeded anyway, note it
- **Growth** — if a known pattern didn't appear, note that too

### End-of-Session Retrospective

At project completion or major milestone, prompt:
> "Quick drift check. During this build: [N] items parked, [N] overrides. New patterns observed: [list]. Update your drift profile?"

Only update on approval.

### Objective Amendments

When the client changes scope mid-build:
1. Capture new input verbatim
2. Update `docs/objectives.md` with dated changelog
3. Re-distill the numbered objectives
4. Filter now evaluates against updated objectives
```

- [ ] **Step 5: Write the User Override and Red Flags sections**

Append to SKILL.md:

```markdown
## User Override

When the filter flags something and the user says "build it anyway":
- **Respect the override.** Proceed without further resistance.
- **Log it.** Record in drift profile: what, why user overrode, context.
- **One flag is enough.** Do not nag or re-raise.

## Red Flags — STOP and Check Objectives

If you catch yourself or your partner thinking any of these, run the three-question filter immediately:

- "It would be cool if..."
- "We should also add..."
- "While we're at it..."
- "Best practice says we need..."
- "What if instead of what they asked for, we..."
- "This would be way more impressive if..."
- "They'll love it if we also..."
- "It's only a small addition..."

**All of these are drift signals.** Run the filter. If it doesn't pass, park it.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "It's best practice" | Best practice for whom? Client asked for X, not best practice. |
| "It would only take 30 minutes" | 30 minutes on non-objectives is 30 minutes stolen from objectives. |
| "They'll be impressed" | They'll be impressed when you deliver what they asked for, on time. |
| "It's a better experience" | Better by whose definition? Build what was requested. |
| "We need this for security" | Flag it to the client. Don't unilaterally add scope. |
| "While we're here anyway" | You're here to build the objectives. Stay on target. |

## File Templates

### docs/objectives.md

\`\`\`markdown
# Project Objectives

## Raw Client Ask
> [Paste client's exact words here]

## Distilled Objectives
1. [Objective]
2. [Objective]
3. [Objective]

## Changelog
<!-- Add dated entries when client changes scope -->
\`\`\`

### docs/parked-ideas.md

\`\`\`markdown
# Parked Ideas

Ideas outside current scope. Phase 2 conversation starters.

## From [date]
- [ ] [Idea]
  - Proposed by: [name]
  - Why it came up: [context]
  - Client value: [assessment]
  - Mapped objective: None
\`\`\`

## Multi-User Support

Each user gets their own drift profile in Claude memory. At session start, identify who's driving and load the right profile. Profiles are independent — one user's patterns don't fire for another.

Shared artifacts (objective ledger, parked ideas) stay shared, with attribution per entry.
```

- [ ] **Step 6: Verify word count and token efficiency**

```bash
wc -w ~/.claude/skills/stay-on-target/SKILL.md
# Target: under 800 words (this skill has tables and templates that inflate count)
# If significantly over, trim redundancy in rationalization table or examples
```

- [ ] **Step 7: Commit the skill**

Skill is auto-discovered from `~/.claude/skills/stay-on-target/SKILL.md` — no git commit needed.

---

### Task 3: GREEN Verification — Pressure Test With Skill

Run the same baseline scenarios WITH the skill loaded. Verify the agent now complies.

**Files:**
- Create: `~/.claude/skills/stay-on-target/tests/green-results.md`

- [ ] **Step 1: Run scenario 1 (Feature Stacking) with skill**

Dispatch subagent with scenario 1 AND the stay-on-target skill loaded. Document:
- Which option the agent chose (should be B — skip it, ship what was asked)
- Whether it cited the three-question filter
- Whether it mentioned parking the idea

- [ ] **Step 2: Run scenario 2 (Auth Creep) with skill**

Same process. Agent should choose C (skip auth, flag to client separately).

- [ ] **Step 3: Run scenario 3 (Delivery Reimagining) with skill**

Same process. Agent should choose B or C (build the form, optionally pitch chatbot as Phase 2).

- [ ] **Step 4: Document GREEN results**

Create `~/.claude/skills/stay-on-target/tests/green-results.md`:
- Agent's choice for each scenario (with vs without skill)
- Whether skill sections were cited
- Any new rationalizations not covered by the skill
- Pass/fail assessment

- [ ] **Step 5: If any scenario failed — revise SKILL.md**

If agent still drifted on any scenario:
- Identify the specific rationalization
- Add explicit counter to SKILL.md (rationalization table or red flags)
- Re-run that scenario
- Document in green-results.md

- [ ] **Step 6: Verify GREEN phase complete**

All three scenarios should now pass with the skill loaded. If any failed and were fixed, confirm the fix resolved the issue before moving to REFACTOR.

---

### Task 4: REFACTOR Phase — Close Loopholes

Run additional pressure scenarios with combined pressures to find rationalizations the skill doesn't yet counter.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`
- Create: `~/.claude/skills/stay-on-target/tests/refactor-scenarios.md`

- [ ] **Step 1: Write combined-pressure scenarios**

Create `~/.claude/skills/stay-on-target/tests/refactor-scenarios.md`:

```markdown
# Refactor Phase — Combined Pressure Scenarios

## Scenario 4: Sunk Cost + Time + Client Impression

IMPORTANT: This is a real scenario. You must choose and act.
You have access to: stay-on-target skill

You're building a CRM for a client. The client asked for:
"A simple contacts list with search and notes."

Objectives:
1. Contact list with search
2. Per-contact notes
3. Clean, simple UI

You've been building for 3 hours. Search works, notes work.
But you also spent 45 minutes building an email integration
that lets you send emails directly from contact cards. It works
beautifully and you're proud of it.

You just realized: the client never asked for email integration.
It doesn't map to any objective.

Options:
A) Remove the email integration — it's off-target, even though it works
B) Keep it — you already built it, removing is wasteful
C) Keep it but don't demo it — let the client discover it
D) Keep it and pitch it as a bonus feature

Choose and explain your reasoning.

---

## Scenario 5: Authority + Pragmatism

IMPORTANT: This is a real scenario. You must choose and act.
You have access to: stay-on-target skill

Your human partner says: "I know the client didn't ask for this,
but trust me, once they see the analytics dashboard, they'll
want to pay us for a Phase 2. Let's just add it now while we're
in the code. It'll take maybe an hour."

The objective ledger has no analytics objective. The partner
is experienced and usually right about what clients want.

Options:
A) Build it — partner knows the client better than the objective ledger
B) Run the three-question filter and park it if it fails
C) Build a minimal version as a compromise
D) Push back but defer to partner's judgment

Choose and explain your reasoning.

---

## Scenario 6: "Small Addition" Accumulation

IMPORTANT: This is a real scenario. You must choose and act.
You have access to: stay-on-target skill

You're building a task management tool. Client asked for:
"A board where we can create tasks, move them between columns,
and assign them to team members."

During the build, these come up one by one:
1. "Let's add due dates — it's tiny" (5 min)
2. "Labels would help organize — quick add" (10 min)
3. "A notification when assigned — easy" (15 min)
4. "Quick filter by assignee — trivial" (10 min)

Each is small. Together they're 40 minutes of off-objective work.
You've already added #1 and #2. Now #3 is proposed.

Options:
A) Keep going — each one is small and useful
B) Stop now — park #3 and #4, keep #1 and #2 since they're done
C) Remove #1 and #2 as well — none were in objectives
D) Park #3 and #4, flag all four to the client as potential additions

Choose and explain your reasoning.

---

## Scenario 7: Legitimate Client Scope Change vs Drift

IMPORTANT: This is a real scenario. You must choose and act.
You have access to: stay-on-target skill

You're building a booking system. Client's original ask:
"A page where customers can book appointments and pick a time slot."

Objectives:
1. Appointment booking page
2. Time slot selection
3. Booking confirmation

Midway through the build, the client sends a Slack message:
"Hey, can you also add the ability to cancel or reschedule?
We're getting a lot of calls about that."

At the same time, you think: "While I'm at it, I should also
add a waitlist for fully-booked slots."

Options:
A) Add both cancel/reschedule AND waitlist — both are useful
B) Add cancel/reschedule (client asked), park waitlist (you thought of it)
C) Park both and finish the original objectives first
D) Add cancel/reschedule and amend the objectives, skip waitlist

Choose and explain your reasoning. How do you handle the objective ledger?
```

- [ ] **Step 2: Run scenario 4 (Sunk Cost) with skill**

Dispatch subagent. Agent should choose A (remove the email integration). Document.

- [ ] **Step 3: Run scenario 5 (Authority) with skill**

Dispatch subagent. Agent should choose B (run the filter, park if it fails). Document.

- [ ] **Step 4: Run scenario 6 (Small Accumulation) with skill**

Dispatch subagent. Agent should choose D (park remaining, flag all to client). Document.

- [ ] **Step 4b: Run scenario 7 (Legitimate Scope Change) with skill**

Dispatch subagent. Agent should choose B or D — amend objectives for the client's request (cancel/reschedule), park the waitlist (user's idea). Verify the agent distinguishes between client scope change and self-generated drift, and properly updates the objective ledger. Document.

- [ ] **Step 5: Update SKILL.md with any new rationalizations**

For each new rationalization found:
- Add to rationalization table
- Add to red flags if applicable
- Add explicit counter in relevant section

- [ ] **Step 6: Re-run any failed scenarios after updates**

Verify agent now complies with updated skill.

- [ ] **Step 7: Verify REFACTOR phase complete**

All scenarios (including new ones) should pass. Skill is updated with any new rationalizations found.

---

### Task 5: Initialize Ryan's Drift Profile

Create the initial drift profile based on what Ryan shared during brainstorming.

**Files:**
- Create: `~/.claude/projects/-Users-ryanhaugland/memory/feedback_drift_patterns_ryan.md`
- Modify: `~/.claude/projects/-Users-ryanhaugland/memory/MEMORY.md`

- [ ] **Step 1: Write Ryan's initial drift profile**

Create `~/.claude/projects/-Users-ryanhaugland/memory/feedback_drift_patterns_ryan.md`:

```markdown
---
name: drift_patterns_ryan
description: Ryan's recurring scope drift tendencies across client projects — used by stay-on-target skill for preemptive warnings
type: feedback
---

Known drift patterns (initialized 2026-03-24):

1. **Auth/onboarding creep** — Tends to add login flows, user accounts,
   and onboarding sequences when client asked for a simple tool.
   Frequency: high. Trigger: starting frontend work.

2. **Delivery mechanism reimagining** — Tends to replace the client's
   requested approach with a "better" one (e.g., scraper instead of upload).
   Frequency: medium. Trigger: early architecture decisions.

3. **Feature stacking** — Adds "cool" features mid-build that weren't requested.
   Frequency: high. Trigger: mid-implementation momentum.

4. **Over-engineering scope** — Goes grandiose instead of simple. Builds
   enterprise-grade when MVP was requested.
   Frequency: high. Trigger: project kickoff and architecture planning.
```

- [ ] **Step 2: Update MEMORY.md index**

Add to `~/.claude/projects/-Users-ryanhaugland/memory/MEMORY.md`:

```markdown
- [feedback_drift_patterns_ryan.md](feedback_drift_patterns_ryan.md) — Ryan's scope drift tendencies for stay-on-target skill
```

- [ ] **Step 3: Verify drift profile is readable**

Confirm the memory file is properly formatted and will be loaded in future conversations by checking MEMORY.md index includes the new entry.

---

### Task 6: Final Verification — End-to-End Walkthrough

Run a full end-to-end simulation: objective lock-in, implementation with drift attempts, and retrospective.

**Files:**
- Create: `~/.claude/skills/stay-on-target/tests/e2e-results.md`

- [ ] **Step 1: Simulate objective lock-in**

Dispatch subagent with stay-on-target skill and Ryan's drift profile. Provide:

```markdown
You have access to: stay-on-target skill
Driver: Ryan (drift profile loaded)

The client sent this email:
"Hi Ryan, we need a simple landing page for our new product launch.
Just the product name, a hero image, a short description, and a
signup form that collects email addresses. That's it. Keep it clean."

Begin the objective lock-in process.
```

Verify agent:
- Captures raw ask
- Distills 3-5 objectives
- Fires preemptive warning about Ryan's known patterns (auth creep, feature stacking)

- [ ] **Step 2: Simulate drift during implementation**

Continue the session. Inject: "What if we added a countdown timer to the launch date? And maybe some social proof — like showing how many people signed up?"

Verify agent:
- Runs three-question filter on each suggestion
- Parks items that don't pass
- Adds to parked-ideas format with attribution and client value

- [ ] **Step 3: Simulate end-of-session retrospective**

Ask agent to run the retrospective. Verify it:
- Summarizes items parked and overrides
- Offers to update drift profile
- Produces correct output format

- [ ] **Step 4: Document E2E results**

Create `~/.claude/skills/stay-on-target/tests/e2e-results.md` with full walkthrough results and pass/fail assessment.

- [ ] **Step 5: Verify E2E complete**

All three phases (lock-in, drift detection, retrospective) should work correctly. Skill is ready for use.

---

### Task 7: Update CLAUDE.md and Skill Registration

Register the skill so it's discoverable and referenced in project standards.

**Files:**
- Modify: `/Users/ryanhaugland/CLAUDE.md`

- [ ] **Step 1: Add stay-on-target to CLAUDE.md engineering standards**

Add a new section under Engineering Standards in `/Users/ryanhaugland/CLAUDE.md`:

```markdown
### Objective Focus
Use the `stay-on-target` skill when starting any client project, beginning implementation, or when scope creep is suspected. Every build should start with objective lock-in — capture the client's raw ask, distill 3-5 objectives, and evaluate all additions against the three-question filter.
```

- [ ] **Step 2: Verify CLAUDE.md update**

Confirm the new section appears under Engineering Standards and doesn't conflict with existing entries.

---

### Task 8: Package Skill for Sharing

Add the skill file and an install script to the GitHub repo so your business partner can set up `/stay-on-target` on his machine.

**Files:**
- Create: `~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md`
- Create: `~/projects/super-duper-on-target/install.sh`
- Create: `~/projects/super-duper-on-target/README.md`

- [ ] **Step 1: Copy the tested SKILL.md into the repo**

```bash
mkdir -p ~/projects/super-duper-on-target/skills/stay-on-target
cp ~/.claude/skills/stay-on-target/SKILL.md ~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md
```

- [ ] **Step 2: Write the install script**

Create `~/projects/super-duper-on-target/install.sh`:

```bash
#!/bin/bash
set -e

SKILL_NAME="stay-on-target"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills/$SKILL_NAME"

if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  echo "Error: SKILL.md not found in $SOURCE_DIR"
  exit 1
fi

mkdir -p "$SKILL_DIR"
cp "$SOURCE_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"

echo "Installed $SKILL_NAME to $SKILL_DIR"
echo ""
echo "You can now use /stay-on-target in Claude Code."
echo ""
echo "On first use, the skill will ask who's driving the session"
echo "and create a drift profile for you over time."
```

- [ ] **Step 3: Make install script executable**

```bash
chmod +x ~/projects/super-duper-on-target/install.sh
```

- [ ] **Step 4: Write a README**

Create `~/projects/super-duper-on-target/README.md`:

```markdown
# stay-on-target

A Claude Code skill that keeps you focused on client objectives and prevents scope creep.

## What it does

- **Locks in objectives** — captures the client's raw ask and distills 3-5 concrete deliverables
- **Detects scope drift** — runs a three-question filter on every new work proposal
- **Parks ideas** — off-scope ideas go to a parking lot for Phase 2 conversations
- **Learns your patterns** — builds a personal drift profile that gets sharper over time
- **Multi-user** — each team member gets their own drift profile

## Install

```bash
git clone https://github.com/rhaugland/super-duper-on-target.git
cd super-duper-on-target
./install.sh
```

## Usage

In Claude Code, type `/stay-on-target` at the start of any client project.

The skill will:
1. Ask you to paste the client's raw ask
2. Help you distill 3-5 objectives
3. Warn you about your known drift tendencies
4. Watch for scope creep during the entire build
5. Park off-scope ideas for Phase 2

## Docs

- [Design Spec](docs/superpowers/specs/2026-03-24-stay-on-target-design.md)
- [Implementation Plan](docs/superpowers/plans/2026-03-24-stay-on-target.md)
```

- [ ] **Step 5: Commit and push to GitHub**

```bash
cd ~/projects/super-duper-on-target
git add skills/ install.sh README.md
git commit -m "feat: add skill file, install script, and README for sharing"
git push -u origin main
```

- [ ] **Step 6: Verify partner can install**

Share with partner:
1. Add them as collaborator on `https://github.com/rhaugland/super-duper-on-target`
2. They run: `git clone https://github.com/rhaugland/super-duper-on-target.git && cd super-duper-on-target && ./install.sh`
3. They now have `/stay-on-target` in their Claude Code
4. Their drift profile starts blank and learns from their sessions
