// --- Regional Parsers and Formatters ---

#let parse-city-euro(city-str) = {
  let m = city-str.match(regex("^\\s*(?:[A-Z]{1,2}-)?(\\d{4,5})\\s+(.+)$"))
  if m != none {
    let pc-raw = m.captures.at(0, default: none)
    let name-raw = m.captures.at(1, default: none)
    (
      name: if name-raw != none { name-raw.trim() } else { "" },
      post-code: if pc-raw != none { pc-raw.trim() } else { none },
    )
  } else {
    (
      name: city-str.trim(),
      post-code: none,
    )
  }
}

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

#let parse-city-uk(city-str) = {
  let m = city-str.match(
    regex(
      "(?i)^\\s*(.+?)(?:,\\s*|\\s+|\\n)\\s*([a-z]{1,2}\\d[a-z\\d]?\\s*\\d[a-z]{2})\\s*$",
    ),
  )
  if m != none {
    let name-raw = m.captures.at(0, default: none)
    let pc-raw = m.captures.at(1, default: none)
    (
      name: if name-raw != none { name-raw.trim() } else { "" },
      post-code: if pc-raw != none { upper(pc-raw).trim() } else { none },
    )
  } else {
    (
      name: city-str.trim(),
      post-code: none,
    )
  }
}

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
  let m1 = city-str.match(
    regex(
      "(?i)^\\s*(.+?)(?:,\\s*|\\s+)([a-z]{2})\\s+(\\d{5}(?:-\\d{4})?)\\s*$",
    ),
  )
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
    let m2 = city-str.match(
      regex("(?i)^\\s*(.+?)(?:,\\s*|\\s+)(\\d{5}(?:-\\d{4})?)\\s*$"),
    )
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
  let to-string(it) = {
    if type(it) == str { it } else if it == none or it == auto { "" } else if (
      type(it) != content
    ) {
      str(it)
    } else if it.has("text") { it.text } else if it.has("children") {
      it.children.map(to-string).join()
    } else if it.has("body") { to-string(it.body) } else { "" }
  }

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
      parse-city-raw(to-string(city))
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

// --- Exported Country Functions ---

#let de(name: "Deutschland", code: "DE", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let at(name: "Österreich", code: "AT", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let ch(name: "Schweiz", code: "CH", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let fr(name: "France", code: "FR", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let it(name: "Italia", code: "IT", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let es(name: "España", code: "ES", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)

#let be(name: "België", code: "BE", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let bg(name: "Bulgaria", code: "BG", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let cy(name: "Cyprus", code: "CY", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let cz(name: "Česko", code: "CZ", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let dk(name: "Danmark", code: "DK", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let ee(name: "Eesti", code: "EE", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let gr(name: "Greece", code: "GR", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let hr(name: "Hrvatska", code: "HR", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let hu(name: "Magyarország", code: "HU", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let ie(name: "Ireland", code: "IE", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let lt(name: "Lietuva", code: "LT", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let lu(name: "Luxembourg", code: "LU", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let lv(name: "Latvija", code: "LV", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let mt(name: "Malta", code: "MT", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let nl(name: "Nederland", code: "NL", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let pl(name: "Polska", code: "PL", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let pt(name: "Portugal", code: "PT", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let ro(name: "România", code: "RO", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let se(name: "Sverige", code: "SE", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let si(name: "Slovenija", code: "SI", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)
#let sk(name: "Slovensko", code: "SK", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
)

#let uk(name: "United Kingdom", code: "GB", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
  format-city: format-city-uk,
  format-inline-city: format-inline-city-uk,
  parse-city-raw: parse-city-uk,
)

#let us(name: "United States", code: "US", show-always: false) = make-country(
  name: name,
  code: code,
  show-always: show-always,
  format-city: format-city-us,
  format-inline-city: format-city-us,
  parse-city-raw: parse-city-us,
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

#let normalize-region-to-string(region-opt, fallback) = {
  if region-opt == none or region-opt == auto {
    return fallback
  }
  if type(region-opt) == str {
    return region-opt
  }
  if type(region-opt) == dictionary {
    if (
      "meta" in region-opt
        and type(region-opt.meta) == dictionary
        and "region" in region-opt.meta
    ) {
      return region-opt.meta.region
    }
    if "code" in region-opt and type(region-opt.code) == str {
      return region-opt.code
    }
  }
  if type(region-opt) == function {
    import "../locale/region/region.typ"
    if region-opt == region.at { "at" } else if region-opt == region.ch {
      "ch"
    } else if region-opt == region.de { "de" } else if region-opt == region.es {
      "es"
    } else if region-opt == region.fr { "fr" } else if region-opt == region.it {
      "it"
    } else if region-opt == de { "de" } else if region-opt == at {
      "at"
    } else if region-opt == ch { "ch" } else if region-opt == fr {
      "fr"
    } else if region-opt == it { "it" } else if region-opt == es {
      "es"
    } else if region-opt == be { "be" } else if region-opt == bg {
      "bg"
    } else if region-opt == cy { "cy" } else if region-opt == cz {
      "cz"
    } else if region-opt == dk { "dk" } else if region-opt == ee {
      "ee"
    } else if region-opt == gr { "gr" } else if region-opt == hr {
      "hr"
    } else if region-opt == hu { "hu" } else if region-opt == ie {
      "ie"
    } else if region-opt == lt { "lt" } else if region-opt == lu {
      "lu"
    } else if region-opt == lv { "lv" } else if region-opt == mt {
      "mt"
    } else if region-opt == nl { "nl" } else if region-opt == pl {
      "pl"
    } else if region-opt == pt { "pt" } else if region-opt == ro {
      "ro"
    } else if region-opt == se { "se" } else if region-opt == si {
      "si"
    } else if region-opt == sk { "sk" } else if region-opt == uk {
      "gb"
    } else if region-opt == us { "us" } else { fallback }
  } else {
    fallback
  }
}

#let resolve-country(country-opt, default-region) = {
  if type(country-opt) == function {
    country-opt()
  } else if type(country-opt) == dictionary {
    country-opt
  } else {
    // country-opt is auto
    let region-lower = lower(default-region)
    if region-lower in region-to-country {
      region-to-country.at(region-lower)()
    } else {
      make-country(code: upper(default-region))
    }
  }
}

#let normalize-party(
  party,
  default-region,
  is-recipient: false,
  sender-country-code: none,
  recipient-country-code: none,
) = {
  if type(party) != dictionary { return party }

  let has-street = "street" in party and party.street != none
  let has-address = "address" in party and party.address != none
  if has-street and has-address {
    panic(
      "Both 'street' and 'address' are populated for "
        + (if is-recipient { "recipient" } else { "sender" })
        + ", but they are mutually exclusive.",
    )
  }

  // 1. Resolve country
  let party-region-raw = party.at("region", default: none)
  let party-region = normalize-region-to-string(
    party-region-raw,
    default-region,
  )

  let country-opt = party.at("country", default: auto)
  let resolved-country = resolve-country(country-opt, party-region)

  // 2. Parse / extract city data
  let city-raw = party.at("city", default: none)
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

  import "../utils/coercion.typ": to-string
  let address-lines = if address-raw == none {
    ()
  } else if type(address-raw) == array {
    address-raw.map(to-string)
  } else {
    (to-string(address-raw),)
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

