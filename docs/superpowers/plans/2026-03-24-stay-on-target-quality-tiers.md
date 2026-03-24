# stay-on-target Quality Tiers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add quality tier commitment and rushing detection to the stay-on-target skill.

**Architecture:** Four additions to the existing SKILL.md: (1) a new step 4c in Phase 1 for quality tier selection, (2) a Quality Check subsection in Phase 2 with rushing signal phrases and tier-based responses, (3) an updated objectives template with the Quality Tier section, and (4) the quality tier displayed in the returning user cheat sheet.

**Tech Stack:** Markdown (SKILL.md updates)

**Spec:** `docs/superpowers/specs/2026-03-24-stay-on-target-quality-tiers-design.md`

**Edit ordering:** Tasks are ordered bottom-to-top within the file so that earlier insertions don't shift the anchor text of later tasks.

---

## File Structure

| File | Responsibility |
|------|---------------|
| `~/.claude/skills/stay-on-target/SKILL.md` | Modify: update objectives template, add Quality Check subsection to Phase 2, add step 4c to Phase 1, update cheat sheet, update walkthrough text |
| `~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md` | Sync: copy updated skill to GitHub repo |
| `~/projects/super-duper-on-target/docs/superpowers/specs/2026-03-24-stay-on-target-quality-tiers-design.md` | Create: copy spec to repo |
| `~/projects/super-duper-on-target/docs/superpowers/plans/2026-03-24-stay-on-target-quality-tiers.md` | Create: copy this plan to repo |

---

### Task 1: Update the Objectives Template

Add `## Quality Tier` section to the `docs/objectives.md` template in SKILL.md.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Add Quality Tier section to the template**

Find the `docs/objectives.md` template under `## File Templates`. Inside the template code block, find:

```
## Client Expectations
- [What the client expects to experience]
- [Implicit constraints — e.g., "no login needed"]
- [Quality expectations — e.g., "fast, mobile-friendly"]

## Changelog
```

Insert between Client Expectations and Changelog:

```markdown
## Quality Tier
**Tier:** Craft | Functional | Prototype
**Reference:** (optional)
```

So the template now flows: Raw Client Ask → Distilled Objectives → Client Expectations → Quality Tier → Changelog.

- [ ] **Step 2: Verify template is correct**

Read the File Templates section and confirm Quality Tier is between Client Expectations and Changelog.

---

### Task 2: Add Quality Check Subsection to Phase 2

Add rushing detection as a new subsection in Phase 2, after Task Boundary Check.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Insert Quality Check subsection**

Find `### Preemptive Anticipation` in Phase 2. Immediately BEFORE that line, insert:

```markdown
### Quality Check

Rushing signal phrases — intervene based on the project's quality tier when you hear:

- "Just make it work"
- "Good enough"
- "We can polish later"
- "The client won't notice"
- "Let's just ship it"
- "I don't want to overthink this"
- "It's fine, let's move on" / "It's fine for now"
- "We're running out of time"

Evaluate in context — "it's fine" as genuine acceptance is not a rushing signal.

| Tier | Response |
|------|----------|
| Craft | **Stop.** "You committed to craft. Before moving on: is this something you'd be proud to show?" |
| Functional | **Nudge.** "Quick check — is this clean and consistent, or are you cutting a corner?" |
| Prototype | **Silent.** Speed is the commitment. Don't intervene on quality. |

One intervention per signal. If the builder says "I know, move on" — respect it. This is a mirror, not a gate. Rushing signals are not drift events — do not log them to the drift log or dashboard.

To change tier mid-project: update `docs/objectives.md`, log in Changelog, confirm aloud. No further ceremony.

```

- [ ] **Step 2: Verify the section is correctly placed**

Read Phase 2 and confirm Quality Check sits after Task Boundary Check and before Preemptive Anticipation.

---

### Task 3: Add Quality Tier Step to Phase 1

Add step 4c to Phase 1 for quality tier selection.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Add step 4c after step 4b**

Find the last line of step 4b (the line containing `Save to `docs/objectives.md` under `## Client Expectations``). After that line and before step 5, insert:

```markdown
4c. **Set quality tier.** Ask: "Quality tier for this project — Craft, Functional, or Prototype? Optional: add a reference for what 'good' looks like."
    - **Craft** — Design matters. Iterate on look and feel. "Is this good?" before moving on.
    - **Functional** — Solid and clean. Good defaults, no rough edges. Don't obsess, don't cut corners.
    - **Prototype** — Speed is the point. Get it working. Polish is deferred.
    - Default to **Functional** if the builder declines to choose.
    - Optional reference: "Craft — think Linear" or "Prototype — demo for Thursday."
    - Save to `docs/objectives.md` under `## Quality Tier`.
    - If returning to a project where `docs/objectives.md` exists but has no `## Quality Tier`, prompt for the tier before proceeding. Default to Functional if declined.
```

- [ ] **Step 2: Verify Phase 1 step flow**

Read Phase 1 and confirm steps flow: 1 → 2 → 3 → 4 → 4b → 4c → 5.

---

### Task 4: Update Returning User Cheat Sheet

Add the quality tier to the cheat sheet so returning users see their commitment at session start.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Add tier line to cheat sheet**

Find the Returning User Cheat Sheet block. After the line:

```
> No/No/Yes → Park it. Gray area → Ask yes/no.
```

And before the blank line preceding `> Your patterns:`, insert:

```
> Tier: {tier} — "{reference}"
```

So the cheat sheet now shows: Filter → Tier → Your patterns → Dashboard.

- [ ] **Step 2: Verify cheat sheet reads correctly**

Read the full cheat sheet block and confirm the tier line is present and the layout flows naturally.

---

### Task 5: Update First-Time Walkthrough Text

Update the walkthrough to mention quality tiers so new users know about them.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Update walkthrough step 1**

Find the line:

```
> 1. You paste the client's exact ask. We distill 3-5 concrete objectives and capture what the client expects to experience.
```

Replace with:

```
> 1. You paste the client's exact ask. We distill objectives, capture what the client expects to experience, and set a quality tier.
```

- [ ] **Step 2: Verify the walkthrough reads naturally**

Read the full walkthrough block and confirm it flows.

---

### Task 6: Verify SKILL.md is Well-Formed

**Files:**
- Read: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Read the full file and verify structure**

Confirm:
- Phase 1 has step 4c (quality tier) after 4b and before 5
- Phase 2 has Quality Check subsection after Task Boundary Check and before Preemptive Anticipation
- Returning user cheat sheet shows the tier line
- First-time walkthrough mentions quality tier
- Objectives template includes Quality Tier section between Client Expectations and Changelog
- All markdown code fences are properly closed
- File reads naturally end-to-end

- [ ] **Step 2: Fix any issues found**

If anything is misplaced or reads poorly, correct it.

---

### Task 7: Sync to GitHub Repo

Copy all updated files to the GitHub repo, commit, and push.

**Files:**
- Modify: `~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md`
- Create: `~/projects/super-duper-on-target/docs/superpowers/specs/2026-03-24-stay-on-target-quality-tiers-design.md`
- Create: `~/projects/super-duper-on-target/docs/superpowers/plans/2026-03-24-stay-on-target-quality-tiers.md`

- [ ] **Step 1: Copy files to repo**

```bash
cp ~/.claude/skills/stay-on-target/SKILL.md ~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md
cp ~/docs/superpowers/specs/2026-03-24-stay-on-target-quality-tiers-design.md ~/projects/super-duper-on-target/docs/superpowers/specs/
cp ~/docs/superpowers/plans/2026-03-24-stay-on-target-quality-tiers.md ~/projects/super-duper-on-target/docs/superpowers/plans/
```

- [ ] **Step 2: Commit and push**

```bash
cd ~/projects/super-duper-on-target
git add skills/ docs/
git commit -m "feat: add quality tiers — rushing detection calibrated by craft commitment

- Phase 1 now captures quality tier (Craft/Functional/Prototype)
- Phase 2 Quality Check detects rushing signals with tier-based responses
- Updated objectives template and cheat sheet with tier display
- Spec and plan docs included

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
