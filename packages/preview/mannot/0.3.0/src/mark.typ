#import "util.typ": default-stroke


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
        let (crest, cremove) = _remove-leading-h(c)
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
    } else if body == [ ] or body.func() == _align-point-func or body.func() == h or body.func() == v {
      // Do not put `label` on layout contents such as [ ], align-point(),
      // h(), or v(), in order to avoid broken layout.
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
///   return core-mark(body, tag: tag, color: red, overlay: overlay, outset: (y: .1em))
/// }
///
/// $
///   mymark(x, tag: #<e>)
///
///   #context {
///     let info = query(<e>).last()
///     sym.wj
///     box(place(repr(info.value), dx: -5em))
///   }
/// $
/// #v(12em)
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
  /// How much to expand the marking box size without affecting the layout.
  /// This can be specified as a single `length` value, which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  outset: (:),
) = {
  // Extract leading/trailing horizontal spaces from body.
  let (body, leading-h) = _remove-leading-h(body)
  let (body, trailing-h) = _remove-trailing-h(body)
  leading-h

  context {
    let y-lab = label("_mannot-mark-y")
    let dy-lab = label("_mannot-mark-dy")
    let info-lab = if type(tag) == label {
      tag
    } else {
      label("_mannot-mark-info")
    }

    let color = color
    if color == auto {
      color = text.fill
    }

    let begin-loc = here()

    // Place `underlay(width, height, color)` under the `body`.
    if underlay != none {
      sym.wj
      context {
        let elems = query(selector(info-lab).after(begin-loc))
        if elems.len() > 0 {
          let info
          for e in elems {
            info = e.value
            // Find the corresponding info if nesting.
            if info.begin-loc == begin-loc {
              break
            }
          }

          let hpos = here().position()
          let dx = info.x - hpos.x
          let dy = info.y - hpos.y
          let width = info.width
          let height = info.height
          let color = info.color
          box(place(dx: dx, dy: dy, float: false, left + top, underlay(width, height, color)))
        }
      }
    }

    // Put the labeled body for measuring its position and size.
    let labeled-body = _label-each-child(body, y-lab)
    sym.wj
    labeled-body
    sym.wj
    math.attach(
      math.display(math.limits([#none#dy-lab])),
      t: pad(-1em, [#none#dy-lab]),
      b: pad(-1em, [#none#dy-lab]),
    )

    // Measure the position and size, expose metadata and place the overlay.
    context {
      let end-loc = here()

      let y-array = query(selector(y-lab).after(begin-loc).before(end-loc)).map(e => e.location().position().y)
      let min-y = calc.min(..y-array)
      let max-y = calc.max(..y-array)

      let dy-array = query(selector(dy-lab).after(begin-loc).before(end-loc)).map(e => e.location().position().y)
      let top-dy = dy-array.at(0) - dy-array.at(1)
      let top-y = min-y + top-dy
      let bottom-dy = dy-array.at(0) - dy-array.at(2)
      let bottom-y = max-y + bottom-dy

      let outset = if outset == none {
        (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)
      } else if type(outset) == length {
        let outset = outset.to-absolute()
        (left: outset, right: outset, top: outset, bottom: outset)
      } else if type(outset) == dictionary {
        let rest = outset.at("rest", default: 0pt).to-absolute()
        let x = outset.at("x", default: rest).to-absolute()
        let left = outset.at("left", default: x).to-absolute()
        let right = outset.at("right", default: x).to-absolute()
        let y = outset.at("y", default: rest).to-absolute()
        let top = outset.at("top", default: y).to-absolute()
        let bottom = outset.at("bottom", default: y).to-absolute()
        (left: left, right: right, top: top, bottom: bottom)
      }

      let x = begin-loc.position().x - outset.left
      let y = top-y - outset.top
      let width = end-loc.position().x + outset.right - x
      let height = bottom-y - top-y + outset.top + outset.bottom

      // Expose the metadata.
      let info = (body: body, x: x, y: y, width: width, height: height, color: color, tag: tag, begin-loc: begin-loc)
      sym.wj
      [#metadata(info)#info-lab]

      // Place `overlay(width, height, color)` over the `body`.
      if overlay != none {
        let hpos = here().position()
        let dx = x - hpos.x
        let dy = y - hpos.y
        sym.wj
        box(place(dx: dx, dy: dy, float: false, left + top, overlay(width, height, color)))
      }
    }
  }

  sym.wj
  trailing-h
}


/// Marks an annotation target within a math block.
///
/// If you mark content with a tag, you can annotate it using the `annot` function.
///
/// If the `color` argument is provided, it will change the color of the marked text.
///
/// *Example*
/// ```example
/// $ mark(x, color: #red) $
/// ```
///
/// -> content
#let mark(
  /// The content to be marked within a math block. -> content
  body,
  /// An optional tag used to identify the marked content for later annotations.
  /// -> none | label
  tag: none,
  /// An optional color for the text and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
  /// -> auto | color
  color: auto,
  /// How much to expand the marking box size without affecting the layout.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  outset: (y: .1em),
) = {
  if color != auto {
    body = text(fill: color, body)
    return core-mark(body, tag: tag, color: color, outset: outset)
  } else {
    return context {
      let color = text.fill
      core-mark(body, tag: tag, color: color, outset: outset)
    }
  }
}


/// Marks and highlights content within a math block.
///
/// If you mark content with a tag, you can annotate it using the `annot` function.
///
/// *Example*
/// ```example
/// $ markhl(x) $
/// ```
///
/// -> content
#let markhl(
  /// The content to be highlighted within a math block. -> content
  body,
  /// An optional tag used to identify the marked content for later annotations.
  /// -> none | label
  tag: none,
  /// The color used for the highlight and later annotations.
  /// If both `color` and `fill` are set to `auto`, `color` defaults to `orange`.
  /// Otherwise, if only `color` is `auto`, it defaults to the text fill color.
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
) = {
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

  return core-mark(body, tag: tag, color: color, underlay: underlay, outset: outset)
}


/// Marks and boxes around content within a math block.
///
/// If you mark content with a tag, you can annotate it using the `annot` function.
///
/// *Example*
/// ```example
/// $ markrect(x + y) $
/// ```
///
/// -> content
#let markrect(
  /// The content to be boxed around within a math block. -> content
  body,
  /// An optional tag used to identify the content for later annotations.
  /// -> none | label
  tag: none,
  /// The color used for the rectangle's stroke and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
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
) = {
  let underlay = if fill == none and stroke == none { none } else {
    (width, height, color) => {
      let stroke = stroke
      if stroke != none {
        stroke = default-stroke(stroke, paint: color, thickness: .048em)
      }

      rect(
        width: width,
        height: height,
        fill: fill,
        stroke: stroke,
        radius: radius,
      )
    }
  }

  return core-mark(body, tag: tag, color: color, underlay: underlay, outset: outset)
}


/// Marks and underlines content within a math block.
///
/// If you mark content with a tag, you can annotate it using the `annot` function.
///
/// *Example*
/// ```example
/// $ markul(x + y) $
/// ```
///
/// -> content
#let markul(
  /// The content to be underlined within a math block. -> content
  body,
  /// An optional tag used to identify the content for later annotations.
  /// -> none | label
  tag: none,
  /// The color used for the underline and later annotations.
  /// If set to `auto`, it defaults to the text fill color.
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
) = {
  let overlay = if stroke == none { none } else {
    (width, height, color) => {
      let stroke = stroke
      if stroke != none {
        stroke = default-stroke(stroke, paint: color, thickness: .048em)
      }

      line(start: (0pt, height), end: (width, height), stroke: stroke)
    }
  }

  return core-mark(body, tag: tag, color: color, overlay: overlay, outset: outset)
}
