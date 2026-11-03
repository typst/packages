/// English (American) number-to-words conversion.
#import "../errors.typ"

/// The language code for this module.
#let _lang-code = "en"

// -- Data tables --

/// Words for numbers 0–19.
#let _units = (
  "zero",
  "one",
  "two",
  "three",
  "four",
  "five",
  "six",
  "seven",
  "eight",
  "nine",
  "ten",
  "eleven",
  "twelve",
  "thirteen",
  "fourteen",
  "fifteen",
  "sixteen",
  "seventeen",
  "eighteen",
  "nineteen",
)

/// Words for multiples of ten from 20–90.
#let _tens = (
  "twenty",
  "thirty",
  "forty",
  "fifty",
  "sixty",
  "seventy",
  "eighty",
  "ninety",
)

/// Scale words for groups of three digits (short scale).
#let _scales = (
  "",
  "thousand",
  "million",
  "billion",
  "trillion",
  "quadrillion",
  "quintillion",
  "sextillion",
  "septillion",
  "octillion",
  "nonillion",
  "decillion",
  "undecillion",
  "duodecillion",
  "tredecillion",
  "quattuordecillion",
  "quindecillion",
  "sexdecillion",
  "septendecillion",
  "octodecillion",
  "novemdecillion",
  "vigintillion",
)

/// Cardinal words whose ordinal form is irregular.
#let _ordinal-irregulars = (
  one: "first",
  two: "second",
  three: "third",
  five: "fifth",
  eight: "eighth",
  nine: "ninth",
  twelve: "twelfth",
)

/// Supported forms for this language module.
#let _supported-forms = ("cardinal", "ordinal", "year")

// -- Cardinal helpers --

/// Converts a number in the range 1–99 to its cardinal word form.
///
/// - number (int): The number to convert (1–99).
/// -> str
#let _convert-below-100(number) = {
  if number < 20 {
    _units.at(number)
  } else {
    let tens-digit = calc.quo(number, 10)
    let units-digit = calc.rem(number, 10)
    if units-digit == 0 {
      _tens.at(tens-digit - 2)
    } else {
      _tens.at(tens-digit - 2) + "-" + _units.at(units-digit)
    }
  }
}

/// Converts a number in the range 1–999 to its cardinal word form.
///
/// - number (int): The number to convert (1–999).
/// -> str
#let _convert-below-1000(number) = {
  if number < 100 {
    _convert-below-100(number)
  } else {
    let hundreds-digit = calc.quo(number, 100)
    let remainder = calc.rem(number, 100)
    if remainder == 0 {
      _units.at(hundreds-digit) + " hundred"
    } else {
      _units.at(hundreds-digit) + " hundred " + _convert-below-100(remainder)
    }
  }
}

/// Recursively splits a number into 3-digit chunks and converts each chunk,
/// appending the appropriate scale word.
///
/// - number (int): The remaining number to convert.
/// - scale-index (int): The current scale index (0 = units, 1 = thousands, etc.).
/// -> array
#let _chunk-and-convert(number, scale-index) = {
  if number == 0 {
    ()
  } else {
    errors.out-of-range(scale-index, max: _scales.len() - 1, lang: _lang-code)
    let chunk = calc.rem(number, 1000)
    let rest = calc.quo(number, 1000)
    let higher = _chunk-and-convert(rest, scale-index + 1)
    if chunk == 0 {
      higher
    } else {
      let words = _convert-below-1000(chunk)
      if scale-index > 0 {
        words = words + " " + _scales.at(scale-index)
      }
      higher + (words,)
    }
  }
}

/// Converts a positive integer to its cardinal word form.
///
/// - number (int): The number to convert (>= 1).
/// -> str
#let _convert-cardinal(number) = {
  _chunk-and-convert(number, 0).join(" ")
}

// -- Ordinal helpers --

/// Converts a single cardinal word to its ordinal form.
///
/// - word (str): The cardinal word to ordinalize.
/// -> str
#let _ordinalize(word) = {
  if word in _ordinal-irregulars {
    _ordinal-irregulars.at(word)
  } else if word.ends-with("y") {
    word.slice(0, word.len() - 1) + "ieth"
  } else {
    word + "th"
  }
}

/// Transforms a full cardinal string into its ordinal form by ordinalizing
/// only the last word (handling hyphenated compounds like "forty-two").
///
/// - cardinal (str): The cardinal string to transform.
/// -> str
#let _cardinal-to-ordinal(cardinal) = {
  let tokens = cardinal.split(" ")
  let last = tokens.last()
  if "-" in last {
    let parts = last.split("-")
    let ordinal-part = _ordinalize(parts.last())
    let new-last = (
      parts.slice(0, parts.len() - 1).join("-") + "-" + ordinal-part
    )
    if tokens.len() == 1 {
      new-last
    } else {
      tokens.slice(0, tokens.len() - 1).join(" ") + " " + new-last
    }
  } else {
    let ordinal-last = _ordinalize(last)
    if tokens.len() == 1 {
      ordinal-last
    } else {
      tokens.slice(0, tokens.len() - 1).join(" ") + " " + ordinal-last
    }
  }
}

/// Converts a positive integer to its ordinal word form.
///
/// - number (int): The number to convert (>= 1).
/// -> str
#let _convert-ordinal(number) = {
  let cardinal = _convert-cardinal(number)
  _cardinal-to-ordinal(cardinal)
}

// -- Year helpers --

/// Converts a positive integer to its year reading form.
///
/// - number (int): The number to convert (>= 1).
/// -> str
#let _convert-year(number) = {
  if number < 1000 {
    _convert-cardinal(number)
  } else if number < 10000 {
    let high = calc.quo(number, 100)
    let low = calc.rem(number, 100)
    if calc.rem(number, 1000) == 0 {
      _convert-cardinal(number)
    } else if low == 0 {
      _convert-below-100(high) + " hundred"
    } else if high == 20 and low < 10 {
      "two thousand " + _convert-below-100(low)
    } else if low < 10 {
      _convert-below-100(high) + " oh " + _units.at(low)
    } else {
      _convert-below-100(high) + " " + _convert-below-100(low)
    }
  } else {
    _convert-cardinal(number)
  }
}

// -- Public entry point --

/// Converts a number to its English word form.
///
/// - number (int): The number to convert.
/// - form (str): The form: `"cardinal"`, `"ordinal"`, or `"year"` (default: `"cardinal"`).
/// - negative (str): The prefix for negative numbers (default: `"negative"`).
/// -> str
#let convert(number, form: "cardinal", negative: "negative") = {
  errors.assert-type("form", str, form, lang: _lang-code)
  errors.assert-form(form, _supported-forms, _lang-code)
  errors.assert-type("negative", str, negative, lang: _lang-code)

  if number == 0 {
    if form == "ordinal" {
      "zeroth"
    } else {
      "zero"
    }
  } else {
    let prefix = if number < 0 { negative + " " } else { "" }
    let abs-number = calc.abs(number)
    let result = if form == "cardinal" {
      _convert-cardinal(abs-number)
    } else if form == "ordinal" {
      _convert-ordinal(abs-number)
    } else {
      _convert-year(abs-number)
    }
    prefix + result
  }
}
