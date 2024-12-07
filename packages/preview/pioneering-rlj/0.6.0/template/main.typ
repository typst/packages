#import "/logo.typ": LaTeX, LaTeX2e
#import "@preview/pioneering-rlj:0.6.0": (
  appendix, acknowledgments, contribution, impact-statement, rlj, url)

#let affls = (
  amii: ("Alberta Machine Intelligence Institute (Amii)", ),
  cifar: ("CIFAR AI Chair", ),
  skoltech: (
    department: "AI Center",
    institution: "Skoltech",
    location: "Moscow",
    country: "Russia"),
  UoA: (
    institution: "Department of Computing Science",
    location: "University of Alberta, Canada"),
  UoM: (
    department: "Manning College of Information and Computer Sciences",
    institution: "University of Massachusetts"),
  // Not an affilation but a general comment (must contain `comment` key).
  some-comment: (
    comment: [
      Additional comments can be added like this, e.g., indicating equal
      contribution,
    ],
  ),
)

// NOTE For camera-ready and preprint versions, the cover page includes author
// names but not affiliations. It automatically adds the superscripts for
// affiliations.
#let authors = (
  (name: "Marlos C. Machado",
   email: "machado@ualberta.ca",
   affl: ("UoA", "amii", "cifar", "some-comment")),
  (name: "Philip S. Thomas",
   email: "pthomas@cs.umass.edu",
   affl: ("UoM", "some-comment")),
  (name: "Lorem Ipsum",
   email: "lipsum@cs.umass.edu",
   affl: "some-comment"),
)

#let contribs = (
  contribution[
    Provide a succinct but precise list of the contribution(s) of the paper.
    Use contextual notes to avoid implications of contributions more
    significant than intended and to clarify and situate the contribution
    relative to prior work (see the examples below). If there is no additional
    context, enter "None". Try to keep each contribution to a single sentence,
    although multiple sentences are allowed when necessary. If using complete
    sentences, include punctuation. If using a single sentence fragment, you
    may omit the concluding period. A single contribution can be sufficient,
    and there is no limit on the number of contributions. Submissions will be
    judged mostly on the contributions claimed on their cover pages and the
    evidence provided to support them. Major contributions should not be
    claimed in the main text if they do not appear on the cover page.
    Overclaiming can lead to a submission being rejected, so it is important to
    have well-scoped contribution statements on the cover page.
  ],
  contribution(
    caveat: [Built from previous RLC/RLJ, ICLR, and TMLR submission templates],
  )[The submission template for submissions to RLJ/RLC 2025],
  contribution(
    caveat: [
      Prior work established expressions for the policy gradient without
      function approximation @Williams1992.
    ],
  )[
    _\[Example of one contribution and corresponding contextual note for the
    paper "Policy gradient methods for reinforcement learning with function
    approximation" @Sutton2000.\]_\
    This paper presents an expression for the policy gradient when using
    function approximation to represent the action-value function.
  ],
)

#let summary = [
  The summary appears on the cover page. Although it can be identical to the
  abstract, it does not have to be. One might choose to omit the stated
  contributions in the Summary, given that they will be stated in the box
  below. The original abstract may also be extended to two paragraphs. The
  authors should ensure that the contents of the cover page fit entirely on a
  single page. The cover page does *not* count towards the 8--12 page limit.

  #lorem(130)
]

// WARNING Authors must not appear in the submitted version. They should be
// hidden as long as the `rlj` package is used without the `accepted: true` or
// `accepted: none` options. Non-anonymous submissions will be rejected without
// review.

#show: rlj.with(
  title: [Formatting Instructions for RLJ/RLC Submissions],
  authors: (authors, affls),
  abstract: [
    The abstract paragraph should be indented 1/2~inch on both left and
    right-hand margins. Use 10~point type, with a vertical spacing of
    11~points. The word "Abstract" must be centered, in bold, and in point
    size~12. Two line spaces precede the abstract. The abstract must be limited
    to one paragraph.
  ],
  keywords: ("RLJ", "RLC", "formatting guide", "style file", "LaTeX template"),
  bibliography: bibliography("main.bib", full: true),
  appendix: [],
  accepted: false,
  summary: summary,
  contributions: contribs,
  running-title: [Enter Your Running Title Here],
  supplementary: include "supplementary.typ",
)

= Submission of papers to RLJ/RLC <sec:submission>

RLJ/RLC requires electronic submissions, processed by
#url("https://openreview.net/"). See RLC's website for more instructions.

Fur submissions, use no options with the `rlj` package to adjust the format for
submission requirements, as follows:

#align(center)[
  ```latex
      \usepackage{rlj}
  ```
]

If your paper is ultimately accepted, use option `accepted` with the `rlj`
package to adjust the format to the camera ready requirements, as follows:

#align(center)[
  ```latex
      \usepackage[accepted]{rlj}
  ```
]

To de-anonymize and remove mentions to RLJ/RLC (for example for posting to
preprint servers), use the preprint option, as in

#align(center)[
  ```latex
      \usepackage[preprint]{rlj}
  ```
]

== Style

Papers to be submitted to RLJ/RLC must be prepared according to the
instructions presented here.

Authors are required to use the RLJ/RLC #LaTeX style files obtainable at the
RLJ/RLC websites (as both a .zip file and a link to an Overleaf project).
Changing the style files, font, font size, margins, line spacing, or appearance
of sections and subsections may be grounds for rejection.

== Retrieval of style files

The style files for RLJ/RLC are available online on the RLJ/RLC website. The
file `rlj.pdf` contains these instructions and illustrates the various
formatting requirements your RLC paper must satisfy. Submissions must be made
using #LaTeX and the style files `rlj.sty` and `rlj.bst` (to be used with
#LaTeX2e. The file `rlj.tex` may be used as a "shell" for writing your paper.
All you have to do is replace the author, title, abstract, and text of the
paper with your own.

= Citations, figures, tables, references, equations <sec:others>

These instructions apply to everyone, regardless of the formatter being used.

== Citations within the text <sec:citations>

Citations within the text should be based on the `natbib` package and include
the authors' last names and year (with the "et~al." construct for more than two
authors). When the authors or the publication are included in the sentence, the
citation should not be in parenthesis, using `\citet{}` (as in "See the work of
#cite(<sutton1998introduction>, form: "prose") for more information.").
Otherwise, the citation should be in parenthesis using `\citep{}` (as in
"Reinforcement learning is defined not by characterizing learning methods, but
by characterizing a learning _problem_ @sutton1998introduction.").

The corresponding references are to be listed in alphabetical order of authors,
in the *References* section. As to the format of the references themselves, any
style is acceptable as long as it is used consistently.

== Footnotes <sec:footnotes>

Indicate footnotes with a number#footnote[This is an example of a footnote.] in
the text. Place the footnotes at the bottom of the page on which they appear.
Precede the footnote with a horizontal rule of 2~inches. When following
punctuation, footnotes should be placed after the punctuation (e.g., commas and
periods).#footnote[This is a second example of a footnote.]

== Figures <sec:figures>

All artwork must be neat, clean, and legible when printed. Lines should be dark
enough for purposes of reproduction. The figure number and caption always
appear after the figure. Place one line space before the figure caption, and
one line space after the figure. The figure caption is lowercase (except for
the first word and proper nouns); figures are numbered consecutively.

Make sure the figure caption does not get separated from the figure. Leave
sufficient space to avoid splitting the figure and figure caption. Ensure that
figures are always referenced in the text before they appear, or on the same
page that they appear. This will be ensured if the figure occurs after its
first reference in the source. For example, see @fig:example.

#let example-image = rect(
  width: 4.25cm - 0.9pt, height: 4.25cm - 0.9pt, stroke: 0.45pt)

#v(-8pt)
#figure(
  caption: [Sample figure caption.],
  example-image,
) <fig:example>
#v(-8pt)

You may use color figures. However, it is best for the figure captions and the
paper body to make sense if the paper is printed either in black/white or in
color.

You may use subfigures, as shown in @fig:subfigureExample.

#let subfigures = {
  set figure(kind: "subfigure", supplement: [], gap: 3.5pt)
  show figure.where(kind: "subfigure"): set figure.caption(separator: [~])
  show figure: set figure(numbering: "(a)")
  grid(
    columns: (1fr, 1fr),
    figure(
      caption: [First subfigure],
      example-image),
    figure(
      caption: [Second subfigure],
      example-image))
}

// NOTE Figures, specifically @fig:example, allows a lot of stretching and
// shrinking. Typst can not do it at the moment. Thus we shrink spaces
// manually.
#v(-2pt)

== Tables <sec:tables>

Tables must be centered, neat, clean and legible. Do not use hand-drawn tables.
The table number and title always appear after the table. See
@tab:exampleTable. Place one line space before the table title, one line space
above the table title, and one line space after the table. Tables are numbered
consecutively.

#figure(
  caption: [An example using subfigures.],
  kind: image,
  gap: 10.5pt,
  subfigures,
) <fig:subfigureExample>

#figure(
  caption: [Sample table caption],
  table(
    columns: 2,
    align: (center, left),
    stroke: none,
    inset: (y: 0pt),
    table.header(..([*PART*], [*DESCRIPTION*]).map(it => table.cell(inset: (bottom: 4pt), it))),
    table.hline(stroke: 0.4pt),
    [~     ], [~                            ],
    [Actor ], [Stores and updates the policy],
    [Critic], [Stores and updates a value function],
  )) <tab:exampleTable>

== Equations <sec:equations>

Equations can be included inline or using `equation`, `gather`, or `align`
blocks. When using `align` blocks, place the alignment character `&` after
equality or inequality symbols so that it is visually clear where each
expression (which may span more than one line) begins and ends, as in the
following example.

#let nows = h(0pt)
#let eq = $nows=nows$
$ Pr(A_2 eq a_2)
  = & sum_(s_0 in cal(S)) Pr(S_0 eq s_0) sum_(a_0 in cal(A)) Pr(A_0 eq a_0|S_0 eq s_0) sum_(s_1 in cal(S)) Pr(S_1 eq s_1|S_0 eq s_0,A_0 eq a_0) \
    & times sum_(a_1 in cal(A)) Pr(A_1 eq a_1|S_1 eq s_1) sum_(s_2 in cal(S)) Pr(S_2 eq s_2|S_1 eq s_1,A_1 eq a_1) Pr(A_2 eq a_2|S_2 eq s_2) \
  = & sum_(s_0 in cal(S)) d_0(s_0) sum_(a_0 in cal(A)) pi(s_0,a_0) sum_(s_1 in cal(S)) p(s_0,a_0,s_1) sum_(a_1 in cal(A)) pi(s_1,a_1) sum_(s_2 in cal(S)) p(s_1,a_1,s_2) \
    & times pi(s_2,a_2),
$ <eq:secondActionPr>

where $times$ denotes scalar multiplication split across multiple lines.

You may use the style of your choice when referencing expressions by number,
including the following forms:

- In @eq:secondActionPr, there is no summation over $a_2$ because it is defined
  on the left side of the equation. #footnote[This format is sometimes
  preferred because often referenced expressions are inequalities or
  definitions, not equations. Notice the use of `eqref` in place of `ref` in
  this example.]

- In @eq:secondActionPr[Equation], there is no summation
  over $a_2$ because it is defined on the left side of the equation.

- In @eq:secondActionPr[Eq.], there is no summation over $a_2$ because it is
  defined on the left side of the equation.

You may number all lines of all equations, some lines of each equation
(typically one line per equation), or only the equations that are referenced.
#footnote[To number some lines of each equation use `\nonumber` to suppress
numbers for some of the lines, as in this document. To number only the
referenced equations, uncomment the line in main.tex:
`\mathtoolsset{showonlyrefs}`. Note that there may be conflicts between
showonlyrefs and both autoref and cref.]

The default behavior is to number all lines of all equations and we strongly
encourage (but do not require) authors to number all lines of all equations for
initial submissions to allow reviewers to easily reference specific lines.

= Final instructions <sec:final>

Do not change any aspects of the formatting parameters in the style files. In
particular, do not modify the width or length of the rectangle the text should
fit into, and do not change font sizes (except perhaps in the
*References* section; see below). Please note that pages should be
numbered for submissions, but not for camera-ready versions.

= Preparing PostScript or PDF files <sec:prep>

We recommend preparing your manuscript using the provided Overleaf project,
which will automatically construct a PDF file for submission. This file can be
downloaded by clicking the "Menu" button in the top left, and then selecting
"PDF" at the top of the menu that appears.

If you are not using Overleaf, please prepare PostScript or PDF files with
paper size "US Letter", and not, for example, "A4". The `-t` letter option on
dvips will produce US Letter files.

Consider directly generating PDF files using `pdflatex` (especially if you are
a MiKTeX user). PDF figures must be substituted for EPS figures, however.

Otherwise, please generate your PostScript and PDF files with the following
commands:

```bash
    dvips mypaper.dvi -t letter -Ppdf -G0 -o mypaper.ps
    ps2pdf mypaper.ps mypaper.pdf
```

== Margins in LaTeX <sec:margins>

Most of the margin problems come from figures positioned by hand using
`\special` or other commands. We suggest using the command `\includegraphics`
from the graphicx package. Always specify the figure width as a multiple of the
line width as in the example below using .eps graphics

```latex
    \usepackage[dvips]{graphicx} ...
    \includegraphics[width=0.8\linewidth]{myfile.eps}
```
or // Apr 2009 addition
```latex
    \usepackage[pdftex]{graphicx} ...
    \includegraphics[width=0.8\linewidth]{myfile.pdf}
```

for .pdf graphics. See Section~4.4 in the graphics bundle documentation
(#url("http://www.ctan.org/tex-archive/macros/latex/required/graphics/grfguide.ps")).

A number of width problems arise when LaTeX cannot properly hyphenate a line.
Please give LaTeX hyphenation hints using the `\-` command.

#impact-statement[
  In this optional section, RLJ/RLC encourages authors to discuss possible
  repercussions of their work, notably any potential negative impact that a
  user of this research should be aware of.
]

// Appendices.
//
// There are two options for stylizing appendices: use `appendix` show rule or
// pass appendix content to `appendix` keyword of `rlj` show rule.
#show: appendix

= The first appendix <sec:appendix1>

This is an example of an appendix.

*Note:* Appendices appear before the references and are viewed as
part of the "main text" and are subject to the 8--12 page limit, are peer
reviewed, and can contain content central to the claims of the paper.

= The second appendix <sec:appendix2>

This is an example of a second appendix. If there is only a single section in
the appendix, you may simply call it "Appendix" as follows:

#heading(numbering: none)[Appendix]

This format should only be used if there is a single appendix (unlike in this
document).

#acknowledgments[
  Use unnumbered third level headings for the acknowledgments. All
  acknowledgments, including those to funding agencies, go at the end of the
  paper. Only add this information once your submission is accepted and
  deanonymized. The acknowledgments do not count towards the 8--12 page limit.
]
