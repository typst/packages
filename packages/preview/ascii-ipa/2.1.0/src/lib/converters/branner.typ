// https://web.archive.org/web/19990209070257/http://weber.u.washington.edu/~yuenren/ASCII_IPA.html
// https://en.wikipedia.org/wiki/Comparison_of_ASCII_encodings_of_the_International_Phonetic_Alphabet

#let branner-unicode = (
  ("&g^", "ˤ"),
  ("'", "ˈ"),
  ("(", "̯"),
  ("(^", "̆"),
  ("+", "̟"),
  (",", "ˌ"),
  (",)", "̩"),
  (".", "."),
  (".)", "̚"),
  ("/", "↗"),
  ("/)", "ꜛ"),
  ("1", "̏"),
  ("13", "᷅"),
  ("15", "̌"),
  ("2", "̀"),
  ("3", "̄"),
  ("342", "᷈"),
  ("35", "᷄"),
  ("3\"", "ʒ"),
  ("4", "́"),
  ("5", "̋"),
  ("51", "̂"),
  (":", "ː"),
  (";", "ˑ"),
  ("<", "̘"),
  ("=", "̝"),
  ("=)", "‿"),
  ("=\"", "̞"),
  (">", "̙"),
  ("?", "ʔ"),
  ("?&", "ʕ"),
  ("?&-", "ʢ"),
  ("?-", "ʡ"),
  ("?\"", "ʢ"),
  ("@", "ə"),
  ("B", "ʙ"),
  ("B\"", "β"),
  ("E", "ɛ"),
  ("E&", "ɜ"),
  ("E\"", "ɞ"),
  ("G", "ɢ"),
  ("G$", "ʛ"),
  ("H", "ʜ"),
  ("I", "ɪ"),
  ("L", "ʟ"),
  ("N", "ɴ"),
  ("O-", "θ"),
  ("OE)", "ɶ"),
  ("P\"", "ɸ"),
  ("Q&-", "ʢ"),
  ("R", "ʀ"),
  ("R%", "ʁ"),
  ("S", "ʃ"),
  ("Sx)", "ɧ"),
  ("U", "ʊ"),
  ("U)", "̜"),
  ("U\"", "ɤ"),
  ("V)", "̥"),
  ("X", "χ"),
  ("Y", "ʏ"),
  ("[", "̪"),
  ("[]", "̻"),
  ("\"^", "̈"),
  ("\\", "↘"),
  ("\\)", "ꜜ"),
  ("]", "̺"),
  ("_", "̠"),
  ("`", "ʼ"),
  ("a", "a"),
  ("a&", "ɐ"),
  ("a\"", "ɑ"),
  ("a\"&", "ɒ"),
  ("ae)", "æ"),
  ("b", "b"),
  ("b$", "ɓ"),
  ("c!", "ǂ"),
  ("c", "c"),
  ("c&", "ɔ"),
  ("c\"", "ç"),
  ("ci)", "ɕ"),
  ("d", "d"),
  ("d$", "ɗ"),
  ("d-", "ð"),
  ("dr)", "ɖ"),
  ("e", "e"),
  ("e&", "ɘ"),
  ("f", "f"),
  ("g", "ɡ"),
  ("g$", "ɠ"),
  ("g\"", "ɣ"),
  ("g^", "ˠ"),
  ("h", "h"),
  ("h&", "ɥ"),
  ("h-", "ħ"),
  ("h\"", "ɦ"),
  ("h\")", "̤"),
  ("h^", "ʰ"),
  ("i", "i"),
  ("i-", "ɨ"),
  ("j", "j"),
  ("j$", "ʄ"),
  ("j-", "ɟ"),
  ("j\"", "ʝ"),
  ("j^", "ʲ"),
  ("jr)", "ɻ"),
  ("k", "k"),
  ("l!", "ǁ"),
  ("l", "l"),
  ("l-", "ɬ"),
  ("l3\")", "ɮ"),
  ("l\"", "ɺ"),
  ("l^", "ˡ"),
  ("lr)", "ɭ"),
  ("l~)", "ɫ"),
  ("m", "m"),
  ("m&", "ɯ"),
  ("m&\"", "ɰ"),
  ("m\"", "ɱ"),
  ("n", "n"),
  ("n^", "ⁿ"),
  ("ng)", "ŋ"),
  ("nj)", "ɲ"),
  ("nr)", "ɳ"),
  ("o", "o"),
  ("o-", "ɵ"),
  ("o/)", "ø"),
  ("oe)", "œ"),
  ("p!", "ʘ"),
  ("p", "p"),
  ("q", "q"),
  ("r!", "ǃ"),
  ("r", "r"),
  ("r&", "ɹ"),
  ("r\"", "ɾ"),
  ("r^", "˞"),
  ("rr)", "ɽ"),
  ("s", "s"),
  ("sr)", "ʂ"),
  ("t!", "ǀ"),
  ("t", "t"),
  ("tr)", "ʈ"),
  ("u", "u"),
  ("u)", "̹"),
  ("u-", "ʉ"),
  ("v", "v"),
  ("v&", "ʌ"),
  ("v)", "̬"),
  ("v\"", "ʋ"),
  ("w", "w"),
  ("w&", "ʍ"),
  ("w^", "ʷ"),
  ("x", "x"),
  ("x^", "̽"),
  ("xr^", "ɚ"),
  ("y", "y"),
  ("y&", "ʎ"),
  ("z", "z"),
  ("zi)", "ʑ"),
  ("zr)", "ʐ"),
  ("{", "̼"),
  ("|", "|"),
  ("||", "‖"),
  ("~", "̰"),
  ("~)", "̴"),
  ("~^", "̃"),
).sorted(
  key: (pair) => -pair.at(0).len()
)

#let parse-tiebar(text, reverse: false) = {
  let tiebar = if reverse { regex("(.)͡(.)") } else { regex("(.)(.)\)\)") }

  let transform = if reverse {
    (match) => match.captures.at(0) + match.captures.at(1) + "))"
  } else {
    (match) => match.captures.at(0) + "͡" + match.captures.at(1)
  }

  let unique-matches = text.matches(tiebar).dedup(key: (match) => match.text)

  for match in unique-matches {
    text = text.replace(match.text, transform(match))
  }

  return text
}

#let convert-branner(text, reverse: false) = {
  let (from, to) = if reverse { (1, 0) } else { (0, 1) }

  if reverse {
    text = parse-tiebar(text, reverse: true)
  }

  for pair in branner-unicode {
    text = text.replace(pair.at(from), pair.at(to))
  }

  if not reverse {
    text = parse-tiebar(text, reverse: false)
  }

  return text
}
