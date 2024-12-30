#let pigment-page-list-heading = [
  #link("https://typst.app/universe/package/pigmentpedia","pigmentpedia") by #link("https://github.com/neuralpain","neuralpain")
]

// color viewbox settings
#let colorbox = (radius: 100%, width: 100%, height: 1em)

#let colorbox-block-properties = (
  inset: 1em,
  radius: 10pt,
  width: 100%,
  spacing: 8mm,
)

// page setup for pigmentpedia view
#let pigmentpage = (
  fill: white,
  paper: "a4",
  margin: (x: 1cm, y: 2cm),
  foreground: none,
  background: none,
  header: align(center, text(11pt, pad(y: 3mm, pigment-page-list-heading))),
  footer: text(
    11pt,
    [#h(1fr) Pigment Page #context counter(page).display("1") #h(1fr)],
  ),
)

#let group-divider-line = (
  stroke: (
    thickness: 1pt,
    paint: gradient.linear(..color.map.rainbow),
  ),
  length: 100%,
)
