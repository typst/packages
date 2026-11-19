#import "basic-tool.typ": *

// #let pre-parse-fields-with-n(n, ..args, only-fields: ()) = {
//   let returned-fields = (:)
//   if only-fields == () {
//     for (k, v) in args.named() {
//       if type(v) == function {
//         returned-fields.insert(k, v(n))
//       } else {
//         returned-fields.insert(k, v)
//       }
//     }
//     return returned-fields
//   } else {
//     // allow-fields
//     returned-fields = args.named()
//     for k in only-fields {
//       let v = returned-fields.remove(k, default: none)
//       if v != none {
//         returned-fields.insert(k, v(n))
//       }
//     }
//     return returned-fields
//   }
// }

/// Processes tag arguments before element parsing, converting tag functions to values.
#let pre-parse-tag(n, ..args) = {
  let name-args = args.named()
  let tag = name-args.remove("tag", default: none)
  if tag != none { name-args.insert("tag", tag(n)) }
  // number (only for enum)
  let number = name-args.remove("number", default: none)
  if number != none { name-args.insert("number", number(n)) }
  // marker (only for list)
  let marker = name-args.remove("marker", default: none)
  if marker != none { name-args.insert("marker", marker(n)) }
  return name-args
  // return pre-parse-fields-with-n(n, ..args, only-fields: ("tag", "number", "marker"))
}

/// Parse a general function with a specified level and index of nesting
#let parse-general-func-with-level-n(func, initial, default, ..args) = level => (n, ..more-args) => {
  if type(func) == function {
    let level-n-args = (level: level + 1, n: n + 1, ..pre-parse-tag(n, ..args), ..more-args.named())
    // form: it => value; it => array
    return get-value-by-n(func(level-n-args), initial, default)(n)
  } else {
    // func: array; value
    return get-value-by-n(get-depth-value(func, level), initial, default)(n)
  }
}

/// Parses text arguments with nesting level support
#let parse-text-args(..text-args, level, args: (:)) = {
  let dic = for (k, v) in text-args.named() {
    if k in default-text-args.keys() {
      let value = parse-general-func-with-level-n(v, auto, auto, ..args)(level)
      if value != auto {
        (str(k): value)
      }
    }
  }
  let dic-f = (n, ..more-args) => {
    if dic != none {
      for (k, v) in dic {
        if v(n, ..more-args) != auto {
          let value = if type(v(n, ..more-args)) == length { v(n, ..more-args).to-absolute() } else {
            v(n, ..more-args)
          }
          (str(k): value)
        }
      }
    } else {
      (:)
    }
  }
  return dic-f
}


/// Parse a format function for styling
#let parse-format-func(format, ..args) = level => n => (body, ..more-args) => {
  if type(format) == function {
    // form: it => any
    return [#format(
      (level: level + 1, n: n + 1, body: body, ..pre-parse-tag(n, ..args), ..more-args.named()),
    )]
  } else {
    let item = get-depth-value(format, level)
    if type(item) == function {
      return [#item(body)]
    } else {
      let item-n = get-value-by-n(item, none, none)(n)
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


/// Parse arguments with specified nesting level
#let parse-args-with-level(args, level, ..other-args) = {
  if type(args) == function {
    return args((level: level + 1, ..other-args.named()))
  } else {
    return get-depth-value(args, level)
  }
}

/// Parse general arguments with a specified level of nesting
#let parse-general-args-with-level(curr-args, rel-level, enum-args, abs-level, ..args) = {
  let _enum-args = parse-args-with-level(enum-args, abs-level, ..args)
  if _enum-args != none {
    _enum-args
  } else {
    parse-args-with-level(curr-args, rel-level, ..args)
  }
}


/// Parse general arguments with a specified level of nesting and an index
#let parse-general-args-with-level-n(curr-args, rel-level, enum-args, abs-level, default, ..args) = {
  let _curr-args = parse-general-func-with-level-n(curr-args, auto, default, ..args)(rel-level)
  let _enum-args = parse-general-func-with-level-n(enum-args, auto, default, ..args)(abs-level)
  let item-pos = args.pos()
  let _item-args = if item-pos.len() >= 2 {
    let (item-args, item-level) = item-pos
    n => parse-general-func-with-level-n(item-args(n), auto, default, ..args)(item-level(n))
  } else {
    n => n => none
  }
  return n => get-none-value(_curr-args(n), get-none-value(_enum-args(n), _item-args(n)(n)))
}

/// Processes format configurations with fmt-args arguments
#let parse-format-with(format, level, ..args, fmt-args: ()) = {
  let fmt = (:)
  if type(format) == dictionary {
    if format != (:) {
      for k in fmt-args {
        let v = format.remove(k, default: (:))
        if v != (:) {
          let value = parse-general-func-with-level-n(v, auto, (:), ..args)(level)
          fmt.insert(k, value)
        }
      }
      assert(
        format == (:),
        message: "The valid keys are: "
          + fmt-args.join(", ")
          + ".\nBut found invalid keys: "
          + format.keys().join(", ")
          + ".",
      )
    }
  }

  return (n, ..more-args) => {
    for (k, v) in fmt {
      let value = v(n, ..more-args.named())
      if value not in ((:), none) {
        (str(k): value)
      }
    }
    (:)
  }
}

/// Parse text formatting arguments for body content
#let parse-body-text-format-with(format, level, ..args) = {
  let style = (:)
  // text
  if format not in (none, (), (:)) {
    if format != (:) {
      for k in default-text-args.keys() {
        let v = format.remove(k, default: auto)
        if v != auto {
          let value = parse-general-func-with-level-n(v, auto, none, ..args)(level)
          style.insert(k, value)
        }
      }
      assert(
        format == (:),
        message: "The valid keys are: "
          + default-text-args.keys().join(", ")
          + ".\nBut found invalid keys: "
          + format.keys().join(", ")
          + ".",
      )
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
