# Design / Visual Asset Review Rules

> Auto-loaded by the core engine when reviewing images, mockups, posters,
> or social media assets. Switches to the V1-V5 framework (replaces text dimensions 1-5).

**Pre-review**: Read the image (Read tool) + load your brand guidelines (if available).

## V1: Physics — Physical Logic (25%)

**Core question**: Does the scene obey real-world physics?

| Check | Deduction |
|-------|-----------|
| Character/object floating in air (not grounded) | -4 |
| Perspective error (closer objects appear smaller) | -3 |
| Contradictory light/shadow direction | -2 |
| Obviously wrong proportions | -2 |
| Reflection/shadow mismatch | -1 |

**Known rule**: Do not paste 2D images onto mockups with PIL/Pillow.
When 3D characters are needed, generate "physical 3D fiberglass sculpture, STANDING ON THE GROUND" using image generation tools.

## V2: Brand Compliance (25%)

**Core question**: Does it strictly follow brand VI guidelines?

Customize this section for your brand. Example checklist:

| Check | Deduction |
|-------|-----------|
| Logo placement violates brand guidelines | -4 |
| Logo proportion/quality incorrect | -3 |
| Brand colors wrong | -2 |
| Font doesn't match brand spec | -1 |

**Template for your brand**:
```yaml
brand_name: [Your Brand]
primary_color: [hex]
secondary_color: [hex]
logo_position: [e.g., "top-left or centered, never bottom"]
logo_min_size: [e.g., "12-15% of width"]
font_primary: [e.g., "Helvetica Neue"]
font_secondary: [e.g., "Arial"]
co_branding_rule: [e.g., "[Brand A] x [Brand B], logos equal height"]
```

## V3: IP / Asset Accuracy (25%)

**Core question**: Are characters, products, and assets represented correctly?

**Asset source priority**:
1. Official assets (from brand team / shared drive)
2. Solid color background + typography (when no suitable asset exists)
3. **Prohibited**: AI-generated imitation of copyrighted characters/IP

| Check | Deduction |
|-------|-----------|
| Using AI-generated imitation of copyrighted IP | -5 (fatal) |
| Character features incorrect | -3 |
| Series/collection confusion | -2 |

## V4: Composition (15%)

| Check | Deduction |
|-------|-----------|
| No clear visual focal point | -2 |
| Text unreadable (background eating text) | -3 |
| Overly crowded layout | -2 |
| Key info (date/location) not prominent | -2 |

## V5: Purpose Fit (10%)

| Use Case | Review Focus |
|----------|-------------|
| Business proposal (for executives) | Professionalism, sense of space/venue |
| Social media asset (FB/IG/TikTok) | Dimensions, CTA, thumb-stop factor |
| Print materials (banners/flags) | Print resolution, far-distance readability |
| Mockup / concept render | Can a non-designer understand the concept? |

## Design Critic Output Format

```
Design Critic Report

[Physics] [specific issues]
[Brand Compliance] [specific issues, citing VI guidelines]
[IP Accuracy] [specific issues, comparing to official assets]
[Composition] [specific issues]
[Purpose Fit] [specific issues]

Summary: [1-2 most critical issues]
```

## Design Judge Scoring Format

```
| Dimension | Score | Weight | Weighted |
|-----------|-------|--------|----------|
| Physics          | X/10 | 25% | X.X |
| Brand Compliance | X/10 | 25% | X.X |
| IP Accuracy      | X/10 | 25% | X.X |
| Composition      | X/10 | 15% | X.X |
| Purpose Fit      | X/10 | 10% | X.X |
| **Total**        |      |     | **X.X** |

Verdict: PASS (>= 8) / REVISE (< 8)
```
