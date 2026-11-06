// The main color of the Paris-Saclay University visual identity
#let prune = rgb(99, 0, 60)

// Yellow background color for highlighting
#let yellow-highlighting = rgb("#fffd11a1") // default color of highlight() https://typst.app/docs/reference/text/highlight/#parameters-fill

// An highlighted empty rectangle for missing parameters
#let missing-field(width: 10em) = box(
  fill: yellow-highlighting,
  width: width,
  height: 1em,
  baseline: 0.2em
)

// An highlighted block for when the doctoral school logo is not selected
#let missing-doctoral-school-logo = block(
  height: 65pt,
  width: 200pt,
  fill: yellow-highlighting
)[
  #align(center+horizon)[
    Logo de l'école doctorale
  ]
]

// The function takes the whole document as `body` parameter
// and formats it for a Paris-Saclay University thesis
#let paris-saclay-thesis(

  // The first and last names of the candidate
  candidate-name: highlight[Prénom Nom],

  // The thesis title in French
  title-fr: highlight[Titre de la thèse],

  // The translated thesis title in English
  title-en: highlight[Title of the thesis],

  // The keywords of the thesis subject, in French
  keywords-fr: (highlight[Mot-clé 1], highlight[Mot-clé 2], highlight[Mot-clé 3]),

  // The translated keywords of the thesis subject, in English
  keywords-en: (highlight[Keyword 1], highlight[Keyword 2], highlight[Keyword 3]),

  // Abstract of the thesis, in French
  abstract-fr: highlight(lorem(200)),

  // Translated abstract of the thesis, in English
  abstract-en: highlight(lorem(200)),

  // The national thesis number (NNT, Numéro National de Thèse)
  NNT: highlight[XXXXXXXXXX],

  // The line for the doctoral school number and name
  doctoral-school: [École doctorale n°#missing-field(width: 3em) : #missing-field()],

  // The short code of the doctoral school. See images filename in ./img/
  doctoral-school-code: none,

  // The line for the specialty
  specialty: [Spécialité de doctorat : #missing-field()],

  // The line for the graduate school
  graduate-school: [Graduate School : #missing-field()],

  // The line for the university component / associated university (référent)
  university-component: [Référent : #missing-field()],

  // The paragraph for the research unit and the PhD advisors
  research-unit-and-advisors: [
    Thèse préparée dans l'unité de recherche #missing-field(),\ sous la direction de #missing-field(), #highlight[titre du directeur de thèse],\ 
    et l'encadrement de #missing-field(), #highlight[titre du co-endadrant].
  ],

  // The date of the PhD defense
  defense-date: [#missing-field()],

  // The list of thesis examiners (rapporteurs and defense examiners)
  thesis-examiners: (
    (
      name: missing-field(),
      title: missing-field(width: 25em),
      status: highlight[Président(e)]
    ),
    (
      name: missing-field(),
      title: missing-field(width: 25em),
      status: highlight[Rapporteur &\ Examinateur/trice]
    ),
    (
      name: missing-field(),
      title: missing-field(width: 25em),
      status: highlight[Rapporteur &\ Examinateur/trice]
    ),
    (
      name: missing-field(),
      title: missing-field(width: 25em),
      status: highlight[Examinateur/trice]
    ),
  ),

  // Spacings in the first page
  vertical-spacing-1: 15pt,
  vertical-spacing-2: 55pt,
  vertical-spacing-3: 40pt,
  vertical-spacing-4: 40pt,
  vertical-spacing-5: 40pt,
  horizontal-spacing-1: 50pt,
  horizontal-spacing-2: 100pt,

  // The thesis content
  body

) = {

  set page(
    paper: "a4",
    margin: (
      left: 0pt,
      top: 0pt,
      bottom: 0pt,
      right: 2.5cm
    )
  )

  set text(
    font: ("Segoe UI This"),
    size: 12pt,
    lang: "fr"
  )

  let rectangle_width = 16.4%*21cm // 16.4% of the page width

  grid(
    columns: (rectangle_width, 100%-rectangle_width),
    gutter: 25pt,
    [
      #rect(
        fill: prune,
        width: 100%,// 100% of rectangle_width,
        height: 100%
      )

      #place(
        bottom+left,
        dx: 0.1cm,
        dy: -3cm,
        rotate(
          -90deg,
          block[
            #text(
              fill: white,
              size: 16pt,
            )[
              THESE~DE~DOCTORAT
            ]
            #v(0.5pt)
            #text(
              fill: white,
            )[
              NNT~:~#NNT
            ]
          ]
        )
      )
    ],
    [ // right part of the grid

      #v(vertical-spacing-1)

      #image("img/universite-paris-saclay.png", width: 25.4%*21cm)

      #v(vertical-spacing-2)

      #align(right)[
        #text(
          size: 20pt,
          fill: prune,
        )[
          #title-fr
        ]\
        #v(2pt)
        #text(
          size: 13pt,
          fill: black,
          style: "italic"
        )[
          #title-en
        ]\

        #v(vertical-spacing-3)

        #text(
          size: 13pt,
          weight: 400,
        )[
          *Thèse de doctorat de l’université Paris-Saclay*
        ]
        #v(10pt)
        #text(
          size: 12pt,
        )[
          #doctoral-school\
          #specialty\
          #graduate-school\ 
          #university-component
          #v(10pt)
          #research-unit-and-advisors
        ]

        #v(vertical-spacing-4)

        #text(
          size: 11pt,
        )[
          *Thèse soutenue à Paris-Saclay, le #defense-date, par* \
        ]

        #text(
          size: 20pt,
          fill: prune,
          weight: 600,
        )[
          #candidate-name
        ]
      ]

      #v(vertical-spacing-5)

      #grid(
        columns: (horizontal-spacing-1, auto),
        row-gutter: 1em,
        stroke: (x,y) => if x == 1 and y == 1 { (left: (1pt + prune)) },
        [],
        [
          #text(size: 14pt, fill: prune)[*Composition du jury*]\
          #text(size: 11pt, fill: prune)[Membres du jury avec voix délibérative]
        ],
        [],
        [
          #set text(10pt)
          #grid(
            columns: (auto, auto),
            column-gutter: horizontal-spacing-2,
            inset: (x: 6pt, y: 3pt),
            align: horizon,
            ..for thesis-examiner in thesis-examiners {
              (thesis-examiner.name, grid.cell(rowspan: 2)[#thesis-examiner.status], text(size: 9pt)[#thesis-examiner.title])
              if thesis-examiner != thesis-examiners.last() {
                ([],[])
              }
            }
          )
        ],
      )
    ]
  ) // end grid

  // from the second page, default margins of the A4 paper size
  set page(
    margin: auto
  )

  pagebreak()

  if doctoral-school-code == none {
    missing-doctoral-school-logo
  }
  else {
    assert(type(doctoral-school-code) == str)
    image("img/" + doctoral-school-code + ".png", width: 60%)
  }

  v(10pt)

  grid(
    columns: (100%),
    rows: 2,
    gutter: 40pt,
    inset: 10pt,
    stroke: 1pt+prune,
    [
      #set text(10pt)
      *Titre :* #title-fr\
      *Mots-clés :* #for keyword in keywords-fr {
        (keyword)
        if keyword != keywords-fr.last() {
          (", ")
        }
      }\
      #v(5pt)
      *Résumé :* #abstract-fr
    ],
    [
      #set text(10pt)
      *Title :* #title-en\
      *Keywords :* #for keyword in keywords-en {
        (keyword)
        if keyword != keywords-en.last() {
          (", ")
        }
      }\
      #v(5pt)
      *Abstract :* #abstract-en
    ]
  )

  pagebreak(weak: true)

  body
}