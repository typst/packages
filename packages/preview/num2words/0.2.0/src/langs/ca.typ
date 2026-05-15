/// Catalan number-to-words conversion.
#import "../errors.typ"

/// The language code for this module.
#let _lang-code = "ca"

// Cardinal data tables.

/// Words for numbers 0–19. Numbers 16–19 are single irregular words in Catalan
/// (`setze`, `disset`, `divuit`, `dinou`).
#let _units = (
  "zero",
  "u",
  "dos",
  "tres",
  "quatre",
  "cinc",
  "sis",
  "set",
  "vuit",
  "nou",
  "deu",
  "onze",
  "dotze",
  "tretze",
  "catorze",
  "quinze",
  "setze",
  "disset",
  "divuit",
  "dinou",
)

/// Apocopated unit words. Used when the trailing "u" precedes a noun-like
/// element (a scale word `mil`/`milió`/… or a noun in the document): "u" → "un".
/// All other entries match `_units`.
#let _units-apocopated = (
  "zero",
  "un",
  "dos",
  "tres",
  "quatre",
  "cinc",
  "sis",
  "set",
  "vuit",
  "nou",
  "deu",
  "onze",
  "dotze",
  "tretze",
  "catorze",
  "quinze",
  "setze",
  "disset",
  "divuit",
  "dinou",
)

/// Words for multiples of ten from 30–90. Indexed by `tens-digit - 3`.
#let _tens = (
  "trenta",
  "quaranta",
  "cinquanta",
  "seixanta",
  "setanta",
  "vuitanta",
  "noranta",
)

/// Words for multiples of one hundred from 100–900. Indexed by hundreds digit;
/// index 0 is unused. The same form is used both alone (100 → "cent") and as
/// the leading element of a 1XX number (101 → "cent u"); there is no separate
/// combining form in Catalan.
#let _hundreds = (
  "",
  "cent",
  "dos-cents",
  "tres-cents",
  "quatre-cents",
  "cinc-cents",
  "sis-cents",
  "set-cents",
  "vuit-cents",
  "nou-cents",
)

/// Singular long-scale words by 6-digit group index (long scale: each step
/// adds 6 zeros). Index 0 is empty (no scale word at the bottom group).
#let _scales-singular = (
  "",
  "milió",
  "bilió",
  "trilió",
  "quatrilió",
  "quintilió",
  "sextilió",
)

/// Plural long-scale words, paired with `_scales-singular`.
#let _scales-plural = (
  "",
  "milions",
  "bilions",
  "trilions",
  "quatrilions",
  "quintilions",
  "sextilions",
)

// Ordinal data tables.

/// Standalone ordinal forms for 1–9 (masculine). Index 0 is unused.
#let _ord-units = (
  "",
  "primer",
  "segon",
  "tercer",
  "quart",
  "cinquè",
  "sisè",
  "setè",
  "vuitè",
  "novè",
)

/// Compound-ordinal forms for the trailing unit 1–9 used inside hyphenated
/// blocks like "vint-i-unè" or "trenta-dosè". Differs from `_ord-units` only
/// for 1–4 (`unè`, `dosè`, `tresè`, `quatrè` instead of `primer`…`quart`).
#let _ord-units-compound = (
  "",
  "unè",
  "dosè",
  "tresè",
  "quatrè",
  "cinquè",
  "sisè",
  "setè",
  "vuitè",
  "novè",
)

/// Ordinal forms for 10–19, indexed by `n - 10`.
#let _ord-teens-and-ten = (
  "desè",
  "onzè",
  "dotzè",
  "tretzè",
  "catorzè",
  "quinzè",
  "setzè",
  "dissetè",
  "divuitè",
  "dinovè",
)

/// Ordinal forms for tens 10–90, indexed by tens digit. Index 0 is unused.
#let _ord-tens = (
  "",
  "desè",
  "vintè",
  "trentè",
  "quarantè",
  "cinquantè",
  "seixantè",
  "setantè",
  "vuitantè",
  "norantè",
)

/// Fused ordinal forms for hundreds 100–900, indexed by hundreds digit. Used
/// when the number is an exact multiple of 100. Index 0 is unused.
#let _ord-hundreds = (
  "",
  "centè",
  "dos-centè",
  "tres-centè",
  "quatre-centè",
  "cinc-centè",
  "sis-centè",
  "set-centè",
  "vuit-centè",
  "nou-centè",
)

/// Supported forms for this language module.
#let _supported-forms = ("cardinal", "ordinal")

/// Supported gender values.
#let _supported-genders = ("masculine", "feminine")

// Gender / apocope helpers.

/// Returns the feminine form of a cardinal unit word. Only "u" and "dos"
/// inflect: "u" → "una", "dos" → "dues". Compound forms ending in "-u" or
/// "-dos" (e.g. "vint-i-u", "trenta-dos") inflect at the suffix.
#let _feminine-unit(word) = if word == "u" or word.ends-with("-u") {
  word.slice(0, -1) + "una"
} else if word == "dos" or word.ends-with("-dos") {
  word.slice(0, -3) + "dues"
} else {
  word
}

/// Returns the feminine form of a hundreds word. "cent" is invariable;
/// "dos-cents" → "dues-centes" (both prefix and suffix inflect); the rest
/// "tres-cents"…"nou-cents" only change the suffix to "-centes".
#let _feminine-hundred(word) = if word == "cent" {
  "cent"
} else if word == "dos-cents" {
  "dues-centes"
} else {
  word.slice(0, -5) + "centes"
}

/// Feminizes the last token of a (possibly multi-word) ordinal expression:
/// trailing "-è" becomes "-ena"; the standalone forms `primer`/`segon`/
/// `tercer`/`quart` get a final "a". All preceding tokens stay unchanged.
#let _feminine-ordinal(words) = {
  let parts = words.split(" ")
  let last-idx = parts.len() - 1
  let last = parts.at(last-idx)
  let new-last = if last.ends-with("è") {
    last.trim("è", at: end) + "ena"
  } else {
    last + "a"
  }
  if last-idx == 0 {
    new-last
  } else {
    parts.slice(0, last-idx).join(" ") + " " + new-last
  }
}

// Cardinal helpers.

/// Converts a number in the range 0–99 to its cardinal word form. The
/// `apocopate` and `feminine` flags control the form of a trailing "u"/"dos":
/// apocopated ("un"), feminine ("una"/"dues"), or default ("u"/"dos").
/// `apocopate` takes precedence over `feminine`.
///
/// - number (int): The number to convert (0–99).
/// - apocopate (bool): Whether to apocopate a trailing "u".
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
  if number < 20 {
    unit-word(number)
  } else if number == 20 {
    "vint"
  } else if number < 30 {
    "vint-i-" + unit-word(number - 20)
  } else {
    let tens-digit = calc.quo(number, 10)
    let units-digit = calc.rem(number, 10)
    if units-digit == 0 {
      _tens.at(tens-digit - 3)
    } else {
      _tens.at(tens-digit - 3) + "-" + unit-word(units-digit)
    }
  }
}

/// Converts a number in the range 1–999 to its cardinal word form. The
/// `apocopate` and `feminine` flags are forwarded to the trailing 1–99 part
/// and used to pick the feminine variant of a hundreds word (e.g. 200 →
/// "dues-centes").
///
/// - number (int): The number to convert (1–999).
/// - apocopate (bool): Whether to apocopate a trailing "u".
/// - feminine (bool): Whether to use feminine forms.
/// -> str
#let _convert-below-1000(number, apocopate: false, feminine: false) = {
  if number < 100 {
    _convert-below-100(number, apocopate: apocopate, feminine: feminine)
  } else {
    let hundreds-digit = calc.quo(number, 100)
    let remainder = calc.rem(number, 100)
    let masc-hundreds = _hundreds.at(hundreds-digit)
    let hundreds-word = if feminine { _feminine-hundred(masc-hundreds) } else { masc-hundreds }
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
/// the entire group OR the caller requested apocopation for the final unit
/// (controlled by `apocopate-units`).
///
/// - number (int): The number to convert (1–999_999).
/// - apocopate-units (bool): Whether the units part should apocopate (true
///   when a scale noun like "milió" follows this 6-digit group, or when the
///   user requested `apocopated` for the bottom chunk).
/// - feminine (bool): Whether the chunk modifies a feminine noun. Affects the
///   thousands part (e.g. "vint-i-una mil persones") and the units part when
///   no scale word follows; ignored for units when `apocopate-units` is true,
///   since scale nouns (milió, bilió…) are masculine.
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
/// - scale-index (int): The current scale index (0 = bottom group, 1 = milions, …).
/// - feminine (bool): Whether the overall number modifies a feminine noun.
///   Only the bottom chunk (scale-index 0) inherits the gender, since scale
///   words (milió, bilió…) are masculine and impose their own agreement.
/// - apocopated (bool): Whether the user requested the apocopated form. Only
///   affects the bottom chunk when no scale word follows.
/// -> array
#let _chunk-and-convert(number, scale-index, feminine: false, apocopated: false) = {
  if number == 0 {
    ()
  } else {
    errors.out-of-range(scale-index, max: _scales-singular.len() - 1, lang: _lang-code)
    let chunk = calc.rem(number, 1000000)
    let rest = calc.quo(number, 1000000)
    let higher = _chunk-and-convert(rest, scale-index + 1, feminine: feminine, apocopated: apocopated)
    if chunk == 0 {
      higher
    } else {
      let words = _convert-below-million(
        chunk,
        apocopate-units: scale-index > 0 or (scale-index == 0 and apocopated),
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
/// - apocopated (bool): Whether to apocopate a trailing "u" → "un".
/// -> str
#let _convert-cardinal(number, feminine: false, apocopated: false) = {
  _chunk-and-convert(number, 0, feminine: feminine, apocopated: apocopated).join(" ")
}

// Ordinal helpers.

/// Converts a number in the range 1–99 to its ordinal word form (masculine,
/// non-feminine). Compound forms 21–29 and 31–99 use the fused suffix variants
/// (`vint-i-unè`, `trenta-dosè`, `quaranta-cinquè`).
///
/// - number (int): The number to convert (1–99).
/// -> str
#let _convert-ordinal-below-100(number) = {
  if number < 10 {
    _ord-units.at(number)
  } else if number < 20 {
    _ord-teens-and-ten.at(number - 10)
  } else if number == 20 {
    "vintè"
  } else if number < 30 {
    "vint-i-" + _ord-units-compound.at(number - 20)
  } else {
    let tens-digit = calc.quo(number, 10)
    let units-digit = calc.rem(number, 10)
    if units-digit == 0 {
      _ord-tens.at(tens-digit)
    } else {
      _tens.at(tens-digit - 3) + "-" + _ord-units-compound.at(units-digit)
    }
  }
}

/// Converts a positive integer in the range 1–999 to its ordinal word form.
/// Panics if `number` is outside [1, 999]. The masculine form is built first
/// and `feminine` swaps the trailing suffix on the last word for `-ena` (or
/// appends `-a` to `primer`/`segon`/`tercer`/`quart`).
///
/// - number (int): The number to convert (1–999).
/// - feminine (bool): Whether to return the feminine form.
/// -> str
#let _convert-ordinal(number, feminine: false) = {
  errors.out-of-range(number, min: 1, max: 999, lang: _lang-code)
  let masculine = if number < 100 {
    _convert-ordinal-below-100(number)
  } else {
    let hundreds-digit = calc.quo(number, 100)
    let remainder = calc.rem(number, 100)
    if remainder == 0 {
      _ord-hundreds.at(hundreds-digit)
    } else {
      _hundreds.at(hundreds-digit) + " " + _convert-ordinal-below-100(remainder)
    }
  }
  if feminine {
    _feminine-ordinal(masculine)
  } else {
    masculine
  }
}

// Public entry point.

/// Converts a number to its Catalan word form.
///
/// Cardinals are returned across the full long-scale range. Ordinals are
/// supported within the closed range [1, 999]; values outside that range panic
/// with an out-of-range error.
///
/// `gender` controls grammatical agreement: with `"feminine"`, cardinals
/// inflect "u"/"dos" and the hundreds 200–900 ("una", "vint-i-una", "dues",
/// "vint-i-dues", "dues-centes", "vint-i-una mil persones"); ordinals end in
/// `-ena` (or `-a` for `primer`/`segon`/`tercer`/`quart`). Scale nouns (mil,
/// milió, bilió…) are invariable and stay masculine.
///
/// `apocopated` is only available for cardinals in masculine. It produces the
/// short form "un" instead of "u" for the trailing unit ("vint-i-un",
/// "trenta-un", "cent un"). Combining `apocopated: true` with
/// `form: "ordinal"` or `gender: "feminine"` panics.
///
/// - number (int): The number to convert.
/// - form (str): The form: `"cardinal"` (default) or `"ordinal"`.
/// - gender (str): `"masculine"` (default) or `"feminine"`.
/// - apocopated (bool): Use the apocopated cardinal form. Cardinal + masculine only.
/// - negative (str): The prefix for negative numbers (default: `"menys"`).
/// -> str
#let convert(
  number,
  form: "cardinal",
  gender: "masculine",
  apocopated: false,
  negative: "menys",
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
      form == "cardinal",
      message: "num2words (ca): 'apocopated' is only available for cardinals",
    )
    assert(
      not feminine,
      message: "num2words (ca): 'apocopated' is not available for feminine gender",
    )
  }

  if number == 0 and form == "cardinal" {
    "zero"
  } else {
    let prefix = if number < 0 { negative + " " } else { "" }
    let abs-number = calc.abs(number)
    let result = if form == "cardinal" {
      _convert-cardinal(abs-number, feminine: feminine, apocopated: apocopated)
    } else {
      _convert-ordinal(abs-number, feminine: feminine)
    }
    prefix + result
  }
}
