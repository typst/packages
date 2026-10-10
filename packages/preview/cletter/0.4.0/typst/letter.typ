#import "generated/tables.typ": locales-table, countries-table
#import "vendor/cnice/typst/greet.typ" as cnice-greet
#import "vendor/cnice/typst/greet.typ": salutation-last-name, salutation-honorific, salutation-titles, salutation-surname, recipient-salutation-warning, honorific-warning, is-supported
#import "vendor/cnice/typst/farewell.typ": closing, available-locales
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

/// Opening line: when a name is given for a locale covered by the uniform
/// salutation renderer, the name is parsed and rendered the same way as
/// `salutation`; otherwise the `named` template is filled verbatim, or the
/// formal address when no name is given. An explicit override always wins.
#let opening(locale, name: none, override: none) = {
    if override != none {
        override
    } else {
        let entry = locales-table.locales.at(resolve-key(locale))
        if name != none and name.trim() != "" and is-supported(locale) {
            cnice-greet.salutation(locale, name.trim())
        } else if name != none and name.trim() != "" {
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

/// Normalize explicit locale spelling without inference, fallback or validation.
/// Trim ASCII space, tab, LF, CR, VT and FF; replace underscores with hyphens
/// and lowercase ASCII letters. Preserve other characters for caller validation.
/// Preserve all subtags, even outside the correspondence tables; empty stays empty.
#let normalize-locale-id(input) = {
    let trimmed = input.trim(regex("[ \t\n\r\u{b}\u{c}]"))
    trimmed.replace("_", "-").replace(regex("[A-Z]"), match => lower(match.text))
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

/// Locale-correct salutation through the uniform renderer for every locale
/// it covers (no per-language branch: coverage is data in the salutation
/// tables); all other locales resolve the opening template.
#let salutation(locale, name) = {
    let who = if name == none { "" } else { name }
    if is-supported(locale) {
        cnice-greet.salutation(locale, who)
    } else {
        opening(locale, name: who)
    }
}

/// Non-blocking advisories for a recipient name: the missing-name warning
/// in every locale, the honorific warning wherever the uniform renderer
/// applies. Empty means the record is clean.
#let warnings(location, locale, name) = {
    let result = ()
    let missing = recipient-salutation-warning(location, name)
    if missing != none { result.push(missing) }
    if is-supported(locale) {
        let honorific = honorific-warning(location, locale, name)
        if honorific != none { result.push(honorific) }
    }
    result
}
