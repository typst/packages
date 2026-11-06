#let first-letter-to-upper = (s) => {
  upper(s.first()) + s.slice(1)
}

// Take a number as an input and a length,
// if number is not as big as length, return the number
// with 0 padding in front, like 9 with length 2
// will return 09
#let pad = (number, length, pad_char: "0") => {
  let str_num = str(number)
  let padding = ""
  while str_num.len() + padding.len() < length {
    padding += pad_char
  }
  return padding + str_num
}

#let safe-slice = (s, length) => {
  let result = ""
  for ch in s {
    if result.len() < length {
      result += ch
    } else {
      break
    }
  }
  result
}
