#import "frames.typ": fill-width, stroke-of
#import "styles.typ": base, epigraph-presets

#let _option-list = base.keys().join(", ")

// Resolve a preset name or dictionary plus inline overrides into one complete
// style dictionary.
#let _resolve-style(style, overrides) = {
  let sty = if type(style) == str {
    if style not in epigraph-presets {
      panic(
        "cartouche: unknown style \"" + style + "\"; available styles: "
          + epigraph-presets.keys().join(", "),
      )
    }
    epigraph-presets.at(style)
  } else if type(style) == dictionary {
    base + style
  } else {
    panic("cartouche: `style` must be a preset name or a dictionary, found " + str(type(style)))
  }

  for (key, value) in overrides {
    if key not in base {
      panic("cartouche: unknown option `" + key + "`; valid options: " + _option-list)
    }
    sty.insert(key, value)
  }

  sty
}

// Build the attribution line from `by` and `from`.
#let _attribution(sty, by, from) = {
  if by == none and from == none { return none }
  if sty.attribution-format != auto {
    return (sty.attribution-format)(by, from)
  }
  let parts = ()
  if by != none { parts.push(by) }
  if from != none { parts.push(emph(from)) }
  [#sty.attribution-prefix#parts.join[, ]]
}

// Horizontal and vertical components of an alignment, `none` where absent.
#let _components(position) = {
  if type(position) != alignment { return (none, none) }
  (position.x, position.y)
}

/// Set an epigraph: a short quotation placed at the threshold of a document,
/// chapter or section.
///
/// - body (content): The quotation itself.
/// - by (none, content, str): Who is being quoted.
/// - from (none, content, str): The work being quoted, rendered with
///   italics by default.
/// - style (str, dictionary): A name from `epigraph-presets`, or a style
///   dictionary.
/// - position (auto, alignment): `auto` sets the epigraph in the text flow.
///   An alignment such as `top + end` or `horizon + center` pins it to an
///   edge or corner. An alignment with only a horizontal component keeps the
///   epigraph at its place in the flow and pulls it sideways.
/// - anchor (str): What `position` is measured against. `"area"`, the
///   default, is the area the epigraph sits in — the text block of the page,
///   or the enclosing container. `"page"` is the whole sheet of paper,
///   margins included; `align` does not apply there, and a missing
///   component of `position` centres on that axis.
/// - float (bool, length): Let a `top`- or `bottom`-positioned epigraph
///   displace the text instead of overlapping it. A length floats with that
///   much clearance.
/// - dx (relative): Horizontal nudge; needs a `position`.
/// - dy (relative): Vertical nudge; needs a `position`.
/// - ..overrides (any): Any key of a style dictionary, overriding the style
///   for this epigraph only.
/// -> content
#let epigraph(
  body,
  by: none,
  from: none,
  style: "classic",
  position: auto,
  anchor: "area",
  float: false,
  dx: 0pt,
  dy: 0pt,
  ..overrides,
) = {
  if overrides.pos().len() > 0 {
    panic("cartouche: `epigraph` takes one positional argument, the quote body")
  }
  if position != auto and type(position) != alignment {
    panic("cartouche: `position` must be `auto` or an alignment, found " + str(type(position)))
  }
  if anchor != "area" and anchor != "page" {
    panic("cartouche: `anchor` must be \"area\" or \"page\", found " + repr(anchor))
  }
  if position == auto {
    // These only mean something once the epigraph leaves the flow.
    if float != false {
      panic("cartouche: a floating epigraph needs `position: top` or `position: bottom`")
    }
    if anchor != "area" {
      panic("cartouche: `anchor` has no effect without a `position`")
    }
    if dx != 0pt or dy != 0pt {
      panic("cartouche: `dx` and `dy` have no effect without a `position`")
    }
  }

  let sty = _resolve-style(style, overrides.named())
  let attribution = _attribution(sty, by, from)
  let floating = float != false
  let clearance = if floating and float != true { float } else { 1.5em }

  let text-align = if sty.text-align == auto { start } else { sty.text-align }
  let attribution-align = if sty.attribution-align == auto {
    text-align
  } else {
    sty.attribution-align
  }

  // `quote` picks the right quotation marks for the current language.
  let quoted = if sty.quotes { quote(quotes: true, body) } else { body }

  // The frame fills the width given to it, so sizing happens one level up.
  let inner(width) = block(width: width, {
    set par(..sty.par)
    set text(..sty.text)
    align(text-align, quoted)
    if attribution != none {
      v(sty.gap, weak: true)
      if sty.divider != false and sty.divider != none {
        context line(
          length: 100%,
          stroke: if sty.divider == true { stroke-of(sty) } else { sty.divider },
        )
        v(sty.gap, weak: true)
      }
      align(attribution-align, {
        set text(..sty.attribution-text)
        attribution
      })
    }
  })

  // `width: auto` shrinks to the quote: its natural width, but never wider
  // than the space available.
  let framed = if sty.width == auto {
    layout(available => {
      // The quote's natural width, capped at the space available. The frame
      // may add an inset on top, so take it off again if that overflows.
      let natural = calc.min(measure(inner(auto)).width, available.width)
      let framed = (sty.frame)(inner(natural), sty)
      let overflow = measure(framed).width - available.width
      if overflow > 0pt { (sty.frame)(inner(natural - overflow), sty) } else { framed }
    })
  } else {
    block(width: sty.width, (sty.frame)(inner(100%), sty))
  }

  // A pinned epigraph takes its horizontal placement from `position`; only
  // fall back to the style's own alignment when `position` leaves x open.
  let (x, y) = _components(position)
  let aligned = if sty.align != auto and x == none {
    align(sty.align, framed)
  } else {
    framed
  }

  if position == auto {
    let spacing = (:)
    if sty.above != auto { spacing.insert("above", sty.above) }
    if sty.below != auto { spacing.insert("below", sty.below) }
    block(width: 100%, ..spacing, aligned)
  } else if anchor == "page" {
    if floating {
      panic("cartouche: a floating epigraph cannot be combined with `anchor: \"page\"`")
    }
    // Offsetting by the current position lands on the paper's top left
    // corner, whatever container the epigraph is called from.
    context {
      if page.width == auto or page.height == auto {
        panic("cartouche: `anchor: \"page\"` needs a page of fixed width and height")
      }
      let origin = here().position()
      let on-page = (if x == none { center } else { x }) + (if y == none { horizon } else { y })
      place(
        dx: dx - origin.x,
        dy: dy - origin.y,
        block(width: page.width, height: page.height, align(on-page, framed)),
      )
    }
  } else {
    if floating {
      if y != top and y != bottom {
        panic("cartouche: a floating epigraph needs a `position` of `top` or `bottom`")
      }
      if x != none {
        panic("cartouche: a floating epigraph cannot take a horizontal position; "
          + "use `position: " + repr(y) + "` and `align` instead")
      }
    }
    place(position, dx: dx, dy: dy, float: floating, clearance: clearance, aligned)
  }
}
