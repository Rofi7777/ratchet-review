# PPTX Review Rules

> Auto-loaded by the core engine when reviewing PPTX files.
> Adds two independent dimensions on top of text dimensions 1-5.

## Dimension 6: Image Quality (Weight: 15%)

**Core question**: Does every image meaningfully improve communication without breaking readability?

### 6a. Layout Conflict Detection (Hard Fail)

| Red Line | Consequence | Detection Method |
|----------|------------|-----------------|
| Image overlaps text (overlap > 0.3 sq.in) | **FAIL, reject immediately** | python-pptx bounding box overlap calculation |
| TINY image (< 5% of slide area) | -5 per occurrence | `(w * h) / slide_area < 5%` |
| Image extends beyond slide boundary | -3 per occurrence | `left + width > slide_width` |

### 6b. Placement Quality

| Rule | Deduction |
|------|-----------|
| All images in same quadrant (>60% same position) | -3 |
| Irrelevant decorative images | -2 per occurrence |
| Forcing images on data-heavy slides | -2 per occurrence |
| Concept images missing captions | -1 per occurrence |

### 6c. Page Type -> Image Strategy

| Page Type | Image Strategy | Layout |
|-----------|---------------|--------|
| Section Divider | Full-bleed background + overlay | z-order bottom, overlay 65-75% |
| Visual showcase (<= 60 words) | Left text, right image 60/40 | Text right <= 7.0", image left >= 7.3" |
| Content + data (60-120 words) | Right-side accent 10-20% | Must not overlap text_frame |
| Data-dense (>120 words) | **No image** | Data is king |
| Multi-column (3+ side by side) | **No image** | Columns already fill the space |
| 2-column layout | Optional bottom strip (<2" tall) | top > lowest text bottom + 0.2" |

### 6d. Three-Step Build Method

```
STEP 1 (before build): Label each slide [BG] / [L-R] / [STRIP] / [CLEAN]
STEP 2 (during build): Build per label. [CLEAN] slides get no images.
STEP 3 (after build): Run overlap detection. Overlap > 0.3 = HARD FAIL.
```

## Dimension 7: Anti-AI Layout (Weight: 15%)

**Core question**: Does the presentation look like a human designer made it?

### 7 Rules

| # | Rule | Deduction | Detection Method |
|---|------|-----------|-----------------|
| 1 | Font size variation on page < 2x | -3/slide | Scan font_size, max/min ratio |
| 2 | No focal element >= 48pt | -2/slide | Every slide needs 1 visual anchor |
| 3 | No images touch edges | -3 overall | >= 30% content slides should bleed to edge |
| 4 | 3+ consecutive slides with same layout | -3/streak | Page type sequence check |
| 5 | Single slide > 5 visual elements | -2/slide (>7 = -3) | Header/page numbers excluded, KPI groups count as 1 |
| 6 | White space < 25% | -2/slide (<15% = -3) | Area calculation |
| 7 | Unprocessed images placed directly | -1/each | Should add semi-transparent overlay (product photos/logos exempt) |

### PPTX Critic Output Block

```
[PPTX Image Quality]
- Overlap detection: X slides PASS / X slides FAIL
- TINY images: X found
- Image strategy: [BG X / L-R X / STRIP X / CLEAN X]

[Anti-AI Layout]
- Visual anchors: X/Y slides have >= 48pt [pass/fail]
- Image bleed: X% touch edges (>= 30%?) [pass/fail]
- Page rhythm: [layout sequence] [pass/fail]
- Element density: max X per slide [pass/fail]
- White space: minimum X% [pass/fail]
- Anti-AI score: X/7 rules passing
```

### Recommended Font Ranges

Customize these for your organization:

- Slide title: 20-24pt
- Subtitle / section: 13-16pt
- Body text: 10-13pt
- Footnotes / benchmarks: 9-10pt
- Font family: Calibri (primary) / Arial (fallback)
