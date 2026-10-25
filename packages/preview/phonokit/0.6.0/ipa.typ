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
    "\\textpipe": "ǀ",
    "!": "ǃ",
    "\\textdoublebarpipe": "ǂ",
    "\\doublebarpipe": "ǂ",
    "||": "ǁ",
    "\\textdoublepipe": "ǁ",
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
    "\\v": "̩", // combining vertical line below (syllabic)
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

  // Below-diacritics clash with descenders (e.g., ŋ̩). IPA convention:
  // place them above instead (ŋ̍, ŋ̊).
  let above_alternates = (
    "̩": "̍", // vertical line below -> vertical line above
    "̥": "̊", // ring below -> ring above
    "̪": "͆", // bridge below -> bridge above (dental)
  )
  let descenders = (
    "g", "ɡ", "j", "p", "q", "y", "ç", "ŋ", "ɲ", "ɳ", "ɱ", "ɟ", "ʝ",
    "ɣ", "ɰ", "ɽ", "ɻ", "ʐ", "ʂ", "ɖ", "ɭ", "ʈ", "ɠ", "ʄ", "ɥ",
    "ʃ", "ʒ", "ʑ", "β", "ɸ", "ɧ",
    "ɺ", // no descender, but marks read better above its long leg
    "Q", // archiphoneme: its tail drops below the baseline
    "ȷ", "ǰ", "ʞ", "ƞ", "ƥ", "ʠ", "ɼ", "ƿ", "þ", "ʆ", "ʓ", "ƫ", "ʤ", "ʧ", "ʥ",
    "ʗ", // stretched c dips below the baseline
    "ʖ", // inverted glottal stop: marks read better above
  )
  let attach = (base, diacritic) => {
    if diacritic in above_alternates and base in descenders {
      above_alternates.at(diacritic)
    } else {
      diacritic
    }
  }

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
          result += attach(mappings.at(token), pending_diacritic)
          pending_diacritic = none
        }
      } else {
        result += token
      }
    } else if token in mappings {
      // No backslash, but the whole token is a mapping (e.g., "||")
      result += mappings.at(token)
      if pending_diacritic != none {
        result += attach(mappings.at(token), pending_diacritic)
        pending_diacritic = none
      }
    } else {
      // No backslash: split into individual characters
      let chars = token.clusters()
      for (idx, char) in chars.enumerate() {
        let out = if char in mappings { mappings.at(char) } else { char }
        result += out
        // Apply pending diacritic to first character only
        if idx == 0 and pending_diacritic != none {
          result += attach(out, pending_diacritic)
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

// Spacing fixes tuned by eye for Charis; other fonts keep their native spacing
#let charis-spacing(body) = {
  // ʲ's tail curls left under the base glyph (pʲ, bʲ): nudge it right
  show "ʲ": it => h(0.06em) + it
  // f, ʃ, ʄ, ʎ, the hooked implosives and the rhotic vowels overhang to the
  // right at the top and collide with superscripts
  // Same for capitals (archiphonemes) whose serifed arms reach the right edge
  show regex("[fʃʄʎɗɠʛɚɝƈƙʠƭƥʧTFVWY][ʰˠʲʷ]"): it => {
    let (base, mark) = it.text.codepoints()
    // The rhotic hook, ʧ and capital arms need less room, except before ʲ
    let small = base in ("ɚ", "ɝ", "ʧ", "T", "F", "V", "W", "Y")
    let gap = if small { 0.06em } else { 0.12em }
    // ʲ already gets 0.06em from the rule above
    if mark == "ʲ" and not small { gap -= 0.06em }
    base + h(gap) + mark
  }
  // The unreleased mark (̚) collides with glyphs that reach the top right
  // (f, ʃ, ʎ, hooks, glottals). It is combining, so it is re-hosted on a word
  // joiner to be pushed right.
  show regex("[fʃʄʎʔʕʡʢɓɗɠʛɦɧƈƙʠƭƥʖʧ]\u{031A}"): it => {
    let (base, mark) = it.text.codepoints()
    // Some reach further right than the rest
    let gap = if base in ("ʄ", "ɗ", "ʛ") { 0.1em } else if base == "ʖ" { 0.07em } else { 0.05em }
    base + h(gap) + "\u{2060}" + mark
  }
  // Ligatures anchor marks on their first letter; re-host them centered.
  // Marks above are raised over the ascender. Widths are Charis advances.
  let ligatures = (ʣ: 0.809, ʥ: 0.809, ʤ: 0.836, ʦ: 0.645, ʧ: 0.575, ʨ: 0.694, ƕ: 0.869)
  show regex("[ʣʥʤʦʧʨƕ][\u{0303}\u{0325}\u{0329}\u{032A}\u{030A}\u{030D}\u{0346}]"): it => {
    let (base, mark) = it.text.codepoints()
    let above = mark in ("\u{0303}", "\u{030A}", "\u{030D}", "\u{0346}")
    let shift = (0.272 - ligatures.at(base) / 2) * 1em
    // ʦ and ʨ start with t, which is shorter than d, h or ʃ
    let raise = if not above { 0em } else if base in ("ʦ", "ʨ") { 0.2em } else { 0.27em }
    base + box(width: 0pt, baseline: -raise, move(dx: shift, "\u{2060}" + mark))
  }
  // Glyphs whose anchors sit too low: marks above touch the hook, long leg or
  // top curve. Re-host the mark on a word joiner, raise it, and center it.
  // A hosted mark draws ~0.272em (half an o) left of the pen.
  // base: (Charis advance width, raise)
  let low-anchors = (
    ɧ: (0.555, 0.27em),
    ɺ: (0.391, 0.33em), // stem top sits right under the mark
    ʃ: (0.355, 0.25em),
    ʆ: (0.355, 0.25em),
  )
  show regex("[ɧɺʃʆ][\u{0303}\u{030A}\u{030D}\u{0346}]"): it => {
    let (base, mark) = it.text.codepoints()
    // ɧ̃ is fine as is
    if base == "ɧ" and mark == "\u{0303}" { return it }
    let (width, raise) = low-anchors.at(base)
    // Shift with move(), not h(): extra inline width lets the mark wrap onto
    // its own line in narrow containers (e.g., table cells)
    base + box(width: 0pt, baseline: -raise, move(dx: (0.272 - width / 2) * 1em, "\u{2060}" + mark))
  }
  body
}

#let ipa(input) = {
  let rendered = ipa-to-unicode(input)
  context {
    metadata(rendered)
    let font = phonokit-font.get()
    // The font may be a name, a fallback list, or (name: .., covers: ..) dicts
    let primary = if type(font) == array { font.first() } else { font }
    if type(primary) == dictionary { primary = primary.name }
    let body = text(font: font, rendered)
    if lower(primary).starts-with("charis") { charis-spacing(body) } else { body }
  }
}
