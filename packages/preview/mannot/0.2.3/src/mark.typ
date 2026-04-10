#import "util.typ": copy-stroke


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
/// The metadata includes the original content, its position (`x`, `y`), dimensions (`width`, `height`),
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
///   return core-mark(body, tag: tag, color: red, overlay: overlay, padding: (y: .1em))
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
/// #v(11em)
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
  /// The color used for marking. -> color
  color: black,
  /// An optional function to create a custom underlay.
  /// This function receives the marked content's width and height (including padding)
  /// and marking color, and should return content to be placed *under* the marked content.
  /// The signature is `underlay(width, height, color)`.
  /// -> none | function
  underlay: none,
  /// An optional function to create a custom overlay.
  /// This function receives the marked content's width and height (including padding)
  /// and marking color, and should return content to be placed *over* the marked content.
  /// The signature is `overlay(width, height, color)`.
  /// -> none | function
  overlay: none,
  /// The spacing between the marked content and the edge of the underlay/overlay.
  /// This can be specified as a single `length` value, which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  padding: (:),
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
          set text(dir: ltr)
          box(place(dx: dx, dy: dy, underlay(width, height, color)))
        }
      }
    }

    let labeled-body = _label-each-child(body, y-lab)
    sym.wj
    labeled-body
    sym.wj
    math.attach(
      math.display(math.limits([#none#dy-lab])),
      t: pad(-1em, [#none#dy-lab]),
      b: pad(-1em, [#none#dy-lab]),
    )

    context {
      let end-loc = here()

      let y-array = query(selector(y-lab).after(begin-loc).before(end-loc)).map(e => e.location().position().y)
      let min-y = calc.min(..y-array)
      let max-y = calc.max(..y-array)

      let dy-array = query(selector(dy-lab).after(begin-loc).before(end-loc)).map(e => e.location().position().y)
      let top-dy = dy-array.at(0) - dy-array.at(1)
      let top = min-y + top-dy
      let bottom-dy = dy-array.at(0) - dy-array.at(2)
      let bottom = max-y + bottom-dy

      let padding = if padding == none {
        (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)
      } else if type(padding) == length {
        let padding = padding.to-absolute()
        (left: padding, right: padding, top: padding, bottom: padding)
      } else if type(padding) == dictionary {
        let rest = padding.at("rest", default: 0pt).to-absolute()
        let x = padding.at("x", default: rest).to-absolute()
        let left = padding.at("left", default: x).to-absolute()
        let right = padding.at("right", default: x).to-absolute()
        let y = padding.at("y", default: rest).to-absolute()
        let top = padding.at("top", default: y).to-absolute()
        let bottom = padding.at("bottom", default: y).to-absolute()
        (left: left, right: right, top: top, bottom: bottom)
      }

      let x = begin-loc.position().x - padding.left
      let y = top - padding.top
      let width = end-loc.position().x + padding.right - x
      let height = bottom - top + padding.top + padding.bottom

      let info = (body: body, x: x, y: y, width: width, height: height, color: color, begin-loc: begin-loc)
      sym.wj
      [#metadata(info)#info-lab]

      // Place `overlay(width, height, color)` over the `body`.
      if overlay != none {
        let hpos = here().position()
        let dx = x - hpos.x
        let dy = y - hpos.y
        sym.wj
        set text(dir: ltr)
        box(place(dx: dx, dy: dy, overlay(width, height, color)))
      }
    }
  }

  sym.wj
  trailing-h
}


/// Marks content within a math block with highlighting.
///
/// If you mark content with a tag, you can annotate it using the `annot` function.
///
/// *Example*
/// ```example
/// $ mark(x) $
/// ```
///
/// -> content
#let mark(
  /// The content to be highlighted within a math block. -> content
  body,
  /// An optional tag used to identify the marked content for later annotations.
  /// -> none | label
  tag: none,
  /// The color used for the highlight and later annotations.
  /// If both `color` and `fill` are set to `auto`, `color` defaults to `orange`.
  /// Otherwise, if only `color` is `auto`, it defaults to `black`.
  /// -> auto | color
  color: auto,
  /// The fill style for the highlight rectangle.
  /// If set to `auto`, `fill` will be set to `color.transparentize(60%)`.
  /// -> auto | none | color | gradient | pattern
  fill: auto,
  /// The stroke style for the highlight rectangle.
  /// -> none | auto | length | color | gradient | stroke | pattern | dictionary
  stroke: none,
  /// The corner radius of the highlight rectangle. -> relative | dictionary
  radius: (:),
  /// The spacing between the marked content and the edge of the highlight rectangle.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  padding: (y: .1em),
) = {
  if fill == auto {
    if color == auto {
      color = orange
    }
    fill = color.transparentize(60%)
  } else if color == auto {
    color = black
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

  return core-mark(body, tag: tag, color: color, underlay: underlay, padding: padding)
}


/// Marks content within a math block with a rectangle.
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
  /// The content to be marked within a math block. -> content
  body,
  /// An optional tag used to identify the content for later annotations.
  /// -> none | label
  tag: none,
  /// The color used for the rectangle stroke and later annotations.
  /// -> color
  color: black,
  /// The fill style for the rectangle.
  /// -> none | color | gradient | pattern
  fill: none,
  /// The stroke style for the rectangle.
  /// If its `paint` is set to `auto`, it will be set to the `color`.
  /// -> none | length | color | gradient | stroke | pattern | dictionary
  stroke: .05em,
  /// The corner radius of the rectangle. -> relative | dictionary
  radius: (:),
  /// The spacing between the marked content and the edge of the rectangle.
  /// This can be specified as a single `length` value which applies to all sides,
  /// or as a `dictionary` of `length` with keys `left`, `right`, `top`, `bottom`, `x`, `y`, or `rest`.
  /// -> none | length | dictionary
  padding: (y: .1em),
) = {
  if stroke != none {
    stroke = std.stroke(stroke)
    if stroke.paint == auto {
      stroke = copy-stroke(stroke, (paint: color))
    }
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

  return core-mark(body, tag: tag, color: color, underlay: underlay, padding: padding)
}


/// Marks content within a math block with an underline.
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
  /// An optional tag used to identify the underlined content for later annotations.
  /// -> none | label
  tag: none,
  /// The color used for the underline. -> color
  color: black,
  /// The stroke style for the underline.
  /// -> none | length | color | gradient | stroke | pattern | dictionary
  stroke: .05em,
  /// The spacing between the marked content and the underline.
  /// -> none | length
  padding: .15em,
) = {
  if stroke != none {
    stroke = std.stroke(stroke)
    if stroke.paint == auto {
      stroke = copy-stroke(stroke, (paint: color))
    }
  }
  if type(padding) == length {
    padding = (bottom: padding)
  }

  let overlay = if stroke == none { none } else {
    (width, height, _) => {
      line(start: (0pt, height), end: (width, height), stroke: stroke)
    }
  }

  return core-mark(body, tag: tag, color: color, overlay: overlay, padding: padding)
}


/// Marks content within a math block and changes its text color.
///
/// If you mark content with a tag, you can annotate it using the `annot` function.
///
/// *Example*
/// ```example
/// $ marktc(x + y) $
/// ```
///
/// -> content
#let marktc(
  /// The content to be underlined within a math block. -> content
  body,
  /// An optional tag used to identify the underlined content for later annotations.
  /// -> none | label
  tag: none,
  /// The color used for the underline. -> color
  color: red,
) = {
  body = text(fill: color, body)

  return core-mark(body, tag: tag, color: color, padding: .15em)
}
