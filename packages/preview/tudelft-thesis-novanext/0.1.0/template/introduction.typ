#import "@preview/tudelft-thesis-novanext:0.1.0": *

= Introduction
#dropcap[The template is activated using the command `#show: thesis`.
This will use the TU Delft corporate style including the fonts Arial and Roboto Slab.]

Alternatively, `#show: thesis-classic` will use the default Typst font, Libertinus Serif, which will give a more classic look.

`#show: front-matter` will disable the chapter numbering for the first chapters, such as the summary. It will also use roman lowercase letters for the page numbers.

`#show: main-matter` will enable the chapter numbering for the main chapters, and use Western Arabic numerals for the page numbers.

`#show: appendix` will start the appendix, using capital letters for chapter numbering.

`#show: back-matter` will start the back matter, which has unnumbered chapters.


== Motivation
#dropcap[#ipsum(50, 50)]

#ipsum(70, 100)

=== Afterthought
#ipsum(5, 170)

== Problem Statement
#dropcap[#ipsum(50, 175)]

Not all names are spelled consistently 
#multicite[@Leeuw1712, @Leuwe1704].

Not everyone is always right @vonBBerratum2022.

Not everything always weighs the same @EinsteinTraegheit1905.

#{
  show "A. Einstein": [*A. Eistein*]
  show bibliography: set heading(level: 2)
  show regex("\\\\textit\\{[^\}]*\\}"): it => [_#it.text.slice(8,-1)_]
  show regex("\\\\textbf\\{[^\}]*\\}"): it => [*#it.text.slice(8,-1)*]
  bibliography("typst.bib")
}
