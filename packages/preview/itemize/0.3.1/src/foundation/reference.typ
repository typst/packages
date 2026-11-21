#import "../util/parse-args.typ": *

/// Parse supplement content
#let supp(body, supplement, ..args) = {
  if supplement not in (auto, none) {
    if type(supplement) == dictionary {
      let prefix = supplement.remove("prefix", default: [])
      let suffix = supplement.remove("suffix", default: [])
      assert(
        supplement == (:),
        message: "The key of `supplement` should be: `prefix`, `suffix`."
          + "\nBut found: "
          + supplement.keys().join(", "),
      )
      [#prefix~#h(0em, weak: true)#body#h(0em, weak: true)~#suffix]
    } else if type(supplement) == function {
      [#supplement((body: body, ..args.named()))]
    } else {
      [#supplement~#h(0em, weak: true)#body]
    }
  } else {
    [#body]
  }
}

/// Pre-parse item supplement arguments (do not handle `auto`, `none`)
#let pre-parse-supplement(supplement, level, ..args) = n => (body, ..other-args) => {
  if supplement in (none, auto) {
    return supplement
  }
  if type(supplement) == function {
    supp(body, supplement, level: level + 1, n: n + 1, ..pre-parse-tag(n, ..args), ..other-args)
  } else {
    let _supplement = get-depth-value(supplement, level)
    if _supplement in (none, auto) {
      return _supplement
    }
    if type(_supplement) == function {
      supp(body, _supplement, n: n + 1, ..pre-parse-tag(n, ..args), ..other-args)
    } else {
      _supplement = get-value-by-n(_supplement, none, none)(n)
      if _supplement in (none, auto) {
        return _supplement
      }
      supp(body, _supplement)
    }
  }
}

/// Parse item supplement arguments (handle `auto`, `none` as `_ => body`)
#let parse-supplement(
  curr-supplement,
  rel-level,
  elem-supplement,
  abs-level,
  ..args,
) = n => (body, ..other-args) => {
  let supplement = pre-parse-supplement(elem-supplement, abs-level, ..args)(n)(body, ..other-args)
  if supplement in (auto, none) {
    supplement = pre-parse-supplement(curr-supplement, rel-level, ..args)(n)(body, ..other-args)
    if supplement not in (auto, none) {
      return supplement
    } else {
      return body
    }
  } else {
    return supplement
  }
}

#let get-ref-numbering-info(ref-numbering) = {
  let info = (:)
  if type(ref-numbering) == dictionary {
    let _numbering = ref-numbering.remove("numbering", default: none)
    let _full = ref-numbering.remove("full", default: none)
    assert(
      ref-numbering == (:),
      message: "The key of `ref-numbering` should be: `numbering`, `full`."
        + "\nBut found: "
        + ref-numbering.keys().join(", "),
    )
    if _numbering != none { info.numbering = _numbering }
    if _full != none { info.full = _full }
  } else {
    if ref-numbering != none { info.numbering = ref-numbering }
  }
  return info
}

/// Parse ref-numbering
#let parse-ref-numbering(ref-numbering, ref-numbering-e, ref-numbering-item) = {
  // fold
  let item-info = get-ref-numbering-info(ref-numbering-item)
  let e-info = get-ref-numbering-info(ref-numbering-e)
  let info = get-ref-numbering-info(ref-numbering)
  let (numbering, full) = (numbering: none, full: auto) + info + e-info + item-info
  assert(
    numbering == none or type(numbering) in (str, function),
    message: "`ref-numbering` must be a string or a function",
  )
  assert(
    full in (auto, true, false, "rel"),
    message: "`full` must be `auto`, bool, or \"rel\". " + "\nBut found: " + repr(full),
  )
  return (numbering, full)
}

// #let parse-ref-numbering(ref-numbering, ref-numbering-e, ref-numbering-item) = {
//   let _ref-numbering = get-none-value(ref-numbering, get-none-value(
//     ref-numbering-e,
//     ref-numbering-item,
//   ))
//   let (numbering, full) = if type(_ref-numbering) == dictionary {
//     let _numbering = _ref-numbering.remove("numbering", default: none)
//     let _full = _ref-numbering.remove("full", default: auto)
//     assert(
//       _ref-numbering == (:),
//       message: "The key of `ref-numbering` should be: `numbering`, `full`."
//         + "\nBut found: "
//         + _ref-numbering.keys().join(", "),
//     )
//     (_numbering, _full)
//   } else { (_ref-numbering, auto) }
//   assert(
//     numbering == none or type(numbering) in (str, function),
//     message: "`ref-numbering` must be a string or a function",
//   )
//   assert(
//     full in (auto, true, false, "rel"),
//     message: "`full` must be `auto`, bool, or \"rel\". " + "\nBut found: " + repr(full),
//   )
//   return (numbering, full)
// }
