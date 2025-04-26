#import "args.typ": __codly-args, __codly-save, __codly-load

#let __codly-trim(body) = {
  if type(body) == str {
    return body.trim()
  }

  if body.has("children") {
    let out = ()
    let start = true
    for child in body.children {
      if start and child.has("text") and child.text.trim().len() == 0 {
        continue
      } else if start and child == [ ] {
        continue
      }

      start = false
      out.push(child)
    }

    (body.func())(out)
  } else {
    body
  }
}

#let __codly-inset(inset) = {
  if type(inset) == dictionary {
    let other = inset.at("rest", default: 0.32em)
    (
      top: inset.at("top", default: inset.at("y", default: other)),
      right: inset.at("right", default: inset.at("x", default: other)),
      bottom: inset.at("bottom", default: inset.at("y", default: other)),
      left: inset.at("left", default: inset.at("x", default: other)),
    )
  } else {
    (top: inset, right: inset, bottom: inset, left: inset)
  }
}

/// Lets you set a line number offset.
///
///  #codly-offset(offset: 25)
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
///
/// - offset (int): the offset to apply to the code block
/// 
/// -> content
#let codly-offset(offset: 0) = {
  (__codly-args.offset.update)(offset)
}

/// Lets you set a range of line numbers to highlight.
/// Similar to `codly(range: (start, end))`.
///
///  #codly-range(start: 2)
///  ```py
///  def fib(n):
///      if n <= 1:
///          return n
///      return fib(n - 1) + fib(n - 2)
///  fib(25)
///  ```
///
/// - start (int): the start of the displayed range
/// - end (none, int): the end of the displayed range, none for the rest of the block
/// 
/// -> content
#let codly-range(
  start,
  end: none,
  ..rest,
) = {
  let pos = rest.pos();
  if pos.len() > 0 {
    (__codly-args.ranges.update)(((start, end), ..pos))
  } else {
    (__codly-args.range.update)((start, end))
  }
}

/// Disables codly.
///
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
///
///  #codly-disable()
///  *Disabled:*
///  ```
///  Hello, world!
///  ```
/// 
/// -> content
#let codly-disable() = {
  (__codly-args.enabled.update)(false)
}

/// Enables codly.
///
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
///  #codly-disable()
///  *Disabled:*
///  ```
///  Hello, world!
///  ```
///
///  #codly-enable()
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
/// 
/// -> content
#let codly-enable() = {
  (__codly-args.enabled.update)(true)
}

/// Disabled codly locally.
///
/// ````
///  *Enabled:*
///  ```
///  Hello, world!
///  ```
///
///  *Disabled:*
///  #no-codly(```
///  Hello, world!
///  ```)
/// 
/// -> content
#let no-codly(body) = {
  (__codly-args.enabled.update)(false)
  body
  (__codly-args.enabled.update)(true)
}

/// Enable codly locally.
///
/// ````
///  *Disabled:*
///  #codly(enabled: false)
///  ```
///  Hello, world!
///  ```
///
///  *Enabled:*
///  #yes-codly(```
///  Hello, world!
///  ```)
/// 
/// -> content
#let yes-codly(body) = {
  (__codly-args.enabled.update)(true)
  body
  (__codly-args.enabled.update)(false)
}

/// Appends a skip to the list of skips.
///
///  #codly-skip(4, 32)
///  ```
///  Hello, world!
///  Goodbye, world!
///  ```
/// 
/// - position (int): the line at which to insert the skip
/// - length (int): the number of lines the skip is long
/// 
/// -> content
#let codly-skip(
  position,
  length,
) = {
  state("codly-skips", ()).update(skips => {
    if skips == none {
      skips = ()
    }

    skips.push((position, length))
    skips
  })
}


/// Configures codly.
/// Is used in a similar way as `set` rules. You can imagine the following:
/// ```typc
/// // This is a representation of the actual code.
/// // The actual code behave like a set rule that uses `state`.
/// let codly(
///    enabled: true,
///    offset: 0,
///    range: none,
///    languages: (:),
///    display-name: true,
///    display-icon: true,
///    default-color: rgb("#283593"),
///    radius: 0.32em,
///    inset: 0.32em,
///    fill: none,
///    zebra-fill: luma(240),
///    stroke: 1pt + luma(240),
///    lang-inset: 0.32em,
///    lang-outset: (x: 0.32em, y: 0pt),
///    lang-radius: 0.32em,
///    lang-stroke: (lang) => lang.color + 0.5pt,
///    lang-fill: (lang) => lang.color.lighten(80%),
///    lang-format: auto,
///    number-format: (number) => [ #number ],
///    number-align: left + horizon,
///    number-placement: false,
///    smart-indent: false,
///    annotations: none,
///    annotation-format: numbering.with("(1)"),
///    highlights: none,
///    highlight-radius: 0.32em,
///    highlight-fill: (color) => color.lighten(80%),
///    highlight-stroke: (color) => 0.5pt + color,
///    highlight-inset: 0.32em,
///    highlight-outset: 0em,
///    highlight-clip: true,
///    reference-by: line,
///    reference-sep: "-",
///    reference-number-format: numbering.with("1"),
///    header: none,
///    header-repeat: false,
///    header-transform: (x) => x,
///    header-cell-args: (),
///    footer: none,
///    footer-repeat: false,
///    footer-transform: (x) => x,
///    footer-cell-args: (),
///    breakable: false,
/// ) = {}
/// ```
///
/// Each argument is explained in the docs: https://github.com/Dherse/codly/blob/main/docs.pdf
#let __codly-inner(
  ..args,
) = {
  let pos = args.named()

  if args.pos().len() > 0 {
    panic("codly: no positional arguments are allowed")
  }

  for (key, arg) in __codly-args {
    if key in pos {
      // Remove the argument from the list.
      let i = pos.remove(key)

      // Update the state.
      (arg.update)(i)
    }
  }

  if pos.len() > 0 {
    panic("codly: unknown arguments: " + pos.keys().join(", "))
  }
}

/// Resets the codly state to its default values.
/// This is useful if you want to reset the state of codly to its default values.
///
/// Note that this is mostly intended for testing purposes.
///
/// -> content
#let codly-reset() = {
  for (_, arg) in __codly-args {
    (arg.reset)()
  }
}

#let get-len(child) = {
  if child.has("label") and child.label == <codly-highlight> {
    0
  } else if child.has("text") {
    child.text.len()
  } else if child.has("children") {
    child.children.map(get-len).sum()
  } else if child.has("child") {
    get-len(child.child)
  } else if child.has("body") {
    get-len(child.body)
  } else {
    0
  }
}

#let ws_regex = regex("\s")
#let indent-regex = regex("^\\s*")
#let get-flattened-body(elem) = {
  if elem.has("label") and elem.label == <codly-highlight> {
    return (elem,)
  }

  if elem.has("children") {
    elem.children.map(get-flattened-body).flatten()
  } else if elem.has("child") and elem.has("styles") {
    get-flattened-body(elem.child)
      .map(x => (elem.func())(x, elem.styles))
      .flatten()
  } else if elem.has("text") {
    // Separate the whitespaces at the start of text
    let out = ()
    let ws = none
    for cluster in elem.text.clusters() {
      let m = cluster.match(ws_regex)
      if m != none and ws != none {
        ws += cluster
      } else if m != none and ws == none {
        ws = cluster
      } else if ws != none {
        out.push(text(ws))
        ws = none
        out.push(text(cluster))
      } else {
        out.push(text(cluster))
      }
    }

    if ws != none {
      out.push(text(ws))
    }
    out
  } else {
    (elem,)
  }
}

#let codly-line(
  highlight-stroke,
  highlight-fill,
  highlight-radius,
  highlight-inset,
  highlight-baseline,
  highlight-outset,
  highlight-clip,
  default-color,
  highlights,
  smart-indent,
  reference-by,
  reference-sep,
  reference-number-format,
  it,
  block-label: none
) = {
  let highlighted = it.body
  let highlights = {
    if highlights == none {
      ()
    } else {
      highlights
        .filter(x => x.line == it.number)
        .map(x => {
          if not "start" in x or x.start == none {
            x.insert("start", 0)
          }

          if not "end" in x or x.end == none {
            x.insert("end", 999999999)
          }

          if not "fill" in x {
            x.insert("fill", default-color)
          }
          x
        })
        .sorted(key: x => x.start)
    }
  }

  // Smart indentation code.
  let body = if it.body.has("children") {
    it.body.children
  } else {
    (body, )
  }

  let width = none
  if smart-indent {
    // Check the indentation of the line by taking l,
    // and checking for the first element in the sequence.
    let first = for child in body {
      if child.has("children") {
        for c in child.children {
          if c.has("text") {
            c
            break
          }
        }
      } else if child.has("child") {
        if child.child.has("text") {
          child.child
          break
        }
      } else if child.has("body") {
        if child.body.has("text") {
          child.body
          break
        }
      } else if child.has("text") {
        child
        break
      }
    }

    if first != none and first.has("text") {
      let match = first.text.match(indent-regex)

      // Ensure there is a match and it starts at the beginning of the line.
      if match != none and match.start == 0 {
        // Calculate the indentation.
        let indent = match.end - match.start

        // Then measure the necessary indent.
        let indent = first.text.slice(match.start, match.end)
        width = measure([#indent]).width
      }
    }
  }

  // If there are no highlights, return the line as is.
  if highlights.len() == 0 {
    if width != none {
      // We add the indentation to the line.
      highlighted = {
        set par(hanging-indent: width)
        highlighted
      }
    }

    let l = raw.line(it.number, it.count, it.text, highlighted)

    // Build a label if the code block has one.
    if block-label != none {
      let lab = label(str(block-label) + ":" + str(it.number))

      return [#figure(
        kind: "codly-line",
        supplement: none,
        caption: none,
        outlined: false,
        numbering: (..) => {
          ref(block-label)
          reference-sep
          reference-number-format(it.number)
        },
        l
      )#lab]
    } else {
      return l
    }
  }

  // Apply highlights
  let l = it.body
  for hl in highlights {
    let fill = highlight-fill(hl.fill)
    let stroke = highlight-stroke(hl.fill)
    let tag = if "tag" in hl {
      hl.tag
    } else {
      none
    }

    let children = ()
    let collection = none
    let i = 0

    let body = get-flattened-body(highlighted)

    let len = body.len()
    for (index, child) in body.enumerate() {
      let last = index == len - 1
      if child.has("label") and child.label == <codly-highlight> {
        if collection != none {
          collection.push(child)
          continue
        } else {
          children.push(child)
          continue
        }
      }

      let len = get-len(child)

      if collection != none {
        collection.push(child)
      } else if collection == none and (
        i >= hl.start or i + len >= hl.start
      ) and (i < hl.end) {
        collection = (child,)
      } else {
        children.push(child)
      }

      let label = if "label" in hl and hl.label != none {
        assert.ne(block-label, none, message: {
          "codly: for labels on highlights to work, "
          "you must have the code block contained within a figure "
          "and that figure must have a label."
        })

        let referenced = if reference-by == "line" {
          reference-number-format(it.number)
        } else {
          assert("tag" in hl, message: "codly: tag is required for item reference")
          hl.tag
        }

        place(hide[#figure(
          kind: "codly-referencer",
          supplement: none,
          numbering: (..) => {
            ref(block-label)
            reference-sep
            __codly-trim(referenced)
          },
          []
        )#hl.label])
      } else {
        none
      }

      if collection != none and (i + len >= hl.end or last) {
        if tag == none {
          let content = box(
            radius: highlight-radius,
            clip: highlight-clip,
            fill: fill,
            stroke: stroke,
            inset: highlight-inset,
            outset: highlight-outset,
            baseline: highlight-baseline,
            collection.join() + label,
          )
          children.push(content)
        } else {
          let col = collection.join()
          let height-col = measure(col).height
          let height-tag = measure(tag).height
          let max-height = calc.max(
            height-col,
            height-tag,
          ) + 2 * highlight-inset
          let hl-box = box(
            radius: (
              top-right: 0pt,
              bottom-right: 0pt,
              rest: highlight-radius,
            ),
            height: max-height,
            clip: highlight-clip,
            fill: fill,
            stroke: stroke,
            inset: highlight-inset,
            outset: highlight-outset,
            baseline: highlight-baseline,
            collection.join(),
          )
          let tag-box = box(
            radius: (
              top-left: 0pt,
              bottom-left: 0pt,
              rest: highlight-radius,
            ),
            height: max-height,
            clip: highlight-clip,
            fill: fill,
            stroke: stroke,
            inset: highlight-inset,
            outset: highlight-outset,
            baseline: highlight-baseline,
            tag + label,
          )

          children.push([#hl-box#h(
            0pt,
            weak: true,
          )#tag-box<codly-highlight>])
        }
        collection = none
      }

      i += len
    }

    highlighted = children.join()
  }

  if width != none {
    // We add the indentation to the line.
    highlighted = {
      set par(hanging-indent: width)
      highlighted
    }
  }

  let l = raw.line(it.number, it.count, it.text, highlighted)

  // Build a label if the code block has one.
  if block-label != none {
    let lab = label(str(block-label) + ":" + str(it.number))
    return [#figure(
      kind: "codly-line",
      supplement: none,
      numbering: (..) => {
        ref(block-label)
        reference-sep
        reference-number-format(it.number)
      },
      l
    )#lab]
  } else {
    return l
  }
}

#let in_range(ranges, line) = {
  if ranges == none or ranges.len() == 0 {
    return true
  }

  // Return true if the line is contained in any of the ranges.
  for r in ranges {
    if r.at(0) == none {
      if line <= r.at(1) {
        return true
      }
    } else if r.at(1) == none {
      if r.at(0) <= line {
        return true
      }
    } else if r.at(0) <= line and line <= r.at(1) {
      return true
    }
  }

  return false
}

#let __codly-raw(
  it,
  block-label: none,
  alias: none,
  extra: (:),
) = context {
  let enabled = (__codly-args.enabled.type_check)(if "enabled" in extra {
    extra.enabled
  } else {
    state("codly-enabled", __codly-args.enabled.default).get()
  })

  if not enabled {
    return it
  }

  if type(it) != content or it.func() != raw {
    panic("codly-raw: body must be a raw content")
  }

  // Optimization: skip alises checking if `alias` already set
  let aliases = if alias == none {
    (__codly-args.aliases.type_check)(if "aliases" in extra {
      extra.aliases
    } else {
      state("codly-aliases", __codly-args.aliases.default).get()
    })
  } else {
    (:)
  }

  let alias = if it.lang != none and it.lang in aliases {
    let real = aliases.at(it.lang)
    return {
      show raw.where(block: true): __codly-raw.with(alias: it.lang, extra: extra, block-label: block-label)

      raw(
        it.text,
        block: true,
        align: it.align,
        lang: real,
        theme: it.theme,
        syntaxes: it.syntaxes,
        tab-size: it.tab-size,
      )
    }
  } else if alias == none {
    it.lang
  } else {
    alias
  }

  let highlight-inset = (
    __codly-args.highlight-inset.type_check
  )(if "highlight-inset" in extra {
    extra.highlight-inset
  } else {
    state("highlight-inset", __codly-args.highlight-inset.default).get()
  });

  show raw.line.where(label: <codly-highlighted>): codly-line.with(
    (__codly-args.highlight-stroke.type_check)(if "highlight-stroke" in extra {
      extra.highlight-stroke
    } else {
      state("codly-highlight-stroke", __codly-args.highlight-stroke.default).get()
    }),
    (__codly-args.highlight-fill.type_check)(if "highlight-fill" in extra {
      extra.highlight-fill
    } else {
      state("codly-highlight-fill", __codly-args.highlight-fill.default).get()
    }),
    (__codly-args.highlight-radius.type_check)(if "highlight-radius" in extra {
      extra.highlight-radius
    } else {
      state("codly-highlight-radius", __codly-args.highlight-radius.default).get()
    }),
    highlight-inset,
    __codly-inset(highlight-inset).bottom,
    (__codly-args.highlight-outset.type_check)(if "highlight-outset" in extra {
      extra.highlight-outset
    } else {
      state("codly-highlight-outset", __codly-args.highlight-outset.default).get()
    }),
    (__codly-args.highlight-clip.type_check)(if "highlight-clip" in extra {
      extra.highlight-clip
    } else {
      state("codly-highlight-clip", __codly-args.highlight-clip.default).get()
    }),
    (__codly-args.default-color.type_check)(if "default-color" in extra {
      extra.default-color
    } else {
      state("codly-default-color", __codly-args.default-color.default).get()
    }),
    (__codly-args.highlights.type_check)(if "highlights" in extra {
      extra.highlights
    } else {
      state("codly-highlights", __codly-args.highlights.default).get()
    }),
    (__codly-args.smart-indent.type_check)(if "smart-indent" in extra {
      extra.smart-indent
    } else {
      state("codly-smart-indent", __codly-args.smart-indent.default).get()
    }),
    (__codly-args.reference-by.type_check)(if "reference-by" in extra {
      extra.reference-by
    } else {
      state("codly-reference-by", __codly-args.reference-by.default).get()
    }),
    (__codly-args.reference-sep.type_check)(if "reference-sep" in extra {
      extra.reference-sep
    } else {
      state("codly-reference-sep", __codly-args.reference-sep.default).get()
    }),
    (__codly-args.reference-number-format.type_check)(if "reference-number-format" in extra {
      extra.reference-number-format
    } else {
      state("codly-reference-number-format", __codly-args.reference-number-format.default).get()
    }),
    block-label: block-label,
  )

  show figure.where(kind: "codly-line"): it => {
    set align(left + horizon)
    it.body
  }

  show figure.where(kind: "__codly-raw-line"): it => {
    set align(left + horizon)
    it.body
  }

  show figure.where(kind: "__codly-end-block"): it => none

  set par(justify: false, first-line-indent: 0pt)

  let range = (__codly-args.range.type_check)(if "range" in extra {
    extra.range
  } else {
    state("codly-range", __codly-args.range.default).get()
  })

  let ranges = (__codly-args.ranges.type_check)(if "ranges" in extra {
    extra.ranges
  } else {
    state("codly-ranges", __codly-args.ranges.default).get()
  })

  if ranges == none and range != none {
    ranges = (range, )
  }

  // Pre-check ranges (skips range check in every iter)
  if ranges != none {
    for r in ranges {
      assert(type(r) == array, message: "codly: ranges must be an array of arrays, found " + str(type(r)))
      assert(r.len() == 2, message: "codly: ranges must be an array of arrays with two elements")
    }
  }

  let block-label = auto
  let display-names = (
    __codly-args.display-name.type_check
  )(if "display-name" in extra {
    extra.display-name
  } else {
    state("codly-display-name", __codly-args.display-name.default).get()
  })

  let display-icons = (
    __codly-args.display-icon.type_check
  )(if "display-icon" in extra {
    extra.display-icon
  } else {
    state("codly-display-icon", __codly-args.display-icon.default).get()
  })

  let lang-outset = (
    __codly-args.lang-outset.type_check
  )(if "lang-outset" in extra {
    extra.lang-outset
  } else {
    state("codly-lang-outset", __codly-args.lang-outset.default).get()
  })

  let language-block = {
    let fn = (__codly-args.lang-format.type_check)(if "lang-format" in extra {
      extra.lang-format
    } else {
      state("codly-lang-format", __codly-args.lang-format.default).get()
    })

    if fn == none {
      (..) => none
    } else if fn == auto {
      auto
    } else {
      fn
    }
  }
  let default-color = (
    __codly-args.default-color.type_check
  )(if "default-color" in extra {
    extra.default-color
  } else {
    state("codly-default-color", __codly-args.default-color.default).get()
  })

  let radius = (__codly-args.radius.type_check)(if "radius" in extra {
    extra.radius
  } else {
    state("codly-radius", __codly-args.radius.default).get()
  })

  let offset = (__codly-args.offset.type_check)(if "offset" in extra {
    extra.offset
  } else {
    state("codly-offset", __codly-args.offset.default).get()
  })

  let offset-from = (
    __codly-args.offset-from.type_check
  )(if "offset-from" in extra {
    extra.offset-from
  } else {
    state("codly-offset-from", __codly-args.offset-from.default).get()
  })

  if offset-from != none {
    let origin = query(offset-from)
    if origin.len() == 0 {
      panic("codly: offset-from must be used with a valid label, could not find: " + str(offset-from))
    } else if origin.len() > 1 {
      panic("codly: offset-from must be used with a unique label, found multiple: " + str(offset-from))
    }

    let origin = origin.first()
    let end = query(figure.where(kind: "__codly-end-block").after(origin.location())).first()
    let lines = query(figure.where(kind: "__codly-raw-line").after(origin.location()).before(end.location()))
    if lines.len() > 0 {
      offset += lines.last().body.children.at(0).number
    }
  }

  let stroke = (__codly-args.stroke.type_check)(if "stroke" in extra {
    extra.stroke
  } else {
    state("codly-stroke", __codly-args.stroke.default).get()
  })

  let zebra-color = (
    __codly-args.zebra-fill.type_check
  )(if "zebra-fill" in extra {
    extra.zebra-fill
  } else {
    state("codly-zebra-fill", __codly-args.zebra-fill.default).get()
  })

  let numbers-format = (
    __codly-args.number-format.type_check
  )(if "number-format" in extra {
    extra.number-format
  } else {
    state("codly-number-format", __codly-args.number-format.default).get()
  })

  let numbers-alignment = (
    __codly-args.number-align.type_check
  )(if "number-align" in extra {
    extra.number-align
  } else {
    state("codly-number-align", __codly-args.number-align.default).get()
  })

  let number-placement = (
    __codly-args.number-placement.type_check
  )(if "number-placement" in extra {
    extra.number-placement
  } else {
    state("codly-number-placement", __codly-args.number-placement.default).get()
  })

  if number-placement != "inside" and number-placement != "outside" {
    panic("codly: number-placement must be either `\"inside\"` or `\"outside\"`")
  }

  let numbers-outside = (number-placement == "outside") and numbers-format != none

  let padding = __codly-inset(
    (__codly-args.inset.type_check)(if "inset" in extra {
      extra.inset
    } else {
      state("codly-inset", __codly-args.inset.default).get()
    }),
  )

  let breakable = (
    __codly-args.breakable.type_check
  )(if "breakable" in extra {
    extra.breakable
  } else {
    state("codly-breakable", __codly-args.breakable.default).get()
  })

  let fill = (__codly-args.fill.type_check)(if "fill" in extra {
    extra.fill
  } else {
    state("codly-fill", __codly-args.fill.default).get()
  })

  let skips = {
    let skips = (__codly-args.skips.type_check)(if "skips" in extra {
      extra.skips
    } else {
      state("codly-skips", __codly-args.skips.default).get()
    })
    if skips == none {
      ()
    } else {
      skips.sorted(key: x => x.at(0)).dedup()
    }
  }
  
  let highlighted-lines = (
    __codly-args.highlighted-lines.type_check
  )(if "highlighted-lines" in extra {
    extra.highlighted-lines
  } else {
    state("codly-highlighted-lines", __codly-args.highlighted-lines.default).get()
  });

  let highlighted-default-color = (
    __codly-args.highlighted-default-color.type_check
  )(if "highlighted-default-color" in extra {
    extra.highlighted-default-color
  } else {
    state("codly-highlighted-default-color", __codly-args.highlighted-default-color.default).get()
  });

  let highlighted-by-line = ()
  if highlighted-lines == none {
    
  } else if type(highlighted-lines) == array {
    if highlighted-lines.len() > 0 {
      let ix = 1
      for l in highlighted-lines.sorted(key: (x) => if type(x) == int { x } else { x.at(0) }) {
        let (ln, col) =  if type(l) == int {
          (l, highlighted-default-color)
        } else if type(l) == array {
          assert(l.len() == 2, message: "codly: a highlighted line definition must be an integer or an array of two elements: the line, and the highlight color (array length mismatch)")
          let ln = l.at(0)
          assert(type(ln) == int, message: "codly: the type of a `highlighted-lines` line must be either an integer, found: " + str(type(ln)));
          
          let col = l.at(1)
          assert(
            type(col) == color or type(col) == gradient or type(col) == pattern,
            message: "codly: the type of a `highlighted-lines` color must be either a color, a gradient, or a pattern, found: " + str(type(col))
          )

          (ln, col)
        }

        while ix < ln {
          ix += 1
          highlighted-by-line.push(none)
        }

        highlighted-by-line.push(col)
        ix += 1
      }
    }
  } else {
    panic("codly: incorrect type for highlighted-lines, this shouldn't happen")
  }

  let has-skips = skips != none and skips != ()
  let skip-line = (
    __codly-args.skip-line.type_check
  )(if "skip-line" in extra {
    extra.skip-line
  } else {
    state("codly-skip-line", __codly-args.skip-line.default).get()
  })

  let skip-number = (
    __codly-args.skip-number.type_check
  )(if "skip-number" in extra {
    extra.skip-number
  } else {
    state("codly-skip-number", __codly-args.skip-number.default).get()
  })

  let skip-last-empty = (
    __codly-args.skip-last-empty.type_check
  )(if "skip-last-empty" in extra {
    extra.skip-last-empty
  } else {
    state("codly-skip-last-empty", __codly-args.skip-last-empty.default).get()
  })

  let reference-by = (
    __codly-args.reference-by.type_check
  )(if "reference-by" in extra {
    extra.reference-by
  } else {
    state("codly-reference-by", __codly-args.reference-by.default).get()
  })

  if not reference-by in ("line", "item") {
    panic("codly: reference-by must be either 'line' or 'item'")
  }

  let reference-sep = (
    __codly-args.reference-sep.type_check
  )(if "reference-sep" in extra {
    extra.reference-sep
  } else {
    state("codly-reference-sep", __codly-args.reference-sep.default).get()
  })

  let reference-number-format = (
    __codly-args.reference-number-format.type_check
  )(if "reference-number-format" in extra {
    extra.reference-number-format
  } else {
    state("codly-reference-number-format", __codly-args
        .reference-number-format
        .default).get()
  })

  let annotation-format = {
    let fn = (
      __codly-args.annotation-format.type_check
    )(if "annotation-format" in extra {
      extra.annotation-format
    } else {
      state("codly-annotation-format", __codly-args
          .annotation-format
          .default).get()
    })
    if fn == none {
      _ => none
    } else {
      fn
    }
  }

  let annotations = {
    let annotations = (
      __codly-args.annotations.type_check
    )(if "annotations" in extra {
      extra.annotations
    } else {
      state("codly-annotations", __codly-args.annotations.default).get()
    })
    annotations = if annotations == none or annotations.len() == 0 {
      ()
    } else {
      annotations.sorted(key: x => x.start).map(x => {
        if (not "end" in x) or x.end == none {
          x.insert("end", x.start)
        }

        if (not "content" in x) {
          x.insert("content", none)
        }

        if "label" in x {
          if block-label == none {
            panic("codly: label " + str(x.label) + " is only allowed in a figure block")
          }
        }

        x
      })
    }

    // Check for overlapping annotations.
    let current = none
    for a in annotations {
      if current != none and a.start <= current.end {
        panic("codly: overlapping annotations")
      }
      current = a
    }

    annotations
  }
  let has-annotations = annotations != none and annotations.len() > 0

  // Get the widest annotation.
  let annot-bodies-width = annotations
    .map(x => x.content)
    .map(measure)
    .map(x => x.width)
  let num = annotation-format(annotations.len())
  let lr-width = if annotations.len() > 0 {
    measure(math.lr("}", size: 5em) + num).width
  } else {
    0pt
  }

  let annot-width = annot-bodies-width.fold(
    0pt,
    (a, b) => calc.max(a, b),
  ) + padding.left + padding.right + lr-width

  // Get the height of an individual line.
  let line-height = measure(
    raw.line(1, 1, "X", [X])
  ).height + padding.top + padding.bottom

  let items = ()
  let lines_to_number = ()
  let height = measure[1].height
  let current-annot = none
  let first-annot = false
  let annots = 0

  // prepare the header
  let header = (__codly-args.header.type_check)(if "header" in extra {
    extra.header
  } else {
    state("codly-header", __codly-args.header.default).get()
  })
  let header-repeat = (
    __codly-args.header-repeat.type_check
  )(if "header-repeat" in extra {
    extra.header-repeat
  } else {
    state("codly-header-repeat", __codly-args.header-repeat.default).get()
  })

  // The language block (icon + name)
  let languages = (
    __codly-args.languages.type_check
  )(if "languages" in extra {
    extra.languages
  } else {
    state("codly-languages", __codly-args.languages.default).get()
  })

  let language-block = if alias == none {
    none
  } else if alias in languages {
    let lang = languages.at(alias)
    let name = if type(lang) == str {
      lang
    } else if display-names and "name" in lang {
      lang.name
    } else {
      []
    }
    let icon = if display-icons and "icon" in lang {
      lang.icon
    } else {
      []
    }
    let color = if "color" in lang {
      lang.color
    } else {
      default-color
    }

    if language-block == auto {
      let radius = (
        __codly-args.lang-radius.type_check
      )(if "lang-radius" in extra {
        extra.lang-radius
      } else {
        state("codly-lang-radius", __codly-args.lang-radius.default).get()
      })
      let padding = __codly-inset(
        (__codly-args.lang-inset.type_check)(if "lang-inset" in extra {
          extra.lang-inset
        } else {
          state("codly-lang-inset", __codly-args.lang-inset.default).get()
        }),
      )

      let lang-stroke = (
        __codly-args.lang-stroke.type_check
      )(if "lang-stroke" in extra {
        extra.lang-stroke
      } else {
        state("codly-lang-stroke", __codly-args.lang-stroke.default).get()
      })
      let lang-fill = (
        __codly-args.lang-fill.type_check
      )(if "lang-fill" in extra {
        extra.lang-fill
      } else {
        state("codly-lang-fill", __codly-args.lang-fill.default).get()
      })

      let fill = if type(lang-fill) == function {
        (lang-fill)((name: name, icon: icon, color: color))
      } else if type(lang-fill) == color or type(lang-fill) == gradient or type(lang-fill) == pattern {
        lang-fill
      } else {
        color
      }

      let stroke = if type(lang-stroke) == function {
        (lang-stroke)((name: name, icon: icon, color: color))
      } else {
        lang-stroke
      }

      let b = measure(icon + name)
      box(
        radius: radius,
        fill: fill,
        inset: padding,
        stroke: stroke,
        outset: 0pt,
        height: b.height + padding.top + padding.bottom,
        icon + name,
      )
    } else {
      (language-block)(name, icon, color)
    }
  } else if display-names {
    if language-block == auto {
      let radius = (
        __codly-args.lang-radius.type_check
      )(if "lang-radius" in extra {
        extra.lang-radius
      } else {
        state("codly-lang-radius", __codly-args.lang-radius.default).get()
      })

      let padding = __codly-inset(
        (__codly-args.lang-inset.type_check)(if "lang-inset" in extra {
          extra.lang-inset
        } else {
          state("codly-lang-inset", __codly-args.lang-inset.default).get()
        }),
      )

      let lang-stroke = (
        __codly-args.lang-stroke.type_check
      )(if "lang-stroke" in extra {
        extra.lang-stroke
      } else {
        state("codly-lang-stroke", __codly-args.lang-stroke.default).get()
      })

      let lang-fill = (
        __codly-args.lang-fill.type_check
      )(if "lang-fill" in extra {
        extra.lang-fill
      } else {
        state("codly-lang-fill", __codly-args.lang-fill.default).get()
      })

      let fill = if type(lang-fill) == function {
        (lang-fill)((name: alias, icon: [], color: default-color))
      } else if type(lang-fill) == color or type(lang-fill) == gradient or type(lang-fill) == pattern {
        lang-fill
      } else {
        default-color
      }

      let stroke = if type(lang-stroke) == function {
        (lang-stroke)((name: alias, icon: [], color: default-color))
      } else {
        lang-stroke
      }

      let b = measure(alias)
      box(
        radius: radius,
        fill: fill,
        inset: padding,
        stroke: stroke,
        outset: 0pt,
        height: b.height + padding.top + padding.bottom,
        alias,
      )
    } else {
      (language-block)(alias, [], default-color)
    }
  }

  // Push the line and the language block in a grid for alignment
  let language-block-final = place(
    right + horizon,
    dx: lang-outset.x,
    dy: lang-outset.y,
    language-block,
  )
  let lb = measure(language-block)

  let header = if header != none {
    let header-args = (
      __codly-args.header-cell-args.type_check
    )(if "header-cell-args" in extra {
      extra.header-cell-args
    } else {
      state("codly-header-cell-args", __codly-args
          .header-cell-args
          .default).get()
    })

    let transform = (
      __codly-args.header-transform.type_check
    )(if "header-transform" in extra {
      extra.header-transform
    } else {
      state("codly-header-transform", __codly-args
          .header-transform
          .default).get()
    })

    lines_to_number.push(-999999999)
    (
      grid.header(
        repeat: header-repeat,
        grid.cell(
          transform(header) + language-block-final,
          colspan: if numbers-format == none { 1 } else { 2 },
          ..header-args,
        ),
      ),
    )
  } else {
    none
  }

  let smart-skip = (
    __codly-args.smart-skip.type_check
  )(if "smart-skip" in extra {
    extra.smart-skip
  } else {
    state("codly-smart-skip", __codly-args
        .smart-skip
        .default).get()
  })

  let smart-skip-top = if type(smart-skip) == bool {
    smart-skip
  } else if "first" in smart-skip {
    smart-skip.first
  } else if "rest" in smart-skip {
    smart-skip.rest
  } else {
    false
  }

  let smart-skip-bot = if type(smart-skip) == bool {
    smart-skip
  } else if "last" in smart-skip {
    smart-skip.last
  } else if "rest" in smart-skip {
    smart-skip.rest
  } else {
    false
  }

  let smart-skip-rest = if type(smart-skip) == bool {
    smart-skip
  } else if "rest" in smart-skip {
    smart-skip.rest
  } else {
    false
  }

  let smart-skip-enabled = if type(smart-skip) == bool {
    smart-skip
  } else {
    smart-skip.values().any((v) => v) 
  }

  let in-skip = false
  let in-first = true
  let had-first = false
  for line in it.lines {
    first-annot = false

    // Check for annotations
    let annot = annotations.at(0, default: none)
    if annot != none and line.number == annot.start {
      current-annot = annot
      first-annot = true
      annots += 1
    }

    // Cleanup annotations
    if current-annot != none and line.number > current-annot.end {
      current-annot = none
      _ = annotations.remove(0)

      // Check for annotations again
      let annot = annotations.at(0, default: none)
      if annot != none and line.number == annot.start {
        current-annot = annot
        first-annot = true
        annots += 1
      }
    }

    // Try and look for a skip
    let skip = skips.at(0, default: none)
    if skip != none and line.number == skip.at(0) {
      if numbers-format != none { 
        items.push(skip-number)
      }

      items.push(skip-line)
      lines_to_number.push(-99999999);
      // Advance the offset.
      offset += skip.at(1)
      _ = skips.remove(0)
    } else if smart-skip-enabled and not in_range(ranges, line.number) and not in-skip {
      if in-first {
        if smart-skip-top {
          if numbers-format != none { 
            items.push(skip-number)
          }
          items.push(skip-line)
          lines_to_number.push(-99999999);
        }
      } else if array.range(line.number, line.count).any((i) => in_range(ranges, i)) {
        if smart-skip-rest {
          if numbers-format != none { 
            items.push(skip-number)
          }
          items.push(skip-line)
          lines_to_number.push(-99999999);
        }
      } else {
        if smart-skip-bot {
          if numbers-format != none { 
            items.push(skip-number)
          }
          items.push(skip-line)
          lines_to_number.push(-99999999);
        }
      }
    }

    // Don't include if not in range
    if not in_range(ranges, line.number) {
      in-skip = true
      continue
    } else {
      in-skip = false
    }

    in-first = false

    // Remove the last line if it's empty
    if skip-last-empty and line.text.trim().len() == 0 and line.number == line.count {
      continue
    }

    // Always push the formatted line number
    let l = figure(
      kind: "__codly-raw-line",
      numbering: none,
      placement: none,
      outlined: false,
      gap: 0pt,
      caption: none,
      [#raw.line(
        line.number + offset,
        line.count,
        line.text,
        box(height: height, width: 0pt) + line.body,
      ) <codly-highlighted>]
    )

    lines_to_number.push(line.number + offset)

    // Must be done before the smart indentation code.
    // Otherwise it results in two paragraphs.
    if numbers-format != none {
      items.push(numbers-format(line.number + offset))      
    }

    let annot = none
    if current-annot != none and first-annot {
      let height = line-height * (current-annot.end - current-annot.start + 1)
      let num = annotation-format(annots)
      let label = if "label" in current-annot and current-annot.label != none {
        let referenced = if reference-by == "line" {
          reference-number-format(line.number + offset)
        } else {
          num
        }

        place(hide[#figure(
          kind: "codly-referencer",
          supplement: none,
          numbering: (..) => {
            ref(block-label)
            sep
            referenced
          },
          []
        )#current-annot.label])
      } else {
        none
      }

      let annot-content = {
        $lr(}, size: #height) #num #current-annot.content #label$
      }

      annot = grid.cell(
        rowspan: current-annot.end - current-annot.start + 1,
        align: left + horizon,
        annot-content,
      )
    }
    
    if had-first or (
      display-names != true and display-icons != true
    ) {
      if annot == none and has-annotations {
        items.push(grid.cell(l, colspan: if current-annot == none { 2 } else { 1 }))
      } else if annot == none {
        items.push(l)
      } else {
        items.push(l)
        items.push(annot)
      }
      continue
    } else if alias == none {
      if annot == none and has-annotations {
        items.push(grid.cell(l, colspan: if current-annot == none { 2 } else { 1 }))
      } else if annot == none {
        items.push(l)
      } else {
        items.push(l)
        items.push(annot)
      }
      continue
    }

    had-first = true
    if has-annotations {
      if header != none {
        if annot == none and has-annotations {
          items.push(grid.cell(l, colspan: if current-annot == none { 2 } else { 1 }))
        } else if annot == none {
          items.push(annot)
        } else {
          items.push(l)
          items.push(annot)
        }
      } else {
        // Annotation printing
        if annot == none and has-annotations {
          items.push(grid.cell(grid(
            columns: (1fr, lb.width + padding.left + padding.right),
            l, language-block-final,
          ), colspan: if current-annot == none { 2 } else { 1 }))
        } else if annot == none {
          items.push(grid(
            columns: (1fr, lb.width + padding.left + padding.right),
            l, language-block-final,
          ))
          items = (..items, grid(
            columns: (1fr, lb.width + padding.left + padding.right),
            l, language-block-final,
          ))
        } else {
          items.push(grid(
            columns: (1fr, lb.width + padding.left + padding.right),
            l, language-block-final,
          ))
          items.push(annot)
        }
      }
    } else {
      if header != none {
        items.push(l)
      } else {
        items.push(
          grid(
            columns: (1fr, lb.width + padding.left + padding.right),
            l, language-block-final,
          ),
        )
      }
    }
  }

  // prepare the footer
  let footer = (__codly-args.footer.type_check)(if "footer" in extra {
    extra.footer
  } else {
    state("codly-footer", __codly-args.footer.default).get()
  })
  let footer-repeat = (
    __codly-args.footer-repeat.type_check
  )(if "footer-repeat" in extra {
    extra.footer-repeat
  } else {
    state("codly-footer-repeat", __codly-args.footer-repeat.default).get()
  })
  let footer = if footer != none {
    let footer-args = (
      __codly-args.footer-cell-args.type_check
    )(if "footer-cell-args" in extra {
      extra.footer-cell-args
    } else {
      state("codly-footer-cell-args", __codly-args
          .footer-cell-args
          .default).get()
    })
    let transform = (
      __codly-args.footer-transform.type_check
    )(if "footer-transform" in extra {
      extra.footer-transform
    } else {
      state("codly-footer-transform", __codly-args
          .footer-transform
          .default).get()
    })

    (
      grid.footer(
        repeat: footer-repeat,
        grid.cell(
          transform(footer),
          colspan: if numbers-format == none { 1 } else { 2 },
          ..footer-args
        ),
      ),
    )
  } else {
    ()
  }

  // If the fill or zebra color is a gradient, we will draw it on a separate layer.
  let is-complex-fill = (
    (type(fill) != color and fill != none) or (
      type(zebra-color) != color and zebra-color != none
    )
  )
  
  let width_lines_number = calc.max(2, (calc.ceil(calc.log(it.lines.len())) + 1)) * 1em

  let line_colors = ()
  for (i, line) in lines_to_number.enumerate() {
    let highlighted = highlighted-by-line.at(line - 1, default: none)
    if highlighted != none {
      line_colors.push(highlighted)
    } else if zebra-color != none and calc.rem(i, 2) == 0 {
      line_colors.push(zebra-color)
    } else {
      line_colors.push(fill)
    }
  }

  let block_content = block(
    breakable: breakable,
    clip: true,
    width: 100%,
    radius: radius,
    stroke: if numbers-outside { none } else { stroke },
    {
      if is-complex-fill {
        // We use place to draw the fill on a separate layer.
        place(
          grid(
            columns: if has-annotations {
              (1fr, annot-width)
            } else {
              (1fr,)
            },
            stroke: none,
            inset: padding.pairs().map(((k, x)) => (k, x * 1.5)).to-dict(),
            fill: (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
              zebra-color
            } else {
              fill
            },
            ..header,
            ..it.lines.map(line => hide(line)),
            ..footer,
          ),
        )
      }

      if numbers-format != none {
        grid(
          columns: if has-annotations {
            (auto, 1fr, annot-width)
          } else {
            (auto, 1fr)
          },
          inset: padding.pairs().map(((k, x)) => (k, x * 1.5)).to-dict(),
          stroke: (x,y) => 
            if numbers-outside {
              let idx_end = if has-annotations {
                2
              } else {
                1
              }

              (
                left: if x == 1 { stroke } else { none },
                right: if x == idx_end { stroke } else { none },
                top: if x != 0 and y == 0 { stroke } else { none },
                bottom: if x != 0 and y == it.lines.len() - 1 { stroke } else { none },
              )
            } else {
              none
            },
          align: (numbers-alignment, left + horizon),
          fill: if is-complex-fill {
            none
          } else {
            (x, y) => if numbers-outside and x == 0 {
              none 
            } else {
              line_colors.at(y, default: fill)
            }
          },
          ..header,
          ..items,
          ..footer,
        )
      } else {
        grid(
          columns: if has-annotations {
            (1fr, annot-width)
          } else {
            (1fr)
          },
          inset: padding.pairs().map(((k, x)) => (k, x * 1.5)).to-dict(),
          stroke: none,
          align: (numbers-alignment, left + horizon),
          fill: (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
            zebra-color
          } else {
            fill
          },
          ..header,
          ..items,
          ..footer,
        )
      }
    },
  )
  
  block_content
    
  figure(
    kind: "__codly-end-block",
    supplement: none,
    numbering: none,
    placement: none,
    outlined: false,
    gap: 0pt,
    caption: none,
  )[]

  if offset != 0 {
    state("codly-offset").update(0)
  }

  if offset-from != none {
    state("codly-offset-from").update(none)
  }

  if range != none {
    state("codly-range").update(none)
  }

  if ranges != none {
    state("codly-ranges").update(none)
  }

  if has-skips {
    state("codly-skips").update(())
  }

  if has-annotations {
    state("codly-annotations").update(())
  }

  if header != () {
    state("codly-header").update(none)
  }

  if footer != () {
    state("codly-footer").update(none)
  }

  let highlights = state("codly-highlights").get()
  if highlights != none and highlights != () {
    state("codly-highlights").update(())
  }

  let highlighted = state("codly-highlighted-lines").get()
  if highlighted != none and highlighted != () {
    state("codly-highlighted-lines").update(())
  }
}

#let __codly-get-parts(fig) = {
  let num = fig.body.children.at(0)
  let lbl = fig.body.children.at(1)
  (num.body, label(lbl.body.text))
}

/// Initializes the codly show rule.
///
/// ```typ
/// #show: codly-init
/// ```
/// 
/// - body (content): the body of the document
/// 
/// -> content
#let codly-init(
  body,
) = {
  show figure.where(kind: raw): fig => {
    if fig.has("label") {
      show raw.where(block: true): it => __codly-raw(it, block-label: fig.label)
      fig
    } else {
      fig
    }
  }

  show raw.where(block: true): it => __codly-raw(it)

  body
}

/// Allows setting codly setting locally.
/// Anything that happens inside the block will have the settings applied only to it.
/// The pre-existing settings will be restored after the block. This is useful
/// if you want to apply settings to a specific block only.
///
/// #pre-example()
/// #example(`````
///  *Special:*
///  #local(default-color: red)[
///    ```
///    Hello, world!
///    ```
///  ]
///
///  *Normal:*
///  ```
///  Hello, world!
///  ```
/// `````, mode: "markup", scale-preview: 100%)
#let __local-inner(body, nested: false, ..args) = {
  assert(type(nested) == bool, message: "local: nested must be a boolean, found: " + str(type(nested)))
  if nested {
    let extra = args.named()
    context {
      let current = state("codly-extra-args", (:)).get()
      state("codly-extra-args", (:)).update(old => {
        old + extra
      })

      let args = current + extra
      show raw.where(block: true): it => __codly-raw(it, extra: args)
      show figure.where(kind: raw): fig => {
        if fig.has("label") {
          show raw.where(block: true, extra: args): it => __codly-raw(it, block-label: fig.label)
          fig
        } else {
          fig
        }
      }

      body
      state("codly-extra-args").update(current)
    }
  } else {
    let extra = args.named()
    state("codly-extra-args").update(extra)
    show raw.where(block: true): it => __codly-raw(it, extra: extra)
    show figure.where(kind: raw): fig => {
      if fig.has("label") {
        show raw.where(block: true, extra: args): it => __codly-raw(it, block-label: fig.label)
        fig
      } else {
        fig
      }
    }
    body
    state("codly-extra-args").update((:))
  }
}

#let typst-icon = (
  typ: (
    name: "Typst",
    icon: box(
      image("typst-small.png", height: 0.8em),
      baseline: 0.1em,
      inset: 0pt,
      outset: 0pt,
    ) + h(0.2em),
    color: rgb("#239DAD"),
  ),
  typc: (
    name: "Typst code",
    icon: box(
      image("typst-small.png", height: 0.8em),
      baseline: 0.1em,
      inset: 0pt,
      outset: 0pt,
    ) + h(0.2em),
    color: rgb("#239DAD"),
  ),
)
