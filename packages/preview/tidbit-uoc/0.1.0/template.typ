#let aqua = rgb("#73EDFF")
#let marine = rgb("#000078")

#let template(
  subject: [Nombre Asignatura],
  title: [PEC1: Nombre de Trabajo],
  subtitle: [Un subtítulo de la tarea],
  date: datetime.today(),
  author: "Nombre Del Autor",
  body,
  region: "es",
  lang: "es",
) = {
  let format_month(month) = {
    ( (month == 1,"Enero"),
      (month == 2,"Febrero"),
      (month == 3,"Marzo"),
      (month == 4,"Abril"),
      (month == 5,"Mayo"),
      (month == 6,"Junio"),
      (month == 7,"Julio"),
      (month == 8,"Agosto"),
      (month == 9,"Septiembre"),
      (month == 10,"Octubre"),
      (month == 11,"Noviembre"),
      (month == 12,"Diciembre"),
      (true, "Unknown month")).find(t => t.at(0)).at(1)
  }
  let format-date(date) = {
    date.display("[day padding:none]" + " de " + format_month(date.month()) + " de [year]")
  }


  set text(region: "es", lang:  "es", font: "Arial", fill: marine, size: 11pt)
  set heading(numbering: "1")

  let day = datetime(
    year: 2024,
    month: 5,
    day: 31,
  )

  set page(
    paper: "a4",
    margin: (top: 1.5cm, bottom: 1.5cm, x: 1.2cm)
  )

  rect(width: 100%, fill: aqua, [
    #set par(leading: 20pt)
    #v(20pt)
    #text(font: "Arial", size: 53pt, weight: "bold", fill: marine, subject)
    #v(10pt)
    #text(font: "Arial", size: 32pt, fill: marine, title)
    #v(20pt)
  ])

  v(15pt)

  grid(
    columns: (35%, 1fr),
    rows: (auto),
    gutter: 30pt,
    block(height: 1fr)[
      #rect(width: 100%, height: 1fr, fill: aqua, inset: 0pt)[
        #align(right, [
          #image("assets/logo.svg", width: 75%)
        ])
      ]
      #text(font: "Georgia", size: 20pt, fill: marine, [
        Universitat Oberta de Catalunya
      ])
      #v(10pt)
      #rect(width: 100%, height: 5pt, fill: aqua, inset: 0pt)
    ],
    rect(width: 100%, height: 1fr,fill: rgb("F0F0F0"), inset: 10pt)[
      #v(10pt)
      #text(font: "Arial", size: 28pt, weight: "bold", fill: marine, [
        #author
      ])
      #v(20pt)
      #text(font: "Arial", size: 18pt, fill: marine, [
        #format-date(date)
      ])
    ],
  )

  pagebreak()

  set page(
    paper: "a4",
    number-align: center,
    margin: (top: 4cm, bottom: 4cm, left: 3.4cm, right: 2cm),
    header: [
      #pad(left: -2.4cm, [
        #grid(
          columns: (70pt, 30%, 1fr),
          gutter: 5pt,
          rect(width: 100%, inset: (left: 3pt, right: 0pt, y: 0pt), fill: aqua, [
            #image("assets/logo.svg")
          ]),
          rect(stroke: (top: 2pt + aqua, bottom: 2pt + aqua), width: 100%, height: 45.5pt)[
            #align(horizon, [
              #par(leading: 4pt, spacing: 0pt, [
                #text(font: "Georgia", size: 11pt, fill: marine, [
                  Universitat Oberta de Catalunya
                ])
              ])
            ])
          ],
          rect(stroke: (top: 2pt + aqua, bottom: 2pt + aqua), width: 100%, height: 45.5pt)[
            #align(horizon, [
              #text(font: "Arial", fill: marine, [
                #link("https://www.uoc.edu", "uoc.edu")
              ])
            ])
          ],
        )
      ])
    ],
    footer: context [
      #grid(
        columns: (40%, 1fr, 1fr),
        gutter: 5pt,
        rect(width: 100%, stroke: (top: 2pt + aqua), [
          #author
        ]),
        rect(width: 100%, stroke: (top: 2pt + aqua), [
          #lower(format-date(date))
        ]),
        rect(width: 100%, stroke: (top: 2pt + aqua), [
          #text(font: "Arial", weight: "bold", fill: marine, [
            pág. #counter(page).display()
          ])
        ]),
      )
    ]
  )

  text(font: "Arial", size: 29pt, weight: "bold", fill: marine, title)
  v(0pt)
  text(font: "Arial", size: 28pt, fill: marine, subtitle)
  v(40pt)

  set par(justify: true)
  set cite(style: "apa")
  set image(width: 75%)
  set text(region: region, lang:  lang)

  body
}
