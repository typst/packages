/// Deterministic salutation helpers, sharing the canonical Rust/TS/Python table.
#let de-table = json("../tables/de.json")

#let tokens(name) = name.trim().split(regex("\\s+")).filter(token => token != "")

/// Strip leading/trailing periods and lowercase ASCII A-Z only.
#let norm(token) = {
  token.trim(".").clusters().map(char => if char >= "A" and char <= "Z" { lower(char) } else { char }).fold("", (result, char) => result + char)
}

#let parse-region(code) = if code in ("ch", "li", "de", "at") { code } else { none }

#let region-uses-comma(region) = {
  assert(parse-region(region) != none, message: "region must be ch, li, de, or at")
  region in de-table.comma_regions
}

#let salutation-last-name(name) = tokens(name).at(-1, default: "")

#let salutation-honorific(name) = {
  de-table.honorifics.at(norm(tokens(name).at(0, default: "")), default: "")
}

#let salutation-title-kind(token) = de-table.titles.at(norm(token), default: "")

#let salutation-titles(name) = {
  let kept = ()
  for token in tokens(name) {
    let title = salutation-title-kind(token)
    if title != "" and title not in kept { kept.push(title) }
  }
  let sole = kept.filter(title => title in de-table.sole_titles)
  if sole.len() > 0 { (sole.first(),) } else { kept }
}

#let salutation-surname(name) = {
  tokens(name).filter(token => norm(token) not in de-table.filler).at(-1, default: "")
}

#let de-salutation(name, region: "ch") = {
  let comma = if region-uses-comma(region) { "," } else { "" }
  let honorific = salutation-honorific(name)
  let surname = salutation-surname(name)
  if honorific == "" or surname == "" {
    de-table.generic + comma
  } else {
    let titles = salutation-titles(name)
    let title-part = if titles.len() == 0 { "" } else { " " + titles.join(" ") }
    let address = if honorific == "frau" { "Sehr geehrte Frau" } else { "Sehr geehrter Herr" }
    address + title-part + " " + surname + comma
  }
}

#let recipient-salutation-warning(location, name) = {
  if salutation-last-name(name) == "" {
    location + ": job.cl_recipient.name is empty; using generic salutation (provide a name for tailored opportunities)"
  } else { none }
}

#let de-honorific-warning(location, name) = {
  if salutation-last-name(name) == "" {
    none
  } else if salutation-honorific(name) == "" or salutation-surname(name) == "" {
    location + ": job.cl_recipient.name has no parsable Herr/Frau honorific; using generic salutation (provide e.g. \"Frau Dr. Müller\" for tailored opportunities)"
  } else { none }
}
