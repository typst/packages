#import "../util/parse-args.typ": *

/// Define body border arguments for styling
///
/// Version 0.2.0 arguments: "stroke", "radius", "outset", "fill", "inset" (length), "clip"
/// Version 0.3.0 additions: "sticky", "breakable", "width" (only works for whole)
#let body-border-args = ("stroke", "radius", "outset", "fill", "inset", "clip", "sticky", "breakable", "width")

/// Processes body formatting configurations including border styles, text styles,
/// and format specifications for outer, inner, and whole body elements.
#let parse-body-format(body-format, level, ..args) = {
  let border = (outer: _ => (:), inner: _ => (:), whole: _ => (:))
  let format = (outer: none, inner: none, whole: none)
  let style = _ => (:)
  if type(body-format) == dictionary {
    let outer = body-format.remove("outer", default: none)
    let inner = body-format.remove("inner", default: none)
    let whole = body-format.remove("whole", default: none)

    let text-style = body-format.remove("style", default: none)

    if outer == none and inner == none and whole == none {
      outer = body-format
    }

    if type(outer) in (function, array) {
      format.outer = outer
    } else {
      format.outer = if type(outer) == dictionary { outer.remove("format", default: none) }
    }
    if type(inner) in (function, array) {
      format.inner = inner
    } else {
      format.inner = if type(inner) == dictionary { inner.remove("format", default: none) }
    }
    if type(whole) in (function, array) {
      format.whole = whole
    } else {
      format.whole = if type(whole) == dictionary { whole.remove("format", default: none) }
    }

    border.outer = parse-format-with(outer, level, fmt-args: body-border-args, ..args)
    border.inner = parse-format-with(inner, level, fmt-args: body-border-args, ..args)
    border.whole = parse-format-with(whole, level, fmt-args: body-border-args, ..args)

    style = parse-body-text-format-with(text-style, level, ..args)
  } else {
    if type(body-format) in (function, array) {
      format.outer = body-format
    }
  }
  format.outer = parse-format-func(format.outer, ..args)(level)
  format.inner = parse-format-func(format.inner, ..args)(level)
  format.whole = parse-format-func(format.whole, ..args)(level)
  return (border, style, format)
}

#let get-body-format(
  body-format,
  elem-body-format,
  item-body-format,
  rel-level,
  curr-level,
  level-item,
  args-with-tags,
  args-with-tags-item,
) = {
  let (border-f, style-f, format-f) = parse-body-format(body-format, rel-level, ..args-with-tags)
  let (border-f-e, style-f-e, format-f-e) = parse-body-format(
    elem-body-format,
    curr-level,
    ..args-with-tags,
  )
  let body-format-item = n => parse-body-format(
    item-body-format(n),
    level-item(n),
    ..args-with-tags-item,
  )
  (
    for (k, value) in border-f {
      (
        str(k): (n, ..more-args) => (
          value(n, ..more-args)
            + (border-f-e.at(str(k)))(n, ..more-args)
            + body-format-item(n).at(0).at(str(k))(n, ..more-args)
        ),
      )
    },
    (n, ..more-args) => style-f(n, ..more-args) + style-f-e(n, ..more-args) + body-format-item(n).at(1)(n, ..more-args),
    for (k, f) in format-f {
      (
        str(k): n => (body, ..more-args) => {
          let f-e = format-f-e.at(str(k))
          let f-item = body-format-item(n).at(2).at(str(k))
          f(n)(f-e(n)(f-item(n)(body, ..more-args), ..more-args), ..more-args)
        },
      )
    },
  )
}