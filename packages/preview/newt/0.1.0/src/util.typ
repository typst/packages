#let assert-type(value, required: true, ..t) = assert(
  type(value) in t.pos() or (not required and value in (none, auto)),
  message: "Expected " 
         + t.pos().map(str).join(", ", last: " or ") 
         + ", found " 
         + str(type(value))
)

#let assert-enum(value, ..vs) = assert(
  value in vs.pos(),
  message: "Expected "
         + vs.pos().map(repr).join(", ", last: " or ")
         + ", found "
         + repr(value)
)

#let assert-number(value) = assert-type(value, int, float, str, decimal) + if type(value) == str {
    assert(
      value.match(regex("^[+-]?\\d*|\\d*(\\.\\d+)$")) != none,
      message: "Invalid number: " + value
    )
}

#let or-else(..items) = items.pos().find(i => i != none and i != false and i != "" and i != [])

#let half-round(value, place, carry: auto, pad: false) = {
  let lookup = (
    "0": "1", "1": "2", "2": "3", "3": "4", "4": "5",
    "5": "6", "6": "7", "7": "8", "8": "9", "9": "0",
  )
  assert-type(value, str)
  assert-type(place, int)
  assert-type(carry, function, required: false)
  let carried-zeros = ""

  let reached-end = false
  while (not reached-end and value.at(place) == "9") {
    carried-zeros += "0"
    place -= 1
    reached-end = place <= -1
  }

  if pad { carried-zeros = (value.len() - place - 1) * "0" } 

  if reached-end {
    if type(carry) == function {
      return carry(carried-zeros)
    } else {
      return "1" + carried-zeros
    }
  }

  value.slice(0, place) + lookup.at(value.at(place)) + carried-zeros
}

#let strtok(s, cur, predicate) = {
  if type(s) == str {
    s = s.codepoints()
  }
  let tok = ""
  while s.len() > cur and predicate(s.at(cur)) {
    tok += s.at(cur)
    cur += 1
  }
  (tok, cur)
}

#let strchunks(s, chunk-size, at: start) = {
  let chunks = ()
  let cur = 0
  if at == end and calc.rem(s.len(), chunk-size) != 0 {
    cur = calc.rem(s.len(), chunk-size)
    chunks.push(s.slice(0, cur))
  }
  while s.len() > cur + chunk-size {
    chunks.push(s.slice(cur, count: chunk-size))
    cur +=  chunk-size
  }
  if s.len() > cur {
    chunks.push(s.slice(cur))
  }
  chunks
}

#let group-digits(s, by: 3, from: 0, at: end, sep: " ") = if s.len() < from {
  return s
} else {
  strchunks(s, by, at: at).join(sep)
}
