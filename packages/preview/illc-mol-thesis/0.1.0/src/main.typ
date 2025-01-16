#let titlepage(
  title: "Title of the Thesis",
  author: "John Q. Public",
  birth-date: "April 1st, 1980",
  birth-place: "Alice Springs, Australia",
  defense-date: "August 28, 2005",
  supervisors: ("Dr Jack Smith", "Prof Dr Jane Williams"),
  committee: (
    "Dr Jack Smith",
    "Prof Dr Jane Williams",
    "Dr Jill Jones",
    "Dr Albert Heijn"),
  degree: "MSc in Logic"
) = align(alignment.center)[
  #let title-size = 21pt
  #let subtitle-size = 14pt

  #v(85pt)

  = #text(smallcaps(title), size: title-size, weight: 100)

  #v(54pt)

  #text([*MSc Thesis* _(Afstudeerscriptie)_], size: subtitle-size)

  written by

  *#author*

  #v(-7pt)

  (born #birth-date in #birth-place)

  #par(spacing: 6pt)[
    under the supervision of #supervisors.map(x => [*#x*]).join(", ", last:
    " and "), and

    submitted to the Examinations Board in partial fullfillment of the
    requirements

    for the degree of
  ]

  #text([*#degree*], size: subtitle-size)

  at the _Universiteit van Amsterdam_.

  #v(50pt)

  #box(width: 75%)[
    #par(spacing: 6pt)[
      #columns(2, gutter: -10%)[
        #align(alignment.left)[
          *Date of the public defense:*

          _#defense-date _

          #colbreak()

          *Members of the Thesis Committee:*

          #committee.join("\n")
        ]
      ]
    ]
  ]

  #v(100pt)

  #image("../img/illclogo.svg", alt: "ILLC Logo. A 3-by-3 jigsaw puzzle. The
      center piece is white, while the surrounding pieces are black. The text
      below the puzzle reads 'Institute for Logic, Language, and Computation'",
      width: 65%)

  #pagebreak()
]
