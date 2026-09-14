#import "@preview/basic-postcard:1.0.0": postcard

#set block(breakable: false)

#show: postcard.with(
  motif: read(encoding: none, "retro-landscape.png"),
  background-motif: image(width: 85%, "triangles.png"),
  margin: 5%,
  paper: "a6",
  flipped: true,
  post-stamp: [#rect(height: 30.13mm, width: 31.80mm, align(horizon + right, text(size: 5em, emoji.mail)))],
  footer: [Retro Landscape by GrossKahn, 2020],
  address-lines: ("John Doe", "7 Hairy Man Road", "Round Rock", "Texas", "78681", "USA"),
  address-lines-gutter: 1pt,
  address-line-length: 80%,
  address-stroke: stroke(1pt + color.fuchsia.darken(50%)),
  divider-dx: 60%,
  divider-length: 90%,
  divider-stroke: stroke(4pt + gradient.linear(..color.map.flare, angle: 90deg)),
  divider-gutter: 5%,
)
#lorem(32)
