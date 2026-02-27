// arabib – Arabic-aware bibliography package for Typst
//
// Wraps the citrus CSL processor with bundled styles (MLA, IEEE)
// and locale files so that callers only need to specify a short
// style key ("mla" / "ieee") and a language code ("ar" / "en").
//
// Usage:
//   #import "arabib/arabib.typ": init-arabib, arabib-bibliography, to-arabic-numerals
//
//   #show: init-arabib.with(read("refs.bib"), style: "mla", lang: "ar")
//   ...
//   #arabib-bibliography(title: none)

#import "@preview/citrus:0.2.0": csl-bibliography as _csl-bib, init-csl
#import "utils.typ": to-arabic-numerals, percent-decode


// ── Bundled assets (read once at import time) ──────────────────

#let _mla-csl = read("assets/mla.csl")
#let _ieee-csl = read("assets/ieee.csl")
#let _locales-ar = read("assets/locales-ar.xml")

#let _styles = (
  "mla": _mla-csl,
  "ieee": _ieee-csl,
)

#let _locale-files = (
  "ar": ("ar": _locales-ar),
  "en": (:),
)


// ── Internal state ─────────────────────────────────────────────

#let _arabib-lang = state("arabib-lang", "en")


// ── Internal helpers ───────────────────────────────────────────

/// Apply Arabic punctuation substitutions and numeral conversion.
///
/// CSL files hardcode English punctuation in `delimiter` attributes
/// rather than referencing locale terms, so we patch them at the
/// Typst level via show rules.  This helper is used for both
/// inline citations (`show ref`) and the bibliography output.
#let _arabicize(body) = {
  show ",": "،"
  show ";": "؛"
  to-arabic-numerals(body)
}

/// Inject `default-locale` into a CSL XML string's `<style>` tag
/// so that citrus resolves locale terms (e.g. "accessed",
/// "available at") from the correct language.
#let _inject-csl-locale(csl-data, lang) = {
  csl-data.replace(
    regex("<style\\b([^>]*)>"),
    m => {
      let tag = m.text
      // Strip any pre-existing default-locale, then append ours
      let cleaned = tag.replace(regex("default-locale\\s*=\\s*\"[^\"]*\""), "")
      cleaned.replace(regex(">$"), " default-locale=\"" + lang + "\">")
    },
  )
}


// ── Initialization ─────────────────────────────────────────────

/// Initialize the arabib bibliography engine.
///
/// Apply as a show rule:
///   #show: init-arabib.with(read("refs.bib"), style: "mla", lang: "ar")
///
/// - bib-data (string): Raw `.bib` file content (pass via `read()`).
/// - style (string): Citation style — `"mla"` or `"ieee"`.
/// - lang (string): Language — `"ar"` (Arabic) or `"en"` (English).
#let init-arabib(bib-data, style: "mla", lang: "en", body) = {
  assert(style in _styles,
    message: "arabib: unknown style '" + style + "' — use 'mla' or 'ieee'")
  assert(lang in _locale-files,
    message: "arabib: unknown lang '" + lang + "' — use 'ar' or 'en'")

  _arabib-lang.update(lang)

  let csl-data = _styles.at(style)
  let locales = _locale-files.at(lang)

  if lang != "en" {
    csl-data = _inject-csl-locale(csl-data, lang)
  }

  show: init-csl.with(bib-data, csl-data, locales: locales, auto-links: false)

  // For Arabic, convert inline citations: [1] → [١], , → ،, etc.
  if lang == "ar" {
    show ref: it => _arabicize(it)
    body
  } else {
    body
  }
}


// ── Bibliography rendering ─────────────────────────────────────

/// Render the bibliography.
///
/// When the active language is Arabic the output receives Arabic
/// punctuation and numeral conversion automatically.
///
/// All keyword arguments are forwarded to the underlying
/// CSL bibliography renderer (e.g. `title: none`).
#let arabib-bibliography(..args) = {
  // URLs are rendered as plain text (auto-links is disabled in
  // init-csl).  Match them here and turn them into clickable,
  // percent-decoded, LTR links.  Unicode bidi isolates keep the
  // URL left-to-right even inside RTL paragraphs.
  show regex("https?://[^\\s<>\"]*[^\\s<>\".,;:!?\\])]"): it => {
    let decoded = percent-decode(it.text)
    link(it.text, "\u{2066}" + decoded + "\u{2069}")
  }

  context {
    let lang = _arabib-lang.get()
    if lang == "ar" {
      _arabicize(_csl-bib(..args))
    } else {
      _csl-bib(..args)
    }
  }
}
