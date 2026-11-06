
// float, int string or content
#let get-num-str(number, decimal-marker) = {
  let result = lower(repr(number).trim("[").trim("]"))
  result = result.replace(",", decimal-marker)
  result = result.replace(".", decimal-marker)
  if result.ends-with(decimal-marker) { result += "0" }
  return result
}

#let get-decimal-pos(str, decimal-marker) = {
  let decimal-pos = str.position(decimal-marker)
  if decimal-pos == none { decimal-pos = str.len() }
  return decimal-pos
}
#let get-num-decimals(str, decimal-marker) = {
  let decimal-pos = str.position(decimal-marker)
  if decimal-pos != none { return str.len() - decimal-pos - 1 }
  return 0
}

#let group-digits(input, group-size, group-sep, group-min-digits, decimal-marker) = {
  let decimal-pos = get-decimal-pos(input, decimal-marker)
  let effective-group-size = group-size
  if decimal-pos < group-min-digits {
    effective-group-size = group-min-digits
  }
  let index = effective-group-size - calc.rem(decimal-pos, effective-group-size)
  let result = ""
  let i = 0
  for k in input {      
    if k == decimal-marker { 
      effective-group-size = group-size
      if input.len() - decimal-pos <= group-min-digits {
        effective-group-size = group-min-digits
      }
      index = effective-group-size - 1
      i = -1 
    } else if calc.rem(index, effective-group-size) == 0 and i != 0 {
      result += group-sep 
    }
    result += k
    index += 1
    i += 1
  }
  return result
}


