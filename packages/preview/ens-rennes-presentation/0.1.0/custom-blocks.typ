// Blocks

#let tblock(color: black, title: none, it) = {
  show : block.with(breakable:false)
  grid(
    columns: 1,
    row-gutter: 0pt,
    block(
      fill: color,
      width: 100%,
      radius: (top: 6pt),
      inset: (top: 0.4em, bottom: 0.4em, left: 0.5em, right: 0.5em),
      text(fill:white, title),
    ),
    block(
      fill: color.lighten(90%),
      width: 100%,
      radius: (bottom: 6pt),
      inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
      it,
    ),
  )
}

#let new-block(kind: none, color:black) = (title:none, body) => tblock(color: color, title: 
  if title == none [
    #kind
  ] else [
    #kind (#title)
  ]
)[#body]
