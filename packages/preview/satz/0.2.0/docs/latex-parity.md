# Making satz a practical LaTeX replacement

## Direction

The aim is to let authors import satz and write a complete, well-composed
document with little layout work. Satz should supply typographic defaults,
document structure, and integrated access to useful Typst packages.

Use LaTeX documents as design references and acceptance examples. Here,
“conversion” means recreating their content and document structure in Typst,
then improving satz until that recreation needs little custom styling. An
automatic LaTeX source converter is a separate project.

This is a proposed development sequence, not a claim of existing parity.
The [package review](package-research.md) records candidate dependencies.

## What the current implementation leaves to authors

- `defaults.typ` exposes line/paragraph spacing and a boolean first-line-indent
  switch; `document-class()` applies those shared paragraph settings.
- Heading rules in `class.typ` wrap headings in blocks, configure spacing below,
  and add an explicit `v(0.5em)` inside the level-one block. Evaluate the combined
  behavior at page starts, between consecutive headings, and after paragraphs.
  Above-spacing settings were deliberately removed in commit `97f7809`; establish
  the intended behavior before changing that choice.
- Running headers use custom chapter/section state. A chapter update does not
  reset section state. Header selection and chapter-opening suppression need
  explicit cases rather than assuming that a header at page start sees the
  desired heading. These are inspection findings, not reproduced bug reports.

Typst already supplies the underlying spacing mechanisms. Its `par.leading`
is the gap between line edges, not a LaTeX-style baseline multiplier; baseline
distance also depends on text edges. Paragraph spacing and adjacent block spacing
interact, and adjacent block gaps collapse rather than simply add. Satz should
make those choices coherent for authors. See the official
[paragraph](https://typst.app/docs/reference/model/par/) and
[block](https://typst.app/docs/reference/layout/block/) documentation.

## Build a small reference collection

Start with three paired documents; each pair has identical content and a written
list of expected behaviors:

| Pair | LaTeX reference | What it exercises |
|---|---|---|
| Ordinary document | KOMA-Script `scrartcl` | Paragraph rhythm, heading levels, lists, quotation, footnotes, table, equation, caption |
| Report/thesis extract | KOMA-Script `scrreprt` or `scrbook` with `scrlayer-scrpage` | Chapter openings, two-sided pages, running headers, front matter, TOC/LoF/LoT, references, bibliography |
| Letter | KOMA-Script `scrlttr2` | Address window, subject, closing, signature, multi-page continuation |

The [KOMA-Script project](https://ctan.org/pkg/koma-script) is the primary
reference because satz already takes inspiration from it. The official
[book examples](https://ctan.org/pkg/koma-script-examples) provide additional
source material under LPPL 1.3c. Prefer original neutral fixture text; record
source, version, license, and any modifications before redistributing outside
examples. Use existing personal documents locally without publishing their data.

For each pair:

1. Write and inspect the LaTeX reference with deliberate typography. Record the
   engine, class/packages, fonts, paper, and relevant options.
2. Recreate it using public satz functions and minimal configuration. Record
   every workaround in the Typst document as a candidate package improvement.
3. Render both PDFs at the same scale. Inspect whole spreads and close views of
   paragraphs, heading transitions, tables, and captions. Extract text positions
   when checking baseline distances and header/footer alignment.
4. Improve one shared behavior at a time; re-render the pair and an existing
   consuming document. Check other affected templates before committing.
5. Keep a short acceptance checklist with the sources. Track source and checks
   in Git; keep generated PDFs out of Git under the existing repository policy.

Judge readable spacing, hierarchy, usable line lengths, heading attachment,
correct headers, references, and authoring effort. Matching TeX's exact line
breaks and pagination is not a universal acceptance criterion. Inspect both a
normal example and boundary cases: long headings, consecutive headings, headings
near a page end, a chapter without sections, and page-counter resets.

## Dependencies and the public API

Welcome dependencies that remove substantial maintenance or supply a useful
capability. For each adoption, pin the version, check license and compiler
requirements, compile an integration example, and document the supported API.
Featured status alone does not establish compatibility.

- **Core implementation:** hide an implementation detail such as heading
  selection behind satz's header configuration.
- **Optional document features:** make glossary and special layout tools easy
  to access with documented setup and styling. “Optional” refers to author use;
  it does not promise that an import from `lib.typ` avoids loading dependencies.
- **Documentation tooling:** keep manual generation separate from ordinary
  document compilation.

Preserve an upstream namespace for rich APIs where a wrapper adds no value.
Add wrappers when satz supplies meaningful defaults or coordinates document
behavior. Avoid wildcard re-exports that create name collisions. One satz import
should offer a coherent supported workflow, with an escape hatch for ordinary
Typst and upstream functions.

## Suggested order

1. Establish the ordinary-document and report reference pairs, including header
   boundary cases, before changing defaults.
2. Trial Hydra against those header cases; retain satz's policy for alignment,
   chapter openings, excluded front matter, and custom headers.
3. Refine paragraph and heading rhythm from the reference comparisons.
4. Add a Glossarium integration example, then expose a supported glossary and
   abbreviation workflow once references, first use, and styling work together.
5. Generate the API manual with Tidy and adapt existing doc comments as needed.
6. Trial Tschich as a selectable page-layout preset and Meander in a dedicated
   flowing-layout example before exposing either broadly.

Expand to articles, journals, and contracts as those reference pairs reveal
requirements. Search non-featured packages by the next concrete capability gap
(for example tables, margin notes, or diagrams), then use the same adoption checks.
