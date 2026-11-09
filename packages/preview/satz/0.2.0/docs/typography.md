# Heading, paragraph and callout rhythm

Satz defaults to a shared KOMA-Script heading rhythm, calculated from the actual
font metrics. Headings stay attached to following content, wrap with hanging
indents and suppress extra before-spacing when consecutive. Use configuration
rather than manual `v()` around individual headings. See the
[shared spacing policy](heading-spacing.md) for formulas and compatibility.

## Shared defaults and document calibration

| Level | Size | KOMA before / after skip |
| --- | --- | --- |
| 1 | 14pt | 3.5ex / 2.3ex |
| 2 | 12pt | 3.25ex / 1.5ex |
| 3 | 11pt | 3.25ex / 1.5ex |
| 4 | 11pt | 3.25ex / 0 (block heading) |

These are baseline skips, translated to Typst block gaps rather than copied
literally. `headings.h1-above` through `h4-below` accept explicit block-gap
lengths; `auto` selects the measured KOMA value. Set `headings.spacing: "native"`
to opt out of the renderer. Template-specific and document-specific lengths
continue to override the shared policy.

There is no universal correct number of points. Inside a flowing text passage,
the heading should normally be closer to the text it introduces than to the
previous passage. Smaller headings generally need smaller absolute gaps.
Chapter openings, consecutive headings, lists, equations and page starts
require separate inspection.

`headings.h1-pagebreak` defaults to `false`. Set it to `true` when every
top-level heading must begin on a fresh page. That preserves the chapter-opening
convention used by report classes such as `scrreprt`, but it can leave a short
ending on the previous page when Typst's wrapping differs from another engine.
Set it to `false` for continuous reports where flowing into the next chapter is
preferable to that extra white space; heading stickiness still keeps a
heading with its following content.

```typst
#show: report.with(config: (headings: (h1-pagebreak: false)))
```

The research report's STIX Two Text calibration is **document configuration**,
not a replacement for the shared defaults:

| Heading | Size | Configured above / below | Measured visible gap before / after |
| --- | --- | --- | --- |
| Section (level 2) | 14.35pt | 2.6em / 1.95em | about 33.2pt / 23.4pt |
| Subsection (level 3) | 11.95pt | 2.75em / 2em | about 29.0pt / 19.9pt |

The corresponding LaTeX reference gaps were about 32.7/23.2pt and 28.7/19.8pt.
The smaller subsection font resolves `em` to fewer points, so its absolute gaps
decrease even though its numeric `em` value is larger. Configured block gaps
and visible ink-to-ink gaps differ because font edges and adjacent content
also affect the measurement. These are selected same-page measurements, not
a promise that every heading in either document has identical geometry.

## Why the line spacing became cramped

Typst's `par.leading` measures the gap between line edges. `par.spacing`
controls paragraph separation; it is not an extra amount added to leading.
A paragraph spacing smaller than leading can therefore make paragraph
boundaries tighter than ordinary lines.

At 11pt STIX Two Text with `leading: 0.75em`, the report's ordinary baseline
distance is about 15.48pt, close to the LaTeX reference's 15.45pt. That does not
protect a callout with its own `spacing: 0.4em`, a smaller code-only line, or a
tight list. Those contexts need to be checked separately.

The public `callout` helper inherits body size, font and leading, sets paragraph
spacing to 1em, and uses loose list/enum spacing of 1.2em. Smaller raw-only
lines retain the surrounding body's measured cap-height. The block breaks
within the normal text area and keeps the ordinary footer clear.

```typst
#import "@local/satz:0.2.0": report, callout
#show: report.with(config: (toc: (depth: 0),))

#callout(title: [Main finding])[
  Explain the result here. Long content can continue onto the next page.
]
```

Component configuration is explicit: pass `config:` to `callout` to share a
document palette or customize `callouts.inset`, `radius`, `stroke`,
`paragraph-spacing`, `list-spacing` and `title-below`. Optional `title:` uses
the component palette and stays with following content. `fill:` and `stroke:` allow individual
overrides. Arbitrary headings, custom show rules or unbreakable objects inside
a box still need visual review.

## Verification

Run `python3 examples/latex-parity/check_typography.py` and
`python3 examples/latex-parity/check_callouts.py`. The first checks the KOMA default and native opt-out,
page boundaries and all four heading levels; the second checks body/code
paragraphs at 11pt and 13pt, content preservation and footer clearance.

Use [Typst's paragraph reference](https://typst.app/docs/reference/model/par/)
and [block reference](https://typst.app/docs/reference/layout/block/) for the
underlying spacing semantics. Always render the consuming document and compare
each changed component and affected page with the reference PDF.
