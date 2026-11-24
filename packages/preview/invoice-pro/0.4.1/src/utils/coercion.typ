// --- Primitives ---

#let to-decimal(value) = {
  let t = type(value)
  if t == decimal { value } else if t == int { decimal(value) } else if (
    t == str
  ) { decimal(value) } else if t == float {
    if value == 0.0 { decimal("0") } else {
      let rounded = calc.round(decimal(value), digits: 15)
      let has-decimal = str(rounded).contains(".")

      if has-decimal {
        decimal(str(rounded).trim("0", at: end, repeat: true))
      } else { rounded }
    }
  } else if value == auto { auto } else if value == none { none } else {
    panic("Expected decimal-like, got `" + repr(value) + "`")
  }
}

#let to-ratio(value) = {
  let t = type(value)
  if t == ratio { to-decimal(float(value)) } else { to-decimal(value) }
}

#let to-text(value) = {
  let t = type(value)
  if t == content { value } else if t == str { [#value] } else if (
    value == none
  ) { [] } else if value == auto { auto } else {
    panic("Expected text-like, got `" + repr(value) + "`")
  }
}

#let to-string(it) = {
  if type(it) == str { it } else if it == auto { auto } else if it == none {
    none
  } else if type(it) != content { str(it) } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") { to-string(it.body) } else if it == [ ] { " " }
}

#let to-date(value) = {
  let t = type(value)
  if t == datetime { value } else if t == array {
    value.map(v => if type(v) == datetime { v } else {
      panic("Invalid date in range")
    })
  } else if value == auto { auto } else if value == auto { none } else {
    panic("Expected date-like, got " + str(t))
  }
}

// --- Domain Enums ---

#let to-tax-mode(value) = {
  if value in ("inclusive", "exclusive") { value } else {
    panic("Invalid tax-mode: " + str(value))
  }
}

#let to-tax-code(value) = {
  let map = (
    "standard": "S",
    "S": "S",
    "exempt": "E",
    "E": "E",
    "reverse-charge": "AE",
    "AE": "AE",
    "intra-community": "K",
    "K": "K",
    "export": "G",
    "G": "G",
    "outside-scope": "O",
    "O": "O",
    "L": "L",
    "M": "M",
  )
  let normalized = map.at(value, default: none)
  if normalized != none { normalized } else {
    panic("Unknown tax code: " + str(value))
  }
}

#let to-item-id(value) = {
  let t = type(value)
  if t == str { return (seller: none, buyer: none, standard: value) } else if (
    t == dictionary
  ) {
    (
      seller: value.at("seller", default: none),
      buyer: value.at("buyer", default: none),
      standard: value.at("standard", default: none),
    )
  } else if value == auto { return auto }
  return none
}
