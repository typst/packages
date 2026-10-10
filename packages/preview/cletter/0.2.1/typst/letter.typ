#import "generated/tables.typ": locales-table, countries-table
#import "vendor/cgreet/typst/greet.typ": parse-region, region-uses-comma, salutation-last-name, salutation-honorific, salutation-title-kind, salutation-titles, salutation-surname, de-salutation, recipient-salutation-warning, de-honorific-warning
#import "vendor/cfarewell/typst/farewell.typ": closing, available-locales
#import "vendor/cdate/typst/date.typ": long-date, medium-date, short-date, month-year, is-valid-date
#import "vendor/cink/typst/ink.typ": signature-image

/// Lowercase locale IDs with case-insensitive input; exact code, base language,
/// then English fallback. Explicit overrides always win.
#let base-language(code) = code.split("-").at(0)

#let resolve-key(locale) = {
  let lowered = lower(locale)
  let base = base-language(lowered)
  if lowered in locales-table.locales {
    lowered
  } else if base in locales-table.locales {
    base
  } else {
    locales-table.fallback
  }
}

/// Opening line: the `named` template with `{name}` filled when a name is
/// given, otherwise the formal address. An explicit override always wins.
#let opening(locale, name: none, override: none) = {
    if override != none {
        override
    } else {
        let entry = locales-table.locales.at(resolve-key(locale))
        if name != none and name.trim() != "" {
            entry.named.replace("{name}", name.trim())
        } else {
            entry.formal
        }
    }
}

/// Subject line: prefix plus title, or the unsolicited default.
/// The override replaces the prefix only.
#let subject(locale, title: none, prefix-override: none) = {
    let entry = locales-table.locales.at(resolve-key(locale))
    if title != none and title.trim() != "" {
        let prefix = if prefix-override != none { prefix-override } else { entry.subject_prefix }
        prefix + " " + title.trim()
    } else {
        entry.subject_unsolicited
    }
}

/// Literal source/replacement pairs for the locale, in table order.
#let orthography-replacements(locale) = {
    if locales-table.locales.at(resolve-key(locale)).use_ss {
        locales-table.orthography_replacements
    } else {
        ()
    }
}

/// Non-mutating diagnostics for caller-selected prose; each matched pair once.
#let orthography-issues(locale, text) = {
    orthography-replacements(locale).filter(pair => text.contains(pair.at(0)))
}

/// Apply literal substitutions only to caller-selected prose. Exclude protected
/// names, quotations, URLs and source material first, or use orthography-issues.
/// Opening, subject, closing and overrides are never transformed implicitly.
#let apply-ortho(locale, text) = {
    let result = text
    for pair in orthography-replacements(locale) {
        result = result.replace(pair.at(0), pair.at(1))
    }
    result
}

/// Country extraction from a free-text location: keywords, then cantons.
#let country-from-location(location) = {
    let lowered = lower(location).trim()
    if lowered == "" {
        none
    } else {
        let found = none
        for (keyword, code) in countries-table.keywords {
            if lowered.contains(keyword) {
                found = code
                break
            }
        }
        if found == none {
            for part in lowered.split(regex("[,;]")) {
                if part.trim() in countries-table.cantons {
                    found = "CH"
                    break
                }
            }
        }
        found
    }
}

/// Normalize mixed case and underscores to a supported lowercase locale ID.
#let normalize-language(input) = {
    let lowered = lower(input.trim().replace("_", "-"))
    let base = base-language(lowered)
    if lowered in locales-table.supported {
        lowered
    } else if base in locales-table.supported {
        base
    } else {
        none
    }
}

/// Resolve a language plus an optional location to a lowercase BCP 47 locale.
#let resolve-locale(language: none, location: none) = {
    let normalized = if language == none { none } else { normalize-language(language) }
    if normalized == none { normalized = "en" }
    let base = base-language(normalized)
    let country = if location == none { none } else { country-from-location(location) }
    if country == none {
        normalized
    } else {
        locales-table.variants.at(base, default: (:)).at(country, default: base)
    }
}

/// cgreet region for locales whose salutation it implements.
#let region-for(locale) = {
    parse-region(locales-table.locales.at(resolve-key(locale)).at("region", default: ""))
}

/// German locales use cgreet; other locales use the named opening template.
#let salutation(locale, name) = {
    let region = region-for(locale)
    if region == none { opening(locale, name: name) } else { de-salutation(name, region: region) }
}

/// Nonblocking recipient advisories, matching the Rust/TS/Python facade.
#let warnings(location, locale, name) = {
    let result = ()
    let missing = recipient-salutation-warning(location, name)
    if missing != none { result.push(missing) }
    if region-for(locale) != none {
        let honorific = de-honorific-warning(location, name)
        if honorific != none { result.push(honorific) }
    }
    result
}
