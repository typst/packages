#import "@preview/cetz:0.4.2"

#let draw-hide(hide, ctx, draw-molecules-and-link) = {
  ctx.hide = true
  let (hide-ctx, drawing, cetz-rec) = draw-molecules-and-link(
    ctx,
    hide.body,
  )
  hide-ctx.hide = false
  drawing = cetz.draw.hide(drawing, bounds: hide.bounds)
  (hide-ctx, drawing, cetz-rec)
}