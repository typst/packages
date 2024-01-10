// Create a longer arrow, almost the way TeX does it. That is, repeating a truncated version
// of the symbol. This is arguably less elegant than using the scale function, but
// will look better with most renderers.
// The symbol is divided in three parts, as defined by the section parameter.
// Please adjust this parameter and/or use longer versions of the given arrows
// if artefacts occur.
#let xarrow(
  sym: sym.arrow.long, // the arrow symbol to use
  margin: 0.15em, // margins surrounding body over the symbol on each side
  width: auto, // override variable width 
  sections: (40%, 60%), // delimiting the symbol in three parts, the central one is repeated
  partial_repeats: true, // whether the central part can be partially repeated
  position: top, // default position of the main argument
  opposite: none, // content on the opposite, non-default side of the arrow
  body
) = style(styles => {
  assert(type(sym) == symbol, message: "xarrow: input symbol must be of type `symbol`")

  // put the symbol in a barebone equation block in order to
  // measure and lay it out correctly
  let sym = math.equation(block: true, numbering: none, sym)

  let (begin, end) = sections
  assert(begin > 0%, message: "xarrow: middle section must start within the symbol")
  assert(begin < end, message: "xarrow: sections must be given in increasing order")
  assert(end < 100%, message: "xarrow: middle section must end within the symbol")

  let (top_content, bottom_content) = if position == top {
    (body, opposite)
  } else if position == bottom {
    (opposite, body)
  } else {
    panic("xarrow: incorrect body position `" + repr(position) + "`")
  }
  
  let (body_width, _) = measure($limits("") ^#top_content _#bottom_content$, styles).values()
  let (sym_w, sym_h) = measure(sym, styles).values()

  // Using styles to find the value of the margins, otherwise not comparable
  let margin_absolute = measure(line(length: margin), styles).width
  let repeated_width = body_width + 2 * margin_absolute - (100% - end + begin) * sym_w

  if type(width) == length {
    let width = measure(line(length: width), styles).width
    repeated_width = width - (100% - end + begin) * sym_w
  } else if width != auto {
    panic("xarrow: unsupported width type `" + repr(type(width)) + "`")
  }
  
  // Repeat the body to fit the given width
  let fit_width(width, styles, partial_repeats, body) = {
    let (body_width, body_height) = measure(body, styles).values()
    if partial_repeats {
      let repeats = calc.floor(width / body_width)
      let remainder = width - repeats * body_width
      body * repeats
      box(height: body_height, width: remainder, clip: true, body)
    } else {
      let repeats = calc.ceil(width / body_width)
      body * repeats
    }
  }

  math.class("relation", math.attach(
    math.limits({
      if repeated_width < (end - begin) * sym_w {
        sym
      } else {
        // The contents in the boxes are centered, using `place` to center the view
        // on the desired sections. Cannot use `align` because it doesn't affect `block`s.
        box(width: begin * sym_w, height: sym_h, clip: true,
          place(dx: (100% - begin) / 2 * sym_w, sym)
        )
        
        fit_width(repeated_width, styles, partial_repeats,
          box(height: sym_h, width: (end - begin) * sym_w, clip: true,
            place(dx: (100% - begin - end) / 2 * sym_w, sym)
          )
        )
          
        box(width: (100% - end) * sym_w, height: sym_h, clip: true,
          place(dx: - end / 2 * sym_w, sym)
        )
      }
    }),
    t: top_content,
    b: bottom_content,
  ))
})

// Some alternative arrow styles.
#let xarrowDashed = xarrow.with(sym: sym.arrow.dashed, sections: (20%, 51%), partial_repeats: false)
#let xarrowDouble = xarrow.with(sym: sym.arrow.double.long)
#let xarrowHook = xarrow.with(sym: sym.arrow.hook)
#let xarrowLeftRight = xarrow.with(sym: sym.arrow.l.r, sections: (33%, 66%))
#let xarrowLeftRightDouble = xarrow.with(sym: sym.arrow.l.r.double, sections: (40%, 60%))
#let xarrowSquiggly = xarrow.with(sym: sym.arrow.long.squiggly, sections: (20%, 45%), partial_repeats: false)
#let xarrowTwoHead = xarrow.with(sym: sym.arrow.twohead, sections: (10%, 20%), partial_repeats: false)

