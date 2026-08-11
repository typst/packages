#import "/src/cetz.typ": draw

#import "/src/consts.typ": *
#import "/src/core/utils.typ": get-ctx, set-ctx

#let render(sep) = get-ctx(ctx => {
  ctx.y -= Y-SPACE

  let x0 = ctx.x-pos.first() - 20
  let x1 = ctx.x-pos.last() + 20
  let m = measure(
    box(
      sep.name,
      inset: (left: 3pt, right: 3pt, top: 5pt, bottom: 5pt)
    )
  )
  let w = m.width / 1pt
  let h = m.height / 1pt
  let cx = (x0 + x1) / 2
  let xl = cx - w / 2
  let xr = cx + w / 2

  ctx.y -= h / 2
  draw.rect(
    (x0, ctx.y),
    (x1, ctx.y - 3),
    stroke: none,
    fill: white
  )
  draw.line((x0, ctx.y), (x1, ctx.y))
  ctx.y -= 3
  draw.line((x0, ctx.y), (x1, ctx.y))
  draw.content(
    ((x0 + x1) / 2, ctx.y + 1.5),
    sep.name,
    anchor: "center",
    padding: (5pt, 3pt),
    frame: "rect",
    fill: COL-SEP-NAME
  )
  ctx.y -= h / 2

  set-ctx(c => {
    c.y = ctx.y
    return c
  })
})
