#import "@preview/cetz:0.4.1": draw, process, util

#let draw-operator(operator, ctx) = {
  import draw: *

  let op-name = operator.name
  ctx.last-anchor = (type: "coord", anchor: (rel: (operator.margin, 0), to: (name: op-name, anchor: "east")))

  (
    ctx,
    get-ctx(cetz-ctx => {

      let west-previous-mol-anchor = (name: ctx.last-name, anchor: "east")

      let east-op-anchor = (rel: (operator.margin, 0), to: west-previous-mol-anchor)

      let op = if (operator.op == none) {
        ""
      } else {
        operator.op
      }

      content(
        name: op-name,
        anchor: "west",
        east-op-anchor,
        op,
      )

			if (ctx.config.debug) {
				circle(west-previous-mol-anchor, radius: 0.05, fill: yellow, stroke: none)
				circle(ctx.last-anchor.anchor, radius: 0.05, fill: yellow, stroke: none)
			}
    }),
  )
}
