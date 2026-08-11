#import "_util.typ"
#import "_draw.typ"

#let cases(
  ..options,
  delim: ("{", "}"),
  reverse: false,
  align: horizon
) = {
  delim = _util.parse-delim(delim)
  if align.x == none {
    if type(delim) == array {
      align += center
    } else if reverse == false {
      align += left
    } else {
      align += right
    }
  }
  let baseline = 0% + 0.225em
  if align.y == horizon {
    baseline = 50% - 0.35em
  } else if align.y == top {
    baseline = 100% - 0.9em
  }
  let option-grid = grid(align: align, gutter: 0.5em, ..options)
  context {
    let option-grid-height = measure(option-grid).height
    let items = ()
    if delim.left != none {
      items.push(_draw.bracket(delim.left, option-grid-height))
    }
    items.push(option-grid)
    if delim.right != none {
      items.push(_draw.bracket(delim.right, option-grid-height))
    }
    box(
      baseline: baseline,
      stack(
        dir: ltr,
        spacing: 0.15em,
        ..items
      )
    )
  }
}

#let cases-left = cases.with(delim: ("{", none))
#let cases-right = cases.with(delim: (none, "}"))
