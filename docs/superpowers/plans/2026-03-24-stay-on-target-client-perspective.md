# stay-on-target Client Perspective Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add client expectations capture and pre-delivery walkthrough to the stay-on-target skill.

**Architecture:** Two additions to the existing SKILL.md: (1) a new step in Phase 1 that captures what the client expects to experience, and (2) a new Client Walkthrough section between Phase 2 and Phase 3 that role-plays the client perspective before delivery. The objectives.md template is updated to include expectations. All changes are to a single markdown file.

**Tech Stack:** Markdown (SKILL.md updates)

**Spec:** `docs/superpowers/specs/2026-03-24-stay-on-target-client-perspective-design.md`

**Edit ordering:** Tasks are ordered bottom-to-top within the file so that earlier insertions don't shift the anchor text of later tasks.

---

## File Structure

| File | Responsibility |
|------|---------------|
| `~/.claude/skills/stay-on-target/SKILL.md` | Modify: update objectives template, update amendment flow, add Client Walkthrough section, add expectations step to Phase 1, update walkthrough text |
| `~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md` | Sync: copy updated skill to GitHub repo |
| `~/projects/super-duper-on-target/docs/superpowers/specs/2026-03-24-stay-on-target-client-perspective-design.md` | Create: copy spec to repo |
| `~/projects/super-duper-on-target/docs/superpowers/plans/2026-03-24-stay-on-target-client-perspective.md` | Create: copy this plan to repo |

---

### Task 1: Update the Objectives Template

Replace the existing `docs/objectives.md` template in SKILL.md to include the Client Expectations section.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Replace the objectives.md template**

Find the `### docs/objectives.md` template section (under `## File Templates`). Replace the entire template block — everything from `### docs/objectives.md` through the closing code fence — with:

````markdown
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
````

- [ ] **Step 2: Verify template includes Client Expectations between Objectives and Changelog**

Read the template and confirm the new section is present and correctly placed.

---

### Task 2: Update the Objective Amendment Flow

Update the existing Objective Amendment Flow to also cover client expectations when objectives change.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Update the Objective Amendment Flow**

Find `### Objective Amendment Flow` under Phase 3. Replace:

```
When new client input arrives: capture verbatim, update `docs/objectives.md` changelog, re-distill objectives, reset filter against new list.
```

With:

```
When new client input arrives: capture verbatim, update `docs/objectives.md` changelog, re-distill objectives, review and update `## Client Expectations` if the amendment changes the expected experience, reset filter against new list.
```

- [ ] **Step 2: Verify the edit**

Read the section and confirm the expectations update is included in the amendment flow.

---

### Task 3: Add Client Walkthrough Section

Add the new Client Walkthrough section between Phase 2 and Phase 3.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Insert Client Walkthrough section**

Find `## Phase 3: Drift Pattern Learning`. Immediately **before** that line, insert the following new section:

````markdown
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
````

- [ ] **Step 2: Verify the section is correctly placed**

Read the file and confirm Client Walkthrough sits between Phase 2 (Active Drift Detection) and Phase 3 (Drift Pattern Learning).

---

### Task 4: Add Client Expectations Step to Phase 1

Add step 4b to Phase 1 in SKILL.md that captures client expectations after objectives are saved.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Add step 4b after step 4 in Phase 1**

Find `4. **Save to `docs/objectives.md`** using template below.` in Phase 1. Immediately after that line, insert:

```markdown
4b. **Distill client expectations.** Extract 2-5 plain-language statements about what the client expects to *experience* — not what to build (that's objectives), but what it should feel like to use.
    - **Simple projects** (1-2 flows): short-form statements. E.g., "Upload a photo, see result — no account needed."
    - **Complex projects** (3+ flows): scenario format for critical paths. E.g., "Agent opens link → picks slot → confirms → gets email."
    - **Insufficient signal**: if the raw ask lacks experience clues, state assumptions and mark as `*(inferred)*`. Human confirms before lock-in.
    - Save to `docs/objectives.md` under `## Client Expectations`, directly below Distilled Objectives.
```

- [ ] **Step 2: Verify the edit reads correctly**

Read the Phase 1 section and confirm steps flow: 1 → 2 → 3 → 4 → 4b → 5.

---

### Task 5: Update First-Time Walkthrough Text

Update the first-time walkthrough to mention expectations capture so new users know about it.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Update walkthrough step 1**

Find the line:

```
> 1. You paste the client's exact ask. We distill 3-5 concrete objectives.
```

Replace with:

```
> 1. You paste the client's exact ask. We distill 3-5 concrete objectives and capture what the client expects to experience.
```

- [ ] **Step 2: Verify the walkthrough reads naturally**

Read the full walkthrough block and confirm it flows.

---

### Task 6: Verify SKILL.md is Well-Formed

**Files:**
- Read: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Read the full file and verify structure**

Confirm:
- Phase 1 has step 4b (client expectations)
- Client Walkthrough section exists between Phase 2 and Phase 3
- Objective Amendment Flow mentions expectations
- Objectives template includes Client Expectations section
- First-time walkthrough mentions expectations
- File is under 1200 words
- All markdown code fences are properly closed

- [ ] **Step 2: Fix any issues found**

If anything is misplaced or reads poorly, correct it.

---

### Task 7: Sync to GitHub Repo

Copy all updated files to the GitHub repo, commit, and push.

**Files:**
- Modify: `~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md`
- Create: `~/projects/super-duper-on-target/docs/superpowers/specs/2026-03-24-stay-on-target-client-perspective-design.md`
- Create: `~/projects/super-duper-on-target/docs/superpowers/plans/2026-03-24-stay-on-target-client-perspective.md`

- [ ] **Step 1: Copy files to repo**

```bash
cp ~/.claude/skills/stay-on-target/SKILL.md ~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md
cp ~/docs/superpowers/specs/2026-03-24-stay-on-target-client-perspective-design.md ~/projects/super-duper-on-target/docs/superpowers/specs/
cp ~/docs/superpowers/plans/2026-03-24-stay-on-target-client-perspective.md ~/projects/super-duper-on-target/docs/superpowers/plans/
```

- [ ] **Step 2: Commit and push**

```bash
cd ~/projects/super-duper-on-target
git add skills/ docs/
git commit -m "feat: add client perspective — expectations capture and pre-delivery walkthrough

- Phase 1 now captures client experience expectations alongside objectives
- New Client Walkthrough section for pre-delivery role-play check
- Updated objectives template with Client Expectations section
- Objective amendment flow now covers expectations updates

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push origin main
```

- [ ] **Step 3: Verify push succeeded**

```bash
cd ~/projects/super-duper-on-target
git log --oneline -3
git diff HEAD
```

Confirm latest commit includes all changes and working tree is clean.
