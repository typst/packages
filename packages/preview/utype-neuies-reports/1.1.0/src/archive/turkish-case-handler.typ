/* ARCHIVE: src/core/turkish-case-handler.typ
// Only Turkish special characters mapping (lowercase -> uppercase)
#let _lower-to-upper-special-char-map-tr = (
  "i": "İ",
  "ı": "I",
  "ğ": "Ğ",
  "ü": "Ü",
  "ş": "Ş",
  "ö": "Ö",
  "ç": "Ç",
)

// Create reverse mapping (uppercase -> lowercase)
#let _upper-to-lower-special-char-map-tr = {
  let map = (:)
  for (key, value) in _lower-to-upper-special-char-map-tr {
    map.insert(value, key)
  }
  map
}

// Words that should remain lowercase in titles according to TDK
#let _special-lowercase-words-tr = (
  // Connecting words
  "ve", // and
  "ile", // with
  "ya", // or
  "veya", // or
  "yahut", // or
  "ki", // that
  // Suffixes
  "da", // too/also
  "de", // too/also
  // Question particles
  "mı", // question particle
  "mi", // question particle
  "mu", // question particle
  "mü", // question particle
)

#let lower-case-tr(text) = {
  let text = str(text)
  text = text.replace(
    regex("[" + _upper-to-lower-special-char-map-tr.keys().join() + "]"),
    char => _upper-to-lower-special-char-map-tr.at(char.text),
  )
  return lower(text)
}

#let upper-case-tr(text) = {
  let text = str(text)
  text = text.replace(
    regex("[" + _lower-to-upper-special-char-map-tr.keys().join() + "]"),
    char => _lower-to-upper-special-char-map-tr.at(char.text),
  )
  return upper(text)
}

#let title-case-tr(text, all-caps: false) = {
  // If all-caps is true, convert everything to uppercase
  if all-caps {
    return upper-case-tr(text)
  }

  // Split text into words and process each
  let words = text.split(" ")
  let result = words
    .enumerate()
    .map(((i, word)) => {
      if word.len() == 0 {
        return word
      }

      // Convert word to lowercase
      let lower-word = lower-case-tr(word)

      // Keep certain words lowercase unless they're at the start
      if i != 0 and (lower-word in _special-lowercase-words-tr) {
        lower-word
      } else {
        let first-char = word.first()
        upper-case-tr(first-char) + lower-case-tr(word.trim(first-char, at: start, repeat: false))
      }
    })
    .join(" ")

  result
}
