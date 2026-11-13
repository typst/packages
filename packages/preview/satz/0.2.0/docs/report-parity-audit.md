# Research report parity audit — 20 October 2026

**Visually reviewed, not 1:1 parity.** The reference is the 71-page decoding/RSA
report using LaTeX scrreprt. The earlier Typst port had 70 pages; the current
continuous-chapter-flow version has 69. Both PDFs were rendered to PNGs and
inspected visually across the full document, including chapter openings, split
boxes, equations, diagrams, captions and both appendices. The latest flow change
was additionally rendered and checked on the affected chapter transitions.
No Python layout analysis was used for this review. Text extraction was used
only to index caption identities; it does not substitute for image inspection.
Research sources, PDFs and participant data remain outside this repository.

## Shared fixes incorporated into Satz

| Area | Implemented behavior |
| --- | --- |
| Heading rhythm | Native heading flow, configurable above/below spacing at four levels, ragged-right unhyphenated headings, opt-in chapter page breaks. |
| Callouts | Inherited body leading, deliberate paragraph/list spacing, body-height safeguard for small code-only lines, attached colored titles, left-aligned reading text even inside centered figures, normal page fragmentation. |
| Scientific tables | Strong top/bottom rules and thin header rules, repeatable native headings, configurable font/padding, ragged-right cells, shared figure/caption for related panels. |
| Table figures | Opt-in scientific-tables show rule sets top captions and explicit breakability without replacing native labels/references. |
| Captions | Configurable alignment and label weight, preserving numbering and short-list/long-caption behavior. |
| Numbering | Chapter-numbering scopes capture fixed figure/table/equation prefixes, including cross-appendix and backward references. |
| References | Internal references receive the configured color; bibliography citations retain their separate styling. |
| Typefaces | Independent math-font and mono-font configuration, with native defaults retained through auto. |

See [typography](typography.md), [scientific tables](scientific-tables.md),
[chapter numbering](chapter-numbering.md), and the [unreleased changelog](../CHANGELOG.md).

## Corrections in the real workbook

- STIX Two Text, STIX Two Math and Fira Code now match the source choices.
  Earlier matching prose fonts did not ensure matching math fonts.
- All 14 explanatory boxes use the shared callout helper and title API.
- Related test/CI panels share captions and restored labels. The document retains
  20 main-text native tables and 45 appendix native tables, grouped into
  26 captioned table figures, alongside 20 image figures.
- Fifty missing table verdicts and eight missing prose verdicts were copied
  from the LaTeX source. They were not inferred from statistical values.
- All 45 captions visible in the reference remain represented. Figure 1.1's
  caption is additionally visible: the reference clipped it below the page.
- The chronology map is rebuilt as eleven readable native cards that flow
  between pages. Other diagram assets remain vector PDFs.
- Captions, explicit column widths, spanning panel titles and dense-table
  padding are calibrated by table family. The 35-row results table fits on
  one page with all mean/SEM values and verdicts.
- Appendix headings precede their actual tables rather than collecting ahead
  of deferred floats. Forward/backward references use the correct chapter or
  appendix prefix. Callout equations stay unnumbered where the source is.
- The cover is calibrated against the reference. Contents entries are grouped
  by chapter; two-em chapter-group spacing keeps chapter 9 with its entries.
  This is document calibration, not a general guarantee against orphaned
  custom-outline groups.
- Front matter has no visible folios; body numbering begins at 1. This is a
  deliberate correction to the reference's visible front-matter numbering.

The report carries a vendored snapshot. Only relevant shared files were adopted;
ongoing outline/theme/list edits were not silently copied into the document.
Source, compiled output, comparison images and backups live together in its
permanent typst directory under ncwm-dcm.

## Remaining differences and next work

| Difference | Evidence and next step |
| --- | --- |
| Float distribution | Some figures move to different pages than in LaTeX, and related tables may sit closer to the discussion. This follows each engine's layout decisions; the difference is acceptable when figures remain readable, correctly captioned and referenced. Compare by caption identity when checking content. |
| Sparse chapter endings | Resolved in the current workbook by setting `headings.h1-pagebreak: false`. Chapter 6 now follows the short ending on printed page 23, and Chapter 7 follows the Chapter 6 ending on page 29; the affected pages were rendered and visually checked. This improves page density but gives up KOMA's fresh-page chapter openings. Set the option back to `true` when that convention matters more than the extra white space. This is document-level calibration, not a changed package default. |
| Line wrapping and page count | Paragraphs, long headings and table labels wrap differently despite matched fonts and calibrated spacing. Those differences are acceptable if reading remains clear and no content is lost. The current 70/71 page difference is not proof of a content problem or exact parity. |
| Contents | Chapter grouping is much closer; long subsection wrapping, color and running-header treatment still differ from LaTeX. The custom outline needs broader testing before generalizing its policy. |
| Diagram typography | Six diagrams remain existing vector assets. Their embedded labels do not inherit document fonts; native reconstruction should be justified individually. |
| Coverage beyond this specimen | Report and journal consumers compile, but this visual review does not establish journal, two-column article, letter or full KOMA compatibility. |

No clipping into page numbers or recurrence of the original cramped callout
paragraph boundaries was observed in the final images. This is a visual finding,
not a proof for arbitrary future document content.

## Reproduce and verify

Compile the real workbook from its typst directory, then render it and the
reference with Poppler's pdftoppm. Retain the page PNGs and inspect them visually;
compare shifted figures/tables by their caption identities. The saved review
folder contains paired contact sheets and original page images.

The committed package was exported into an isolated directory. Seven focused
fixtures (callouts, scientific tables, table flow, caption styles, chapter
numbering, reference colors and text/math/code fonts), plus report and journal
consumers, all compiled successfully. Consumer imports were redirected to that
snapshot's lib.typ so the check exercised these changes rather than the old
published package. The report example requests unavailable EB Garamond and
falls back; the actual research workbook uses installed STIX fonts.

The isolated check caught and corrected two caption configuration groups nested
at the wrong level in an earlier commit. Legacy numeric PDF-check scripts remain
available, but their old workbook fragment/page-count expectations do not describe
this updated native chronology map and should not be cited as current evidence.

Native Typst provides the needed table rules, repeated headings and breakable
blocks, so these fixes require no extra dependencies. Hydra and Glossarium address
separate concerns. Subfigure work remains shelved. At this audit checkpoint the
manifest was 0.1.1; the repository later identified an unpublished 0.2.0
candidate. This audit itself did not tag, release or publish the package.
