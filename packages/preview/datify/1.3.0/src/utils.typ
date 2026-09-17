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

#let safe-slice = (s, start, end) => {
  let clusters = s.clusters()
  let n = if end > clusters.len() { clusters.len() } else { end }
  return clusters.slice(start, n).join()
}
