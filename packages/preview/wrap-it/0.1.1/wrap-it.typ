#let styled = text(red)[lorem].func()

#let _gridded(dir, fixed, to-wrap, ..kwargs) = {
  let dir-kwargs = (:)
  if dir not in (ltr, rtl) {
    panic("Specify either `rtl` or `ltr` as the wrap direction")
  }
  let args = if dir == rtl {
    (to-wrap, fixed)
  } else {
    (fixed, to-wrap)
  }
  grid(..args, columns: 2, rows: 2, column-gutter: 1em, ..kwargs)
}

#let _grid-height(content, container-size) = {
  measure(box(width: container-size.width, content)).height
}

#let _get-chunk(words, end, reverse, start: 0) = {
  if end < 0 {
    return words.join(" ")
  }
  if reverse {
    words = words.rev()
  }
  let subset = words.slice(start, end)
  if reverse {
    subset = subset.rev()
  }
  subset.join(" ")
}

#let _get-wrap-index(height-func, words, goal-height, reverse) = {
  for index in range(1, words.len(), step: 1) {
    let cur-height = height-func(_get-chunk(words, index, reverse))
    if cur-height > goal-height {
      return index - 1
    }
  }
  return -1
}

#let _rewrap(element, new-content) = {
  let fields = element.fields()
  for key in ("body", "text", "children", "child") {
    if key in fields {
      let _ = fields.remove(key)
    }
  }
  let positional = (new-content,)
  if "styles" in fields {
    positional.push(fields.remove("styles"))
  }
  element.func()(..fields, ..positional)
}

#let split-other(body, height-func, goal-height, align, splitter-func) = {
  (wrapped: none, rest: body)
}

#let split-has-text(body, height-func, goal-height, align, splitter-func) = {
  let words = body.text.split(" ")
  let reverse = align.y == bottom
  let wrap-index = _get-wrap-index(height-func, words, goal-height, reverse)
  let _rewrap = _rewrap.with(body)
  if wrap-index > 0 {
    let chunk = _rewrap(_get-chunk(words, wrap-index, reverse))
    let end-chunk = _rewrap(_get-chunk(words, words.len(), reverse, start: wrap-index))
    (
      wrapped: context {
        chunk
        linebreak(justify: par.justify)
      },
      rest: end-chunk,
    )
  } else {
    (wrapped: none, rest: body)
  }
}

#let split-has-children(body, height-func, goal-height, align, splitter-func) = {
  let reverse = align.y == bottom
  let children = if reverse {
    body.children.rev()
  } else {
    body.children
  }
  for (ii, child) in children.enumerate() {
    let prev-children = children.slice(0, ii).join()
    let new-height-func(child) = {
      height-func((prev-children, child).join())
    }
    let height = new-height-func(child)
    if height <= goal-height {
      continue
    }
    // height func calculator should now account for prior children
    let split = splitter-func(child, new-height-func, goal-height, align)
    let new-children = (..children.slice(0, ii), split.wrapped)
    let new-rest = children.slice(ii + 1)
    if split.rest != none {
      new-rest.insert(0, split.rest)
    }
    if reverse {
      new-children = new-children.rev()
      new-rest = new-rest.rev()
    }
    return (
      wrapped: _rewrap(body, new-children),
      rest: _rewrap(body, new-rest),
    )
  }
  panic("This function should only be called if the seq child should be split")
}

#let split-has-body(body, height-func, goal-height, align, splitter-func) = {
  // Elements that can be split and have a 'body' field.
  let splittable = (strong, emph, underline, stroke, overline, highlight, list.item, styled)

  let new-height-func(content) = {
    height-func(_rewrap(body, content))
  }
  let args = (new-height-func, goal-height, align, splitter-func)
  let body-text = body.at("body", default: body.at("child", default: none))
  if body.func() in splittable {
    let result = splitter-func(body-text, new-height-func, goal-height, align)
    if result.wrapped != none {
      return (wrapped: _rewrap(body, result.wrapped), rest: _rewrap(body, result.rest))
    } else {
      return split-other(body, ..args)
    }
  }
  // Shape doesn't split nicely, so treat it as unwrappable
  return split-other(body, ..args)
}

#let splitter(body, height-func, goal-height, align) = {
  let self-height = height-func(body)
  if self-height <= goal-height {
    return (wrapped: body, rest: none)
  }
  if type(body) == str {
    body = text(body)
  }
  let body-splitter = if body.has("text") {
    split-has-text
  } else if body.has("body") or body.has("child") {
    split-has-body
  } else if body.has("children") {
    split-has-children
  } else {
    split-other
  }
  return body-splitter(body, height-func, goal-height, align, splitter)
}

#let _inner-wrap-content(to-wrap, y-align, grid-func, container-size, ..grid-kwargs) = {
  let height-func(txt) = _grid-height(grid-func(txt), container-size)
  let goal-height = height-func([])
  if y-align == top {
    goal-height += measure(v(1em)).height
  }
  let result = splitter(to-wrap, height-func, goal-height, y-align)
  if y-align == top {
    grid-func(result.wrapped)
    result.rest
  } else {
    result.rest
    grid-func(result.wrapped)
  }
}

/// Places `to-wrap` next to `fixed`, wrapping `to-wrap` as its height overflows `fixed`.
///
/// *Basic Use:*
/// ```typ
/// #let body = lorem(40)
/// #wrap-content(rect(fill: teal), body)
/// ```
///
/// *Something More Fun:*
/// ```typ
/// #set par(justify: true)
/// // Helpers; not required
/// #let grad(map) = {
///   gradient.linear(
///     ..eval("color.map." + map)
///   )
/// }
/// #let make-fig(fill) = {
///   set figure.caption(separator: "")
///   fill = grad(fill)
///   figure(
///     rect(fill: fill, radius: 0.5em),
///     caption: [],
///   )
/// }
/// #let (fig1, fig2) = {
///   ("viridis", "plasma").map(make-fig)
/// }
/// #wrap-content(fig1, body, align: right)
/// #wrap-content(fig2, [#body #body], align: bottom)
/// ```
///
/// Note that you can increase the distance between a figure's bottom and the wrapped
/// text by boxing it with an inset:
/// ```typ
/// #let spaced = box(
///   make-fig("rocket"),
///   inset: (bottom: 0.3em)
/// )
/// #wrap-content(spaced, body)
/// ```
///
/// - fixed (content): Content that will not be wrapped, (i.e., a figure).
///
/// - to-wrap (content): Content that will be wrapped, (i.e., text). Currently, logic
///   works best with pure-text content, but hypothetically will work with any `content`.
///
/// - align (alignment): Alignment of `fixed` relative to `to-wrap`. `top` will align
///   the top of `fixed` with the top of `to-wrap`, and `bottom` will align the bottom of
///   `fixed` with the bottom of `to-wrap`. `left` and `right` alignments determine
///   horizontal alignment of `fixed` relative to `to-wrap`. Alignments can be combined,
///   i.e., `bottom + right` will align the bottom-right corner of `fixed` with the
///   bottom-right corner of `to-wrap`.
///  ```typ
///  #wrap-content(
///    make-fig("turbo"),
///    body,
///    align: bottom + right
///  )
///  ```
///
/// - size (size, auto): Size of the wrapping container. If `auto`, this will be set to
///   the current container size. Otherwise, wrapping logic will attempt to stay within
///   the provided constraints.
///
/// - ..grid-kwargs (any): Keyword arguments to pass to the underlying `grid` function.
///   Of note:
///     - `column-gutter` controls horizontal margin between `fixed` and `to-wrap`. Or,
///       you can surround the fixed content in a box with `(inset: ...)` for more
///       fine-grained control.
///     - `columns` can be set to force sizing of `fixed` and `to-wrap`. For instance,
///       `columns: (50%, 50%)` will force `fixed` and `to-wrap` to each take up half
///       of the available space. If content isn't this big, the fill will be blank
///       margin.
///  ```typ
///  #let spaced = box(
///    make-fig("mako"), inset: 0.5em
///  )
///  #wrap-content(spaced, body)
///  ```
///  ```typ
///  #wrap-content(
///    make-fig("spectral"),
///    body,
///    align: bottom,
///    columns: (50%, 50%),
///  )
///  ```
///
#let wrap-content(
  fixed,
  to-wrap,
  align: top + left,
  size: auto,
  ..grid-kwargs,
) = {
  if center in (align.x, align.y) {
    panic("Center alignment is not supported")
  }

  // "none" x alignment defaults to left
  let dir = if align.x == right {
    rtl
  } else {
    ltr
  }
  let gridded(..args) = box(_gridded(dir, fixed, ..grid-kwargs, ..args))
  // "none" y alignment defaults to top
  let y-align = if align.y == bottom {
    bottom
  } else {
    top
  }

  if size != auto {
    _inner-wrap-content(to-wrap, y-align, gridded, size, ..grid-kwargs)
  } else {
    layout(container-size => {
      _inner-wrap-content(to-wrap, y-align, gridded, container-size, ..grid-kwargs)
    })
  }
}

/// Wrap a body of text around two pieces of content. The logic only works if enough text
/// exists to overflow both the top and bottom content. Use this instead of 2 separate
/// `wrap-content` calls if you want to avoid a paragraph break between the top and bottom
/// content.
///
/// *Example:*
/// ```typ
/// #let fig1 = make-fig("inferno")
/// #let fig2 = make-fig("rainbow")
/// #wrap-top-bottom(fig1, fig2, lorem(60))
/// ```
/// - top-fixed (content): Content that will not be wrapped, (i.e., a figure).
/// - bottom-fixed (content): Content that will not be wrapped, (i.e., a figure).
/// - body (content): Content that will be wrapped, (i.e., text)
/// - top-kwargs (any): Keyword arguments to pass to the underlying `wrap-content` function
///   for the top content. `x` alignment is kept (left/right), but `y` alignment is
///   overridden to `top`.
/// - bottom-kwargs (any): Keyword arguments to pass to the underlying `wrap-content` function
///   for the bottom content. `x` alignment is kept (left/right), but `y` alignment is
///   overridden to `bottom`.
///
#let wrap-top-bottom(
  top-fixed,
  bottom-fixed,
  body,
  top-kwargs: (:),
  bottom-kwargs: (:),
) = {
  top-kwargs = top-kwargs + (
    align: top-kwargs.at("align", default: top + left).x + top,
  )
  bottom-kwargs = bottom-kwargs + (
    align: bottom-kwargs.at("align", default: bottom + right).x + bottom,
  )
  layout(size => {
    let wrapfig(..args) = wrap-content(size: size, ..args)
    wrapfig(top-fixed, ..top-kwargs)[
      #wrapfig(bottom-fixed, ..bottom-kwargs)[
        #body
      ]
    ]
  })
}
