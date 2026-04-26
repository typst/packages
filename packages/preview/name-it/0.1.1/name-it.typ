#let name-it(num, show-and: true, negative-prefix: "negative") = {
  let digit-name(digit, show-zero) = {
    let names = ("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
    if digit == "0" and not show-zero {
      return ""
    }
    return names.at(int(digit))
  }

  let three-digit-name(num, show-zero, show-and) = {
    if num.len() == 3 {
      let hundreds = digit-name(num.at(0), false)
      let tens = three-digit-name(num.slice(1), show-zero and num.at(0) == "0", show-and)
      return (
        hundreds
        + if hundreds != "" { " hundred" }
        + if tens.trim() != "" and show-and { " and" }
        + tens
      )
    }
    let names = ("", none, "twenty-", "thirty-", "forty-", "fifty-", "sixty-", "seventy-", "eighty-", "ninety-")
    let teens = ("ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen")
    let name = names.at(int(num.at(0)))
    if name != none { num = num.slice(1) }
    if num.len() == 1 {
      name += digit-name(num, name == "" and show-zero)
    } else {
      name += teens.at(int(num.slice(1)))
    }
    return " " + name.trim("-", at: end)
  }

  assert(
    type(num) == int
    or type(num) == str and num.contains(regex("^-?\d+$")),
    message: "argument must be either an integer or a string of an integer, got " + repr(num),
  )
  let name = ""
  num = str(num)
  let is-negative = num.at(0) == "-"
  if is-negative { num = num.slice(1) }
  let group-names = ("", "thousand", "million", "billion", "trillion", "quadrillion", "quintillion", "sextillion", "septillion", "octillion", "nonillion", "decillion")
  // pad left with zeros to a multiple of 3
  num = ((int((num.len() - 1) / 3) + 1) * 3 - num.len()) * "0" + num
  let group-count = int(num.len() / 3)
  for group in range(group-count) {
    let group-name = group-names.at(group-count - 1 - group)
    let named = three-digit-name(num.slice(group * 3, count: 3), group-count == 1, show-and)
    name += " "
    name += named
    if named.trim() != "" {
      name += " "
      name += group-name
    }
  }
  name = name.replace(regex("^ *and"), "").trim().replace(regex(" +"), " ")
  if is-negative { name = negative-prefix + " " + name }
  return name
}
