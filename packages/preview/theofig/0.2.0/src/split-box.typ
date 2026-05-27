// This is adaptation of the code by isuffix:
// https://sitandr.github.io/typst-examples-book/book/typstonomicon/block_break.html#implementation-via-headers-footers-and-stated

/// Create a box for content which spans multiple pages/columns and
/// has custom borders above and below the column-break.
///
/// Source: https://sitandr.github.io/typst-examples-book/book/typstonomicon/block_break.html#implementation-via-headers-footers-and-stated
///
/// - stroke (auto, stroke, dictionary): How to stroke the borders
///
///   This can be:
///
///   - `auto` for a stroke of `1pt + black` for `top,bottom,left,right` borders (without `between` borders)
///
///   - any kind of stroke for `top,bottom,left,right`
///
///   - A dictionary describing the stroke for each side individually. The
///     dictionary can contain the following keys in order of precedence:
///
///     - `left`, `right`, `top`, `bottom`, `between-top`, `between-bottom`,
///     - `x` for `left` and `right`, `y` for `top` and `bottom`, `between` for `between-top` and `between-bottom`,
///     - `outer` for all sides except `between-top` and `between-bottom`,
///     - `rest` for all sides
///
///
/// - inset (length, dictionary): How much to pad the content of the split-box.
///
///   This can be:
///
///   - a length, that sets the padding for all sides with non-0pt strokes
///
///   - A dictionary describing the padding for each side individually. The
///     dictionary can contain the following keys in order of precedence:
///
///     - `left`, `right`, `top`, `bottom`, `between-top`, `between-bottom`,
///     - `x` for `left` and `right`, `y` for `top` and `bottom`, `between` for `between-top` and `between-bottom`,
///     - `outer` for all sides except `between-top` and `between-bottom`,
///     - `rest` for all sides
///   
/// - ..args (arguments): Any extra named args will be sent to the underlying grid when called.
///
///   This is useful for fill, align, etc.
///
#let theofig-split-box(
  stroke: auto,
  inset: 5pt,
  body,
  ..args
) = {
  let strokes = {
    if stroke == auto {
      stroke = 1pt + black
    }
    if type(stroke) == std.stroke {
      (
        top: stroke, bottom: stroke, 
        left: stroke, right: stroke, 
        between-top: 0pt, 
        between-bottom: 0pt
      )

    }
    else {
      (
        left: stroke.at(
          "left", 
          default: stroke.at(
            "x", 
            default: stroke.at(
              "outer",
              default: stroke.at(
                "rest", 
                default: 0pt)
              )
            )
          ), 
        right: stroke.at(
          "right", 
          default: stroke.at(
            "x", 
            default: stroke.at(
              "outer",
              default: stroke.at(
                "rest", 
                default: 0pt)
              )
            )
          ), 
        top: stroke.at(
          "top", 
          default: stroke.at(
            "y", 
            default: stroke.at(
              "outer",
              default: stroke.at(
                "rest", 
                default: 0pt)
              )
            )
          ), 
        bottom: stroke.at(
          "bottom", 
          default: stroke.at(
            "y", 
            default: stroke.at(
              "outer",
              default: stroke.at(
                "rest", 
                default: 0pt)
              )
            )
          ), 
        between-top: stroke.at(
          "between-top", 
          default: stroke.at(
            "between", 
            default: stroke.at(
              "rest", 
              default: 0pt
            )
          )
        ),
        between-bottom: stroke.at(
          "between-bottom", 
          default: stroke.at(
            "between", 
            default: stroke.at(
              "rest", 
              default: 0pt
            )
          )
        ),
      )
    }
  }

  let insets = if type(inset) == length {
    (
      left:            if (strokes.left == 0pt)           {0pt} else {inset},
      right:           if (strokes.right == 0pt)          {0pt} else {inset},
      top:             if (strokes.top == 0pt)            {0pt} else {inset},
      bottom:          if (strokes.bottom == 0pt)         {0pt} else {inset},
      between-top:     if (strokes.between-top == 0pt)    {0pt} else {inset},
      between-bottom:  if (strokes.between-bottom == 0pt) {0pt} else {inset},
    )
  } else {
    let rest = inset.at("rest", default: 0pt)
    let outer = inset.at("outer", default: rest)
    let between = inset.at("between", default: rest)
    let x = inset.at("x", default: outer)
    let y = inset.at("y", default: outer)
    (
      left:            inset.at("left", default: x),
      right:           inset.at("right", default: x),
      top:             inset.at("top", default: y),
      bottom:          inset.at("bottom", default: y),
      between-top:     inset.at("between-top", default: between),
      between-bottom:  inset.at("between-bottom", default: between),
    ) 
  }


  let split-box-counter = counter("split-box-counter")
  split-box-counter.step()
  let header-counter = counter("split-box-counter" + str(split-box-counter.get().at(0)))

  let border-top = context {
    if header-counter.get() == (0,) { 
      line(length: 100%, stroke: strokes.top)
    } 
    else { 
      line(length: 100%, stroke: strokes.between-top)
    }
    header-counter.step()
  }
  let border-bottom = context {
    if header-counter.get() == header-counter.final() { 
      line(length: 100%, stroke: strokes.bottom)
    } 
    else { 
      line(length: 100%, stroke: strokes.between-bottom)
    }
  }

  grid(
    ..args.named(),
    grid.vline(stroke: strokes.left, start: 0, end: 3),
    grid.header(border-top, repeat: true),
    context{
      grid.cell(
        [
          #v(insets.top - insets.between-top) 
          #body
          #v(insets.bottom - insets.between-bottom) 
        ], 
        inset: (
          left: insets.left, 
          right: insets.right,
          top: insets.between-top,
          bottom: insets.between-bottom,
        )
      )
    },
    grid.footer(border-bottom, repeat: true),
    grid.vline(stroke: strokes.right),
  )
}
