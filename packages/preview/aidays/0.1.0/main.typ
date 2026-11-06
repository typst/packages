// Working example and author instructions adapted from example_paper.tex.
// typst compile main.typ
#import "@preview/aidays:0.1.0": *

#let accepted = sys.inputs.at("accepted", default: "true") == "true"
#show: aidays.with(
  title: [Submission and Formatting Instructions for \ Swiss AI Days],
  short-title: [Submission and Formatting Instructions for Swiss AI Days 2027],
  accepted: accepted,
  // In the web editor, choose an available Times-compatible face here.
  font: sys.inputs.at("font", default: "Times New Roman"),
  authors: (
    (
      name: "Firstname1 Lastname1",
      affiliations: ("yyy",),
      equal: true,
      email: "first1.last1@xxx.edu",
      corresponding: true,
    ),
    (
      name: "Firstname2 Lastname2",
      affiliations: ("yyy", "comp"),
      equal: true,
      email: "first2.last2@www.uk",
      corresponding: true,
    ),
    (name: "Firstname3 Lastname3", affiliations: ("comp",)),
    (name: "Firstname4 Lastname4", affiliations: ("sch",)),
    (name: "Firstname5 Lastname5", affiliations: ("yyy",)),
    (name: "Firstname6 Lastname6", affiliations: ("sch", "yyy", "comp")),
    (name: "Firstname7 Lastname7", affiliations: ("comp",)),
    (name: "Firstname8 Lastname8", affiliations: ("sch",)),
    (name: "Firstname9 Lastname9", affiliations: ("yyy", "comp")),
  ),
  affiliations: (
    yyy: [Department of XXX, University of YYY, Location, Country],
    comp: [Company Name, Location, Country],
    sch: [School of ZZZ, Institute of WWW, Location, Country],
  ),
  keywords: ("Machine Learning", "Swiss AI Days", "2027"),
  abstract: [
    This document provides a basic paper template and submission guidelines.
    Abstracts must be a single paragraph, ideally between 4--6 sentences long.
    Gross violations will trigger corrections at the camera-ready phase.
  ],
)

= Electronic Submission <submission>

Submission to Swiss AI Days is electronic, via OpenReview. Information about
the submission process is available on the conference website:

#align(center, strong(link("https://ai-days.swiss-ai-center.ch", "ai-days.swiss-ai-center.ch")))

The supplied 2027 LaTeX instructions apply to initial submissions and
camera-ready copies. The following summary preserves their main requirements.

- Submit the main paper, references, and any appendices as *a single PDF*.
  Reviewers may miss appendices uploaded separately.
- The page limits exclude references and appendices; the total PDF must not
  exceed *10 MB*.
  - *Long papers*: eight pages for review, with one additional page permitted
    for the final version to respond to reviews.
  - *Short papers*: four pages for review, with one additional page permitted
    for the final version to respond to reviews.
- *Do not include author information or acknowledgements* in the initial
  submission. See @author-information.
- Use the supplied Times-style typeface and formatting. Do not compress the
  paper by changing margins, font sizes, or vertical spacing.
- Place figure captions *below* figures and table captions *above* tables.
- Keep the abstract self-contained, in one paragraph of roughly 4--6 sentences.
- Make references complete and include page numbers whenever possible. Order
  grouped citations chronologically.
- For contributions with code artifacts, provide an anonymous repository,
  for example through #link("https://anonymous.4open.science/").

== Submitting Papers

*Anonymous submission.* Swiss AI Days uses double-blind review. Neither the
paper nor linked supplementary material may reveal the authors' identities.
The template hides the author list, affiliations, correspondence, PDF author
metadata, and acknowledgements by default.

*AI usage.* Submissions must represent original scholarly work conceived,
conducted, and written by human authors. The supplied instructions prohibit
papers generated wholly or substantially by generative AI, including their
arguments, analyses, results, or conclusions. Generative AI tools may not be
named as authors. Limited assistance with language, formatting, or coding
does not transfer responsibility: the authors remain accountable for
originality, accuracy, citations, and compliance.

Every submission must include an *AI Use Statement* describing whether and how
generative AI tools were used in the research or preparation of the manuscript,
including the tools and tasks. If none were used, the supplied instructions
require the exact declaration:

#quote(
  block: true,
)[The authors declare that no generative AI tools were used in conducting the research or preparing this manuscript.]

Materially false or incomplete disclosure may result in rejection or
withdrawal of an accepted paper.

== Camera-Ready Copy

Set `accepted: true` in `aidays.with(...)`, or compile this example with
`--input accepted=true`. This reveals the authors, affiliations, and
correspondence, replaces the review notice with the proceedings notice, and
removes the review ruler. The rest of the layout is unchanged.

The proceedings text follows `said2027.sty`: _Proceedings of the Fifth Swiss AI
Days_, Geneva, GE, Yverdon-les-Bains, VD, & Fribourg, FR, Switzerland: PMLR 342,
2027. Copyright 2027 by the author(s).

= Format of the Paper

== Dimensions and Typography

Use US Letter paper with two columns, a total text width of 6.75 inches, a
column gap of 0.25 inches, and a text height of 9 inches. The implementation
retains the effective 0.77-inch left margin of the LaTeX style. The title's
upper rule is one inch from the top edge. The body uses 10-TeX-point Times-style
text on an 11-TeX-point baseline. TeX points are converted to physical lengths
because Typst points and TeX points differ slightly.

The template uses Times New Roman by default, supplied by your system. No font
files are distributed with the template. In the Typst web app, choose an
available Times-compatible font such as TeX Gyre Termes using the `font`
argument, or upload your own font files. For the command line, install the
selected font and use `--input font="TeX Gyre Termes"` and, if necessary,
`--font-path` pointing to its directory.

The original LaTeX instructions mention Type-1 fonts. Typst embeds OpenType
fonts as PDF CID fonts instead. Keep all fonts embedded and avoid Type-3 fonts
in imported graphics.

== Title and Running Head

The title is centered in 14-point bold text between one-point horizontal
rules. Capitalize the content words. The running head appears on every page
after the first, in centered, bold 9-point text above a one-point rule. Supply
`short-title` if the full title does not fit on one line.

== Author Information <author-information>

Keep `accepted: false` for review. It is safe to configure the author records in
the source: the template substitutes anonymous information in the output.
Authors remain responsible for identifying information in the body,
self-citations, acknowledgements written outside the provided helper,
images, and external links.

For the accepted version, provide each author's full name and affiliation
identifiers. Names are bold and stay on one line; the list wraps between
authors. Affiliations receive superscript numbers in order of first use and
are listed once in a note at the bottom of the first column.

Set `equal: true` for authors with equal contribution. Set
`corresponding: true` and provide `email` for corresponding authors, ideally
one or two. The template hides both notes in the review version.

=== Self-Citations

Refer to your own published work in the third person. Do not anonymize
published references. Anonymized copies of unpublished manuscripts cited in
the paper should be provided as supplementary material. The paper must remain
self-contained: reviewers need not consult supplementary files.

== Abstract and Sections

The abstract starts in the first column with a centered, bold 11-point heading.
Its body is indented a further 0.25 inches on each side. Use at most three
numbered heading levels: section, subsection, and subsubsection. The third
level uses small capitals.

Do not indent paragraph openings. Separate paragraphs with vertical space.
Footnotes appear in 9-point text at the bottom of their column, beneath a
0.8-inch rule.#footnote[Footnotes should be complete sentences.]

== Figures

Center figures and ensure their contents are legible at the printed size.
Use dark lines at least 0.5 points thick. Label axes and distinct components;
put titles in captions rather than inside graphics. Number figures
consecutively and place 9-point captions below them. Short captions are
centered; longer captions are aligned to the left.

@method-figure demonstrates a figure built with native Typst elements. Use
`image("figure.svg", width: 100%)` for external vector graphics. Set
`scope: "parent", placement: top` for a figure spanning both columns.

#figure(
  align(center, stack(
    dir: ltr,
    spacing: 8pt,
    rect(inset: 8pt, stroke: 0.6pt)[Input],
    [$arrow.r$],
    rect(inset: 8pt, stroke: 0.6pt)[Model],
    [$arrow.r$],
    rect(inset: 8pt, stroke: 0.6pt)[Output],
  )),
  caption: [An illustrative processing pipeline. Replace this diagram with an appropriate figure for your paper.],
) <method-figure>

== Algorithms

Use `algorithm(caption)[...]` for a ruled, numbered pseudocode block, as in
@bubble-sort. Its label can be referenced with the usual Typst `@label` syntax.

#algorithm([Bubble Sort])[
  #set par(justify: false, spacing: 3pt)
  *Input:* data $x_1, dots, x_m$

  *repeat*\
  #h(1em) $"noChange" <- "true"$\
  #h(1em) *for* $i <- 1$ *to* $m - 1$ *do*\
  #h(2em) *if* $x_i > x_(i+1)$ *then*\
  #h(3em) Swap $x_i$ and $x_(i+1)$\
  #h(3em) $"noChange" <- "false"$\
  #h(2em) *end if*\
  #h(1em) *end for*\
  *until* $"noChange" = "true"$
] <bubble-sort>

== Tables

Number tables consecutively and place captions above them. Use headings that
identify each column and report uncertainties where appropriate. @sample-table
reproduces example values from the supplied LaTeX document; these values are
included only to demonstrate formatting.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, center, center),
    stroke: none,
    inset: (x: 5pt, y: 4pt),
    table.hline(stroke: 0.8pt),
    table.header([Data set], [Naive Bayes], [Flexible Bayes]),
    table.hline(stroke: 0.4pt),
    [Breast], [$95.9 plus.minus 0.2$], [$96.7 plus.minus 0.2$],
    [Cleveland], [$83.3 plus.minus 0.6$], [$80.0 plus.minus 0.6$],
    [Glass2], [$61.9 plus.minus 1.4$], [$83.8 plus.minus 0.7$],
    [Credit], [$74.8 plus.minus 0.5$], [$78.3 plus.minus 0.6$],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Example classification accuracies from the LaTeX template.],
) <sample-table>

== Mathematics and Theorems

Use Typst's native math syntax for equations. Numbered displayed equations
support cross-references, as in @risk:

$ hat(R)(f) = 1/n sum_(i=1)^n ell(f(x_i), y_i). $ <risk>

Definitions, propositions, lemmas, theorems, corollaries, assumptions, and
remarks share a counter within each section. @injective and @cardinality
illustrate the available helpers.

#definition[
  A function $f: X -> Y$ is injective if $f(x) != f(y)$ whenever $x != y$.
] <injective>

#proposition[
  If $X$ is finite and $f: X -> Y$ is injective, then $|Y| >= |X|$.
] <cardinality>

#proof[Distinct elements of $X$ have distinct images in $Y$.]

== Citations and References

Use author-year citations, for example @Samuel59, and narrative citations such
as #cite(<langley00>, form: "prose"). Group related citations to sort them
chronologically: @kearns89 @mitchell80 @Samuel59. References are sorted
alphabetically by author and include titles and publication details.

The bundled CSL style implements the author-year conventions of `said2027.bst`.
Use an existing BibTeX file with `bibliography("main.bib")`; no BibTeX
command or network package download is needed. Bibliography entries are
clickable from citations.

== Software and Data

Provide sufficient methodological detail for reproduction. Include code and
data links when appropriate; ensure the review version uses anonymous links.
Supplementary material belongs in the same PDF whenever it is an appendix.

#acknowledgements[
  Acknowledgements appear only in the accepted version. Thank reviewers,
  colleagues, and funding sources here, before the references.
]

#unnumbered[Limitations]
The supplied instructions require authors to explain the limitations of their
work so readers can position the contribution within existing research. This
section is excluded from the main paper page limit.

#unnumbered[Ethical Statement]
Discuss relevant issues such as annotator remuneration, third-party code and
data licenses, intended use, and the computational resources invested in the
work. The source excludes this section from the main page limit and specifies
a one-page cap for the statement material; its wording repeats “Ethical
Statement”, so the exact grouping requires clarification by the organizers.

#unnumbered[AI Use Statement]
Every submitted paper must accurately disclose whether and how generative AI
was used. Replace this instructional paragraph with the disclosure for your
own research and manuscript; do not copy a no-use statement unless it is true.

#bibliography("template/main.bib", full: true)

#appendix[
  = Additional Details

  Appendices are included in the same PDF, after the references. There is no
  appendix page limit in the supplied instructions, subject to the total
  10 MB file-size limit. They do not increase the main-paper allowance.

  This appendix uses one column, as does the supplied LaTeX example. Use
  `appendix(columns: 2)[...]` to retain two columns. The paper's fonts,
  running head, margins, and page numbers continue here.

  == Reproducibility Information

  Include additional proofs, configuration details, or experimental results
  needed to make the work reproducible.
]
