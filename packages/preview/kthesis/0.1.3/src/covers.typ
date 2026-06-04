#import "./utils.typ": t

#let front-cover(
  title: "Example Title in Primary Language",
  subtitle: "Example Subtitle in Primary Language",
  authors: ("Peter Grey", "Joan Yellow"),
  subject-area: "Technology",
  cycle: 2,
  credits: 15,
) = page(
  margin: (top: 12.5mm, rest: 25mm),
  {
    set align(center)
    set text(size: 12pt, font: "Liberation Sans") // Arial is proprietary...

    image("../assets/KTH_logo_RGB_bla.svg", width: 37.45mm)

    [
      \

      \

      #t("degree-project-in") #subject-area \

      #set text(size: 10pt)
      #t("cycle-" + str(cycle)), #credits #t("credits") \

      \

      #text(size: 26pt, strong(title)) \
      \
      #text(size: 16pt, subtitle) \

      \
    ]

    for author in authors {
      strong(upper(author))
      linebreak()
    }
  },
)

#let back-cover(
  trita-series: "EECS-EX",
  trita-number: "2024:0000",
  year: 2025,
) = page(
  margin: (top: 65mm, bottom: 30mm, left: 74pt, right: 35mm),
  {
    set text(size: 12pt, font: "Liberation Sans") // Arial is proprietary...

    v(1fr)

    set text(size: 10pt)
    show link: it => text(fill: rgb("#1954A6"), it) // not an official color?

    // I don't know why they want an en-dash here...
    [
      TRITA -- #trita-series #trita-number \
      #set text(size: 8pt)
      #t("stockholm-sweden") #year \
      #link("https://www.kth.se", "www.kth.se")
    ]
  },
)
