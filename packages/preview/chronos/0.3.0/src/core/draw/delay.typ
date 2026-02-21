#import "/src/cetz.typ": draw

#import "/src/core/utils.typ": get-ctx, set-ctx

#let render(delay) = get-ctx(ctx => {
  let y0 = ctx.y
  let y1 = ctx.y - delay.size
  for (i, line) in ctx.lifelines.enumerate() {
    line.lines.push(("delay-start", y0))
    line.lines.push(("delay-end", y1))
    ctx.lifelines.at(i) = line
  }
  if delay.name != none {
    let x0 = ctx.x-pos.first()
    let x1 = ctx.x-pos.last()
    draw.content(
      ((x0 + x1) / 2, (y0 + y1) / 2),
      anchor: "center",
      delay.name
    )
  }
  ctx.y = y1
  set-ctx(c => {
    c.y = ctx.y
    c.lifelines = ctx.lifelines
    return c
  })
})