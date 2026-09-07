// ===========================================================================
// Language registry: SAN piece letters + UI strings.
//
// Each `src/assets/i18n/<code>.typ` exports:
//   * `piece-chars` -- piece KIND -> SAN letter(s) (German knight "S", ...);
//   * `strings`     -- UI strings: diagram/table supplement + outline titles.
// They are imported statically here (Typst cannot import by a runtime string)
// into `notation-langs` (piece-chars) and `ui-strings` (UI strings), keyed by
// language code; an unknown code falls back to English.
//
// Adding a language is a no-code change beyond this file: drop
// `src/assets/i18n/<code>.typ` exporting `piece-chars` + `strings`, then add one
// line to each map below.
// ===========================================================================

#import "style.typ": default-i18n-style, i18n-style-state

#import "assets/i18n/en.typ"
#import "assets/i18n/de.typ"
#import "assets/i18n/es.typ"
#import "assets/i18n/fr.typ"
#import "assets/i18n/it.typ"
#import "assets/i18n/pt.typ"
#import "assets/i18n/ru.typ"

#let notation-langs = (
  en: en.piece-chars,
  de: de.piece-chars,
  es: es.piece-chars,
  fr: fr.piece-chars,
  it: it.piece-chars,
  pt: pt.piece-chars,
  ru: ru.piece-chars,
)

#let ui-strings = (
  en: en.strings,
  de: de.strings,
  es: es.strings,
  fr: fr.strings,
  it: it.strings,
  pt: pt.strings,
  ru: ru.strings,
)

/// Resolve an effective language code. Must be called inside a `context`.
/// `call-lang == auto` uses the document `lang` setting; `"auto"` follows
/// `text.lang`; any other code is used as given.
///
/// - call-lang (auto, str): the per-call language, or `auto` for the document
///   default.
/// -> str
#let resolve-lang(call-lang) = {
  let setting = if call-lang != auto { call-lang } else { (default-i18n-style + i18n-style-state.get()).lang }
  if setting == "auto" { text.lang } else { setting }
}

/// Look up one localized UI string (English fallback for an unknown code or key).
/// Must be called inside a `context`.
///
/// - call-lang (auto, str): the language, or `auto` for the document default.
/// - key (str): the string key (e.g. `"diagram-supplement"`).
/// -> str
#let ui-string(call-lang, key) = {
  let code = resolve-lang(call-lang)
  let tbl = ui-strings.at(code, default: ui-strings.en)
  tbl.at(key, default: ui-strings.en.at(key))
}

// Resolve piece-chars for a call-lang (context). English fallback.
#let lang-piece-chars(call-lang) = {
  notation-langs.at(resolve-lang(call-lang), default: notation-langs.en)
}

// Reverse of `notation-langs.at(lang)`: SAN letter -> piece kind, sorted longest
// letter first so a multi-cluster letter (Russian king "Кр") is tried before a
// shorter one it starts with (knight "К") -- derived, never a second hand-written
// table. `lang` must already be a known code (see `normalize-san`).
#let _lang-letter-kinds(lang) = {
  let chars = notation-langs.at(lang)
  let pairs = chars.pairs().map(p => (p.at(1), p.at(0)))
  pairs.sorted(key: p => -p.at(0).clusters().len())
}

// Unicode chess figurines (both colour sets) -> the canonical English SAN
// letter, pawn glyphs mapping to "" since SAN never writes a pawn letter.
// Language-neutral by construction, so this is looked up ONCE, before any
// per-`lang` letter table -- see the trap called out in `normalize-san`.
#let _figurine-glyphs = (
  "\u{2654}": "K", "\u{2655}": "Q", "\u{2656}": "R", "\u{2657}": "B", "\u{2658}": "N", "\u{2659}": "",
  "\u{265A}": "K", "\u{265B}": "Q", "\u{265C}": "R", "\u{265D}": "B", "\u{265E}": "N", "\u{265F}": "",
)

/// Convert one SAN token written in `lang` into canonical English SAN: the
/// leading piece letter and any promotion letter (after `=`) are translated via
/// `notation-langs`; everything else (files, ranks, `x`, `O-O`/`O-O-O`, check/mate,
/// glyph suffixes) is language-independent and passes through untouched.
///
/// A leading Unicode figurine (either colour set, e.g. `"♘f3"`, `"♞c6"`) is
/// resolved straight to its English letter and is a TERMINAL branch: the
/// per-`lang` letter lookup below is skipped entirely for that token, because
/// English letters collide across languages (Spanish/French/Italian/
/// Portuguese `"R"` is a king, not a rook) -- translating the figurine and
/// then still running the language pass would silently turn rooks into kings.
/// A figurine pawn glyph is stripped rather than translated, since SAN never
/// writes a pawn letter. This figurine handling applies for every `lang`,
/// including `"en"`, since figurines are language-neutral and `"en"` is the
/// default.
///
/// - san (str): a SAN token in the given language, e.g. `"Sf3"` (German).
/// - lang (str): the source language code (must be a key of `notation-langs`).
/// -> str
#let normalize-san(san, lang) = {
  assert(
    notation-langs.keys().contains(lang),
    message: "unknown language code \"" + lang + "\"; supported: " + notation-langs.keys().join(", "),
  )

  let s = san
  let cs = s.clusters()

  // Leading figurine glyph: language-neutral, terminal (see docstring).
  let leading-is-figurine = cs.len() > 0 and _figurine-glyphs.keys().contains(cs.at(0))
  if leading-is-figurine {
    s = _figurine-glyphs.at(cs.at(0)) + cs.slice(1).join("")
  }

  // Promotion figurine after "=" -- independent of the leading glyph (a plain
  // pawn move can still promote to a figurine piece), so checked regardless.
  if s.contains("=") {
    let parts = s.split("=")
    if parts.len() == 2 and parts.at(1).len() > 0 {
      let pc = parts.at(1).clusters()
      if _figurine-glyphs.keys().contains(pc.at(0)) {
        s = parts.at(0) + "=" + _figurine-glyphs.at(pc.at(0)) + pc.slice(1).join("")
      }
    }
  }

  if leading-is-figurine { return s }
  if lang == "en" { return s }
  let kinds = _lang-letter-kinds(lang)

  // leading piece letter
  cs = s.clusters()
  for (letter, kind) in kinds {
    let lc = letter.clusters()
    if cs.len() >= lc.len() and cs.slice(0, lc.len()) == lc {
      s = notation-langs.en.at(kind) + cs.slice(lc.len()).join("")
      break
    }
  }

  // promotion letter after "="
  if s.contains("=") {
    let parts = s.split("=")
    if parts.len() == 2 and parts.at(1).len() > 0 {
      let pc = parts.at(1).clusters()
      let letter = pc.at(0)
      for (l, kind) in kinds {
        if kind != "king" and l == letter {
          s = parts.at(0) + "=" + notation-langs.en.at(kind) + pc.slice(1).join("")
          break
        }
      }
    }
  }
  s
}
