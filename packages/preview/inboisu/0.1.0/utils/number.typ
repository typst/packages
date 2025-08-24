#let n(num, decimal: ".", thousands: ",") = {
  let parts = str(num).split(".")
  let decimal_part = if parts.len() == 2 {
    parts.at(1)
  }
  let integer_part = parts
    .at(0)
    .rev()
    .clusters()
    .enumerate()
    .map(item => {
        let (index, value) = item
        return value + if calc.rem(index, 3) == 0 and index != 0 {
          thousands
        }
      })
    .rev()
    .join("")
  return integer_part + if decimal_part != none {
    decimal + decimal_part
  }
}

#let d = n.with(decimal: ".", thousands: ",") // English Style
#let c = n.with(decimal: ",", thousands: ".") // Continental Style
#let s = n.with(decimal: ".", thousands: " ") // SI Style (English)
#let f = n.with(decimal: ",", thousands: " ") // SI Style (French)

#for x in (1.2, 65536, 3800.25) {
  [
    *#x* \
    #raw("d" + "(" + str(x) + ")") = #d(x) \
    #raw("c" + "(" + str(x) + ")") = #c(x) \
    #raw("f" + "(" + str(x) + ")") = #s(x) \
    #raw("s" + "(" + str(x) + ")") = #f(x) \
    \
  ]
}