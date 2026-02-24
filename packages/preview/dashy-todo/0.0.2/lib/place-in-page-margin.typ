#import "side-margin.typ": calc-side-margin

#let place-in-page-margin(body, cur-pos: none, position: auto) = (
  box({
    let side = position
    if position == auto {
      if cur-pos.x > page.width / 2 {
        side = right
      } else {
        side = left
      }
    }

    // caclulation based on https://typst.app/docs/reference/layout/page/#parameters-margin
    let page-side-margin = calc-side-margin(side)

    let target-x = if side == left { 0pt } else { page.width - page-side-margin }
    let delta-x = target-x - cur-pos.x

    place(dx: delta-x)[
      #box(body, width: page-side-margin)
    ]
  })
)