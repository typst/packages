#let digit-names = ("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
#let teen-names = ("ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen")
#let tens-names = ("", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety")
#let scale-names = ("", "thousand", "million", "billion", "trillion", "quadrillion", "quintillion", "sextillion", "septillion", "octillion", "nonillion", "decillion")

#let convert-two-digits(digits) = {
  let tens = int(digits.at(0))
  let ones = int(digits.at(1))
  
  if tens == 0 {
    return if ones == 0 { "" } else { digit-names.at(ones) }
  }
  
  if tens == 1 {
    return teen-names.at(ones)
  }
  
  let result = tens-names.at(tens)
  if ones != 0 {
    result = result + "-" + digit-names.at(ones)
  }
  return result
}

#let convert-group(digits, scale-idx, options) = {
  let hundreds = int(digits.at(0))
  let rest = digits.slice(1)
  
  let parts = ()
  
  // Hundreds place
  if hundreds != 0 {
    parts.push(digit-names.at(hundreds) + " hundred")
  }
  
  // Tens and ones
  let rest-text = convert-two-digits(rest)
  if rest-text != "" {
    parts.push(rest-text)
  }
  
  if parts.len() == 0 { return none }
  
  // Handle "and" for English
  let show-and = options.named().at("show-and", default: true)
  let joiner = if parts.len() == 2 and show-and { " and " } else { " " }
  
  return parts.join(joiner)
}

#let join-parts(parts, options) = {
  let result-parts = ()
  
  for part in parts {
    let text = part.text
    if part.scale > 0 {
      text = text + " " + scale-names.at(part.scale)
    }
    result-parts.push(text)
  }
  
  return result-parts.join(" ")
}

#let format-negative(text) = {
  "negative " + text
}

#let lang-config = (
  zero-name: "zero",
  convert-group: convert-group,
  join-parts: join-parts,
  format-negative: format-negative,
)
