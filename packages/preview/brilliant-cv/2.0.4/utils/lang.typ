#let isNonLatin(lang) = {
  let nonLatinLanguageCode = ("zh", "ja", "ko", "ru")
  return nonLatinLanguageCode.contains(lang)
}
