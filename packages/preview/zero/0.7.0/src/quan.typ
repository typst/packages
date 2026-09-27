#import "num.typ": num
#import "parsing.typ": content-to-string
#import "units.typ": parse-unit, qty, unit

#let quan(input) = {
  if type(input) == content {
    input = content-to-string(input)
    assert(input != none, message: "")
  }
  
  let regex-beginning-of-unit = regex("[ a-zA-Zµ/]")

  
  // We need to protect against detecting the e/E exponent notation as a unit
  let e-position = lower(input).position("e")
  let pos = if (
    e-position != none
      and input.at(e-position + 1, default: ".") in "+-1234567890.,"
  ) {
    let pos = input.slice(e-position + 1).position(regex-beginning-of-unit)
    if pos != none {
      pos += e-position + 1
    }
    pos
  } else {
    input.position(regex-beginning-of-unit)
  }

  if pos == none {
    num(input)
  } else if pos == 0 {
    unit(parse-unit(input))
  } else {
    qty(
      input.slice(0, pos),
      parse-unit(input.slice(pos)),
    )
  }
}

