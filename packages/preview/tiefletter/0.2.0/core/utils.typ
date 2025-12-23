#let format-currency(number, precision: 2) = {
  let s = str(calc.round(number, digits: precision))
  let after-dot = s.find(regex("\..*"))

  if after-dot == none {
    s = s + "."
    after-dot = "."
  }

  for i in range(precision - after-dot.len() + 1) {
    s = s + "0"
  }

  s
}
