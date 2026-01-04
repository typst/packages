#let digit-names = (
  "kosong",
  "satu",
  "dua",
  "tiga",
  "empat",
  "lima",
  "enam",
  "tujuh",
  "lapan",
  "sembilan"
)

#let scale-names = (
  "",
  "ribu",
  "juta",
  "bilion",
  "trilion",
  "kuadrilion",
  "kuitilion",
  "sekstilion",
  "septilion",
  "oktilion",
  "nonilion",
  "desilion"
)

#let convert-two-digits(digits) = {
  let tens = int(digits.at(0))
  let ones = int(digits.at(1))

  if tens == 0 {
    return if ones == 0 { "" } else { digit-names.at(ones) }
  }

  if tens == 1 and ones == 0 {
    return "sepuluh"
  }

  if tens == 1 and ones == 1 {
    return "sebelas"
  }

  if tens == 1 {
    return digit-names.at(ones) + " belas"
  }

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
  zero-name: "sifar",
  convert-group: convert-group,
  join-parts: join-parts,
  format-negative: format-negative,
)

