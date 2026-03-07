#import "identifier.typ": LOOP


/// Group an array by a function.
///
/// -> any
#let _continue-group-by(array, function) = {
  let arr = ()
  if array == () {
    return arr
  }
  let befor = function(array.first())
  let temp = ()

  for value in array {
    if function(value) {
      if befor {
        temp.push(value)
      } else {
        arr.push(temp)
        temp = ()
        temp.push(value)
      }
      befor = true
    } else {
      if not befor {
        temp.push(value)
      } else {
        arr.push(temp)
        temp = ()
        temp.push(value)
      }
      befor = false
    }
  }
  arr.push(temp)
  return arr
}


/// Get the type of an element, handling 'enum' and 'list' cases.
///
/// -> any
#let get_type-enum-or-list(elem) = {
  if elem == "enum" {
    enum
  } else if elem == "list" {
    list
  } else {
    elem
  }
}

/// Rebuild a label for an element, optionally adding a suffix.
///
/// -> any
#let rebuild-label(elem, _label) = {
  if _label == none {
    return elem
  } else {
    [#elem#_label]
  }
}


// for number-body and marker-body in order to not override
/// Define default arguments for text styling.
///
/// -> any
#let default-text-args = (
  alternates: false,
  baseline: 0pt,
  bottom-edge: "baseline",
  cjk-latin-spacing: auto,
  costs: (
    hyphenation: 100%,
    runt: 100%,
    widow: 100%,
    orphan: 100%,
  ),
  dir: auto,
  discretionary-ligatures: false,
  fallback: true,
  features: (:),
  fill: luma(0%),
  font: "libertinus serif",
  fractions: false,
  historical-ligatures: false,
  hyphenate: auto,
  kerning: true,
  lang: "en",
  ligatures: true,
  number-type: auto,
  number-width: auto,
  overhang: true,
  region: none,
  script: auto,
  size: 11pt,
  slashed-zero: false,
  spacing: 100% + 0pt,
  stretch: 100%,
  stroke: none,
  style: "normal",
  stylistic-set: (),
  top-edge: "cap-height",
  tracking: 0pt,
  weight: "regular",
)

/// Define default text styling with specified arguments.
///
/// -> any
#let default-text = text.with(
  ..default-text-args,
)

/// Get the current text arguments from an object.
///
/// -> any
#let get_current-text-args(it) = (
  alternates: it.alternates,
  baseline: it.baseline,
  bottom-edge: it.bottom-edge,
  cjk-latin-spacing: it.cjk-latin-spacing,
  costs: it.costs,
  dir: it.dir,
  discretionary-ligatures: it.discretionary-ligatures,
  fallback: it.fallback,
  features: it.features,
  fill: it.fill,
  font: it.font,
  fractions: it.fractions,
  historical-ligatures: it.historical-ligatures,
  hyphenate: it.hyphenate,
  kerning: it.kerning,
  lang: it.lang,
  ligatures: it.ligatures,
  number-type: it.number-type,
  number-width: it.number-width,
  overhang: it.overhang,
  region: it.region,
  script: it.script,
  size: it.size,
  slashed-zero: it.slashed-zero,
  spacing: it.spacing,
  stretch: it.stretch,
  stroke: it.stroke,
  style: it.style,
  stylistic-set: it.stylistic-set,
  top-edge: it.top-edge,
  tracking: it.tracking,
  weight: it.weight,
)

// in order do not override by the users using `set`
/// Define default arguments for box elements.
///
/// -> any
#let default-box-args = (
  // width: auto,
  height: auto,
  baseline: 0em,
  fill: none,
  stroke: none,
  radius: (:),
  inset: 0em,
  outset: (:),
  clip: false,
)


/// Define default arguments for block elements.
///
/// -> any
#let default-block-args = (
  // width: 100%,
  height: auto,
  fill: none,
  stroke: none,
  radius: (:),
  inset: (:),
  outset: (:),
  // spacing: relativefraction,
  above: auto,
  below: auto,
  clip: false,
  sticky: false,
  breakable: true,
)


/// Fixes the indentation issue for the first line of a paragraph.
///
/// -> any
/// Fixes the indentation issue for the first line of a paragraph.
///
/// -> any
#let fix-first-line = context {
  if par.first-line-indent.all and par.first-line-indent.amount != 0 {
    h(-par.first-line-indent.amount)
  }
}


/// Get the label of an element if it exists.
///
/// -> any
#let get_elem_label(e) = {
  return if e.has("label") { e.label } else { none }
}

/// Get a label from a string, label, or object with a text property.
///
/// -> any
#let get_label(it) = {
  return if type(it) == str {
    label(it)
  } else if type(it) == label {
    it
  } else if it.has("text") {
    label(it.text)
  } else {
    panic("The argument should be a string or a label.")
  }
}


/// Get the value at a specific index in an array, handling LOOP cases.
///
/// -> any
#let get_array-value(arr, n) = {
  // arr is an array
  if arr != () {
    let last = arr.last()
    if last == LOOP {
      let len = arr.len()
      if len == 1 {
        return ()
      } else {
        let m = calc.rem-euclid(n, len - 1)
        return arr.at(m)
      }
    } else {
      return arr.at(n, default: last)
    }
  } else {
    return arr
  }
}

/// Retrieves a value from an array based on the current nesting level.
///
/// - value: The value or array of values.
/// - level: The current nesting level.
/// -> any
#let get_depth-value(value, level) = {
  if type(value) == array {
    if value == () {
      return value
    } else {
      return get_array-value(value, level)
    }
  } else {
    return value
  }
}


/// Get the default value for a given parameter.
///
/// -> any
#let get_default-value(value, initial, default) = {
  if value == initial { default } else { value }
}
#let get_auto-value(value, default) = {
  return get_default-value(value, auto, default)
}



// form: n => value
// return : n => value
/// Get the value at a specific index in an array.
///
/// -> any
#let get_value-by-n(func, initial, default) = {
  if type(func) == function {
    // form: n => value
    return n => get_default-value(func(n + 1), initial, default)
  } else if type(func) == array {
    n => get_default-value(get_array-value(func, n), initial, default)
  } else {
    return _ => get_default-value(func, initial, default)
  }
}
// form: level => n => value
// return: n => vallue
/// Get the value at a specific depth in a nested structure.
///
/// -> any
#let get_depth-value-by-n(func, level, initial, default) = {
  if type(func) == function {
    // func: level => n => value; level => array; level => value;
    return get_value-by-n(func(level + 1), initial, default)
  } else {
    // func: array; value
    return get_value-by-n(get_depth-value(func, level), initial, default)
  }
}

/// Return a default 'none' value.
///
/// -> none
#let get_none-value(value1, value2) = {
  if value2 != none {
    return value2
  } else {
    return value1
  }
}

/// func : it => value; it => array; array; value
/// Parse a general function with a specified level of nesting.
///
/// -> any
#let parse-general-func-with-level-n(func, initial, default, ..args) = level => n => {
  if type(func) == function {
    let level-n-args = (level: level + 1, n: n + 1, ..args.named())

    // form: it => value; it => array
    return get_value-by-n(func(level-n-args), initial, default)(n)
  } else {
    // func: array; value
    return get_value-by-n(get_depth-value(func, level), initial, default)(n)
  }
}

/// Parses named arguments with support for level-based value selection.
///
/// - args: Named arguments to parse.
/// - level: The current nesting level for value selection.
/// -> arguments
#let parse-args(..args, level, n-last: 0) = {
  let dic = for (k, v) in args.named() {
    let value = parse-general-func-with-level-n(v, auto, auto, n-last)(level)
    if k in default-text-args.keys() and value != auto {
      (str(k): value)
    }
  }
  let dic-f = n => {
    if dic != none {
      for (k, v) in dic {
        if v(n) != auto {
          // (str(k): v(n))
          let value = if type(v(n)) == length { v(n).to-absolute() } else { v(n) }
          (str(k): value)
        }
      }
    } else {
      (:)
    }
  }
  return dic-f
}



/// Parse a format function for styling.
///
/// -> any
#let parse-format-func(format, ..args) = level => n => body => {
  if type(format) == function {
    // form: it => any
    return [#format(
      (level: level + 1, n: n + 1, body: body, ..args.named()),
    )]
  } else {
    let item = get_depth-value(format, level)
    if type(item) == function {
      return [#item(body)]
    } else {
      let item-n = get_value-by-n(item, none, none)(n)
      if type(item-n) == function {
        return [#item-n(body)]
      } else {
        if item-n in (none, auto, (), (:)) {
          return body
        }
        return [#item-n]
      }
    }
  }
}


/// Parse the width of a label.
///
/// -> any
#let parse-label-width(label-width, max-width, level, labels-width: (), ..args) = {
  let width-f = parse-general-func-with-level-n(label-width, auto, auto, ..args)(level)
  return n => {
    let width = width-f(n)
    if width == auto {
      return (amount: max-width, style: "native")
    }
    let _type = type(width)
    if _type == dictionary {
      let (amount, style) = width
      assert(
        amount == auto or type(amount) in (length, relative, ratio) or amount == "max" or type(amount) == function,
        message: "`amount` should be a length, `auto` or a string \"max\".",
      )
      assert(
        style in ("default", "constant", "auto", "native"),
        message: "Unknown style. The label-width's style should be one of the following strings: \"default\", \"constant\", \"auto\" and \"native\".",
      )
      if amount == "max" {
        return (amount: max-width, style: style)
      }
      if type(amount) == function {
        return (amount: amount(labels-width), style: style)
      }
      return width
    } else if _type in (length, relative, ratio) {
      return (amount: width, style: "default")
    } else {
      panic("`label-width` should be a length or `auto`.")
    }
  }
}

/// Parse general arguments with a specified level of nesting.
///
/// -> any
#let parse-general-args-with-level-n(curr-args, rel-level, enum-args, abs-level, default, ..args) = {
  let _curr-args = parse-general-func-with-level-n(curr-args, auto, default, ..args.named())(rel-level)
  let _enum-args = parse-general-func-with-level-n(enum-args, auto, default, ..args.named())(abs-level)
  return n => get_none-value(_curr-args(n), _enum-args(n))
}


/// Parse the format of an item.
///
/// -> any
#let parse-item-format(item-format, level, ..args) = {
  let outer
  let inner
  let whole
  if type(item-format) == dictionary {
    outer = item-format.at("outer", default: none)
    inner = item-format.at("inner", default: none)
    whole = item-format.at("whole", default: none)
  } else {
    outer = item-format
  }
  let outer-format = parse-format-func(outer, ..args)(level)
  let inner-format = parse-format-func(inner, ..args)(level)
  let whole-format = parse-format-func(whole, ..args)(level)
  return (outer: outer-format, inner: inner-format, whole: whole-format)
}


/// Define border arguments for styling.
///
/// -> any
#let border-args = ("stroke", "radius", "outset", "fill", "inset", "clip")


/// Parse the body format with additional parameters.
///
/// -> any
/// Parse the format of a body.
///
/// -> any
#let parse-body-format-with(format, level, ..args) = {
  let border = (:)
  if type(format) == dictionary and level >= 0 {
    for k in border-args {
      let v = format.at(k, default: (:))
      if v != (:) {
        let value = parse-general-func-with-level-n(v, auto, (:), ..args)(level)
        border.insert(k, value)
      }
    }
  }
  let border-f = n => {
    for (k, v) in border {
      if v(n) not in ((:), none) {
        (str(k): v(n))
      }
    }
  }
  return border-f
}

/// Parse the text format of a body with additional parameters.
///
/// -> any
#let parse-body-text-format-with(format, level, ..args) = {
  let style = (:)
  // text
  if format not in (none, (), (:)) {
    // let style-format = format.at("style", default: (:))
    for k in default-text-args.keys() {
      let v = format.at(k, default: auto)
      if v != auto {
        let value = parse-general-func-with-level-n(v, auto, none, ..args)(level)
        style.insert(k, value)
      }
    }
  }
  let style-f = n => {
    for (k, v) in style {
      if v(n) != none {
        // (str(k): v(n))
        let value = if type(v(n)) == length { v(n).to-absolute() } else { v(n) }
        (str(k): value)
      }
    }
  }
  return style-f
}

/// Parse the format of a body.
///
/// -> any
#let parse-body-format(body-format, level, ..args) = {
  let border = (outer: _ => (:), inner: _ => (:), whole: _ => (:))
  let style = _ => (:)
  // assert(body-format != none and type(body-format) == dictionary)

  if type(body-format) == dictionary {
    let outer = body-format.at("outer", default: none)
    let inner = body-format.at("inner", default: none)
    let whole = body-format.at("whole", default: none)

    let text-style = body-format.at("style", default: none)

    if outer == none and inner == none and whole == none {
      outer = body-format
    }

    border.outer = parse-body-format-with(outer, level, ..args)
    border.inner = parse-body-format-with(inner, level, ..args)
    border.whole = parse-body-format-with(whole, level, ..args)

    style = parse-body-text-format-with(text-style, level)
  }

  return (border, style)
}


/// Display text with specified formatting.
///
/// -> any
#let show-text(args, body) = {
  if args not in (none, (:)) {
    set text(..args)
    body
  } else {
    body
  }
}

/// Parse inset values excluding the left inset.
///
/// -> any
#let parse-inset-without-left(inset) = {
  // `relative` and `ratio` are not supported yet. Use `length` instead.
  if type(inset) in (length, relative, ratio) {
    return (rest: inset)
  } else if type(inset) == dictionary {
    let _ = inset.remove("left", default: none)
    return inset
  } else {
    panic("Invalid arguments.")
  }
}


/// Get the baseline value with specified style.
///
/// -> any
#let get-basline-with-style(same-line-style, prev-label-height, curr-label-height, curr-baseline) = {
  if same-line-style == "center" {
    curr-baseline + (prev-label-height - curr-label-height) * 0.5
  } else if same-line-style == "top" {
    curr-baseline + (prev-label-height - curr-label-height)
  } else if same-line-style == "bottom" {
    curr-baseline
  }
  // "alone"
}

/// Parse the baseline value.
///
/// -> any
#let parse-baseline(baseline, number, text-style) = {
  let label-height = measure(number).height.to-absolute()
  let text-height = 0pt
  let base-align = top
  let alone = false
  let amount
  let same-line-style = "bottom"
  if type(baseline) == dictionary {
    amount = baseline.at("amount", default: none)
    same-line-style = baseline.at("same-line-style", default: "center")
    alone = baseline.at("alone", default: false)
    if amount == none {
      panic("The legel keys are: `amount`, `same-line-style` and `alone`, and the values are not `none`.")
    }
    // if amount not in (length, relative, ratio, "center", "top", "bottom") {
    //   panic(
    //     "The value of amount should be: `length`, `relative`, `ratio`; or one of the following strings: \"center\", \"top\", \"bottom\".",
    //   )
    // }
    assert(
      type(amount) in (length, relative, ratio) or amount in ("center", "top", "bottom") or amount == auto,
      message: "The value of amount should be: `length`, `relative`, `ratio`, `auto`; or one of the following strings: \"center\", \"top\", \"bottom\".",
    )
    assert(
      same-line-style in ("center", "top", "bottom"),
      message: "The value of the key `same-line-style` should be one of the following strings: \"center\", \"top\", \"bottom\".",
    )
    assert(
      type(alone) == bool,
      message: "The value of the key `alone` should be a bool.",
    )
  } else {
    amount = baseline
  }
  // panic(amount)
  if amount == auto {
    amount = 0pt
  } else if amount == "center" {
    base-align = horizon
    text-height = measure(show-text(text-style, [A])).height.to-absolute()
    let body-baseline = text-style.at("baseline", default: 0pt).to-absolute()
    amount = (label-height - text-height) * .5 + body-baseline
  } else if amount == "top" {
    let body-baseline = text-style.at("baseline", default: 0pt)
    text-height = measure(show-text(text-style, [A])).height.to-absolute().to-absolute()
    amount = label-height - text-height + body-baseline
  } else if amount == "bottom" {
    let body-baseline = text-style.at("baseline", default: 0pt).to-absolute()
    base-align = bottom
    amount = 0pt + body-baseline
  } else {
    assert(
      type(amount) in (length, relative, ratio),
      message: "The value of `label-baseline` should be: `length`, `relative`, `ratio`, `auto`; or one of the following strings: \"center\", \"top\", \"bottom\".",
    )
  }
  return (amount, same-line-style, base-align, alone, label-height)
}

/// Define default formatting arguments for an element.
///
/// -> any
#let default-elem-format-args = (
  "indent",
  "body-indent",
  "label-indent",
  "is-full-width",
  "item-spacing",
  "enum-spacing",
  "enum-margin",
  "hanging-indent",
  "line-indent",
  "label-width",
  "body-format",
  "label-format",
  "item-format",
  "label-align",
  "label-baseline",
)

/// Parse arguments for an element.
///
/// -> any
#let parse-elem-args(elem-args: (:)) = {
  if type(elem-args) == dictionary {
    for k in default-elem-format-args {
      let value = elem-args.at(k, default: none)
      (str(k): value)
    }
    // text args
    let dic = for k in default-text-args.keys() {
      let v = elem-args.at(k, default: none)
      if v != none {
        (str(k): v)
      }
    }
    (text-args: arguments(..dic))
  } else {
    for k in default-elem-format-args {
      (str(k): none)
    }
    (text-args: none)
  }
}


