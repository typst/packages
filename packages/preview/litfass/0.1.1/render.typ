#import "tiling.typ": pad
#import "themes/lib.typ": basic as theme

// Applies a tiling layout to a given context and renders the provided contents
//
// tiling: The tiling layout which gets created by possibly nested tiling functions, e.g. vs, hs, pad
// ctx: the context element to apply the tiling to
#let apply(tiling, ctx) = {
  if type(tiling(ctx)) == function {
    return tiling(ctx)()
  } else {
    return tiling(ctx).flatten().fold([], (acc, x) => acc + x())
  }
}

// The tiling context contains the bounding box within a tiling can be applied, a
// theme and a convenience handle to the box-footnotes state which is an internal
// to capture footnotes per box.
//
// dims: (
//   pos: (x: lenght, y: length), 
//   wh: (width: length, height: lenght)   // (width, height)
// )
//
// theme: a theme to use to render content, see the themes submodule for a 
// selection of default themes
#let create-context(dims, theme: theme) = {
  let ctx = (
    dims: dims,
    theme: theme,
    box-footnotes: state("box-footnotes", ())
  )
  return ctx
}

#let poster(tiling, theme: theme) = {
  set page(
    margin: 0pt
  )

  
  context box(
    width: page.width,
    height: page.height,
    clip: true,

    {
      let ctx = create-context(
        (
          pos: (x: 0pt, y: 0pt),
          wh: (width: page.width, height: page.height)
        ),
        theme: theme
      )

      if type(theme.background) == color {
        place(
          top + left,
          dx: ctx.dims.pos.x,
          dy: ctx.dims.pos.y,
          rect(width: ctx.dims.wh.width, height: ctx.dims.wh.height, fill: theme.background)
        )
      } else if type(theme.background) == function {
        theme.at("background")(ctx)
      }

      apply(pad(padding: theme.padding, tiling), ctx) 
    }
  )
}


#let inline-box(tiling, width: 100%, height: 5em, theme: theme, ..box-args) = {
  let ctx = create-context(
    (
      pos: (x: 0pt, y: 0pt),
      wh: (width: 100%, height: 100%)
    ),
    theme: theme
  )
  box(
    width: width,
    height: height,
    ..box-args,
    { 
      if type(theme.background) == color {
        place(
          top + left,
          dx: ctx.dims.pos.x,
          dy: ctx.dims.pos.y,
          rect(width: ctx.dims.wh.width, height: ctx.dims.wh.height, fill: theme.background)
        )
      } else if type(theme.background) == function {
        theme.at("background")(ctx)
      }
      apply(pad(padding: ctx.theme.padding, tiling), ctx)
    }
  )
}
