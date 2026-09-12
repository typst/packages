// iarticle - i18n-aware article/report templates
//
// This file has two parts:
//  1. A small localization mechanism: a string table per locale
//     (l10n/*.typ) plus `t()` to look a key up in the table for the
//     document's current `text.lang`/`text.region`.
//  2. Two templates built on top of it, mirroring the LaTeX article vs.
//     report distinction:
//       - `iarticle`: flat, starts at "section", no chapters, no
//         auto-outline by default - for papers and short documents.
//       - `ireport`: "chapter" is the top level (each one starts a new
//         page), sections nest under it, auto-outline by default - for
//         longer, structured documents.
//     Both get numbered/labelled headings, translated figure and table
//     captions, a translated table of contents, an abstract block, a
//     translated bibliography title, and an `appendix()` helper.
//
// Supported locales: en, ja.

// A locale is the key used for l10n/<locale>.typ and for the font
// tables below. It's currently just `lang` passed through unchanged,
// since neither supported locale needs `region` to disambiguate it.
// `region` is still threaded through the call site (rather than
// dropped) so a future script-ambiguous locale - e.g. Chinese, where
// `text.lang` only ever carries the bare "zh" and `region` is the only
// signal that tells Simplified from Traditional apart - only needs to
// extend this one function.
#let _locale-for(lang, region) = lang

// locales with a l10n/<locale>.typ table. To add one: write
// l10n/xx.typ with the same keys as l10n/en.typ and add "xx" here -
// nothing else needs to change, see `_strings-for` below. (If it's a
// new script variant of an existing lang, like a future zh would be,
// extend `_locale-for` too.)
#let _supported-locales = ("en", "ja")

// Locale used as a fallback, both when the resolved locale isn't in
// `_supported-locales` and when a table is missing a specific key.
#let _fallback-locale = "en"

// Load the string table for `locale`. This only imports
// l10n/<locale>.typ - not every l10n/*.typ file - because `import` is
// an ordinary statement in Typst: it runs (and so only reads its file)
// when control actually reaches it, same as an `if` branch that's
// never taken never runs. Repeated calls with the same `locale` are
// cheap: Typst caches a module by its resolved path, so only the first
// call per locale actually parses the file.
#let _strings-for(locale) = {
  let locale = if locale in _supported-locales { locale } else { _fallback-locale }
  import "l10n/" + locale + ".typ": strings
  strings
}

// Look up `key` for the document's current locale (read via `context
// text.lang`/`text.region`, so `t` only makes sense where a context is
// available - which is anywhere in markup content). Extra positional
// arguments are forwarded to the entry when it's a function; see
// l10n/en.typ for why some entries are functions instead of plain
// content.
#let t(key, ..args) = context {
  let locale = _locale-for(text.lang, text.region)
  let dict = _strings-for(locale)
  let entry = dict.at(key, default: _strings-for(_fallback-locale).at(key))
  if type(entry) == function {
    entry(..args)
  } else {
    entry
  }
}

// Whether the document is currently inside `appendix(..)`. Read by the
// level-1 heading show rule to switch its label from t("chapter") to
// t("appendix").
#let _in-appendix = state("iarticle-in-appendix", false)

// Render a heading's number (if it has one) through the localized
// "chapter"/"section"/"appendix" entries, honouring whatever numbering
// pattern is active at that heading (so it keeps working inside
// `appendix()`, which switches to letters).
#let _numbered-label(it, key) = context {
  if it.numbering == none {
    none
  } else {
    let n = numbering(it.numbering, ..counter(heading).at(it.location()))
    t(key, n)
  }
}

// Wrap the appendix portion of the document, e.g.:
//
//   #appendix[
//     = Survey questions
//     ...
//   ]
//
// Resets heading numbering to letters and switches the level-1 label
// from t("chapter") to t("appendix").
#let appendix(body) = {
  _in-appendix.update(true)
  counter(heading).update(0)
  set heading(numbering: "A.1")
  body
}

// Default font stacks, split into a Latin base and a per-locale CJK
// addition. Typst resolves fonts per character, not per document: for
// each glyph it walks the list and uses the first font that actually
// contains it, falling through to the next entry otherwise. A single
// Latin+CJK stack - rather than switching the whole stack per `lang` -
// is what keeps mixed-script content correct (an English proper noun
// in a Japanese sentence, code in a Japanese doc, etc.).
//
// The CJK addition is keyed per locale (see `_font-stack` below)
// rather than always appended, because Typst warns once per `set
// text(font: ...)` call for every named family that isn't installed,
// whether or not it was ever actually needed - so an English document
// listing Japanese font names it will never use would warn about them
// for no reason. Only appending a CJK addition for locales whose
// script needs it keeps a `lang: "en"` document (the common case)
// silent by default. Keying by locale rather than hardcoding "ja" also
// leaves room to add another CJK locale later without touching
// `_font-stack` itself - different CJK scripts conventionally want
// different fonts even where they share a Unicode codepoint ("Han
// unification"), so a future addition would get its own entry rather
// than reusing this one.
//
// "New Computer Modern" ships embedded in Typst itself, so it's always
// available as the Latin anchor; "Liberation Sans" is metric-compatible
// with Arial and preinstalled on most Linux/CI images. The CJK fonts
// are commonly available but not guaranteed on every system (nothing
// is: Typst can't embed CJK fonts for you) - I could only verify actual
// rendering with the Japanese ones, since that's what's installed here.
// Override `serif-font`/`sans-font` at the call site - not by editing
// this file - if your system has different fonts installed. All four
// tables are exported (not `_`-prefixed) so a per-machine override can
// build on them instead of retyping a stack from scratch, e.g.:
//
//   #import "@preview/iarticle:0.1.0": iarticle
//   #import "@preview/iarticle:0.1.0": default-latin-serif-font, default-cjk-serif-font
//   #show: iarticle.with(
//     lang: "ja",
//     serif-font: default-latin-serif-font
//       + ("Hiragino Mincho ProN",)
//       + default-cjk-serif-font.at("ja"),
//   )
#let default-latin-serif-font = ("New Computer Modern",)
#let default-latin-sans-font = ("Liberation Sans",)
#let default-cjk-serif-font = (
  ja: ("Noto Serif JP", "Noto Serif CJK JP"),
)
#let default-cjk-sans-font = (
  ja: ("Noto Sans JP", "Noto Sans CJK JP"),
)

#let _font-stack(locale, latin, cjk-by-locale) = {
  latin + cjk-by-locale.at(locale, default: ())
}

// Both templates share everything except three things:
//  - which l10n key labels a level-1 heading outside `appendix()`
//    ("section" for iarticle, "chapter" for ireport)
//  - whether a level-1 heading forces a page break first (report-style
//    chapters do; article-style sections don't)
//  - whether `show-outline` defaults to true or false
// so they're both generated from one private builder instead of being
// two near-duplicate copies of the same template.
#let _document(top-level-key, pagebreak-before-top-level, show-outline-default) = (
  lang: "en",
  region: none,
  title: none,
  authors: (),
  date: auto,
  abstract: none,
  show-outline: show-outline-default,
  serif-font: auto,
  sans-font: auto,
  page-numbering: "1",
  body,
) => {
  // `auto` means "pick the default stack for this locale"; an explicit
  // serif-font/sans-font argument is used exactly as given, with no
  // locale-based CJK fallback appended - if you override it for a
  // Japanese document, include a CJK font in the override yourself.
  let locale = _locale-for(lang, region)
  let serif-font = if serif-font == auto {
    _font-stack(locale, default-latin-serif-font, default-cjk-serif-font)
  } else {
    serif-font
  }
  let sans-font = if sans-font == auto {
    _font-stack(locale, default-latin-sans-font, default-cjk-sans-font)
  } else {
    sans-font
  }

  set text(lang: lang, region: region, font: serif-font)
  set document(title: title)
  // Bottom-center page number by default; pass `page-numbering: none`
  // to turn it off, or any other Typst numbering pattern (e.g. "1 / 1"
  // for "page N of total") to change its format.
  set page(numbering: page-numbering)

  // Headings get the sans stack and real bold, not synthetic
  // emboldening - the CJK fonts above ship multiple weights, so a
  // `weight: "bold"` request resolves to an actual bold face instead of
  // Typst faking one by thickening strokes.
  show heading: set text(font: sans-font, weight: "bold")

  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    let label = context {
      if it.numbering == none {
        none
      } else {
        let n = numbering(it.numbering, ..counter(heading).at(it.location()))
        t(if _in-appendix.get() { "appendix" } else { top-level-key }, n)
      }
    }
    if pagebreak-before-top-level {
      pagebreak(weak: true)
    }
    block(above: 1.8em, below: 1em)[#label #it.body]
  }
  show heading.where(level: 2): it => {
    block(above: 1.2em, below: 0.6em)[#_numbered-label(it, "section") #it.body]
  }

  show figure.where(kind: table): set figure(supplement: t("table"))
  show figure.where(kind: image): set figure(supplement: t("figure"))

  set bibliography(title: t("references"))

  if title != none {
    align(center)[
      #block(text(size: 1.4em, weight: "bold", title))
      #if authors.len() > 0 {
        block(authors.join(", "))
      }
      #block(if date == auto { datetime.today().display() } else if date != none { date })
    ]
  }

  if abstract != none {
    block[
      #text(weight: "bold")[#t("abstract")]
      #abstract
    ]
  }

  if show-outline {
    outline(title: t("contents"))
  }

  body
}

// Flat template: top level is "section" (no chapters), no forced page
// break between sections, no auto-outline by default - for papers and
// other short documents. Used as:
//
//   #import "@preview/iarticle:0.1.0": iarticle
//   #show: iarticle.with(lang: "ja", title: "...")
//
//   = Section title
//   ...
#let iarticle = _document("section", false, false)

// Structured template: top level is "chapter" (each starts a new
// page), sections nest under it, auto-outline by default - for longer
// documents. Used as:
//
//   #import "@preview/iarticle:0.1.0": ireport
//   #show: ireport.with(lang: "ja", title: "...")
//
//   = Chapter title
//   ...
#let ireport = _document("chapter", true, true)
