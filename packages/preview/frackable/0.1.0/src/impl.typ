#let _generate-symbol(
  super,
  sub
) = {
  (:
    "superscript": super,
    "subscript": sub,
  )
}

#let symbols = (:
  "0": _generate-symbol("⁰", "₀"),
  "1": _generate-symbol("¹", "₁"),
  "2": _generate-symbol("²", "₂"),
  "3": _generate-symbol("³", "₃"),
  "4": _generate-symbol("⁴", "₄"),
  "5": _generate-symbol("⁵", "₅"),
  "6": _generate-symbol("⁶", "₆"),
  "7": _generate-symbol("⁷", "₇"),
  "8": _generate-symbol("⁸", "₈"),
  "9": _generate-symbol("⁹", "₉"),
)

#let premade = (:
  "1/2": "½",
  "1/3": "⅓",
  "2/3": "⅔",
  "1/4": "¼",
  "3/4": "¾",
  "1/5": "⅕",
  "2/5": "⅖",
  "3/5": "⅗",
  "4/5": "⅘",
  "1/6": "⅙",
  "5/6": "⅚",
  "1/7": "⅐",
  "1/8": "⅛",
  "3/8": "⅜",
  "5/8": "⅝",
  "7/8": "⅞",
  "1/9": "⅑",
  "1/10": "⅒",
)

#let _assert-keys = symbols.keys()
#let _assert-valid(s) = {
  for char in s.codepoints() {
    if char not in _assert-keys {
      panic("Unsupported character " + char)
    }
  }
}

/// Create vulgar fractions using unicode
/// #example(```typ
/// #frackable()
/// #frackable(denominator: 3)
/// #frackable(numerator: 9, denominator: 16)
/// #frackable(numerator: 31, denominator: 32)
/// #frackable(numerator: 0, denominator: "000")
/// ```, scale-preview: 200%)
/// 
/// - numerator (integer, string): The top part of the fraction.
/// - denominator (integer, string): The bottom part of the fraction.
/// - use-predefined (boolean): While this function can typeset arbitrary vulgar
///       fractions, there are some for which there is a predefined unicode
///       codepoint that is prioritized. Set this value to false to prevent
///       predefined codepoints being used.
/// 
///       #example(```typ
///       #frackable() \
///       #frackable(use-predefined: false)
///       ```, scale-preview: 75%)
/// -> content
#let frackable(
  numerator: 1,
  denominator: 2,
  use-predefined: true
) = {
  (numerator, denominator) = (str(numerator), str(denominator))
  _assert-valid(numerator)
  _assert-valid(denominator)
  
  if use-predefined {
    let predefined = premade.at(
      numerator + "/" + denominator,
      default: none
    )
    if predefined != none {return predefined}
  }
  
  box({
    numerator.codepoints().map(char=>{symbols.at(char).superscript}).join()
    [⁄]
    denominator.codepoints().map(char=>{symbols.at(char).subscript}).join()
  })
}
