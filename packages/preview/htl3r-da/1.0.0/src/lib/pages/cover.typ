#import "../settings.typ" as settings
#import "../util.typ": format-date, format-department

#let create-page(
  title: "Meine Diplomarbeit",
  subtitle: "Wir sind super toll!",
  department: "IT",
  school-year: "2024/2025",
  authors: (
    (
      name: "Max Mustermann",
      supervisor: "Otto Normalverbraucher",
      role: "Projektleiter",
    ),
    (
      name: "Erika Mustermann",
      supervisor: "Lieschen Müller",
      role: "Stv. Projektleiter",
    ),
  ),
  date: datetime(year: 2024, month: 12, day: 1),
) = {
  // Header
  block(
    width: auto,
    height: 2cm,
    stroke: (
      left: 4pt + settings.COLOR_RED,
    ),
    inset: (
      top: 2pt,
      bottom: 2pt,
      left: 8pt,
    ),
    align(left + horizon)[
      #box(
        height: 100%,
        text(
          size: 10pt,
          font: settings.FONT_HEADING,
          [
            #text(
              size: 10pt,
              font: settings.FONT_HEADING,
              [#strong([Höhere Technische Bundeslehranstalt Wien 3, Rennweg])],
            ) \
            #v(0cm)
            Höhere Abteilung für Mechatronik \
            Höhere Abteilung für Informationstechnologie \
            Fachschule für Informationstechnik
          ],
        ),
      )
      #h(1fr)
      #box(
        height: 100%,
        image("../assets/htl3r-logo.svg"),
      )
    ],
  )
  v(1fr)
  // Body
  align(center)[
    #text(
      size: 24pt,
      font: settings.FONT_HEADING,
      weight: "bold",
      "Diplomarbeit",
    )
  ]
  v(1fr)
  align(center)[
    #text(
      size: 16pt,
      font: settings.FONT_HEADING,
      strong[
        #title
      ],
    )
    #linebreak()
    #v(-5pt)
    #text(
      size: 16pt,
      font: settings.FONT_HEADING,
      strong[
        #subtitle
      ],
    )
  ]
  v(1fr)
  align(center)[
    #text(
      size: 12pt,
      [
        ausgeführt an der \
        Höheren Abteilung für #format-department(department) \
        der Höheren Technischen Lehranstalt Wien 3 Rennweg
      ],
    )
  ]
  v(1fr)
  align(center)[
    #text(
      size: 12pt,
      [
        im Schuljahr #school-year
      ],
    )
  ]
  v(1fr)
  align(
    center,
    block(width: 60%)[
      #par(
        leading: 1.4em,
        text(size: 10pt)[
          durch #h(1fr) unter Anleitung von \
          /* we thought this would look better, but the LaTeX Template doesn't have a line
          #v(-5pt)
          #line(length: 100%, stroke: 0.5pt)
          #v(-5pt)
          */
          #for author in authors [
            #text(size: 12pt, strong(author.name)) #h(1fr) #text(
              size: 12pt,
              author.supervisor,
            ) \
          ]
        ],
      )
    ],
  )
  v(1fr)
  align(
    center,
    block(width: 60%)[
      #text(
        size: 10pt,
        [
          Wien, #format-date(date)
        ],
      )
    ],
  )
}
