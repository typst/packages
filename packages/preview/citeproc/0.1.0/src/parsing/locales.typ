// citeproc-typst - Locale Management
//
// Centralized language detection and built-in locale data.
// Supports zh-CN and en-US out of the box, with extension mechanism for other languages.

// =============================================================================
// Built-in Locale Data
// =============================================================================

/// Built-in locale data for supported languages
/// Structure: (terms: dict, dates: dict, options: dict)
#let _builtin-locales = (
  "en-US": (
    terms: (
      "et-al": "et al.",
      "and": "and",
      "and-symbol": "&",
      "with": "with",
      "edition": "edition",
      "edition-short": "ed.",
      "page": (single: "page", multiple: "pages"),
      "page-short": (single: "p.", multiple: "pp."),
      "volume": (single: "volume", multiple: "volumes"),
      "volume-short": (single: "vol.", multiple: "vols."),
      "issue": "issue",
      "chapter": "chapter",
      "chapter-short": "chap.",
      "editor": (single: "editor", multiple: "editors"),
      "editor-short": (single: "ed.", multiple: "eds."),
      "translator": "translator",
      "translator-short": "trans.",
      "references": "References",
      "accessed": "accessed",
      "retrieved": "retrieved",
      "from": "from",
      "in": "in",
      "no date": "n.d.",
      "no date-short": "n.d.",
      // CSL-M legal terms
      "article": "article",
      "paragraph": "paragraph",
      "section": "section",
      "rule": "rule",
      // Quote marks (U+201C/D double, U+2018/9 single)
      "open-quote": "\u{201C}",
      "close-quote": "\u{201D}",
      "open-inner-quote": "\u{2018}",
      "close-inner-quote": "\u{2019}",
      // Ordinal suffixes (CSL 1.0.2)
      "ordinal": "th",
      "ordinal-01": "st",
      "ordinal-02": "nd",
      "ordinal-03": "rd",
      "ordinal-11": "th",
      "ordinal-12": "th",
      "ordinal-13": "th",
      // Long ordinals (1-10)
      "long-ordinal-01": "first",
      "long-ordinal-02": "second",
      "long-ordinal-03": "third",
      "long-ordinal-04": "fourth",
      "long-ordinal-05": "fifth",
      "long-ordinal-06": "sixth",
      "long-ordinal-07": "seventh",
      "long-ordinal-08": "eighth",
      "long-ordinal-09": "ninth",
      "long-ordinal-10": "tenth",
    ),
    dates: (:),
    options: (:),
  ),
  "zh-CN": (
    terms: (
      "et-al": "等",
      "and": "和",
      "and-symbol": "&",
      "with": "与",
      "edition": "版",
      "edition-short": "版",
      "page": (single: "页", multiple: "页"),
      "page-short": (single: "p.", multiple: "pp."),
      "volume": (single: "卷", multiple: "卷"),
      "volume-short": (single: "卷", multiple: "卷"),
      "issue": "期",
      "chapter": "章",
      "chapter-short": "章",
      "editor": (single: "编", multiple: "编"),
      "editor-short": (single: "编", multiple: "编"),
      "translator": "译",
      "translator-short": "译",
      "references": "参考文献",
      // Chinese uses same curly quotes as English
      "open-quote": "\u{201C}",
      "close-quote": "\u{201D}",
      "open-inner-quote": "\u{2018}",
      "close-inner-quote": "\u{2019}",
      "accessed": "访问",
      "retrieved": "检索于",
      "from": "自",
      "in": "载",
      "no date": "无日期",
      "no date-short": "无日期",
      // CSL-M legal terms
      "article": "条",
      "paragraph": "款",
      "section": "节",
      "rule": "规则",
    ),
    dates: (:),
    options: (:),
  ),
  "zh-TW": (
    terms: (
      "et-al": "等",
      "and": "與",
      "and-symbol": "&",
      "edition": "版",
      "edition-short": "版",
      "page": (single: "頁", multiple: "頁"),
      "page-short": (single: "p.", multiple: "pp."),
      "volume": (single: "卷", multiple: "卷"),
      "volume-short": (single: "卷", multiple: "卷"),
      "issue": "期",
      "chapter": "章",
      "chapter-short": "章",
      "editor": (single: "編", multiple: "編"),
      "editor-short": (single: "編", multiple: "編"),
      "translator": "譯",
      "translator-short": "譯",
      "references": "參考文獻",
      // Traditional Chinese uses corner brackets
      "open-quote": "\u{300C}",
      "close-quote": "\u{300D}",
      "open-inner-quote": "\u{300E}",
      "close-inner-quote": "\u{300F}",
      "accessed": "存取",
      "retrieved": "檢索於",
      "from": "自",
      "in": "載",
      "no date": "無日期",
      "no date-short": "無日期",
    ),
    dates: (:),
    options: (:),
  ),
  "de-DE": (
    terms: (
      "et-al": "et al.",
      "and": "und",
      "and-symbol": "&",
      "edition": "Auflage",
      "edition-short": "Aufl.",
      "page": (single: "Seite", multiple: "Seiten"),
      "page-short": (single: "S.", multiple: "S."),
      "volume": (single: "Band", multiple: "Bände"),
      "volume-short": (single: "Bd.", multiple: "Bde."),
      "issue": "Heft",
      "chapter": "Kapitel",
      "chapter-short": "Kap.",
      "editor": (single: "Herausgeber", multiple: "Herausgeber"),
      "editor-short": (single: "Hrsg.", multiple: "Hrsg."),
      "translator": "Übersetzer",
      "translator-short": "Übers.",
      "references": "Literaturverzeichnis",
      "accessed": "zugegriffen",
      "retrieved": "abgerufen am",
      "from": "von",
      "in": "in",
      "no date": "o. J.",
      "no date-short": "o. J.",
      // German quotes: „..." and ‚...'
      "open-quote": "\u{201E}",
      "close-quote": "\u{201C}",
      "open-inner-quote": "\u{201A}",
      "close-inner-quote": "\u{2018}",
    ),
    dates: (:),
    options: (:),
  ),
  "fr-FR": (
    terms: (
      "et-al": "et al.",
      "and": "et",
      "and-symbol": "&",
      "edition": "édition",
      "edition-short": "éd.",
      "page": (single: "page", multiple: "pages"),
      "page-short": (single: "p.", multiple: "p."),
      "volume": (single: "volume", multiple: "volumes"),
      "volume-short": (single: "vol.", multiple: "vol."),
      "issue": "numéro",
      "chapter": "chapitre",
      "chapter-short": "chap.",
      "editor": (single: "éditeur", multiple: "éditeurs"),
      "editor-short": (single: "éd.", multiple: "éds."),
      "translator": "traducteur",
      "translator-short": "trad.",
      "references": "Références",
      "accessed": "consulté",
      "retrieved": "récupéré le",
      "from": "de",
      "in": "dans",
      "no date": "s. d.",
      "no date-short": "s. d.",
      // French quotes: «...» and ‹...› with non-breaking spaces
      "open-quote": "\u{00AB}\u{00A0}",
      "close-quote": "\u{00A0}\u{00BB}",
      "open-inner-quote": "\u{2039}\u{00A0}",
      "close-inner-quote": "\u{00A0}\u{203A}",
    ),
    dates: (:),
    options: (:),
  ),
  "es-ES": (
    terms: (
      "et-al": "et al.",
      "and": "y",
      "and-symbol": "&",
      "edition": "edición",
      "edition-short": "ed.",
      "page": (single: "página", multiple: "páginas"),
      "page-short": (single: "p.", multiple: "pp."),
      "volume": (single: "volumen", multiple: "volúmenes"),
      "volume-short": (single: "vol.", multiple: "vols."),
      "issue": "número",
      "chapter": "capítulo",
      "chapter-short": "cap.",
      "editor": (single: "editor", multiple: "editores"),
      "editor-short": (single: "ed.", multiple: "eds."),
      "translator": "traductor",
      "translator-short": "trad.",
      "references": "Referencias",
      "accessed": "accedido",
      "retrieved": "recuperado el",
      "from": "de",
      "in": "en",
      "no date": "s. f.",
      "no date-short": "s. f.",
      // Spanish quotes: «...» and "..."
      "open-quote": "\u{00AB}",
      "close-quote": "\u{00BB}",
      "open-inner-quote": "\u{201C}",
      "close-inner-quote": "\u{201D}",
    ),
    dates: (:),
    options: (:),
  ),
  "ja-JP": (
    terms: (
      "et-al": "ほか",
      "and": "・",
      "and-symbol": "&",
      "edition": "版",
      "edition-short": "版",
      "page": (single: "ページ", multiple: "ページ"),
      "page-short": (single: "p.", multiple: "pp."),
      "volume": (single: "巻", multiple: "巻"),
      "volume-short": (single: "巻", multiple: "巻"),
      "issue": "号",
      "chapter": "章",
      "chapter-short": "章",
      "editor": (single: "編", multiple: "編"),
      "editor-short": (single: "編", multiple: "編"),
      "translator": "訳",
      "translator-short": "訳",
      "references": "参考文献",
      "accessed": "アクセス日",
      "retrieved": "取得日",
      "from": "より",
      "in": "所収",
      "no date": "日付なし",
      "no date-short": "n.d.",
      // Japanese quotes: 「...」 and 『...』
      "open-quote": "\u{300C}",
      "close-quote": "\u{300D}",
      "open-inner-quote": "\u{300E}",
      "close-inner-quote": "\u{300F}",
    ),
    dates: (:),
    options: (:),
  ),
  "ko-KR": (
    terms: (
      "et-al": "외",
      "and": "및",
      "and-symbol": "&",
      "edition": "판",
      "edition-short": "판",
      "page": (single: "쪽", multiple: "쪽"),
      "page-short": (single: "p.", multiple: "pp."),
      "volume": (single: "권", multiple: "권"),
      "volume-short": (single: "권", multiple: "권"),
      "issue": "호",
      "chapter": "장",
      "chapter-short": "장",
      "editor": (single: "편", multiple: "편"),
      "editor-short": (single: "편", multiple: "편"),
      "translator": "역",
      "translator-short": "역",
      "references": "참고문헌",
      "accessed": "접근일",
      "retrieved": "검색일",
      "from": "에서",
      "in": "소재",
      "no date": "날짜 없음",
      "no date-short": "n.d.",
      // Korean uses same quotes as Japanese or English
      "open-quote": "\u{201C}",
      "close-quote": "\u{201D}",
      "open-inner-quote": "\u{2018}",
      "close-inner-quote": "\u{2019}",
    ),
    dates: (:),
    options: (:),
  ),
  "pt-BR": (
    terms: (
      "et-al": "et al.",
      "and": "e",
      "and-symbol": "&",
      "edition": "edição",
      "edition-short": "ed.",
      "page": (single: "página", multiple: "páginas"),
      "page-short": (single: "p.", multiple: "p."),
      "volume": (single: "volume", multiple: "volumes"),
      "volume-short": (single: "v.", multiple: "v."),
      "issue": "número",
      "chapter": "capítulo",
      "chapter-short": "cap.",
      "editor": (single: "editor", multiple: "editores"),
      "editor-short": (single: "ed.", multiple: "eds."),
      "translator": "tradutor",
      "translator-short": "trad.",
      "references": "Referências",
      "accessed": "acessado",
      "retrieved": "recuperado em",
      "from": "de",
      "in": "em",
      "no date": "s.d.",
      "no date-short": "s.d.",
      // Portuguese uses English-style quotes
      "open-quote": "\u{201C}",
      "close-quote": "\u{201D}",
      "open-inner-quote": "\u{2018}",
      "close-inner-quote": "\u{2019}",
    ),
    dates: (:),
    options: (:),
  ),
  "ru-RU": (
    terms: (
      "et-al": "и др.",
      "and": "и",
      "and-symbol": "&",
      "edition": "издание",
      "edition-short": "изд.",
      "page": (single: "страница", multiple: "страницы"),
      "page-short": (single: "с.", multiple: "с."),
      "volume": (single: "том", multiple: "тома"),
      "volume-short": (single: "т.", multiple: "т."),
      "issue": "выпуск",
      "chapter": "глава",
      "chapter-short": "гл.",
      "editor": (single: "редактор", multiple: "редакторы"),
      "editor-short": (single: "ред.", multiple: "ред."),
      "translator": "переводчик",
      "translator-short": "пер.",
      "references": "Литература",
      "accessed": "дата обращения",
      "retrieved": "получено",
      "from": "из",
      "in": "в",
      "no date": "б. г.",
      "no date-short": "б. г.",
      // Russian quotes: «...» and „..."
      "open-quote": "\u{00AB}",
      "close-quote": "\u{00BB}",
      "open-inner-quote": "\u{201E}",
      "close-inner-quote": "\u{201C}",
    ),
    dates: (:),
    options: (:),
  ),
)

// =============================================================================
// Language Detection
// =============================================================================

/// Check if text contains CJK (Chinese/Japanese/Korean) characters
///
/// - text: String to check
/// Returns: bool
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
///
/// - name: Name dict with family/given fields
/// Returns: bool
#let is-cjk-name(name) = {
  let family = name.at("family", default: "")
  let given = name.at("given", default: "")
  is-cjk-text(family + given)
}

// Language name to code mappings (module-level constant)
#let _language-name-map = (
  "chinese": "zh",
  "english": "en",
  "german": "de",
  "french": "fr",
  "spanish": "es",
  "japanese": "ja",
  "korean": "ko",
  "portuguese": "pt",
  "russian": "ru",
)

// Language code prefixes for detection
#let _language-code-prefixes = (
  "zh",
  "en",
  "de",
  "fr",
  "es",
  "ja",
  "ko",
  "pt",
  "ru",
)

/// Detect language from context or fields
///
/// Priority:
/// 1. Explicit "language" field in entry
/// 2. Auto-detect from title content (CJK → zh, else → en)
///
/// - ctx-or-fields: Either a context dict (with .fields) or a fields dict directly
/// Returns: "zh" or "en"
#let detect-language(ctx-or-fields) = {
  // Extract fields from context or use directly
  let fields = if (
    type(ctx-or-fields) == dictionary and "fields" in ctx-or-fields
  ) {
    ctx-or-fields.fields
  } else if type(ctx-or-fields) == dictionary {
    ctx-or-fields
  } else {
    (:)
  }

  // Check explicit language field
  let lang = fields.at("language", default: "")
  if lang != "" {
    let lower-lang = lower(lang)

    // Check for language names
    for (name, code) in _language-name-map.pairs() {
      if lower-lang.contains(name) {
        return code
      }
    }

    // Check for language codes (e.g., "zh-CN", "en-US", "de")
    for prefix in _language-code-prefixes {
      if lower-lang.starts-with(prefix) {
        return prefix
      }
    }

    // Return first two chars as language code
    return lower-lang.slice(0, calc.min(2, lower-lang.len()))
  }

  // Auto-detect from content
  let title = fields.at("title", default: "")

  // Check for CJK (Chinese/Japanese/Korean)
  if is-cjk-text(title) {
    // Could be Chinese, Japanese, or Korean
    // For now, default to Chinese; could be enhanced with better detection
    return "zh"
  }

  // Default to English
  "en"
}

/// Check if entry is Chinese
///
/// - ctx: Context with .fields
/// Returns: bool
#let is-chinese-entry(ctx) = {
  detect-language(ctx) == "zh"
}

/// Check if entry is English
///
/// - ctx: Context with .fields
/// Returns: bool
#let is-english-entry(ctx) = {
  detect-language(ctx) == "en"
}

// =============================================================================
// Locale Access
// =============================================================================

/// Language family mappings for fallback
#let _language-family-map = (
  "zh": "zh-CN",
  "en": "en-US",
  "de": "de-DE",
  "fr": "fr-FR",
  "es": "es-ES",
  "ja": "ja-JP",
  "ko": "ko-KR",
  "pt": "pt-BR",
  "ru": "ru-RU",
)

/// Get a built-in locale by language code
///
/// Supports partial matching: "zh" matches "zh-CN", "en" matches "en-US"
///
/// - lang: Language code (e.g., "en-US", "zh-CN", "en", "zh")
/// Returns: Locale dict or none
#let get-builtin-locale(lang) = {
  // Try exact match first
  let locale = _builtin-locales.at(lang, default: none)
  if locale != none { return locale }

  // Try prefix match for language variants
  let prefix = if lang.len() >= 2 { lower(lang.slice(0, 2)) } else {
    lower(lang)
  }

  let target = _language-family-map.at(prefix, default: "en-US")
  _builtin-locales.at(target)
}

/// Create a fallback locale for a language code
///
/// Uses built-in locale data if available, otherwise returns English defaults.
///
/// - lang: Language code
/// Returns: Complete locale dict (lang, terms, dates, options)
#let create-fallback-locale(lang) = {
  let builtin = get-builtin-locale(lang)
  (
    lang: lang,
    terms: builtin.terms,
    dates: builtin.dates,
    options: builtin.options,
  )
}

// =============================================================================
// CSL-M Locale Matching (for layout selection)
// =============================================================================

/// Check if entry language matches a locale specification (CSL-M extension)
///
/// Used for selecting the correct layout in multilingual styles.
/// The locale attribute can contain multiple space-separated locales.
///
/// Examples:
///   - "en" matches "en", "en-US", "en-GB"
///   - "en es de" matches entries in English, Spanish, or German
///   - "zh" matches "zh", "zh-CN", "zh-TW"
///
/// - entry-lang: The entry's language code (e.g., "en", "zh-CN", "de-AT")
/// - locale-spec: Space-separated locale codes from CSL layout
/// Returns: bool
#let locale-matches(entry-lang, locale-spec) = {
  if locale-spec == none or locale-spec == "" {
    return true // No locale restriction
  }

  // Normalize entry language
  let entry-prefix = if entry-lang.len() >= 2 {
    lower(entry-lang.slice(0, 2))
  } else {
    lower(entry-lang)
  }

  // Parse locale spec (space-separated list)
  let locales = locale-spec.split(" ").map(s => s.trim()).filter(s => s != "")

  // Check if any locale matches
  for locale in locales {
    let locale-prefix = if locale.len() >= 2 {
      lower(locale.slice(0, 2))
    } else {
      lower(locale)
    }

    // Match by prefix (en matches en-US, en-GB, etc.)
    if entry-prefix == locale-prefix {
      return true
    }

    // Also try exact match for full locale codes
    if lower(entry-lang) == lower(locale) {
      return true
    }
  }

  false
}

/// Get the fallback chain for a language code (CSL-M extension)
///
/// Returns a list of locales to try, from most specific to most generic.
/// Used when looking up terms that may not exist in the primary locale.
///
/// Examples:
///   - "de-AT" → ["de-AT", "de-DE", "en-US"]
///   - "pt-PT" → ["pt-BR", "en-US"] (pt-PT not built-in, uses pt-BR)
///   - "en" → ["en-US"]
///
/// - lang: Language code
/// Returns: Array of locale codes to try
#let get-locale-fallback-chain(lang) = {
  let chain = ()

  // Add exact match first
  if lang != "" and lang in _builtin-locales {
    chain.push(lang)
  }

  // Add language family default
  let prefix = if lang.len() >= 2 { lower(lang.slice(0, 2)) } else {
    lower(lang)
  }
  let family-default = _language-family-map.at(prefix, default: none)

  if family-default != none and family-default not in chain {
    chain.push(family-default)
  }

  // Always include English as final fallback
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
/// Per CSL spec, terms are looked up from the style's locale (ctx.locale),
/// which is determined by the style's default-locale attribute.
/// For multilingual output, use CSL-M's <layout locale="..."> mechanism
/// to select different layouts for different entry languages.
///
/// - ctx: Context with .locale
/// - name: Term name (e.g., "page", "editor", "et-al")
/// - form: Term form ("long", "short", "verb", "verb-short", "symbol")
/// - plural: Whether to use plural form
/// Returns: Term string
#let lookup-term(ctx, name, form: "long", plural: false) = {
  let key = if form == "long" { name } else { name + "-" + form }

  // Look up term from context locale (per CSL spec)
  let term-value = ctx.locale.terms.at(key, default: none)
  if term-value == none {
    // Try without form suffix
    term-value = ctx.locale.terms.at(name, default: "")
  }

  // Handle single/multiple forms
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
///
/// - lang: Language code (e.g., "en-US", "zh-CN", "de", "fr")
/// Returns: Dictionary with open-quote, close-quote, open-inner-quote, close-inner-quote
#let get-quote-chars(lang) = {
  let locale = get-builtin-locale(lang)
  let terms = locale.terms

  // Default English quotes as fallback
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
