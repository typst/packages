#let digit-names = ("zéro", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf")
#let teen-names = ("dix", "onze", "douze", "treize", "quatorze", "quinze", "seize", "dix-sept", "dix-huit", "dix-neuf")
#let tens-names = ("", "dix", "vingt", "trente", "quarante", "cinquante", "soixante", "soixante", "quatre-vingt", "quatre-vingt")
#let scale-names = ("", "mille", "million", "milliard", "billion", "billiard", "trillion", "trilliard", "quadrillion", "quadrilliard", "quintillion", "quintilliard")

#let convert-two-digits(digits) = {
  let tens = int(digits.at(0))
  let ones = int(digits.at(1))
  
  if tens == 0 {
    return if ones == 0 { "" } else { digit-names.at(ones) }
  }
  
  if tens == 1 {
    return teen-names.at(ones)
  }
  
  // Special handling for 70-79 (soixante-dix)
  if tens == 7 {
    if ones == 0 {
      return "soixante-dix"
    } else if ones == 1 {
      return "soixante et onze"
    } else {
      return "soixante-" + teen-names.at(ones)
    }
  }
  
  // Special handling for 80-89 (quatre-vingts)
  if tens == 8 {
    if ones == 0 {
      return "quatre-vingts"
    } else {
      return "quatre-vingt-" + digit-names.at(ones)
    }
  }
  
  // Special handling for 90-99 (quatre-vingt-dix)
  if tens == 9 {
    if ones == 0 {
      return "quatre-vingt-dix"
    } else {
      return "quatre-vingt-" + teen-names.at(ones)
    }
  }
  
  // Regular tens (20-60)
  let result = tens-names.at(tens)
  if ones == 0 {
    return result
  } else if ones == 1 and (tens == 2 or tens == 3 or tens == 4 or tens == 5 or tens == 6) {
    // Use "et" for 21, 31, 41, 51, 61
    return result + " et un"
  } else {
    return result + "-" + digit-names.at(ones)
  }
}

#let convert-group(digits, scale-idx, options) = {
  let hundreds = int(digits.at(0))
  let rest = digits.slice(1)
  
  let parts = ()
  
  // Hundreds place
  if hundreds != 0 {
    if hundreds == 1 {
      parts.push("cent")
    } else {
      // Plural "cents" only if it's an exact multiple of 100
      let rest-value = int(rest.at(0)) * 10 + int(rest.at(1))
      if rest-value == 0 {
        parts.push(digit-names.at(hundreds) + " cents")
      } else {
        parts.push(digit-names.at(hundreds) + " cent")
      }
    }
  }
  
  // Tens and ones
  let rest-text = convert-two-digits(rest)
  if rest-text != "" {
    parts.push(rest-text)
  }
  
  if parts.len() == 0 { return none }
  
  // French doesn't use "and" between hundreds and tens
  return parts.join(" ")
}

#let join-parts(parts, options) = {
  let result-parts = ()
  
  for part in parts {
    let text = part.text
    let scale = part.scale
    
    if scale > 0 {
      let scale-name = scale-names.at(scale)
      
      // Special handling for "mille" (thousand) - never plural, no "un"
      if scale == 1 {
        // Remove "un" before mille
        if text == "un" {
          text = scale-name
        } else {
          text = text + " " + scale-name
        }
      } else {
        // Million, milliard, etc. are plural if > 1
        if text != "un" {
          text = text + " " + scale-name + "s"
        } else {
          text = "un " + scale-name
        }
      }
    }
    
    result-parts.push(text)
  }
  
  return result-parts.join(" ")
}

#let format-negative(text) = {
  "moins " + text
}

#let lang-config = (
  zero-name: "zéro",
  convert-group: convert-group,
  join-parts: join-parts,
  format-negative: format-negative,
)
