#import "utils.typ": *

#let rufish(
  words,
  type: "lorem"
) = {
  let default-types = json("../data.json")
  if type == "lorem" {
    return transliterate(lorem(words))
  }
  if type not in default-types {
    panic("Type '" + type + "' is not available")
  }
  if words == 0 {
    return ""
  }
  if words < 0 {
    panic("Words count must be positive")
  }
  let text = default-types.at(type)
  let text = text.join(" ")
  let repeated_text = get-text-with-length(text, words)
  let repeated_text = emplace_dot(repeated_text)
  return repeated_text
}
