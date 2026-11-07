// University of Oxford document styling. See README.md for logo-use requirements.

#let colours = (
  blue: rgb("#002147"), mauve: rgb("#776885"), peach: rgb("#E08D79"),
  potters-pink: rgb("#ED9390"), dusk: rgb("#C4A29E"), lilac: rgb("#D1BDD5"),
  sienna: rgb("#994636"), red: rgb("#AA1A2D"), plum: rgb("#7F055F"),
  coral: rgb("#FE615A"), lavender: rgb("#D4CDF4"), orange: rgb("#FB5607"),
  pink: rgb("#E6007E"), green: rgb("#426A5A"), ocean-grey: rgb("#789E9E"),
  yellow-ochre: rgb("#E2C044"), cool-grey: rgb("#E4F0EF"), sky-blue: rgb("#B9D6F2"),
  viridian: rgb("#15616D"), royal-blue: rgb("#1D42A6"), aqua: rgb("#00AAB4"),
  vivid-green: rgb("#65E5AE"), lime-green: rgb("#95C11F"),
  cerulean-blue: rgb("#49B6FF"), lemon-yellow: rgb("#F7EF66"),
  charcoal: rgb("#211D1C"), ash-grey: rgb("#61615F"), umber: rgb("#89827A"),
  stone-grey: rgb("#D9D8D6"), shell-grey: rgb("#F1EEE9"), off-white: rgb("#F2F0F0"),
)

#let oxford(
  accent: "blue",
  secondary: none,
  logo: "../assets/oxford-logo-square-rgb.png",
  logo-width: 26mm,
  secondary-logo: none,
  footer: "University of Oxford",
  body,
) = {
  let accent = colours.at(accent)
  set page(
    paper: "a4",
    margin: (top: 34mm, bottom: 24mm, x: 24mm),
    header: if secondary-logo != none {
      grid(
        columns: (logo-width, 4mm, logo-width), column-gutter: 4mm,
        image(logo, width: logo-width),
        align(center + horizon, image("../assets/oxford-notched-line.png", height: 22mm, fit: "contain")),
        image(secondary-logo, width: logo-width),
      )
    } else {
      grid(
        columns: (logo-width, 2.5mm, 1fr), column-gutter: 4mm,
        image(logo, width: logo-width),
        align(center + horizon, image("../assets/oxford-notched-line.png", height: 22mm, fit: "contain")),
        if secondary != none {
          align(left + horizon, text(size: 9.5pt, weight: "medium", fill: colours.blue)[#secondary])
        },
      )
    },
    footer: context align(right, text(size: 8pt, fill: colours.ash-grey)[#footer · #counter(page).display("1")]),
  )
  set text(font: ("Roboto", "Arial"), size: 10.5pt, fill: colours.charcoal)
  set par(leading: 0.65em, justify: true)
  show heading.where(level: 1): it => block(above: 1.5em, below: 0.6em)[
    #text(font: ("Noto Serif", "Times New Roman"), size: 19pt, weight: "bold", fill: colours.blue)[#it.body]
  ]
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.4em)[
    #text(size: 13pt, weight: "bold", fill: accent)[#it.body]
  ]
  show link: set text(fill: accent)
  body
}

#let title-block(title, subtitle: none, author: none, date: none, accent: colours.blue) = [
  #v(22mm)
  #text(font: ("Noto Serif", "Times New Roman"), size: 30pt, weight: "bold", fill: colours.blue)[#title]
  #if subtitle != none { v(6mm); text(size: 15pt, fill: accent)[#subtitle] }
  #v(18mm)
  #if author != none { text(size: 11pt, weight: "medium")[#author] }
  #if date != none { linebreak(); text(size: 10pt, fill: colours.ash-grey)[#date] }
]
