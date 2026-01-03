#import "languages/en.typ" 
#import "languages/id.typ" 

#let languages = (
  "en": en.lang-config,
  "id": id.lang-config,
)

#let name-it(num, lang: "en", ..options) = {
  // assert types
  assert(
    type(num) == int or (type(num) == str and num.contains(regex("^[-−]?\d+$"))),
    message: "Argument must be a number or a valid string of a number"
  )

  assert(
    lang in languages,
    message: "Language '" + lang + "' is not supported. Create a issue or help contribute in `https://github.com/IrregularPersona/name-all-the-numbers`"
  )
  let config = languages.at(lang)

  // Convert to string and handle negative
  let num-str = str(num)
  let is-negative = false

  if num-str.len() > 0 {
    let first-char = num-str.clusters().at(0)
    if first-char in ("-", "−") {
      is-negative = true
      num-str = num-str.clusters().slice(1).join()
    }
  }

  // Remove leading zeros manually (to handle very large numbers)
  num-str = num-str.trim("0", at: start, repeat: true)
  
  // Handle case where all digits were zeros
  if num-str == "" {
    return if is-negative {
      config.format-negative(config.zero-name)
    } else {
      config.zero-name
    }
  }
  
  // Pad to multiple of 3
  let remainder = calc.rem(num-str.len(), 3)
  if remainder != 0 {
    num-str = (3 - remainder) * "0" + num-str
  }

  let group-count = int(num-str.len() / 3)
  let parts = ()

  for group-idx in range(group-count) {
    let group-digits = num-str.slice(group-idx * 3, count: 3)
    let scale-idx = group-count - 1 - group-idx

    let group-text = (config.convert-group)(group-digits, scale-idx, options)

    if group-text != none and group-text.trim() != "" {
      parts.push((
        text: group-text,
        scale: scale-idx,
      ))
    }
  }

  let result = (config.join-parts)(parts, options)

  if is-negative {
    result = (config.format-negative)(result)
  }

  return result
}
