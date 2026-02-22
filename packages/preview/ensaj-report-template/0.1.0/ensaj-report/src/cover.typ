#let cover-page(
  title: "",
  contributors: [],
  jury: [],
  subject-image: none,
  date: datetime.today(),
  module: "",
  field: "",
  degree: "",
  code: "",
  dep: ""
) = {

  // ────────────────────────────────────────────────────────────────
  // Academic year
  // ────────────────────────────────────────────────────────────────

  let y = date.year()
  let m = date.month()

  let academic-year = if m >= 9 {
      str(y) + "/" + str(y + 1)
    } else {
      str(y - 1) + "/" + str(y)
    }

  // ────────────────────────────────────────────────────────────────
  // Page setup
  // ────────────────────────────────────────────────────────────────

  set page(margin: 2cm)

  // ────────────────────────────────────────────────────────────────
  // Top logos
  // ────────────────────────────────────────────────────────────────

  place(top + left,
    image("assets/tri_logo.png", width: 2.5cm)
  )

  place(top + right,
    image("assets/logo_ensaj.png", width: 7cm)
  )

  // ────────────────────────────────────────────────────────────────
  // Center content
  // ────────────────────────────────────────────────────────────────

  align(center + horizon)[

    #stack(spacing: 0.6em,

      stack(spacing: 0em,
        line(
          length: 100%,
          stroke: (paint: rgb("#1a1a2e"), thickness: 2.5pt, cap: "round")
        ),
      ),

      v(0.4cm),

      block(width: 100%)[
        #align(center)[
          #text(
            size: 28pt,
            weight: "bold",
            fill: rgb("#1a1a2e"),
            tracking: 0.5pt,
          )[#title]
        ]
      ],

      v(0.4cm),

      line(
        length: 100%,
        stroke: (paint: rgb("#1a1a2e"), thickness: 2.5pt, cap: "round")
      ),

      v(0.3cm),

      align(right)[
        #text(size: 12pt, fill: rgb("#1a1a2e"))[
          #text(weight: "bold")[Student Code:] #code
        ]
      ],
    )

    #align(center + horizon)[
      #text(size: 16pt)[
        *Module*: #emph(module)
      ]
    ]

    #if subject-image != none and subject-image != "" {
      image("../"+subject-image, width: 7cm)
    }
  ]

  // ────────────────────────────────────────────────────────────────
  // Bottom-left: Contributors
  // ────────────────────────────────────────────────────────────────

  place(bottom + left, dx: 2cm, dy: -6cm)[
    #stack(spacing: 7pt,

      stack(spacing: 3pt,
        text(weight: "bold", size: 15pt, fill: rgb("#1a1a2e"))[Author],
        line(
          length: 4cm,
          stroke: (paint: rgb("#1a1a2e"), thickness: 1.5pt, cap: "round")
        ),
      ),

      text(size: 13pt)[#contributors],
    )
  ]

  // ────────────────────────────────────────────────────────────────
  // Bottom-right: Supervisors + Head of Department
  // ────────────────────────────────────────────────────────────────

  place(bottom + right, dx: -2cm, dy: -3.27cm)[
    #block[

      #block[
        #stack(spacing: 3pt,
          text(weight: "bold", size: 15pt, fill: rgb("#1a1a2e"))[Supervisors],
          line(
            length: 3.5cm,
            stroke: (paint: rgb("#1a1a2e"), thickness: 1.5pt, cap: "round")
          ),
        )
        #v(4pt)
        #text(size: 13pt)[#jury]
      ]

      #v(12pt)

      #block[
        #stack(spacing: 3pt,
          text(weight: "bold", size: 15pt, fill: rgb("#1a1a2e"))[Head of The Department],
          line(
            length: 6cm,
            stroke: (paint: rgb("#1a1a2e"), thickness: 1.5pt, cap: "round")
          ),
        )
        #v(4pt)
        #text(size: 13pt)[#dep]
      ]
    ]
  ]

  // ────────────────────────────────────────────────────────────────
  // Bottom center: Field, Degree, Academic year
  // ────────────────────────────────────────────────────────────────

  place(bottom + center, dy: 1cm)[
    #align(center + horizon)[
      #text(size: 16pt)[
        *Field*:  #emph(field) \
        *Degree*: #emph(degree) \
        *Institution*: _National School of Applied Sciences_
        #linebreak()
      ]
    ]

    #box(
      fill: rgb("#1a1a2e"),
      inset: (x: 16pt, y: 7pt),
      radius: 20pt,
    )[
      #text(size: 12pt, weight: "bold", fill: white)[#academic-year]
    ]
  ]

  pagebreak()
  outline(title: [Table of Content])
  pagebreak()
  outline(title: [List of Figures], target: figure)
  pagebreak()
}