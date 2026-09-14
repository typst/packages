#import "utils.typ": types, _err, _is-err

#let _matches(c, regex) = c.find(regex) != none

// See https://github.com/typst/typst/blob/d6b0d68ffa4963459f52f7d774080f1f128841d4/crates/typst-layout/src/math/text.rs#L185
#let _styled-char(
  ctx,
  /// -> str
  c,
  auto-italic: false,
  bold: false,
  /// -> bool | auto
  italic: auto,
  /// one of "serif", "sans", "cal", "frak", "mono" or "bb"
  /// -> str
  variant: "serif",
) = {
  if c.clusters().len() != 1 {
    _err(ctx, "expected a single character but got " + c.clusters().len() + ": " + c)
  }
  let matches = _matches.with(c)
  let italic = if italic == auto {
    (auto-italic
      and matches(regex("[a-zħıȷA-Zα-ω∂ϵϑϰϕϱϖ]"))
      and (variant == "sans" or variant == "serif"))
  } else {
    italic
  }

  // basic exception
  let basic-exception = (
    "〈": "⟨",
    "〉": "⟩",
    "《": "⟪",
    "》": "⟫",
  )
  if c in basic-exception {
    return basic-exception.at(c)
  }

  // latin-exception
  if (c, variant, bold) == ("B", "cal", false) { return "ℬ" }
  else if (c, variant, bold) == ("E", "cal", false) { return "ℰ" }
  else if (c, variant, bold) == ("F", "cal", false) { return "ℱ" }
  else if (c, variant, bold) == ("H", "cal", false) { return "ℋ" }
  else if (c, variant, bold) == ("I", "cal", false) { return "ℐ" }
  else if (c, variant, bold) == ("L", "cal", false) { return "ℒ" }
  else if (c, variant, bold) == ("M", "cal", false) { return "ℳ" }
  else if (c, variant, bold) == ("R", "cal", false) { return "ℛ" }
  else if (c, variant, bold) == ("C", "frak", false) { return "ℭ" }
  else if (c, variant, bold) == ("H", "frak", false) { return "ℌ" }
  else if (c, variant, bold) == ("I", "frak", false) { return "ℑ" }
  else if (c, variant, bold) == ("R", "frak", false) { return "ℜ" }
  else if (c, variant, bold) == ("Z", "frak", false) { return "ℨ" }
  else if (c, variant) == ("C", "bb") { return "ℂ" }
  else if (c, variant) == ("H", "bb") { return "ℍ" }
  else if (c, variant) == ("N", "bb") { return "ℕ" }
  else if (c, variant) == ("P", "bb") { return "ℙ" }
  else if (c, variant) == ("Q", "bb") { return "ℚ" }
  else if (c, variant) == ("R", "bb") { return "ℝ" }
  else if (c, variant) == ("Z", "bb") { return "ℤ" }
  else if (c, variant, italic) == ("D", "bb", true) { return "ⅅ" }
  else if (c, variant, italic) == ("d", "bb", true) { return "ⅆ" }
  else if (c, variant, italic) == ("e", "bb", true) { return "ⅇ" }
  else if (c, variant, italic) == ("i", "bb", true) { return "ⅈ" }
  else if (c, variant, italic) == ("j", "bb", true) { return "ⅉ" }
  else if (c, variant, bold, italic) == ("h", "serif", false, true) { return "ℎ" }
  else if (c, variant, bold) == ("e", "cal", false) { return "ℯ" }
  else if (c, variant, bold) == ("g", "cal", false) { return "ℊ" }
  else if (c, variant, bold) == ("o", "cal", false) { return "ℴ" }
  else if (c, variant, italic) == ("ħ", "serif", true) { return "ℏ" }
  else if (c, variant, italic) == ("ı", "serif", true) { return "𝚤" }
  else if (c, variant, italic) == ("ȷ", "serif", true) { return "𝚥" }

  // greek-exception
  if c == "Ϝ" and variant == "serif" and bold {
      return "𝟊";
  }
  if c == "ϝ" and variant == "serif" and bold {
      return "𝟋";
  }
  let list = if c == "ϴ" { ("𝚹", "𝛳", "𝜭", "𝝧", "𝞡", "ϴ") }
    else if c == "∇" { ("𝛁", "𝛻", "𝜵", "𝝯", "𝞩", "∇") }
    else if c == "∂" { ("𝛛", "𝜕", "𝝏", "𝞉", "𝟃", "∂") }
    else if c == "ϵ" { ("𝛜", "𝜖", "𝝐", "𝞊", "𝟄", "ϵ") }
    else if c == "ϑ" { ("𝛝", "𝜗", "𝝑", "𝞋", "𝟅", "ϑ") }
    else if c == "ϰ" { ("𝛞", "𝜘", "𝝒", "𝞌", "𝟆", "ϰ") }
    else if c == "ϕ" { ("𝛟", "𝜙", "𝝓", "𝞍", "𝟇", "ϕ") }
    else if c == "ϱ" { ("𝛠", "𝜚", "𝝔", "𝞎", "𝟈", "ϱ") }
    else if c == "ϖ" { ("𝛡", "𝜛", "𝝕", "𝞏", "𝟉", "ϖ") }
    else if c == "Γ" { ("𝚪", "𝛤", "𝜞", "𝝘", "𝞒", "ℾ") }
    else if c == "γ" { ("𝛄", "𝛾", "𝜸", "𝝲", "𝞬", "ℽ") }
    else if c == "Π" { ("𝚷", "𝛱", "𝜫", "𝝥", "𝞟", "ℿ") }
    else if c == "π" { ("𝛑", "𝜋", "𝝅", "𝝿", "𝞹", "ℼ") }
    else if c == "∑" { ("∑", "∑", "∑", "∑", "∑", "⅀") }
    else { none }
  if list != none {
    if (variant, bold, italic) == ("serif", true, false) { return list.at(0) }
    else if (variant, bold, italic) == ("serif", false, true) { return list.at(1) }
    else if (variant, bold, italic) == ("serif", true, true) { return list.at(2) }
    else if (variant, italic) == ("sans", true) { return list.at(3) }
    else if (variant, italic) == ("sans", false) { return list.at(4) }
    else if variant == "bb" { return list.at(5) }
  }

  let base = if matches(regex("[A-Z]")) { "A" }
  else if matches(regex("[a-z]")) { "a" }
  else if matches(regex("[Α-Ω]")) { "Α" }
  else if matches(regex("[α-ω]")) { "α" }
  else if matches(regex("[0-9]")) { "0" }
  else if matches(regex("[\\u05D0-\\u05D3]")) { "\u{05D0}" } // Hebrew Alef -> Dalet.
  else { return c }

  let start = if matches(regex("[A-Z]")) {
    // Latin upper.
    if (variant, bold, italic) == ("serif", false, false) { 0x0041 }
    else if (variant, bold, italic) == ("serif", true, false) { 0x1D400 }
    else if (variant, bold, italic) == ("serif", false, true) { 0x1D434 }
    else if (variant, bold, italic) == ("serif", true, true) { 0x1D468 }
    else if (variant, bold, italic) == ("sans", false, false) { 0x1D5A0 }
    else if (variant, bold, italic) == ("sans", true, false) { 0x1D5D4 }
    else if (variant, bold, italic) == ("sans", false, true) { 0x1D608 }
    else if (variant, bold, italic) == ("sans", true, true) { 0x1D63C }
    else if (variant, bold) == ("cal", false) { 0x1D49C }
    else if (variant, bold) == ("cal", true) { 0x1D4D0 }
    else if (variant, bold) == ("frak", false) { 0x1D504 }
    else if (variant, bold) == ("frak", true) { 0x1D56C }
    else if variant == "mono" { 0x1D670 }
    else if variant == "bb" { 0x1D538 }
    else { return _err(ctx, "unreachable", c, variant, bold, italic) }
  } else if matches(regex("[a-z]")){
    // Latin lower.
    if (variant, bold, italic) == ("serif", false, false) { 0x0061 }
    else if (variant, bold, italic) == ("serif", true, false) { 0x1D41A }
    else if (variant, bold, italic) == ("serif", false, true) { 0x1D44E }
    else if (variant, bold, italic) == ("serif", true, true) { 0x1D482 }
    else if (variant, bold, italic) == ("sans", false, false) { 0x1D5BA }
    else if (variant, bold, italic) == ("sans", true, false) { 0x1D5EE }
    else if (variant, bold, italic) == ("sans", false, true) { 0x1D622 }
    else if (variant, bold, italic) == ("sans", true, true) { 0x1D656 }
    else if (variant, bold) == ("cal", false) { 0x1D4B6 }
    else if (variant, bold) == ("cal", true) { 0x1D4EA }
    else if (variant, bold) == ("frak", false) { 0x1D51E }
    else if (variant, bold) == ("frak", true) { 0x1D586 }
    else if variant == "mono" { 0x1D68A }
    else if variant == "bb" { 0x1D552 }
    else { return _err(ctx, "unreachable", c, variant, bold, italic) }
  } else if matches(regex("[Α-Ω]")) {
    // Greek upper.
    if (variant, bold, italic) == ("serif", false, false) { 0x0391 }
    else if (variant, bold, italic) == ("serif", true, false) { 0x1D6A8 }
    else if (variant, bold, italic) == ("serif", false, true) { 0x1D6E2 }
    else if (variant, bold, italic) == ("serif", true, true) { 0x1D71C }
    else if (variant, italic) == ("sans", false) { 0x1D756 }
    else if (variant, italic) == ("sans", true) { 0x1D790 }
    else { return c }
  } else if matches(regex("[α-ω]")) {
    // Greek lower.
    if (variant, bold, italic) == ("serif", false, false) { 0x03B1 }
    else if (variant, bold, italic) == ("serif", true, false) { 0x1D6C2 }
    else if (variant, bold, italic) == ("serif", false, true) { 0x1D6FC }
    else if (variant, bold, italic) == ("serif", true, true) { 0x1D736 }
    else if (variant, italic) == ("sans", false) { 0x1D770 }
    else if (variant, italic) == ("sans", true) { 0x1D7AA }
    else { return c }
  } else if matches(regex("[\\u05D0-\\u05D3]")) {
    0x2135 // Hebrew Alef -> Dalet.
  } else if matches(regex("[0-9]")) {
    // Numbers.
    if (variant, bold) == ("serif", false) { 0x0030 }
    else if (variant, bold) == ("serif", true) { 0x1D7CE }
    else if variant == "bb" { 0x1D7D8 }
    else if (variant, bold) == ("sans", false) { 0x1D7E2 }
    else if (variant, bold) == ("sans", true) { 0x1D7EC }
    else if variant == "mono" { 0x1D7F6 }
    else { return c }
  } else {
    return _err(ctx, "unreachable", c)
  }
 
  str.from-unicode(start + (str.to-unicode(c) - str.to-unicode(base)))
}

/// see <https://github.com/typst/typst/blob/d6b0d68ffa4963459f52f7d774080f1f128841d4/crates/typst-utils/src/lib.rs#L345>
/// for most unicode values only `large` and `relation` will be correct.
#let _default-math-class(
  ctx,
  c
) = {
  if c.clusters().len() != 1 {
    return _err(ctx, "expected a single character but got " + c.clusters().len() + ": " + c)
  }
  if c == ":" {
    "relation"
  } else if c == "⋯" or c == "⋱" or c == "⋰" or c == "⋮" {
    "normal"
  } else if c == "." or c == "/" {
    "normal"
  } else if c == "\u{22A5}" { // UP TACK
    "normal"
  } else if c == "⅋" {
    "binary"
  } else if c == "⎰" or c == "⟅" {
    "opening"
  } else if c == "⎱" or c == "⟆" {
    "closing"
  } else if c == "⟇" {
    "binary"
  } else {
    // see https://www.unicode.org/Public/math/revision-15/MathClass-15.txt
    let cp = c.to-unicode()
    if (0x0606,0x0607,0x2140,0x220F,0x2210,0x2211,0x221A,0x221B,0x221C,0x222B,0x222C,0x222D,0x222E,0x222F,0x2230,0x2231,0x2232,0x2233,0x22C0,0x22C1,0x22C2,0x22C3,0x27CC,0x27D5,0x27D6,0x27D7,0x27D8,0x27D9,0x29F8,0x29F9,0x2AFC,0x2AFF,0x1EEF0,0x1EEF1).contains(cp) {
      "large"
    } else if 0x2A00 <= cp and cp <= 0x2A21 {
      "large"
    } else if (0x3C,0x3D,0x3E,0x2020,0x2021,0x204F,0x2050,0x221D,0x22A2,0x22A3,0x22C8,0x22CD,0x22D0,0x22D1,0x2322,0x2323,0x23b0,0x23b1,0x27CD,0x27d2,0x27d3,0x27d4,0x29DF,0x29E1,0x29F4,0x2A59,0xAF2,0xAF3,0x2B95).contains(cp) {
      "relation"
    } else {
      for (start, end) in (
        (0x2190,0x21B3),
        (0x21BA,0x21FF),
        (0x2208,0x220D),
        (0x2223,0x2226),
        (0x2234,0x2237),
        (0x2239,0x223D),
        (0x2241,0x228B),
        (0x228F,0x2292),
        (0x22A5,0x22B8),
        (0x22D4,0x22FF),
        (0x233F,0x237C),
        (0x27C2,0x27CB),
        (0x27DA,0x27DF),
        (0x27F0,0x297F),
        (0x29CE,0x29D5),
        (0x29E3,0x29E6),
        (0x2A66,0x2A70),
        (0x2A73,0x2AE0),
        (0x2AE2,0x2AF0),
        (0x2AF7,0x2AFA),
        (0x2B00,0x2B11),
        (0x2B30,0x2B44),
        (0x2B47,0x2B4C),
      ) {
        if start <= cp and cp <= end {
          return "relation"
        }
      }
      // FIXME try harder
      none
    }
  }
}


/// determine if the base has limits
/// -> "never" | "display" | "always"
///
/// see `https://github.com/typst/typst/blob/d6b0d68ffa4963459f52f7d774080f1f128841d4/crates/typst-layout/src/math/fragment.rs#L628`
#let _limits-for-char(ctx, c) = {
  let matches = _matches.with(c)
  let class = _default-math-class(ctx, c)
  if _is-err(ctx, class) { return class }
  if class == "large" {
    if matches(regex("[∫-∳]|[⨋-⨜]")) { // is integral
      "never"
    } else {
      "display"
    }
  } else if class == "relation" {
    "always"
  } else {
    "never"
  }
}

/// The default limit configuration for a math class.
/// -> "never" | "display" | "always"
///
/// see `https://github.com/typst/typst/blob/d6b0d68ffa4963459f52f7d774080f1f128841d4/crates/typst-layout/src/math/fragment.rs#L643`
#let _limits_for_class(class) = {
  if class == "large" {
    "display"
  } else if class == "relation" {
    "always"
  } else {
    "never"
  }
}

#let _is-space(val) = {
  let s = sym.space
  let spaces = (s, s.en, s.quad, s.fig, s.punct, s.thin, s.hair, s.nobreak, s.med, s.nobreak.narrow, s.third, s.quarter, s.sixth, sym.zws)
  if type(val) == content {
    if val.func() == text {
      _is-space(val.text)
    } else if val.func() == types.symbol {
      _is-space(val.text)
    } else if val.func() == types.space {
      true
    } else {
      false
    }
  } else if type(val) == symbol {
    val in spaces
  } else {
    val in spaces.map(str)
  }
}

