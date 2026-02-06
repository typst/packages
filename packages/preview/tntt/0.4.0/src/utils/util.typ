#let array-at(arr, pos) = { arr.at(calc.min(pos, arr.len()) - 1) }

#let str2bool(s) = {
  s = lower(s)
  if (s == "true" or s == "1" or s == "yes" or s == "on") {
    true
  } else if (s == "false" or s == "0" or s == "no" or s == "off") {
    false
  } else {
    panic("Cannot convert string to bool: " + s)
  }
}
