#let _replace-none(val, default) = if val == none {default} else {val}

#let comp-box-background(theme) = {
  if type(theme.box.background) != ratio {
    return theme.box.background
  }

  if type(theme.box.title.background) != color {
    if type(theme.box.background) == color{
      return theme.box.background
    } else {
      return none
    }
  }

  let hsl-components = theme.box.title.background.hsl().components()
  return color.hsl(hsl-components.at(0), hsl-components.at(1), theme.box.background)
}

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

  place(
    top + left,
    dx: dims.pos.x,
    dy: dims.pos.y,
    box(
      width: ctx.dims.wh.width,
      height: ctx.dims.wh.height,
      layout(size => {
        let title-box = box(
          title-cnt,
          inset: ctx.theme.box.title.inset,
          width: 100% * size.width ,
          radius: (top: ctx.theme.box.radius),
          stroke: ctx.theme.box.stroke,
          clip: true,
          fill: ctx.theme.box.title.background
        )

        let title-height = if title == none {0pt} else {measure(title-box).height}

        stack(
          dir: ttb,
          if title != none {title-box},
          box(
            {
            cnt
            },
            stroke: ctx.theme.box.stroke,
            width: 100%,
            height: 100% - title-height,
            radius: if title == none {ctx.theme.box.radius} else {(bottom: ctx.theme.box.radius)},
            inset: ctx.theme.box.inset, 
            //fill: ctx.theme.box.at("background", default: ctx.theme.box.title.background.lighten(95%)),
            fill: comp-box-background(ctx.theme),
            clip: true,
          )
        )
      })
    )
  )
}

#let theme = (
  padding: 1em,
  box: (
    padding: 1em,
    background: 90%,
    inset: 1em,
    radius: 0.5em,
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
      inset: 0.75em,
    )
  ),
  background: white,
  p-block: _p-block
)
