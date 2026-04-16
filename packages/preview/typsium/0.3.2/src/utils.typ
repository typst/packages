#let brackets = (
  math.paren.l,
  math.bracket.l,
  math.brace.l,
  math.bar.v,
  math.paren.r,
  math.bracket.r,
  math.brace.r,
  math.bar.v,
)

#let arrows = (
  sym.arrow.r.l,
  sym.arrow.r,
  sym.arrow.l,
  sym.arrow.r.double,
  sym.arrow.l.double,
  sym.arrow.r.not,
  sym.arrow.l.not,
  sym.harpoons.rtlb,
)
#let roman-numerals = (
  "0",
  "I",
  "II",
  "III",
  "IV",
  "V",
  "VI",
  "VII",
  "VIII",
  "IX",
  "X",
  "XI",
  "XII",
  "XIII",
)
#let arrow-kinds = (
  "<->": 0,
  "↔": 0,
  "->": 1,
  "→": 1,
  "<-": 2,
  "←": 2,
  "=>": 3,
  "⇒": 3,
  "<=": 4,
  "⇐": 4,
  "-/>": 5,
  "</-": 6,
  "<=>": 7,
  "⇔": 7,
)

#let get-bracket(kind, open: true) = {
  kind = calc.clamp(kind, 0, 3)
  if not open {
    kind += 4
  }
  brackets.at(kind, default: none)
}
#let get-arrow(kind) = {
  arrows.at(kind, default: sym.arrow.r)
}

#let count-to-content(count) = {
  if count == none {
    return none
  } else if type(count) == int {
    if count > 1 {
      return [#count]
    }
  } else if type(count) == content {
    if count != [1] {
      return count
    }
  }
  return none
}
#let roman-to-number(roman-number) = {
  return roman-numerals.position(x => x == roman-number)
}
#let show-roman(body, roman: true) = {
  if roman {
    show "1": "I"
    show "2": "II"
    show "3": "III"
    show "4": "IV"
    show "5": "V"
    show "6": "VI"
    show "7": "VII"
    show "8": "VIII"
    body
  } else {
    show "V": "5"
    show "I": "1"
    show "II": "2"
    show "III": "3"
    show "IV": "4"
    show "VI": "6"
    show "VII": "7"
    show "VIII": "8" // highest priority is lowest, otherwise it will render VII as 511
    body
  }
}
#let oxidation-to-content(
  oxidation,
  roman: true,
  negative-symbol: math.minus,
  positive-symbol: math.plus,
) = {
  if oxidation == none {
    return none
  } else if type(oxidation) == int {
    let symbol = none
    if oxidation < 0 {
      symbol = negative-symbol
    } else if oxidation > 0 {
      symbol = positive-symbol
    }
    if roman {
      return [#symbol#roman-numerals.at(calc.abs(oxidation))]
    } else {
      return [#symbol#calc.abs(oxidation)]
    }
  } else if type(oxidation) == content {
    return oxidation
  }
  return none
}
#let arrow-string-to-kind(arrow) = {
  arrow = arrow.trim()
  arrow-kinds.at(arrow, default: 1)
}

#let parser-config = (
  arrow: (arrow_size: 120%, reversible_size: 120%),
  conditions: (
    bottom: (
      symbols: (heating: ("Delta", "delta", "Δ", "δ", "fire", "heat", "hot", "heating")),
      identifiers: (("T=", "t="), ("P=", "p=")),
      units: ("°C", "K", "atm", "bar"),
    ),
  ),
  match_order: (
    basic: ("bracket", "element", "charge"),
    full: ("bracket", "element", "plus", "arrow", "charge"),
  ),
)


// Following utility methods are from:
// https://github.com/touying-typ/touying/blob/6316aa90553f5d5d719150709aec1396e750da63/src/utils.typ#L157C1-L166C2

#let typst-builtin-sequence = ([A] + [ ] + [B]).func()
#let typst-builtin-styled = [#set text(fill: red)].func()
#let typst-builtin-context = [#context {}].func()
#let typst-builtin-space = [ ].func()

#let is-sequence(it) = {
  type(it) == content and it.func() == typst-builtin-sequence
}

#let is-empty-content(it) = {
  it in ([ ], parbreak(), linebreak())
}

#let is-styled(it) = {
  type(it) == content and it.func() == typst-builtin-styled
}

#let is-metadata(it) = {
  type(it) == content and it.func() == metadata
}

/// Determine if a content is a metadata with a specific kind.
#let is-kind(it, kind) = {
  type(it.value) == dictionary and it.value.at("kind", default: none) == kind
}

/// Determine if a content is a heading in a specific depth.
///
/// -> bool
#let is-heading(it, depth: 9999) = {
  type(it) == content and it.func() == heading and it.depth <= depth
}



// Following utility method is from:
// https://github.com/typst-community/linguify/blob/b220a5993c7926b1d2edcc155cda00d2050da9ba/lib/utils.typ#L3
#let if-auto-then(val, ret) = {
  if (val == auto) {
    ret
  } else {
    val
  }
}

#let try-at(value, field, default: none) = {
  if (value == none) {
    none
  } else {
    value.at(field, default: default)
  }
}

#let none-coalesce(value, default) = {
  if value == none {
    return default
  } else {
    return value
  }
}

// own utils
#let length(value) = {
  if value == none {
    return 0
  }
  return value.len()
}
#let is-default(value) = {
  if value == [] or value == none or value == auto or value == "" {
    return true
  }
  return false
}

#let customizable-attach(
  base,
  t: none,
  tr: none,
  br: none,
  tl: none,
  bl: none,
  b: none,
  affect-layout: true,
) = {
  if affect-layout == false {
    base = box(base)
  }

  if t == [] { t = none }
  if tr == [] and t == none { tr = none } // otherwise oxidation numbers appear in the top left even when attached to the top position
  if tl == [] { tl = none }
  if br == [] { br = none }
  if bl == [] { bl = none }

  return math.attach(
    base,
    t: t,
    tr: tr,
    br: br,
    tl: tl,
    bl: bl,
    b: b,
  )
}

#let padright(array, targetLength) = {
  for value in range(array.len(), targetLength) {
    array.insert(value, none)
  }
  return array
}
#let sequence-to-array(it) = {
  if is-sequence(it) {
    it.children.map(sequence-to-array)
  } else {
    it
  }
}

#let get-all-children(it) = {
  if it == none {
    return none
  }

  let children = if is-sequence(it) { it.children } else { (it,) }

  return children.map(sequence-to-array).flatten()
}
#let to-string(content) = {
  if content.has("text") {
    if type(content.text) == str {
      content.text
    } else {
      to-string(content.text)
    }
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let reconstruct-content(template, body) = {
  if template == none or template == auto {
    return body
  }

  let func = template.func()

  if func == typst-builtin-styled {
    return template.func()(body, template.styles)
  } else if func == typst-builtin-context {
    template
  } // else if func in (emph, smallcaps, sub, super, box, block, hide, heading) {
  //   return template.func()(body)
  // }
  else if (
    func
      in (
        math.overbrace,
        math.underbrace,
        math.underbracket,
        math.overbracket,
        math.underparen,
        math.overparen,
        math.undershell,
        math.overshell,
      )
  ) {
    return template.func()(body, template.at("annotation", default: none))
  } else if func == pad {
    return template.func()(
      body,
      bottom: template.at("bottom", default: 0%),
      top: template.at("top", default: 0%),
      left: template.at("left", default: 0%),
      right: template.at("right", default: 0%),
      rest: template.at("rest", default: 0%),
    )
  } else if func == strong {
    return template.func()(body, delta: template.at("delta", default: 300))
  } else if func == highlight {
    return template.func()(
      body,
      bottom-edge: template.at("bottom-edge", default: "descender"),
      extent: template.at("extent", default: 0pt),
      fill: template.at("fill", default: rgb("#fffd11a1")),
      radius: template.at("radius", default: (:)),
      stroke: template.at("stroke", default: (:)),
      top-edge: template.at("top-edge", default: "ascender"),
    )
  } else if func in (overline, underline, strike) {
    return template.func()(
      body,
      background: template.at("background", default: false),
      extent: template.at("extent", default: 0pt),
      offset: template.at("offset", default: auto),
      stroke: template.at("stroke", default: auto),
    )
  } else if func == math.cancel {
    return template.func()(
      body,
      angle: template.at("angle", default: auto),
      cross: template.at("cross", default: false),
      inverted: template.at("inverted", default: false),
      length: template.at("length", default: 100% + 3pt),
      stroke: template.at("stroke", default: 0.5pt),
    )
  } else {
    return template.func()(body)
  }
}
#let reconstruct-nested-content(templates, body) = {
  let result = body
  for template in templates {
    result = reconstruct-content(template, result)
  }
  return result
}
#let templates-equal(a, b) = {
  if a.func() != b.func() {
    return false
  }
  if a.func() == typst-builtin-styled {
    return true
  }
  for i in a.fields() {
    if i.at(0) != "child" and i.at(0) != "text" and i.at(0) != "body" {
      if i.at(1) != b.at(i.at(0)) {
        return false
      }
    }
  }
  return true
}
#let reconstruct-content-from-strings(strings, templates, start: 0, end: none) = {
  if strings.len() == 1 {
    return reconstruct-nested-content(templates.at(0), [#strings.at(0)])
  }
  strings = strings.slice(start, end)
  templates = templates.slice(start, end)

  let result = none
  start = 0
  for i in range(1, templates.len()) {
    let is-equal = templates.at(i).len() == templates.at(start).len()
    if is-equal {
      for j in range(0, templates.at(i).len()) {
        if not templates-equal(templates.at(i).at(j), templates.at(start).at(j)) {
          is-equal = false
        }
      }
    }
    if is-equal {
      continue
    } else {
      result += reconstruct-nested-content(templates.at(start), [#strings.slice(start, i)])
      start = i
    }
  }
  result += reconstruct-nested-content(templates.at(start), [#strings.slice(start, templates.len())])
  return result
}

#let charge-to-content(
  charge,
  radical: false,
  roman: false,
  radical-symbol: box(baseline: - 0.1em, sym.dot),
  negative-symbol: box(baseline: - 0.1em, sym.minus),
  positive-symbol: box(baseline: - 0.1em, sym.plus),
) = {
  // NOTE: This function intentionally returns `[]` (not `none`) for
  // "no charge" in many cases, because callers feed it into `math.attach`
  // where `[]` behaves as an empty attachment.
  if is-default(charge) {
    return []
  }

  if type(charge) == int {
    // `radical` is rendered as a dot/bullet in front of the charge.
    if radical {
      radical-symbol
    }

    // No visible charge.
    if charge == 0 {
      []
      return
    }

    // Choose sign symbol.
    let sign = if charge < 0 { negative-symbol } else { positive-symbol }
    let magnitude = calc.abs(charge)

    if roman {
      roman-numerals.at(magnitude)
      sign
    } else {
      if magnitude > 1 {
        str(magnitude)
      }
      sign
    }
  } else if type(charge) == str {
    charge
      .replace(".", radical-symbol)
      .replace("-", negative-symbol)
      .replace("+", positive-symbol)
  } else if type(charge) == content {
    show ".": radical-symbol
    show "-": negative-symbol
    show "+": positive-symbol
    show-roman(charge, roman: roman)
  }
}
