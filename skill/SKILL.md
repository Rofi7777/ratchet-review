---
name: ratchet-review
description: |
  A 5-layer adversarial quality gate for Claude Code.
  Ground Truth Anchor + Subagent Critic + Calibrated Judge + Ratchet Loop + Learning Loop.
  Catches factual errors, score inflation, and buried conclusions before output ships.
  Auto-loads PPTX-RULES.md for presentations, DESIGN-RULES.md for visual assets.
  Use when: quality check, review my output, polish this, optimize output.
triggers:
  - quality check
  - review my output
  - polish this
  - polish
  - check this
  - review output
  - can you check
  - is this good
  - proofread
  - fact check
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
model: sonnet
author: Rofi (github.com/Rofi7777)
version: 3.0.0
date: 2026-04-09
effort: high
---

# Ratchet Review — Output Quality Gate v3

## Exclusion Rules (do NOT trigger)

- Output < 50 words (quick replies, confirmations)
- Raw data / data table exports
- Code / scripts / system configuration
- Internal drafts / personal notes / memory updates
- Output that already passed Ratchet Review

## Architecture Overview (5 Layers)

```
+----------------------------------------------+
|  Layer 0: Ground Truth Anchor (immutable)     |  External fact verification
|  Proper nouns / numbers -> cross-reference    |  Fact error > 0 = blocked
+-----------------+----------------------------+
                  v
+----------------------------------------------+
|  Layer 1: Subagent Critic (independent)       |  Launch separate Agent
|  Only sees deliverable + Persona card         |  True cognitive diversity
+-----------------+----------------------------+
                  v
+----------------------------------------------+
|  Layer 2: Judge (score + ratchet)             |  Calibration anchors + scoring
+-----------------+----------------------------+
                  | < 8 = Writer revises -> back to Layer 0
                  | >= 8 v
+----------------------------------------------+
|  Layer 3: Deliver + Learning Loop             |  Track improvement trajectory
+----------------------------------------------+
```

## Layer 0: Ground Truth Anchor

> Immutable evaluation function. Must execute every iteration. Cannot be skipped.

**0a. Extract**: Scan all proper nouns, names, venue names, brand names, abbreviations, amounts, dates.

**0b. Cross-reference** (by priority):
1. User's knowledge base / memory files (if available)
2. Original source data (Excel / PDF / screenshots provided by user)
3. Context files
4. `date` command to verify dates / day-of-week

**0c. Intercept rules**:
- Fact errors > 0 -> **reject immediately**, do not enter Critic/Judge
- Fact errors = 0 -> proceed

| Category | Verification Method | On Failure |
|----------|-------------------|------------|
| Brand / venue names | Search user's knowledge base | Red: reject |
| Person names | Cross-reference contact list | Red: reject |
| Company names / abbrevs | Cross-reference source data | Red: reject |
| Amounts / quantities | Cross-reference original data | Red: reject |
| Dates / day-of-week | `date` command verification | Red: reject |
| Product / IP names | Cross-reference official names | Yellow: flag, allow review |

## Layer 1: Subagent Critic

> The writer and reviewer must be separate. Same-model self-review is structurally blind.

**Launch method**:
```
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
  You are a strict quality reviewer.

  [Reader Persona]
  {persona_card}

  [Output format] {format}
  [Output purpose] {purpose}
  [Output content]
  {content}

  Review using these 5 dimensions. Give specific problems (not vague praise).
  List 1-3 most serious issues per dimension.
  Summarize the 2 most critical issues at the end.

  Dimensions: Hook / Structure / Evidence / Actionability / Conciseness
  """
)
```

**Why this works**:
- Subagent only receives the deliverable and Persona — not the writer's reasoning
- Breaks the structural weakness of "reviewing your own work"
- True cognitive diversity

**Fallback**: If Agent tool is unavailable or denied, fall back to same-instance Critic (v2 mode).

## Reader Personas

> Before Critic review, load the appropriate Persona card based on the target reader.
> Personas are optional — without custom personas, the Critic uses a general executive reader profile.
> To customize, copy the examples into your skill directory:
> `cp -r <repo>/examples/personas/ ~/.claude/skills/ratchet-review/personas/`
> Then edit to match your organization's stakeholders. Template:

```yaml
name: [Reader Name / Role]
reading_time: [e.g., "< 2 minutes"]
first_look: [What they scan for first]
hates: [What makes them stop reading]
test_question: [The question this reader asks after reading]
weight_adjustment: [e.g., "Hook +5%, Conciseness stricter"]
```

See `examples/personas/` for ready-to-use templates:
- `executive-ceo.md` — Time-starved decision maker
- `executive-vp.md` — Needs full context + data-backed narrative
- `team-internal.md` — Just needs to know what to do next

## Text Content Review (5 Dimensions)

Applies to: Email, PPTX, DOCX, PDF, Excel

### Dimension 1: Hook — 3-Second Rule (20%)
- Does the decision-maker know the point within 3 seconds?
- Deductions: Opens with background -3 / Vague title -2 / Must scroll to find the point -2

### Dimension 2: Structure — Pyramid Principle (25%)
- Complete logic chain? Conclusion first?
- Deductions: Conclusion buried in middle -3 / Logic gap -2 / Contradictions -2 / Can't skim -1

### Dimension 3: Evidence — Data Credibility (25%)
- Numbers sourced? Reasonable comparison baselines? Internally consistent?
- Deductions: Claims without data -3 / No comparison baseline -2 / Chart contradicts text -3 / Cross-table inconsistency -3

### Dimension 4: Actionability — Drives Decisions (20%)
- Reader knows next step? Ask is clear?
- Deductions: No Ask -3 / Vague Ask -2 / Missing deadline -1 / Missing owner -1

### Dimension 5: Conciseness — Respect Reader's Time (10%)
- Where can you cut? Is every sentence earning its place?
- Deductions: Can cut 30%+ content -3 / Excessive modifiers -1 / PPTX text wall >80 words/slide -2

### Format-Specific Extensions

- **PPTX**: Auto-load `${CLAUDE_SKILL_DIR}/PPTX-RULES.md`, add Dimension 6 (Image Quality 15%) + Dimension 7 (Anti-AI Layout 15%), reduce text dimension weights accordingly
- **Design assets**: Auto-load `${CLAUDE_SKILL_DIR}/DESIGN-RULES.md`, switch to V1-V5 framework, do not use text dimensions

### Format Weight Matrix

| Format | Hook | Structure | Evidence | Action | Concise | Image | Anti-AI |
|--------|------|-----------|----------|--------|---------|-------|---------|
| Email (exec) | 25% | 20% | 20% | 25% | 10% | - | - |
| PPTX | 10% | 20% | 20% | 10% | 10% | 15% | 15% |
| DOCX/PDF | 15% | 25% | 30% | 20% | 10% | - | - |
| Excel | 10% | 20% | 35% | 20% | 15% | - | - |

## Calibration Anchors

> Judge must review these 3 anchors before every scoring round to prevent score inflation.

**Anchor-A (4.5 — Failing)**
- Venue name misspelled ("Grand Hayatt" instead of "Grand Hyatt"), conclusion buried in paragraph 4, no Ask, 280 words of padding
- This quality must never ship

**Anchor-B (7.0 — Close but not passing)**
- Facts correct, structure decent, but Ask is vague ("looking forward to your feedback"), no YoY comparison, could cut 20%
- Needs one more revision round

**Anchor-C (8.5 — Passing)**
- First sentence is conclusion + Ask, data has comparison baselines, under 150 words, risks transparent
- This is the quality bar for executive deliverables

> Anchors are optional — the defaults above work out of the box.
> To customize, copy `<repo>/examples/anchors/` into your skill directory and edit to match your real cases.

## Execution Flow

**Step 0: Ground Truth Anchor** (lock)
Extract -> cross-reference -> intercept (see Layer 0)

**Step 1: Confirm format & load rules**
- Email/DOCX/PDF/Excel -> text dimensions 1-5
- PPTX -> text dimensions 1-5 + load `PPTX-RULES.md`
- Design assets -> load `DESIGN-RULES.md`
- Confirm target reader -> load Persona card

**Step 2: Subagent Critic review**
Launch independent Agent (see Layer 1), pass deliverable + Persona card + dimension checklist.
Critic returns per-dimension issue list + 2 most critical issues.

**Step 3: Judge scoring + Ratchet Check**
```
Judge Scoring

| Dimension | Score | Weight | Weighted | Deduction Reason |
|-----------|-------|--------|----------|-----------------|
| Hook      | X/10  | X%     | X.X      | [reason]        |
| ...       | ...   | ...    | ...      | ...             |
| **Total** |       |        | **X.X**  |                 |

Ratchet Check:
- Round N: X.X / Round N-1: X.X / Delta: +X.X
- Ratchet: [up] increasing / [stall] change strategy / [down] rollback this round

Calibration: vs Anchor-A(4.5) Anchor-B(7.0) Anchor-C(8.5) — is this score reasonable?

Verdict: PASS (>= 8) / REVISE (< 8)
```

**Step 4: Iterate (if needed)**
- Writer revises based on Critic feedback -> **back to Step 0** (Ground Truth re-check)
- Maximum 3 Ratchet Loop rounds
- Regression -> rollback this round, restore previous version
- Log each round: round number, score, delta, main changes

**Step 5: Deliver + Learning Loop**
```
Ratchet History
| Round | Ground Truth | Score | Delta | Main Changes |
|-------|-------------|-------|-------|-------------|
| R1    | [pass]      | X.X   | -     | Initial     |
| R2    | [pass]      | X.X   | +X.X  | [changes]   |
| Final | [pass]      | X.X   |       | PASS        |

Learning Loop:
- Biggest improvement: [which dimension improved most, how]
- Upstream suggestion: [which upstream skill/process could prevent this issue]
```

## 3-Round Fail Safe

If still < 8 after 3 rounds -> **stop iterating** + output current best version + attach "unresolved issues list" + analyze what's stuck (skill issue or input issue) -> ask user to decide manually.

## Integration with Other Skills

```
[Any output-producing skill] -> ratchet-review -> deliver

email-writer           -> RR (text dims)       -> Email
pptx-creator           -> RR (text + PPTX)     -> PPTX
docx-writer            -> RR (text dims)       -> DOCX
xlsx-writer            -> RR (text dims)       -> Excel
design-workflow        -> RR (DESIGN-RULES)    -> Images/mockup
```

## Version History

| Item | v1 | v2 | v3 |
|------|----|----|-----|
| Architecture | 3 layers (W/C/J) | 4 layers (+Ground Truth) | **5 layers (+Subagent Critic + Learning Loop)** |
| Fact verification | Critic internal reasoning | Layer 0 external check | Same + modularized Ground Truth |
| Critic | Same-instance role play | Same-instance (shared blind spots) | **Independent Subagent (cognitive diversity)** |
| Reader simulation | One-line instruction | One-line instruction | **Persona cards (quantified reading behavior)** |
| Score calibration | None | None | **3 Anchor Cases prevent inflation** |
| Learning loop | None | None | **Track improvement trajectory + upstream feedback** |

**Inspired by**:
- Adversarial content review (Fu Sheng)
- AutoResearch Ratchet Loop (Karpathy, 2026)

**Maintainer**: Community (originally by Rofi + Claude Code)
