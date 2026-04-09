# Ratchet Review

**Ratchet Review** is an open-source [Claude Code](https://claude.ai/code) skill
that runs an independent AI agent to review your AI-generated output before it ships.
It catches factual errors, score inflation, and buried conclusions using a 5-layer
adversarial quality gate with calibrated scoring and a ratchet mechanism that
ensures each revision improves on the last.

> Before: "This report looks great."
> After: "This report is great AND the client name is actually spelled right."

## Why This Exists

AI writes fluently. It doesn't write carefully:

- A consulting firm's AI-generated government report cited fabricated sources
  -- the contract was partially refunded
  ([Deloitte Australia](https://originality.ai/blog/ai-hallucination-factual-error-problems))
- Multiple lawyers sanctioned after submitting AI-hallucinated legal citations
  to court -- fines exceeding $10K, public apologies
  ([Originality.AI](https://originality.ai/blog/ai-hallucination-factual-error-problems))
- An AI travel guide listed a food bank as a "must-visit dining experience"
  ([Microsoft Copilot](https://www.crescendo.ai/blog/ai-controversies))
- 77% of daily AI users now review AI output as carefully as human colleagues'
  work ([Workday/Hanover Research, n=3,200](https://newsroom.workday.com/2026-01-14-New-Workday-Research-Companies-Are-Leaving-AI-Gains-on-the-Table))

The root cause: **asking the same AI to check its own work is structurally
blind.** The model that made the mistake will defend it.
([Nature, 2025](https://www.nature.com/articles/d41586-025-04032-1))

Ratchet Review runs a separate Critic agent that never sees the writer's
reasoning -- only the deliverable and the reader's profile.

## How It Works

Five layers, each independently verifiable:

```
Layer 0  Ground Truth     Fact-check names, numbers, dates against
                          your source data. Any error = blocked.

Layer 1  Subagent Critic  Independent agent. Only sees the deliverable
                          + reader persona. No shared context with writer.

Layer 2  Judge            Score across 5 dimensions with calibrated
                          anchor cases (4.5 / 7.0 / 8.5). No inflation.

Layer 3  Ratchet          Each revision must score higher than the last.
                          Regression = automatic rollback.

Layer 4  Learning Loop    Track what improved, feed insights upstream.
```

## Install

```bash
bash install.sh

# or manually:
cp -r skill/ ~/.claude/skills/ratchet-review/
```

## 30-Second Test

After installing, open Claude Code and try:

```
Write me a short email to the Grand Hyatt about our event.
```

Then say: **"review my output"**

Watch Layer 0 fact-check the hotel name, Layer 1 critique the structure,
and Layer 2 score it -- all before you hit send.

## Usage

Say any of these to trigger a review:

- "review my output"
- "quality check"
- "polish this"
- "check this"
- "proofread"
- "fact check"

The skill auto-triggers based on keywords. No setup needed beyond install.

## Customize

| What | How | Where |
|------|-----|-------|
| **Reader Personas** | Define who reads your output -- reading time, priorities, pet peeves | `examples/personas/` |
| **Scoring Anchors** | Calibrate what fail / borderline / pass looks like for YOUR context | `examples/anchors/` |
| **Format Rules** | Add dimension rules for specific output formats | `skill/` directory |

See [Customization Guide](docs/customization.md) for details.

## Formats Supported

| Format | Review Dimensions |
|--------|-------------------|
| Email / DOCX / PDF | Hook, Structure, Evidence, Actionability, Conciseness |
| PPTX | Above + Image Quality, Anti-AI Layout |
| Design / Mockup | Physics, Brand Compliance, IP Accuracy, Composition, Purpose Fit |

Each format loads its own rule file automatically. PPTX and Design rules
are included out of the box.

## Born in Production

Most AI quality tools target developers and CI pipelines
([DeepEval](https://github.com/confident-ai/deepeval),
[Guardrails AI](https://github.com/guardrails-ai/guardrails),
[NeMo Guardrails](https://github.com/NVIDIA/NeMo-Guardrails)).
None of them review an executive email, a board deck, or a marketing report.

This skill was built for that gap -- 3 months, 5+ retail brands, dozens
of executive deliverables. It caught a misspelled venue name 2 hours
before a CEO presentation. Layer 0 flagged it in seconds by
cross-referencing the knowledge base.

In the 4 major tools we benchmarked, none combine independent agent review
+ reader personas + calibrated scoring anchors + a ratchet mechanism.
This is a verifiable positioning gap, not a category claim.

**Methodology grounded in**:
- Adversarial content review (Fu Sheng) -- opposition improves quality
- [AutoResearch Ratchet Loop](https://fortune.com/2026/03/17/andrej-karpathy-loop-autonomous-ai-agents-future/) (Karpathy, 2026) -- each iteration must measurably improve, never regress

## Architecture

```
+--------------------------------------------------+
|  Any Claude Code skill that produces output       |
|  (email writer, PPTX creator, report builder)     |
+------------------------+-------------------------+
                         v
+--------------------------------------------------+
|            Ratchet Review (this skill)            |
|                                                   |
|  Ground Truth -> Subagent Critic -> Judge          |
|  -> Ratchet (max 3 rounds) -> Learning Loop       |
+------------------------+-------------------------+
                         v
              Reviewed output
              (score >= 8.0 or flagged for human review)
```

See [Architecture Deep Dive](docs/architecture.md) for the full specification.

## FAQ

**Q: Does this work with other AI tools (ChatGPT, Copilot, Cursor)?**
A: No. This is a Claude Code skill that uses Claude's Agent tool for the
independent Critic. It's designed for the Claude Code ecosystem.

**Q: Will this slow down my workflow?**
A: A full review cycle takes 30-60 seconds. Skip it for drafts -- the skill
has built-in exclusion rules (< 50 words, raw data, code, internal notes).

**Q: Can I use this for code review?**
A: Not designed for it. This targets natural-language deliverables (reports,
emails, presentations, designs). Code has better dedicated tools.

**Q: What if it keeps failing after 3 rounds?**
A: The skill stops automatically, outputs the best version so far, and
gives you an unresolved issues list. You decide what to ship.

**Q: Can I add my own review dimensions?**
A: Yes. Add format-specific rule files in `skill/` following the pattern
of `PPTX-RULES.md` or `DESIGN-RULES.md`.

## Contributing

PRs welcome. Especially:

- New format rule modules (e.g., newsletter, social media post, video script)
- Reader persona templates for different industries
- Translations of trigger keywords
- Scoring anchor examples from your domain
- Bug reports and improvement suggestions

## License

[MIT](LICENSE)
