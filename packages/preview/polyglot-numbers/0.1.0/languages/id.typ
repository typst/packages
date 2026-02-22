#let digit-names = (
  "nol",
  "satu",
  "dua",
  "tiga",
  "empat",
  "lima",
  "enam",
  "tujuh",
  "delapan",
  "sembilan"
)

#let scale-names = (
  "",
  "ribu",
  "juta",
  "miliar",
  "triliun",
  "kuadriliun",
  "kuitiliun",
  "sekstiliun",
  "septiliun",
  "oktiliun",
  "noniliun",
  "desiliun"
)

#let convert-two-digits(digits) = {
  let tens = int(digits.at(0))
  let ones = int(digits.at(1))

  // 0 - 9
  if tens == 0 {
    return if ones == 0 { "" } else { digit-names.at(ones) }
  }

  // 10
  if tens == 1 and ones == 0 {
    return "sepuluh"
  }

  // 11
  if tens == 1 and ones == 1 {
    return "sebelas"
  }

  // 12 - 19
  if tens == 1 {
    return digit-names.at(ones) + " belas"
  }

  // 20 - 99
  let result = digit-names.at(tens) + " puluh"
  if ones != 0 {
    result = result + " " + digit-names.at(ones)
  }

  return result
}

#let convert-group(digits, scale-idx, options) = {
  let hundreds = int(digits.at(0))
  let rest = digits.slice(1)

  let parts = ()

  if hundreds != 0 {
    let hundred-text = if hundreds == 1 {
      "seratus"
    } else {
      digit-names.at(hundreds) + " ratus"
    }
    parts.push(hundred-text)
  } 
  

  let rest-text = convert-two-digits(rest)
  if rest-text != "" {
    parts.push(rest-text)
  }

  if parts.len() == 0 { return none }

  return parts.join(" ")
}

#let join-parts(parts, options) = {
  let result-parts = ()

  for part in parts {
    let text = part.text
    if part.scale > 0 {
      if part.scale == 1 and text == "satu" {
        text = "seribu"
      } else {
        text = text + " " + scale-names.at(part.scale)
      }
    }

    result-parts.push(text)
  }

  return result-parts.join(" ")
}

#let format-negative(text) = {
  "negatif " + text
}

#let lang-config = (
  zero-name: "nol",
  convert-group: convert-group,
  join-parts: join-parts,
  format-negative: format-negative,
)
