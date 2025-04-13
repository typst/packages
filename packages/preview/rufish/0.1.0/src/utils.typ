#let transliterate(text) = {
  let mapping = (
    ("a", "а"), ("b", "б"), ("c", "ц"), ("d", "д"), ("e", "е"),
    ("f", "ф"), ("g", "г"), ("h", "х"), ("i", "и"), ("j", "й"),
    ("k", "к"), ("l", "л"), ("m", "м"), ("n", "н"), ("o", "о"),
    ("p", "п"), ("q", "к"), ("r", "р"), ("s", "с"), ("t", "т"),
    ("u", "у"), ("v", "в"), ("w", "в"), ("x", "кс"), ("y", "й"),
    ("z", "з")
  )
  let result = ""
  for char in text.split("") {
      let found = false
      for (key, val) in mapping {
          if lower(char) == key {
              if (char == upper(char)) {
                  result += upper(val)
              } else {
                  result += val
              }
              found = true
              break
          }
      }
      if not found {
        result += char
      }
  }
  return result
}

#let get-text-with-length(text, length) = {
  if length == 0 or text == "" {
    return text
  }
  
  let words = text.split(" ")
  let current_length = words.len()
  
  if current_length < length {
    let repetitions = calc.floor(length / current_length)
    let remainder = length - (repetitions * current_length)
    
    let result = (words * repetitions)
    
    if remainder > 0 {
      result += words.slice(0, remainder)
    }
    
    return result.join(" ")
  } else {
    return words.slice(0, length).join(" ")
  }
}

#let emplace_dot(text) = {
  let last_symbol = text.split("").at(-2)
  if last_symbol != "." {
    if last_symbol in ":;,(-" {
      text = text.slice(0, -1).trim()
    }
    if last_symbol not in "!?" {
      text += "."
    }
  }
  return text
}