#import "@preview/blind-cvpr:0.5.0": cvpr2025, conf-name, conf-year, eg, etal, indent
#import "/logo.typ": LaTeX, TeX

#let affls = (
  one: (institution: "Institution1", location: "Institution1 address"),
  two: (
    institution: "Institution2",
    location: "First line of institution1 address"),
  airi: ("AIRI", "Moscow", "Russia"),
  skoltech: (
    department: "AI Center",
    institution: "Skoltech",
    location: "Moscow",
    country: "Russia"),
)

#let authors = (
  (name: "First Author", affl: ("one", ), email: "firstauthor@i1.org"),
  (name: "Second Author", affl: ("two", ), email: "secondauthor@i2.org"),
)

#show: cvpr2025.with(
  title: [#LaTeX Author Guidelines for #conf-name~Proceedings],
  authors: (authors, affls),
  keywords: (),
  abstract: [
    The ABSTRACT is to be in fully justified italicized text, at the top of the
    left-hand column, below the author and affiliation information. Use the
    word "Abstract" as the title, in 12-point Times, boldface type, centered
    relative to the column, initially capitalized. The abstract is to be in
    10-point, single-spaced type. Leave two blank lines after the Abstract,
    then begin the main text. Look at previous CVPR abstracts to get a feel for
    style and length.
  ],
  bibliography: bibliography("main.bib"),
  accepted: false,
  id: none,
)

= Introduction <sec:intro>

Please follow the steps outlined below when submitting your manuscript to the
IEEE Computer Society Press. This style guide now has several important
modifications (for example, you are no longer warned against the use of sticky
tape to attach your artwork to the paper), so all authors should read this new
version.

== Language

All manuscripts must be in English.

== Dual submission

Please refer to the author guidelines on the #conf-name #conf-year web page for
a discussion of the policy on dual submissions.

== Paper length

Papers, excluding the references section, must be no longer than eight pages in
length. The references section will not be included in the page count, and
there is no limit on the length of the references section. For example, a paper
of eight pages with two pages of references would have a total length of 10
pages. *There will be no extra page charges for #conf-name #conf-year.*

Overlength papers will simply not be reviewed. This includes papers where the
margins and formatting are deemed to have been significantly altered from those
laid down by this style guide. Note that this #LaTeX guide already sets figure
captions and references in a smaller font. The reason such papers will not be
reviewed is that there is no provision for supervised revisions of manuscripts.
The reviewing process cannot determine the suitability of the paper for
presentation in eight pages if it is reviewed in eleven.

== The ruler

The #LaTeX style defines a printed ruler which should be present in the version
submitted for review. The ruler is provided in order that reviewers may comment
on particular lines in the paper without circumlocution. If you are preparing a
document using a non-#LaTeX document preparation system, please arrange for an
equivalent ruler to appear on the final output pages. The presence or absence
of the ruler should not change the appearance of any other content on the page.
The camera-ready copy should not contain a ruler. (#LaTeX users may use options
of `cvpr.sty` to switch between different versions.)

Reviewers: note that the ruler measurements do not align well with lines in the
paper --- this turns out to be very difficult to do well when the paper
contains many figures and equations, and, when done, looks ugly. Just use
fractional references (#eg., this line is $087.5$), although in most cases one
would expect that the approximate location will be adequate.

== Paper ID

Make sure that the Paper ID from the submission system is visible in the
version submitted for review (replacing the "\*\*\*\*\*" you see in this
document). If you are using the #LaTeX template, *make sure to update paper ID
in the appropriate place in the tex file*.

== Mathematics

Please number all of your sections and displayed equations as in these
examples:

$ E = m dot.c c^2 $ <eq:important>

and

$ v = a dot.c t. $ <eq:also-important>

It is important for readers to be able to refer to any particular equation.
Just because you did not refer to it in the text does not mean some future
reader might not need to refer to it. It is cumbersome to have to use
circumlocutions like "the equation second from the top of page 3 column 1".
(Note that the ruler will not be present in the final copy, so is not an
alternative to equation numbers). All authors will benefit from reading
Mermin's description of how to write mathematics:
#link("http://www.pamitc.org/documents/mermin.pdf").

== Blind review

Many authors misunderstand the concept of anonymizing for blind review. Blind
review does not mean that one must remove citations to one's own work --- in
fact it is often impossible to review a paper unless the previous citations are
known and available.

Blind review means that you do not use the words "my" or "our" when citing
previous work. That is all. (But see below for tech reports.)

Saying "this builds on the work of Lucy Smith [1]" does not say that you are
Lucy Smith; it says that you are building on her work. If you are Smith and
Jones, do not say "as we show in [7]", say "as Smith and Jones show in [7]" and
at the end of the paper, include reference 7 as you would any other cited work.

An example of a bad paper just asking to be rejected:

#quote(block: true)[
  #h(1.5em)
  An analysis of the frobnicatable foo filter.

  In this paper we present a performance analysis of our previous paper [1],
  and show it to be inferior to all previously known methods. Why the previous
  paper was accepted without this analysis is beyond me.

  [1] Removed for blind review
]

An example of an acceptable paper:

#quote(block: true)[
  #h(1.5em)
  An analysis of the frobnicatable foo filter.

  In this paper we present a performance analysis of the  paper of Smith #etal
  [1], and show it to be inferior to all previously known methods. Why the
  previous paper was accepted without this analysis is beyond me.

  [1] Smith, L and Jones, C. "The frobnicatable foo filter, a fundamental
  contribution to human knowledge". Nature 381(12), 1-213.
]

#indent
If you are making a submission to another conference at the same time, which
covers similar or overlapping material, you may need to refer to that
submission in order to explain the differences, just as you would if you had
previously published related work. In such cases, include the anonymized
parallel submission~@Authors14 as supplemental material and cite it as

#quote(block: true)[
  [1] Authors. "The frobnicatable foo filter", F\&G 2014 Submission ID 324,
  Supplied as supplemental material `fg324.pdf`.
]

#indent
Finally, you may feel you need to tell the reader that more details can be
found elsewhere, and refer them to a technical report. For conference
submissions, the paper must stand on its own, and not _require_ the reviewer to
go to a tech report for further details. Thus, you may say in the body of the
paper "further details may be found in~@Authors14b". Then submit the tech
report as supplemental material. Again, you may not assume the reviewers will
read this material.

Sometimes your paper is about a problem which you tested using a tool that is
widely known to be restricted to a single institution. For example, let's say
it's 1969, you have solved a key problem on the Apollo lander, and you believe
that the CVPR70 audience would like to hear about your solution. The work is a
development of your celebrated 1968 paper entitled "Zero-g frobnication: How
being the only people in the world with access to the Apollo lander source code
makes us a wow at parties", by Zeus #etal.

You can handle this paper like any other. Do not write "We show how to improve
our previous work [Anonymous, 1968]. This time we tested the algorithm on a
lunar lander [name of lander removed for blind review]". That would be silly,
and would immediately identify the authors. Instead write the following:

#quote(block: true)[
  We describe a system for zero-g frobnication. This system is new because it
  handles the following cases: A, B.  Previous systems [Zeus et al. 1968] did
  not  handle case B properly. Ours handles it by including a foo term in the
  bar integral.
  #linebreak()
  #indent
  ...
  #linebreak()
  #indent
  The proposed system was integrated with the Apollo lunar lander, and went all
  the way to the moon, don't you know. It displayed the following behaviours,
  which show how well we solved cases A and B: ...
]

As you can see, the above text follows standard scientific convention, reads
better than the first version, and does not explicitly name you as the authors.
A reviewer might think it likely that the new paper was written by Zeus #etal,
but cannot make any decision based on that guess. He or she would have to be
sure that no other authors could have been contracted to solve problem B.

#v(16pt, weak: true)
#block[
FAQ

\
*Q:* Are acknowledgements OK? \
*A:* No.  Leave them for the final copy.

\
*Q:* How do I cite my results reported in open challenges? \
*A:* To conform with the double-blind review policy, you can report results of
other challenge participants together with your results in your paper. For your
results, however, you should not identify yourself and should not mention your
participation in the challenge. Instead present your results referring to the
method proposed in your paper and draw conclusions based on the experimental
comparison to other results.
]

#figure(
  caption: [
    Example of caption. It is set in Roman so that mathematics (always set in
    Roman: $B sin A = A sin B$) may be included without an ugly clash.
  ],
  placement: top,
  kind: image,
  rect(width: 0.9 * 3.25in - 0.8pt, height: 2.1in - 0.8pt, stroke: 0.4pt),
) <fig:onecol>
\

== Miscellaneous

Compare the following:

#align(center, grid(
  columns: 2,
  align: left,
  gutter: 5pt,
  `conf_a`,          $c o n f_a$,
  `\mathit{conf}_a`, $italic("conf")_a$,
))

See The #TeX book, p165.

The space after #eg, meaning "for example", should not be a sentence-ending
space. So #eg is correct, _e.g._ is not. The provided `\eg` macro takes care of
this.

When citing a multi-author paper, you may save space by using "et alia",
shortened to "#etal" (not "_et.~al._" as "_et_" is a complete word). If you use
the `\etal` macro provided, then you need not worry about double periods when
used at the end of a sentence as in Alpher #etal. However, use it only when
there are three or more authors. Thus, the following is correct: "Frobnication
has been trendy lately. It was introduced by Alpher~@Alpher02, and subsequently
developed by Alpher and Fotheringham-Smythe~@Alpher03, and Alpher
#etal~@Alpher04."

This is incorrect: "... subsequently developed by Alpher #etal~@Alpher03 ..."
because reference~@Alpher03 has just two authors.

#show figure.where(kind: "subfigure"): it => {
  it.body
  v(-9pt)
  it.caption
}
#show figure.caption.where(kind: "subfigure"): it => {
  let ix = counter(figure.where(kind: "subfigure")).display("(a)")
  [#ix~#it.body]
}

#let fig2a = figure(
  caption: [An example of a subfigure.],
  supplement: [],
  kind: "subfigure",
  rect(width: 4in, height: 2in, stroke: 0.4pt))

#let fig2b = figure(
  caption: [Another example of a subfigure.],
  supplement: [],
  kind: "subfigure",
  rect(width: 2in, height: 2in, stroke: 0.4pt))

#let fig = block(width: 6.875in, height: 2.59in)[
  #figure(
    caption: [Example of a short caption, which should be centered.],
    placement: top,
    grid(
      columns: 2,
      column-gutter: 0.875in - 2 * 0.4pt,
      [#fig2a <fig2a>], [#fig2b <fig2b>],
    )
  ) <fig:short-a>
]

= Formatting your paper <sec:formatting>

All text must be in a two-column format. The total allowable size of the text
area is $6 7/8$ inches (17.46 cm) wide by $8 7/8$ inches (22.54 cm) high.
Columns are to be $3 1/4$ inches (8.25 cm) wide, with a $5/(16)$ inch (0.8 cm)
space between them. The main title (on the first page) should begin 1 inch
(2.54 cm) from the top edge of the page. The second and following pages should
begin 1 inch (2.54 cm) from the top edge. On all pages, the bottom margin
should be $1 1/8$ inches (2.86 cm) from the bottom edge of the page for $8.5
times 11$-inch paper; for A4 paper, approximately $1 5/8$ inches (4.13 cm) from
the bottom edge of the page.

== Margins and page numbering

All printed material, including text, illustrations, and charts, must be kept
within a print area $6 7/8$ inches (17.46 cm) wide by $8 7/8$ inches (22.54 cm)
high. Page numbers should be in the footer, centered and $3/4$ inches from the
bottom of the page. The review version should have page numbers, yet the final
version submitted as camera ready should not show any page numbers. The #LaTeX
template takes care of this when used properly.

== Type style and fonts

Wherever Times is specified, Times Roman may also be used. If neither is
available on your word processor, please use the font closest in appearance to
Times to which you have access.

MAIN TITLE. Center the title $1 3/8$ inches (3.49 cm) from the top edge of the
first page. The title should be in Times 14-point, boldface type. Capitalize
the first letter of nouns, pronouns, verbs, adjectives, and adverbs; do not
capitalize articles, coordinate conjunctions, or prepositions (unless the title
begins with such a word). Leave two blank lines after the title.

AUTHOR NAME(s) and AFFILIATION(s) are to be centered beneath the title and
printed in Times 12-point, non-boldface type. This information is to be
followed by two blank lines.

The ABSTRACT and MAIN TEXT are to be in a two-column format.

MAIN TEXT. Type main text in 10-point Times, single-spaced. Do NOT use
double-spacing. All paragraphs should be indented 1 pica (approx.~$1/6$ inch or
0.422 cm). Make sure your text is fully justified --- that is, flush left and
flush right. Please do not place any additional blank lines between paragraphs.

Figure and table captions should be 9-point Roman type as in
@fig:onecol[Figs.] and @fig:short-a[]. Short captions should be centred.\
Callouts should be 9-point Helvetica, non-boldface type. Initially
capitalize only the first word of section titles and first-, second-, and
third-order headings.

FIRST-ORDER HEADINGS. (For example, #box(text(size: 12pt)[*1. Introduction*]))
should be Times 12-point boldface, initially capitalized, flush left, with one
blank line before, and one blank line after.

SECOND-ORDER HEADINGS. (For example, #box(text(size: 11pt)[*1.1. Database
elements*])) should be Times 11-point boldface, initially capitalized, flush
left, with one blank line before, and one after. If you require a third-order
heading (we discourage it), use 10-point Times, boldface, initially
capitalized, flush left, preceded by one blank line, followed by a period and
your text on the same line.

#place(top, float: true, fig)

== Footnotes

Please use footnotes#footnote[This is what a footnote looks like. It often
distracts the reader from the main flow of the argument.] sparingly. Indeed,
try to avoid footnotes altogether and include necessary peripheral observations
in the text (within parentheses, if you prefer, as in this sentence). If you
wish to use a footnote, place it at the bottom of the column on the page on
which it is referenced. Use Times 8-point type, single-spaced.

== Cross-references

For the benefit of author(s) and readers, please use the

```tex
  \cref{...}
```

command for cross-referencing to figures, tables, equations, or sections. This
will automatically insert the appropriate label alongside the cross-reference
as in this example:

#quote(block: true)[
  #indent
  To see how our method outperforms previous work, please see @fig:onecol[Fig.]
  and @tab:example[Tab.]. It is also possible to refer to multiple targets as
  once, #eg~to @fig:onecol[Figs.] and @fig:short-a[]. You may also return to
  @sec:formatting[Sec.] or look at @eq:also-important.
]

If you do not wish to abbreviate the label, for example at the beginning of the
sentence, you can use the

```tex
  \Cref{...}
```

#indent
command. Here is an example:

#quote(block: true)[
  #indent
  @fig:onecol[Figure] is also quite important.
]

#place(top, float: true,
  block(width: 3.25in, height: fig.height)
)

== References

List and number all bibliographical references in 9-point Times, single-spaced,
at the end of your paper. When referenced in the text, enclose the citation
number in square brackets, for example~@Authors14. Where appropriate, include
page numbers and the name(s) of editors of referenced books. When you cite
multiple papers at once, please make sure that you cite them in numerical order
like this @Authors14 @Authors14b @Alpher02 @Alpher03 @Alpher05. If you use the
template as advised, this will be taken care of automatically.

#figure(
  caption: [Results. Ours is better.],
  placement: top,
  table(
    columns: 2,
    align: (left, center),
    row-gutter: 0pt,
    stroke: none,
    inset: (x, y) => (
      top: if y == 0 or y == 1 { 5pt } else { 2.6pt },
      bottom: if y == 0 or y == 3 { 5.4pt } else { 2.6pt },
      left: if x == 0 { 0pt } else { 5pt },
      right: if x == 1 { 5pt } else { 0pt },
    ),
    table.hline(stroke: 0.9pt),
    table.header([Method], [Frobnability]),
    table.hline(stroke: 0.4pt),
    [Theirs], [Frumpy],
    [Yours], [Frobbly],
    [Ours], [Makes one's heart Frob],
    table.hline(stroke: 0.9pt),
)) <tab:example>

== Illustrations, graphs, and photographs

All graphics should be centered. In #LaTeX, avoid using the `center`
environment for this purpose, as this adds potentially unwanted whitespace.
Instead use

```tex
  \centering
```

at the beginning of your figure. Please ensure that any point you wish to make
is resolvable in a printed copy of the paper. Resize fonts in figures to match
the font in the body text, and choose line widths that render effectively in
print. Readers (and reviewers), even of an electronic copy, may choose to print
your paper in order to read it. You cannot insist that they do otherwise, and
therefore must not assume that they can zoom in to see tiny details on a
graphic.

When placing figures in #LaTeX, it's almost always best to use
`\includegraphics`, and to specify the figure width as a multiple of the line
width as in the example below

```tex
  \usepackage{graphicx} ...
  \includegraphics[width=0.8\linewidth]
                  {myfile.pdf}
```

== Color

Please refer to the author guidelines on the #conf-name #conf-year web page for
a discussion of the use of color in your document.

If you use color in your plots, please keep in mind that a significant subset
of reviewers and readers may have a color vision deficiency; red-green
blindness is the most frequent kind. Hence avoid relying only on color as the
discriminative feature in plots (such as red \vs green lines), but add a second
discriminative feature to ease disambiguation.

= Final copy

You must include your signed IEEE copyright release form when you submit your
finished paper. We MUST have this form before your paper can be published in
the proceedings.

Please direct any questions to the production editor in charge of these
proceedings at the IEEE Computer Society Press:
#link("https://www.computer.org/about/contact").
