
/// if value is auto then return other value else return value itself
#let if-auto-then(val, ret) = {
  if (val == auto) {
    ret
  } else {
    val
  }
}

/// if value is none return other value else return value itself
#let if-none-then(val, ret) = {
  if (val == none) {
    ret
  } else {
    val
  }
}

/// check if a value is a certain type
#let is-type(val, typ) = {
  if typ == none  or typ == auto {
    val == typ
  } else {
    type(val) == typ
  }
}

/// assert if a value is a certain type
#let assert-type(val, typ) = {
  assert(is-type(val,typ), message: "Expected " + typ + ", found " + type(val))
}

/// decode an input
#let decode-input(name, default: none) = {
  let input = sys.inputs.at(name, default: default)
  if input != none {
    return json.decode(input)
  } else { return none }
}

/// maps an input to an boolean
#let bool-input(name) = {
  let value = json.decode(sys.inputs.at(name, default: "false"))
  assert(type(value) == bool, message: "--input " + name + "=... must be set to true or false if present")
  value
}

// maps an input to a date
#let parse-date-str(date) = {
  if date == none { return none }
  assert(type(date) == str, message: "Expected string, found:" + type(date))
  if date.match(regex("^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$")) != none {
    let da = date.split("-").map(p => int(p))
    return datetime(year: da.at(0), month: da.at(1), day: da.at(2))
  }
  return none

}
