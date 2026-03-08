#import "@preview/fine-lncs:0.1.0": lncs, institute, author, theorem, proof

#let inst_princ = institute("Princeton University", 
  addr: "Princeton NJ 08544, USA"
)
#let inst_springer = institute("Springer Heidelberg", 
  addr: "Tiergartenstr. 17, 69121 Heidelberg, Germany", 
  email: "lncs@springer.com",
  url: "http://www.springer.com/gp/computer-science/lncs"
)
#let inst_abc = institute("ABC Institute", 
  addr: "Rupert-Karls-University Heidelberg, Heidelberg, Germany", 
  email: "{abc,lncs}@uni-heidelberg.de"
)


#show: lncs.with(
  title: "Contribution Title",
  thanks: "Supported by organization x.",
  authors: (
    author("First Author", 
      insts: (inst_princ),
      oicd: "0000-1111-2222-3333",
    ),
    author("Second Author", 
      insts: (inst_springer, inst_abc),
      oicd: "1111-2222-3333-4444",
    ),
    author("Third Author", 
      insts: (inst_abc),
      oicd: "2222-3333-4444-5555",
    ),
  ),
  abstract: [
    The abstract should briefly summarize the contents of the paper in
    15--250 words.
  ],
  keywords: ("First keyword", "Second keyword", "Another keyword"),
  bibliography: bibliography("refs.bib")
)

= First Section
== A Subsection Sample

Please note that the first paragraph of a section or subsection is not indented. The first paragraph that follows a table, figure, equation etc. does not need an indent, either.

Subsequent paragraphs, however, are indented.

=== Sampling Heading (Third Level)
Only two levels of headings should be numbered. Lower level headings remain unnumbered; they are formatted as run-in headings.

==== Sample Heading (Fourth Level)
The contribution should contain no more than
four levels of headings. @heading_styles gives a summary of all heading levels.

#figure(caption: [Table Captions should be placed above the tables])[
  #table(
    columns: 3,
    align: left + bottom,
    table.hline(),
    [Heading level], [Example], [Font size and style],
    table.hline(),
    [Title (centered)], text(14pt, weight: "bold", "Lecture Notes"), [14 point, bold],
    [1st-level heading], text(12pt, weight: "bold")[Introduction], [12 point, bold],
    [2nd-level heading], text(10pt, weight: "bold")[Printing Area], [10 point, bold],
    [3rd-level heading], [#text(10pt, weight: "bold")[Run-in Heading in Bold.] Text follows.], [10 point, bold],
    [4th-level heading], [#text(10pt, style: "italic")[Lowest Level Heading] Text follows.], [10 point, italic],
    table.hline(),
  )
] <heading_styles>

Displayed equations are centered and set on a separate line.
$ x + y = z $

Please try to avoid rasterized images for line-art diagrams and schemas. When-
ever possible, use vector graphics instead (see @image_fig).

#figure(caption: [A figure caption is always placed below the illustration. Please note that short
captions are centered, while long ones are justified by the macro package automatically.],
image("fig1.svg")
) <image_fig>


#theorem[This is a sample theorem. The run-in heading is set in bold, while the following text appears in italics. `definition`, `lemma`, `proposition`, and `corollary` are styled the same way.]

#proof[Proofs, examples, and remarks have the initial word in italics, while the following text appears in normal font.]

For citations of references, we prefer the use of square brackets and consecutive numbers. Citations using labels or the author/year convention are also acceptable. The following bibliography provides a sample reference list with entries for journal articles @PAPER:1, a book @BOOK:2, and a homepage @WEBSITE:1. Multiple citations are grouped @BOOK:2@ARTICLE:1@BOOK:1.
