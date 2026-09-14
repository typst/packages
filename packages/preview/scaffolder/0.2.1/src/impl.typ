// A vertical line spanning the height of the page
#let vline(stroke, page-height) = line(
  start: (0pt, 0pt),
  end: (0pt, page-height),
  stroke: stroke
)

// A horizontal line spanning the width of the page
#let hline(stroke, page-width) = line(
  start: (0pt, 0pt),
  end: (page-width, 0pt),
  stroke: stroke
)

// rtl languages taken from the Typst compiler code as of 2025-03-24
#let rtl-languages = ("ar", "dv", "fa", "he", "ks", "pa", "ps", "sd", "ug", "ur", "yi")

// Resolve text.dir specification into the concrete ltr/rtl value.
//
// Requires context.
#let get-text-dir() = {
  if text.dir == ltr {
    ltr
  } else if text.dir == rtl {
    rtl
  } else if text.dir == auto {
    if rtl-languages.contains(text.lang) {
      rtl
    } else {
      ltr
    }
  } else {
    panic("Unexpected value for text.dir: ", text.dir)
  }
}

// Resolve page.binding specification into the concrete left/right value.
//
// Requires context.
#let get-page-binding() = {
  if page.binding == left {
    left
  } else if page.binding == right {
    right
  } else if page.binding == auto {
    if get-text-dir() == ltr {
      left
    } else {
      right
    }
  } else {
    panic("Unexpected value for page.binding: ", page.binding)
  }
}

// Resolve page.margin specification into the concrete lengths.
//
// Obtain page margins from page.margin via context and parse the specification
// in the same way as typst does to get the actual left/right/top/bottom
// values.
// If the "inside" or "outside" keys are given, this requires parsing
// page.binding.
//
// Requires context.
#let get-page-margins() = {
  // This computes Typst's default margin on all sides, which is used for each
  // side which is not explicitly specified through any of the keys in
  // page.margin.
  let min-dim = calc.min(
    if page.width == auto { 210mm } else { page.width },
    if page.height == auto { 297mm } else { page.height },
  )
  let default-margin = 2.5 / 21 * min-dim

  // Initialize all margins to `auto`, then go through page.margin in the order
  // of precedence specified in Typst's docs and update them.
  let margins = (top: auto, bottom: auto, left: auto, right: auto)
  if type(page.margin) == dictionary {
    let binding = if "inside" in page.margin or "outside" in page.margin {
      get-page-binding()
    } else {
      left   // dummy value, it is not required below
    }

    if "rest" in page.margin {
      let value = page.margin.rest
      margins.top = value
      margins.bottom = value
      margins.left = value
      margins.right = value
    }
    if "x" in page.margin {
      margins.left = page.margin.x
      margins.right = page.margin.x
    }
    if "y" in page.margin {
      margins.top = page.margin.y
      margins.bottom = page.margin.y
    }
    if "inside" in page.margin {
      if binding == left {
        if calc.odd(here().page()) {
          margins.left = page.margin.inside
        } else {
          margins.right = page.margin.inside
        }
      } else {
        if calc.odd(here().page()) {
          margins.right = page.margin.inside
        } else {
          margins.left = page.margin.inside
        }
      }
    }
    if "outside" in page.margin {
      if binding == left {
        if calc.odd(here().page()) {
          margins.right = page.margin.outside
        } else {
          margins.left = page.margin.outside
        }
      } else {
        if calc.odd(here().page()) {
          margins.left = page.margin.outside
        } else {
          margins.right = page.margin.outside
        }
      }
    }
    if "top" in page.margin {
      margins.top = page.margin.top
    }
    if "bottom" in page.margin {
      margins.bottom = page.margin.bottom
    }
    if "left" in page.margin {
      margins.left = page.margin.left
    }
    if "right" in page.margin {
      margins.right = page.margin.right
    }
  } else {
    let value = page.margin
    margins.top = value
    margins.bottom = value
    margins.left = value
    margins.right = value
  }

  // Set all remaining `auto` values to the default.
  for (k, v) in margins {
    if v == auto {
      margins.at(k) = default-margin
    }
  }

  return margins
}

// Defines the default stroke
#let __default-stroke = stroke(
  thickness: 0.5pt,
  paint: rgb(0, 0, 0, 128),
  dash: "densely-dashed",
)

// Display lines around the main text area, header and footer.
#let scaffolding(
  stroke: __default-stroke,
) = context {
  let margins = get-page-margins()

  // Rotate page clockwise for landscape mode
  // cf. https://github.com/typst/typst/issues/4158
  let page-height = if page.flipped { page.width } else { page.height }
  let page-width = if page.flipped { page.height } else { page.width }

  let hl = hline(stroke, page-width)
  let vl = vline(stroke, page-height)

  // Main text area
  place(top + left, dx: margins.left, vl)
  place(top + left, dx: page-width - margins.right, vl)
  place(top + left, dy: margins.top, hl)
  place(top + left, dy: page-height - margins.bottom, hl)

  // Header
  let ascent = page.header-ascent.ratio * margins.top - page.header-ascent.length
  place(top + left, dy: margins.top - ascent, hl)

  // Footer
  let descent = page.footer-descent.ratio * margins.bottom + page.footer-descent.length
  place(top + left, dy: page-height - margins.bottom + descent, hl)

  // If the page more than a single column, show additional lines highlighting
  // the column gutter.
  if page.columns > 1 {
    let textwidth = page-width - margins.left - margins.right
    let gutter = columns.gutter.length + columns.gutter.ratio * textwidth
    let col-width = (textwidth - (page.columns - 1) * gutter) / page.columns
    let dx = margins.left
    for i in range(1, page.columns) {
      dx += col-width
      place(top + left, dx: dx, vl)
      dx += gutter
      place(top + left, dx: dx, vl)
    }
  }
}
