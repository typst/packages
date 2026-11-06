#import "../util/parse-args.typ": *
#import "../foundation/label-format.typ": get-label-width-info, pre-parse-label-width
#import "../util/identifier.typ": same-line-next-term-ID
#import "../lib/par-lib.typ": disable-par

#let desc-keys = (
  "separator", // content
  "prefix", // content
  "suffix", // content
  "style", // horizontal, stacked, plain, hanging, auto
  // "marker", // TODO
  // "numbering", // TODO
  "hanging-indent", // length
  "enable-first-par", // bool
  "term-width", // dict
  "term-align", // alignment
  "checklist", // bool
)

#let DescStyle = (
  "horizontal": "horizontal",
  "stacked": "stacked",
  "plain": "plain",
  "hanging": "hanging",
)


#let parse-description-config(description-config, level, ..args) = {
  let format = none
  let term-format = none
  let description-format = none
  let format-dic = (:)
  let desc-style = none
  let desc-term-width = none
  if type(description-config) == dictionary {
    format = description-config.remove("format", default: none)
    term-format = description-config.remove("term-format", default: none)
    description-format = description-config.remove("description-format", default: none)
    desc-style = description-config.remove("style", default: none)
    desc-term-width = description-config.remove("term-width", default: none)
    format-dic = description-config
  } else {
    format = description-config
  }
  format = parse-format-func(format, ..args)(level)
  term-format = parse-format-func(term-format, ..args)(level)
  description-format = parse-format-func(description-format, ..args)(level)

  format-dic = parse-format-with(format-dic, level, ..args, fmt-args: desc-keys)
  desc-style = parse-general-func-with-level-n(desc-style, auto, auto, ..args)(level)
  desc-term-width = parse-general-func-with-level-n(desc-term-width, auto, auto, ..args)(level)
  return (format, term-format, description-format, desc-style, desc-term-width, format-dic)
}


#let get-description-setting(
  description-config,
  elem-description-config,
  item-description-config,
  rel-level,
  curr-level,
  level-item,
  ..args,
) = {
  let (
    format-f,
    term-format-f,
    description-format-f,
    desc-style-f,
    desc-term-width-f,
    format-dic-f,
  ) = parse-description-config(
    description-config,
    rel-level,
    ..args,
  )
  let (
    format-f-e,
    term-format-f-e,
    description-format-f-e,
    desc-style-f-e,
    desc-term-width-f-e,
    format-dic-f-e,
  ) = parse-description-config(
    elem-description-config,
    curr-level,
    ..args,
  )
  let (
    format-f-item,
    term-format-f-item,
    description-format-f-item,
    desc-style-f-item,
    desc-term-width-f-item,
    format-dic-f-item,
  ) = {
    let all-format = n => parse-description-config(
      item-description-config(n),
      level-item(n),
      ..args,
    )
    let len = 6
    for i in range(len) {
      (n => all-format(n).at(i),)
    }
  }
  let desc-style = (n, ..more-args) => get-none-value(desc-style-f(n, ..more-args), get-none-value(
    desc-style-f-e(n, ..more-args),
    desc-style-f-item(n)(n, ..more-args),
  ))

  // TODO
  let desc-term-width = (n, ..more-args) => get-none-value(desc-term-width-f(n, ..more-args), get-none-value(
    desc-term-width-f-e(n, ..more-args),
    desc-term-width-f-item(n)(n, ..more-args),
  ))

  let format-dic = (n, ..more-args) => (
    format-dic-f(n, ..more-args) + format-dic-f-e(n, ..more-args) + format-dic-f-item(n)(n, ..more-args)
  )

  let term-format = n => (body, ..more-args) => term-format-f(n)(
    term-format-f-e(n)(term-format-f-item(n)(n)(body, ..more-args), ..more-args),
    ..more-args,
  )
  let description-format = n => (body, ..more-args) => description-format-f(n)(
    description-format-f-e(n)(description-format-f-item(n)(n)(body, ..more-args), ..more-args),
    ..more-args,
  )

  let format = n => (body, ..more-args) => format-f(n)(
    format-f-e(n)(format-f-item(n)(n)(body, ..more-args), ..more-args),
    ..more-args,
  )

  return (format-dic, term-format, description-format, desc-style, desc-term-width, format)
}


#let style-allowed-keys = DescStyle.keys()

#let parse-description-format-dic(
  index,
  format-dic,
  desc-style,
  ..more-args,
) = {
  let curr-style = get-default-value(desc-style(index), none, auto)

  curr-style = get-auto-value(curr-style, DescStyle.plain)
  assert(
    curr-style in style-allowed-keys,
    message: "The `style` should be `auto`, or the following strings: "
      + style-allowed-keys.map(s => "\"" + s + "\"").join(", ", last: " and ")
      + "."
      + "\nBut found: "
      + repr(curr-style)
      + ".",
  )
  let curr-format-dic = format-dic(index, style: curr-style, ..more-args)

  let prefix = curr-format-dic.at("prefix", default: [])
  let suffix = curr-format-dic.at("suffix", default: [])
  assert(
    type(prefix) == content,
    message: "The `prefix` should be a content." + "\nBut found: " + repr(type(prefix)) + ".",
  )
  assert(
    type(suffix) == content,
    message: "The `suffix` should be a content." + "\nBut found: " + repr(type(suffix)) + ".",
  )

  let desc-hanging-indent = curr-format-dic.at("hanging-indent", default: auto)
  if desc-hanging-indent == auto {
    desc-hanging-indent = if curr-style == DescStyle.hanging { 2em } else { 0pt }
  }
  assert(
    type(desc-hanging-indent) == length,
    message: "The `hanging-indent` should be a length." + "\nBut found: " + repr(desc-hanging-indent) + ".",
  )
  desc-hanging-indent = desc-hanging-indent.to-absolute()

  let separator = curr-format-dic.at("separator", default: auto) // prefix-sep, suffix-sep
  let sep-dic = (prefix: [], suffix: [])
  if type(separator) == dictionary {
    sep-dic.prefix = separator.remove("prefix", default: [])
    sep-dic.suffix = separator.remove("suffix", default: [])
    assert(
      type(sep-dic.prefix) == content,
      message: "The the value of `prefix` should be a content." + "\nBut found: " + repr(sep-dic.prefix) + ".",
    )
    assert(
      type(sep-dic.suffix) == content,
      message: "The the value of `suffix` should be a content." + "\nBut found: " + repr(sep-dic.suffix) + ".",
    )
    assert(
      separator == (:),
      message: "The `separator` should be a dictionary with keys `prefix` and `suffix`."
        + "\nBut found: "
        + repr(separator)
        + ".",
    )
  } else {
    if separator == auto {
      if curr-style == DescStyle.stacked {
        separator = []
      } else {
        separator = [#h(.6em)#h(0pt, weak: true)]
      }
    }
    assert(
      type(separator) == content,
      message: "The `separator` should be a content or `auto`." + "\nBut found: " + repr(separator) + ".",
    )
    sep-dic.prefix = separator
  }

  let enable-strong-par = curr-format-dic.at("enable-first-par", default: auto)
  if enable-strong-par == auto {
    enable-strong-par = (curr-style == DescStyle.stacked)
  }
  assert(
    type(enable-strong-par) == bool,
    message: "The `enable-strong-par` should be a bool or `auto`." + "\nBut found: " + repr(enable-strong-par) + ".",
  )

  // let pre-term-width = curr-format-dic.at("term-width", default: auto)

  let term-align = curr-format-dic.at("term-align", default: auto)
  term-align = get-auto-value(term-align, start)
  assert(
    type(term-align) == alignment,
    message: "The `term-align` should be an alignment." + "\nBut found: " + repr(term-align) + ".",
  )

  let checklist = curr-format-dic.at("checklist", default: false)
  assert(
    type(checklist) == bool,
    message: "The `checklist` should be a bool." + "\nBut found: " + repr(checklist) + ".",
  )

  return (
    style: curr-style,
    prefix: prefix,
    suffix: suffix,
    desc-hanging-indent: desc-hanging-indent,
    separator: sep-dic,
    enable-strong-par: enable-strong-par,
    term-align: term-align,
    checklist: checklist,
  )
}

#let get-checklist-text(body) = {
  if (
    body.func() == func-seq
      and body.children.len() == 3
      and (body.children.at(0) == [#"["] and body.children.at(2) == [#"]"])
  ) {
    return body.children.at(1)
  } else {
    return none
  }
}

#let parse-description(
  desc-items: (),
  format-dic: (:),
  term-format: _ => none,
  description-format: _ => none,
  desc-style: _ => none,
  term-width: _ => none,
  checklist-args: (:),
) = {
  let desc-index = for (n, desc) in desc-items.enumerate() {
    if desc != none {
      (n,)
    }
  }

  if desc-index == none {
    return none
  }

  let pos-index = desc-index.enumerate()

  let pre-term-width-args = (term-width: (current: 0pt, max: 0pt))
  let desc-config-dic = n => parse-description-format-dic(n, format-dic, desc-style, ..pre-term-width-args)
  let desc-config-array = desc-index.map(n => desc-config-dic(n))

  let desc-config-args = pos => desc-config-array.at(pos)

  let symbol-func = checklist-args.at("symbol-func", default: none)
  let checklist-n = pos => desc-config-args(pos).checklist
  desc-items = pos-index.map(((pos, n)) => {
    let (term, description) = desc-items.at(n)
    if checklist-n(pos) {
      let marker-text = get-checklist-text(term)
      if marker-text != none {
        let marker-info = symbol-func(marker-text)
        if marker-info != none {
          let (checklist-marker, checklist-format) = marker-info
          if checklist-marker != none {
            term = checklist-marker
            if checklist-format != none { description = checklist-format(description) }
          }
        }
      }
    }
    (term, description)
  })

  let terms-item = pos-index.map(((pos, n)) => {
    let (term, description) = desc-items.at(pos)
    let (style, prefix, separator) = desc-config-args(pos)
    let term-body = term-format(n)(term, style: style, ..pre-term-width-args)
    (
      prefix: prefix,
      separator: separator,
      style: style,
      term-body: term-body,
    )
  })

  let horizontal-items-width = (
    terms-item
      .filter(e => e.style == DescStyle.horizontal)
      .map(e => {
        let term = {
          e.prefix
          e.term-body
          e.separator.prefix
        }
        measure(term).width
      })
      + (0pt,)
  )

  let hanging-items-width = (
    terms-item
      .filter(e => e.style == DescStyle.hanging)
      .map(e => {
        let term = {
          e.prefix
          e.term-body
          e.separator.prefix
        }
        measure(term).width
      })
      + (0pt,)
  )

  let plain-items-width = (
    terms-item
      .filter(e => e.style == DescStyle.plain)
      .map(e => {
        let term = {
          e.prefix
          e.term-body
          e.separator.prefix
        }
        measure(term).width
      })
      + (0pt,)
  )

  let horizontal-items-max-width = calc.max(..horizontal-items-width)
  let plains-items-max-width = calc.max(..plain-items-width)
  let hanging-items-max-width = calc.max(..hanging-items-width)

  // parse term-with
  let style = pos => desc-config-args(pos).style
  let unknown-max-width = pos => {
    if style(pos) == DescStyle.horizontal {
      return horizontal-items-max-width
    } else if style(pos) == DescStyle.hanging {
      return hanging-items-max-width
    } else if style(pos) == DescStyle.plain {
      return plains-items-max-width
    } else {
      return auto // TODO
    }
  }
  let curr-label-width = pre-parse-label-width(term-width, unknown-max-width)
  let user-term-width = pos => {
    let _width-f = curr-label-width(pos, style: style(pos))
    let (amount, style) = if _width-f == none {
      // default (do not set by user)
      (auto, "native")
    } else {
      _width-f
    }
    let curr-item = terms-item.at(pos)
    let curr-term = {
      curr-item.prefix
      curr-item.term-body
      curr-item.separator.prefix
    }
    let curr-width = measure(curr-term).width
    let term-width = get-label-width-info(
      amount,
      style,
      curr-width,
      unknown-max-width(pos),
    )
    term-width
  }

  let desc-info = pos-index.map(((pos, n)) => {
    let (term, description) = desc-items.at(pos)
    let term-width = user-term-width(pos)
    let term-width-args = (term-width: (current: term-width.width, max: term-width.max-width))
    let (style, ..other) = parse-description-format-dic(n, format-dic, desc-style, ..term-width-args)

    let term-body = term-format(n)(term, style: style, ..term-width-args)
    let description-body = description-format(n)(description, style: style, ..term-width-args)

    (
      ..other,
      style: style,
      term-width: term-width,
      term-body: term-body,
      description-body: description-body,
    )
  })

  return n => {
    let pos = desc-index.position(it => it == n)
    if pos == none {
      return (:)
    } else {
      return desc-info.at(pos)
    }
  }
}


#let process-terms-item(
  desc-info: none,
  format: _ => none,
  process-par: it => it,
  start-margin: 0pt,
  dir: "left",
  dir-rev: "right",
) = {
  return (n, ..more-args) => doc => {
    if desc-info == none {
      return doc
    }
    let desc-info-n = desc-info(n)
    if desc-info-n == (:) {
      return doc
    }
    let (
      term-body,
      description-body,
      style,
      prefix,
      suffix,
      separator,
      desc-hanging-indent,
      enable-strong-par,
      term-width,
      term-align,
    ) = desc-info-n
    let whole-term = {
      prefix
      term-body
      separator.prefix
    }
    let whole-description = {
      separator.suffix
      description-body
      suffix
    }
    let item-body = if style == DescStyle.plain {
      show: pad
      show: process-par.with(enable-strong-par: enable-strong-par)
      if term-width.auto-width {
        // TODO: not correct for rtl??? see also native `terms`???
        // add `box`???
        whole-term
      } else {
        label-box(
          {
            set align(term-align)
            whole-term
          },
          width: term-width.width,
        )
      }
      whole-description
    } else if style == DescStyle.stacked {
      show: pad
      show: process-par.with(enable-strong-par: enable-strong-par)
      {
        set align(term-align)
        whole-term
      }
      parbreak()
      whole-description
    } else if style == DescStyle.hanging {
      pad(..(str(dir): (desc-hanging-indent)), {
        show: process-par.with(enable-strong-par: enable-strong-par, my-first-line-inset: -desc-hanging-indent)
        if term-width.auto-width {
          // TODO: not correct for rtl??? see also native `terms`???
          // add `box`???
          whole-term
        } else {
          label-box(
            {
              set align(term-align)
              whole-term
            },
            width: term-width.width,
          )
        }
        whole-description
      })
    } else if style == DescStyle.horizontal {
      let margin-inset = term-width.width - term-width.amount
      layout(size => {
        let body-width = size.width - term-width.width
        if body-width < 0pt {
          body-width = 0pt
        }
        let has-baseline = (
          get-first-line-height-in-box(width: body-width, {
            whole-description
            block(height: 0pt, below: 0pt, above: 0.01pt)
          }).at(0)
            != 0pt
        )
        let func-body(bodyA, bodyB) = if has-baseline {
          bodyA
          bodyB
        } else {
          let stack-dir = if dir == "left" { ltr } else { rtl }
          stack(dir: stack-dir, bodyA, bodyB)
        }
        func-body(
          label-box(
            width: calc.min(size.width, term-width.width),
            inset: (str(dir): start-margin, str(dir-rev): -start-margin),
            {
              show: disable-par
              set align(term-align)
              prefix
              term-body
              separator.prefix
            },
          ),
          label-box(width: body-width, inset: (str(dir): (desc-hanging-indent - margin-inset)), {
            show: process-par.with(
              enable-strong-par: enable-strong-par,
              my-first-line-inset: -desc-hanging-indent + margin-inset,
            )
            whole-description
          }),
        )
      })
    } // others: use-defined style (item-body: none)

    let desc-body-format = body => format(n)(
      body,
      term: term-body,
      description: description-body,
      separator: separator,
      prefix: prefix,
      suffix: suffix,
      hanging-indent: desc-hanging-indent,
      style: style,
      enable-first-par: enable-strong-par,
      term-align: term-align,
      term-width: (current: term-width.width, max: term-width.max-width),
      process-par: process-par, // for advanced usage
      dir: dir, // for advanced usage
    )

    show terms.item.where(label: same-line-next-term-ID): it => {
      desc-body-format(item-body)
    }
    doc
  }
}
