#import "@preview/smooth-tmlr:0.4.0": tmlr
#import "/logo.typ": LaTeX, LaTeX as LaTeX2e

#let affls = (
  nyu: (
    department: "Department of Computer Science",
    institution: "University of New York"),
  deepmind: (
    institution: "DeepMind"),
  mila: (
    institution: "Mila, Université de Montréal"),
  google-research: (
    institution: "Google Research"),
  cifar: (
    institution: "CIFAR Fellow")
)

#let authors = (
  (name: "Kyunghyun Cho", email: "kyunghyun.cho@nyu.edu", affl: "nyu"),
  (name: "Raia Hadsell", email: "raia@google.com", affl: "deepmind"),
  (name: "Hugo Larochelle",
   email: "hugolarochelle@google.com",
   affl: ("mila", "google-research", "cifar")),
)

#show: tmlr.with(
  title: [Formatting Instructions for TMLR \ Journal Submissions],
  authors: (authors, affls),
  keywords: (),
  abstract: [
    The abstract paragraph should be indented 1/2~inch on both left and
    right-hand margins. Use 10~point type, with a vertical spacing of
    11~points. The word #text(size: 12pt)[*Abstract*] must be centered, in
    bold, and in point size~12. Two line spaces precede the abstract. The
    abstract must be limited to one paragraph.
  ],
  bibliography: bibliography("main.bib"),
  appendix: include "appendix.typ",
  accepted: false,
  review: "https://openreview.net/forum?id=XXXX",
)

#let url(uri) = {
  link(uri, raw(uri))
}

= Submission of papers to TMLR

TMLR requires electronic submissions, processed by
#url("https://openreview.net/"). See TMLR's website for more instructions.

If your paper is ultimately accepted, use option `accepted` with the `tmlr`
package to adjust the format to the camera ready requirements, as follows:

#align(center, ```tex
\usepackage[accepted]{tmlr}
```)

You also need to specify the month and year by defining variables `month` and
`year`, which respectively should be a 2-digit and 4-digit number. To
de-anonymize and remove mentions to TMLR (for example for posting to preprint
servers), use the preprint option, as in `\usepackage[preprint]{tmlr}`.

Please read carefully the instructions below, and follow them faithfully.

== Style

Papers to be submitted to TMLR must be prepared according to the instructions
presented here.

Authors are required to use the TMLR #LaTeX style files obtainable at the TMLR
website. Please make sure you use the current files and not previous versions.
Tweaking the style files may be grounds for rejection.

== Retrieval of style files

The style files for TMLR and other journal information are available online on
the TMLR website. The file `tmlr.pdf` contains these instructions and
illustrates the various formatting requirements your TMLR paper must satisfy.
Submissions must be made using #LaTeX and the style files `tmlr.sty` and
`tmlr.bst` (to be used with #LaTeX2e). The file `tmlr.tex` may be used as a
"shell" for writing your paper. All you have to do is replace the author,
title, abstract, and text of the paper with your own.

The formatting instructions contained in these style files are summarized in
sections #ref(<gen_inst>, supplement: none), #ref(<headings>, supplement:
none), and #ref(<others>, supplement: none) below.

= General formatting instructions <gen_inst>

The text must be confined within a rectangle 6.5~inches wide and 9~inches long.
The left margin is 1~inch. Use 10~point type with a vertical spacing of
11~points. Computer Modern Bright is the preferred typeface throughout.
Paragraphs are separated by 1/2~line space, with no indentation.

Paper title is 17~point, in bold and left-aligned. All pages should start at
1~inch from the top of the page.

Authors' names are set in boldface. Each name is placed above its corresponding
address and has its corresponding email contact on the same line, in italic and
right aligned. The lead author's name is to be listed first, and the
co-authors' names are set to follow vertically.

Please pay special attention to the instructions in section #ref(<others>,
supplement: none) regarding figures, tables, acknowledgments, and references.

= Headings: first level <headings>

First level headings are in bold, flush left and in point size 12. One line
space before the first level heading and 1/2~line space after the first level
heading.

== Headings: second level

Second level headings are in bold, flush left and in point size 10. One line
space before the second level heading and 1/2~line space after the second level
heading.

=== Headings: third level

Third level headings are in bold, flush left and in point size 10. One line
space before the third level heading and 1/2~line space after the third level
heading.

= Citations, figures, tables, references <others>

These instructions apply to everyone, regardless of the formatter being used.

== Citations within the text

Citations within the text should be based on the `natbib` package and include
the authors' last names and year (with the "et~al." construct for more than two
authors). When the authors or the publication are included in the sentence, the
citation should not be in parenthesis, using `\citet{}` (as in "See
#cite(<Hinton06>, form: "prose") for more information."). Otherwise, the
citation should be in parenthesis using `\citep{}` (as in "Deep learning shows
promise to make progress towards AI~@Bengio2007.").

The corresponding references are to be listed in alphabetical order of authors,
in the *References* section. As to the format of the references themselves, any
style is acceptable as long as it is used consistently.

== Footnotes

Indicate footnotes with a number#footnote[Sample of the first footnote] in the
text. Place the footnotes at the bottom of the page on which they appear.
Precede the footnote with a horizontal rule of 2~inches.#footnote[Sample of the
second footnote]

== Figures

All artwork must be neat, clean, and legible. Lines should be dark enough for
purposes of reproduction; art work should not be hand-drawn. The figure number
and caption always appear after the figure. Place one line space before the
figure caption, and one line space after the figure. The figure caption is
lower case (except for first word and proper nouns); figures are numbered
consecutively.

Make sure the figure caption does not get separated from the figure. Leave
sufficient space to avoid splitting the figure and figure caption.

You may use color figures. However, it is best for the figure captions and the
paper body to make sense if the paper is printed either in black/white or in
color.

#figure(
  rect(width: 4.2cm + 0.8pt, height: 4.20cm + 0.8pt, stroke: 0.4pt),
  caption: [Sample figure caption.])

== Tables

All tables must be centered, neat, clean and legible. Do not use hand-drawn
tables. The table number and title always appear before the table. See
@sample-table. Place one line space before the table title, one line space
after the table title, and one line space after the table. The table title must
be lower case (except for first word and proper nouns); tables are numbered
consecutively.

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (x, y) => if y == 0 { center } else { left },
    table.header([*PART*],   [*DESCRIPTION*]),
    table.hline(stroke: 0.5pt),
    [Dendrite], [Input terminal],
    [Axon    ], [Output terminal],
    [Soma    ], [Cell body (contains cell nucleus)]),
  caption: [Sample table title],
  placement: top) <sample-table>

= Default Notation

In an attempt to encourage standardized notation, we have included the notation
file from the textbook, _Deep Learning_ @goodfellow2016deep available at
#url("https://github.com/goodfeli/dlbook_notation/").  Use of this style is not
required and can be disabled by commenting out `math_commands.tex`.

#v(2em, weak: true)

#align(center, [*Numbers and Arrays*])
#table(
  columns: (1in + 5pt, 3.25in + 15pt),
  inset: 5pt,
  stroke: none,
  $a$,         [A scalar (integer or real)],
  $bold(a)$,   [A vector],
  $bold(A)$,   [A matrix],
  $bold(upright(sans(A)))$, [A tensor],
  $bold(I)_n$, [Identity matrix with $n$ rows and $n$ columns],
  $bold(I)$,   [Identity matrix with dimensionality implied by context],
  $bold(e)^((i))$, [Standard basis vector $[0,dots,0,1,0,dots,0]$ with a 1 at position $i$],
  $op("diag")(bold(a))$, [A square, diagonal matrix with diagonal entries given by $bold(a)$],
  $upright(a)$,       [A scalar random variable],
  $bold(upright(a))$, [A vector-valued random variable],
  $bold(upright(A))$, [A matrix-valued random variable])

#v(0.25cm, weak: true)

#align(center, [*Sets and Graphs*])
#table(
  columns: (1.25in + 5pt, 3.25in + 5pt),
  inset: 5pt,
  stroke: none,
  $AA$, [A set],
  $RR$, [The set of real numbers],
  $\{0, 1\}$, [The set containing 0 and 1],
  $\{0, 1, dots, n \}$, [The set of all integers between $0$ and $n$],
  $[a, b]$, [The real interval including $a$ and $b$],
  $(a, b]$, [The real interval excluding $a$ but including $b$],
  $AA \\ BB$, [Set subtraction, i.e., the set containing the elements of $AA$ that are not in $BB$],
  $cal(G)$, [A graph],
  $italic(P a)_cal(G)(upright(x)_i)$, [The parents of $upright(x)_i$ in $cal(G)$])

#v(0.25cm, weak: true)

#align(center, [*Indexing*])
#table(
  columns: (1.25in + 5pt, 3.25in + 5pt),
  inset: 5pt,
  stroke: none,
  $a_i$, [Element $i$ of vector $bold(a)$, with indexing starting at 1],
  $a_(-i)$, [All elements of vector $bold(a)$ except for element $i$],
  $A_(i, j)$, [Element $i, j$ of matrix $bold(A)$],
  $bold(A)_(i, :)$, [Row $i$ of matrix $bold(A)$],
  $bold(A)_(:, i)$, [Column $i$ of matrix $bold(A)$],
  $sans(A)_(i, j, k)$, [Element $(i, j, k)$ of a 3-D tensor $bold(upright(sans(A)))$],
  $bold(upright(sans(A)))_(:, :, i)$, [2-D slice of a 3-D tensor],
  $upright(a)_i$, [Element $i$ of the random vector $bold(upright(a))$])

#v(0.25cm, weak: true)

#align(center, [*Calculus*])
#table(
  columns: (1.25in + 5pt, 3.25in + 5pt),
  inset: 5pt,
  stroke: none,
  $display((d y) / (d x))$, [Derivative of $y$ with respect to $x$],
  $display((diff y) / (diff x))$, [Partial derivative of $y$ with respect to $x$],
  $nabla_bold(x) y$, [Gradient of $y$ with respect to $bold(x)$],
  $nabla_bold(X) y$, [Matrix derivatives of $y$ with respect to $bold(X)$],
  $nabla_bold(upright(sans(X))) y$, [Tensor containing derivatives of $y$ with respect to $bold(upright(sans(X)))$],
  $display((diff f) / (diff bold(x)))$, [Jacobian matrix $bold(J) in RR^(m times n)$ of $f: RR^n arrow.r RR^m$],
  $nabla_bold(x)^2 f(bold(x)) "or" bold(H)(f)(bold(x))$, [The Hessian matrix of $f$ at input point $bold(x)$],
  $display(integral f(bold(x)) d bold(x))$,
  [Definite integral over the entire domain of $bold(x)$],
  $display(integral_SS f(bold(x)) d bold(x))$,
  [Definite integral with respect to $bold(x)$ over the set $SS$])

#v(0.25cm, weak: true)

#align(center, [*Probability and Information Theory*])
#table(
  columns: (1.25in + 5pt, 3.25in + 5pt),
  inset: 5pt,
  stroke: none,
  $P(upright(a))$, [A probability distribution over a discrete variable],
  $p(upright(a))$, [A probability distribution over a continuous variable, or over a variable whose type has not been specified],
  $upright(a) tilde P$, [Random variable $upright(a)$ has distribution $P$],
  $EE_(upright(x) tilde P) [ f(x) ] "or" EE f(x)$, [Expectation of $f(x)$ with respect to $P(upright(x))$],
  $op("Var")(f(x))$,       [Variance of $f(x)$ under $P(upright(x))$],
  $op("Cov")(f(x), g(x))$, [Covariance of $f(x)$ and $g(x)$ under $P(upright(x))$],
  $H(upright(x))$,   [Shannon entropy of the random variable $upright(x)$],
  $D_"KL" (P || Q)$, [Kullback-Leibler divergence of $P$ and $Q$],
  $cal(N)(bold(x); bold(mu), bold(Sigma))$, [Gaussian distribution over $bold(x)$ with mean $bold(mu)$ and covariance $bold(Sigma)$])

#v(0.25cm, weak: true)

#align(center, [*Functions*])
#table(
  columns: (1.25in + 5pt, 3.25in + 5pt),
  inset: 5pt,
  stroke: none,
  $f: AA arrow.r BB$, [The function $f$ with domain $AA$ and range $BB$],
  $f circle.stroked.tiny g$, [Composition of the functions $f$ and $g$],
  $f(bold(x); bold(theta))$,
  [A function of $bold(x)$ parametrized by $bold(theta)$. (Sometimes we write
  $f(bold(x))$ and omit the argument $bold(theta)$ to lighten notation)],
  $log x$,    [Natural logarithm of $x$],
  $sigma(x)$, [Logistic sigmoid, $display(1 / (1 + exp(-x)))$],
  $zeta(x)$,  [Softplus, $log(1 + exp(x))$],
  $norm(bold(x))_p$, [$L^p$ norm of $bold(x)$],
  $norm(bold(x))$,   [$L^2$ norm of $bold(x)$],
  $x^+$, [Positive part of $x$, i.e., $max(0,x)$],
  $bold(1)_"condition"$, [is 1 if the condition is true, 0 otherwise])

#v(0.25cm, weak: true)

// We add page break here in order to align the end of the paper.
#pagebreak()

= Final instructions

Do not change any aspects of the formatting parameters in the style files. In
particular, do not modify the width or length of the rectangle the text should
fit into, and do not change font sizes (except perhaps in the *References*
section; see below). Please note that pages should be numbered.

= Preparing PostScript or PDF files

Please prepare PostScript or PDF files with paper size "US Letter", and not,
for example, "A4". The -t letter option on dvips will produce US Letter files.

Consider directly generating PDF files using `pdflatex` (especially if you are
a MiKTeX user). PDF figures must be substituted for EPS figures, however.

Otherwise, please generate your PostScript and PDF files with the following
commands:

```shell
dvips mypaper.dvi -t letter -Ppdf -G0 -o mypaper.ps
ps2pdf mypaper.ps mypaper.pdf
```

== Margins in LaTeX

Most of the margin problems come from figures positioned by hand using
`\special` or other commands. We suggest using the command `\includegraphics`
from the graphicx package. Always specify the figure width as a multiple of the
line width as in the example below using .eps graphics

```tex
   \usepackage[dvips]{graphicx} ...
   \includegraphics[width=0.8\linewidth]{myfile.eps}
```

or

```tex
   \usepackage[pdftex]{graphicx} ...
   \includegraphics[width=0.8\linewidth]{myfile.pdf}
```

for .pdf graphics. See section~4.4 in the graphics bundle documentation
(#url("http://www.ctan.org/tex-archive/macros/latex/required/graphics/grfguide.ps")

A number of width problems arise when #LaTeX cannot properly hyphenate a line.
Please give LaTeX hyphenation hints using the `\-` command.

= Broader Impact Statement

In this optional section, TMLR encourages authors to discuss possible
repercussions of their work, notably any potential negative impact that a user
of this research should be aware of. Authors should consult the TMLR Ethics
Guidelines available on the TMLR website for guidance on how to approach this
subject.

= Author Contributions

If you'd like to, you may include a section for author contributions as is done
in many journals. This is optional and at the discretion of the authors. Only
add this information once your submission is accepted and deanonymized.

= Acknowledgments

Use unnumbered third level headings for the acknowledgments. All
acknowledgments, including those to funding agencies, go at the end of the
paper. Only add this information once your submission is accepted and
deanonymized.
