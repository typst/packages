#import "@preview/outrageous:0.4.1"
#import "@preview/hydra:0.6.2": hydra
#import "@preview/colorful-boxes:1.4.3": colorbox
#import "@preview/datify:1.0.1": custom-date-format
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
// The main color of the Paris-Saclay University visual identity
#let prune = rgb(99, 0, 60)

// Yellow background color for highlighting
#let yellow-highlighting = rgb("#fffd11a1") // default color of highlight() https://typst.app/docs/reference/text/highlight/#parameters-fill

// An highlighted empty rectangle for missing parameters
#let missing-field(width: 10em) = box(
  fill: yellow-highlighting,
  width: width,
  height: 1em,
  baseline: 0.2em,
)

#show outline.entry: outrageous.show-entry.with(
  font-weight: ("bold", auto),
  fill: (none, line(length: 100%, stroke: gray + .5pt)),
  prefix-transform: (lvl, prefix) => { [#h(0.001cm) #prefix] },
)

// A box to have a small summary for a section/sub-section
#let summary(body) = {
  colorbox(
    title: text(font: "Open Sans")[En résumé],
    radius: 2pt,
    width: auto,
    box-colors: (
      prune: (stroke: prune, fill: white, title: white),
    ),
    color: "prune",
  )[
    #body
    #v(2pt)
  ]
}

// Allows to have non numbered sections, eg.
//= Addendum <unnumbered>

#show selector(<unnumbered>): set heading(numbering: none)

// List of tables
#let table-list() = {
  heading("Liste des tables", numbering: none)
  outline(target: figure.where(kind: table), title: none)
}

// List of figures
#let figure-list() = {
  heading("Liste des figures", numbering: none)
  outline(target: figure.where(kind: image), title: none)
}

// Lexicon
#let lexicon(content) = {
  heading("Lexique", numbering: none)
  (content)
}

// A "Remarque : " text box

#let remark(number: none, body) = {
  block(stroke: (left: 1pt), inset: 0.5em)[
    #smallcaps[Remarque #number :] #body
  ]
}

// The function takes the whole document as `body` parameter
// and formats it for a IUT Orsay report
#let iut-orsay-report(
  // The first and last names of the students
  student-names: (
    (
      last_name: highlight[Nom],
      first_name: highlight[Prénom],
    ),
  ),
  // Show the students names in the headers
  students-in-headers: true,
  // Students's group(s)
  group: highlight[Groupe],
  // The report title in French
  title: highlight[Titre du rapport],
  // The translated report title in English
  subtitle: highlight[Title of the report],
  // The keywords of the thesis subject, in French
  keywords: (highlight[Mot-clé 1], highlight[Mot-clé 2], highlight[Mot-clé 3]),
  // Abstract of the thesis, in French
  abstract: highlight(lorem(200)),
  // Show the abstract page
  show-abstract: true,
  // The line for the doctoral school number and name
  diploma: [Département #missing-field()],
  // The line for the specialty
  specialty: [],
  // The line for the level
  level: [#missing-field() année],
  // The date of the report
  report-date: custom-date-format(datetime.today(), pattern: "dd MMMM yyyy", lang: "fr"),
  // Report type
  report-type: [],
  // Training/Alternance
  company-name: [],
  company-logo: "img/empty.png",
  // The list of report examiners (tuteur/maître de stage/alternance...)
  report-examiners: (),
  // Spacings in the first page
  vertical-spacing-1: 15pt,
  vertical-spacing-2: 55pt,
  vertical-spacing-3: 40pt,
  vertical-spacing-4: 40pt,
  vertical-spacing-5: 40pt,
  horizontal-spacing-1: 50pt,
  horizontal-spacing-2: 100pt,
  // The thesis content
  body,
) = {
  set page(
    paper: "a4",
    margin: (
      left: 0pt,
      top: 0pt,
      bottom: 0pt,
      right: 2.5cm,
    ),
  )

  show: codly-init.with()
  codly(languages: codly-languages)
  codly(stroke: 1pt + black, zebra-fill: none, number-format: none)
  codly(display-icon: false, display-name: true, breakable: false)

  set text(
    font: "Open Sans",
    size: 12pt,
    lang: "fr",
  )

  let rectangle_width = 16.4% * 21cm // 16.4% of the page width

  grid(
    columns: (rectangle_width, 100% - rectangle_width),
    gutter: 25pt,
    [
      #rect(
        fill: prune,
        width: 100%, // 100% of rectangle_width,
        height: 100%,
      )
    ],
    [ // right part of the grid

      #v(vertical-spacing-1)

      #image("img/iut-orsay.svg", width: 50% * 21cm)

      #v(vertical-spacing-2)

      #align(right)[
        #text(
          size: 20pt,
          fill: prune,
        )[
          #title
        ]\
        #v(2pt)
        #text(
          size: 13pt,
          fill: black,
          style: "italic",
        )[
          #subtitle
        ]\

        #v(vertical-spacing-3)

        #text(
          size: 13pt,
          weight: 400,
        )[
          #if specialty != none [*#diploma --- #specialty*] else [*#diploma*]\
        ]
        #text(
          size: 12pt,
        )[
          #level
        ]

        #text(
          size: 11pt,
        )[
          *Rapport rédigé le #report-date, par* \
        ]

        #text(
          size: 20pt,
          fill: prune,
          weight: 600,
        )[
          #for student-name in student-names {
            [#student-name.first_name #student-name.last_name]
            if student-name != student-names.last() {
              [#linebreak()]
            }
          }
        ]
      ]

      #v(vertical-spacing-4)

      #align(center)[
        #text(
          size: 12pt,
        )[
          #if report-type == [stage] [
            Stage effectué au sein de :
          ] else if report-type == [apprentissage] [
            Apprentissage effectué au sein de :
          ]
        ]

        #text(
          size: 12pt,
        )[
          #company-name
        ]

        #image(company-logo, width: 100%, height: 25%, fit: "contain")

      ]


      #v(vertical-spacing-4)

      #v(1fr)

      #grid(
        columns: (horizontal-spacing-1, auto),
        row-gutter: 1em,
        stroke: (x, y) => if x == 1 and y == 1 { (left: (1pt + prune)) },
        [],
        [
          #text(size: 14pt, fill: prune)[*Encadrement*]
        ],

        [],
        [
          #set text(10pt)
          #grid(
            columns: (auto, auto),
            column-gutter: horizontal-spacing-2,
            inset: (x: 6pt, y: 3pt),
            align: horizon,
            ..for report-examiner in report-examiners {
              (
                report-examiner.name,
                grid.cell(rowspan: 2)[#report-examiner.status],
                text(size: 9pt)[#report-examiner.title],
              )
              if report-examiner != report-examiners.last() {
                ([], [])
              }
            }
          )
        ],
      )

      #v(vertical-spacing-5)
    ],
  ) // end grid

  // from the second page, default margins of the A4 paper size
  set page(
    margin: auto,
  )

  pagebreak()

  if show-abstract {
    image("img/iut-orsay.svg", width: 60%)

    v(10pt)

    grid(
      columns: 100%,
      rows: 1,
      gutter: 40pt,
      inset: 10pt,
      stroke: 1pt + prune,
      [
        #set text(10pt)
        *Titre :* #title\
        *Mots-clés :* #for keyword in keywords {
          (keyword)
          if keyword != keywords.last() { ", " }
        }\
        #v(5pt)
        *Résumé :* #abstract
      ]
    )

    pagebreak(weak: true)
  }

  let heading_text_size = (none, 18pt, 15pt, 12pt, 11pt) // for each heading level
  show heading.where(level: 1): header => {
    set align(left)
    set text(
      size: heading_text_size.at(1),
      fill: prune,
      font: "Open Sans",
      weight: "bold",
    )
    let number = context counter(heading).display("1 • ") // prefix format
    pagebreak(weak: true) // start level 1 headings on a new page
    block(breakable: false)[
      #if header.numbering != none [ #number ]
      #upper(header.body)
    ]
    v(heading_text_size.at(1)) // same height spacing as the font size
  }
  show heading.where(level: 2): header => {
    set align(left)
    set text(
      size: heading_text_size.at(2),
      font: "Open Sans",
      weight: "bold",
    )
    v(heading_text_size.at(2)) // same height spacing as the font size
    box()[
      #counter(heading).display()~
      #upper(header.body)
    ]
    v(heading_text_size.at(2)) // same height spacing as the font size
  }
  show heading.where(level: 3): header => {
    set align(left)
    set text(
      size: heading_text_size.at(3),
      font: "Open Sans",
      weight: "bold",
    )
    v(heading_text_size.at(3)) // same height spacing as the font size
    box()[
      #h(10pt) // small indent
      #counter(heading).display()~
      #header.body
    ]
    v(heading_text_size.at(3)) // same height spacing as the font size
  }
  show heading: it => text(fill: prune)[
    #it
  ]

  // Headings numbering & refer to a section with "Partie X" instead of "Section X"

  set heading(numbering: "1.1", supplement: "Partie")

  // Refer to an equation with "Équation X" instead of "Equation X"

  set math.equation(supplement: "Équation")

  show outline.entry: outrageous.show-entry.with(
    font-weight: ("bold", auto),
    fill: (none, line(length: 100%, stroke: gray + .5pt)),
    prefix-transform: (lvl, prefix) => { [#h(0.001cm) #prefix] },
  )

  set page(
    numbering: "1",
    header: context (
      if students-in-headers {
        for student-name in student-names {
          [#student-name.first_name #student-name.last_name]
          if student-name != student-names.last() {
            [ -- ]
          }
        }
      }
    ),
    footer: context [
      #set align(center)
      #set text(8pt)
      #counter(page).display(
        "1",
        both: false,
      )],
  )

  body
}
