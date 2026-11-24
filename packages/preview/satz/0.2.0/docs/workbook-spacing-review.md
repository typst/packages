# Workbook spacing review

Historical diagnosis of an earlier conversion. For the current shared fixes,
71-page report verification and remaining gaps, see the
[20 October parity audit](report-parity-audit.md). Measurements below describe
the earlier state and must not be read as final parity evidence.

The workbook migration exposed a document-style regression despite the shared
class already containing the native heading/paragraph fixes. The supplied port
uses a vendored satz snapshot and overrides body, heading, contents, callout,
card, table, and caption spacing independently. A successful compilation and a
content-preservation audit did not establish visual parity with LaTeX.

## Reproduced causes

- The initial supplied PDF compressed contents entries to roughly 8.4pt baseline
  distances at a 10pt font size. The ZIP snapshot and the live working directory
  represented different iterations, so they must not be treated as identical
  references. The live project changed again during this review.
- Paragraph spacing is not an extra amount added to line leading. At 11pt STIX
  Two Text with `leading: 0.75em`, ordinary lines have a 15.477pt baseline gap;
  paragraphs with `spacing: 0.52em` have only 12.947pt between baselines. Even
  `0.7em` produces 14.927pt, tighter than ordinary lines. The workbook's local
  overrides therefore removed the paragraph separation expected from KOMA.
- Local heading gaps of `0.45em` and `0.35em` superseded satz's more generous
  native heading settings. The same compression appeared independently in
  callouts and the chronological analysis cards.
- Equal leading does not imply equal page density. The port's text area was
  wider and substantially taller than the KOMA text area. More text per page
  changed wrapping, page rhythm, and the apparent density.
- Relative raw-text scaling compounded with Typst's existing raw-text scaling:
  a local `0.82em` show-set rule produced 7.216pt code in an 11pt paragraph.
  An absolute 9.02pt size produced the intended 82% scale. Compact table/card
  contexts need their own explicit code sizes rather than repeated em scaling.

The independent, public reproduction is:

```sh
python3 examples/latex-parity/check_paragraph_rhythm.py
```

## Reference-based revision

A separate workbook copy was revised without changing the original LaTeX,
other chat's project, scientific prose, tables, or result plots. The KOMA log
provided the text-area geometry; representative PDF passages provided measured
baseline distances. The review edition uses the shared contents configuration
being developed alongside the migration rather than a second hard-coded
contents renderer. Its precise style values remain in that document's
`style.typ` rather than becoming universal satz defaults.

| Representative measurement | LaTeX | Revised Typst |
| --- | ---: | ---: |
| Contents row baselines | 15.446pt | 15.477pt |
| Gap before the next main contents group | 26.355pt | 26.477pt |
| Ordinary prose baselines | 15.446pt | 15.477pt |
| Paragraph break baselines | 23.169pt | 23.177pt |
| Tested subsection heading to first prose baseline | 30.910pt | 31.127pt |

These measurements describe selected passages, not every context in the report.
The revised document has 69 pages against the reference's 71; equal page counts
are not an acceptance criterion. A rendered side-by-side estimator passage is
more informative than page count or a single leading measurement.

The existing content checks pass: 65 source tables, 2,298 decimal values, seven
native diagrams, thirteen plots, caption counts, bounds, and numbered footers.
104 prose/source/figure files are byte-identical to the prior port. Diagram
style changes affect leading only. The footer check was made independent of the
number of contents pages and adjusted to the reference's larger bottom margin.
The scientific interpretation was not reviewed or rewritten.

## Implications for satz

Keep native heading flow and explicit document-level control, but avoid letting
independent compact overrides silently undo an intended report rhythm. A
reusable report typography preset should specify prose, paragraphs, lists,
headings, contents, callouts, and captions together, with a representative
rendered specimen. It should be tested across fonts and several document types
before its values become defaults. Matching this workbook's KOMA geometry and
spacing does not establish general KOMA parity.

The conversion still needs editorial layout work around large figures, long
callout continuations, table breaks, equation numbering, and running-header
conventions. The spacing revision is a review draft, not a completed migration.
No new package dependency is needed for the spacing corrections.
