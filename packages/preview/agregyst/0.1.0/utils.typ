#import "@preview/cetz:0.4.1"
#import "@preview/jumble:0.0.1" : sha1
#let graph(g) = cetz.canvas(length: 1em, {
    import cetz.draw: *

    let r = if "radius" in g {g.radius} else {0.4}
    let links = g.links
    let nodes = g.nodes
    for node in nodes {
      circle(node.at(1), radius: r, name: node.at(0))
      content(node.at(0), [#node.at(0)])
    }
    for link in links {
      if (link.at(0) == "bezier") {
        set-style(mark: (end: ">"))
        bezier(
          (link.at(1), r, link.at(2)),
          (link.at(2), r, link.at(1)),
          link.at(3)
        )
      } else {
        set-style(mark: (end: ">"))
        line(..link)
      }
    }
})

#let todo = text(red, [*TODO*])

#let max = 1.bit-lshift(15)
#let color_from_string(s0, h: 150, s:200, v:255) = {
  let hash = array(sha1(s0))
  let value = hash.at(0).bit-lshift(8).bit-or(hash.at(1)).bit-lshift(8).bit-or(hash.at(2)) / (1.bit-lshift(8 * 3) - 1)
  // color.hsv(360deg * hash.at(0) / 255, h, s, v)
  color.hsv(360deg * value, h, s, v)
  // color.hsl(360deg * array(sha1(s0)).at(0)/255, 255, 180, 255)
}


#let colors_default = (
  GARD: red,
  // BOUQUIN : colors.rgb("#696969"),
)

#let colors_for_dev = (
  CSAPP: color.rgb("#696969"),
  PAT: color.rgb("#556b2f"),
  TOR:color.rgb("#a0522d"),
  VERT:color.rgb("#191970"),
  NSIP:color.rgb("#8b0000"),
  NSIT:color.rgb("#808000"),
  VIA:color.rgb("#008000"),
  VAH:color.rgb("#3cb371"),
  CAR:color.rgb("#008080"),
  BAR:color.rgb("#4682b4"),
  COR2:color.rgb("#9acd32"),
  COR3:color.rgb("#00008b"),
  OSC:color.rgb("#32cd32"),
  SED:color.rgb("#daa520"),
  OCA:color.rgb("#7f007f"),
  DRAG:color.rgb("#d2b48c"),
  COMPI:color.rgb("#ff4500"),
  TIGER:color.rgb("#00ced1"),
  SCHWARZ:color.rgb("#ff8c00"),
  DESG:color.rgb("#6a5acd"),
  BEAU:color.rgb("#ffff00"),
  CERV:color.rgb("#c71585"),
  MOS:color.rgb("#0000cd"),
  GEH:color.rgb("#00ff00"),
  HAI:color.rgb("#9400d3"),
  BEN:color.rgb("#ba55d3"),
  GARD: color.rgb("#dc143c"),
)
/*
#f4a460
#adff2f
#ff00ff
#1e90ff
#db7093
#f0e68c
#fa8072
#dda0dd
#87ceeb
#98fb98
#7fffd4
#fdf5e6
#ffb6c1
#2f4f4f
#2e8b57
#800000
#191970
#808000
#ff0000
#ff8c00
#ffd700
#ba55d3
#00ff7f
#00ffff
#0000ff
#f08080
#adff2f
#ff00ff
#1e90ff
#dda0dd
#ff1493
#87cefa
#fff8dc
*/
