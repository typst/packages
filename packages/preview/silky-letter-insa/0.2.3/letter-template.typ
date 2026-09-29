#import "insa-common.typ": *

#let insa-letter(
  author: none,
  insa: "rennes",
  date: datetime.today(),
  footer: none,
  doc,
) = {
  _ = insa-school-name(insa) // checks that the INSA is supported

  set text(lang: "fr", font: insa-body-fonts)
  set page(
    "a4",
    margin: (top: 3.2cm, x: 2.5cm),
    header-ascent: 0.71cm,
    header: [
      #place(
        left,
        image(insa-logo-path(insa), height: 1.28cm),
        dy: 1.25cm,
      )
      #place(right + bottom)[
        #author\
        #if type(date) == datetime [
          #date.display("[day]/[month]/[year]")
        ] else [
          #date
        ]
      ]
    ],
    footer: context {
      place(
        right + bottom,
        dx: page.margin.at("right") - 0.6cm,
        dy: -0.6cm,
        box(width: 2.34cm, height: 2.34cm, image("assets/footer.png")),
      )
      if counter(page).final() != (1,) {
        place(
          right + bottom,
          dx: page.margin.at("right") - 0.6cm,
          dy: -0.6cm,
          box(width: 1.15cm, height: 1.15cm, align(center + horizon, text(
            fill: white,
            weight: "bold",
            counter(page).display(),
          ))),
        )
      }
      footer
    },
  )
  show heading: set text(font: insa-heading-fonts)

  doc
}
