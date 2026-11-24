#let presets = (
  "blue": gradient.linear(rgb("#C9EBFF"), white, angle: 90deg),
  "green": gradient.linear(rgb("#A3D9A3"), white, angle: 90deg),
  "red": gradient.linear(rgb("#D9A3A3"), white, angle: 90deg),
)

#let section(title: none, body) = [
  = #title
  #body
]

#let poster(
  title: [Poster Title],
  authors: (),
  info: (),
  logo: none,
  theme: "blue",
  banner-height: 17%,
  gutter: 50pt,
  title-size: 64pt,
  body-size: 29pt,
  heading-size: 50pt,
  meta-size: 30pt,
  caption-size: 20pt,
  body,
) = {
  let display = ("Libre Baskerville", "Linux Libertine", "Times New Roman")
  let sans = ("TeX Gyre Heros", "Arial", "Liberation Sans")

  let header-bg = if type(theme) == str {
    if theme not in presets {
      panic("unknown theme `" + theme + "`; available: " + presets.keys().join(", "))
    }
    presets.at(theme)
  } else {
    theme
  }

  // page config
  set page(
    width: 75cm,
    height: 100cm,
    margin: (top: 2cm, rest: 1.5cm),
    background: place(
      top + left,
      rect(width: 100%, height: banner-height, fill: header-bg),
    ),
  )

  // content style
  set text(font: sans, size: body-size)

  show heading.where(level: 1): it => block(
    width: 100%,
    below: .6em,
    [
      #text(font: display, weight: 500, size: heading-size, it.body)
      #v(-0.6em)
      #line(length: 100%, stroke: 2pt)
    ],
  )

  show figure.caption: set text(size: caption-size)

  // header Block
  grid(
    columns: (1fr, auto),
    gutter: 2cm,
    align: (left + horizon, right + bottom),

    {
      text(font: display, size: title-size, weight: 500, title)
      v(-0.5em)
      set text(font: sans, size: meta-size)
      let lines = ()
      if authors.len() > 0 { lines.push(authors.join(", ")) }
      lines += info
      lines.join(linebreak())
    },

    if logo != none { logo },
  )

  v(0.2em)
  line(length: 100%, stroke: 2pt)
  v(.2em)

  columns(2, gutter: gutter, body)
}
