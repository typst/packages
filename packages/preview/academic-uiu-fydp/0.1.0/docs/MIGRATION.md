# LaTeX conversion notes

The conversion followed the supplied `.tex` sources. The original bundled PDF
was older and differed in title text, chapter sections, and front matter.
The legacy LaTeX files, auxiliary outputs, and reference PDF have been removed;
this repository now contains the Typst implementation. The table below records
the historical file mapping. The original template remains linked in [NOTICE](../NOTICE).

| Original file | Typst counterpart |
| --- | --- |
| `fydp.tex` | `lib.typ`, root `main.typ`, `template/content.typ` |
| `0.0.title.tex` | `fydp-report` title page, `template/project.typ` |
| `0.1.abstract.tex` | `template/front-matter/abstract.typ` |
| `0.2.ack.tex` | `template/front-matter/acknowledgements.typ` |
| `0.3.pub.tex` | `template/front-matter/publications.typ` |
| `1.intro.tex` | `template/chapters/01-introduction.typ` |
| `2.back.tex` | `template/chapters/02-background.typ` |
| `3.design.tex` | `template/chapters/03-project-design.typ` |
| `4.implementation.tex` | `template/chapters/04-implementation.typ` |
| `5.sic.tex` | `template/chapters/05-standards.typ` |
| `6.conclusion.tex` | `template/chapters/06-conclusion.typ` |
| `fydp.bib` | `template/references.bib` |

## Preserved behavior

A4 paper, 11 pt text, 3 cm margins, an unnumbered cover, Roman front matter,
Arabic body pages, chapter numbering, automatic contents/figure/table lists,
numeric citations, and both engineering mapping tables are supported. The chapter
and section structure follows the `.tex` files, including gap analysis, project
planning, task allocation, constraints, and complex engineering mappings.

## Deliberate changes

- New Computer Modern replaces LaTeX's default Computer Modern. Typst line
  spacing approximates `onehalfspacing`; line and page breaks differ.
- Cover metadata supports multiple students, explicit dates, and optional supervisors.
- Publications are disabled until explicitly enabled, consistent with the original
  template's optional designation.
- Draft text has been rewritten as clearer guidance. An example context diagram
  and equation demonstrate cross-references.
- Engineering mapping checkmarks are blank dashes, so the starter makes no claims
  about a project's compliance. The apparent “Dept of Knowledge” typo is corrected
  to “Depth of knowledge”; current rubric terminology still needs educator review.
- The bibliography uses Typst's built-in IEEE numeric style instead of `unsrt`.
- Running headers display the chapter on continuation pages. The LaTeX template's
  separate section mark is not reproduced.
- The title is logo-free by default. The local entry point accepts an optional
  user-supplied logo; local assets are not distributed.
- FYDP-1 can omit implementation while updating all chapter numbers and references.

LaTeX packages loaded without an active example, such as `algorithm2e`, `makeidx`,
and `longtable`, do not map to extra Typst dependencies. Typst tables can span
pages. A custom algorithm layout or index is outside this starter's implemented
features. Commented-out dedication, appendix, and index pages are not generated.
