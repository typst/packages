// Create a longer arrow, almost the way TeX does it. That is, repeating a truncated version
// of the symbol. This is arguably less elegant than using the scale function, but
// will look better with most renderers.
// The symbol is divided is three parts, as defined by the section parameter.
// Please adjust this parameter and/or use longer versions of the given arrows
// if artefacts occur.
#let xarrow(
  sym: sym.arrow.long, // the arrow symbol to use
  margin: 0.15em, // margins surrounding body over the symbol on each side
  sections: (40%, 60%), // delimiting the symbol in three parts, the central one is repeated
  reducible: false, // whether the symbol can be shorter than the original if body is too narrow
  partial_repeats: true, // whether the central part can be partially repeated
  body
) = style(styles => {
  assert(type(sym) == "symbol", message: "xarrow: input symbol must be of type `symbol`")

  // put the symbol in a barebone equation block in order to
  // measure and lay it out correctly
  let sym = math.equation(block: true, numbering: none, sym)

  let (begin, end) = sections
  assert(begin > 0%, message: "xarrow: middle section must start within the symbol")
  assert(begin < end, message: "xarrow: sections must be given in increasing order")
  assert(end < 100%, message: "xarrow: middle section must end within the symbol")
  
  let (body_width, _) = measure($limits("")^#body$, styles).values()
  let (sym_w, sym_h) = measure(sym, styles).values()

  // Using styles to find the value of the margins, otherwise not comparable
  let margin_absolute = measure(line(length: margin), styles).width
  let repeated_width = body_width + 2 * margin_absolute - (100% - end + begin) * sym_w
  
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

  // using non-empty baseline to trick the compiler and not recomputing another
  // baseline for the box, which would lead to incorrect alignment.
  box(baseline: 1e-10pt, math.attach(
    math.limits({
      if not reducible and repeated_width < (end - begin) * sym_w {
        sym
      } else {
        // The contents in the boxes are centered, using `place` to center the view
        // on the desired sections.
        box(width: begin * sym_w, height: sym_h, clip: true,
          place(dx: (100% - begin) / 2 * sym_w, sym)
        )
        h(0cm)
        
        fit_width(repeated_width, styles, partial_repeats,
          box(height: sym_h, width: (end - begin) * sym_w, clip: true,
            place(dx: (100% - begin - end) / 2 * sym_w, sym)
          )
        )
          
        h(0cm)
        box(width: (100% - end) * sym_w, height: sym_h, clip: true,
          place(dx: - end / 2 * sym_w, sym)
        )
      }
    }),
    t: body,
  ))
})

// Some alternative arrow styles.
#let xarrowDashed = xarrow.with(sym: sym.arrow.dashed, sections: (20%, 51%), partial_repeats: false)
#let xarrowDouble = xarrow.with(sym: sym.arrow.double.long)
#let xarrowHook = xarrow.with(sym: sym.arrow.hook)
#let xarrowSquiggly = xarrow.with(sym: sym.arrow.long.squiggly, sections: (20%, 45%), partial_repeats: false)
#let xarrowTwoHead = xarrow.with(sym: sym.arrow.twohead, sections: (10%, 20%), partial_repeats: false)

