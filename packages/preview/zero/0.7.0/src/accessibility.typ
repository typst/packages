#import "parsing.typ": content-to-string

#let phrases = (
  "fallback": (
    "times": "×",
    "power": "^",
    "plus": "+",
    "minus": "−",
    "per": "/",
    "decimal-separator": ".",
  ),
  "en": (
    "times": "times",
    "power": "to the power of",
    "plus": "plus",
    "minus": "minus",
    "per": "per",
    "decimal-separator": ".",
  ),
  "de": (
    "times": "mal",
    "power": "hoch",
    "plus": "plus",
    "minus": "minus",
    "per": "pro",
    "decimal-separator": ",",
  ),
  "fr": (
    "times": "fois",
    "power": "à la puissance",
    "plus": "plus",
    "minus": "moins",
    "per": "par",
    "decimal-separator": ",",
  ),
  "es": (
    "times": "veces",
    "power": "elevado a",
    "plus": "más",
    "minus": "menos",
    "per": "por",
    "decimal-separator": ",",
  ),
  "it": (
    "times": "per",
    "power": "alla potenza di",
    "plus": "più",
    "minus": "meno",
    "per": "per",
    "decimal-separator": ",",
  ),
  "ru": (
    "times": "на",
    "power": "в степени",
    "plus": "плюс",
    "minus": "минус",
    "per": "в",
    "decimal-separator": ",",
  ),
  "fi": (
    "times": "kertaa",
    "power": "potenssiin",
    "plus": "plus",
    "minus": "miinus",
    "per": "jaettuna",
    "decimal-separator": ",",
  ),
  "sl": (
    "times": "krat",
    "power": "na stopnjo",
    "plus": "plus",
    "minus": "minus",
    "per": "na",
    "decimal-separator": ",",
  ),
)

#let prefixes = (
  en: (
    a: "atto",
    f: "femto",
    p: "pico",
    n: "nano",
    µ: "micro",
    m: "milli",
    c: "centi",
    d: "deci",
    da: "deca",
    h: "hecto",
    k: "kilo",
    M: "mega",
    G: "giga",
    T: "tera",
    P: "peta",
    E: "exa",
  ),
  // identical prefixes are inherited from English
  de: (
    a: "Atto",
    f: "Femto",
    p: "Piko",
    n: "Nano",
    µ: "Mikro",
    m: "Milli",
    c: "Zenti",
    d: "Dezi",
    da: "Deka",
    h: "Hekto",
    k: "Kilo",
    M: "Mega",
    G: "Giga",
    T: "Tera",
    P: "Peta",
    E: "Exa",
  ),
  fr: (
    d: "déci",
    da: "déca",
    M: "méga",
    T: "téra",
    P: "péta",
  ),
  es: (:),
  ru: (
    a: "атто",
    f: "фемто",
    p: "пико",
    n: "нано",
    µ: "микро",
    m: "милли",
    c: "санти",
    d: "деци",
    da: "дека",
    h: "гекто",
    k: "кило",
    M: "мега",
    G: "гига",
    T: "тера",
    P: "пета",
    E: "экса",
  ),
  it: (
    k: "chilo",
    h: "etto",
  ),
  fi: (
    a: "atto",
    f: "femto",
    p: "piko",
    n: "nano",
    µ: "mikro",
    m: "milli",
    c: "sentti",
    d: "desi",
    da: "deka",
    h: "hehto",
    k: "kilo",
    M: "mega",
    G: "giga",
    T: "tera",
    P: "peta",
    E: "eksa",
  ),
  sl: (
    /* inherits femto, nano,
    centi, deci, kilo, mega,
    giga, tera, and peta */
    a: "ato",
    p: "piko",
    µ: "mikro",
    m: "mili",
    da: "deka",
    h: "hekto",
    E: "eksa",
  ),
)

#let units = (
  en: (
    A: "ampere",
    au: "astronomical unit",
    B: "bel",
    Bq: "becquerel",
    C: "coulomb",
    cd: "candela",
    d: "day",
    Da: "dalton",
    dB: "decibel",
    sym.degree: "degree",
    sym.degree + "C": "degree Celsius",
    eV: "electronvolt",
    F: "farad",
    g: "gram",
    Gy: "gray",
    H: "henry",
    h: "hour",
    ha: "hectare",
    Hz: "hertz",
    J: "joule",
    K: "kelvin",
    kat: "katal",
    kg: "kilogram",
    L: "liter",
    lm: "lumen",
    lx: "lux",
    m: "meter",
    sym.prime: "arc minute",
    min: "minute",
    mol: "mole",
    sym.prime.double: "arc second",
    N: "newton",
    Np: "neper",
    sym.Omega: "ohm",
    Pa: "pascal",
    rad: "radian",
    s: "second",
    S: "siemens",
    sr: "steradian",
    Sv: "sievert",
    t: "tonne",
    T: "tesla",
    V: "volt",
    W: "watt",
    Wb: "weber",
    "%": "percent",
    "‰": "permille",
  ),
  de: (
    // identical/similar units are inherited from English
    ha: "Hektar",
    sym.degree: "Grad",
    sym.degree + "C": "Grad Celsius",
    h: "Stunde",
    min: "Minute",
    s: "Sekunde",
    d: "Tag",
    kg: "Kilogramm",
    g: "Gramm",
    dB: "Dezibel",
    eV: "Elektronvolt",
    au: "astronomische Einheit",
    sym.prime.double: "Bogensekunde",
    sym.prime: "Bogenminute",
    mol: "Mol",
    A: "Ampère",
    B: "Bel",
    Bq: "Becquerel",
    C: "Coulomb",
    cd: "Candela",
    Da: "Dalton",
    F: "Farad",
    Gy: "Gray",
    H: "Henry",
    Hz: "Hertz",
    J: "Joule",
    K: "Kelvin",
    kat: "Katal",
    L: "Liter",
    lm: "Lumen",
    lx: "Lux",
    m: "Meter",
    N: "Newton",
    Np: "Neper",
    sym.Omega: "Ohm",
    Pa: "Pascal",
    rad: "Radian",
    S: "Siemens",
    sr: "Steradian",
    Sv: "Sievert",
    t: "Tonne",
    T: "Tesla",
    V: "Volt",
    W: "Watt",
    Wb: "Weber",
    "%": "Prozent",
    "‰": "Promille",
  ),
  fr: (
    A: "ampère",
    sym.degree: "degré",
    sym.degree + "C": "degré Celsius",
    h: "heure",
    m: "mètre",
    min: "minute",
    s: "seconde",
    d: "jour",
    au: "unité astronomique",
    sym.prime.double: "seconde d'arc",
    sym.prime: "minute d'arc",
    decibel: "décibel",
    eV: "électronvolt",
    g: "gramme",
    kg: "kilogramme",
    l: "litre",
    Np: "néper",
    sr: "stéradian",
    "%": "pour cent",
    "‰": "pour mille",
  ),
  es: (
    A: "amperio",
    C: "culombio",
    sym.degree: "grado sexagesimal",
    sym.degree + "C": "grado Celsius",
    eV: "electronvoltio",
    F: "faradio",
    g: "gramo",
    kg: "kilogramo",
    l: "litro",
    m: "metro",
    ha: "hectárea",
    J: "julio",
    H: "henrio",
    Hz: "hercio",
    mol: "mol",
    sym.Omega: "ohmio",
    rad: "radián",
    sr: "esterorradián",
    t: "tonelada",
    V: "voltio",
    W: "vatio",
    h: "hora",
    min: "minuto",
    s: "segundo",
    d: "día",
    au: "unidad astronómica",
    sym.prime.double: "segundo de arco",
    sym.prime: "minuto de arco",
    "%": "por ciento",
    "‰": "por mil",
  ),
  it: (
    m: "metro",
    kg: "kilogrammo",
    g: "grammo",
    eV: "elettronvolt",
    sym.degree: "grado",
    sym.degree + "C": "grado Celsius",
    h: "ora",
    min: "minuto",
    s: "secondo",
    d: "giorno",
    rad: "radiante",
    sr: "steradiante",
    au: "unità astronomica",
    sym.prime.double: "secondo d'arco",
    sym.prime: "minuto d'arco",
    "%": "per cento",
    "‰": "per mille",
  ),
  fi: (
    A: "ampeeri",
    au: "astronominen yksikkö",
    B: "bel",
    Bq: "becquerel",
    C: "coulombi",
    cd: "kandela",
    d: "päivä",
    Da: "dalton",
    dB: "desibeli",
    sym.degree: "aste",
    sym.degree + "C": "Celsiusaste",
    eV: "elektronivoltti",
    F: "faradi",
    g: "gramma",
    Gy: "gray",
    H: "henry",
    h: "tunti",
    ha: "hehtaari",
    Hz: "hertsi",
    J: "joule",
    K: "kelvin",
    kat: "katal",
    kg: "kilogramma",
    L: "litra",
    lm: "luumen",
    lx: "luksi",
    m: "metri",
    sym.prime: "kaariminuutti",
    min: "minuuti",
    mol: "mooli",
    sym.prime.double: "kaarisekunti",
    N: "newton",
    Np: "neper",
    sym.Omega: "ohmi",
    Pa: "pascal",
    rad: "radiaani",
    s: "sekunti",
    S: "siemens",
    sr: "steradiaani",
    Sv: "sievertti",
    t: "tonni",
    T: "tesla",
    V: "voltti",
    W: "watti",
    Wb: "weber",
    "%": "prosentti",
    "‰": "promille",
  ),
  sl: (
    /* inherits bel, dalton,
    decibel, farad, gram,
    kelvin, katal, kilogram,
    liter, lumen, meter,
    newton, neper, radian,
    steradian, tesla,
    and volt */
    A: "amper",
    au: "astronomska enota",
    Bq: "bekerel",
    C: "kulon",
    cd: "kandela",
    d: "dan",
    sym.degree: "stopinja",
    sym.degree + "C": "stopinja Celzija",
    eV: "elektronvolt",
    Gy: "grej",
    H: "henri",
    h: "ura",
    ha: "hektar",
    Hz: "herc",
    J: "džul",
    lx: "luks",
    sym.prime: "kotna minuta",
    min: "minuta",
    mol: "mol",
    sym.prime.double: "kotna sekunda",
    sym.Omega: "om",
    Pa: "paskal",
    s: "sekunda",
    S: "simens",
    Sv: "sivert",
    t: "tona",
    W: "vat",
    Wb: "veber",
    "%": "odstotek",
    "‰": "odtisoček",
  ),
)

// Register of the shorthands for special powers that a language has. This
// can be a string that is appended to the constituent unit (with a space)
// or a function that takes the translated constituent unit.
#let power-shorthands = (
  en: (
    "2": "squared",
    "3": "cubed",
  ),
  de: (
    "2": unit => "Quadrat" + lower(unit),
    "3": unit => "Kubik" + lower(unit),
  ),
  fr: (
    "2": "carré",
    "3": "cube",
  ),
  es: (
    "2": "al cuadrado",
    "3": "al cubo",
  ),
  it: (
    "2": "al quadrato",
    "3": "al cubo",
  ),
  fi: (
    "2": "toiseen",
    "3": "kolmanteen",
  ),
  sl: (
    "2": "na kvadrat",
    "3": "na kub",
  ),
)

#let finnish-plural-units = (
  A: "ampeeria",
  au: "astronomista yksikköä",
  B: "beliä",
  Bq: "becquereliä",
  C: "coulombia",
  cd: "kandelaa",
  d: "päivää",
  Da: "daltonia",
  dB: "desibeliä",
  sym.degree: "astetta",
  sym.degree + "C": "Celsiusastetta",
  eV: "elektronivolttia",
  F: "faradia",
  g: "grammaa",
  Gy: "graytä",
  H: "henryä",
  h: "tuntia",
  ha: "hehtaaria",
  Hz: "hertsiä",
  J: "joulea",
  K: "kelviniä",
  kat: "katalia",
  kg: "kilogrammaa",
  L: "litraa",
  lm: "luumenia",
  lx: "luksia",
  m: "metriä",
  sym.prime: "kaariminuuttia",
  min: "minuuttia",
  mol: "moolia",
  sym.prime.double: "kaarisekuntia",
  N: "newtonia",
  Np: "neperiä",
  sym.Omega: "ohmia",
  Pa: "pascalia",
  rad: "radiaania",
  s: "sekuntia",
  S: "siemensiä",
  sr: "steradiaania",
  Sv: "sieverttiä",
  t: "tonnia",
  T: "teslaa",
  V: "volttia",
  W: "wattia",
  Wb: "weberiä",
  "%": "prosentti",
  "‰": "promille",
)

// Needed by pluralize when a unit is in a denominator.
// The unit suffixes are in a form where each word would be preceded by the word "jaettuna" or "divided by".
#let finnish-denom-units = (
  A: "ampeerilla",
  au: "astronomisella yksikköllä",
  B: "belillä",
  Bq: "becquerelillä",
  C: "coulombilla",
  cd: "kandelalla",
  d: "päivällä",
  Da: "daltonilla",
  dB: "desibelillä",
  sym.degree: "asteella",
  sym.degree + "C": "Celsiusasteella",
  eV: "elektronivoltilla",
  F: "faradilla",
  g: "grammalla",
  Gy: "grayllä",
  H: "henryllä",
  h: "tunnilla",
  ha: "hehtaarilla",
  Hz: "hertsillä",
  J: "joulella",
  K: "kelvinillä",
  kat: "katalilla",
  kg: "kilogrammalla",
  L: "litralla",
  lm: "luumenilla",
  lx: "luksilla",
  m: "metrillä",
  sym.prime: "kaariminuuttilla",
  min: "minuutilla",
  mol: "moolilla",
  sym.prime.double: "kaarisekunnilla",
  N: "newtonilla",
  Np: "neperillä",
  sym.Omega: "ohmilla",
  Pa: "pascalilla",
  rad: "radiaanilla",
  s: "sekunnilla",
  S: "siemensillä",
  sr: "steradiaanilla",
  Sv: "sievertillä",
  t: "tonnilla",
  T: "teslalla",
  V: "voltilla",
  W: "watilla",
  Wb: "weberillä",
  "%": "prosentilla",
  "‰": "promillella",
)

// How to form the plural of a constituent unit. For each language, this should
// be a function that takes a unit symbol string, e.g. "Hz",
// and a float `count` which is assumed to be of some plural amount,
// and a bool `is-in-denom` that specifies whether the unit is placed in the denominator.
#let pluralize = (
  en: (unit, count, is-in-denom) => {
    let singular = units.en.at(unit)
    if unit in ("lx", "Hz", "S", "%", "‰") {
      return singular
    }
    if unit == sym.degree + "C" {
      return "degrees Celsius"
    }
    if unit == "H" {
      return "henries"
    }
    return singular + "s"
  },

  de: (unit, count, is-in-denom) => {
    let singular = units.de.at(unit)
    if unit in ("h", "min", "s", sym.prime.double, sym.prime, "t", "%", "‰") {
      return singular + "n"
    }
    if unit == "au" {
      return singular + "en"
    }
    if unit == "d" {
      return singular + "e"
    }

    return singular
  },

  fi: (unit, count, is-in-denom) => {
    if is-in-denom {
      // Things get more complex here since when in a denominator we need a form of each word where things happen IN something.
      // Like literally IN one second, or IN one meter. And of course Finnish has a specific suffix for each word for this.
      // Often this just means adding a "ss" before the last letter of the quantity form of each word but not always.
      // For example "metriä sekunnissa" means "meters per second" or "meters in one second".
      return finnish-denom-units.at(unit)
    } else {
      return finnish-plural-units.at(unit)
    }
  },

  fr: (unit, count, is-in-denom) => {
    let singular = units.fr.at(unit, default: units.en.at(unit))
    if unit in ("lx", "Hz", "S", "%", "‰") {
      return singular
    }
    if unit == sym.degree + "C" { return "degrés Celsius" }
    if unit == sym.prime.double { return "secondes d'arc" }
    if unit == sym.prime { return "minutes d'arc" }
    if unit == "au" { return "unités astronomique" }
    return singular + "s"
  },

  es: (unit, count, is-in-denom) => {
    let singular = units.es.at(unit, default: units.en.at(unit))
    if unit in ("lx", "Hz", "S", "%", "‰") {
      return singular
    }
    if unit == sym.degree + "C" { return "grados Celsius" }
    if unit == "rad" { return "radianes" }
    if unit == "sr" { return "esterorradianes" }
    if (
      singular.ends-with("o") or singular.ends-with("y") or singular.ends-with("a")
    ) {
      return singular + "s"
    } else {
      return singular + "es"
    }
  },

  it: (unit, count, is-in-denom) => {
    let singular = units.it.at(unit, default: units.en.at(unit))
    if unit in ("J", "A", "T", "%", "‰") { return singular }
    if unit == sym.degree + "C" { return "gradi Celsius" }
    if unit.ends-with("o") or unit.ends-with("e") {
      return singular.slice(0, -1) + "i"
    }
    if unit.ends-with("a") { return singular.slice(0, -1) + "e" }
    return singular
  },

  sl: (unit, count, is-in-denom) => {
    let singular = units.sl.at(unit, default: units.en.at(unit))

    // This doesn't ruin 1 000, 10 000, 100 000, 1 000 000 ...
    // Because 0 is plural in the same way as them
    count = calc.abs(calc.rem(count, 100))

    // Easier keywords
    let (dual, plural-3-4, is-float) = (
      count == 2, // Dual
      count in (3, 4), // Plural for 3 and 4

      // A would-be `plural-5` for 5+ and 0
      // Is simply an `else` branch instead
      // count >= 5 or count == 0,

      float == type(count), // Singular genitive for floats
    )

    // Checks the need for plural despite already supposedly done via `needs-plural()`
    if calc.abs(count) == 1 and not is-float and not is-in-denom {
      panic("Attempt to use plural for an integer count of 1")
    }

    let feminine(word) = {
      // Denominator rule with a hardcoded `return`
      if is-in-denom { return word.slice(0, -1) + "o" }

      // When the word is a feminine adjective, so to a feminine noun
      let adj-role = if word in ("astronomska", "kotna") { "ih" }

      if dual {
        word.slice(0, -1) + "i"
      } else if plural-3-4 or is-float {
        word.slice(0, -1) + "e"
      } else {
        word.slice(0, -1) + adj-role
      }
    }

    let masculine(word) = {
      // Denominator rule with a hardcoded `return`
      if is-in-denom and word == "tesla" { return word.slice(0, -1) + "o" } else if is-in-denom { return word }

      // Different float rule with a hardcoded `return`
      if word == "tesla" and is-float {
        return "tesle"
      }

      if dual or is-float {
        if word == "dan" {
          "dneva"
        } else if word == "henri" {
          "henrija"
        } else if word == "lumen" {
          "lumna"
        } else if word == "tesla" {
          "tesli"
        } else if word.ends-with("ek") {
          word.slice(0, -2) + "ka"
        } else if word.ends-with(regex("ber|ter")) {
          word.slice(0, -2) + "ra"
        } else {
          word + "a"
        }
      } else if plural-3-4 {
        if word == "dan" {
          "dnevi"
        } else if word == "henri" {
          "henriji"
        } else if word == "lumen" {
          "lumni"
        } else if word == "tesla" {
          "tesle"
        } else if word.ends-with("ek") {
          word.slice(0, -2) + "ki"
        } else if word.ends-with(regex("ber|ter")) {
          word.slice(0, -2) + "ri"
        } else {
          word + "i"
        }
      } else {
        if word == "dan" {
          "dni"
        } else if word == "henri" {
          "henrijev"
        } else if word == "lumen" {
          "lumnov"
        } else if word == "tesla" {
          "tesel"
        } else if word.ends-with("ek") {
          word.slice(0, -2) + "kov"
        } else if word.ends-with(regex("ber|ter")) {
          word.slice(0, -2) + "rov"
        } else if word.ends-with(regex("c|j")) {
          word + "ev"
        } else {
          word + "ov"
        }
      }
    }

    // Feminine
    if unit in ("cd", str(sym.degree), "h", "min", "s", "t") {
      return feminine(singular)
    }

    // Masculine
    if (
      unit in (
        "A", "B", "Bq", "C", "d", "Da", "dB", "eV", "F", "g", "Gy", "H", "ha",
        "Hz", "J", "K", "kat", "kg", "L", "lm", "lx", "m", "mol", "N", "Np",
        str(sym.Omega), "Pa", "rad", "S", "sr", "Sv", "T", "V", "W", "Wb",
        "%", "‰",
      )
    ) {
      return masculine(singular)
    }

    // More, all of which are so far feminine, apart from the C-noun
    if unit in ("au", str(sym.degree) + "C", str(sym.prime), str(sym.prime.double)) {
      return singular
        .split(" ")
        .map(word => {
          if word == "Celzija" { word } else { feminine(word) }
        })
        .join(" ")
    }

    // Beware that this error can also appear because `sym.___` or `symbol(sym.___)` isn't the same as the symbol string itself
    panic("Slovenian translation not updated to support '" + singular + "'?")
  },
)


// How to join a prefix to a unit. This can be overridden for individual languages.
#let join-prefix-unit(
  /// The translated prefix, e.g. "milli"
  /// -> str
  prefix,

  /// The translated unit, e.g. "meter".
  /// -> str
  unit,

  /// The language code.
  /// -> str
  lang,
) = {
  if lang == "de" {
    prefix + lower(unit)
  } else {
    prefix + unit
  }
}


// Check whether a quantity requires the (composed) unit to be in plural. This
// can be overridden for individual languages.
#let needs-plural(
  /// The value of the quantity, e.g. `1.5`.
  /// -> float
  value,

  /// The language code.
  /// -> str
  lang,
) = {
  if lang == "fr" {
    calc.abs(value) >= 2
  } else {
    calc.abs(value) != 1 or type(value) == float
  }
}


#let base-to-string(base) = {
  if type(base) == str {
    return base
  } else if type(base) in (int, float, symbol) {
    return str(base)
  } else if type(base) == content {
    if base.func() == math.equation {
      let result = content-to-string(base.body)
      if result != none {
        return result
      }
    }
  }

  assert(
    false,
    message: "Failed to convert base to string. Please provide a manual alt text for this numeral.",
  )
}

#let generate-num-alt-description(info, translation: auto) = {
  let lang = text.lang
  if translation == auto {
    translation = phrases.at(lang, default: phrases.fallback)
  }
  let format-comma-number(int, frac) = {
    if int.len() == 0 {
      int = "0"
    }
    int + if frac.len() > 0 { translation.decimal-separator + frac }
  }

  let alt = ""
  alt += if info.sign == "-" { translation.minus + " " }
  alt += format-comma-number(info.int, info.frac)

  if info.pm != none {
    if type(info.pm.first()) == array {
      alt += (
        " " + translation.plus + " " + format-comma-number(..info.pm.first())
      )
      alt += (
        " " + translation.minus + " " + format-comma-number(..info.pm.last())
      )
    } else {
      alt += (
        " " + translation.plus + " " + translation.minus + " " + format-comma-number(..info.pm)
      )
    }
  }
  if info.e != none {
    alt += (
      " " + translation.times + " " + base-to-string(info.base) + " " + translation.power + " " + info.e
    )
  }

  alt
}




#let unit-component-description(
  component,
  plural: false,
  count: auto,
  is-in-denom: false,
) = {
  if count == auto {
    if not plural { count = 1 } else { count = 99 }
  }

  let lang = text.lang
  let units = units.en + units.at(lang, default: units.en)
  let get-unit(unit-code) = {
    if plural { (pluralize.at(lang))(unit-code, count, is-in-denom) } // Add your language here to `pluralize` the denominator
    else if is-in-denom and lang in ("sl", "fi") {
      (pluralize.at(lang))(unit-code, count, is-in-denom)
    } else { units.at(unit-code) }
  }

  if type(component) in (symbol, str) {
    component = str(component)
    if component in units {
      return get-unit(component)
    }
    if component.len() > 1 {
      let prefixes = prefixes.en + prefixes.at(lang, default: prefixes.en)
      let clusters = component.clusters()
      let prefix = clusters.at(0)
      let unit = clusters.slice(1).join()
      if prefix in prefixes and unit in units {
        return join-prefix-unit(prefixes.at(prefix), get-unit(unit), text.lang)
      }
    }
  }
  assert(
    false,
    message: "Failed to auto-generate alt description for unit component "
      + repr(component)
      + ". Please provide a manual alt text for this unit.",
  )
}

#let generate-unit-alt-description(
  numerator,
  denominator,
  translation: auto,
  value: 1,
) = {
  let lang = text.lang
  if translation == auto {
    translation = phrases.at(lang, default: phrases.fallback)
    if lang not in phrases {
      return none
    }
    // assert(
    //   lang in phrases,
    //   message: "Unsupported language "
    //     + lang
    //     + " for alt text generation. Please provide a manual alt text for this unit. Supported languages are: "
    //     + repr(phrases.keys())
    //     + ". If you want to contribute a translation for your language, please open a pull request.",
    // )
  }

  let alt = ""
  let power-shorthands = power-shorthands.at(lang, default: (:))

  let power-of-unit-component-description((unit-component, exponent), plural: false, is-in-denom: false) = {
    let unit = unit-component-description(unit-component, plural: plural, count: value, is-in-denom: is-in-denom)
    if exponent == "1" { return unit }
    if exponent in power-shorthands {
      let power-shorthand = power-shorthands.at(exponent)
      if type(power-shorthand) == function {
        unit = power-shorthand(unit)
      } else {
        unit += " " + power-shorthand
      }
    } else {
      unit += " " + translation.power + " " + exponent
    }
    unit
  }

  let plural = needs-plural(value, lang)
  if numerator.len() > 0 {
    alt += (
      numerator.slice(0, -1).map(power-of-unit-component-description)
        + (power-of-unit-component-description(numerator.at(-1), plural: plural),)
    ).join(" ")
  }
  if denominator.len() > 0 {
    alt += " " + translation.per + " "
    alt += denominator
      .map(power-of-unit-component-description.with(is-in-denom: true))
      .join(" " + translation.per + " ")
  }

  alt
}
