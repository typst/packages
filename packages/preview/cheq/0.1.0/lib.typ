#let unchecked-sym(fill: white, stroke: rgb("#616161"), radius: .1em) = move(
  dy: -.08em,
  box(stroke: .05em + stroke, fill: fill, height: .8em, width: .8em, radius: radius),
)

#let checked-sym(fill: white, stroke: rgb("#616161"), radius: .1em) = move(
  dy: -.08em,
  box(
    stroke: .05em + stroke,
    fill: stroke,
    height: .8em,
    width: .8em,
    radius: radius,
    {
      box(move(dy: .48em, dx: 0.1em, rotate(45deg, line(length: 0.3em, stroke: fill + .1em))))
      box(move(dy: .38em, dx: -0.05em, rotate(-45deg, line(length: 0.48em, stroke: fill + .1em))))
    },
  ),
)

#let checklist(
  fill: white,
  stroke: rgb("#616161"),
  radius: .1em,
  default: ([•], [‣], [–]),
  unchecked: auto,
  checked: auto,
  body,
) = {
  let _typst-sequence = ([A] + [ ] + [B]).func()

  if unchecked == auto {
    unchecked = unchecked-sym(fill: fill, stroke: stroke, radius: radius)
  }

  if checked == auto {
    checked = checked-sym(fill: fill, stroke: stroke, radius: radius)
  }

  show list.item: it => {
    if type(it.body) == content and it.body.func() == _typst-sequence {
      let children = it.body.children
      if children.len() >= 5 and children.slice(0, 4).sum() == [[ ] ] {
        set list(marker: unchecked)
        list.item({
          // use default marker for sublist
          set list(marker: default)
          children.slice(4).sum()
        })
      } else if children.len() >= 5 and children.slice(0, 4).sum() == [[x] ] {
        set list(marker: checked)
        list.item({
          // use default marker for sublist
          set list(marker: default)
          children.slice(4).sum()
        })
      } else {
        it
      }
    } else {
      it
    }
  }

  body
}