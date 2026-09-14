#let rel-to-abs = (rel, size) => rel.length + rel.ratio * size

// must run within a context
#let calc-side-margin(side) = {
  // https://typst.app/docs/reference/layout/page/#parameters-margin
  let auto-margin = calc.min(page.width, page.height) * 2.5 / 21

  if page.margin == auto {
    auto-margin
  } else if type(page.margin) == relative {
    rel-to-abs(page.margin, page.width)
  } else {
    if side == left and page.margin.left == auto or side == right and page.margin.right == auto {
      auto-margin
    } else {
      if side == left {
        rel-to-abs(page.margin.left, page.width)
      } else {
        rel-to-abs(page.margin.right, page.width)
      }
    }
  }
}

// must run within a context
#let calculate-page-margin-box(side) = {
  assert(side in (left, right))

  let margin = calc-side-margin(side)

  if side == left {
    (
      "x": 0pt,
      "y": 0pt,
      "width": margin,
      "height": page.height,
    )
  } else {
    (
      "x": page.width - margin,
      "y": 0pt,
      "width": margin,
      "height": page.height,
    )
  }
}