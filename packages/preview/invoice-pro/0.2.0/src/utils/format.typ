#let number(
  number,
  decimal-sign: ",",
  thousand-separators: ".",
  negative-sign: "-",
  padding: false,
  accuracy: 2,
) = {
  let rounded = calc.round(number, digits: accuracy)
  let is-negative = rounded < 0
  let abs-val = calc.abs(rounded)

  let s = str(abs-val)
  let parts = s.split(".")
  let int-part = parts.at(0)
  let frac-part = if parts.len() > 1 { parts.at(1) } else { "" }

  if padding and accuracy > 0 {
    if frac-part.len() < accuracy {
      frac-part += "0" * (accuracy - frac-part.len())
    }
  }

  let formatted-int = int-part
    .clusters()
    .rev()
    .chunks(3)
    .map(c => c.join())
    .join(thousand-separators.rev())
    .clusters()
    .rev()
    .join()

  let result = formatted-int

  if frac-part.len() > 0 { result += decimal-sign + frac-part }
  if is-negative { result = negative-sign + result }

  return result
}

#let currency(
  value,
  currency: "€",
  location: end,
  number-format: (:),
) = {
  number-format += (padding: number-format.at("padding", default: true))

  let formated-string = number(value, ..number-format)
  if location == start { currency + formated-string } else if location == end {
    formated-string + currency
  } else { panic("Inavalid Location!") }
}
