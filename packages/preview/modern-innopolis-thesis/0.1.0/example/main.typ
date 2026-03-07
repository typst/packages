#import "@preview/modern-innopolis-thesis:0.1.0": *

#title-page(
  program-code: "09.04.01",
  program-ru: "Информатика и вычислительная техника",
  program-en: "Computer Science",
  work-ru: "МАГИСТЕРСКАЯ ДИССЕРТАЦИЯ",
  work-en: "MASTER GRADUATE THESIS",
  specialty-ru: "Анализ данных и искусственный интеллект",
  specialty-en: "Data Analysis and Artificial Intelligence",
  topic-ru: "Применение существующих бизнес-моделей к продуктам, созданным на платформе Telegram",
  topic-en: "Application of existing business models to product on Telegram platform",
  author-ru: "Иванов Иван Иванович",
  author-en: "Ivanov Ivan Ivanovich",
  supervisor-ru: "Иванов Иван Иванович",
  supervisor-en: "Ivanov Ivan Ivanovich",
  consultants: "Иванов Иван Иванович / Ivanov Ivan Ivanovich",
  year: "2025",
)

#show: thesis.with(
  abstract: lorem(100),
  // font-family: "Tempora LGC Uni" // Install font: https://www.fonts.uprock.ru/fonts/tempora-lgc-uni
)

= Introduction <intro>

== Spacing & Type

This is a section. This is a citation without brackets. and this is one with brackets @A. Multiple @A, @B, @C. Here's a reference to a subsection: #ref(<subsection>, supplement: []). Citation of an online article @D. Citation of an online proceeding @F. The body of the text and abstract must be double-spaced except for footnotes or long quotations. Fonts such as Times Roman, Bookman, New Century Schoolbook, Garamond, Palatine, and Courier are acceptable and commonly found on most computers. The same type must be used throughout the body of the text. The font size must be 10 point or larger and footnotes #footnote[This is a footnote.] must be two sizes smaller than the text #footnote[This is another footnote.] but no smaller than eight points. Chapter, section, or other headings should be of a consistent font and size throughout the ETD, as should labels for illustrations, charts, and figures.

\ \

=== Creating a subsection <subsection>

==== Creating a subsubsection
==== Creating a subsubsection
==== Creating a subsubsection

#par(first-line-indent: 0em)[*This is a heading level below subsubsection* #h(0.5em) And this is a quote:]

#quote[#lorem(50)] \

This is a _fancy_ table:

#align(center)[
  #figure(
    caption: [#flex-title([This is a Table Example], [This is the title I want to appear in the list of tables])],
    table(
      columns: 3,
      inset: 0.5em,
      table.header([A], [B], [C]),
      stroke: (left: none),
      table.vline(stroke: none, start: 0, end: 5),
      [a1], [b1], [c1],
      table.hline(stroke: none, start: 0, end: 3),
      [a2], [b2], [c2],
      table.hline(stroke: none, start: 0, end: 3),
      [a3], [b3], [c3],
      table.hline(stroke: none, start: 0, end: 3),
      [a4], [b4], [c4],
    ),
    supplement: "TABLE",
  )
]

#align(center)[
  #figure(
    image("figs/images.png"),
    caption: [One kernel at $x_s$ (#emph[dotted kernel]) or two kernels at $x_i$ and $x_j$ (_left and right_) lead to the same summed estimate at $x_s$. This shows a figure consisting of different types of lines. Elements of the figure described in the caption should be set in italics, in parentheses, as shown in this sample caption.],
  )
]

Typst supports non-italicized lower-case greek letters. See for yourself: $upright(beta), bold(upright(beta)), beta, bold(beta)$. Next is a numbered equation:

$
  |bold(X)|_(2,1) = underbrace(sum_(j=1)^n f_j(bold(X)), "convex") = sum_(j=1)^n |X_(.,j)|_2
$ <equation>

The reference to equation #ref(<equation>, supplement: []) is clickable.

== Theorems, Corollaries, Lemmas, Proofs, Remarks, Definitions and Examples

#theorem[
  #lorem(100),
] <thm>

#proof[
  I'm a (very short) proof.
]

#lemma[
  I'm a lemma.
]

#corollary[
  I include a reference to #link(<thm>)[Theorem 1]
]

#proposition[
  I'm a proposition.
]

#remark[
  I'm a remark.
]

#definition[
  I'm a definition. I'm a definition. I'm a definition. I'm a definition. I'm a definition. I'm a definition. I'm a definition. I'm a definition. I'm a definition. I'm a definition. I'm a definition.
]

#example[
  I'm an example.
]

== #flex-title([Section with \ line breaks in \ the name], [Optional table of contents heading])

#lorem(100)

= Literature Review <lr>

#lorem(200)

== Another section

#lorem(100)

#pagebreak()

#lorem(150)

#align(center)[
  #figure(
    caption: [#flex-title([Simulation Parameters], [This is the title I want to appear in the list of tables])],
    table(
      columns: (1fr, 1fr),
      align: center,
      table.header([A], [B]),
      stroke: (left: none),
      table.vline(stroke: none, start: 0, end: 13),
      inset: 0.5em,
      [*Parameter*], [*Value*],
      [Number of vehicles], [$|cal(V)|$],
      [Number of RSUs], [$|cal(U)|$],
      [RSU coverage radius], [150 m],
      [V2V communication radius], [30 m],
      [Smart vehicle antenna height], [1.5 m],
      [RSU antenna height], [25 m],
      [Smart vehicle maximum speed], [$v_"max"$ m/s],
      [Smart vehicle minimum speed], [$v_"min"$ m/s],
      [Common smart vehicle cache capacities], [[50, 100, 150, 200, 250] mb],
      [Common RSU cache capacities], [[5000, 1000, 1500, 2000, 2500] mb],
      [Common backhaul rates], [[75, 100, 150] mb/s],
    ),
    supplement: "TABLE",
  )
]

#align(center)[
  #figure(
    image("figs/images.png"),
    caption: [One kernel at $x_s$ (#emph[dotted kernel]) or two kernels at $x_i$ and $x_j$ (_left and right_) lead to the same summed estimate at $x_s$. This shows a figure consisting of different types of lines. Elements of the figure described in the caption should be set in italics, in parentheses, as shown in this sample caption.],
  )
]

\

This description implies several essential properties of the task at hand:

1. Watermark must contain all necessary information, but still, be placeable and recognizable even on smaller images. The produced watermark must be compact but have the possibility to store enough information.
2. To prevent easy tampering, the watermark must be invisible to the naked eye (and, preferably, to basic image parsing tools). If malefactor does not know about the existence of watermark, they might not even try to remove it and disable it.


= Methodology <method>

Referencing other chapters #ref(<lr>, supplement: []), #ref(<method>, supplement: []), #ref(<impl>, supplement: []), #ref(<eval>, supplement: []) and #ref(<concl>, supplement: [])


#align(center)[
  #figure(
    caption: [#flex-title([Simulation Parameters], [This is the title I want to appear in the list of tables])],
    table(
      columns: (1fr, 1fr),
      align: center,
      table.header([A], [B]),
      stroke: (left: none),
      table.vline(stroke: none, start: 0, end: 13),
      inset: 0.5em,
      [*Parameter*], [*Value*],
      [Number of vehicles], [$|cal(V)|$],
      [Number of RSUs], [$|cal(U)|$],
      [RSU coverage radius], [150 m],
      [V2V communication radius], [30 m],
      [Smart vehicle antenna height], [1.5 m],
      [RSU antenna height], [25 m],
      [Smart vehicle maximum speed], [$v_"max"$ m/s],
      [Smart vehicle minimum speed], [$v_"min"$ m/s],
      [Common smart vehicle cache capacities], [[50, 100, 150, 200, 250] mb],
      [Common RSU cache capacities], [[5000, 1000, 1500, 2000, 2500] mb],
      [Common backhaul rates], [[75, 100, 150] mb/s],
    ),
    supplement: "TABLE",
  )
]

= Implementation <impl>

...

= Evaluation and Discussion <eval>

...

= Conclusion <concl>

...

#bibliography(
  title: "Bibliography cited",
  "refs.bib",
)

#show: appendix

= Extra Stuff

#lorem(100)

= Even More Extra Stuff

#lorem(100)
