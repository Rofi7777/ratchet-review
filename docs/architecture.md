# Architecture Deep Dive

## Why 5 Layers?

Each layer addresses a distinct failure mode that the others cannot catch:

| Layer | Failure Mode | Why It Needs Its Own Layer |
|-------|-------------|--------------------------|
| Ground Truth | Wrong facts presented confidently | AI models hallucinate with high confidence. No amount of style review catches a wrong name. |
| Subagent Critic | Writer's blind spots | The same model that made a reasoning error will defend it. An independent agent breaks this loop. |
| Judge | Score inflation | Without calibration anchors, every review converges to "looks good, 8.5/10". |
| Ratchet | Revision that shuffles without improving | Without a monotonic improvement constraint, edits can regress. |
| Learning Loop | Repeated mistakes across sessions | Without tracking what improved and why, the same issues recur. |

## Layer 0: Ground Truth Anchor

```
Input: deliverable text/content
  |
  v
Extract all proper nouns, names, numbers, dates
  |
  v
Cross-reference against (in priority order):
  1. User's knowledge base / memory files
  2. Original source data (Excel, PDF, screenshots)
  3. Context files
  4. `date` command (for day-of-week verification)
  |
  v
Fact errors found?
  |
  +-- Yes --> BLOCK. Return error list. Do not proceed to Layer 1.
  |
  +-- No  --> Proceed to Layer 1.
```

**Design principle**: Ground Truth is an immutable function. It runs identically
on every iteration. It cannot be "argued with" or overridden by the Critic or Judge.
This prevents the common failure mode where a persuasive AI talks itself out of
acknowledging a factual error.

## Layer 1: Subagent Critic

```
Input: deliverable + reader Persona card

Subagent receives ONLY:
  - The deliverable content
  - The reader Persona card
  - The dimension checklist

Subagent does NOT receive:
  - The writer's reasoning or thought process
  - Previous revision history
  - The score from previous rounds

Output: per-dimension issue list + 2 most critical issues
```

**Why a separate agent?** In v1 and v2, the Critic was the same Claude instance
role-playing as a reviewer. This creates a structural blind spot: the model has
access to its own reasoning chain and tends to defend its own decisions
(a form of sycophancy). The Subagent approach forces genuine independence.

**Fallback**: If the Agent tool is unavailable (permissions denied, tool not
available), the skill falls back to v2 mode: same-instance Critic with explicit
instructions to challenge every claim.

## Layer 2: Judge

The Judge scores across dimensions with calibrated anchor cases:

- **Anchor-A (4.5)**: The "this must never ship" example
- **Anchor-B (7.0)**: The "close but needs work" example
- **Anchor-C (8.5)**: The "ready for the CEO" example

Before scoring, the Judge reviews all three anchors to recalibrate. This prevents
the common failure mode of score inflation, where repeated reviews converge to
"everything is 8-9/10".

## Layer 3: Ratchet

The ratchet mechanism ensures monotonic improvement:

```
Round N score >= Round N-1 score  -->  Accept, continue
Round N score <  Round N-1 score  -->  Rollback Round N, restore Round N-1
Round N score == Round N-1 score  -->  Stall detected, change strategy
```

Maximum 3 rounds. If still below 8.0 after 3 rounds, stop and output the best
version with an unresolved issues list.

**Inspiration**: Karpathy's AutoResearch (2026) applies the same principle to
autonomous research agents -- changes that don't measurably improve the output
are reverted.

## Layer 4: Learning Loop

After delivery, the skill logs:

1. **Ratchet history**: Score progression across rounds
2. **Biggest improvement**: Which dimension gained the most, and how
3. **Upstream suggestion**: Which earlier skill/process could prevent the issue

This creates a feedback mechanism that improves the entire skill chain over time,
not just the current deliverable.

## Dimension System

### Text Dimensions (1-5)

Used for Email, DOCX, PDF, Excel:

| # | Dimension | Weight | What It Measures |
|---|-----------|--------|-----------------|
| 1 | Hook | 20% | Can the reader grasp the point in 3 seconds? |
| 2 | Structure | 25% | Pyramid principle. Conclusion first. Logic chain complete. |
| 3 | Evidence | 25% | Data sourced, baselines provided, internally consistent. |
| 4 | Actionability | 20% | Reader knows next step, Ask is specific with deadline. |
| 5 | Conciseness | 10% | Every sentence earns its place. |

### PPTX Extensions (6-7)

Added when reviewing presentations (see `PPTX-RULES.md`):

| # | Dimension | Weight | What It Measures |
|---|-----------|--------|-----------------|
| 6 | Image Quality | 15% | Images improve communication without breaking readability. |
| 7 | Anti-AI Layout | 15% | Presentation looks human-designed, not AI-generated. |

### Design Dimensions (V1-V5)

Used for images, mockups, posters (see `DESIGN-RULES.md`):

| # | Dimension | Weight | What It Measures |
|---|-----------|--------|-----------------|
| V1 | Physics | 25% | Scene obeys real-world physics. |
| V2 | Brand Compliance | 25% | Strictly follows brand VI guidelines. |
| V3 | IP Accuracy | 25% | Characters/assets correctly represented. |
| V4 | Composition | 15% | Clear focal point, readable text, balanced layout. |
| V5 | Purpose Fit | 10% | Output matches its intended use case. |

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| v1 | 2026-02 | 3 layers: Writer, Critic, Judge |
| v2 | 2026-03 | Added Ground Truth Anchor (Layer 0) |
| v3 | 2026-04 | Added Subagent Critic, Persona cards, calibration anchors, learning loop |
