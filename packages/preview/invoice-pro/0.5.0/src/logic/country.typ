// Countries of the parties: the ISO 3166-1 alpha-2 code, the printed name and
// how the city line (post code and city name) is parsed and printed.

// The plain text of the city line as it reads on the page, the same text the
// e-invoice writes.
#import "../utils/text.typ": plain-text

// --- Regional Parsers and Formatters ---

// The patterns of the parsers below. Each is compiled once, when a party of
// its country is parsed for the first time: compiling a regular expression
// costs far more than matching it, and most invoices need none of them.
#let _euro-city-pattern() = regex("^\\s*(?:[A-Z]{1,2}-)?(\\d{4,5})\\s+(.+)$")
#let _uk-city-pattern() = regex(
  "(?i)^\\s*(.+?)(?:,\\s*|\\s+|\\n)\\s*([a-z]{1,2}\\d[a-z\\d]?\\s*\\d[a-z]{2})\\s*$",
)
#let _us-city-patterns() = (
  with-state: regex(
    "(?i)^\\s*(.+?)(?:,\\s*|\\s+)([a-z]{2})\\s+(\\d{5}(?:-\\d{4})?)\\s*$",
  ),
  without-state: regex("(?i)^\\s*(.+?)(?:,\\s*|\\s+)(\\d{5}(?:-\\d{4})?)\\s*$"),
)

// A city line without a post code of the expected format: the whole text is
// the city name.
#let _unparsed-city(city-str) = (name: city-str.trim(), post-code: none)

// The generic parser of custom countries: a post code of 4 or 5 digits,
// optionally with a country marker ("D-10115"), before the city name.
#let parse-city-euro(city-str) = {
  let m = city-str.match(_euro-city-pattern())
  if m != none {
    let pc-raw = m.captures.at(0, default: none)
    let name-raw = m.captures.at(1, default: none)
    (
      name: if name-raw != none { name-raw.trim() } else { "" },
      post-code: if pc-raw != none { pc-raw.trim() } else { none },
    )
  } else {
    _unparsed-city(city-str)
  }
}

/// Builds a parser that splits a city line into the post code and the city
/// name of one country.
///
/// - `pattern`: regular expression of the post code, without anchors and
///   capturing groups (e.g. `"\\d{5}"`).
/// - `position`: where the post code stands: `"before"` the city name
///   ("10115 Berlin"), `"after"` it ("Valletta VLT 1117") or `"either"`.
/// - `prefixes`: country markers that may precede the post code ("D-10115").
///   They are dropped, unless `keep-prefix` is set because the marker is part
///   of the official post code ("LV-1050").
/// - `ignore-case`: letters of the post code may be written in lower case;
///   the post code is returned in upper case.
///
/// -> function
#let post-code-parser(
  pattern,
  position: "before",
  prefixes: (),
  keep-prefix: false,
  ignore-case: false,
) = {
  let flags = if ignore-case { "(?i)" } else { "" }
  let prefix = if prefixes.len() == 0 { "()" } else {
    "(?:(" + prefixes.join("|") + ")-)?"
  }
  let before = regex(
    flags + "^" + prefix + "(" + pattern + ")\\s+(.+)$",
  )
  let after = regex(
    flags + "^(.+?)(?:,\\s*|\\s+)" + prefix + "(" + pattern + ")$",
  )
  let result(name, marker, code) = {
    let code = if ignore-case { upper(code) } else { code }
    (
      name: name.trim(),
      post-code: if keep-prefix and marker not in (none, "") {
        marker + "-" + code
      } else { code },
    )
  }

  city-str => {
    let city-str = city-str.trim()
    if position in ("before", "either") {
      let m = city-str.match(before)
      if m != none {
        let (marker, code, name) = m.captures
        return result(name, marker, code)
      }
    }
    if position in ("after", "either") {
      let m = city-str.match(after)
      if m != none {
        let (name, marker, code) = m.captures
        return result(name, marker, code)
      }
    }
    _unparsed-city(city-str)
  }
}

// Post code, then city name on one line: "10115 Berlin".
#let format-city-euro(parsed-city) = {
  if parsed-city == none { return none }
  let parts = ()
  if parsed-city.at("post-code", default: none) != none {
    parts.push(parsed-city.post-code)
  }
  if parsed-city.at("name", default: none) != none {
    parts.push(parsed-city.name)
  }
  parts.join(" ")
}

// City name, then post code on one line: "Valletta VLT 1117".
#let format-city-trailing(parsed-city) = {
  if parsed-city == none { return none }
  let parts = ()
  if parsed-city.at("name", default: none) != none {
    parts.push(parsed-city.name)
  }
  if parsed-city.at("post-code", default: none) != none {
    parts.push(parsed-city.post-code)
  }
  parts.join(" ")
}

#let parse-city-uk(city-str) = {
  let m = city-str.match(_uk-city-pattern())
  if m != none {
    let name-raw = m.captures.at(0, default: none)
    let pc-raw = m.captures.at(1, default: none)
    (
      name: if name-raw != none { name-raw.trim() } else { "" },
      post-code: if pc-raw != none { upper(pc-raw).trim() } else { none },
    )
  } else {
    _unparsed-city(city-str)
  }
}

// City name and post code on separate lines: "London \ SW1A 2AA".
#let format-city-uk(parsed-city) = {
  if parsed-city == none { return none }
  let lines = ()
  if parsed-city.at("name", default: none) != none {
    lines.push(parsed-city.name)
  }
  if parsed-city.at("post-code", default: none) != none {
    lines.push(parsed-city.post-code)
  }
  lines.join([ \ ])
}

#let format-inline-city-uk(parsed-city) = {
  if parsed-city == none { return none }
  let parts = ()
  if parsed-city.at("name", default: none) != none {
    parts.push(parsed-city.name)
  }
  if parsed-city.at("post-code", default: none) != none {
    parts.push(parsed-city.post-code)
  }
  parts.join(", ")
}

#let parse-city-us(city-str) = {
  let patterns = _us-city-patterns()
  let m1 = city-str.match(patterns.with-state)
  if m1 != none {
    let name-raw = m1.captures.at(0, default: none)
    let state-raw = m1.captures.at(1, default: none)
    let pc-raw = m1.captures.at(2, default: none)
    (
      name: if name-raw != none { name-raw.trim() } else { "" },
      state: if state-raw != none { upper(state-raw) } else { none },
      post-code: if pc-raw != none { pc-raw.trim() } else { none },
    )
  } else {
    let m2 = city-str.match(patterns.without-state)
    if m2 != none {
      let name-raw = m2.captures.at(0, default: none)
      let pc-raw = m2.captures.at(1, default: none)
      (
        name: if name-raw != none { name-raw.trim() } else { "" },
        state: none,
        post-code: if pc-raw != none { pc-raw.trim() } else { none },
      )
    } else {
      (
        name: city-str.trim(),
        state: none,
        post-code: none,
      )
    }
  }
}

#let format-city-us(parsed-city) = {
  if parsed-city == none { return none }
  let city-state = ()
  if parsed-city.at("name", default: none) != none {
    city-state.push(parsed-city.name)
  }
  if parsed-city.at("state", default: none) != none {
    city-state.push(parsed-city.state)
  }
  let city-state-str = city-state.join(", ")

  let parts = ()
  if city-state-str != "" { parts.push(city-state-str) }
  if parsed-city.at("post-code", default: none) != none {
    parts.push(parsed-city.post-code)
  }
  parts.join(" ")
}

// --- Country Module Builder ---

#let make-country(
  name: "",
  code: "",
  show-always: false,
  format-city: format-city-euro,
  format-inline-city: format-city-euro,
  parse-city-raw: parse-city-euro,
) = {
  let parse-city(city) = {
    if city == none or city == "" or city == () {
      none
    } else if type(city) == dictionary {
      let result = (
        name: city.at("name", default: none),
        post-code: city.at("post-code", default: none),
      )
      for (k, v) in city {
        result.insert(k, v)
      }
      result
    } else {
      // Composed or styled content ([#plz #ort], [10115 *Berlin*]) is parsed
      // as the text it shows, spaces and line breaks included.
      let text = plain-text(city)
      if text == "" { none } else { parse-city-raw(text) }
    }
  }

  (
    name: name,
    code: code,
    show-always: show-always,
    parse-city: parse-city,
    format-address: (name, address, city, country-name: none) => {
      let lines = ()
      if name != none and name != () and name != "" {
        lines.push(if type(name) == array { name.join([ \ ]) } else { name })
      }
      if address != none and address != () and address != "" {
        lines.push(if type(address) == array { address.join([ \ ]) } else {
          address
        })
      }

      let parsed-city = parse-city(city)
      let formatted-city = if parsed-city == none {
        none
      } else if "display" in parsed-city {
        parsed-city.display
      } else {
        format-city(parsed-city)
      }

      if formatted-city != none and formatted-city != "" {
        lines.push(formatted-city)
      }
      if country-name != none and country-name != "" {
        lines.push(country-name)
      }
      lines.join([ \ ])
    },
    format-inline: (name, address, city, country-name: none) => {
      let parts = ()
      if name != none and name != () and name != "" {
        parts.push(if type(name) == array { name.join(", ") } else { name })
      }
      if address != none and address != () and address != "" {
        parts.push(if type(address) == array { address.join(", ") } else {
          address
        })
      }

      let parsed-city = parse-city(city)
      let formatted-city = if parsed-city == none {
        none
      } else if "inline-display" in parsed-city {
        parsed-city.inline-display
      } else if "display" in parsed-city {
        parsed-city.display
      } else {
        format-inline-city(parsed-city)
      }

      if formatted-city != none and formatted-city != "" {
        parts.push(formatted-city)
      }
      if country-name != none and country-name != "" {
        parts.push(country-name)
      }
      parts.join(", ")
    },
  )
}

// A country code must be an ISO 3166-1 alpha-2 code: two letters.
#let _code-pattern = regex("^[A-Za-z]{2}$")

// The upper-case ISO 3166-1 alpha-2 code of `code` (a string or content).
// "UK", reserved in ISO 3166-1 for the United Kingdom, is its code "GB".
// `field` names the input in the error message.
#let normalize-code(code, field) = {
  let text = if type(code) in (str, content) { plain-text(code) } else { none }
  if text == none or text.match(_code-pattern) == none {
    panic(
      "`"
        + field
        + "`: "
        + repr(code)
        + " is not an ISO 3166-1 alpha-2 country code (two letters such as \"DE\" or \"FR\").",
    )
  }
  let code = upper(text)
  if code == "UK" { "GB" } else { code }
}

// The characters that have a meaning in a regular expression, which a post
// code mask escapes.
#let _regex-syntax = (
  "\\": true,
  ".": true,
  "+": true,
  "*": true,
  "?": true,
  "(": true,
  ")": true,
  "|": true,
  "[": true,
  "]": true,
  "{": true,
  "}": true,
  "^": true,
  "$": true,
  "#": true,
  "&": true,
  "~": true,
  "-": true,
)

// Turns a post code mask of `country.custom` into a regular expression:
// `9` is a digit, `A` a letter, a space an optional space, anything else
// stands for itself ("9999", "A9A 9A9", "999-9999").
#let _mask-pattern(mask) = {
  let pattern = ""
  for char in mask.clusters() {
    pattern += if char == "9" { "\\d" } else if char == "A" {
      "[A-Z]"
    } else if char == " " { "\\s?" } else if char in _regex-syntax {
      "\\" + char
    } else { char }
  }
  pattern
}

/// A country that is not predefined in the `country` module.
///
/// - `code`: the ISO 3166-1 alpha-2 code, e.g. `"NO"` (required).
/// - `name`: the printed name of the country.
/// - `show-always`: print the country line even for domestic addresses.
/// - `post-code`: the format of the post code as a mask, `9` for a digit and
///   `A` for a letter (e.g. `"9999"`, `"A9A 9A9"`, `"999-9999"`), or an array
///   of masks. `auto` accepts 4 or 5 digits.
/// - `post-code-position`: `"before"` the city name ("0154 Oslo") or
///   `"after"` it ("Toronto ON M5V 2T6").
///
/// -> dictionary
#let custom(
  code: none,
  name: none,
  show-always: false,
  post-code: auto,
  post-code-position: "before",
) = {
  let code = normalize-code(code, "country.custom: code")
  if name != none and type(name) not in (str, content) {
    panic(
      "`country.custom: name` must be a string or content, got "
        + repr(name)
        + ".",
    )
  }
  if post-code-position not in ("before", "after") {
    panic(
      "`country.custom: post-code-position` must be \"before\" or \"after\", got "
        + repr(post-code-position)
        + ".",
    )
  }
  let masks = if type(post-code) == array { post-code } else { (post-code,) }
  if (
    post-code != auto
      and (masks.len() == 0 or masks.any(mask => type(mask) != str))
  ) {
    panic(
      "`country.custom: post-code` must be a mask such as \"9999\" or \"A9A 9A9\" (9 = digit, A = letter), an array of masks or auto, got "
        + repr(post-code)
        + ".",
    )
  }
  // Like the predefined countries, the post code may carry the country code
  // as marker ("NO-0154 Oslo").
  let parse-city-raw = if post-code == auto {
    if post-code-position == "before" { parse-city-euro } else {
      post-code-parser("\\d{4,5}", position: "after", prefixes: (code,))
    }
  } else {
    post-code-parser(
      masks.map(_mask-pattern).join("|"),
      position: post-code-position,
      prefixes: (code,),
      ignore-case: true,
    )
  }
  let format-city = if post-code-position == "before" {
    format-city-euro
  } else { format-city-trailing }
  make-country(
    name: if name == none { "" } else { name },
    code: code,
    show-always: show-always,
    format-city: format-city,
    format-inline-city: format-city,
    parse-city-raw: parse-city-raw,
  )
}

// --- Exported Country Functions ---
//
// Each country parses the post code in its own format, so that a city line
// such as "1012 AB Amsterdam" is split into the complete post code and the
// city name. A post code of another format is not taken apart: the whole line
// is the city name.

// Post codes of 4 or 5 digits before the city name, optionally with the
// country markers `prefixes` ("D-10115").
#let _digits(count, ..prefixes) = post-code-parser(
  "\\d{" + str(count) + "}",
  prefixes: prefixes.pos(),
)

// A predefined country: its function takes `name`, `code` and `show-always`;
// `parser` builds the parser of its city lines when the country is used.
#let _country(name, code, parser, format: format-city-euro, inline: auto) = (
  name: name,
  code: code,
  show-always: false,
) => make-country(
  name: name,
  code: code,
  show-always: show-always,
  format-city: format,
  format-inline-city: if inline == auto { format } else { inline },
  parse-city-raw: parser(),
)

#let de = _country("Deutschland", "DE", () => _digits(5, "D", "DE"))
#let at = _country("Österreich", "AT", () => _digits(4, "A", "AT"))
#let ch = _country("Schweiz", "CH", () => _digits(4, "CH"))
#let fr = _country("France", "FR", () => _digits(5, "F", "FR"))
#let it = _country("Italia", "IT", () => _digits(5, "I", "IT"))
#let es = _country("España", "ES", () => _digits(5, "E", "ES"))

#let be = _country("België", "BE", () => _digits(4, "B", "BE"))
#let bg = _country("Bulgaria", "BG", () => _digits(4, "BG"))
#let cy = _country("Cyprus", "CY", () => _digits(4, "CY"))
// "110 00 Praha 1"
#let cz = _country("Česko", "CZ", () => post-code-parser(
  "\\d{3}\\s?\\d{2}",
  prefixes: ("CZ",),
))
#let dk = _country("Danmark", "DK", () => _digits(4, "DK"))
#let ee = _country("Eesti", "EE", () => _digits(5, "EE"))
#let fi = _country("Suomi", "FI", () => _digits(5, "FI"))
// "105 57 Athina"
#let gr = _country("Greece", "GR", () => post-code-parser(
  "\\d{3}\\s?\\d{2}",
  prefixes: ("GR",),
))
#let hr = _country("Hrvatska", "HR", () => _digits(5, "HR"))
#let hu = _country("Magyarország", "HU", () => _digits(4, "H", "HU"))
// The Eircode follows the city (or county) line: "Dublin 2 D02 X285".
#let ie = _country(
  "Ireland",
  "IE",
  () => post-code-parser(
    "(?:[AC-FHKNPRTV-Y]\\d{2}|D6W)\\s?[0-9AC-FHKNPRTV-Y]{4}",
    position: "either",
    ignore-case: true,
  ),
  format: format-city-uk,
  inline: format-inline-city-uk,
)
// The official post codes of Lithuania, Luxembourg and Latvia include the
// country marker: "LT-01100", "L-1648", "LV-1050".
#let lt = _country("Lietuva", "LT", () => post-code-parser(
  "\\d{5}",
  prefixes: ("LT",),
  keep-prefix: true,
))
#let lu = _country("Luxembourg", "LU", () => post-code-parser(
  "\\d{4}",
  prefixes: ("L",),
  keep-prefix: true,
))
#let lv = _country("Latvija", "LV", () => post-code-parser(
  "\\d{4}",
  prefixes: ("LV",),
  keep-prefix: true,
))
// "Valletta VLT 1117"
#let mt = _country(
  "Malta",
  "MT",
  () => post-code-parser("[A-Z]{3}\\s?\\d{4}", position: "either"),
  format: format-city-trailing,
)
// "1012 AB Amsterdam"
#let nl = _country("Nederland", "NL", () => post-code-parser(
  "\\d{4}\\s?[A-Z]{2}",
  prefixes: ("NL",),
))
// "00-950 Warszawa"
#let pl = _country("Polska", "PL", () => post-code-parser(
  "\\d{2}-\\d{3}",
  prefixes: ("PL",),
))
// "1000-001 Lisboa"
#let pt = _country("Portugal", "PT", () => post-code-parser(
  "\\d{4}-\\d{3}",
  prefixes: ("PT",),
))
#let ro = _country("România", "RO", () => _digits(6, "RO"))
// "114 55 Stockholm"
#let se = _country("Sverige", "SE", () => post-code-parser(
  "\\d{3}\\s?\\d{2}",
  prefixes: ("S", "SE"),
))
#let si = _country("Slovenija", "SI", () => _digits(4, "SI"))
// "811 01 Bratislava"
#let sk = _country("Slovensko", "SK", () => post-code-parser(
  "\\d{3}\\s?\\d{2}",
  prefixes: ("SK",),
))

#let uk = _country(
  "United Kingdom",
  "GB",
  () => parse-city-uk,
  format: format-city-uk,
  inline: format-inline-city-uk,
)
#let gb = uk

#let us = _country(
  "United States",
  "US",
  () => parse-city-us,
  format: format-city-us,
)

// --- Helper mapping ---
#let region-to-country = (
  de: de,
  at: at,
  ch: ch,
  fr: fr,
  it: it,
  es: es,
  be: be,
  bg: bg,
  cy: cy,
  cz: cz,
  dk: dk,
  ee: ee,
  fi: fi,
  gr: gr,
  hr: hr,
  hu: hu,
  ie: ie,
  lt: lt,
  lu: lu,
  lv: lv,
  mt: mt,
  nl: nl,
  pl: pl,
  pt: pt,
  ro: ro,
  se: se,
  si: si,
  sk: sk,
  uk: uk,
  gb: uk,
  us: us,
)

// The country of a locale region such as "de" (the default of the parties).
#let country-from-region(region) = {
  let key = lower(region)
  if key in region-to-country {
    region-to-country.at(key)()
  } else {
    make-country(code: upper(region))
  }
}

// The country of an ISO 3166-1 alpha-2 code: the predefined country, or a
// custom one without name. "UK" is accepted for the United Kingdom (GB).
#let country-from-code(code, field) = {
  let code = normalize-code(code, field)
  let key = lower(code)
  if key in region-to-country {
    region-to-country.at(key)()
  } else {
    custom(code: code)
  }
}

#let _invalid-country(value, field) = panic(
  "`"
    + field
    + "` must be a country of the `country` module (e.g. `country.fr`), `country.custom(code: \"NO\", name: \"Norge\")` or an ISO 3166-1 alpha-2 code such as \"FR\", got "
    + repr(value)
    + ".",
)

// Completes a country dictionary: missing parsers and formatters are taken
// from the country of its code, the code is validated and upper-cased.
#let _complete-country(country, field) = {
  if "code" not in country {
    panic(
      "`"
        + field
        + "`: the country dictionary has no `code`. Use e.g. `country.custom(code: \"NO\", name: \"Norge\")`.",
    )
  }
  let code = normalize-code(country.code, field + ".code")
  for key in ("parse-city", "format-address", "format-inline") {
    if key in country and type(country.at(key)) != function {
      panic(
        "`"
          + field
          + "."
          + key
          + "` must be a function, got "
          + repr(country.at(key))
          + ".",
      )
    }
  }
  let base = if ("parse-city", "format-address", "format-inline").all(key => (
    key in country
  )) { (name: "", show-always: false) } else {
    country-from-code(code, field + ".code")
  }
  base + country + (code: code)
}

// Whether a `country` (or `region`) value states no country: `auto`, `none`,
// or an empty string or content (e.g. an empty column of imported data), which
// is the same as leaving the key out.
#let _states-no-country(value) = (
  value == auto
    or value == none
    or (type(value) in (str, content) and plain-text(value) == "")
)

/// Resolves the `country` of a party: a function of the `country` module
/// (`country.fr`), a country dictionary (`country.custom(..)`,
/// `(code: "NO", name: "Norge")`) or an ISO 3166-1 alpha-2 code as string or
/// content (`"FR"`). `auto`, `none` and an empty string give the country of
/// `default-region`.
///
/// Any other value is an error: a country must never be replaced silently.
///
/// -> dictionary
#let resolve-country(country-opt, default-region, field: "country") = {
  if _states-no-country(country-opt) {
    return country-from-region(default-region)
  }
  let kind = type(country-opt)
  if kind in (str, content) {
    let code = plain-text(country-opt)
    if code.match(_code-pattern) == none {
      _invalid-country(country-opt, field)
    }
    return country-from-code(code, field)
  }
  let country = if kind == function { country-opt() } else if (
    kind == dictionary
  ) { country-opt } else { _invalid-country(country-opt, field) }
  if type(country) != dictionary { _invalid-country(country-opt, field) }
  _complete-country(country, field)
}

// The `region` key of a party, an older alias of `country`: also accepts the
// regions of the `locale` module (`region.de`) and their dictionaries.
#let _resolve-region(region-opt, default-region, field) = {
  if type(region-opt) == function {
    import "../locale/region/region.typ"
    let locale-regions = (
      (region.at, "at"),
      (region.ch, "ch"),
      (region.de, "de"),
      (region.es, "es"),
      (region.fr, "fr"),
      (region.it, "it"),
    )
    for (region-fn, code) in locale-regions {
      if region-opt == region-fn { return country-from-region(code) }
    }
  }
  if (
    type(region-opt) == dictionary
      and type(region-opt.at("meta", default: none)) == dictionary
      and "region" in region-opt.meta
  ) {
    return country-from-region(region-opt.meta.region)
  }
  resolve-country(region-opt, default-region, field: field)
}

/// The country of a party and whether the party states it (`country` or
/// `region`). Without, the party gets `default-country` (e.g. the recipient's
/// country for a delivery address) or the country of `default-region`.
///
/// -> dictionary
#let resolve-party-country(
  party,
  default-region,
  default-country: auto,
  field: "party",
) = {
  let country-opt = party.at("country", default: auto)
  if not _states-no-country(country-opt) {
    return (
      country: resolve-country(
        country-opt,
        default-region,
        field: field + ".country",
      ),
      explicit: true,
    )
  }
  let region-opt = party.at("region", default: none)
  if not _states-no-country(region-opt) {
    return (
      country: _resolve-region(region-opt, default-region, field + ".region"),
      explicit: true,
    )
  }
  if default-country != auto {
    return (country: default-country, explicit: false)
  }
  (country: country-from-region(default-region), explicit: false)
}

// Checks the `city` of a party: a string, content or a dictionary whose parts
// are strings or content. A post code given as a number would lose its leading
// zeros ("01067 Dresden"), so it is rejected instead of converted.
#let _check-city(city, field) = {
  if city == () { return none }
  if city == none or type(city) in (str, content) { return city }
  if type(city) != dictionary {
    panic(
      "`"
        + field
        + ".city` must be a string such as \"10115 Berlin\", content or a dictionary `(name: \"Berlin\", post-code: \"10115\")`, got "
        + repr(city)
        + ".",
    )
  }
  for key in ("name", "post-code", "state", "display", "inline-display") {
    let value = city.at(key, default: none)
    if value != none and type(value) not in (str, content) {
      panic(
        "`"
          + field
          + ".city."
          + key
          + "` must be a string"
          + if key == "post-code" {
            " such as \"01067\", so that leading zeros are kept"
          } else { "" }
          + ", got "
          + repr(value)
          + ".",
      )
    }
  }
  city
}

#let normalize-party(
  party,
  default-region,
  is-recipient: false,
  sender-country-code: none,
  recipient-country-code: none,
  // The country of a party without `country` (and `region`); `auto` is the
  // country of `default-region`.
  default-country: auto,
  // The name of the party in error messages; `auto` is "sender" or
  // "recipient".
  field: auto,
) = {
  if type(party) != dictionary { return party }
  let field = if field != auto { field } else if is-recipient {
    "recipient"
  } else { "sender" }

  let has-street = "street" in party and party.street != none
  let has-address = "address" in party and party.address != none
  if has-street and has-address {
    panic(
      "Both 'street' and 'address' are populated for "
        + field
        + ", but they are mutually exclusive.",
    )
  }

  // 1. Resolve country
  let (country: resolved-country, explicit: country-explicit) = (
    resolve-party-country(
      party,
      default-region,
      default-country: default-country,
      field: field,
    )
  )

  // 2. Parse / extract city data
  let city-raw = _check-city(party.at("city", default: none), field)
  let parsed-city = none
  if city-raw != none {
    if type(city-raw) == dictionary {
      parsed-city = city-raw
    } else {
      parsed-city = (resolved-country.parse-city)(city-raw)
    }
  }

  // 3. Format name and address
  let format-poly-block(val) = {
    if val == none { none } else if type(val) == array {
      val.join([ \ ])
    } else { val }
  }

  let format-poly-inline(val) = {
    if val == none { none } else if type(val) == array { val.join(", ") } else {
      val
    }
  }

  let name-raw = party.at("name", default: none)
  let name-vertical = format-poly-block(name-raw)
  let name-inline = format-poly-inline(name-raw)

  let address-raw = if has-street { party.street } else {
    party.at("address", default: none)
  }
  let address-vertical = format-poly-block(address-raw)
  let address-inline = format-poly-inline(address-raw)

  // The raw lines; the e-invoice extracts their plain text itself.
  let address-lines = if address-raw == none {
    ()
  } else if type(address-raw) == array {
    address-raw
  } else {
    (address-raw,)
  }

  // 4. Format city (handling international country name printing)
  let display-country-name = none
  if resolved-country.code != none and lower(resolved-country.code) != "base" {
    let show-country = resolved-country.at("show-always", default: false)
    if not show-country {
      if is-recipient {
        if (
          (
            sender-country-code != none
              and lower(resolved-country.code) != lower(sender-country-code)
          )
            or (
              default-region != "base"
                and lower(resolved-country.code) != lower(default-region)
            )
        ) {
          show-country = true
        }
      } else {
        if (
          (
            recipient-country-code != none
              and lower(resolved-country.code) != lower(recipient-country-code)
          )
            or (
              default-region != "base"
                and lower(resolved-country.code) != lower(default-region)
            )
        ) {
          show-country = true
        }
      }
    }

    if show-country {
      display-country-name = if (
        resolved-country.name != none and resolved-country.name != ""
      ) {
        resolved-country.code + " - " + resolved-country.name
      } else {
        resolved-country.code
      }
    }
  }

  let city-vertical = if parsed-city != none {
    (resolved-country.format-address)(
      none,
      none,
      parsed-city,
      country-name: display-country-name,
    )
  } else { none }

  let city-inline = if parsed-city != none {
    (resolved-country.format-inline)(
      none,
      none,
      parsed-city,
      country-name: display-country-name,
    )
  } else { none }

  // 5. Build normalized dictionary
  {
    party
    (
      name: name-vertical,
      address-lines: address-lines,
      address: address-vertical,
      city: city-vertical,
      name-inline: name-inline,
      address-inline: address-inline,
      city-inline: city-inline,
      country: resolved-country,
      // Whether the party states its country; otherwise it is the default
      // (the locale region, or the recipient's country for a delivery
      // address).
      country-explicit: country-explicit,
      city-name: none,
      post-code: none,
      state: none,
      tax-nr: party.at("tax-nr", default: none),
      vat-id: party.at("vat-id", default: none),
    )

    if parsed-city != none {
      (city-name: parsed-city.at("name", default: none))
    }
    if parsed-city != none {
      (post-code: parsed-city.at("post-code", default: none))
    }
    if parsed-city != none {
      (state: parsed-city.at("state", default: none))
    }
  }
}
