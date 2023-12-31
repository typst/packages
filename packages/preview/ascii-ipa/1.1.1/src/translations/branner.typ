// adaptation of https://github.com/tirimid/ipa-translate/blob/master/translations/branner.rs

#let branner-translations = (
  // vowels part 1.
  ("i-", "ɨ"),
  ("e&", "ɘ"),
  ("E&", "ɜ"),
  ("E\"", "ɞ"),
  ("a\"&", "ɒ"),
  ("a\"", "ɑ"),
  ("a&", "ɐ"),
  ("ae)", "æ"),
  ("c&", "ɔ"),
  ("o/)", "ø"),
  ("oe)", "œ"),
  ("OE)", "ɶ"),
  ("o-", "ɵ"),
  ("u-", "ʉ"),
  ("v&", "ʌ"),
  ("U\"", "ɤ"),
  ("m&", "ɯ"),
  ("xr^", "ɚ"),

  // consonants part 1.
  ("tr)", "ʈ"),
  ("dr)", "ɖ"),
  ("j-", "ɟ"),
  ("m\"", "ɱ"),
  ("nr)", "ɳ"),
  ("nj)", "ɲ"),
  ("ng)", "ŋ"),
  ("r\"", "ɾ"),
  ("rr)", "ɽ"),
  ("P\"", "ɸ"),
  ("B\"", "β"),
  ("O-", "θ"),
  ("d-", "ð"),
  ("3\"", "ʒ"),
  ("sr)", "ʂ"),
  ("zr)", "ʐ"),
  ("c\"", "ç"),
  ("j\"", "ʝ"),
  ("g\"", "ɣ"),
  ("R%", "ʁ"),
  ("h-", "ħ"),
  ("?&", "ʕ"),
  ("h\"", "ɦ"),
  ("l-", "ɬ"),
  ("l3\")", "ɮ"),
  ("v\"", "ʋ"),
  ("r&", "ɹ"),
  ("jr)", "ɻ"),
  ("m&\"", "ɰ"),
  ("lr)", "ɭ"),
  ("y&", "ʎ"),
  ("b$", "ɓ"),
  ("d$", "ɗ"),
  ("j$", "ʄ"),
  ("g$", "ɠ"),
  ("G$", "ʛ"),
  ("w&", "ʍ"),
  ("h&", "ɥ"),
  ("?-", "ʡ"),
  ("?\"", "ʢ"),
  ("Sx)", "ɧ"),
  ("p!", "ʘ"),
  ("t!", "ǀ"),
  ("r!", "ǃ"),
  ("c!", "ǂ"),
  ("l!", "ǁ"),
  ("l\"", "ɺ"),
  ("ci)", "ɕ"),
  ("zi)", "ʑ"),
  ("l~)", "ɫ"),

  // diacritics.
  ("`", "ʼ"),
  ("V)", "̥"),
  ("v)", "̬"),
  ("h^", "ʰ"),
  ("h\")", "̤"),
  ("~^", "̃"),
  ("~)", "̴"),
  ("~", "̰"),
  ("{", "̼"),
  ("[]", "̻"),
  ("[", "̪"),
  ("]", "̺"),
  ("u)", "̹"),
  ("U)", "̜"),
  ("+", "̟"),
  ("_", "̠"),
  ("\"^", "̈"),
  ("x^", "̽"),
  ("<", "̘"),
  (">", "̙"),
  ("r^", "˞"),
  ("w^", "ʷ"),
  ("j^", "ʲ"),
  ("&g^", "ˤ"),
  ("g^", "ˠ"),
  ("n^", "ⁿ"),
  ("l^", "ˡ"),
  (".)", "̚"),
  ("=\"", "̞"),
  ("=)", "͜"),
  ("=", "̝"),
  (",)", "̩"),
  ("(", "̯"),

  // not implemented according to description.
  // branner describes this being placed after two segments: `ts))`.
  // in this implementation, it is placed in the middle: `t))s`.
  ("))", "͡"),

  ("'", "ˈ"),
  (",", "ˌ"),
  (":", "ː"),
  (";", "ˑ"),
  ("(^", "̆"),
  (".", "."),
  ("||", "‖"),
  ("|", "|"),
  ("/)", "ꜛ"),
  ("\\)", "ꜜ"),
  ("/", "↗"),
  ("\\", "↘"),
  ("15", "̌"),
  ("51", "̂"),
  ("35", "᷄"),
  ("13", "᷅"),
  ("342", "᷈"),
  ("5", "̋"),
  ("4", "́"),
  ("3", "̄"),
  ("2", "̀"),
  ("1", "̏"),

  // vowels part 2.
  ("i", "i"),
  ("e", "e"),
  ("E", "ɛ"),
  ("a", "a"),
  ("o", "o"),
  ("u", "u"),
  ("y", "y"),
  ("I", "ɪ"),
  ("Y", "ʏ"),
  ("U", "ʊ"),
  ("@", "ə"),

  // consonants part 2.
  ("p", "p"),
  ("b", "b"),
  ("t", "t"),
  ("d", "d"),
  ("c", "c"),
  ("k", "k"),
  ("g", "ɡ"),
  ("q", "q"),
  ("G", "ɢ"),
  ("?", "ʔ"),
  ("m", "m"),
  ("n", "n"),
  ("N", "ɴ"),
  ("B", "ʙ"),
  ("r", "r"),
  ("R", "ʀ"),
  ("f", "f"),
  ("v", "v"),
  ("s", "s"),
  ("z", "z"),
  ("S", "ʃ"),
  ("x", "x"),
  ("X", "χ"),
  ("h", "h"),
  ("j", "j"),
  ("l", "l"),
  ("L", "ʟ"),
  ("w", "w"),
  ("H", "ʜ"),
)
