#import "util.typ": *

#let strnum(value) = {
  assert-number(value)

  let (strint, strdec, ..) = str(value)
    .trim(regex("[+−-]"), at: start)
    .split(".") + (none,)

  let sign = if type(value) in (int, float, decimal) and value < 0 {
    "-"
  } else if type(value) == str and value.first() == "-" {
    "-"
  } else {
    "+"
  }
  strint = strint.trim("0", at: start)
  if strint == "" { strint = "0" }

  (integer: strint, decimal: strdec, sign: sign)
}

#let first-sigfig(strnum) = if strnum.integer == "0" {
  if strnum.decimal == none {
    return 1
  }
  let first-sigfig = strnum.decimal.position(regex("[1-9]"))
  if first-sigfig != none { -first-sigfig }
} else {
  strnum.integer.len()
}

#let at-sigfig(strnum, sigfig) = if sigfig > 0 {
  int(strnum.integer.at(strnum.integer.len() - sigfig))
} else {
  int(strnum.decimal.at(-sigfig))
}

#let last-digit(strnum) = if strnum.decimal == none {
  if strnum.integer == "0" {
    return 1
  }
  strnum.integer.trim("0", at: start).len()
} else {
  -strnum.decimal.len() + 1
}

#let round(strnum, places) = if places == 1 {
  if strnum.decimal == none { return strnum }
  if strnum.decimal.at(0) in "56789" {
    strnum.integer = half-round(strnum.integer, strnum.integer.len() - 1)
  }
  strnum.decimal = none
  strnum
} else if places > 1 {
  if places > strnum.integer.len() { places = strnum.integer.len() }
  strnum.decimal = none
  if strnum.integer.at(-places + 1) in "56789" {
    strnum.integer = half-round(strnum.integer, strnum.integer.len() - places, pad: true)
  }
  strnum.integer = strnum.integer.slice(0, -places + 1) + "0" * (places - 1)
  strnum
} else if strnum.decimal == none {
  strnum.decimal = "0" + "0" * -places
  strnum
} else if -places >= strnum.decimal.len() - 1 {
  strnum.decimal += "0" * (-places - strnum.decimal.len() + 1)
  strnum
} else if strnum.decimal.at(-places + 1) in "56879" {
  let result = half-round(strnum.decimal, -places, carry: strdec => (strdec, half-round(strnum.integer, strnum.integer.len() - 1)))
  // (strnum.decimal, strnum.integer) = (result,).flatten() + (strnum.integer,)
  if type(result) == str {
    strnum.decimal = result
  }
  else {
    strnum.decimal = result.first()
    strnum.integer = result.last()
  }
  strnum
} else {
  strnum.decimal = strnum.decimal.slice(0, -places + 1)
  strnum
}
/* 
#let round(strnum, places) = if places > 0 {
  if places > strnum.integer.len() {
    places = strnum.integer.len()
  }
  if strnum.decimal != none and (places == 1 and strnum.decimal.at(0) in "56789") or strnum.integer.at(strnum.integer.len() - places - 1) in "56789" {
    strnum.integer = half-round(strnum.integer, strnum.integer.len() - places)
  }
  strnum.decimal = none
  strnum
} else if strnum.decimal == none {
  strnum.decimal = "0" * (-places + 1)
  strnum
} else if strnum.decimal.len() <= -places + 1 {
  strnum.decimal += "0" * (-places + 1 - strnum.decimal.len())
  strnum
} else if strnum.decimal.at(-places + 1) in "56789" {
  let result = half-round(strnum.decimal, -places, carry: strdec => (strdec, half-round(strnum.integer, strnum.integer.len() - 1)))
  if type(result) == str {
    strnum.decimal = result
  }
  else {
    strnum.decimal = result.first()
    strnum.integer = result.last()
  }
  strnum
} else {
  strnum.decimal = strnum.decimal.slice(0, -places + 1)
  strnum
}
*/
#let shift(strnum, offset) = if offset > 0 {
  if strnum.integer.len() > offset {
    strnum.decimal = strnum.integer.slice(strnum.integer.len() - offset) + strnum.decimal
    strnum.integer = strnum.integer.slice(0, strnum.integer.len() - offset)
  }
  else {
    strnum.decimal = "0" * (offset - strnum.integer.len()) + strnum.integer + strnum.decimal
    strnum.integer = "0"
  }
  strnum
} else if offset < 0 {
  if strnum.integer == "0" and strnum.decimal == none { return strnum }
  if strnum.integer == "0" { strnum.integer = "" }
  if strnum.decimal == none {
    strnum.integer += "0" * -offset
  }
  else if strnum.decimal.len() > -offset {
    strnum.integer += strnum.decimal.slice(0, -offset)
    strnum.decimal = strnum.decimal.slice(-offset) 
  }
  else {
    strnum.integer += strnum.decimal + "0" * (-offset - strnum.decimal.len())
    strnum.decimal = none 
  }
  strnum.integer = strnum.integer.trim("0", at: start)
  if strnum.integer == "" { strnum.integer = "0" }
  strnum
} else {
  strnum
}

#let str(strnum, point: ",", explicit-sign: false) = (
  if explicit-sign or strnum.sign == "-" { 
    if strnum.sign == "-" { math.minus }
    else { math.plus }
  }
  + if strnum.integer.len() > 4 { group-digits(strnum.integer) }
    else { strnum.integer }
  + if strnum.decimal != none { point + group-digits(strnum.decimal, by: 5, at: start) }
)
