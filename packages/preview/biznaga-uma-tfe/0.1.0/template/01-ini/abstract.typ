#import "@preview/biznaga-uma-tfe:0.1.0": *

#show heading: none
#heading(level: 1, numbering: none)[Abstract]
#v(-8pt)

#context [
  #align(center)[#fakesc("E.T.S. de Ingeniería de Telecomunicación, Universidad de Málaga")]

  #v(2.5em)
  #align(center)[
    #text(size: Large)[
      #set par(justify: false, leading: 0.7em)
      #strong[#fakesc(titlenameENG.at(here()))]
    ]
  ]

  #v(2.5em)
  #block(width: 100%, inset: (left: 17.5pt))[
    #set par(first-line-indent: 0pt, spacing: 0pt)
    *Author:* #author.at(here())
    #v(12pt)
    *Supervisor:* #tutor.at(here())
    #v(12pt)
    *Department:* \<DEPARTMENT>
    #v(12pt)
    *Degree:* Master's Degree in \<DEGREE>
    #v(12pt)
    *Keywords:* Keywords (separated by commas) describing and characterizing the topic of the work.
  ]
  #v(2.5em)

  #align(center)[*Abstract*]
  #v(9pt)
]

The abstract should briefly describe the project context, goals and
obtained results. It should not exceed this page.

#chapterend()
