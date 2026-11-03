#import "../util/parse-args.typ": *

#let parse-len(complex-len, default, level, ..args) = (n, ..more-args) => {
  if complex-len == auto {
    return default
  } else {
    let result
    // complex-len: it => value; it => array
    if type(complex-len) == function {
      let temp-len = complex-len(
        (
          level: level + 1,
          n: n + 1,
          ..more-args.named(),
          ..pre-parse-tag(n, ..args),
        ),
      )
      result = get-value-by-n(temp-len, auto, default)(n)
    } else {
      // complex-len: array; value
      result = get-value-by-n(get-depth-value(complex-len, level), auto, default)(n)
    }
    assert(
      type(result) == length or result in (auto, none),
      message: "Expected a `length` value or `auto`. \nBut found: " + repr(result),
    )
    return result
  }
}

#let parse-h-spacing(
  curr-level,
  indent,
  body-indent,
  label-indent,
  label-inset,
  first-line-inset,
  hanging-indent,
  line-indent,
  indent-default: 0pt,
  body-indent-default: 0pt,
  ..args,
) = {
  let curr-indent = parse-len(indent, indent-default, curr-level, ..args)
  let curr-body-indent = parse-len(body-indent, body-indent-default, curr-level, ..args)
  let curr-label-indent = parse-len(label-indent, 0pt, curr-level, ..args)
  let curr-label-inset = parse-len(label-inset, 0pt, curr-level, ..args)
  let curr-first-line-inset = parse-len(first-line-inset, 0pt, curr-level, ..args)
  let curr-hanging-indent = parse-len(hanging-indent, auto, curr-level, ..args)
  let curr-line-indent = parse-len(line-indent, auto, curr-level, ..args)

  return (
    curr-indent,
    curr-body-indent,
    curr-label-indent,
    curr-label-inset,
    curr-first-line-inset,
    curr-hanging-indent,
    curr-line-indent,
  )
}

#let get-h-spacing(
  rel-level,
  curr-level,
  level-item,
  indent-default: 0pt,
  body-indent-default: 0pt,
  indent-f,
  body-indent-f,
  label-indent-f,
  label-inset-f,
  first-line-inset-f,
  hanging-indent-f,
  line-indent-f,
  indent-f-e,
  body-indent-f-e,
  label-indent-f-e,
  label-inset-f-e,
  first-line-inset-f-e,
  hanging-indent-f-e,
  line-indent-f-e,
  indent-f-item,
  body-indent-f-item,
  label-indent-f-item,
  label-inset-f-item,
  first-line-inset-f-item,
  hanging-indent-f-item,
  line-indent-f-item,
  args-with-tags,
  args-with-tags-item,
) = {
  let (
    indent-f,
    body-indent-f,
    label-indent-f,
    label-inset-f,
    first-line-inset-f,
    hanging-indent-f,
    line-indent-f,
  ) = parse-h-spacing(
    rel-level,
    indent-f,
    body-indent-f,
    label-indent-f,
    label-inset-f,
    first-line-inset-f,
    hanging-indent-f,
    line-indent-f,
    indent-default: indent-default,
    body-indent-default: body-indent-default,
    ..args-with-tags,
  )
  let (
    indent-f-e,
    body-indent-f-e,
    label-indent-f-e,
    label-inset-f-e,
    first-line-inset-f-e,
    hanging-indent-f-e,
    line-indent-f-e,
  ) = parse-h-spacing(
    curr-level,
    indent-f-e,
    body-indent-f-e,
    label-indent-f-e,
    label-inset-f-e,
    first-line-inset-f-e,
    hanging-indent-f-e,
    line-indent-f-e,
    indent-default: indent-default,
    body-indent-default: body-indent-default,
    ..args-with-tags,
  )
  let (
    indent-f-item,
    body-indent-f-item,
    label-indent-f-item,
    label-inset-f-item,
    first-line-inset-f-item,
    hanging-indent-f-item,
    line-indent-f-item,
  ) = {
    let item-args = n => parse-h-spacing(
      level-item(n),
      indent-f-item(n),
      body-indent-f-item(n),
      label-indent-f-item(n),
      label-inset-f-item(n),
      first-line-inset-f-item(n),
      hanging-indent-f-item(n),
      line-indent-f-item(n),
      indent-default: indent-default,
      body-indent-default: body-indent-default,
      ..args-with-tags-item,
    )
    let args-size = 7
    for i in range(args-size) {
      (n => item-args(n).at(i),)
    }
  }
  return (
    (n, ..more-args) => get-none-value(indent-f(n, ..more-args), get-none-value(
      indent-f-e(n, ..more-args),
      indent-f-item(n)(n, ..more-args),
    )),
    (n, ..more-args) => get-none-value(body-indent-f(n, ..more-args), get-none-value(
      body-indent-f-e(n, ..more-args),
      body-indent-f-item(n)(n, ..more-args),
    )),
    (n, ..more-args) => get-none-value(label-indent-f(n, ..more-args), get-none-value(
      label-indent-f-e(n, ..more-args),
      label-indent-f-item(n)(n, ..more-args),
    )),
    (n, ..more-args) => get-none-value(label-inset-f(n, ..more-args), get-none-value(
      label-inset-f-e(n, ..more-args),
      label-inset-f-item(n)(n, ..more-args),
    )),
    (n, ..more-args) => get-none-value(first-line-inset-f(n, ..more-args), get-none-value(
      first-line-inset-f-e(n, ..more-args),
      first-line-inset-f-item(n)(n, ..more-args),
    )),
    (n, ..more-args) => get-none-value(hanging-indent-f(n, ..more-args), get-none-value(
      hanging-indent-f-e(n, ..more-args),
      hanging-indent-f-item(n)(n, ..more-args),
    )),
    (n, ..more-args) => get-none-value(line-indent-f(n, ..more-args), get-none-value(
      line-indent-f-e(n, ..more-args),
      line-indent-f-item(n)(n, ..more-args),
    )),
  )
}



#let parse-body-margin(
  curr-level,
  body-margin,
  ..args,
) = {
  let margin-f = parse-general-func-with-level-n(body-margin, auto, auto, ..args)(curr-level)
  // parse body-margin
  (n, ..more-args) => {
    let margin = margin-f(n, ..more-args)
    if margin == auto {
      return (left: auto, right: auto)
    } else if type(margin) in length-type {
      // ratio: left (relative to label-width) and right (relative to parent-width)
      return (left: margin, right: margin)
    } else if type(margin) == dictionary {
      let left-margin = margin.remove("left", default: auto)
      let right-margin = margin.remove("right", default: auto)
      assert(
        left-margin == auto or type(left-margin) in length-type,
        message: "The `left` value of `body-margin` should be a length or `auto`."
          + "\nBut found: "
          + repr(left-margin)
          + ".",
      )
      assert(
        right-margin == auto or type(right-margin) in length-type,
        message: "The `right` value of `body-margin` should be a length or `auto`."
          + "\nBut found: "
          + repr(right-margin)
          + ".",
      )
      assert(
        margin == (:),
        message: "The dictionary of `body-margin` should be two keys `left` and `right`."
          + "\But found: "
          + repr(margin.keys())
          + ".",
      )
      return (left: left-margin, right: right-margin)
    } else if margin != none {
      panic(
        "Invalid arguments: `body-margin` should be a length, `auto` or a dictionary. \nBut found: " + repr(margin),
      )
    }
  }
}

#let get-body-margin(
  rel-level,
  curr-level,
  level-item,
  body-margin-f,
  body-margin-f-e,
  body-margin-f-item,
  args-with-tags,
  args-with-tags-item,
) = {
  let body-margin-f = parse-body-margin(rel-level, body-margin-f, ..args-with-tags)
  let body-margin-f-e = parse-body-margin(curr-level, body-margin-f-e, ..args-with-tags)
  let body-margin-f-item = n => parse-body-margin(level-item(n), body-margin-f-item(n), ..args-with-tags-item)
  return (n, ..more-args) => {
    return get-none-value(body-margin-f(n, ..more-args), get-none-value(
      body-margin-f-e(n, ..more-args),
      body-margin-f-item(n)(n, ..more-args),
    ))
  }
}

