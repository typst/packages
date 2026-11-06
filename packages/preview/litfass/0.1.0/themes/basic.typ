#let _p-block(ctx, cnt, title: none) = context {
  let dims = ctx.dims

  let title-cnt = if title == none {none} else {
    set align(center + horizon)
    set text(
      size: ctx.theme.box.title.text.size, 
      fill: ctx.theme.box.title.text.color,
      weight: "bold"
    )
    title
  }

  let (title-width, title-height) = if title == none {(0pt,0pt)} else {
    let stroke-thickness = if type(ctx.theme.box.stroke) == length {
      ctx.theme.box.stroke
    } else if type(ctx.theme.box.stroke) == stroke {
      ctx.theme.box.stroke.thickness
    } else {
      0pt
    }

    (
      ctx.dims.wh.width,
      measure(title-cnt).height + 2*ctx.theme.box.title.inset
    )
  }

  let box-bot-left = dims.pos
  let box-top-rig = (dims.pos.x + dims.wh.width, dims.pos.y + dims.wh.height - title-height)
  place(
    top + left,
    dx: dims.pos.x,
    dy: dims.pos.y + title-height,
    box(
      {
        set par(justify: true)
        cnt
      },
      stroke: ctx.theme.box.stroke,
      width: dims.wh.width,
      height: dims.wh.height - title-height,
      radius: ctx.theme.box.radius,
      inset: ctx.theme.box.inset, 
      fill: ctx.theme.box.background,
      clip: true
    )
  )
  if title != none {
    place(
      top + left,
      dx: dims.pos.x,
      dy: dims.pos.y,
      box(
        title-cnt,
        inset: 0.25em,
        width: title-width,
        height: title-height,
        radius: ctx.theme.box.radius,
        stroke: ctx.theme.box.stroke,
        clip: true,
        fill: ctx.theme.box.title.background
      )
    )
  }
}

#let theme = (
  padding: 1em,
  box: (
    padding: 1em,
    inset: 1em,
    background: white,
    radius: 0em,
    stroke: 0em,
    footnote: (
      text: (
        size: 0.8em,
      ),
    ),
    title: (
      text: (
        size: 1.5em,
        color: white,
      ),
      background: rgb("#1e417a"),
      inset: 0.5em,
    )
  ),
  background: white,
  p-block: _p-block
)
