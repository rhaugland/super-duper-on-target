# stay-on-target Dashboard & Startup Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add adaptive startup instructions, drift event logging, and a per-user static HTML dashboard to the stay-on-target skill.

**Architecture:** Three additions to the existing skill: (1) a startup display section in SKILL.md that shows a walkthrough or cheat sheet based on whether the user is new, (2) a JSONL event log that captures every drift event, and (3) a self-contained HTML dashboard that's generated on demand from the log data. All file operations use Claude's standard Write/Edit tools. No servers, no dependencies.

**Tech Stack:** Markdown (SKILL.md updates), JSON Lines (event log), vanilla HTML/CSS/JS (dashboard)

**Spec:** `docs/superpowers/specs/2026-03-24-stay-on-target-dashboard-design.md`

---

## File Structure

| File | Responsibility |
|------|---------------|
| `~/.claude/skills/stay-on-target/SKILL.md` | Modify: add Startup Display section, add drift event logging instructions to Phase 2 |
| `~/.claude/skills/stay-on-target/drift-log-ryan.json` | Create: seeded JSONL event log with dummy data |
| `~/.claude/skills/stay-on-target/dashboard-ryan.html` | Create: static HTML dashboard generated from log data |

---

### Task 1: Seed Dummy Drift Log Data

Create Ryan's drift event log with realistic dummy data so the dashboard has something to show.

**Files:**
- Create: `~/.claude/skills/stay-on-target/drift-log-ryan.json`

- [ ] **Step 1: Write the seeded JSONL file**

Create `~/.claude/skills/stay-on-target/drift-log-ryan.json` with the following content (one JSON object per line):

```jsonl
{"date":"2026-02-23","time":"10:15","project":"virtual-staging","suggestion":"MLS scraper for auto photo import","category":"delivery-reimagining","trigger_context":"architecture planning","result":"parked","driver":"ryan"}
{"date":"2026-02-23","time":"10:42","project":"virtual-staging","suggestion":"Login system for agents","category":"auth-creep","trigger_context":"frontend work","result":"parked","driver":"ryan"}
{"date":"2026-02-24","time":"14:08","project":"virtual-staging","suggestion":"Agent onboarding flow","category":"auth-creep","trigger_context":"frontend work","result":"parked","driver":"ryan"}
{"date":"2026-02-24","time":"15:30","project":"virtual-staging","suggestion":"Batch processing queue for staging jobs","category":"over-engineering","trigger_context":"backend implementation","result":"parked","driver":"ryan"}
{"date":"2026-03-01","time":"09:20","project":"client-crm","suggestion":"Email integration from contact cards","category":"feature-stacking","trigger_context":"mid-implementation","result":"overridden","driver":"ryan"}
{"date":"2026-03-01","time":"11:45","project":"client-crm","suggestion":"Analytics dashboard for contact engagement","category":"feature-stacking","trigger_context":"mid-implementation","result":"parked","driver":"ryan"}
{"date":"2026-03-02","time":"10:00","project":"client-crm","suggestion":"Role-based access control","category":"auth-creep","trigger_context":"frontend work","result":"parked","driver":"ryan"}
{"date":"2026-03-02","time":"14:22","project":"client-crm","suggestion":"Full audit logging system","category":"over-engineering","trigger_context":"backend implementation","result":"parked","driver":"ryan"}
{"date":"2026-03-08","time":"11:10","project":"warranty-form","suggestion":"Chatbot replacement for warranty form","category":"delivery-reimagining","trigger_context":"architecture planning","result":"parked","driver":"ryan"}
{"date":"2026-03-08","time":"14:55","project":"warranty-form","suggestion":"AI auto-classification of issue types","category":"feature-stacking","trigger_context":"mid-implementation","result":"gray-yes","driver":"ryan"}
{"date":"2026-03-09","time":"09:30","project":"warranty-form","suggestion":"Photo enhancement before submission","category":"feature-stacking","trigger_context":"mid-implementation","result":"parked","driver":"ryan"}
{"date":"2026-03-14","time":"10:05","project":"team-dashboard","suggestion":"Authentication system","category":"auth-creep","trigger_context":"frontend work","result":"warned","driver":"ryan"}
{"date":"2026-03-14","time":"10:45","project":"team-dashboard","suggestion":"Role-based access for team members","category":"auth-creep","trigger_context":"frontend work","result":"parked","driver":"ryan"}
{"date":"2026-03-15","time":"13:20","project":"team-dashboard","suggestion":"Slack integration for status updates","category":"feature-stacking","trigger_context":"mid-implementation","result":"parked","driver":"ryan"}
{"date":"2026-03-15","time":"15:10","project":"team-dashboard","suggestion":"Real-time WebSocket updates","category":"over-engineering","trigger_context":"architecture planning","result":"parked","driver":"ryan"}
{"date":"2026-03-20","time":"09:45","project":"booking-app","suggestion":"Waitlist for fully-booked slots","category":"feature-stacking","trigger_context":"mid-implementation","result":"parked","driver":"ryan"}
{"date":"2026-03-20","time":"11:30","project":"booking-app","suggestion":"SMS confirmation notifications","category":"feature-stacking","trigger_context":"mid-implementation","result":"parked","driver":"ryan"}
{"date":"2026-03-21","time":"10:15","project":"booking-app","suggestion":"Calendar sync integration","category":"feature-stacking","trigger_context":"mid-implementation","result":"gray-no","driver":"ryan"}
{"date":"2026-03-21","time":"14:00","project":"booking-app","suggestion":"Multi-location support","category":"over-engineering","trigger_context":"architecture planning","result":"warned","driver":"ryan"}
```

- [ ] **Step 2: Verify the file is valid JSONL**

```bash
cat ~/.claude/skills/stay-on-target/drift-log-ryan.json | python3 -c "import sys,json; [json.loads(l) for l in sys.stdin]; print('Valid JSONL: 19 events')"
```

Expected: `Valid JSONL: 19 events`

---

### Task 2: Build the Dashboard HTML

Create the static HTML dashboard that reads embedded data and renders drift patterns and event feed.

**Files:**
- Create: `~/.claude/skills/stay-on-target/dashboard-ryan.html`

- [ ] **Step 1: Read the seed data to understand the data shape**

```bash
head -3 ~/.claude/skills/stay-on-target/drift-log-ryan.json
```

- [ ] **Step 2: Write the dashboard HTML file**

Create `~/.claude/skills/stay-on-target/dashboard-ryan.html`. The file must be self-contained (inline CSS and JS). Requirements:

**Top bar:**
- Display: "Ryan's Drift Dashboard"
- Stats row: total events, unique projects, % parked vs overridden, most common category
- "Last updated" timestamp

**Left panel — Drift Pattern Summary (roughly 40% width):**
- One card per category found in the data
- Each card shows: category name (human-readable), event count, frequency badge (high if 5+, medium if 3-4, low if 1-2)
- Trigger contexts listed under each card
- Trend arrow: compare events in last 15 days vs prior 15 days (↑ increasing, ↓ decreasing, → stable)

**Right panel — Drift Event Feed (roughly 60% width):**
- Each event as a row: date, project name, suggestion text, category tag pill, result badge
- Result badge colors: parked = gray/neutral, overridden = amber/orange, gray-yes = green, gray-no = light red, warned = blue
- Newest events at top
- Filter buttons at top of feed: "All", one per category, one per result type. Clicking toggles visibility.

**Design guidelines:**
- Dark theme with subtle backgrounds (dark gray/slate palette)
- Clean, monospace-friendly typography
- Responsive — single column on narrow screens
- No external dependencies — everything inline

**Data embedding:** The event data from `drift-log-ryan.json` should be embedded as a JS array at the top of a `<script>` tag:

```javascript
const DRIFT_EVENTS = [
  // ... each event as a JS object
];
const DRIVER = "ryan";
const GENERATED_AT = "2026-03-24T...";
```

The rest of the JS reads from `DRIFT_EVENTS` to compute stats and render the UI.

- [ ] **Step 3: Open the dashboard and verify it renders**

```bash
open ~/.claude/skills/stay-on-target/dashboard-ryan.html
```

Verify in browser:
- Top bar stats are correct (19 events, 5 projects)
- Left panel shows 4 category cards (auth-creep, feature-stacking, over-engineering, delivery-reimagining)
- Right panel shows all 19 events with correct badges
- Filter buttons work
- Layout is responsive

- [ ] **Step 4: Fix any visual issues found during verification**

If the dashboard doesn't look right, iterate on the HTML/CSS until it does.

---

### Task 3: Update SKILL.md — Add Startup Display

Add the adaptive startup instructions to the skill file.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Add Startup Display section to SKILL.md**

Add a new section after the overview (before Phase 1) called `## Startup Display`. Content:

```markdown
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
> 1. You paste the client's exact ask. We distill 3-5 concrete objectives.
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
```

- [ ] **Step 2: Verify SKILL.md is still well-formed**

```bash
wc -w ~/.claude/skills/stay-on-target/SKILL.md
```

Confirm the skill hasn't ballooned unreasonably (target: under 1000 words with additions).

---

### Task 4: Update SKILL.md — Add Drift Event Logging

Add instructions to Phase 2 so the skill logs every drift event to the JSONL file.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Add logging instructions to Phase 2**

After the Case Matrix section in Phase 2, add:

```markdown
### Drift Event Logging

After every filter evaluation (park, override, gray area resolution, or preemptive warning), append one line to `~/.claude/skills/stay-on-target/drift-log-{driver}.json`:

```json
{"date":"YYYY-MM-DD","time":"HH:MM","project":"project-name","suggestion":"what was proposed","category":"drift-category","trigger_context":"what was happening","result":"parked|overridden|gray-yes|gray-no|warned","driver":"name"}
```

Driver names are always lowercased. If the file doesn't exist, create it. Categories are free-form strings — use descriptive names like `auth-creep`, `feature-stacking`, `over-engineering`, `delivery-reimagining`.
```

- [ ] **Step 2: Verify the addition is correctly placed**

Read the file and confirm the logging section sits between the Case Matrix and Task Boundary Check sections.

---

### Task 5: Update SKILL.md — Add Dashboard Generation Instructions

Add instructions telling the skill how and when to regenerate the dashboard.

**Files:**
- Modify: `~/.claude/skills/stay-on-target/SKILL.md`

- [ ] **Step 1: Add Dashboard Generation section to SKILL.md**

Add a new section after Multi-User Support called `## Dashboard`. Content:

```markdown
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
```

- [ ] **Step 2: Verify section is correctly placed**

Read the file and confirm the Dashboard section sits after Multi-User Support and before the end of the file.

---

### Task 6: Update GitHub Repo

Sync all changes to the GitHub repo so the partner can get the latest skill.

**Files:**
- Modify: `~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md`
- Create: `~/projects/super-duper-on-target/docs/superpowers/specs/2026-03-24-stay-on-target-dashboard-design.md`
- Create: `~/projects/super-duper-on-target/docs/superpowers/plans/2026-03-24-stay-on-target-dashboard.md`

- [ ] **Step 1: Copy updated skill and new spec/plan to repo**

```bash
mkdir -p ~/projects/super-duper-on-target/skills/stay-on-target
cp ~/.claude/skills/stay-on-target/SKILL.md ~/projects/super-duper-on-target/skills/stay-on-target/SKILL.md
cp /Users/ryanhaugland/docs/superpowers/specs/2026-03-24-stay-on-target-dashboard-design.md ~/projects/super-duper-on-target/docs/superpowers/specs/
cp /Users/ryanhaugland/docs/superpowers/plans/2026-03-24-stay-on-target-dashboard.md ~/projects/super-duper-on-target/docs/superpowers/plans/
```

- [ ] **Step 2: Update install.sh to include drift-log seeding**

Update `~/projects/super-duper-on-target/install.sh` to also note that a sample dashboard can be generated:

```bash
# After the existing install lines, add:
echo ""
echo "To generate your drift dashboard after your first session:"
echo "  Ask Claude: 'update my stay-on-target dashboard'"
```

- [ ] **Step 3: Commit and push**

```bash
cd ~/projects/super-duper-on-target
git add skills/ docs/ install.sh
git commit -m "feat: add drift dashboard, event logging, and adaptive startup

- Adaptive startup: walkthrough for new users, cheat sheet for returning
- JSONL event logging for all drift events
- Static HTML dashboard with pattern summary and event feed
- Updated spec and plan docs

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push origin main
```

---

### Task 7: Verify End-to-End

Open the dashboard and confirm everything works together.

- [ ] **Step 1: Open Ryan's dashboard**

```bash
open ~/.claude/skills/stay-on-target/dashboard-ryan.html
```

- [ ] **Step 2: Verify dashboard content**

Confirm:
- 19 events displayed in feed
- 4 category cards in pattern summary
- Stats are accurate (5 projects, correct parked/overridden counts)
- Filters work (click category tags, result badges)
- Responsive on narrow window

- [ ] **Step 3: Verify SKILL.md reads correctly**

Read the full SKILL.md and confirm:
- Startup Display section is present with both walkthrough and cheat sheet
- Drift Event Logging section is in Phase 2
- Dashboard reference appears in returning user cheat sheet
- Word count is under 1000

- [ ] **Step 4: Verify GitHub repo is current**

```bash
cd ~/projects/super-duper-on-target
git log --oneline -3
git diff HEAD
```

Confirm latest commit includes all changes and working tree is clean.
