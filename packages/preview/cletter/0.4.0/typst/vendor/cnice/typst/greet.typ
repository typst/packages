/// Deterministic locale-correct salutations, sharing the canonical table.
#let salutation-table = json("../tables/salutation.json")

/// Rust split_whitespace semantics: explicit Unicode White_Space set, not \s.
#let ws-regex = regex("[ \t\n\r\u{b}\u{c}\u{85}\u{a0}\u{1680}\u{2000}-\u{200a}\u{2028}\u{2029}\u{202f}\u{205f}\u{3000}]+")

#let tokens(name) = name.split(ws-regex).filter(token => token != "")

/// Strip leading/trailing periods and lowercase ASCII A-Z only.
#let norm(token) = {
  token.trim(".").replace(regex("[A-Z]"), match => lower(match.text))
}

#let base-language(locale) = locale.split("-").at(0)

#let resolve-key(locale) = {
  let lowered = lower(locale)
  let base = base-language(lowered)
  if lowered in salutation-table.locales {
    lowered
  } else if base in salutation-table.locales {
    base
  } else {
    salutation-table.fallback
  }
}

#let is-supported(locale) = {
  let lowered = lower(locale)
  lowered in salutation-table.locales or base-language(lowered) in salutation-table.locales
}

#let salutation-last-name(name) = tokens(name).at(-1, default: "")

#let salutation-honorific(locale, name) = {
  let entry = salutation-table.locales.at(resolve-key(locale))
  let first = tokens(name).at(0, default: "")
  let found = entry.at("honorifics").at(norm(first), default: none)
  if found == none { "" } else { found.at("display") }
}

#let salutation-titles(locale, name) = {
  let entry = salutation-table.locales.at(resolve-key(locale))
  let kept = ()
  for token in tokens(name) {
    let title = entry.at("titles").at(norm(token), default: none)
    if title != none and title not in kept { kept.push(title) }
  }
  let sole = kept.filter(title => title in entry.at("sole_titles"))
  if sole.len() > 0 { (sole.first(),) } else { kept }
}

#let salutation-surname(locale, name) = {
  let entry = salutation-table.locales.at(resolve-key(locale))
  tokens(name).filter(token => norm(token) not in entry.at("filler")).at(-1, default: "")
}

#let salutation(locale, name) = {
  let entry = salutation-table.locales.at(resolve-key(locale))
  let punct = if entry.at("comma") { "," } else { "" }
  let first = tokens(name).at(0, default: "")
  let honorific = entry.at("honorifics").at(norm(first), default: none)
  let surname = salutation-surname(locale, name)
  if honorific == none or surname == "" {
    entry.at("formal") + punct
  } else {
    let titles = salutation-titles(locale, name)
    let title-str = if titles.len() == 0 { "" } else { titles.join(" ") }
    let template = entry.at("named").at(honorific.at("group"), default: entry.at("formal"))
    let rendered = template.replace("{honorific}", honorific.at("display")).replace("{titles}", title-str).replace("{surname}", surname)
    let collapsed = rendered.split(ws-regex).filter(token => token != "").join(" ")
    collapsed + punct
  }
}

#let recipient-salutation-warning(location, name) = {
  if salutation-last-name(name) == "" {
    location + ": job.cl_recipient.name is empty; using formal salutation (provide a name for tailored opportunities)"
  } else { none }
}

#let honorific-warning(location, locale, name) = {
  if salutation-last-name(name) == "" {
    none
  } else if salutation-honorific(locale, name) == "" or salutation-surname(locale, name) == "" {
    location + ": job.cl_recipient.name has no parsable honorific for " + locale + "; using formal salutation (provide an explicit honorific for tailored opportunities)"
  } else { none }
}
