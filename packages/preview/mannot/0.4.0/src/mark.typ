#import "util.typ": coerce-outset, default-stroke


#let _sequence-func = ([x] + [y]).func()
#let _align-point-func = $&$.body.func()

#let _remove-leading-h(body) = {
  if type(body) == content {
    if body.func() == math.equation {
      return _remove-leading-h(body.body)
    } else if body.func() == _sequence-func {
      let children = body.children
      if children.len() == 0 {
        return (none, none)
      }
      let rest
      let remove
      let leadingCount = 0
      for c in children {
        if c == [ ] {
          leadingCount += 1
          continue
        }
        let (crest, cremove) = _remove-leading-h(c)
        rest = crest
        remove += cremove
        if rest != none {
          break
        }
        leadingCount += 1
      }
      children = children.slice(leadingCount)
      children.first() = rest
      let rest = _sequence-func(children)
      return (rest, remove)
    } else if body.func() == h {
      return (none, body)
    }
  }
  return (body, none)
}

#let _remove-trailing-h(body) = {
  if type(body) == content {
    if body.func() == math.equation {
      return _remove-trailing-h(body.body)
    } else if body.func() == _sequence-func {
      let children = body.children
      if children.len() == 0 {
        return (none, none)
      }
      let rest
      let remove
      let trailingCount = 0
      for c in children.rev() {
        if c == [ ] {
          trailingCount += 1
          continue
        }
        let (crest, cremove) = _remove-trailing-h(c)
        rest = crest
        remove += cremove
        if rest != none {
          break
        }
        trailingCount += 1
      }
      children = children.slice(0, children.len() - trailingCount)
      children.last() = rest
      let rest = _sequence-func(children)
      return (rest, remove)
    } else if body.func() == h {
      return (none, body)
    }
  }
  return (body, none)
}

#let _label-each-child(body, label) = {
  if type(body) == content {
    if body.func() == math.equation {
      let body = _label-each-child(body.body, label)
      return body
    } else if body.func() == _sequence-func {
      // If `content` is the sequence of contents,
      // then put `label` on each child.
      let children = body.children.map(c => {
        _label-each-child(c, label)
      })
      return body.func()(children)
    } else if body == [ ] or body.func() in (_align-point-func, h, v) or str(repr(body.func())) == "context" {
      // Do not put `label` on layout contents such as [ ], align-point(),
      // h(), v(), or context{}, in order to avoid broken layout.
      return body
    }
  }
  return math.attach(math.limits(body), t: pad([#none#label], -1em), b: pad([#none#label], -1em))
}


/// Marks content within a math block with a custom underlay or overlay.
///
/// This function measures the position and size of the marked content,
/// applies a custom underlay or overlay, and generates metadata associated with a given tag.
/// The metadata includes the content's position (`x`, `y`), dimensions (`width`, `height`),
/// and the color used for the marking. This metadata can be later used for annotations.
///
/// Use this function as a foundation for defining custom marking functions.
///
/// *Example:*
/// ```example
/// #let mymark(body, tag: none) = {
///   let overlay(width, height, color) = {
///     rect(width: width, height: height, stroke: color)
///   }
///   return core-mark(body, tag: tag, color: red, overlay: overlay, mark-outset: (y: .1em))
/// }
///
/// $ mymark(x, tag: #<e>) $
/// #context {
///   set text(0.8em)
///   let info = query(<e>).last()
///   raw(repr(info.value), lang: "typc")
/// }
/// ```
///
/// -> content
#let core-mark(
  /// The content to be marked within a math block. -> content
  body,
  /// An optional tag to associate with the metadata.
  /// This tag can be used to query the marked element.
  /// -> none | label
  tag: none,
  /// The color used for marking underlay/overlay and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
  /// -> auto | color
  color: auto,
  /// An optional function to create a custom underlay.
  /// This function receives the marked content's width and height (including outset)
  /// and marking color, and should return content to be placed *under* the marked content.
  /// The signature is `underlay(width, height, color)`.
  /// -> none | function
  underlay: none,
  /// An optional function to create a custom overlay.
  /// This function receives the marked content's width and height (including outset)
  /// and marking color, and should return content to be placed *over* the marked content.
  /// The signature is `overlay(width, height, color)`.
  /// -> none | function
  overlay: none,
  /// How much to expand the marking box size (used for underlay/overlay) without affecting the layout.
  /// This can be specified as a single `length` value, which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  mark-outset: (:),
  /// How much to pad the anchor boundary (used for annotations) relative to the marking box.
  /// This can be specified as a single `length` value, which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  anchor-inset: (:),
  /// Whether to render visual markers for debugging purposes.
  /// -> bool
  debug: false,
) = {
  // Extract leading/trailing horizontal spaces from body.
  let (body, leading-h) = _remove-leading-h(body)
  let (body, trailing-h) = _remove-trailing-h(body)
  leading-h

  context {
    let y-lab = label("_mannot-mark-y")
    let end-lab = label("_mannot-mark-end")
    let dy-lab = label("_mannot-mark-dy")
    let data-lab = if type(tag) == label {
      tag
    } else {
      label("_mannot-mark-data")
    }

    let color = color
    if color == auto {
      color = text.fill
    }

    let begin-loc = here()

    // Place `underlay(width, height, color)` under the `body`.
    if underlay != none {
      // sym.wj
      context {
        let elems = query(selector(data-lab).after(begin-loc))
        if elems.len() > 0 {
          let data
          for e in elems {
            data = e.value
            // Find the corresponding metadata if nesting.
            if data.begin-loc == begin-loc {
              break
            }
          }

          let hpos = here().position()
          let bounds = data.mark-bounds
          let dx = bounds.x - hpos.x
          let dy = bounds.y - hpos.y
          let width = bounds.width
          let height = bounds.height
          let color = data.color

          place(
            dx: dx,
            dy: dy,
            float: false,
            left + top,
            underlay(width, height, color),
          )
        }
      }
    }

    // Put the labeled body for measuring its position and size.
    let labeled-body = _label-each-child(body, y-lab)
    labeled-body
    // sym.wj
    math.attach(
      math.limits([#none#end-lab]),
      t: pad(-1em, [#none#dy-lab]),
      b: pad(-1em, [#none#dy-lab]),
    )
    place([#none#dy-lab])

    // Measure the position and size, expose metadata and place the overlay.
    context {
      let end-loc = here()

      // Debug
      if debug {
        let hpos = here().position()
        let dx = begin-loc.position().x - hpos.x
        let dy = begin-loc.position().y - hpos.y
        place(circle(radius: .5pt, stroke: none, fill: red), dx: dx, dy: dy)
        let dx = end-loc.position().x - hpos.x
        let dy = end-loc.position().y - hpos.y
        place(circle(radius: .5pt, stroke: none, fill: orange), dx: dx, dy: dy)
        for pos in query(selector(y-lab).after(begin-loc).before(end-loc)).map(e => e.location().position()) {
          let dx = pos.x - hpos.x
          let dy = pos.y - hpos.y
          place(circle(radius: .5pt, stroke: none, fill: green), dx: dx, dy: dy)
        }
        for pos in query(selector(end-lab).after(begin-loc).before(end-loc)).map(e => e.location().position()) {
          let dx = pos.x - hpos.x
          let dy = pos.y - hpos.y
          place(circle(radius: .5pt, stroke: none, fill: blue), dx: dx, dy: dy)
        }
        for pos in query(selector(dy-lab).after(begin-loc).before(end-loc)).map(e => e.location().position()) {
          let dx = pos.x - hpos.x
          let dy = pos.y - hpos.y
          place(circle(radius: .5pt, stroke: none, fill: olive), dx: dx, dy: dy)
        }
      }

      let y-array = query(selector(y-lab).after(begin-loc).before(end-loc)).map(e => e.location().position().y)
      let min-y = calc.min(..y-array)
      let max-y = calc.max(..y-array)

      let end-pos = query(selector(end-lab).after(begin-loc).before(end-loc)).last().location().position()
      let dy-array = query(selector(dy-lab).after(begin-loc).before(end-loc)).map(e => e.location().position().y)
      let top-dy = end-pos.y - dy-array.at(-3)
      let bottom-dy = end-pos.y - dy-array.at(-2)
      let place-dy = end-pos.y - dy-array.at(-1)
      let top-y = min-y + top-dy + place-dy
      let bottom-y = max-y + bottom-dy + place-dy

      let left-x = begin-loc.position().x
      let right-x = end-pos.x

      let mark-outset = coerce-outset(mark-outset)
      let mark-bounds = (
        x: left-x - mark-outset.left,
        y: top-y - mark-outset.top,
        width: right-x - left-x + mark-outset.left + mark-outset.right,
        height: bottom-y - top-y + mark-outset.top + mark-outset.bottom,
      )

      let anchor-inset = anchor-inset
      // Place `overlay(width, height, color)` over the `body`.
      if overlay != none {
        let hpos = here().position()
        let overlay = overlay(mark-bounds.width, mark-bounds.height, color)
        if type(overlay) == array {
          anchor-inset = overlay.at(1)
          overlay = overlay.at(0)
        }
        place(
          dx: mark-bounds.x - hpos.x,
          dy: mark-bounds.y - hpos.y,
          float: false,
          left + top,
          overlay,
        )
      }

      anchor-inset = coerce-outset(anchor-inset)
      let anchor-bounds = (
        x: mark-bounds.x - anchor-inset.left,
        y: mark-bounds.y - anchor-inset.top,
        width: mark-bounds.width + anchor-inset.left + anchor-inset.right,
        height: mark-bounds.height + anchor-inset.top + anchor-inset.bottom,
      )

      // Expose the metadata.
      let data = (
        body: body,
        tag: tag,
        color: color,
        mark-bounds: mark-bounds,
        anchor-bounds: anchor-bounds,
        begin-loc: begin-loc,
      )
      // sym.wj
      [#metadata(data)#data-lab]
    }
  }

  // sym.wj
  trailing-h
}


#let _coerce-args(args, body, tag, color) = {
  if args.named().len() > 0 {
    panic("unexpected named argument: " + args.named().keys().first())
  }
  let posargs = (body, ..args.pos())
  body = none
  for arg in posargs {
    if tag == none and type(arg) == label {
      tag = arg
    } else if color == auto and type(arg) == std.color {
      color = arg
    } else if body == none {
      body = arg
    } else {
      panic("unexpected positional argument: `" + str(repr(arg)) + "`")
    }
  }
  if body == none {
    panic("missing argument: body")
  }
  return (body, tag, color)
}


/// Marks an annotation target within a math block.
///
/// If you mark content with a tag, you can annotate it using the `annot` function.
///
/// If the `color` argument is provided, it will change the color of the marked text.
///
/// *Basic Usage*
/// ```example
/// $ mark(x, #red) $
/// // Equivalent to: $mark(x, color: #red)$
/// ```
/// *Colors and Tags*
/// ```example
/// $
///   mark(x, #olive, #<1>)
///   // Or with named arguments:
///   mark(+ 1/2, color: #maroon, tag: #<2>)
///   // The `<1>`, `<2>` tags can be used to annotate this mark later.
/// $
/// ```
///
/// -> content
#let mark(
  /// The content to be marked within a math block. -> content
  body,
  /// An optional tag used to identify the marked content for later annotations.
  /// The argument name `tag` can be omitted.
  /// -> none | label
  tag: none,
  /// An optional color for the text and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
  /// The argument name `color` can be omitted.
  /// -> auto | color
  color: auto,
  /// How much to expand the marking box size without affecting the layout.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  outset: (y: .1em),
  ..args,
) = {
  (body, tag, color) = _coerce-args(args, body, tag, color)

  if color != auto {
    return {
      set text(fill: color)
      core-mark(body, tag: tag, color: color, mark-outset: outset)
    }
  } else {
    return {
      core-mark(body, tag: tag, color: color, mark-outset: outset)
    }
  }
}


/// Marks and highlights content within a math block.
///
/// By marking content with a tag, you can later annotate it using the `annot` function.
///
/// *Basic Usage*
/// ```example
/// $ markhl(x) $
/// ```
/// *Colors and Tags*
/// ```example
/// $
///   markhl(x, #blue, #<1>)
///   // Or with named arguments:
///   markhl(- 1/2, color: #green, tag: #<2>)
///   // The tags `<1>` and `<2>` can be used to annotate this mark later.
/// $
/// ```
/// *Custom Styling*
/// ```example
/// $
///   markhl(sum n, stroke: #(2pt + orange), radius: #10%, outset: #.3em)
/// $
/// ```
///
/// -> content
#let markhl(
  /// The content to be highlighted within a math block. -> content
  body,
  /// An optional tag used to identify the marked content for later annotations.
  /// The argument name `tag` can be omitted.
  /// -> none | label
  tag: none,
  /// The color used for the highlight and later annotations.
  /// If both `color` and `fill` are set to `auto`, `color` defaults to `orange`.
  /// Otherwise, if only `color` is `auto`, it defaults to the text fill color.
  /// The argument name `color` can be omitted.
  /// -> auto | color
  color: auto,
  /// How to fill the highlight rectangle.
  /// If set to `auto`, `fill` will be set to `color.transparentize(60%)`.
  /// -> auto | none | color | gradient | pattern
  fill: auto,
  /// How to stroke the highlight rectangle.
  /// If its `paint` is set to `auto`, it will be set to the `color`.
  /// If its `thickness` is set to `auto`, it defaults to `.048em`.
  /// -> none | auto | length | color | gradient | stroke | pattern | dictionary
  stroke: none,
  /// How much to round the highlight rectangle's corner.
  /// -> relative | dictionary
  radius: (:),
  /// How much to expand the highlight box size without affecting the layout.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  outset: (y: .1em),
  ..args,
) = {
  (body, tag, color) = _coerce-args(args, body, tag, color)

  if fill == auto {
    if color == auto {
      color = orange
    }
    fill = color.transparentize(60%)
  }
  if stroke != none {
    stroke = default-stroke(stroke, paint: color, thickness: .048em)
  }

  let underlay = if fill == none and stroke == none { none } else {
    (width, height, _) => {
      rect(
        width: width,
        height: height,
        fill: fill,
        stroke: stroke,
        radius: radius,
      )
    }
  }

  return core-mark(body, tag: tag, color: color, underlay: underlay, mark-outset: outset)
}


/// Marks and boxes around content within a math block.
///
/// By marking content with a tag, you can annotate it using the `annot` function.
///
/// *Basic Usage*
/// ```example
/// $ markrect(x + y) $
/// ```
/// *Colors and Tags*
/// ```example
/// $
///   markrect(x, #red, #<1>)
///   // Or with named arguments:
///   markrect(- 1/2, color: #green, tag: #<2>)
///   // The `<1>`, `<2>` tags can be used to annotate this mark later.
/// $
/// ```
/// *Custom Styling*
/// ```example
/// $
///   markrect(sum n, #red, stroke: #2pt, fill: #silver, outset: #(y: .4em))
/// $
/// ```
///
/// -> content
#let markrect(
  /// The content to be boxed around within a math block. -> content
  body,
  /// An optional tag used to identify the content for later annotations.
  /// The argument name `tag` can be omitted.
  /// -> none | label
  tag: none,
  /// The color used for the rectangle's stroke and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
  /// The argument name `color` can be omitted.
  /// -> color
  color: auto,
  /// How to fill the rectangle.
  /// -> none | color | gradient | pattern
  fill: none,
  /// How to stroke the rectangle.
  /// If its `paint` is set to `auto`, it will be set to the `color`.
  /// If its `thickness` is set to `auto`, it defaults to `.048em`.
  /// -> none | length | color | gradient | stroke | pattern | dictionary
  stroke: .048em,
  /// How much to round the highlight rectangle's corner.
  /// -> relative | dictionary
  radius: (:),
  /// How much to expand the rectangle size without affecting the layout.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  outset: (y: .1em),
  ..args,
) = {
  (body, tag, color) = _coerce-args(args, body, tag, color)

  let is-stroke-sided = (
    type(stroke) == dictionary and stroke.keys().first() in ("top", "right", "bottom", "left", "x", "y", "rest")
  )

  let anchor-inset = (:)
  if stroke != none {
    if is-stroke-sided {
      for (key, value) in stroke {
        let s = default-stroke(value, thickness: .048em)
        anchor-inset.insert(key, s.thickness / 2)
      }
    } else {
      let s = default-stroke(stroke, thickness: .048em)
      anchor-inset = s.thickness / 2
    }
  }

  let underlay = if fill == none and stroke == none { none } else {
    (width, height, color) => {
      let stroke = stroke
      if stroke != none {
        if is-stroke-sided {
          for (key, value) in stroke {
            let value = default-stroke(value, paint: color, thickness: .048em)
            stroke.insert(key, value)
          }
        } else {
          stroke = default-stroke(stroke, paint: color, thickness: .048em)
        }
      }
      return rect(
        width: width,
        height: height,
        fill: fill,
        stroke: stroke,
        radius: radius,
      )
    }
  }

  return core-mark(body, tag: tag, color: color, underlay: underlay, mark-outset: outset, anchor-inset: anchor-inset)
}


/// Marks and underlines content within a math block.
///
/// By marking content with a tag, you can annotate it using the `annot` function.
///
/// *Basic Usage*
/// ```example
/// $ markul(x + y) $
/// ```
/// *Colors and Tags*
/// ```example
/// $
///   markul(x, #red, #<1>)
///   // Or with named arguments:
///   markul(- 1/2, color: #blue, tag: #<2>)
///   // The `<1>`, `<2>` tags can be used to annotate this mark later.
/// $
/// ```
/// *Custom Styling*
/// ```example
/// $
///   markul(sum n, #red, stroke: #(thickness: 2pt, dash: "dashed"), outset: #(x: .2em, y: .4em))
/// $
/// ```
///
/// -> content
#let markul(
  /// The content to be underlined within a math block. -> content
  body,
  /// An optional tag used to identify the content for later annotations.
  /// The argument name `tag` can be omitted.
  /// -> none | label
  tag: none,
  /// The color used for the underline and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
  /// The argument name `color` can be omitted.
  /// -> auto | color
  color: auto,
  /// How to stroke the underline.
  /// If its `paint` is set to `auto`, it will be set to the `color`.
  /// If its `thickness` is set to `auto`, it defaults to `.048em`.
  /// -> none | length | color | gradient | stroke | pattern | dictionary
  stroke: .048em,
  /// How much to expand the marking box size without affecting the layout.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  outset: (top: .1em, bottom: .144em),
  ..args,
) = {
  (body, tag, color) = _coerce-args(args, body, tag, color)

  let anchor-inset = (:)
  if stroke != none {
    let s = default-stroke(stroke, thickness: .048em)
    anchor-inset.insert("bottom", s.thickness / 2)
  }

  let overlay = if stroke == none { none } else {
    (width, height, color) => {
      let stroke = default-stroke(stroke, paint: color, thickness: .048em)
      return line(start: (0pt, height), end: (width, height), stroke: stroke)
    }
  }

  return core-mark(body, tag: tag, color: color, overlay: overlay, mark-outset: outset, anchor-inset: anchor-inset)
}


/// Marks content within a math block and draws a horizontal wavy line under it.
///
/// By marking content with a tag, you can annotate it using the `annot` function.
///
/// *Basic Usage*
/// ```example
/// $ markuw(x + y) $
/// ```
/// *Colors and Tags*
/// ```example
/// $
///   markuw(x, #red, #<1>)
///   // Or with named arguments:
///   markuw(- 1/2, color: #blue, tag: #<2>)
///   // The `<1>`, `<2>` tags can be used to annotate this mark later.
/// $
/// ```
/// *Custom Styling*
/// ```example
/// $
///   markuw(x + y, #red, stroke: #2pt, amp: #.2em, wavelen: #.6em)
/// $
/// ```
///
/// -> content
#let markuw(
  /// The content above the wavy line. -> content
  body,
  /// An optional tag used to identify the content for later annotations.
  /// The argument name `tag` can be omitted.
  /// -> none | label
  tag: none,
  /// The color used for the wavy line and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
  /// The argument name `color` can be omitted.
  /// -> auto | color
  color: auto,
  /// How to stroke the wavy line.
  /// If its `paint` is set to `auto`, it will be set to the `color`.
  /// If its `thickness` is set to `auto`, it defaults to `.048em`.
  /// -> none | length | color | gradient | stroke | pattern | dictionary
  stroke: .048em,
  /// The amplitude of the wavy line.
  amp: .04em,
  /// The wavelength of the wavy line.
  wavelen: .36em,
  /// How much to expand the marking box size without affecting the layout.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  outset: (top: .1em, bottom: .144em),
  ..args,
) = {
  (body, tag, color) = _coerce-args(args, body, tag, color)

  let anchor-inset = (:)
  if stroke != none {
    let s = default-stroke(stroke, thickness: .048em)
    anchor-inset.insert("bottom", amp * 2 + s.thickness / 2)
  }

  let overlay = if stroke == none { none } else {
    (width, height, color) => {
      let stroke = default-stroke(stroke, paint: color, thickness: .048em)

      return box(
        width: width,
        height: height + amp * 2 + stroke.thickness,
        clip: true,
        curve(
          stroke: stroke,
          curve.move((-wavelen / 4, height + amp)),
          ..for i in range(int(width / wavelen.to-absolute()) + 2) {
            (
              // Amplitude is half of the control point height.
              curve.quad((wavelen / 4, amp * 2), (wavelen / 2, 0pt), relative: true),
              curve.quad((wavelen / 4, -amp * 2), (wavelen / 2, 0pt), relative: true),
            )
          },
        ),
      )
    }
  }

  return core-mark(body, tag: tag, color: color, overlay: overlay, mark-outset: outset, anchor-inset: anchor-inset)
}


/// Marks content within a math block and draws a bottom bracket under it.
///
/// By marking content with a tag, you can annotate it using the `annot` function.
///
/// *Basic Usage*
/// ```example
/// $ markub(x + y) $
/// ```
/// *Colors and Tags*
/// ```example
/// $
///   markub(x, #red, #<1>)
///   // Or with named arguments:
///   markub(- 1/2, color: #blue, tag: #<2>)
///   // The `<1>`, `<2>` tags can be used to annotate this mark later.
/// $
/// ```
/// *Custom Brackets*
/// ```example
/// $
///   markub(1 + 2, bracket: brace.b)
///   + markub(3 + 4, bracket: paren.b)
///   + markub(5 + 6, bracket: shell.b)
/// $
/// ```
///
/// -> content
#let markub(
  /// The content above the bracket. -> content
  body,
  /// An optional tag used to identify the content for later annotations.
  /// The argument name `tag` can be omitted.
  /// -> none | label
  tag: none,
  /// The color used for the bracket and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
  /// The argument name `color` can be omitted.
  /// -> auto | color
  color: auto,
  /// How much to expand the marking box size without affecting the layout.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  outset: (top: .1em, bottom: .144em),
  /// The bracket symbol to be drawn under the marked content.
  /// One of `bracket.b` (default), `brace.b`, `paren.b`, or `shell.b`.
  /// -> symbol
  bracket: sym.bracket.b,
  ..args,
) = {
  (body, tag, color) = _coerce-args(args, body, tag, color)

  context {
    let overlay = (width, height, color) => {
      let ub = math.equation(math.stretch(bracket, size: width), block: true)
      let size = measure(ub)
      let ub = text(fill: color, box(width: size.width, ub))
      let anchor-inset = (bottom: size.height, x: (size.width - width) / 2)
      return (
        place(ub, left + top, dx: width / 2 - size.width / 2, dy: height, float: false),
        anchor-inset,
      )
    }

    return core-mark(body, tag: tag, color: color, overlay: overlay, mark-outset: outset)
  }
}
