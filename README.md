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

## The Three-Question Filter

Every addition gets checked:
1. Did the client ask for this?
2. Does this serve a distilled objective?
3. If we skip this, does the deliverable still meet the client's need?

If the answer is No/No/Yes — it's off-target. Park it and move on.

## Docs

- [Design Spec](docs/superpowers/specs/2026-03-24-stay-on-target-design.md)
- [Implementation Plan](docs/superpowers/plans/2026-03-24-stay-on-target.md)
