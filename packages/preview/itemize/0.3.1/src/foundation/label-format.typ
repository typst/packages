#import "../util/parse-args.typ": *

#let get-label-text-args(
  rel-level,
  curr-level,
  level-item,
  text-args: (:),
  text-args-elem: (:),
  text-args-item: _ => (:),
  args-with-tags,
  args-with-tags-item,
) = {
  let curr-text-args = parse-text-args(..text-args, rel-level, args: args-with-tags)
  let elem-text-args = parse-text-args(..text-args-elem, curr-level, args: args-with-tags)
  let item-text-args = n => parse-text-args(
    ..text-args-item(n),
    level-item(n),
    args: args-with-tags-item,
  )
  (n, ..more-args) => (
    curr-text-args(n, ..more-args) + elem-text-args(n, ..more-args) + item-text-args(n)(n, ..more-args)
  )
}

/// Define label border arguments for styling (ver0.3.0)
#let label-border-args = ("stroke", "radius", "outset", "fill", "inset", "clip", "width-style", "height-style", "align")

#let parse-label-format(label-format, level, ..args) = {
  let border = (:)
  let format = none
  if type(label-format) == dictionary {
    let label-format = label-format
    format = label-format.remove("format", default: none)
    border = label-format
  } else {
    format = label-format
  }
  format = parse-format-func(format, ..args)(level)
  border = parse-format-with(border, level, ..args, fmt-args: label-border-args)

  return (border, format)
}


#let get-label-format(
  label-format,
  elem-label-format,
  item-label-format,
  rel-level,
  curr-level,
  level-item,
  args-with-tags,
  args-with-tags-item,
) = {
  let (border-f, format-f) = parse-label-format(label-format, rel-level, ..args-with-tags)
  let (border-f-e, format-f-e) = parse-label-format(
    elem-label-format,
    curr-level,
    ..args-with-tags,
  )
  let body-format-item = n => parse-label-format(
    item-label-format(n),
    level-item(n),
    ..args-with-tags-item,
  )
  (
    (n, ..more-args) => (
      border-f(n, ..more-args) + (border-f-e)(n, ..more-args) + body-format-item(n).at(0)(n, ..more-args)
    ),
    n => (body, ..more-args) => {
      let f-item = body-format-item(n).at(1)
      format-f(n)(format-f-e(n)(f-item(n)(body, ..more-args), ..more-args), ..more-args)
    },
  )
}


#let get-label-user-style(user-style, info, real-length, label-length, inset) = {
  let amount = label-length
  let stretched = false
  if user-style != none {
    if type(user-style) == dictionary {
      let user-style = user-style
      amount = user-style.remove("amount", default: "real-" + info)
      stretched = user-style.remove("stretched", default: false)
      assert(user-style == (:), message: "The key of `" + info + "-style` should be: amount and stretched.")
    } else {
      amount = user-style
    }
    if amount == "real-" + info {
      amount = real-length
    } else if amount == "label-" + info {
      amount = label-length
    } else if type(amount) in length-type {
      let (amount-ratio, amount-abs) = parse-relative(amount)
      amount = amount-abs.to-absolute() + amount-ratio * real-length
    } else {
      if info == "width" {
        panic(
          "The value of `width-style` should be the following string: \"real-width\", \"label-width\", or relative.",
        )
      } else if info == "height" {
        panic(
          "The value of `height-style` should be the following string: \"real-height\", or relative.",
        )
      }
    }
    assert(type(stretched) == bool, message: "The value of `stretched` should be a bool.")
  }
  return ("label-" + info + "-amount": amount + inset, "label-" + info + "-stretched": stretched)
}

/// Parse label width and height style configuration
#let parse-label-width-and-height-style(
  width-style,
  height-style,
  real-width,
  box-width,
  real-height,
  x-inset,
  y-inset,
) = {
  return (
    get-label-user-style(width-style, "width", real-width, box-width, x-inset)
      + get-label-user-style(height-style, "height", real-height, real-height, y-inset)
  )
}


#let get-label-label-width-and-height-style(
  label-border,
  curr-width,
  real-box-width,
  real-box-height,
) = {
  let label-border = label-border
  let (label-border-inset, label-border-align, label-width-style, label-height-style) = {
    if label-border != none {
      (
        label-border.at("inset", default: none),
        label-border.remove("align", default: none),
        label-border.remove("width-style", default: none),
        label-border.remove("height-style", default: none),
      )
    } else {
      (none, none, none, none)
    }
  }
  let (_label-inset-top, _label-inset-bottom, _label-inset-left, _label-inset-right) = if (
    label-border-inset != none
  ) {
    for dir in ("top", "bottom") {
      let _inset = get-dir-inset(label-border-inset, dir: dir)
      let (_inset-ratio, _inset-abs) = parse-relative(_inset)
      (_inset-abs.to-absolute() + _inset-ratio * real-box-height,)
    }
    for dir in ("left", "right") {
      let _inset = get-dir-inset(label-border-inset, dir: dir)
      let (_inset-ratio, _inset-abs) = parse-relative(_inset)
      (_inset-abs.to-absolute() + _inset-ratio * real-box-width,)
    }
  } else { (0pt, 0pt, 0pt, 0pt) }

  // width-and-height-style
  let x-inset = _label-inset-left + _label-inset-right
  let y-inset = _label-inset-top + _label-inset-bottom

  let (
    label-width-amount,
    label-width-stretched,
    label-height-amount,
    label-height-stretched,
  ) = parse-label-width-and-height-style(
    label-width-style,
    label-height-style,
    curr-width,
    real-box-width,
    real-box-height,
    x-inset,
    y-inset,
  )
  return (
    label-border,
    label-border-align,
    label-width-amount,
    label-width-stretched,
    label-height-amount,
    label-height-stretched,
  )
}


#let LabelWidthStyle = (
  "default": "default",
  "constant": "constant",
  "auto": "auto",
  "native": "native",
)

#let allowed-label-width-style = LabelWidthStyle.keys()

#let pre-parse-label-width(width-f, max-width) = {
  let max-width-f = if type(max-width) == function {
    max-width
  } else {
    n => max-width
  }
  return (n, ..more-args) => {
    let max-width = max-width-f(n)
    let width = width-f(n, ..more-args)
    if width == none {
      return none
    }
    if width in (auto, none) {
      return (amount: auto, style: LabelWidthStyle.native)
    }
    let _type = type(width)
    let amount
    let style
    if _type == dictionary {
      amount = width.remove("amount", default: auto)
      style = width.remove("style", default: LabelWidthStyle.default)
      assert(width == (:), message: "The key of `label-width` should be: amount and style.")
      assert(
        amount == auto or type(amount) in length-type or amount == "max",
        message: "`amount` should be a length, `auto` or a string \"max\"." + "\nBut found: " + repr(amount) + ".",
      )
      assert(
        style in allowed-label-width-style,
        message: "Unknown style. Expected one of the following strings: "
          + allowed-label-width-style.map(it => "\"" + it + "\"").join(", ", last: " and ")
          + "."
          + "\nBut found: "
          + repr(style)
          + ".",
      )
    } else if _type in length-type or width == "max" {
      style = LabelWidthStyle.default
      amount = width
    } else {
      panic(
        "`label-width` should be a length, `auto`, a string \"max\", or a dictionary with keys: `amount` and `style`."
          + "\nBut found: "
          + repr(width)
          + ".",
      )
    }
    if amount == "max" { amount = max-width }
    return (amount: amount, style: style)
  }
}

#let parse-label-width(label-width, max-width, level, ..args) = {
  let width-f = parse-general-func-with-level-n(label-width, auto, auto, ..args)(level)
  return pre-parse-label-width(width-f, max-width)
}


#let get-label-width-info(
  amount,
  style,
  curr-width,
  number-max-width,
) = {
  if amount != auto {
    let (amount-ratio, amount-abs) = parse-relative(amount)
    amount = amount-abs.to-absolute() + curr-width * amount-ratio
  }
  let max-width = if amount == auto { curr-width } else { amount }

  let number-width = if style == LabelWidthStyle.native {
    // minor change (ver0.3.0): when style is "native", amount is always set to number-max-width
    max-width = number-max-width
    number-max-width
  } else if amount != auto {
    if style == LabelWidthStyle.default {
      if curr-width <= amount { amount } else { curr-width }
    } else if style == LabelWidthStyle.constant {
      amount
    } else if style == LabelWidthStyle.auto {
      curr-width
    }
  } else { max-width }

  return (width: number-width, amount: max-width, auto-width: amount == auto, max-width: max-width)
}

#let get-label-width(
  rel-level,
  curr-level,
  level-item,
  label-width-f,
  label-width-f-e,
  label-width-f-item,
  number-max-width,
  args-with-tags,
  args-with-tags-item,
) = {
  let width-f = parse-label-width(
    label-width-f,
    number-max-width,
    rel-level,
    ..args-with-tags,
  )
  let width-f-e = parse-label-width(
    label-width-f-e,
    number-max-width,
    curr-level,
    ..args-with-tags,
  )
  let width-f-item = n => parse-label-width(
    label-width-f-item(n),
    number-max-width,
    level-item(n),
    ..args-with-tags-item,
  )
  return (n, ..more-args) => get-none-value(width-f(n, ..more-args), get-none-value(
    width-f-e(n, ..more-args),
    width-f-item(n)(n, ..more-args),
  ))
}

#let get-label-length-info(
  len,
  numbers-width,
  styled-numbers,
  curr-label-width,
  number-max-width,
  label-border-f,
  ..args,
) = {
  return range(len).map(i => {
    let curr-width = numbers-width.at(i).to-absolute()
    let styled-child-number = styled-numbers.at(i)

    let (amount, style) = curr-label-width(i, max-width: number-max-width, width: curr-width)

    // enum'number width (label)
    let number-width = get-label-width-info(
      amount,
      style,
      curr-width,
      number-max-width,
    )
    let real-box-width = number-width.width.to-absolute()
    let real-box-height = measure(width: real-box-width, styled-child-number).height.to-absolute()

    // feat (ver0.3.0): label-border
    let (
      label-border,
      label-border-align,
      label-width-amount,
      label-width-stretched,
      label-height-amount,
      label-height-stretched,
    ) = get-label-label-width-and-height-style(
      label-border-f(i),
      curr-width,
      real-box-width,
      real-box-height,
    )
    let box-width = if label-width-stretched { label-width-amount } else { real-box-width }
    let box-height = if label-height-stretched { label-height-amount } else { real-box-height }

    return (
      box-width: box-width,
      box-height: box-height,
      number-width: number-width,
      label-border: label-border,
      label-border-align: label-border-align,
      label-width-amount: label-width-amount,
      label-height-amount: label-height-amount,
    )
  })
}


// auto label width

#let AutoLabelWidth = (
  "auto": auto,
  "none": none,
  "each": "each",
  "all": "all",
  "enum": "enum",
  "list": "list",
)

#let auto-label-elem(auto-label, elem) = {
  if elem == "enum" {
    return auto-label in (AutoLabelWidth.each, AutoLabelWidth.auto, AutoLabelWidth.all, AutoLabelWidth.enum)
  } else if elem == "list" {
    return auto-label in (AutoLabelWidth.each, AutoLabelWidth.auto, AutoLabelWidth.all, AutoLabelWidth.list)
  }
  return false
}

#let parse-auto-label(auto-label-width, level, ..args) = {
  let curr-auto-label = parse-args-with-level(auto-label-width, level, ..args)
  assert(
    curr-auto-label in AutoLabelWidth.values(),
    message: "The `auto-label-width` should be `none`, `auto`, or one of the following strings: \"each\", \"all\", \"enum\", \"list\"."
      + "\nBut found: "
      + repr(curr-auto-label)
      + ".",
  )
  return curr-auto-label
}
