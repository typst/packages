// SHORT DOCUMENT :

#let insa-short(
  author : none,
  date : datetime.today(),
  doc
) = {
  set text(lang: "fr")
  set page(
    "a4",
    margin: (top: 3.2cm),
    header-ascent: 0.71cm,
    header: [
      #place(left, image("logo.png", height: 1.28cm), dy: 1.25cm)
      #place(right + bottom)[
        #author\
        #if type(date) == datetime [
          #date.display("[day]/[month]/[year]")
        ] else [
          #date
        ]
      ]
    ],
    footer: [
      #place(
        right,
        dy: -0.6cm,
        dx: 1.9cm,
        image("footer.png")
      )
      #place(
        right,
        dx: 1.55cm,
        dy: 0.58cm,
        text(fill: white, weight: "bold", counter(page).display())
      )
    ]
  )

  doc
}
