#import "@preview/cetz:0.3.0"

#let vub-orange = cmyk(
  0%,
  78%,
  100%,
  0%,
)
#let vub-blue = cmyk(
  100%,
  80%,
  16%,
  3%,
)

#let triangle-height = 27.7mm
#let vub-triangle = cetz.canvas({
  import cetz.draw: *
  line(
    (
      0,
      0,
    ),
    (
      0,
      triangle-height,
    ),
    (
      -10mm,
      triangle-height,
    ),
    close: true,
    fill: vub-orange,
    stroke: none,
  )
})

#let vub-titlepage(
  title: "Title of the thesis",
  subtitle: "An optional subtitle",
  pretitle: "Graduation thesis submitted in partial fulfillment of the requirements for the degree of Master of Science in Mathematics",
  authors: ("Jane Doe",),
  promotors: ("John Smith",),
  faculty: "Sciences and Bio-Engineering Sciences",
  date: datetime.today().display("[month repr:long] [day], [year]"),
) = {

  set document(
    author: authors,
    title: title,
  )

  set page(margin: (
    left: 18mm,
    top: 20mm,
    right: 10mm,
  ))
  set text(font: (
    "TeX Gyre Adventor",
    "Roboto",
  ))
  set par(
    linebreaks: "optimized",
    // We adjust it manually
    spacing: 0pt,
  )

  // First the top part with the vub logo and triangle
  place(
    top + left,
    image(
      "/assets/vub_logo_cmyk.svg",
      width: 5.66cm,
    ),
  )

  place(
    top + right,
    vub-triangle,
  )

  // Account for space of triangle
  v(triangle-height)

  v(1fr)

  // Title + author + date
  h(25mm)
  pad(x: 29mm)[
    #par(leading: 0.3em // Make it a bit more tight
    )[

      #text(
        size: 9pt,
        fill: vub-orange,
        pretitle,
      )

      #v(5mm)

      #text(
        size: 24.88pt,
        fill: vub-blue,
        strong(
          upper(title),
        ),
      )
    ]
    #v(5mm)

    #text(
      size: 17.28pt,
      fill: vub-blue,
      subtitle,
    )

    #v(3cm)

    #text(
      size: 12pt,
      fill: vub-orange,
      authors.join(", "),
    )
    #v(5mm)

    #text(
      size: 12pt,
      fill: vub-blue,
      date,
    )
  ]

  v(1fr)

  // Promotors + faculty
  h(25mm)
  pad(x: 29mm)[
    #text(
      size: 10pt,
      fill: vub-orange,
      promotors.join(", "),
    )

    #v(5mm)

    #text(
      size: 10pt,
      fill: vub-blue,
      strong(faculty),
    )
  ]


  pagebreak(weak: true)
}
