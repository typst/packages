#import "/src/lib.typ": *

#let hex-abc = "0123456789abcdef"
#let g = gradient.linear(
  red,
  orange,
  yellow,
  green,
  aqua,
  blue,
  purple
)
#let colorize-hex(txt) = {
  let chars = txt.clusters().map(c => {
    let v = hex-abc.position(c)
    let color = g.sample(v * 100% / 15).lighten(20%).desaturate(40%)
    box(
      fill: color,
      inset: (x: 1pt),
      outset: (
        top: 1pt + 0.5pt * v,
        bottom: 1pt + 0.5pt * v
      ),
      raw(c)
    )
  })

  set text(fill: black)
  chars.join()
}

#let txt = "Jumble"
#let cipher = bytes-to-hex(sha1(txt))

#let banner = [*sha1("#txt") =* #colorize-hex(cipher)]

#let theme = sys.inputs.at("theme", default: "default")

#set page(
  width: auto,
  height: auto,
  margin: 1cm,
  fill: if theme == "default" {white} else {none}
)

#set text(
  size: 12pt,
  font: "Source Sans 3",
  fill: if theme == "dark" {white} else {black}
)

#banner