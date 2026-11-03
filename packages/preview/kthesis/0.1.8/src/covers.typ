#import "./utils.typ": sans-serif, t

#let front-cover(
  title: "Example Title in Primary Language",
  subtitle: "Example Subtitle in Primary Language",
  authors: ("Peter Grey", "Joan Yellow"),
  subject-area: "Technology",
  cycle: 2,
  credits: 15,
  cover-image: none,
  style,
) = page(
  margin: (top: 12.5mm, rest: 25mm),
  {
    set align(center)
    set text(size: 12pt, font: sans-serif(style))

    image("../assets/KTH_logo_RGB_bla.svg", width: 37.45mm)

    [
      \

      \

      #t("degree-project-in") #subject-area \

      #set text(size: 10pt)
      #t("cycle-" + str(cycle)), #credits #t("credits") \

      \

      // without this `par`, multi-line titles would look very squished together
      // (with low-hanging letters like `g` even touching tall letters like `P`)
      // so we try our best. the official template uses 108% line height (from
      // baseline to baseline), but there is no easy way to replicate that in
      // Typst, so we just do this instead. 0.5em is what seems to look nicest
      #text(size: 26pt, strong(par(
        spacing: 0pt, // any extra surrounding margins would break the layout
        leading: 0.5em, // magic number
        title,
      )))
      \
      #if subtitle != none [
        #text(size: 16pt, subtitle)
        \
      ]

      \
    ]

    for author in authors {
      strong(upper(author))
      linebreak()
    }

    if cover-image != none {
      // from official cover template: 120 twips after author + 680 twips before
      // image = 800 twips = 40pt of vertical space
      v(40pt)

      cover-image
    }
  },
)

#let back-cover(
  trita-series: "EECS-EX",
  trita-number: "2026:0000",
  year: 2026,
  style,
) = page(
  margin: (top: 65mm, bottom: 30mm, left: 74pt, right: 35mm),
  {
    set text(size: 12pt, font: sans-serif(style))

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
