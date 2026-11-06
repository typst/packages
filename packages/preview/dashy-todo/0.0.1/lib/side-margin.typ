#let rel-to-abs = (rel, size) => rel.length + rel.ratio*size

#let calc-side-margin(side) = {
  // https://typst.app/docs/reference/layout/page/#parameters-margin
  let auto-margin = calc.min(page.width, page.height)*2.5/21

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