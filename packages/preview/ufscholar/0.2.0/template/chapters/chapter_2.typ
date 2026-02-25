#import "../imports.typ": *

= Development

*Generic standard instructions from the @tcc:pl of the University Library:*

Text must be inserted between sections.

== Presentation of the subject or topic

This is the main and most extensive part of the work. It should present the theoretical foundation, methodology, results, and discussion. It is divided into sections and subsections according to NBR 6024 (*NBR6024:2012*).

Regarding its structure and graphic design, it follows the @abnt recommendations for the preparation of academic works, NBR 14724, from 2011 (*NBR14724:2011*).

#figure(
  label: "fig:elementos-trabalho",
  source: "Federal University of Paraná (1996)",
  caption: "Elements of the academic work",
)[
  #image("../assets/images/elements-trabalho-academico.png", width: 70%)
]

=== Text formatting

Regarding the structure of the work, it is recommended that:

+ the text should be justified, typed in black, with other colors used only in illustrations;
+ white or recycled paper should be used for printing;
+ the preliminary elements must begin on the front side of the sheet, except for the catalog card or work identification card;
+ the textual and post-textual elements must be typed on both sides of the pages when the work is printed. Primary sections should always start on odd-numbered pages when printed. Leave a space between the title of the section/subsection and the text, and between the text and the following subsection title.

Table @tab:formatacao-texto shows the text formatting specifications.

#figure(
  label: "tab:formatacao-texto",
  caption: [Text formatting.],
  source: [*NBR14724:2011*],
  table(
    columns: 2,
    stroke: black.lighten(30%) + 0.6pt,

    table.header([Item], [Rule]),

    [Paper format], [A4],

    [Printing],
    [The standard recommends that, if printing is necessary, both sides of the page should be used.],

    [Margins],
    [Top: 3 cm, Bottom: 2 cm, Inner: 3 cm, and Outer: 2 cm. Use mirrored margins when the work is printed.],

    [Pagination],
    [The pages of the preliminary elements must be counted but not numbered. For works printed only on the front side, the page number should appear in the upper right corner, 2 cm from the edge, starting from the first page of the textual part. For double-sided works, numbering should appear in the upper right corner on the front side and upper left on the back side.],

    [Line spacing],
    [The text should be written with 1.5 line spacing, except for quotations longer than three lines, footnotes, references, captions of illustrations and tables, and the nature of the work (type of work, objective, name of the institution, and area of concentration), which should be in single spacing and smaller font size. References should be separated by a single blank line.],

    [Pagination],
    [Counting starts on the title page, but page numbering appears only from the introduction to the end of the work.],

    [Suggested fonts],
    [Arial or Times New Roman.],

    [Font size],
    [Font size 12 for the text, including section and subsection titles. Quotations longer than three lines, footnotes, pagination, cataloging data, and captions of illustrations and tables should be in a smaller font. In this template, font size 10 is used.],

    [Footnotes],
    [They should be typed within the margin, separated by a single space between lines and by a 5 cm line from the left margin. From the second line onward, they must be aligned below the first letter of the first word of the first line.],
  )
)

==== Illustrations

Regardless of the type of illustration (chart, drawing, figure, photograph, map, etc.), its identification appears at the top, preceded by the designative word.

#quote(block: true)[
  After the illustration, at the bottom, indicate the source consulted (mandatory element, even if it is the author’s own work), caption, notes, and other necessary information for its understanding (if any). The illustration must be cited in the text and placed as close as possible to the corresponding reference in the text. (*NBR14724:2011*)
]

==== Equations and formulas

Equations and formulas must be highlighted in the text to facilitate reading. To number them, use Arabic numerals in parentheses aligned to the right. A line spacing greater than that of the text may be used (*NBR14724:2011*).

Examples, @eq:ex1 and @eq:ex2. Note that the `#gls()` command is used to create a hyperlink to the definition of the symbol in the list of symbols. One could also use `@label` to reference them, like this: @circum. The first time a reference to a symbol, acronym, or abbreviation is made, the long mode is automatically used. After that, they are always referenced by their abbreviations: @circum, but you can still use the long version: @circum:long.

$ #gls("circum") = 2 #gls("pi", long: false) #gls("radius", long: false) sqrt(gamma) + 10. $ <eq:ex1>

$ #gls("area", long: false) = #gls("pi", long: false) #gls("radius", long: false)^2. $ <eq:ex2>

#noindent[
  There is no indentation here because the paragraph has not ended; only a new sentence starts after the equation. Equations are part of the text, therefore subject to punctuation (period, comma, etc.).
]

===== Table example

According to *ibge1993*, a table is a non-discursive form of presenting information, where numbers represent the core information. See @tab:ibge.

#figure(
  label: "tab:ibge",
  caption: [Average urban concentrations 2010–2011.],
  source: [*ibge2016*],
  table(
    columns: (1.1fr, auto, auto, 1fr, 1fr, 1fr),

    table.header(
      [Average urban concentration],
      table.cell(colspan: 2)[Population],
      [Gross Domestic Product — GDP (billions R\$)],
      [Number of companies],
      [Number of local units]
    ),

    [*Name*],
    [*Total*],
    [*In Brazil*],
    [],
    [],
    [],

    [Ji-Paraná (RO)],
    [116,610],
    [116,610],
    [1.686],
    [2,734],
    [3,082],

    [Parintins (AM)],
    [102,033],
    [102,033],
    [0.675],
    [634],
    [683],

    [Boa Vista (RR)],
    [298,215],
    [298,215],
    [4.823],
    [4,852],
    [5,187],

    [Bragança (PA)],
    [113,227],
    [113,227],
    [0.452],
    [654],
    [686]
  ),
)
