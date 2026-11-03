/// Spanish number-to-words conversion.
#import "../errors.typ"

/// The language code for this module.
#let _lang-code = "es"

// Cardinal data tables.

/// Words for numbers 0–29. Numbers 16–29 are written as a single word per RAE.
#let _units = (
  "cero",
  "uno",
  "dos",
  "tres",
  "cuatro",
  "cinco",
  "seis",
  "siete",
  "ocho",
  "nueve",
  "diez",
  "once",
  "doce",
  "trece",
  "catorce",
  "quince",
  "dieciséis",
  "diecisiete",
  "dieciocho",
  "diecinueve",
  "veinte",
  "veintiuno",
  "veintidós",
  "veintitrés",
  "veinticuatro",
  "veinticinco",
  "veintiséis",
  "veintisiete",
  "veintiocho",
  "veintinueve",
)

/// Apocopated unit words. Used when "uno"/"veintiuno" precedes a noun-like
/// scale word (mil, millón, …): "uno" → "un", "veintiuno" → "veintiún".
/// All other entries match `_units`.
#let _units-apocopated = (
  "cero",
  "un",
  "dos",
  "tres",
  "cuatro",
  "cinco",
  "seis",
  "siete",
  "ocho",
  "nueve",
  "diez",
  "once",
  "doce",
  "trece",
  "catorce",
  "quince",
  "dieciséis",
  "diecisiete",
  "dieciocho",
  "diecinueve",
  "veinte",
  "veintiún",
  "veintidós",
  "veintitrés",
  "veinticuatro",
  "veinticinco",
  "veintiséis",
  "veintisiete",
  "veintiocho",
  "veintinueve",
)

/// Words for multiples of ten from 30–90. Indexed by `tens-digit - 3`.
#let _tens = (
  "treinta",
  "cuarenta",
  "cincuenta",
  "sesenta",
  "setenta",
  "ochenta",
  "noventa",
)

/// Words for multiples of one hundred from 100–900. Indexed by hundreds digit;
/// index 0 is unused. Note: the form for exactly 100 is "cien", handled inline
/// in `_convert-below-1000`; this table holds the combining form "ciento" for 1.
#let _hundreds = (
  "",
  "ciento",
  "doscientos",
  "trescientos",
  "cuatrocientos",
  "quinientos",
  "seiscientos",
  "setecientos",
  "ochocientos",
  "novecientos",
)

/// Singular long-scale words by 6-digit group index (RAE long scale: each step
/// adds 6 zeros). Index 0 is empty (no scale word at the bottom group).
#let _scales-singular = (
  "",
  "millón",
  "billón",
  "trillón",
  "cuatrillón",
  "quintillón",
  "sextillón",
)

/// Plural long-scale words, paired with `_scales-singular`.
#let _scales-plural = (
  "",
  "millones",
  "billones",
  "trillones",
  "cuatrillones",
  "quintillones",
  "sextillones",
)

// Ordinal data tables.

/// Ordinal forms for 1–9. Index 0 is unused.
#let _ord-units = (
  "",
  "primero",
  "segundo",
  "tercero",
  "cuarto",
  "quinto",
  "sexto",
  "séptimo",
  "octavo",
  "noveno",
)

/// Ordinal forms for tens 10–90, indexed by tens digit. Index 0 is unused.
#let _ord-tens = (
  "",
  "décimo",
  "vigésimo",
  "trigésimo",
  "cuadragésimo",
  "quincuagésimo",
  "sexagésimo",
  "septuagésimo",
  "octogésimo",
  "nonagésimo",
)

/// Ordinal forms for hundreds 100–900, indexed by hundreds digit. Index 0 is unused.
#let _ord-hundreds = (
  "",
  "centésimo",
  "ducentésimo",
  "tricentésimo",
  "cuadringentésimo",
  "quingentésimo",
  "sexcentésimo",
  "septingentésimo",
  "octingentésimo",
  "noningentésimo",
)

/// Ordinal forms for 13–19 (the contemporary fused single-word forms).
/// Indexed by `n - 13`. 11 → "undécimo" and 12 → "duodécimo" are special-cased.
#let _ord-teens = (
  "decimotercero",
  "decimocuarto",
  "decimoquinto",
  "decimosexto",
  "decimoséptimo",
  "decimoctavo",
  "decimonoveno",
)

/// Supported forms for this language module.
#let _supported-forms = ("cardinal", "ordinal")

/// Supported gender values.
#let _supported-genders = ("masculine", "feminine")

// Gender / apocope helpers.

/// Returns the feminine form of a cardinal unit word (0–29). Only "uno" and
/// "veintiuno" inflect; words like "cuatro" or "ocho" end in "o" but are
/// invariable, so the match is on the "uno" suffix specifically.
#let _feminine-unit(word) = if word.ends-with("uno") { word.slice(0, -1) + "a" } else { word }

/// Returns the feminine form of a hundreds word. "ciento" is invariable when
/// used as a combiner; "doscientos"…"novecientos" become "doscientas"…"novecientas".
#let _feminine-hundred(word) = if word.ends-with("os") { word.slice(0, -2) + "as" } else { word }

/// Feminizes every word in a (possibly multi-word) ordinal expression. Every
/// supported ordinal ends in "o", which is replaced by "a".
#let _feminine-ordinal(words) = words.split(" ").map(w => w.slice(0, -1) + "a").join(" ")

/// Returns the apocopated form of a (possibly compound) ordinal: "primero"/
/// "tercero" suffixes drop their final "o". Other ordinals are unchanged.
#let _apocopate-ordinal(word) = if word.ends-with("primero") or word.ends-with("tercero") {
  word.slice(0, -1)
} else {
  word
}

// Cardinal helpers.

/// Converts a number in the range 1–99 to its cardinal word form. The
/// `apocopate` and `feminine` flags control the form of a trailing
/// "uno"/"veintiuno": apocopated ("un"/"veintiún"), feminine ("una"/"veintiuna"),
/// or default masculine. `apocopate` takes precedence (used before "mil").
///
/// - number (int): The number to convert (1–99).
/// - apocopate (bool): Whether to apocopate a trailing "uno".
/// - feminine (bool): Whether to use the feminine form.
/// -> str
#let _convert-below-100(number, apocopate: false, feminine: false) = {
  let unit-word(i) = if apocopate {
    _units-apocopated.at(i)
  } else if feminine {
    _feminine-unit(_units.at(i))
  } else {
    _units.at(i)
  }
  if number < 30 {
    unit-word(number)
  } else {
    let tens-digit = calc.quo(number, 10)
    let units-digit = calc.rem(number, 10)
    if units-digit == 0 {
      _tens.at(tens-digit - 3)
    } else {
      _tens.at(tens-digit - 3) + " y " + unit-word(units-digit)
    }
  }
}

/// Converts a number in the range 1–999 to its cardinal word form. The
/// `apocopate` flag is forwarded to the trailing 1–99 part; it does not affect
/// the 100 -> "cien" rule, which is intrinsic to this helper.
///
/// - number (int): The number to convert (1–999).
/// - apocopate (bool): Whether to apocopate a trailing "uno".
/// - feminine (bool): Whether to use feminine forms for "uno" and the hundreds
///   200–900. "cien"/"ciento" are invariable.
/// -> str
#let _convert-below-1000(number, apocopate: false, feminine: false) = {
  if number < 100 {
    _convert-below-100(number, apocopate: apocopate, feminine: feminine)
  } else {
    let hundreds-digit = calc.quo(number, 100)
    let remainder = calc.rem(number, 100)
    let hundreds-word = if hundreds-digit == 1 and remainder == 0 {
      "cien"
    } else {
      let masc = _hundreds.at(hundreds-digit)
      if feminine { _feminine-hundred(masc) } else { masc }
    }
    if remainder == 0 {
      hundreds-word
    } else {
      hundreds-word + " " + _convert-below-100(remainder, apocopate: apocopate, feminine: feminine)
    }
  }
}

/// Converts a number in the range 1–999_999 (one long-scale group) to its
/// cardinal word form. Splits the number into a thousands part (joined with
/// "mil") and a units part. The thousands part is always apocopated because
/// "mil" follows; the units part is apocopated only if a scale noun follows
/// the entire group (controlled by `apocopate-units`).
///
/// - number (int): The number to convert (1–999_999).
/// - apocopate-units (bool): Whether the units part should apocopate (true
///   when a scale noun like "millón" follows this 6-digit group).
/// - feminine (bool): Whether the chunk modifies a feminine noun. Affects the
///   thousands part (e.g. "veintiuna mil personas") and the units part when no
///   scale word follows; ignored for units when `apocopate-units` is true,
///   since scale nouns (millón, billón…) are masculine.
/// -> str
#let _convert-below-million(number, apocopate-units: false, feminine: false) = {
  let thousands = calc.quo(number, 1000)
  let units = calc.rem(number, 1000)
  let parts = ()
  if thousands == 1 {
    parts.push("mil")
  } else if thousands > 1 {
    let thousands-word = if feminine {
      _convert-below-1000(thousands, feminine: true)
    } else {
      _convert-below-1000(thousands, apocopate: true)
    }
    parts.push(thousands-word + " mil")
  }
  if units > 0 {
    let units-word = if apocopate-units {
      _convert-below-1000(units, apocopate: true)
    } else {
      _convert-below-1000(units, feminine: feminine)
    }
    parts.push(units-word)
  }
  parts.join(" ")
}

/// Recursively splits a number into 6-digit chunks (one long-scale group each)
/// and converts each chunk, appending the appropriate scale word.
///
/// - number (int): The remaining number to convert.
/// - scale-index (int): The current scale index (0 = bottom group, 1 = millones, …).
/// - feminine (bool): Whether the overall number modifies a feminine noun.
///   Only the bottom chunk (scale-index 0) inherits the gender, since scale
///   words (millón, billón…) are masculine and impose their own agreement.
/// -> array
#let _chunk-and-convert(number, scale-index, feminine: false) = {
  if number == 0 {
    ()
  } else {
    errors.out-of-range(scale-index, max: _scales-singular.len() - 1, lang: _lang-code)
    let chunk = calc.rem(number, 1000000)
    let rest = calc.quo(number, 1000000)
    let higher = _chunk-and-convert(rest, scale-index + 1, feminine: feminine)
    if chunk == 0 {
      higher
    } else {
      let words = _convert-below-million(
        chunk,
        apocopate-units: scale-index > 0,
        feminine: feminine and scale-index == 0,
      )
      if scale-index > 0 {
        let scale-word = if chunk == 1 {
          _scales-singular.at(scale-index)
        } else {
          _scales-plural.at(scale-index)
        }
        words = words + " " + scale-word
      }
      higher + (words,)
    }
  }
}

/// Converts a positive integer to its cardinal word form.
///
/// - number (int): The number to convert (>= 1).
/// - feminine (bool): Whether the number modifies a feminine noun.
/// -> str
#let _convert-cardinal(number, feminine: false) = {
  _chunk-and-convert(number, 0, feminine: feminine).join(" ")
}

// Ordinal helpers.

/// Converts a number in the range 1–99 to its ordinal word form (masculine,
/// non-apocopated).
///
/// - number (int): The number to convert (1–99).
/// -> str
#let _convert-ordinal-below-100(number) = {
  if number < 10 {
    _ord-units.at(number)
  } else if number == 10 {
    "décimo"
  } else if number == 11 {
    "undécimo"
  } else if number == 12 {
    "duodécimo"
  } else if number < 20 {
    _ord-teens.at(number - 13)
  } else {
    let tens-digit = calc.quo(number, 10)
    let units-digit = calc.rem(number, 10)
    if units-digit == 0 {
      _ord-tens.at(tens-digit)
    } else {
      _ord-tens.at(tens-digit) + " " + _ord-units.at(units-digit)
    }
  }
}

/// Converts a positive integer in the range 1–999 to its ordinal word form.
/// Panics if `number` is outside [1, 999]. The masculine form is built first
/// and then transformed: `apocopated` drops the final "o" of a trailing
/// "primero"/"tercero"; `feminine` swaps the final "o" of every word for "a".
///
/// - number (int): The number to convert (1–999).
/// - feminine (bool): Whether to return the feminine form.
/// - apocopated (bool): Whether to return the apocopated form (masculine only;
///   the public entry point rejects the feminine combination).
/// -> str
#let _convert-ordinal(number, feminine: false, apocopated: false) = {
  errors.out-of-range(number, min: 1, max: 999, lang: _lang-code)
  let masculine = if number < 100 {
    _convert-ordinal-below-100(number)
  } else {
    let hundreds-digit = calc.quo(number, 100)
    let remainder = calc.rem(number, 100)
    if remainder == 0 {
      _ord-hundreds.at(hundreds-digit)
    } else {
      _ord-hundreds.at(hundreds-digit) + " " + _convert-ordinal-below-100(remainder)
    }
  }
  if apocopated {
    _apocopate-ordinal(masculine)
  } else if feminine {
    _feminine-ordinal(masculine)
  } else {
    masculine
  }
}

// Public entry point.

/// Converts a number to its Spanish word form.
///
/// Cardinals are returned across the full long-scale range. Ordinals are
/// supported within the closed range [1, 999]; values outside that range panic
/// with an out-of-range error.
///
/// `gender` controls grammatical agreement: with `"feminine"`, cardinals
/// produce forms like "una", "veintiuna", "doscientas" (and "veintiuna mil
/// personas"); ordinals end in "-a". Scale nouns (mil, millón, billón…) are
/// invariable and stay masculine.
///
/// `apocopated` is only available for ordinals in masculine. It produces the
/// short form used before a noun: "primer", "tercer", "vigésimo primer",
/// "decimotercer". Combining `apocopated: true` with `gender: "feminine"`
/// panics, since Spanish has no feminine apocopated ordinal.
///
/// - number (int): The number to convert.
/// - form (str): The form: `"cardinal"` (default) or `"ordinal"`.
/// - gender (str): `"masculine"` (default) or `"feminine"`.
/// - apocopated (bool): Use the apocopated ordinal form. Ordinal + masculine only.
/// - negative (str): The prefix for negative numbers (default: `"menos"`).
/// -> str
#let convert(
  number,
  form: "cardinal",
  gender: "masculine",
  apocopated: false,
  negative: "menos",
) = {
  errors.assert-type("form", str, form, lang: _lang-code)
  errors.assert-option("form", form, _supported-forms, lang: _lang-code)
  errors.assert-type("gender", str, gender, lang: _lang-code)
  errors.assert-option("gender", gender, _supported-genders, lang: _lang-code)
  errors.assert-type("apocopated", bool, apocopated, lang: _lang-code)
  errors.assert-type("negative", str, negative, lang: _lang-code)

  let feminine = gender == "feminine"

  if apocopated {
    assert(
      form == "ordinal",
      message: "num2words (es): 'apocopated' is only available for ordinals",
    )
    assert(
      not feminine,
      message: "num2words (es): 'apocopated' is not available for feminine gender",
    )
  }

  if number == 0 and form == "cardinal" {
    "cero"
  } else {
    let prefix = if number < 0 { negative + " " } else { "" }
    let abs-number = calc.abs(number)
    let result = if form == "cardinal" {
      _convert-cardinal(abs-number, feminine: feminine)
    } else {
      _convert-ordinal(abs-number, feminine: feminine, apocopated: apocopated)
    }
    prefix + result
  }
}
