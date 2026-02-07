// citrus - Locale Management
//
// Module entrance for locale functionality.
// Data is generated in data.typ; handler functions are defined here.

#import "data.typ": (
  _builtin-locales, _language-code-prefixes, _language-family-map,
  _language-name-map,
)

// =============================================================================
// Language Detection
// =============================================================================

/// Check if text contains CJK (Chinese/Japanese/Korean) characters
#let is-cjk-text(text) = {
  if text == none or text == "" { return false }
  let s = if type(text) == str { text } else { str(text) }

  s
    .codepoints()
    .any(c => {
      let code = c.to-unicode()
      // CJK Unified Ideographs (0x4E00-0x9FFF)
      // CJK Extension A (0x3400-0x4DBF)
      (code >= 0x4E00 and code <= 0x9FFF) or (code >= 0x3400 and code <= 0x4DBF)
    })
}

/// Check if a name dict contains CJK characters
#let is-cjk-name(name) = {
  let family = name.at("family", default: "")
  let given = name.at("given", default: "")
  is-cjk-text(family + given)
}

/// Detect language from context or fields
#let detect-language(ctx-or-fields) = {
  let fields = if (
    type(ctx-or-fields) == dictionary and "fields" in ctx-or-fields
  ) {
    ctx-or-fields.fields
  } else if type(ctx-or-fields) == dictionary {
    ctx-or-fields
  } else {
    (:)
  }

  let lang = fields.at("language", default: "")
  if lang != "" {
    let lower-lang = lower(lang)

    for (name, code) in _language-name-map.pairs() {
      if lower-lang.contains(name) { return code }
    }

    for prefix in _language-code-prefixes {
      if lower-lang.starts-with(prefix) { return prefix }
    }

    return lower-lang.slice(0, calc.min(2, lower-lang.len()))
  }

  let title = fields.at("title", default: "")
  if is-cjk-text(title) { return "zh" }

  "en"
}

/// Check if entry is Chinese
#let is-chinese-entry(ctx) = { detect-language(ctx) == "zh" }

/// Check if entry is English
#let is-english-entry(ctx) = { detect-language(ctx) == "en" }

// =============================================================================
// Locale Access
// =============================================================================

/// Get a built-in locale by language code
#let get-builtin-locale(lang) = {
  let locale = _builtin-locales.at(lang, default: none)
  if locale != none { return locale }

  let prefix = if lang.len() >= 2 { lower(lang.slice(0, 2)) } else {
    lower(lang)
  }
  let target = _language-family-map.at(prefix, default: "en-US")
  _builtin-locales.at(target)
}

/// Create a fallback locale for a language code
#let create-fallback-locale(lang) = {
  let builtin = get-builtin-locale(lang)
  (
    lang: lang,
    terms: builtin.terms,
    dates: builtin.dates,
    options: builtin.options,
    term-genders: builtin.at("term-genders", default: (:)),
    ordinal-gender-forms: builtin.at("ordinal-gender-forms", default: (:)),
  )
}

// =============================================================================
// CSL-M Locale Matching
// =============================================================================

/// Check if entry language matches a locale specification (CSL-M extension)
#let locale-matches(entry-lang, locale-spec) = {
  if locale-spec == none or locale-spec == "" { return true }

  let entry-prefix = if entry-lang.len() >= 2 {
    lower(entry-lang.slice(0, 2))
  } else {
    lower(entry-lang)
  }

  let locales = locale-spec.split(" ").map(s => s.trim()).filter(s => s != "")

  for locale in locales {
    let locale-prefix = if locale.len() >= 2 {
      lower(locale.slice(0, 2))
    } else {
      lower(locale)
    }

    if entry-prefix == locale-prefix { return true }
    if lower(entry-lang) == lower(locale) { return true }
  }

  false
}

/// Get the fallback chain for a language code (CSL-M extension)
#let get-locale-fallback-chain(lang) = {
  let chain = ()

  if lang != "" and lang in _builtin-locales {
    chain.push(lang)
  }

  let prefix = if lang.len() >= 2 { lower(lang.slice(0, 2)) } else {
    lower(lang)
  }
  let family-default = _language-family-map.at(prefix, default: none)

  if family-default != none and family-default not in chain {
    chain.push(family-default)
  }

  if "en-US" not in chain {
    chain.push("en-US")
  }

  chain
}

// =============================================================================
// Term Lookup
// =============================================================================

/// Look up a term from locale
///
/// CSL term lookup follows this fallback chain:
/// 1. Exact form match (e.g., "reviewed-author-verb-short")
/// 2. Form base fallback (e.g., "verb-short" -> "verb", "short" -> "long")
/// 3. Base term name (e.g., "reviewed-author")
#let lookup-term(ctx, name, form: "long", plural: false) = {
  let terms = ctx.locale.terms

  // Build list of keys to try in order
  let keys-to-try = ()

  if form == "long" {
    keys-to-try = (name,)
  } else if form == "verb-short" {
    // verb-short -> verb -> base
    keys-to-try = (name + "-verb-short", name + "-verb", name)
  } else if form == "short" {
    // short -> long (base)
    keys-to-try = (name + "-short", name)
  } else if form == "verb" {
    // verb -> base
    keys-to-try = (name + "-verb", name)
  } else if form == "symbol" {
    // symbol -> short -> base
    keys-to-try = (name + "-symbol", name + "-short", name)
  } else {
    // Generic fallback
    keys-to-try = (name + "-" + form, name)
  }

  // Try each key in order
  let term-value = none
  for key in keys-to-try {
    let val = terms.at(key, default: none)
    if val != none {
      term-value = val
      break
    }
  }

  // If term is not found, return none (distinct from empty string term)
  // CSL spec: "terms can be defined as empty strings (e.g. <term name="and"/>)"
  // An empty term definition is different from an undefined term
  if term-value == none {
    return none
  }

  // Handle singular/plural dictionary format
  if type(term-value) == dictionary {
    if plural {
      term-value.at("multiple", default: term-value.at("single", default: ""))
    } else {
      term-value.at("single", default: "")
    }
  } else {
    term-value
  }
}

// =============================================================================
// Quote Character Lookup
// =============================================================================

/// Get quote characters for a language
#let get-quote-chars(lang) = {
  let locale = get-builtin-locale(lang)
  let terms = locale.terms

  let default-quotes = (
    "open-quote": "\u{201C}",
    "close-quote": "\u{201D}",
    "open-inner-quote": "\u{2018}",
    "close-inner-quote": "\u{2019}",
  )

  (
    "open-quote": terms.at("open-quote", default: default-quotes.open-quote),
    "close-quote": terms.at("close-quote", default: default-quotes.close-quote),
    "open-inner-quote": terms.at(
      "open-inner-quote",
      default: default-quotes.open-inner-quote,
    ),
    "close-inner-quote": terms.at(
      "close-inner-quote",
      default: default-quotes.close-inner-quote,
    ),
  )
}
