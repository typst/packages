#import "@preview/droplet:0.3.1": dropcap

#let is-printer-friendly = sys.inputs.at("printer-friendly", default: none) == "true"
#let nice-or(color, default: black ) = if not is-printer-friendly { color } else { default }

#let colors = (
  primary: nice-or(rgb("#9b201f")),
  secondary: nice-or(rgb("#968c6a")),
  accent: nice-or(rgb("#2a548b")),
  light: nice-or(rgb("#AAAAAA"), default: white),
  dark: nice-or(rgb("#222222")),
  text: nice-or(rgb("#444444")),
)

#let fonts = (
  title: "Mathison",
  normal: "Ubuntu",
)

#let initialized(body) = dropcap(
  height: 8,
  gap: 1mm,
  font: fonts.title,
  fill: colors.primary,
  text(size: 10pt, body)
)

#let pages = (
  blank: if not is-printer-friendly {
    pagebreak()
    page(
      fill: colors.primary,
      background: none,
      numbering: none,
      footer: none,
      []
    )
  },
  toc: {
    set page(numbering: none, footer: none)
    show outline.entry.where(level: 1): it => {
      v(12pt, weak: true)
      strong(it)
    }
    outline(
      depth: 2,
      indent: auto,
    )
  },
  title: (
    title: [],
    author: "",
    upd: datetime.today(),
    size: 80pt,
    subtitle: none
  ) => [
    #set document(
      title: title,
      author: (author),
      keywords: (
        "KULT: divinity lost",
        "unofficial",
        "community made",
        "TTRPG",
        "scenario",
        "horror",
      ),
      date: upd,
    )
    #set page(numbering: none, footer: none, margin: 1cm)
    // #counter(page).update(1)
    #align(center + horizon)[#block(width: 100%)[
      #text(
        font: fonts.title,
        weight: "bold",
        fill: colors.secondary,
        size: size,
        title,
      ) <title>
      #v(2.3cm)
      #block(
        stroke: (x: colors.secondary + 2pt),
        fill: nice-or(colors.dark.transparentize(60%), default:none),
        radius: 5mm,
        outset: 1cm
      )[
        #set text(
          font: fonts.normal,
          fill: nice-or(colors.light),
          size: 18pt,
        )
        #text(size: 24pt, weight: "bold", author) \
        #text(upd.display()) \
        #text(sys.inputs.at("version", default: ""))
      ]
      #v(5cm)
      #block(width: 75%,
        radius: 2mm,
        fill: colors.light.transparentize(85%),
        inset: 5mm, text(fill: nice-or(colors.light))[
          This is an *unofficial* module for KULT: Divinity Lost. It is not
          affiliated with and/or endorsed by Helmgast AB. A copy of the *KULT:
          Divinity Lost 4th edition* core rules is required to play.
      ])
    ]]
  ]
)

#let move(
  title: [],
  tag: "",
  description: [],
  attribute: none,
  success: none,
  complications: none,
  failure: none,
  more: none,
) = block(breakable: false)[
    #heading(level:4)[#title #label(tag)]
    #block(stroke: (left: colors.secondary + 2pt), inset: (left: 2mm))[
      #block[#description#if(attribute != none){[ Roll #text(fill: colors.accent, [*+#attribute*])]}]
      #if (success != none and complications != none and failure != none) {
        block[
          #terms.item("(15+)", success)
          #terms.item("(10-14)", complications)
          #terms.item("(9-)", failure)
        ]
      }
      #if (more != none) { more }
    ]
  ]

