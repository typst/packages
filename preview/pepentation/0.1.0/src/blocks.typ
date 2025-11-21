#let _style-raw(color: none, content) = {
  let bg = luma(240)
  let fill = if color != none { bg.rgb().mix(color) } else { bg }
  box(
    fill: fill,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 5pt,
    content
  )
}

#let _presentation-block(color: gray, raw-color: none, content) = {
  let rc = if raw-color == none { color } else { raw-color }
  show raw.where(block: false): it => _style-raw(color: rc, it.text)
  box(
    fill: color.transparentize(80%),
    radius: 1em,
    outset: 0.5em,
    width: 100%,
    content
  )
}

#let definition(content) = _presentation-block(color: gray, content)
#let warning(content) = _presentation-block(color: red, content)
#let remark(content) = _presentation-block(color: orange, content)
#let hint(content) = _presentation-block(color: green, content)
