#import "@preview/lucky-icml:0.2.1": *
#import "logo.typ": LaTeX, TeX

#let affls = (
  airi: ("AIRI", "Moscow", "Russia"),
  skoltech: (
    department: "AI Center",
    institution: "Skoltech",
    location: "Moscow",
    country: "Russia",
    ),
)

#let authors = (
  (name: "Firstname1 Lastname1",
   affl: ("skoltech"),
   email: "author@example.org",
   equal: true),
  (name: "Firstname1 Lastname1", affl: ("airi", "skoltech"), equal: true),
)

#show: icml2024.with(
  title: [
    Submission and Formatting Instructions for \
    International Conference on Machine Learning (ICML 2024)
  ],
  authors: (authors, affls),
  keywords: ("Machine Learning", "ICML"),
  abstract: [
    This document provides a basic paper template and submission guidelines.
    Abstracts must be a single paragraph, ideally between 4–6 sentences long.
    Gross violations will trigger corrections at the camera-ready phase.
  ],
  bibliography: bibliography("main.bib"),
  header: [Submission and Formatting Instructions for ICML 2024],
  appendix: include "appendix.typ",
  accepted: false,
)

#vruler(offset: -1.7in)

= Electronic Submission

Submission to ICML 2023 will be entirely electronic, via
a web site (not email). Information about the submission
process and #LaTeX templates are available on the conference
web site at:

#align(center)[
  ```
  https://icml.cc/
  ```
]

The guidelines below will be enforced for initial submissions and camera-ready
copies. Here is a brief summary:

- Submissions must be in PDF.

- *New to this year:* If your paper has appendices, submit the appendix
  together with the main body and the references *as a single file*. Reviewers
  will not look for appendices as a separate PDF file. So if you submit such an
  extra file, reviewers will very likely miss it.

- Page limit: The main body of the paper has to be fitted to 8 pages, excluding
  references and appendices; the space for the latter two is not limited. For
  the final version of the paper, authors can add one extra page to the main
  body.

- *Do not include author information or acknowledgements* in your initial
  submission.

- Your paper should be in *10 point Times font*.

- Make sure your PDF file only uses Type-1 fonts.

- Place figure captions _under_ the figure (and omit titles from inside the
  graphic file itself). Place table captions _over_ the table.

- References must include page numbers whenever possible and be as complete as
  possible. Place multiple citations in chronological order.

- Do not alter the style template; in particular, do not compress the paper
  format by reducing the vertical spaces.
- Keep your abstract brief and self-contained, one paragraph and roughly 4–6
  sentences. Gross violations will require correction at the camera-ready
  phase. The title should have content words capitalized.

== Submitting Papers

*Paper Deadline:* The deadline for paper submission that is advertised on the
conference website is strict. If your full, anonymized, submission does not
reach us on time, it will not be considered for publication.

*Anonymous Submission:* ICML uses double-blind review: no identifying author
information may appear on the title page or in the paper itself. @author-info
gives further details.

*Simultaneous Submission:* ICML will not accept any paper which, at the time of
submission, is under review for another conference or has already been
published. This policy also applies to papers that overlap substantially in
technical content with conference papers under review or previously published.
ICML submissions must not be submitted to other conferences and journals during
ICML's review period. Informal publications, such as technical reports or
papers in workshop proceedings which do not appear in print, do not fall under
these restrictions.

#v(6pt)  // TODO: Original is \medskip.

Authors must provide their manuscripts in *PDF* format. Furthermore, please
make sure that files contain only embedded Type-1 fonts (e.g.,~using the
program `pdffonts` in linux or using File/DocumentProperties/Fonts in Acrobat).
Other fonts (like Type-3) might come from graphics files imported into the
document.

Authors using *Word* must convert their document to PDF. Most of the latest
versions of Word have the facility to do this automatically. Submissions will
not be accepted in Word format or any format other than PDF. Really. We're not
joking. Don't send Word.

#vruler(page: 1)

Those who use *\LaTeX* should avoid including Type-3 fonts. Those using `latex`
and `dvips` may need the following two commands:

```shell
dvips -Ppdf -tletter -G0 -o paper.ps paper.dvi ps2pdf paper.ps
```

It is a zero following the "-G", which tells dvips to use the `config.pdf`
file. Newer #TeX distributions don't always need this option.

Using `pdflatex` rather than `latex`, often gives better results. This program
avoids the Type-3 font problem, and supports more advanced features in the
`microtype` package.

*Graphics files* should be a reasonable size, and included from
an appropriate format. Use vector formats (.eps/.pdf) for plots,
lossless bitmap formats (.png) for raster graphics with sharp lines, and
jpeg for photo-like images.

The style file uses the `hyperref` package to make clickable links in
documents. If this causes problems for you, add `nohyperref` as one of the
options to the `icml2024` usepackage statement.

== Submitting Final Camera-Ready Copy

The final versions of papers accepted for publication should follow the same
format and naming convention as initial submissions, except that author
information (names and affiliations) should be given. See @final-author for
formatting instructions.

The footnote, "Preliminary work. Under review by the International Conference
on Machine Learning (ICML). Do not distribute." must be modified to
"_Proceedings of the 41#super("st") International Conference on Machine
Learning_, Vienna, Austria, PMLR 235, 2024. Copyright 2024 by the
author(s)."

For those using the *#LaTeX* style file, this change (and others) is handled
automatically by simply changing `\usepackage{icml2024}` to

```tex
\usepackage[accepted]{icml2024}
```

Authors using *Word* must edit the footnote on the first page of the document
themselves.

Camera-ready copies should have the title of the paper as running head on each
page except the first one. The running title consists of a single line centered
above a horizontal rule which is $1$~point thick. The running head should be
centered, bold and in $9$~point type. The rule should be $10$~points above the
main text. For those using the *#LaTeX* style file, the original title is
automatically set as running head using the `fancyhdr` package which is
included in the ICML 2024 style file package. In case that the original title
exceeds the size restrictions, a shorter form can be supplied by using

```tex
\icmltitlerunning{...}
```

just before `\begin{document}`. Authors using *Word* must edit the header of
the document themselves.

= Format of the Paper

All submissions must follow the specified format.

== Dimensions

The text of the paper should be formatted in two columns, with an overall width
of 6.75 inches, height of 9.0 inches, and 0.25 inches between the columns. The
left margin should be 0.75 inches and the top margin 1.0 inch (2.54 cm). The
right and bottom margins will depend on whether you print on US letter or A4
paper, but all final versions must be produced for US letter size. Do not write
anything on the margins.

The paper body should be set in 10 point type with a vertical spacing of 11
points. Please use Times typeface throughout the text.

== Title

The paper title should be set in 14~point bold type and centered between two
horizontal rules that are 1~point thick, with 1.0~inch between the top rule and
the top edge of the page. Capitalize the first letter of content words and put
the rest of the title in lower case.

== Author Information for Submission <author-info>

ICML uses double-blind review, so author information must not appear. If you
are using #LaTeX and the `icml2024.sty` file, use `\icmlauthor{...}` to specify
authors and `\icmlaffiliation{...}` to specify affiliations. (Read the TeX code
used to produce this document for an example usage.) The author information
will not be printed unless `accepted` is passed as an argument to the style
file. Submissions that include the author information will not be reviewed.

=== Self-Citations

If you are citing published papers for which you are an author, refer to
yourself in the third person. In particular, do not use phrases that reveal
your identity (e.g., "in previous work @langley00, we have shown ...").

Do not anonymize citations in the reference section. The only exception are
manuscripts that are not yet published (e.g., under submission). If you choose
to refer to such unpublished manuscripts @anonymous, anonymized copies have to
be submitted as Supplementary Material via OpenReview. However, keep in mind
that an ICML paper should be self contained and should contain sufficient
detail for the reviewers to evaluate the work. In particular, reviewers are not
required to look at the Supplementary Material when writing their review (they
are not required to look at more than the first $8$ pages of the submitted
document).

#vruler(page: 2)

=== Camera-Ready Author Information <final-author>

If a paper is accepted, a final camera-ready copy must be prepared. For
camera-ready papers, author information should start 0.3~inches below the
bottom rule surrounding the title. The authors' names should appear in 10~point
bold type, in a row, separated by white space, and centered. Author names
should not be broken across lines. Unbolded superscripted numbers, starting 1,
should be used to refer to affiliations.

Affiliations should be numbered in the order of appearance. A single footnote
block of text should be used to list all the affiliations. (Academic
affiliations should list Department, University, City, State/Region, Country.
Similarly for industrial affiliations.)

Each distinct affiliations should be listed once. If an author has multiple
affiliations, multiple superscripts should be placed after the name, separated
by thin spaces. If the authors would like to highlight equal contribution by
multiple first authors, those authors should have an asterisk placed after
their name in superscript, and the term "\*Equal contribution" should be placed
in the footnote block ahead of the list of affiliations. A list of
corresponding authors and their emails (in the format Full Name
\<email\@domain.com>) can follow the list of affiliations. Ideally only one or
two names should be listed.

A sample file with author names is included in the ICML2024 style file package.
Turn on the `[accepted]` option to the stylefile to see the names rendered. All
of the guidelines above are implemented by the #LaTeX style file.

== Abstract

The paper abstract should begin in the left column, 0.4~inches below the final
address. The heading 'Abstract' should be centered, bold, and in 11~point type.
The abstract body should use 10~point type, with a vertical spacing of
11~points, and should be indented 0.25~inches more than normal on left-hand and
right-hand margins. Insert 0.4~inches of blank space after the body. Keep your
abstract brief and self-contained, limiting it to one paragraph and roughly
4--6 sentences. Gross violations will require correction at the camera-ready
phase.

== Partitioning the Text

You should organize your paper into sections and paragraphs to help readers
place a structure on the material and understand its contributions.

=== Sections and Subsections

Section headings should be numbered, flush left, and set in 11~pt bold type
with the content words capitalized. Leave 0.25~inches of space before the
heading and 0.15~inches after the heading.

Similarly, subsection headings should be numbered, flush left, and set in 10~pt
bold type with the content words capitalized. Leave 0.2~inches of space before
the heading and 0.13~inches afterward.

Finally, subsubsection headings should be numbered, flush left, and set in
10~pt small caps with the content words capitalized. Leave 0.18~inches of space
before the heading and 0.1~inches after the heading.

Please use no more than three levels of headings.

=== Paragraphs and Footnotes

Within each section or subsection, you should further partition the paper into
paragraphs. Do not indent the first line of a given paragraph, but insert a
blank line between succeeding ones.

You can use footnotes#footnote[Footnotes should be complete sentences.] to
provide readers with additional information about a topic without interrupting
the flow of the paper. Indicate footnotes with a number in the text where the
point is most relevant. Place the footnote in 9~point type at the bottom of the
column in which it appears. Precede the first footnote in a column with a
horizontal rule of 0.8~inches.#footnote[Multiple footnotes can appear in each
column, in the same order as they appear in the text, but spread them across
columns and pages if possible.]

== Figures

You may want to include figures in the paper to illustrate your approach and
results. Such artwork should be centered, legible, and separated from the text.
Lines should be dark and at least 0.5~points thick for purposes of
reproduction, and text should not appear on a gray background.

Label all distinct components of each figure. If the figure takes the form of a
graph, then give a name for each axis and include a legend that briefly
describes each curve. Do not include a title inside the figure; instead, the
caption should serve this function.

Number figures sequentially, placing the figure number and caption #emph[after]
the graphics, with at least 0.1~inches of space before the caption and
0.1~inches after it, as in @icml-historical. The figure caption should be set
in 9~point type and centered unless it runs two or more lines, in which case it
should be flush left. You may float figures to the top or bottom of a column,
and you may set wide figures across both columns (use the environment
`figure*` in #LaTeX). Always place two-column figures at the top or bottom of
the page.

#vruler(page: 3)

#figure(
  image("icml-numpapers.svg"),
  caption: [
    Historical locations and number of accepted papers for International
    Machine Learning Conferences (ICML 1993 -- ICML 2008) and International
    Workshops on Machine Learning (ML 1988 -- ML 1992). At the time this figure
    was produced, the number of accepted papers for ICML 2008 was unknown and
    instead estimated.
  ],
  placement: top,
) <icml-historical>

Add a dummy text here to get the same figure layout. #lorem(100)

== Algorithms

If you are using \LaTeX, please use the "algorithm" and "algorithmic"
environments to format pseudocode. These require the corresponding stylefiles,
algorithm.sty and algorithmic.sty, which are supplied with this package.
@alg-example shows an example.

#import "@preview/algorithmic:0.1.0"
#import algorithmic: algorithm

#let Until(cond: none, ..body) = (
  (strong[repeat]),
  (change_indent: 4, body: body.pos()),
  (strong[until ] + cond),
)

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Bubble Sort],
  placement: top,
  algorithm({
    import algorithmic: *
    State[*Input:* data $x_i$, size $m$]
    Until(cond: [_noChange_ is _true_], {
      State[Initialize _noChange = true_.]
      For(cond: [$i=1$ *to* $m-1$], {
        If(cond: $x_i > x_(i + 1)$, {
          State[Swap $x_i$ and $x_(i + 1)$]
          State[_noChange = false_]
        })
      })
    })
  })
) <alg-example>

== Tables

You may also want to include tables that summarize material. Like figures,
these should be centered, legible, and numbered consecutively. However, place
the title #emph[above] the table with at least 0.1~inches of space before the
title and the same after it, as in @sample-table. The table title should be set
in 9~point type and centered unless it runs two or more lines, in which case it
should be flush left.

#let header = (
  ([Data set], [Naive], [Flexible], [Better?]),
)
#let rows = (
  ([Breast],    [95.9 ± 0.2], [96.7 ± 0.2], $sqrt(x)$),
  ([Cleveland], [83.3 ± 0.6], [80.0 ± 0.6], $times$),
  ([Glass 2],   [61.9 ± 1.4], [83.8 ± 0.7], $sqrt("")$),
  ([Credit],    [74.8 ± 0.5], [78.3 ± 0.6], [ ]),
  ([Horse],     [73.3 ± 0.9], [69.7 ± 1.0], $times$),
  ([Meta],      [67.1 ± 0.6], [76.5 ± 0.5], $sqrt("")$),
  ([Pima],      [75.1 ± 0.6], [44.9 ± 0.6], [ ]),
  ([Vehicle],   [73.9 ± 0.5], [61.5 ± 0.4], $sqrt("")$),
  ([Vehicle],   [73.9 ± 0.5], [61.5 ± 0.4], $sqrt("")$),
)

#let data-frame = (
  header: (nocols: 4, norows: 1, data: header),
  body: (nocols: 4, norows: rows.len(), data: rows),
)

#let format-cell(ix, jx, content, aux) = {
  let inset = (
    left: 0.6em, right: 0.6em,
    top: 0.2em, bottom: 0.2em,
  )
  if ix == 0 {
    inset.top = 0.5em
  }
  if ix == aux.norows - 1 {
    inset.bottom = 0.5em
  }

  if jx > 0 and jx < aux.nocols - 1 {
    inset.left = 0.5em
    inset.right = 0.5em
  }
  return cellx(inset: inset)[
    #text(size: font.small, smallcaps(content))
  ]
}

#figure(
  kind: table,
  tablex(
    columns: 4,
    align: (left + horizon, center + horizon, center + horizon, center + horizon),
    column-gutter: 0.6em,
    auto-lines: false,
    toprule,
    ..map-cells(header, format-cell, data-frame.header),
    midrule,
    ..map-cells(rows, format-cell, data-frame.body),
    bottomrule,
  ),
  caption: [
    Classification accuracies for naive Bayes and flexible Bayes on various
    data sets.
  ],
  placement: top,
) <sample-table>

Tables contain textual material, whereas figures contain graphical material.
Specify the contents of each row and column in the table's topmost row. Again,
you may float tables to a column's top or bottom, and set wide tables across
both columns. Place two-column tables at the top or bottom of the page.

== Theorems and such

The preferred way is to number definitions, propositions, lemmas, etc.
consecutively, within sections, as shown below.

#definition[
  A function $f: X arrow Y$ is injective if for any $x,y in X$ different,
  $f(x) != f(y)$.
] <def-inj>

Using @def-inj we immediate get the following result:

#proposition[
  If $f$ is injective mapping a set $X$ to another set $Y$, the cardinality of
  $Y$ is at least as large as that of $X$
]
#proof[
  Left as an exercise to the reader.
]

@lem-usefullemma stated next will prove to be useful.

#lemma[
  For any $f: X arrow Y$ and $g: Y arrow Z$ injective functions, $f circle.stroked.tiny g$ is injective.
] <lem-usefullemma>

#theorem[
  If $f: X arrow Y$ is bijective, the cardinality of $X$ and $Y$ are the same.
] <thm-bigtheorem>

An easy corollary of @thm-bigtheorem is the following:

#corollary[
  If $f: X arrow Y$ is bijective, the cardinality of $X$ is at least as large
  as that of $Y$.
]

#assumption[
  The set $X$ is finite.
] <ass-xfinite>

#remark[
  According to some, it is only the finite case (cf. @ass-xfinite) that
  is interesting.
]

#vruler(page: 4)

== Citations and References

Please use APA reference format regardless of your formatter or word processor.
If you rely on the #LaTeX bibliographic facility, use `natbib.sty` and
`icml2024.bst` included in the style-file package to obtain this format.

Citations within the text should include the authors' last names and year. If
the authors' names are included in the sentence, place only the year in
parentheses, for example when referencing Arthur Samuel's pioneering work
(#cite(<Samuel59>, form: "year")). Otherwise place the entire reference in
parentheses with the authors and year separated by a comma @Samuel59. List
multiple references separated by semicolons @kearns89 @Samuel59 @mitchell80.
Use the 'et~al.' construct only for citations with three or more authors or
after listing all authors to a publication in an earlier reference
@MachineLearningI.

Authors should cite their own work in the third person in the initial version
of their paper submitted for blind review. Please refer to @author-info for
detailed instructions on how to cite your own papers.

Use an unnumbered first-level section heading for the references, and use a
hanging indent style, with the first line of the reference flush against the
left margin and subsequent lines indented by 10 points. The references at the
end of this document give examples for journal articles @Samuel59, conference
publications @langley00, book chapters @Newell81, books @DudaHart2nd, edited
volumes @MachineLearningI, technical reports @mitchell80, and dissertations
@kearns89.

Alphabetize references by the surnames of the first authors, with single author
entries preceding multiple author entries. Order references for the same
authors by year of publication, with the earliest first. Make sure that each
reference includes all relevant information (e.g., page numbers).

Please put some effort into making references complete, presentable, and
consistent, e.g. use the actual current name of authors. If using bibtex,
please protect capital letters of names and abbreviations in titles, for
example, use #box[\{B\}ayesian] or #box[\{L\}ipschitz] in your .bib file.

= Accessibility

Authors are kindly asked to make their submissions as accessible as possible
for everyone including people with disabilities and sensory or neurological
differences. Tips of how to achieve this and what to pay attention to will be
provided on the conference website #link("http://icml.cc/").

= Software and Data

If a paper is accepted, we strongly encourage the publication of software and
data with the camera-ready version of the paper whenever appropriate. This can
be done by including a URL in the camera-ready copy. However, *do not* include
URLs that reveal your institution or identity in your submission for review.
Instead, provide an anonymous URL or upload the material as "Supplementary
Material" into the OpenReview reviewing system. Note that reviewers are not
required to look at this material when writing their review.

// Acknowledgements should only appear in the accepted version.
= Acknowledgements

*Do not* include acknowledgements in the initial version of the paper submitted
for blind review.

If a paper is accepted, the final camera-ready version can (and probably
should) include acknowledgements. In this case, please place such
acknowledgements in an unnumbered section at the end of the paper. Typically,
this will include thanks to reviewers who gave useful comments, to colleagues
who contributed to the ideas, and to funding agencies and corporate sponsors
that provided financial support.
