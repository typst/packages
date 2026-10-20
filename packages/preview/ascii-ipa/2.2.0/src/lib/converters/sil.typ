// https://help.keyman.com/keyboard/sil_ipa/1.8.7/sil_ipa
// https://en.wikipedia.org/wiki/Comparison_of_ASCII_encodings_of_the_International_Phonetic_Alphabet

#let sil-unicode = (
  ("!", "ǃ"),
  ("!<", "ǀ"),
  ("!=", "ǂ"),
  ("!>", "ǁ"),
  ("#!", "ꜞ"),
  ("##!", "ꜟ"),
  ("#&", "͡"),
  ("#<", "ꜜ"),
  ("#<<", "↘"),
  ("#=", "͜"),
  ("#>", "ꜛ"),
  ("#>>", "↗"),
  ("$", "̩"),
  ("$$", "̯"),
  ("$$$", "̰"),
  ("$$$$", "̢"),
  ("%", "̥"),
  ("%%", "̬"),
  ("%%%", "̤"),
  ("%%%%", "̡"),
  ("*", "̈"),
  ("**", "̽"),
  ("***", "̆"),
  ("****", "̇"),
  ("*****", "̐"),
  ("+", "̟"),
  ("++", "̝"),
  ("+++", "̘"),
  ("++++", "̹"),
  (".", "."),
  (".<", "|"),
  (".=", "‖"),
  (":", "ː"),
  ("::", "ˑ"),
  (":::", "ːː"),
  ("=>", "→"),
  ("?<", "ʕ"),
  ("?=", "ʔ"),
  ("@", "̊"),
  ("@&", "͜"),
  ("@0", "̏"),
  ("@1", "̀"),
  ("@12", "᷅"),
  ("@13", "̌"),
  ("@131", "᷈"),
  ("@2", "̄"),
  ("@21", "᷆"),
  ("@23", "᷄"),
  ("@3", "́"),
  ("@31", "̂"),
  ("@313", "᷉"),
  ("@32", "᷇"),
  ("@4", "̋"),
  ("@@", "̍"),
  ("B=", "ʙ"),
  ("E<", "œ"),
  ("E=", "ɘ"),
  ("E>", "ɶ"),
  ("G=", "ɢ"),
  ("G>", "ʛ"),
  ("H=", "ʜ"),
  ("H>", "ɧ"),
  ("I=", "ɨ"),
  ("L<", "ʎ"),
  ("L=", "ʟ"),
  ("L>", "ɺ"),
  ("N=", "ɴ"),
  ("O<", "ɞ"),
  ("O=", "ɵ"),
  ("O>", "ɤ"),
  ("Q<", "ʢ"),
  ("Q=", "ʡ"),
  ("R<", "ɻ"),
  ("R=", "ʀ"),
  ("R>", "ʁ"),
  ("U=", "ʉ"),
  ("[[", "ʽ"),
  ("[[[", "˞"),
  ("]]", "ʼ"),
  ("]]]", "̚"),
  ("]]]]", "ʻ"),
  ("_", "̠"),
  ("__", "̞"),
  ("___", "̙"),
  ("____", "̜"),
  ("_____", "̧"),
  ("a<", "æ"),
  ("a=", "ɑ"),
  ("a>", "ɐ"),
  ("b", "b"),
  ("b=", "β"),
  ("b>", "ɓ"),
  ("c", "c"),
  ("c<", "ɕ"),
  ("c=", "ç"),
  ("d", "d"),
  ("d<", "ɖ"),
  ("d=", "ð"),
  ("d>", "ɗ"),
  ("e", "e"),
  ("e<", "ɛ"),
  ("e=", "ə"),
  ("e>", "ɜ"),
  ("f", "f"),
  ("f=", "ɸ"),
  ("g<", "ɡ"),
  ("g=", "ɣ"),
  ("g>", "ɠ"),
  ("h", "h"),
  ("h<", "ɦ"),
  ("h=", "ɥ"),
  ("h>", "ħ"),
  ("i", "i"),
  ("i=", "ɪ"),
  ("j", "j"),
  ("j<", "ʝ"),
  ("j=", "ɟ"),
  ("j>", "ʄ"),
  ("k", "k"),
  ("l", "l"),
  ("l<", "ɭ"),
  ("l=", "ɬ"),
  ("l>", "ɮ"),
  ("m", "m"),
  ("m>", "ɱ"),
  ("n", "n"),
  ("n<", "ɳ"),
  ("n=", "ɲ"),
  ("n>", "ŋ"),
  ("o", "o"),
  ("o<", "ɔ"),
  ("o=", "ɒ"),
  ("o>", "ø"),
  ("p", "p"),
  ("p=", "ʘ"),
  ("q", "q"),
  ("r", "r"),
  ("r<", "ɽ"),
  ("r=", "ɹ"),
  ("r>", "ɾ"),
  ("s", "s"),
  ("s<", "ʂ"),
  ("s=", "ʃ"),
  ("s>", "σ"),
  ("t", "t"),
  ("t<", "ʈ"),
  ("t=", "θ"),
  ("u", "u"),
  ("u<", "ʊ"),
  ("u=", "ɯ"),
  ("u>", "ʌ"),
  ("v", "v"),
  ("v<", "ⱱ"),
  ("v=", "ʋ"),
  ("w", "w"),
  ("w=", "ʍ"),
  ("w>", "ɰ"),
  ("x", "x"),
  ("x=", "χ"),
  ("y", "y"),
  ("y<", "ɥ"),
  ("y=", "ʏ"),
  ("z", "z"),
  ("z<", "ʐ"),
  ("z=", "ʒ"),
  ("z>", "ʑ"),
  ("{", "̪"),
  ("{{", "̺"),
  ("{{{", "̻"),
  ("{{{{", "̼"),
  ("{{{{{", "̣"),
  ("}", "ˈ"),
  ("}}", "ˌ"),
  ("}}}", "͈"),
  ("}}}}", "᷂"),
  ("~", "̃"),
  ("~~", "̴"),
).sorted(
  key: (pair) => -pair.at(0).len()
)

#let sil-tones = (
  "&": (
    ("0", "꜖"),
    ("1", "꜕"),
    ("2", "꜔"),
    ("3", "꜓"),
    ("4", "꜒"),
  ),
  "#": (
    ("0", "˩"),
    ("1", "˨"),
    ("2", "˧"),
    ("3", "˦"),
    ("4", "˥"),
  ),
)

#let sil-superscript = (
  ("-", "⁻"),
  ("0", "⁰"),
  ("1", "¹"),
  ("2", "²"),
  ("3", "³"),
  ("4", "⁴"),
  ("5", "⁵"),
  ("6", "⁶"),
  ("7", "⁷"),
  ("8", "⁸"),
  ("9", "⁹"),
  ("a", "ᵃ"),
  ("b", "ᵇ"),
  ("c", "ᶜ"),
  ("d", "ᵈ"),
  ("e", "ᵉ"),
  ("f", "ᶠ"),
  ("g", "ᵍ"),
  ("h", "ʰ"),
  ("i", "ⁱ"),
  ("j", "ʲ"),
  ("k", "ᵏ"),
  ("l", "ˡ"),
  ("m", "ᵐ"),
  ("n", "ⁿ"),
  ("o", "ᵒ"),
  ("p", "ᵖ"),
  ("q", "𐞥"),
  ("r", "ʳ"),
  ("s", "ˢ"),
  ("t", "ᵗ"),
  ("u", "ᵘ"),
  ("v", "ᵛ"),
  ("w", "ʷ"),
  ("x", "ˣ"),
  ("y", "ʸ"),
  ("z", "ᶻ"),
  ("¡", "ꜞ"),
  ("æ", "𐞃"),
  ("ç", "ᶜ̧"),
  ("ð", "ᶞ"),
  ("ø", "𐞢"),
  ("ħ", "𐞕"),
  ("ŋ", "ᵑ"),
  ("œ", "ꟹ"),
  ("ǀ", "𐞶"),
  ("ǁ", "𐞷"),
  ("ǂ", "𐞸"),
  ("ǃ", "ꜝ"),
  ("ɐ", "ᵄ"),
  ("ɑ", "ᵅ"),
  ("ɒ", "ᶛ"),
  ("ɓ", "𐞅"),
  ("ɔ", "ᵓ"),
  ("ɖ", "𐞋"),
  ("ɗ", "𐞌"),
  ("ɘ", "𐞎"),
  ("ə", "ᵊ"),
  ("ɛ", "ᵋ"),
  ("ɜ", "ᶟ"),
  ("ɞ", "𐞏"),
  ("ɟ", "ᶡ"),
  ("ɠ", "𐞓"),
  ("ɢ", "𐞒"),
  ("ɣ", "ˠ"),
  ("ɤ", "𐞑"),
  ("ɦ", "ʱ"),
  ("ɨ", "ᶤ"),
  ("ɪ", "ᶦ"),
  ("ɬ", "𐞛"),
  ("ɭ", "ᶩ"),
  ("ɮ", "𐞞"),
  ("ɯ", "ᵚ"),
  ("ɰ", "ᶭ"),
  ("ɱ", "ᶬ"),
  ("ɲ", "ᶮ"),
  ("ɳ", "ᶯ"),
  ("ɴ", "ᶰ"),
  ("ɵ", "ᶱ"),
  ("ɶ", "𐞣"),
  ("ɸ", "ᶲ"),
  ("ɹ", "ʴ"),
  ("ɺ", "𐞦"),
  ("ɻ", "ʵ"),
  ("ɽ", "𐞨"),
  ("ɾ", "𐞩"),
  ("ʀ", "𐞪"),
  ("ʁ", "ʶ"),
  ("ʂ", "ᶳ"),
  ("ʃ", "ᶴ"),
  ("ʄ", "𐞘"),
  ("ʈ", "𐞯"),
  ("ʉ", "ᶶ"),
  ("ʊ", "ᶷ"),
  ("ʋ", "ᶹ"),
  ("ʌ", "ᶺ"),
  ("ʎ", "𐞠"),
  ("ʏ", "𐞲"),
  ("ʐ", "ᶼ"),
  ("ʒ", "ᶾ"),
  ("ʔ", "ˀ"),
  ("ʕ", "ˤ"),
  ("ʘ", "𐞵"),
  ("ʙ", "𐞄"),
  ("ʛ", "𐞔"),
  ("ʜ", "𐞖"),
  ("ʝ", "ᶨ"),
  ("ʟ", "ᶫ"),
  ("ʡ", "𐞳"),
  ("ʢ", "𐞴"),
  ("ʣ", "𐞇"),
  ("ʤ", "𐞊"),
  ("ʦ", "𐞬"),
  ("ʧ", "𐞮"),
  ("ː", "𐞁"),
  ("ˑ", "𐞂"),
  ("β", "ᵝ"),
  ("θ", "ᶿ"),
  ("χ", "ᵡ"),
  ("ᵻ", "ᶧ"),
  ("ᶑ", "𐞍"),
  ("ⱱ", "𐞰"),
  ("ꞎ", "𐞝"),
  ("ꭦ", "𐞈"),
  ("ꭧ", "𐞭"),
  ("𝼄", "𐞜"),
  ("𝼅", "𐞟"),
  ("𝼆", "𐞡"),
  ("𝼈", "𐞧"),
  ("𝼊", "𐞹"),
)

#let sil-subscript = (
  ("0", "₀"),
  ("1", "₁"),
  ("2", "₂"),
  ("3", "₃"),
  ("4", "₄"),
  ("5", "₅"),
  ("6", "₆"),
  ("7", "₇"),
  ("8", "₈"),
  ("9", "₉"),
)

#let sil-retroflex = (
  ("a", "ᶏ"),
  ("ɑ", "ᶐ"),
  ("ɗ", "ᶑ"),
  ("e", "ᶒ"),
  ("ɛ", "ᶓ"),
  ("ɜ", "ᶔ"),
  ("ə", "ᶕ"),
  ("i", "ᶖ"),
  ("ɔ", "ᶗ"),
  ("ʃ", "ᶘ"),
  ("u", "ᶙ"),
  ("ʒ", "ᶚ"),
)

#let sil-palatal = (
  ("b", "ᶀ"),
  ("d", "ᶁ"),
  ("f", "ᶂ"),
  ("ɡ", "ᶃ"),
  ("k", "ᶄ"),
  ("l", "ᶅ"),
  ("m", "ᶆ"),
  ("n", "ᶇ"),
  ("p", "ᶈ"),
  ("r", "ᶉ"),
  ("s", "ᶊ"),
  ("ʃ", "ᶋ"),
  ("v", "ᶌ"),
  ("x", "ᶍ"),
  ("z", "ᶎ"),
)

#let sil-velar-pharyngeal = (
  ("b", "ᵬ"),
  ("d", "ᵭ"),
  ("f", "ᵮ"),
  ("l", "ɫ"),
  ("m", "ᵯ"),
  ("n", "ᵰ"),
  ("p", "ᵱ"),
  ("r", "ᵲ"),
  ("ɾ", "ᵳ"),
  ("s", "ᵴ"),
  ("z", "ᵵ"),
  ("z", "ᵶ"),
)

#let parse-retroflex(text, reverse: false) = {
  if reverse {
    for (normal, retroflex) in sil-retroflex {
      text = text.replace(retroflex, normal + "̢")
    }
  } else {
    for (normal, retroflex) in sil-retroflex {
      text = text.replace(normal + "̢", retroflex)
    }
  }

  return text
}

#let parse-palatal(text, reverse: false) = {
  if reverse {
    for (normal, palatal) in sil-palatal {
      text = text.replace(palatal, normal + "̡")
    }
  } else {
    for (normal, palatal) in sil-palatal {
      text = text.replace(normal + "̡", palatal)
    }
  }

  return text
}

#let parse-velar-pharyngeal(text, reverse: false) = {
  if reverse {
    for (normal, velar-pharyngeal) in sil-velar-pharyngeal {
      text = text.replace(velar-pharyngeal, normal + "̴")
    }
  } else {
    for (normal, velar-pharyngeal) in sil-velar-pharyngeal {
      text = text.replace(normal + "̴", velar-pharyngeal)
    }
  }

  return text
}

#let parse-tones(text, reverse: false) = {
  let left-tones = sil-tones.at("&")
  let right-tones = sil-tones.at("#")

  let (from, to) = if reverse { (1, 0) } else { (0, 1) }

  let get-tone-regex(tones, prefix) = {
    return if reverse {
      regex("((" + tones.map(tone => tone.at(1)).join("|") + "){1, 3})")
    } else {
      regex(prefix + "([0-4]{1, 3})")
    }
  }

  let left-tone-regex = get-tone-regex(left-tones, "&")
  let right-tone-regex = get-tone-regex(right-tones, "#")

  let match-tones(text, regex) = {
    return text
      .matches(regex)
      .dedup(key: (match) => match.text)
      .sorted(key: (match) => -match.captures.at(0).len()) // Avoid partial matches
  }

  let left-matches = match-tones(text, left-tone-regex)
  let right-matches = match-tones(text, right-tone-regex)

  let replace-matches(text, matches, tones, prefix) = {
    for match in matches {
      let replacement = match.captures.at(0)

      for tone in tones {
        replacement = replacement.replace(tone.at(from), tone.at(to))
      }

      if reverse {
        replacement = prefix + replacement
      }

      text = text.replace(match.text, replacement)
    }

    return text
  }

  text = replace-matches(text, left-matches, left-tones, "&")
  text = replace-matches(text, right-matches, right-tones, "#")

  return text
}

#let parse-subscript(text, reverse: false) = {
  if reverse {
    for (normal, sub) in sil-subscript {
      text = text.replace(sub, normal + "̠")
    }
  } else {
    for (normal, sub) in sil-subscript {
      text = text.replace(normal + "̠", sub)
    }
  }

  return text
}

#let parse-superscript(text, reverse: false) = {
  if reverse {
    for (normal, super) in sil-superscript {
      text = text.replace(super, normal + "^")
    }
  } else {
    for (normal, super) in sil-superscript {
      text = text.replace(normal + "^", super)
    }
  }

  return text
}

#let convert-sil(text, reverse: false) = {
  let run-parsers(text) = {
    text = parse-retroflex(text, reverse: reverse)
    text = parse-palatal(text, reverse: reverse)
    text = parse-velar-pharyngeal(text, reverse: reverse)
    text = parse-subscript(text, reverse: reverse)
    text = parse-tones(text, reverse: reverse)

    // requires all previous parsers to run first
    text = parse-superscript(text, reverse: reverse)

    return text
  }

  if reverse {
    text = run-parsers(text)
  }

  let (from, to) = if reverse { (1, 0) } else { (0, 1) }

  for pair in sil-unicode {
    text = text.replace(pair.at(from), pair.at(to))
  }

  if not reverse {
    text = run-parsers(text)
  }

  return text
}
