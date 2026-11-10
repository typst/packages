#import "@preview/texst:0.1.0": paper, nneq, caption-note, table-note, theorem, proof, prop, lem, rem, ass, cmain, csub, caption-with-note

#show: doc => paper(
  title: [Title],
  subtitle: [Subtitle],
  authors: (
    (
      name: text()[Author Name#footnote(numbering:"*")[Affiliation]],
    ),
  ),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  abstract:
  text()[
    This is the abstract for the paper. It summarizes the key objectives, findings, and significance of the research. The abstract provides a succinct overview, including the methodology and principal results, allowing readers to quickly grasp the purpose and contributions of the work. Replace this placeholder with your full abstract describing the context, main outcomes, and insights presented in the paper.
  ],
  doc,
)

#heading(outlined: false, level: 1)[Introduction]

This is some placeholder text for the introduction. You can replace this with your actual content.
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas in quam eu magna egestas dictum.
Aliquam erat volutpat. Nulla facilisi. Pellentesque cursus bibendum magna, quis tincidunt quam blandit sed.
Donec dapibus, nisi nec laoreet egestas, sem arcu varius leo, eget cursus nisi erat vitae nibh @tab:sample_table.

#nneq($
  alpha = beta + gamma
$)

#figure(
  placement: none,
  block(width: 80%)[
  //   #columns(
  //     gutter: 2em,
  //     [
  //       #image(
  //         "",
  //         width: 100%,
  //         alt: "Sample Photo 1"
  //       )
  //     ],
  //     [
  //       #image(
  //         "",
  //         width: 100%,
  //         alt: "Sample Photo 2"
  //       )
  //     ]
  //   )
  ],
  caption: [Sample figure with two column photos]
)


#figure(
  placement: none,
  block(width: 100%)[
    #set text(size: 0.8em)
    #table(
      columns: 7,
      align: (left, center, center, center, center, center, center),
      inset: (x: 5pt, y: 4pt),
      stroke: none,
      table.hline(stroke: 1.2pt),
      [Sample Outcome:], table.cell(colspan: 6)[_Sample Measure per Unit_],
      [Sample Model:], [(A)], [(B)], [(C)], [(D)], [(E)], [(F)],
      table.hline(stroke: 0.7pt),
      [Sample Effect 1], [$1.1111^(**)$ #linebreak() (0.0101)], [$1.2222^(**)$ #linebreak() (0.0112)], [$1.3333^(**)$ #linebreak() (0.0123)], [$1.4444^(*)$ #linebreak() (0.0134)], [$1.5555^(**)$ #linebreak() (0.0145)], [$1.6666^(**)$ #linebreak() (0.0156)],
      [Sample Effect 2], [$2.1111^(***)$ #linebreak() (0.0165)], [$2.2222^(***)$ #linebreak() (0.0170)], [$2.3333^(***)$ #linebreak() (0.0181)], [$2.4444^(***)$ #linebreak() (0.0192)], [$2.5555^(***)$ #linebreak() (0.0203)], [$2.6666^(***)$ #linebreak() (0.0214)],
      [Sample Covariate 1], [], [], [], [0.1010 #linebreak() (0.0222)], [$-0.2020$ #linebreak() (0.0233)], [$-0.3030$ #linebreak() (0.0244)],
      [Sample Covariate 2], [], [], [], [$-0.1111$ #linebreak() (0.0137)], [0.2222 #linebreak() (0.0148)], [0.3333 #linebreak() (0.0159)],
      [Sample Covariate 3], [], [], [], [$-0.4444$ #linebreak() (0.0162)], [$-0.5555$ #linebreak() (0.0173)], [$-0.6666$ #linebreak() (0.0184)],
      [Sample Group 4], [], [], [], [0.5050 #linebreak() (0.0195)], [0.6060 #linebreak() (0.0206)], [0.7070 #linebreak() (0.0217)],
      table.hline(stroke: 0.4pt),
      [Sample Mean], [1.111], [1.222], [1.333], [1.444], [1.555], [1.666],
      table.hline(stroke: 0.4pt),
      [_Sample Controls_], [], [], [], [], [], [],
      [Sample FE 1], [Yes], [Yes], [Yes], [Yes], [Yes], [Yes],
      [Sample FE 2], [Yes], [Yes], [Yes], [Yes], [Yes], [Yes],
      table.hline(stroke: 0.4pt),
      [_Sample Fit Statistics_], [], [], [], [], [], [],
      [Sample Observations], [123], [234], [345], [456], [567], [678],
      [$R^2$], [0.777], [0.888], [0.999], [0.555], [0.666], [0.444],
      [Within $R^2$], [0.111], [0.222], [0.333], [0.444], [0.555], [0.666],
      table.hline(stroke: 1.2pt),
      table.cell(colspan: 7, table-note([Sample note for errors in round brackets.#linebreak()Signif. Codes: $.^(***)$: 0.001, $.^(**)$: 0.01, $.^(*)$: 0.05, $.^(+)$: 0.1.]))
    )
  ],
  caption: caption-with-note([Sample Title], [This is a sample caption for the table, describing its structure and what the numbers represent. Replace as needed.]),
)<tab:sample_table>

#heading(outlined: false, numbering: none, level: 1)[References]

#bibliography(
  "ref.bib",
  style: "american-political-science-association",
  title: none
)

#pagebreak()

#counter(figure).update(0)
#set figure(numbering: (..n) => "A." + numbering("1", n.at(0)))

#counter(heading).update(0)
#set heading(
  numbering: "A.1.",
  supplement: "Appendix"
)

#align(center)[
  #smallcaps(text(1.2em)[*Appendix*])
]

#show outline.entry: it => link(
  it.element.location(),
  it.indented(it.prefix(), it.inner()),
)
#outline()

#pagebreak()
#heading(level: 1)[Omitted Empirical Results]
