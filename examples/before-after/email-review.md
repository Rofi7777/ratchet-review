# Before / After: Executive Email Review

This example shows a real Ratchet Review cycle: the AI-generated draft,
what each layer caught, and the final output.

## Before (AI First Draft)

```
Subject: Update on recent activities

Dear Management Team,

I hope this email finds you well. I wanted to provide an update on
our recent store performance and some exciting developments.

Our flagship store at Ba Nhat Hotel has been performing well this
quarter. Revenue reached approximately $2.4 million, which represents
solid growth compared to last year. Customer traffic has been steady
and our team has been doing an excellent job.

We are also pleased to announce that we are exploring expansion
opportunities in the southern region. Initial market research suggests
strong demand for our products.

I look forward to discussing these updates in our next meeting.

Best regards
```

## Layer 0: Ground Truth Anchor

```
BLOCKED. 2 factual errors found:

1. "Ba Nhat Hotel" -- not found in knowledge base.
   Did you mean "Bao Ninh Hotel" or "Ba Na Hills"?
   -> Requires manual verification before proceeding.

2. "approximately $2.4 million" -- source data shows $2.1M for Q1.
   Revenue figure inflated by $300K.
   -> Must match source spreadsheet.
```

**Result**: Rejected at Layer 0. Did not enter Critic/Judge.

## After Ground Truth Fix + 2 Revision Rounds

```
Subject: Q1 revenue $2.1M (+12% YoY) -- approve southern expansion study?

Hi [Name],

Ask: Approve $8K for a 4-week market study on southern region expansion.
Deadline: April 5 (consultant availability expires).

Q1 results support the investment:

              Q1 2026    Q1 2025    Change
Revenue       $2.1M      $1.88M     +12%
Traffic       45K visits  41K        +10%
Conversion    4.2%       3.8%       +0.4pp

Store team driving the improvement: new product displays (+18% basket
size) and weekend events (+22% Saturday traffic).

Risk: Southern region has 2 established competitors. The study would
map their store locations, pricing, and lease terms before we commit.

Next step: If approved, consultant starts April 7. First findings
by May 2.

Best regards
```

## Ratchet History

| Round | Ground Truth | Score | Delta | Changes |
|-------|-------------|-------|-------|---------|
| R1 | BLOCKED | -- | -- | 2 fact errors: wrong venue name, wrong revenue |
| R2 | Pass | 6.8 | -- | Facts fixed, but Ask vague, no deadline, no risk section |
| R3 | Pass | 8.6 | +1.8 | Added Ask + deadline + comparison table + risk |

## What Each Layer Caught

| Layer | What It Found | Impact |
|-------|--------------|--------|
| Ground Truth | Wrong venue name, inflated revenue | Would have sent incorrect data to management |
| Subagent Critic | No Ask, buried conclusion, missing comparison | Email would get read but no action taken |
| Judge | Score 6.8 first pass, calibrated against Anchor-B | Prevented a "good enough" output from shipping |
| Ratchet | R2->R3 improved by 1.8 points | Ensured revision actually helped, not just shuffled words |
| Learning Loop | Biggest gain: Actionability (+3) | Upstream suggestion: email-writer skill should require an Ask field |
