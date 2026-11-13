# Typography, letter coverage, and authoring priorities

## Assessment

Satz should make ordinary writing quick and produce a coherent document without
requiring authors to tune each heading. Current comparisons establish selected
behaviors, not complete KOMA-Script parity. Reports are the primary foundation
for theses, assignments, and general documents; journals are the second focus
and a consuming-document check. Letter parity is secondary. Further
template-file/interface work is deferred for discussion.

## Dependency opportunities

| Roadmap item | Candidate | Current decision |
|---|---|---|
| Running headers | Hydra | Integrated and checked against a configured 12-page KOMA-Script fixture. |
| Abbreviations/glossary | Glossarium | Integrated as an optional namespace; five-page example checks first/repeated use, links, unused terms, and coexistence with figures/captions. |
| API manual | Tidy | Next small tooling trial; adapt doc-comment syntax and generate a manual. Keep it outside ordinary document compilation. |
| Scientific tables | Native Typst; Zero/Pillar for a later alignment trial | `scientific-table` now supplies rules and repeated headings. Compare decimal/uncertainty alignment and authoring effort before adding an alignment dependency. |
| Margin notes | Marginalia | Relevant to the commentary reference, but test collisions, binding, and page breaks before promising support. |
| Page proportions | Tschich | Opt-in layout candidate, not a substitute for coordinated heading/paragraph spacing or KOMA type-area calculations. |
| Figures and technical diagrams | Fletcher; subfigures deferred | Subpar work is shelved at the user's request. Test a diagram dependency only when a real document justifies it. |
| Ordinary heading spacing | Native Typst | No new package needed to start. Satz needs to coordinate the controls it already uses. |

Versions, licenses, and source links are in the
[initial review](package-research.md) and [additional review](additional-packages.md).
The broader package survey is complete; each integration is a separate task.

## Heading and paragraph rhythm: first increment completed

The original level-one heading inserted an internal `v(0.5em)` and all four
levels wrapped the native heading. The specimen measured a 7pt h1 page-start
offset relative to equivalent native styling. The first pass removes these
wrappers for reports, styles native headings with show-set rules, and increases
default below-spacing to 1em/1em/0.9em/0.75em. Above-spacing remains native by
default. Commit `08c4fb4` adds opt-in `h1-above` through `h4-above` overrides,
omitting them when `auto` to preserve native behavior. See the
[typography guide](typography.md) for calibration and spacing semantics.

Paragraph spacing and first-line indentation now have shared config keys.
Their explicit defaults retain the prior native paragraph behavior. The
specimen checks that an 8pt spacing override changes the measured gap by 8pt,
and that indentation is suppressed after headings. Eight bounded page-edge
cases pass before and after the change; no orphan-heading defect was reproduced.

Typst has native [paragraph leading/spacing](https://typst.app/docs/reference/model/par/)
and [block above/below spacing and stickiness](https://typst.app/docs/reference/layout/block/).
Adjacent block gaps collapse; leading is not a LaTeX baseline multiplier. A
package cannot pick a coherent document rhythm for us without design choices.

The compact paired specimen contains all four heading levels, ordinary
paragraphs, two consecutive headings, a multiline heading, a list and equation
after headings, with separate page-boundary probes. It compares satz, plain
Typst, and KOMA-Script using comparable fonts and content. The new report matches
the native control's heading geometry; KOMA-Script remains a visual reference,
not a claim of identical line breaking or spacing. See
`examples/latex-parity/check_typography.py`. Header, glossary, caption, journal,
and existing one-page comparisons were also checked.

Acceptance criteria:

- Headings stay attached to following content and do not leave an isolated
  heading at a page bottom.
- Page starts, consecutive headings, and multiline headings retain a clear
  hierarchy without accidental extra gaps.
- Paragraph separation, first-line indentation, and heading spacing work as one
  policy; do not merely add more independent knobs.
- Ordinary authoring needs no manual `v()` calls. Preserve existing overrides
  where practical and document any intentional default changes.
- Recompile the report, journal, and letter consumers and inspect their pages.
  Keep the Hydra checks green while changing heading layout.

## What the letter comparison establishes

| Capability | Current evidence |
|---|---|
| Basic one-page letter | Recreated one official `scrlttr2` source/PDF with public configuration plus a local date workaround. |
| Sender/recipient, subject, contact fields, reference fields | Implemented in the template; not comprehensively compared against KOMA letter examples. |
| Language and postal/digital switches | German/English labels and low-level visibility switches exist. Digital setup currently requires several options. |
| Named enclosures | A missing implementation was reproduced and fixed: `anlagenverzeichnis` now prints without attempting to open its strings as files. |
| Date and address typography | Differences remain: full-size unlabeled date needs a workaround, recipient text is fixed at 11pt, and address/body horizontal offsets differ. |
| Physical envelope geometry | Not validated. Flowing sender content and gaps influence address position; source comments and a visually similar page do not establish envelope fit. |
| Multi-page continuation | A page-number footer exists, but a rich two-page comparison and a deliberate continuation-page layout remain unverified. |
| Closing/signature | A signature-line helper exists. A unified closing/signature block that reliably stays together across page breaks has not been demonstrated. |
| Broader correspondence | Copy-recipient/PS helpers, reusable letterhead profiles, and alternate postal layouts are not established by the current comparison. |

Do not describe the current letter as a complete `scrlttr2` replacement or
claim verified DIN compliance. Next, adapt a richer official letter with
reference fields and enclosures, then extend it to two pages. Test the everyday
workflow before deciding which extra KOMA features are useful to support.

## Usability target

The README now contains a complete one-file letter. Users already need only an
import, a show rule with their details, and their text; they do not need to copy
the implementation or maintain a separate config file. That is the current
starting point, not the finished interface.

For the next letter API pass, test two short tasks: write a postal letter and
write a digital letter. Count required options and remove unnecessary decisions.
Keep advanced layout controls available without making them part of the quick
start. The English `letter` alias still accepts German field names; resolve
that inconsistency deliberately while preserving existing documents. Opening,
closing, signatures, and reusable sender details deserve a coherent interface
rather than a longer starter file. Defer a new scaffolder or template system
until that interface discussion.
