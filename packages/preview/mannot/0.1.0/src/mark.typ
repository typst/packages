#let _mark-cnt = counter("_mannot-mark-cnt")

#let _sequence-func = (math.text("x") + math.text("y")).func()
#let _align-point-func = $&$.body.func()

#let _remove-leading-h(content) = {
  if content.func() == _sequence-func {
    let children = content.children
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
  } else if content.func() == h {
    return (none, content)
  } else {
    return (content, none)
  }
}

#let _remove-trailing-h(content) = {
  if content.func() == _sequence-func {
    let children = content.children
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
  } else if content.func() == h {
    return (none, content)
  } else {
    return (content, none)
  }
}

#let _label-each-child(content, label) = {
  if content.func() == math.equation {
    let body = _label-each-child(content.body, label)
    return body
  } else if content.func() == _sequence-func {
    // If `content` is the sequence of contents,
    // then put `label` on each child.
    let children = content.children.filter(c => c != [ ]).map(c => {
      _label-each-child(c, label)
    })
    return content.func()(children)
  } else if (content.func() == _align-point-func or content.func() == h or content.func() == v) {
    // Do not put `label` on layout contents such as align-point(),
    // h(), or v(), in order to avoid broken layout.
    return content
  } else {
    // return [#content#label]
    return math.attach(math.limits(content), t: [#none#label])
  }
}

/// Marks a part of a math block with a custom overlay.
///
/// This function measures the position and size of the marked content,
/// places an overlay on it, and exposes metadata labeled with a tag.
/// This metadata includes the original content, its position (x, y), size (width, height),
/// and the color used for the overlay.
/// Its purpose is to create custom marking functions.
///
/// *Example*
/// #example(```
///let mymark(body, tag: none) = {
///  let overlay(width, height, color) = {
///    rect(width: width, height: height, stroke: color)
///  }
///  return core-mark(body, tag: tag, color: red, overlay: overlay, padding: (y: .1em))
///}
///
///$ mymark(x, tag: #<e>) $
///
///context {
///  let info = query(<e>).last()
///  repr(info.value)
///}
///```)
///
/// - body (content): The content to be marked within a math block.
/// - tag (none, label): An optional tag associated with the metadata.
/// - color (color): The color for the overlay and annotations put to this.
/// - overlay (none, function): An optional function to create a custom overlay.
///     The function takes `width`, `height`, and `color` as arguments,
///     where `width` and `height` represent the size of the marked content including padding,
///     and `color` is the same color passed to core-mark.
/// - padding (none, length, dictionary): The space between the marked content and the border of the overlay.
///     You can specify `left`, `right`, `top`, `bottom`, `x`, `y`, or a `rest` value.
/// - ctx (auto, string): The context of the marked content.
///     Possible values are `"inline"`, `"script"` or `"sscript"`.
///     If set to `auto`, it is automatically chosen.
/// -> content
#let core-mark(body, tag: none, color: black, overlay: none, padding: (:), ctx: auto) = {
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

    let start = here().position()
    let labeled-body = _label-each-child(body, loc-lab)
    labeled-body

    context {
      let end = here().position()
      let elems = query(loc-lab)

      let min-y = start.y
      for e in elems {
        let pos = e.location().position()
        let hpos = here().position()
        let dx = pos.x - hpos.x
        let dy = pos.y - hpos.y
        if min-y > pos.y {
          min-y = pos.y
        }
      }

      let size
      let attach-space = .2em
      if ctx == auto {
        size = measure($ body $)
        let width = end.x - start.x
        if calc.abs(width - size.width) > .01pt {
          let size1 = measure($ inline(#labeled-body) $)
          let size2 = measure($ script(#labeled-body) $)
          let size3 = measure($ sscript(#labeled-body) $)
          if calc.abs(width - size1.width) < .01pt {
            size = measure($ inline(body) $)
          } else if calc.abs(width - size2.width) < .01pt {
            size = measure($ script(body) $)
            attach-space = measure($ script(#rect(height: attach-space)) $).height
          } else if calc.abs(width - size3.width) < .01pt {
            size = measure($ sscript(body) $)
            attach-space = measure($ sscript(#rect(height: attach-space)) $).height
          }
        }
      } else if ctx == "inline" {
        size = measure($ inline(body) $)
      } else if ctx == "script" {
        size = measure($ script(body) $)
        attach-space = measure($ script(#rect(height: attach-space)) $).height
      } else if ctx == "sscript" {
        size = measure($ sscript(body) $)
        attach-space = measure($ script(#rect(height: attach-space)) $).height
      }
      min-y += attach-space.to-absolute()

      let padding = if type(padding) == none {
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

      // Place `overlay(width, height, color)` in front of the `body`.
      if overlay != none {
        let hpos = here().position()
        let dx = x - hpos.x
        let dy = y - hpos.y
        box(place(dx: dx, dy: dy, overlay(width, height, color)))
        // place([#dy])
        // box(place(dx: -hpos.x, dy: -hpos.y, overlay(width, height, color)))
      }
    }
  }

  trailing-h
}


/// Marks a part of a math block with highlighting.
///
/// Marked content can be annotated with `annot` function.
///
/// *Example*
/// #example(```
///$ mark(x) $
/// ```)
///
/// - body (content): The content to be highlighted within a math block.
/// - tag (none, label):  An optional tag used to identify the highlighted content for later annotation.
/// - color (auto, color): The color used for the highlight.
///     If set to `auto` and `fill` is `auto`, `color` will set be set to `orange`.
///     Otherwise, it defaults to `black`.
/// - fill (auto, none, color, gradient, pattern): The fill style for the highlight rectangle.
///     If set to `auto`, `fill` will be set to `color.transparentize(70%)`.
/// - stroke (none, auto, length, color, gradient, stroke, pattern, dictionary):
///     The stroke style for the highlight rectangle.
/// - radius (relative, dictionary): The corner radius of the highlight rectangle.
/// - padding (none, length, dictionary): he space between the highlighted content and the border of the highlight.
///     You can specify `left`, `right`, `top`, `bottom`, `x`, `y`, or a `rest` value.
/// - ctx (auto, string): The context of the marked content.
///     Possible values are `"inline"`, `"script"` or `"sscript"`.
///     If set to `auto`, it is automatically chosen.
/// -> content
#let mark(
  body,
  tag: none,
  color: auto,
  fill: auto,
  stroke: none,
  radius: (:),
  padding: (y: .1em),
  ctx: auto,
) = {
  if fill == auto {
    if color == auto {
      color = orange
    }
    fill = color.transparentize(70%)
  } else if color == auto {
    color = black
  }

  let overlay(width, height, _) = {
    if fill == none and stroke == none {
      none
    } else {
      rect(
        width: width,
        height: height,
        fill: fill,
        stroke: stroke,
        radius: radius,
      )
    }
  }

  return core-mark(body, tag: tag, color: color, overlay: overlay, padding: padding, ctx: ctx)
}


/// Setup function.
///
/// To start using mannot, you need to initialize mannot using a show rule:
///
/// ```typ
/// #show: mannot-init
/// ```
///
/// This removes unintentional spaces around marked elements within math blocks.
#let mannot-init(body) = {
  show math.equation: content => {
    if content.body.func() == _sequence-func and content.body.children.any(c => c == [ ]) {
      let children = content.body.children.filter(c => c != [ ])
      let args = content.fields()
      args.remove("body")
      return math.equation(_sequence-func(children), ..args)
    } else {
      return content
    }
  }

  body
}
