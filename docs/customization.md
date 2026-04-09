# Customization Guide

Ratchet Review works out of the box, but you'll get much better results by
customizing it for your context.

## Reader Personas

Personas tell the Critic who's reading the output. This changes what gets flagged.

### Create a Persona

Create a markdown file in `examples/personas/` (or wherever you keep your personas):

```yaml
name: [Reader Name / Role]
reading_time: "< 2 minutes"
first_look: "Numbers, ROI, risk"
hates: "Preamble, long background, vague recommendations"
test_question: "Can I make a decision after reading the first paragraph?"
weight_adjustment: "Hook +5%, Conciseness stricter"
```

### Fields Explained

| Field | Purpose | Example |
|-------|---------|---------|
| `name` | Who this persona represents | "CFO", "Product Manager", "External Client" |
| `reading_time` | How long they'll spend | "< 1 minute", "5-10 minutes" |
| `first_look` | What they scan for first | "Budget impact", "Timeline", "Technical feasibility" |
| `hates` | What makes them stop reading | "Jargon", "Missing data sources", "Walls of text" |
| `test_question` | The pass/fail question | "Do I know what to approve and by when?" |
| `weight_adjustment` | Shift dimension weights | "Evidence +10%" for data-heavy readers |

### When Persona Is Not Specified

If no persona is specified, the skill uses a balanced default (no weight adjustments)
and applies the test question: "Is this clear, accurate, and actionable?"

## Scoring Anchors

Anchors prevent score inflation by giving the Judge concrete reference points.

### Create Anchors

Create 3 files in `examples/anchors/`:

1. **anchor-fail.md** (target: 4.0-5.0) — An output that should never ship
2. **anchor-borderline.md** (target: 6.5-7.5) — Almost good enough, needs revision
3. **anchor-pass.md** (target: 8.0-9.0) — Your quality bar

### Tips for Good Anchors

- Use **real examples** from your work (anonymized if needed)
- Include the **specific issues** that make each anchor score what it does
- Update anchors as your quality bar evolves
- Domain-specific anchors work better than generic ones

## Format Rules

You can add review rules for any output format.

### Add a New Format

1. Create a file in `skill/` (e.g., `NEWSLETTER-RULES.md`)
2. Follow this structure:

```markdown
# [Format] Review Rules

> Auto-loaded when reviewing [format] files.

## Dimension N: [Name] (Weight: X%)

**Core question**: [What this dimension evaluates]

| Check | Deduction |
|-------|-----------|
| [Specific issue] | -X |
| [Specific issue] | -X |

## Critic Output Block

[Template for what the Critic should report]

## Judge Scoring Block

[Template for scoring table]
```

3. Reference it in `SKILL.md` under "Format-Specific Extensions"

### Included Format Rules

| File | Format | Extra Dimensions |
|------|--------|-----------------|
| `PPTX-RULES.md` | Presentations | Image Quality, Anti-AI Layout |
| `DESIGN-RULES.md` | Visual assets | Physics, Brand Compliance, IP Accuracy, Composition, Purpose Fit |

## Trigger Keywords

Edit the `triggers` list in `SKILL.md` to add keywords in your language:

```yaml
triggers:
  - quality check
  - review my output
  - polish this
  - 品質檢查        # Chinese
  - 確認してください  # Japanese
  - revisa esto     # Spanish
```

## Advanced: Weight Adjustments

The default weight matrix can be adjusted per persona or per format.
When both a persona and a format specify weight adjustments, they stack:

```
Base weights (Email):  Hook 25% / Structure 20% / Evidence 20% / Action 25% / Concise 10%
Persona adjustment:    Actionability +10%
Effective weights:     Hook 22% / Structure 18% / Evidence 18% / Action 35% / Concise 7%
```

Redistribution is proportional across the other dimensions.
