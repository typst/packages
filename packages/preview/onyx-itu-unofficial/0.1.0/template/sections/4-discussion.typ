// this is needed to make the glossary work
#import "@preview/glossarium:0.5.10": *



= Discussion
#lorem(100)
#parbreak()
#lorem(350)
#v(2em)

#figure(
  table(
    columns: (auto,) * 5,
    align: center,
    inset: 1em,
    [*Aligner*], [*Publication*], [*Indexing*], [*alignment*], [*Max. read length (bp)*],
    [BWA], [2009], [BWT-FM], [Semi-Global], [125],
    [#raw("Bowtie")], [2009], [BWT-FM], [HD], [76],
    [#raw("CloudBurst")], [2009], [Hashing], [Landau-#raw("Vishkin")], [36],
    [#raw("GNUMAP")], [2009], [Hashing], [NW], [36],
  ),
  caption: "Comparison of different alignment tools",
) <example-table>
