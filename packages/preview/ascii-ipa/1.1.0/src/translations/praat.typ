// adaptation of https://github.com/tirimid/ipa-translate/blob/master/translations/praat.rs

#let praat-translations = (
  // understrike diacritics.
  ("\\|v", "̩"),
  ("\\0v", "̥"),
  ("\\Tv", "̞"),
  ("\\T^", "̝"),
  ("\\T(", "̘"),
  ("\\T)", "̙"),
  ("\\-v", "̱"),
  ("\\+v", "̟"),
  ("\\:v", "̤"),
  ("\\~v", "̰"),
  ("\\Nv", "̪"),
  ("\\Uv", "̺"),
  ("\\Dv", "̻"),
  ("\\nv", "̯"),
  ("\\3v", "̹"),
  ("\\cv", "̜"),

  // overstrike diacritics.
  ("\\0^", "̊"),
  ("\\'^", "́"),
  ("\\`^", "̀"),
  ("\\-^", "̄"),
  ("\\~^", "̃"),
  ("\\v^", "̌"),
  ("\\^^", "̂"),
  ("\\:^", "̈"),
  ("\\x^", "̽"),
  ("\\N^", "̆"),
  ("\\li", "͡"),
  ("\\_u", "‿"),

  // inline diacritics.
  ("\\:f", "ː"),
  ("\\.f", "ˑ"),
  ("\\'1", "ˈ"),
  ("\\'2", "ˌ"),
  ("\\|f", "|"),
  ("\\cn", "̚"),
  ("\\hr", "˞"),
  ("\\ap", "ʼ"),

  // superscript diacritics.
  ("\\^h", "ʰ"),
  ("\\^H", "ʱ"),
  ("\\^j", "ʲ"),
  ("\\^g", "ˠ"),
  ("\\^M", "ᵚ"),
  ("\\^G", "ᶭ"),
  ("\\^w", "ʷ"),
  ("\\^Y", "ᶣ"),
  ("\\^?", "ˀ"),
  ("\\^9", "ˁ"),
  ("\\^l", "ˡ"),
  ("\\^n", "ⁿ"),
  ("\\^m", "ᵐ"),
  ("\\^N", "ᵑ"),
  ("\\^s", "ˢ"),
  ("\\^x", "ˣ"),
  ("\\^f", "ᶠ"),
  ("\\^y", "ʸ"),

  // digraphs.
  ("\\ts", "ʦ"),
  ("\\tS", "ʧ"),

  // consonants part 1.
  ("t^l", "tˡ"),
  ("\\t.", "ʈ"),
  ("\\?-", "ʡ"),
  ("\\?g", "ʔ"),
  ("d^l", "dˡ"),
  ("\\d.", "ɖ"),
  ("\\j-", "ɟ"),
  ("\\gs", "ɡ"),
  ("\\gc", "ɢ"),
  ("\\mj", "ɱ"),
  ("\\n.", "ɳ"),
  ("\\nj", "ɲ"),
  ("\\ng", "ŋ"),
  ("\\nc", "ɴ"),
  ("\\ff", "ɸ"),
  ("\\tf", "θ"),
  ("\\l-", "ɬ"),
  ("\\sh", "ʃ"),
  ("\\s.", "ʂ"),
  ("\\cc", "ɕ"),
  ("\\c.", "ç"),
  ("\\wt", "ʍ"),
  ("\\cf", "χ"),
  ("\\h-", "ħ"),
  ("\\hc", "ʜ"),
  ("\\bf", "β"),
  ("\\dh", "ð"),
  ("\\lz", "ɮ"),
  ("\\zh", "ʒ"),
  ("\\z.", "ʐ"),
  ("\\zc", "ʑ"),
  ("\\jc", "ʝ"),
  ("\\gf", "ɣ"),
  ("\\ri", "ʁ"),
  ("\\9e", "ʕ"),
  ("\\9-", "ʢ"),
  ("\\h^", "ɦ"),
  ("\\vs", "ʋ"),
  ("\\rt", "ɹ"),
  ("\\r.", "ɻ"),
  ("\\ht", "ɥ"),
  ("\\ml", "ɰ"),
  ("\\bc", "ʙ"),
  ("\\rc", "ʀ"),
  ("\\fh", "ɾ"),
  ("\\rl", "ɺ"),
  ("\\f.", "ɽ"),
  ("\\l.", "ɭ"),
  ("\\yt", "ʎ"),
  ("\\lc", "ʟ"),
  ("\\b^", "ɓ"),
  ("\\d^", "ɗ"),
  ("\\j^", "ʄ"),
  ("\\g^", "ɠ"),
  ("\\G^", "ʛ"),
  ("\\O.", "ʘ"),
  ("\\|1", "ǀ"),
  ("\\|2", "ǁ"),
  ("\\|-", "ǂ"),
  ("\\l~", "ɫ"),
  ("\\hj", "ɧ"),

  // vowels part 1.
  ("\\i-", "ɨ"),
  ("\\u-", "ʉ"),
  ("\\mt", "ɯ"),
  ("\\ic", "ɪ"),
  ("\\yc", "ʏ"),
  ("\\hs", "ʊ"),
  ("\\o/", "ø"),
  ("\\e-", "ɘ"),
  ("\\o-", "ɵ"),
  ("\\rh", "ɤ"),
  ("\\sw", "ə"),
  ("\\ef", "ɛ"),
  ("\\oe", "œ"),
  ("\\er", "ɜ"),
  ("\\kb", "ɞ"),
  ("\\vt", "ʌ"),
  ("\\ct", "ɔ"),
  ("\\ae", "æ"),
  ("\\at", "ɐ"),
  ("\\Oe", "ɶ"),
  ("\\as", "ɑ"),
  ("\\ab", "ɒ"),
  ("\\sr", "ɚ"),
  ("\\id", "ɿ"),
  ("\\ir", "ʅ"),

  // consonants part 2.
  ("p", "p"),
  ("t", "t"),
  ("c", "c"),
  ("k", "k"),
  ("q", "q"),
  ("b", "b"),
  ("d", "d"),
  ("m", "m"),
  ("n", "n"),
  ("f", "f"),
  ("s", "s"),
  ("x", "x"),
  ("h", "h"),
  ("v", "v"),
  ("z", "z"),
  ("l", "l"),
  ("j", "j"),
  ("w", "w"),
  ("r", "r"),
  ("!", "ǃ"),

  // vowels part 2.
  ("i", "i"),
  ("y", "y"),
  ("u", "u"),
  ("e", "e"),
  ("o", "o"),
  ("a", "a"),
)
