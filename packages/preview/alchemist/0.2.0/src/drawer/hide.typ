#import "@preview/cetz:0.5.2"

#let draw-hide(hide, ctx, draw-fragment-and-link) = {
  let hold-hide = ctx.hide
  ctx.hide = true
  let (hide-ctx, drawing, cetz-rec) = draw-fragment-and-link(
    ctx,
    hide.body,
  )
  hide-ctx.hide = hold-hide
  drawing = cetz.draw.hide(drawing, bounds: hide.bounds)
  cetz-rec = cetz.draw.hide(cetz-rec, bounds: hide.bounds)
  (hide-ctx, drawing, cetz-rec)
}