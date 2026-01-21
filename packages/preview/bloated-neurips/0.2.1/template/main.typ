#import "@preview/bloated-neurips:0.2.1": *
#import "@preview/tablex:0.0.8": cellx, hlinex, tablex
#import "/logo.typ": LaTeX, LaTeXe, TeX

#let affls = (
  airi: ("AIRI", "Moscow", "Russia"),
  skoltech: (
    department: "AI Center",
    institution: "Skoltech",
    location: "Moscow",
    country: "Russia"),
  skoltech2: (
    department: "AI Center",
    institution: "Skoltech",
    location: "Moscow",
    country: "Russia"),
)

#let authors = (
  (name: "Firstname1 Lastname1",
   affl: "skoltech",
   email: "author@example.org",
   equal: true),
  (name: "Firstname2 Lastname2", affl: ("airi", "skoltech"), equal: true),
)

#show: neurips2023.with(
  title: [Formatting Instructions For NeurIPS 2023],
  authors: (authors, affls),
  keywords: ("Machine Learning", "NeurIPS"),
  abstract: [
    The abstract paragraph should be indented ½ inch (3 picas) on both the
    left- and right-hand margins. Use 10 point type, with a vertical spacing
    (leading) of 11 points. The word *Abstract* must be centered, bold, and in
    point size 12. Two line spaces precede the abstract. The abstract must be
    limited to one paragraph.
  ],
  bibliography: bibliography("main.bib"),
  bibliography-opts: (title: none, full: true),  // Only for example paper.
  accepted: false,
)

= Submission of papers to NeurIPS 2023

Please read the instructions below carefully and follow them faithfully.
*Important:* This year the checklist will be submitted separately from the main
paper in OpenReview, please review it well ahead of the submission deadline:
#url("https://neurips.cc/public/guides/PaperChecklist")

== Style

Papers to be submitted to NeurIPS 2023 must be prepared according to the
instructions presented here. Papers may only be up to *nine* pages long,
including figures. Additional pages _containing only acknowledgments and
references_ are allowed. Papers that exceed the page limit will not be
reviewed, or in any other way considered for presentation at the conference.

The margins in 2023 are the same as those in previous years.

Authors are required to use the NeurIPS #LaTeX style files obtainable at the
NeurIPS website as indicated below. Please make sure you use the current files
and not previous versions. Tweaking the style files may be grounds for
rejection.

== Retrieval of style files


The style files for NeurIPS and other conference information are available on
the website at

#align(center)[
  #url("http://www.neurips.cc/")
]

The file `neurips_2023.pdf` contains these instructions and illustrates the
various formatting requirements your NeurIPS paper must satisfy.

The only supported style file for NeurIPS 2023 is `neurips_2023.sty`, rewritten
for #LaTeXe. *Previous style files for #LaTeX 2.09, Microsoft Word, and RTF
are no longer supported!*

The #LaTeX style file contains three optional arguments: `final`, which creates
a camera-ready copy, `preprint`, which creates a preprint for submission to,
e.g., arXiv, and `nonatbib`, which will not load the `natbib` package for you
in case of package clash.

#paragraph[Preprint option] If you wish to post a preprint of your work online,
e.g., on arXiv, using the NeurIPS style, please use the `preprint` option. This
will create a nonanonymized version of your work with the text "Preprint. Work
in progress." in the footer. This version may be distributed as you see fit, as
long as you do not say which conference it was submitted to. Please *do not*
use the `final` option, which should *only* be used for papers accepted to
NeurIPS.

At submission time, please omit the `final` and `preprint` options. This will
anonymize your submission and add line numbers to aid review. Please do _not_
refer to these line numbers in your paper as they will be removed during
generation of camera-ready copies.

The file `neurips_2023.tex` may be used as a "shell" for writing your paper.
All you have to do is replace the author, title, abstract, and text of the
paper with your own.

The formatting instructions contained in these style files are summarized in
Sections~#ref(<gen_inst>, supplement: none), #ref(<headings>, supplement:
none), and #ref(<others>, supplement: none) below.

= General formatting instructions <gen_inst>

The text must be confined within a rectangle 5.5~inches (33~picas) wide and
9~inches (54~picas) long. The left margin is 1.5~inch (9~picas).  Use 10~point
type with a vertical spacing (leading) of 11~points.  Times New Roman is the
preferred typeface throughout, and will be selected for you by default.
Paragraphs are separated by ½~line space (5.5 points), with no indentation.

The paper title should be 17~point, initial caps/lower case, bold, centered
between two horizontal rules. The top rule should be 4~points thick and the
bottom rule should be 1~point thick. Allow ¼~inch space above and below the
title to rules. All pages should start at 1~inch (6~picas) from the top of the
page.

For the final version, authors' names are set in boldface, and each name is
centered above the corresponding address. The lead author's name is to be
listed first (left-most), and the co-authors' names (if different address) are
set to follow. If there is only one co-author, list both author and co-author
side by side.

Please pay special attention to the instructions in @others regarding figures,
tables, acknowledgments, and references.

= Headings: first level <headings>

All headings should be lower case (except for first word and proper nouns),
flush left, and bold.

First-level headings should be in 12-point type.

== Headings: second level

Second-level headings should be in 10-point type.

=== Headings: third level

Third-level headings should be in 10-point type.

#paragraph[Paragraphs] There is also a `\paragraph` command available, which
sets the heading in bold, flush left, and inline with the text, with the
heading followed by #1em of space.

= Citations, figures, tables, references <others>

These instructions apply to everyone.

== Citations within the text

The `natbib` package will be loaded for you by default.  Citations may be
author/year or numeric, as long as you maintain internal consistency.  As to
the format of the references themselves, any style is acceptable as long as it
is used consistently.

The documentation for `natbib` may be found at

#align(center)[
  #url("http://mirrors.ctan.org/macros/latex/contrib/natbib/natnotes.pdf")
]

Of note is the command `\citet`, which produces citations appropriate for use
in inline text.  For example,

```tex
    \citet{hasselmo} investigated\dots
```
produces

#quote(block: true)[Hasselmo, et al.~(1995) investigated\dots]

If you wish to load the `natbib` package with options, you may add the
following before loading the `neurips_2023` package:

```tex
    \PassOptionsToPackage{options}{natbib}
```

If `natbib` clashes with another package you load, you can add the optional
argument `nonatbib` when loading the style file:

```tex
    \usepackage[nonatbib]{neurips_2023}
```

As submission is double blind, refer to your own published work in the third
person. That is, use "In the previous work of Jones et al.~[4]," not "In our
previous work [4]." If you cite your other papers that are not widely available
(e.g., a journal paper under review), use anonymous author names in the
citation, e.g., an author of the form "A.~Anonymous" and include a copy of the
anonymized paper in the supplementary material.

== Footnotes

Footnotes should be used sparingly. If you do require a footnote, indicate
footnotes with a number#footnote[Sample of the first footnote.] in the text.
Place the footnotes at the bottom of the page on which they appear. Precede the
footnote with a horizontal rule of 2~inches (12~picas).

Note that footnotes are properly typeset _after_ punctuation marks.#footnote[As
in this example.]

== Figures

#figure(
  rect(width: 4.25cm, height: 4.25cm, stroke: 0.4pt),
  caption: [Sample figure caption.],
  placement: top,
)

All artwork must be neat, clean, and legible. Lines should be dark enough for
purposes of reproduction. The figure number and caption always appear after the
figure. Place one line space before the figure caption and one line space after
the figure. The figure caption should be lower case (except for first word and
proper nouns); figures are numbered consecutively.

You may use color figures.  However, it is best for the figure captions and the
paper body to be legible if the paper is printed in either black/white or in
color.

== Tables <tables>

All tables must be centered, neat, clean and legible.  The table number and
title always appear before the table. See @sample-table.

Place one line space before the table title, one line space after the
table title, and one line space after the table. The table title must
be lower case (except for first word and proper nouns); tables are
numbered consecutively.

Note that publication-quality tables _do not contain vertical rules_. We
strongly suggest the use of the `booktabs` package, which allows for
typesetting high-quality, professional tables:

#align(center)[
  #url("https://www.ctan.org/pkg/booktabs")
]

This package was used to typeset @sample-table.

// Tickness values are taken from booktabs.
#let toprule = hlinex(stroke: (thickness: 0.08em))
#let bottomrule = toprule
#let midrule = hlinex(stroke: (thickness: 0.05em))
#let rows = (
  toprule,
  cellx(colspan: 2, align: center)[Part], (), [],
  hlinex(start: 0, end: 2, stroke: (thickness: 0.05em)),
  [Name], [Description], [Size ($mu$)],
  midrule,
  [Dendrite], [Input terminal ], [$~100$],
  [Axon    ], [Output terminal], [$~10$],
  [Soma    ], [Cell body      ], [up to $10^6$],
  bottomrule,
)

#figure(
  tablex(
    columns: 3,
    align: left + horizon,
    auto-vlines: false,
    auto-hlines: false,
    header-rows: 2,
    ..rows),  // TODO(@daskol): Fix gutter between rows in body.
  caption: [Sample table title.],
  kind: table,
  placement: top,
) <sample-table>

== Math

Note that display math in bare TeX commands will not create correct line
numbers for submission. Please use LaTeX (or AMSTeX) commands for unnumbered
display math. (You really shouldn't be using $dollar dollar$ anyway; see
#url("https://tex.stackexchange.com/questions/503/why-is-preferable-to") and
#url("https://tex.stackexchange.com/questions/40492/what-are-the-differences-between-align-equation-and-displaymath")
for more information.)

== Final instructions

Do not change any aspects of the formatting parameters in the style files.  In
particular, do not modify the width or length of the rectangle the text should
fit into, and do not change font sizes (except perhaps in the *References*
section; see below). Please note that pages should be numbered.

= Preparing PDF files

Please prepare submission files with paper size "US Letter," and not, for
example, "A4."

Fonts were the main cause of problems in the past years. Your PDF file must only
contain Type 1 or Embedded TrueType fonts. Here are a few instructions to
achieve this.

- You should directly generate PDF files using `pdflatex`.

- You can check which fonts a PDF files uses.  In Acrobat Reader, select the
  menu Files$>$Document Properties$>$Fonts and select Show All Fonts. You can
  also use the program `pdffonts` which comes with `xpdf` and is available
  out-of-the-box on most Linux machines.

- `xfig` "patterned" shapes are implemented with bitmap fonts. Use "solid"
  shapes instead.

- The `\bbold` package almost always uses bitmap fonts. You should use the
  equivalent AMS Fonts:

  ```tex
      \usepackage{amsfonts}
  ```

  followed by, e.g., `\mathbb{R}`, `\mathbb{N}`, or `\mathbb{C}` for $RR$, $NN$
  or $CC$.  You can also use the following workaround for reals, natural and
  complex:

  ```tex
      \newcommand{\RR}{I\!\!R} %real numbers
      \newcommand{\Nat}{I\!\!N} %natural numbers
      \newcommand{\CC}{I\!\!\!\!C} %complex numbers
  ```

  Note that `amsfonts` is automatically loaded by the `amssymb` package.

If your file contains Type 3 fonts or non embedded TrueType fonts, we will ask
you to fix it.

== Margins in #LaTeX

Most of the margin problems come from figures positioned by hand using
`\special` or other commands. We suggest using the command `\includegraphics`
from the `graphicx` package. Always specify the figure width as a multiple of
the line width as in the example below:

```tex
    \usepackage[pdftex]{graphicx} ...
    \includegraphics[width=0.8\linewidth]{myfile.pdf}
```

See @tables in the graphics bundle documentation
(#url("http://mirrors.ctan.org/macros/latex/required/graphics/grfguide.pdf"))

A number of width problems arise when #LaTeX cannot properly hyphenate a line.
please give #LaTeX hyphenation hints using the `\-` command when necessary.

// note this is the acknowledgments section which is not visible in draft.
#if false [
use unnumbered first level headings for the acknowledgments. all
acknowledgments go at the end of the paper before the list of references.
moreover, you are required to declare funding (financial activities supporting
the submitted work) and competing interests (related financial activities
outside the submitted work). More information about this disclosure can be
found at:
#url("https://neurips.cc/Conferences/2023/PaperInformation/FundingDisclosure")

Do *not* include this section in the anonymized submission, only in the final
paper. You can use the `ack` environment provided in the style file to
autmoatically hide this section in the anonymized submission.
]

= Supplementary Material

Authors may wish to optionally include extra information (complete proofs,
additional experiments and plots) in the appendix. All such materials should be
part of the supplemental material (submitted separately) and should NOT be
included in the main submission.

// We typset reference section header manualy in order to reproduce example
// paper. No special effort is required (a user should not override
// `bibliography-opts` as well).
#heading(numbering: none)[References]

References follow the acknowledgments in the camera-ready paper. Use unnumbered
first-level heading for the references. Any choice of citation style is
acceptable as long as you are consistent. It is permissible to reduce the font
size to `small` (9 point) when listing the references. Note that the Reference
section does not count towards the page limit.
