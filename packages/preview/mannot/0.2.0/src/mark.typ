#import "util.typ": copy-stroke

#let _mark-cnt = counter("_mannot-mark-cnt")

#let _sequence-func = (math.text("x") + math.text("y")).func()
#let _align-point-func = $&$.body.func()

#let _remove-leading-h(body) = {
  if type(body) == content {
    if body.func() == _sequence-func {
      let children = body.children
      if children.len() == 0 {
        return (none, none)
      }
      let rest
      let remove
      let leadingCount = 0
      for c in children {
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
    if body.func() == _sequence-func {
      let children = body.children
      if children.len() == 0 {
        return (none, none)
      }
      let rest
      let remove
      let trailingCount = 0
      for c in children.rev() {
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
      let children = body
        .children
        .filter(c => c != [ ])
        .map(c => {
          _label-each-child(c, label)
        })
      return body.func()(children)
    } else if (body.func() == _align-point-func or body.func() == h or body.func() == v) {
      // Do not put `label` on layout contents such as align-point(),
      // h(), or v(), in order to avoid broken layout.
      return body
    }
  }
  return math.attach(math.limits(body), t: pad([#none#label], -1em))
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
/// $ mymark(x, tag: #<e>) $
///
/// #context {
///   let info = query(<e>).last()
///   repr(info.value)
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
  /// The math size style of the marked content.
  /// Possible values are `"display"`, `"inline"`, `"script"`, and `"sscript"`.
  /// This is used for measuring the content's height.
  /// If set to `auto`, the style is determined automatically based on its width.
  /// -> auto | string
  sizestyle: auto,
) = {
  // Extract leading/trailing horizontal spaces from body.
  let (body, leading-h) = _remove-leading-h(body)
  let (body, trailing-h) = _remove-trailing-h(body)
  leading-h

  _mark-cnt.step()

  context {
    set math.equation(numbering: none)

    let cnt-get = _mark-cnt.get().first()
    let loc-lab = label("_mannot-mark-loc-" + str(cnt-get))
    let info-lab
    if type(tag) == label {
      info-lab = tag
    } else {
      info-lab = label("_mannot-mark-info-" + str(cnt-get))
    }

    // Place `underlay(width, height, color)` under the `body`.
    if underlay != none {
      sym.wj
      context {
        let infos = query(selector(info-lab).after(here()))
        if infos.len() > 0 {
          let info = infos.first().value

          let hpos = here().position()
          let dx = info.x - hpos.x
          let dy = info.y - hpos.y
          let width = info.width
          let height = info.height
          let color = info.color
          box(place(dx: dx, dy: dy, underlay(width, height, color)))
        }
      }
    }

    let start = here().position()
    let labeled-body = _label-each-child(body, loc-lab)
    labeled-body
    labeled-body = sym.wj + labeled-body + sym.wj // for measuring size

    context {
      let end = here().position()
      let elems = query(loc-lab)

      let min-y = start.y
      for e in elems {
        let pos = e.location().position()
        if min-y > pos.y {
          min-y = pos.y
        }
      }

      let size
      let attach-space = .28em
      if sizestyle == auto {
        let width = end.x - start.x
        size = measure($ body $)
        let size0 = measure($ #labeled-body $)
        if calc.abs(width - size0.width) > .001pt {
          let size1 = measure($ inline(#labeled-body) $)
          let size2 = measure($ script(#labeled-body) $)
          let size3 = measure($ sscript(#labeled-body) $)
          if calc.abs(width - size1.width) < .001pt {
            size = measure($ inline(body) $)
          } else if calc.abs(width - size2.width) < .001pt {
            size = measure($ script(body) $)
            attach-space = measure($ script(#rect(height: attach-space)) $).height
          } else if calc.abs(width - size3.width) < .001pt {
            size = measure($ sscript(body) $)
            attach-space = .25em
            attach-space = measure($ script(#rect(height: attach-space)) $).height
          }
        }
      } else if sizestyle == "display" {
        size = measure($ body $)
      } else if sizestyle == "inline" {
        size = measure($ inline(body) $)
      } else if sizestyle == "script" {
        size = measure($ script(body) $)
        attach-space = measure($ script(#rect(height: attach-space)) $).height
      } else if sizestyle == "sscript" {
        size = measure($ sscript(body) $)
        attach-space = measure($ script(#rect(height: attach-space)) $).height
      }
      min-y += attach-space.to-absolute()

      let padding = if padding == none {
        (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)
      } else if type(padding) == length {
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

      let x = start.x - padding.left
      let y = min-y - padding.top
      let width = end.x + padding.right - x
      let height = size.height + padding.top + padding.bottom

      let info = (body: body, x: x, y: y, width: width, height: height, color: color)
      [#metadata(info)#info-lab]

      // Place `overlay(width, height, color)` over the `body`.
      if overlay != none {
        let hpos = here().position()
        let dx = x - hpos.x
        let dy = y - hpos.y
        sym.wj
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
  /// The math size style of the marked content.
  /// Possible values are `"display"`, `"inline"`, `"script"` and `"sscript"`.
  /// If set to `auto`, the style is determined automatically.
  /// -> auto | string
  sizestyle: auto,
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

  return core-mark(body, tag: tag, color: color, underlay: underlay, padding: padding, sizestyle: sizestyle)
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
  /// The math size style of the marked content.
  /// Possible values are `"display"`, `"inline"`, `"script"` and `"sscript"`.
  /// If set to `auto`, the style is determined automatically.
  /// -> auto | string
  sizestyle: auto,
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

  return core-mark(body, tag: tag, color: color, underlay: underlay, padding: padding, sizestyle: sizestyle)
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
  /// The math size style of the marked content.
  /// Possible values are `"display"`, `"inline"`, `"script"` or `"sscript"`.
  /// If set to `auto`, the style is determined automatically.
  sizestyle: auto,
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

  return core-mark(body, tag: tag, color: color, overlay: overlay, padding: padding, sizestyle: sizestyle)
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
  /// The math size style of the marked content.
  /// Possible values are `"display"`, `"inline"`, `"script"` or `"sscript"`.
  /// If set to `auto`, the style is determined automatically.
  sizestyle: auto,
) = {
  body = text(fill: color, body)

  return core-mark(body, tag: tag, color: color, padding: .15em, sizestyle: sizestyle)
}
