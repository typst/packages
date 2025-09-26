// #import "lib/lib.typ": thesis
#import "@preview/modern-hkust-thesis:0.1.0": thesis
#import "@preview/booktabs:0.0.4": *
#import "@preview/abbr:0.2.3": load, a as acro

#show: thesis.with(
  title: [YOUR TITLE HERE (title Case is adjusted Automatically)],
  author: "YOUR NAME",
  program: "BSBE", // or AI, IoT, etc.
  date: (2025, 12, 30),
  degree: "Mphil", // or PhD
  supervisor: "Name A",
  co-supervisor: "Name B",
  head: "Name C",
  abstract: include "content/ab.typ", // modify this file to write your own abstract
  acknowledgement: include "content/ac.typ",
  keywords: ("keyword 1", "keyword 2", "Keyword 3"),
  bib-ref: bibliography("content/ref.bib"), // you can export this file from zotero better bibtex plugin automatically
  acronym: load("content/acro.csv"), // this csv file contains abbreviations table
  draft: true, // print line number on the left and time stamp on output pdf 
)

= Introduction

== Section 1 // pay attention to letter case which would not change automatically

=== Subsection 1

#lorem(60)

=== Subsection 2

#lorem(60)

#lorem(50)

#figure(
  rect(width: 100%, inset: 12pt)[
    width of the space you can use is 21-2.5*2=16cm\
    So you need to prepare your image with the *width less than 16cm* and *12pt font size*
  ],
  caption: [Here is a figure title],
)

#lorem(50) #footnote[You can use footnote, if you need]

== Section 2

=== Subsection 2.1

#lorem(50)

Here is an example for image.
#figure(
  image("image/DK Effect.png"),
  caption: [DK Effect],
)

=== Subsection 2.2

#lorem(100)

#figure(
  table(
    columns: (80pt, 80pt, 80pt),
    align: center+horizon,
    toprule(),
    table.header([Pathway], [Function], [Related Genes]),
    midrule(),
    [data1], [data2], [data3],
    [16.6], [104], [1999],
    bottomrule()
  ),
  caption: [Here is the name for your table],
)

// === Epigenetic Regulation of Genome Stability
// 引入话题，染色质状态不仅是DNA损伤发生的背景平台，更是DNA损伤应答（DDR）的主动调控者。表观遗传机制通过调控染色质的可接近性、招募特定修复因子以及建立修复后记忆，在维持基因组稳定性中扮演着至关重要的角色。


// 如何解析染色体结构变异
#lorem(100)
#figure(
  rect(),
  caption: [NGS for mutation],
  kind: image,
)

#text(fill: red.darken(30%))[Besides, you can use citation freely, just `@citekey` you set in zotero. Then you could get something like this @2011.Cell.FirstChromothripsisReport, and references list could be generated in the end of the thesis automatically. The inline citation is a link to the reference list @2020.Nature.ChromosomeStructureVariation.]

= Methods & Materials

// Numbering is automatic, just type in your heading content with right letter case
== Cells & Plasmids

=== Subsection
#lorem(80) 
#figure(
  rect(),
  caption: [should I change a get-month-name],
  kind: image,
)

=== Subsection

#text(fill: red.darken(30%))[If you need to use abbreviations, you can add a record in `content/acro.csv` in advanced, then type in `#acro("PDE")` here, like #acro("PDE")]. When you use this record for the first time, the long form would be displayed, and this record would be added to the abbreviations list above. #acro("PDE") is the second use, just short form. #acro("MTOC") is another use.

#figure(
  table(
    columns: (80pt, 80pt, 80pt),
    align: center+horizon,
    toprule(),
    table.header([head1], [head2], [head3]),
    midrule(),
    [data1], [data2], [data3],
    [16.6], [104], [1999],
    bottomrule()
  ),
  caption: [This is another table, renumbering with chapter \#],
)

=== Subsection 2.1.3
#lorem(150)

#figure(
  rect(fill: aqua, stroke: red),
  caption: [This is a test figure222],
  kind: image,
)

== Another Section in Chapter 2
#lorem(100)
#figure(
  table(
    columns: (80pt, 80pt, 80pt),
    align: center+horizon,
    toprule(),
    table.header([head1], [head2], [head3]),
    midrule(),
    [data1], [data2], [data3],
    [16.6], [104], [1999],
    bottomrule()
  ),
  caption: [This is a test figure 444],
  kind: table,
)


= Results

== Conclusion 1
#lorem(100)

#lorem(120)

You can also use equation freely. #link("https://typst.app/docs/reference/math/")[Details here.]
$ f(t) = A e^(t/tau) $

= Discussion & Conclusion

== Point 1

#lorem(100) @2011.Cell.FirstChromothripsisReport

== Point 2


#lorem(100) @2025.Cell.OngoingChromothtipsis
