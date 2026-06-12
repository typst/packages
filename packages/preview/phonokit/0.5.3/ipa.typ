// Convert tipa-style notation to IPA Unicode (without font styling)
// This is exported separately so other modules can use the conversion logic
#let ipa-to-unicode(input) = {
  // Define TIPA to IPA mappings
  let mappings = (
    // CONSONANTS - Plosives
    "p": "p",
    "b": "b",
    "t": "t",
    "d": "d",
    "\\:t": "ʈ",
    "\\:d": "ɖ",
    "\\textbardotlessj": "ɟ",
    "\\barredj": "ɟ",
    "c": "c",
    "k": "k",
    "g": "ɡ",
    "q": "q",
    "\\;G": "ɢ",
    "?": "ʔ",
    "P": "ʔ",
    // CONSONANTS - Nasals
    "m": "m",
    "M": "ɱ",
    "n": "n",
    "\\:n": "ɳ",
    "\\textltailn": "ɲ",
    "N": "ŋ",
    "\\;N": "ɴ",
    "\\nh": "ɲ",
    // CONSONANTS - Trills
    "\\;B": "ʙ",
    "r": "r",
    "\\;R": "ʀ",
    // CONSONANTS - Tap or Flap
    "R": "ɾ",
    "\\:r": "ɽ",
    // CONSONANTS - Fricatives
    "f": "f",
    "v": "v",
    "F": "ɸ",
    "B": "β",
    "T": "θ",
    "D": "ð",
    "s": "s",
    "z": "z",
    "S": "ʃ",
    "Z": "ʒ",
    "\\:s": "ʂ",
    "\\:z": "ʐ",
    "\\c{c}": "ç",
    "C": "ç",
    "J": "ʝ",
    "x": "x",
    "G": "ɣ",
    "X": "χ",
    "K": "ʁ",
    "\\textcrh": "ħ",
    "\\barredh": "ħ",
    "Q": "ʕ",
    "h": "h",
    "H": "ɦ",
    // CONSONANTS - Lateral Fricatives
    "\\textbeltl": "ɬ",
    "\\textlyoghlig": "ɮ",
    "\\l3": "ɮ",
    // CONSONANTS - Approximants
    "V": "ʋ",
    "\\*r": "ɹ",
    "j": "j",
    "\\textturnmrleg": "ɰ",
    "\\mw": "ɰ",
    "\\:R": "ɻ",
    // CONSONANTS - Lateral Approximants
    "l": "l",
    "\\:l": "ɭ",
    "L": "ʎ",
    "\\;L": "ʟ",
    // CONSONANTS - Velarized l
    "\\darkl": "ɫ",
    // OTHER CONSONANTS - Clicks
    "\\!o": "ʘ",
    "\\textdoublebarpipe": "ǂ",
    "\\doublebarpipe": "ǂ",
    "||": "ǁ",
    // OTHER CONSONANTS - Other
    "\\textbarglotstop": "ʡ",
    "\\barredP": "ʡ",
    // OTHER CONSONANTS - Implosives
    "\\!b": "ɓ",
    "\\!d": "ɗ",
    "\\!j": "ʄ",
    "\\!g": "ɠ",
    "\\!G": "ʛ",
    // OTHER CONSONANTS - Additional Fricatives
    "\\*w": "ʍ",
    "\\texththeng": "ɧ",
    "\\;H": "ʜ",
    "\\textctz": "ʑ",
    "\\textbarrevglotstop": "ʢ",
    "\\barrevglotstop": "ʢ",
    // OTHER CONSONANTS - Approximant/Flap
    "\\textturnlonglegr": "ɺ",
    "\\turnlonglegr": "ɺ",
    // VOWELS - Close
    "i": "i",
    "I": "ɪ",
    "y": "y",
    "Y": "ʏ",
    "1": "ɨ",
    "0": "ʉ",
    "W": "ɯ",
    "u": "u",
    "U": "ʊ",
    // VOWELS - Close-mid/Mid
    "e": "e",
    "\\o": "ø",
    "9": "ɘ",
    "8": "ɵ",
    "7": "ɤ",
    "o": "o",
    // VOWELS - Mid
    "@": "ə",
    // VOWELS - Open-mid
    "E": "ɛ",
    "\\oe": "œ",
    "3": "ɜ",
    "\\textcloseepsilon": "ɞ",
    "\\closeepsilon": "ɞ",
    "2": "ʌ",
    "O": "ɔ",
    // VOWELS - Near-open/Open
    "\\ae": "æ",
    "\\OE": "ɶ",
    "a": "a",
    "5": "ɐ",
    "A": "ɑ",
    "6": "ɒ",
    "\\schwar": "ɚ",
    "\\epsilonr": "ɝ",
    // SUPRASEGMENTALS
    "'": "ˈ", // primary stress
    ",": "ˌ", // secondary stress
    ":": "ː", // length mark
    // SPACING
    "\\s": " ", // space
    // ARCHIPHONEMES escaped
    "\\A": "A",
    "\\B": "B",
    "\\C": "C",
    "\\D": "D",
    "\\E": "E",
    "\\F": "F",
    "\\G": "G",
    "\\H": "H",
    "\\I": "I",
    "\\J": "J",
    "\\K": "K",
    "\\L": "L",
    "\\M": "M",
    "\\N": "N",
    "\\O": "O",
    "\\P": "P",
    "\\Q": "Q",
    "\\R": "R",
    "\\S": "S",
    "\\T": "T",
    "\\U": "U",
    "\\V": "V",
    "\\W": "W",
    "\\X": "X",
    "\\Y": "Y",
    "\\Z": "Z",
    // TIPA LONG-FORM ALTERNATIVES AND ADDITIONAL SYMBOLS
    // A
    "\\textturna": "ɐ",
    "\\textscripta": "ɑ",
    "\\textturnscripta": "ɒ",
    "\\textsca": "ᴀ",
    "\\;A": "ᴀ",
    "\\textturnv": "ʌ",
    // B
    "\\texthtb": "ɓ",
    "\\textscb": "ʙ",
    "\\textcrb": "ƀ",
    "\\textbarb": "ƀ",
    "\\textbeta": "β",
    "\\textsoftsign": "ь",
    "\\texthardsign": "ъ",
    // C
    "\\textbarc": "ȼ",
    "\\texthtc": "ƈ",
    "\\v{c}": "č",
    "\\textctc": "ɕ",
    "\\textstretchc": "ʗ",
    // D
    "\\textcrd": "đ",
    "\\textbard": "đ",
    "\\texthtd": "ɗ",
    "\\textrtaild": "ɖ",
    "\\textctd": "ȡ",
    "\\textdzlig": "ʣ",
    "\\textdctzlig": "ʥ",
    "\\textdyoghlig": "ʤ",
    "\\dh": "ð",
    // E
    "\\textschwa": "ə",
    "\\textrhookschwa": "ɚ",
    "\\textreve": "ɘ",
    "\\textsce": "ᴇ",
    "\\;E": "ᴇ",
    "\\textepsilon": "ɛ",
    "\\textrevepsilon": "ɜ",
    "\\textrhookrevepsilon": "ɝ",
    "\\textcloserevepsilon": "ɞ",
    // G
    "\\textg": "ɡ",
    "\\textbarg": "ǥ",
    "\\textcrg": "ǥ",
    "\\texthtg": "ɠ",
    "\\textscg": "ɢ",
    "\\texthtscg": "ʛ",
    "\\textgamma": "ɣ",
    "\\textbabygamma": "ɤ",
    "\\textramshorns": "ɤ",
    // H
    "\\texthvlig": "ƕ",
    "\\texthth": "ɦ",
    "\\textturnh": "ɥ",
    "4": "ɥ",
    "\\textsch": "ʜ",
    // I
    "\\i": "ı",
    "\\textbari": "ɨ",
    "\\textiota": "ɩ",
    "\\textlhti": "ɩ",
    "\\textsci": "ɪ",
    // J
    "\\j": "ȷ",
    "\\textctj": "ʝ",
    "\\textscj": "ᴊ",
    "\\;J": "ᴊ",
    "\\v{\\j}": "ǰ",
    "\\textObardotlessj": "ɟ",
    "\\texthtbardotlessj": "ʄ",
    // K
    "\\texthtk": "ƙ",
    "\\textturnk": "ʞ",
    // L
    "\\textltilde": "ɫ",
    "\\textbarl": "ł",
    "\\textrtaill": "ɭ",
    "\\textOlyoghlig": "ɮ",
    "\\textscl": "ʟ",
    "\\textlambda": "λ",
    "\\textcrlambda": "ƛ",
    // M
    "\\textltailm": "ɱ",
    "\\textturnm": "ɯ",
    // N
    "\\textnrleg": "ƞ",
    "\\ng": "ŋ",
    "\\textrtailn": "ɳ",
    "\\textctn": "ȵ",
    "\\textscn": "ɴ",
    // O
    "\\textbullseye": "ʘ",
    "\\textbaro": "ɵ",
    "\\textscoelig": "ɶ",
    "\\textopeno": "ɔ",
    "\\textomega": "ω",
    "\\textcloseomega": "ɷ",
    // P
    "\\textwynn": "ƿ",
    "\\textthorn": "þ",
    "\\th": "þ",
    "\\texthtp": "ƥ",
    "\\textphi": "ɸ",
    // Q
    "\\texthtq": "ʠ",
    // R
    "\\textfishhookr": "ɾ",
    "\\textlonglegr": "ɼ",
    "\\textrtailr": "ɽ",
    "\\textturnr": "ɹ",
    "\\textturnrrtail": "ɻ",
    "\\textscr": "ʀ",
    "\\textinvscr": "ʁ",
    // S
    "\\v{s}": "š",
    "\\textrtails": "ʂ",
    "\\textesh": "ʃ",
    "\\textctesh": "ʆ",
    // T
    "\\texthtt": "ƭ",
    "\\textlhookt": "ƫ",
    "\\textrtailt": "ʈ",
    "\\texttctclig": "ʨ",
    "\\texttslig": "ʦ",
    "\\texteshlig": "ʧ",
    "\\textturnt": "ʇ",
    "\\textctt": "ȶ",
    "\\texttheta": "θ",
    // U
    "\\textbaru": "ʉ",
    "\\textupsilon": "ʊ",
    "\\textscu": "ᴜ",
    "\\;U": "ᴜ",
    // V
    "\\textscriptv": "ʋ",
    // W
    "\\textturnw": "ʍ",
    // X
    "\\textchi": "χ",
    // Y
    "\\textturny": "ʎ",
    "\\textscy": "ʏ",
    // Z
    "\\textcommatailz": "ʐ",
    "\\v{z}": "ž",
    "\\textrevyogh": "ʕ",
    "\\textrtailz": "ʐ",
    "\\textyogh": "ʒ",
    "\\textctyogh": "ʓ",
    "\\textcrtwo": "ƻ",
    "\\textglotstop": "ʔ",
    "\\textraiseglotstop": "ˀ",
    "\\textinvglotstop": "ʖ",
    "\\textrevglotstop": "ʕ",
  )

  // Define combining diacritics
  // Forward-looking: precede the phoneme in input (e.g., \~ a → ã)
  let forward_diacritics = (
    "\\~": "̃", // combining tilde (nasalization)
    "\\r": "̥", // combining ring below (devoicing)
    "\\v": "̩", // combining vertical line below (voicing)
    "\\t": "͡", // combining double inverted breve (tie bar for affricates)
    "\\dental": "̪", // no trailing space
  )

  // Backward-looking: follow the phoneme in input (e.g., p \h → pʰ)
  let backward_diacritics = (
    "\\*": "̚", // combining left angle above (unreleased)
    "\\h": "ʰ", // modifier letter small h (aspirated)
    "\\velar": "ˠ",
    "\\palatal": "ʲ",
    "\\labial": "ʷ",
    "\\ej": "ʼ", // modifier letter apostrophe (ejective)
  )

  // Split by spaces and process each token
  let tokens = input.split(" ")
  let result = ""
  let i = 0
  let pending_diacritic = none

  while i < tokens.len() {
    let token = tokens.at(i)

    // Check if this token is a forward-looking diacritic
    if token in forward_diacritics {
      // Store it to apply to next character
      pending_diacritic = forward_diacritics.at(token)
    } else if token in backward_diacritics {
      // Apply immediately to previous character
      result += backward_diacritics.at(token)
    } else if token.contains("\\") {
      // Backslash command
      if token in mappings {
        result += mappings.at(token)
        // Apply pending diacritic if any
        if pending_diacritic != none {
          result += pending_diacritic
          pending_diacritic = none
        }
      } else {
        result += token
      }
    } else {
      // No backslash: split into individual characters
      let chars = token.clusters()
      for (idx, char) in chars.enumerate() {
        if char in mappings {
          result += mappings.at(char)
        } else {
          result += char
        }
        // Apply pending diacritic to first character only
        if idx == 0 and pending_diacritic != none {
          result += pending_diacritic
          pending_diacritic = none
        }
      }
    }

    i += 1
  }

  result
}

// Main IPA function: converts tipa-style notation to IPA
#import "_config.typ": phonokit-font

#let ipa(input) = {
  context {
    text(font: phonokit-font.get(), ipa-to-unicode(input))
  }
}
