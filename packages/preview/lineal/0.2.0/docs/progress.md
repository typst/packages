# Progress bars

`lineal-progress-bar` tracks logical slides. Title slides and frozen focus slides
do not advance it. Revealing an overlay leaves the current slide number unchanged.
Handout mode counts each logical slide once after collapsing its overlays.
Counted section cards contribute one slide; `section-numbered: false` cards contribute
none. Appendix slides do not increase the main-deck total.

```typst
#import "@preview/lineal:0.2.0": lineal-progress-bar

#lineal-progress-bar(variant: "exact", height: 3pt)
```

The variants describe the same deck with different segment detail:

| Variant | Segments, from left to right |
| --- | --- |
| `"broad"` | Completed slides, remaining slides |
| `"near"` | Previous sections, whole current section, future sections |
| `"exact"` | Previous sections, completed current slides, remaining current slides, future sections |

Completion includes the slide being displayed. On the first counted slide,
one slide is complete; on the final counted slide, every slide is complete.
A frozen focus page retains the preceding slide's progress.

## Section boundaries

For a non-empty main deck, let:

- `N` be the number of counted main-deck slides.
- `C` be the current counted slide, capped at `N` in appendices.
- `B` be the logical count before the current section starts.
- `E` be the logical count before the next section starts, or `N` in the last section.

The proportions are:

```text
broad = (C, N − C) / N
near  = (B, E − B, N − E) / N
exact = (B, C − B, E − C, N − E) / N
```

The model requires `0 ≤ B ≤ C ≤ E ≤ N`. Invalid finite bounds fail explicitly;
they are not silently clamped. Appendix counters are saturated at the main-deck
boundary before entering the model. An empty section can have zero width when
its card is unnumbered. Before the first section, opening slides form an
unsectioned range with `B = 0` and `E` at the first section's boundary.

When `N = 0`, the bar shows **0% complete** as a neutral remaining track. Its
data proportions are `(0, 1)` for broad, `(0, 1, 0)` for near and `(0, 0, 1, 0)`
for exact. No division by zero is performed.

Section membership comes from authored level-one headings in Touying's slide
preamble. It includes authored unoutlined sections but excludes headings created
inside slide content, native outlines or decorative titles. A section boundary
uses Touying's counter immediately before that page starts, so counted and frozen
section cards both produce the correct section proportions. Changing `slide-level`
does not turn deeper content headings into root sections.

## Explicit weights and styling

Supply `ratios` to render known proportions independently of slide counts:

```typst
#lineal-progress-bar(
  variant: "broad", ratios: (2, 3), height: 4pt,
  accent: rgb("375b9a"), remaining: rgb("dce4f0"),
)
```

Weights must be finite, non-negative numbers with a positive total. Their count
must match the variant: two, three or four. They do not need to add up to one.
Lineal divides by the largest weight before summing, so values such as
`(1e308, 1e308)` still produce equal halves. NaN, infinity, negative values and
all-zero weights fail explicit assertions. Zero-weight segments are omitted from
the drawing while the other segments retain their colours.

`height` must be a finite positive length; font-relative lengths such as `1em`
resolve against the surrounding text size. `accent` and `remaining` control the
active and remaining colours. The theme passes its configured colours to the
footer bar. Explicit weights are rendered even when the document has no slides.

## Implementation and checks

`src/navigation/progress-model.typ` owns the pure arithmetic and weight validation.
`src/progress.typ` adapts counters and authored headings, then draws the segments.
This adapter intentionally uses the pinned Touying 0.7.4 preamble markers; its
counter fixtures must pass before upgrading that dependency.

The tests assert data for counted and frozen sections, title pages, opening manual
slides, focus pages, regular and section overlays, unoutlined sections, native
outline headings, empty sections, appendices and custom slide levels. Pure tests
cover 31,878 valid boundary/variant combinations and large or subnormal weights.
Invalid-input fixtures verify ordered bounds, finite weights and bar dimensions.
Compile `tests/progress-render.typ` to inspect segment colours and geometry.
