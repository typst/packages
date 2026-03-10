#set page(margin: 0pt, flipped: true)
#let pages = range(1, 13).map(i => rect(
  width: 100%,
  height: 100%,
  fill: color.hsv(i * 30deg, 30%, 100%),
))
#stack(..pages)
