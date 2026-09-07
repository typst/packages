// How-to guide: adding i18n/l10n support to a Typst template, using
// iarticle's own mechanism as the worked example. Unlike the other
// samples (article-{en,ja}.typ / report-{en,ja}.typ), which are
// content templates to copy and fill in, this one is reference
// documentation - and, being about localizing a template, it's itself
// written with iarticle.with(lang: "en") so it doubles as a live
// demonstration of the mechanism it explains. See
// howto-support-i18n-ja.typ for the Japanese version of this guide.
//
// Before this will compile, register the local checkout as
// @preview/iarticle:0.1.1 by running ../install_for_test.sh once.
#import "@preview/iarticle:0.1.1": iarticle, appendix

#show: iarticle.with(
  lang: "en",
  title: [How to Build an i18n/l10n-Aware Template --- iarticle as a Worked Example],
  authors: ("Hideo Takahashi",),
  abstract: [
    This document explains how to give a Typst template `lang`-aware heading
    labels and captions, using the implementation of iarticle
    (`@preview/iarticle:0.1.1`) as the worked example. The mechanism is just
    three pieces --- a string table, locale resolution, and a lookup
    function --- and the template itself only needs to call them from its
    `set`/`show` rules.
  ],
)

= Introduction

This document explains how iarticle switches its section/chapter/appendix
labels, figure/table captions, and the table-of-contents/abstract/references
headings between `lang: "en"` and `lang: "ja"`, and walks through porting the
same mechanism into your own template. It assumes you already have some
Typst template (`#let mytemplate(...) = (...)`) and want to add
multi-language support to it.

For the Japanese version of this guide - written the same way, but with
`iarticle.with(lang: "ja")` - see `howto-support-i18n-ja.typ`.

= The design in three pieces

iarticle's localization is entirely contained in `lib.typ`, and breaks down
into three pieces:

#figure(
  table(
    columns: 2,
    [*Piece*], [*Role*],
    [Locale resolution], [Decides which string table to use, from `lang`/`region`],
    [String table], [Per-locale translations, in `l10n/<locale>.typ`],
    [Lookup function `t()`], [Looks up a key for the current locale, called from the template],
  ),
  caption: [
    The template itself (the builder shared by `iarticle` and `ireport`)
    just combines these three in its `set`/`show` rules --- it never
    branches on locale directly.
  ],
)

The rest of this guide walks through each piece in turn.

= Locale resolution: `lang` and `region`

Typst's `text` element already carries `lang`/`region` (e.g.
`set text(lang: "ja")`). iarticle takes that as its input for "what language
is this document written in" and resolves it to an internal "locale".

```typst
#let _locale-for(lang, region) = lang
```

Right now this just returns `lang` unchanged, ignoring `region` --- but the
point is that it's its own function. `en` and `ja` are both fully determined
by `lang` alone, but a language like Chinese, where `lang: "zh"` alone can't
tell Simplified from Traditional and `region` (`"CN"` / `"TW"`, etc.) is
needed to disambiguate, only needs this one function's body extended when
it's eventually added. Keeping "locale resolution" as its own function from
the start means the call sites (`t()`, and wherever `_font-stack` is
invoked) never need to change.

Supported locales and the fallback locale are also each collected in one
place:

```typst
#let _supported-locales = ("en", "ja")
#let _fallback-locale = "en"
```

An unsupported `lang` falls back to `_fallback-locale` (a document rendering
in the fallback language is safer than one that breaks outright on an
unrecognized locale).

= String tables: `l10n/<locale>.typ`

Per-locale translations live in one dictionary per locale, in a file named
after the locale itself.

```typst
// l10n/en.typ
#let strings = (
  abstract: [Abstract],
  contents: [Contents],
  chapter: n => [Chapter #n],
  section: n => [Section #n],
  table: [Table],
  figure: [Figure],
  appendix: n => [Appendix #n],
  references: [References],
)
```

```typst
// l10n/ja.typ
#let strings = (
  abstract: [概要],
  contents: [目次],
  chapter: n => [第#(n)章],
  section: n => [#n],
  table: [表],
  figure: [図],
  appendix: n => [付録#n],
  references: [参考文献],
)
```

== Name keys after the English word for the slot

Keys like `abstract`, `contents`, and `table` are named after the English
word for what belongs at that spot. That makes `l10n/ja.typ` easy to fill
in side by side with `l10n/en.typ`, and makes it obvious which keys a new
locale is still missing.

== Why some values are functions

`chapter`/`section`/`appendix` aren't plain content but functions,
`n => [...]`, because a number and its label don't always combine the same
way across languages. English prepends the label ("Chapter 3"), but
`l10n/ja.typ`'s `section` is just `n => [#n]` --- Japanese technical
writing typically numbers sections ("3.1 導入") without a word for
"Section" at all. Localizing isn't always a word-for-word swap; sometimes
the right answer in another language is to not emit a label at all, and the
string table needs to be able to express that.

= The lookup function: `t()`

```typst
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
```

Three things are worth calling out here:

+ It reads `text.lang`/`text.region` inside `context`. Typst's `text` state
  can change depending on where in the document you are (e.g. a local
  `set text(lang: ..)` override), so `t()` has to resolve the locale
  relative to wherever it's actually called from --- which also means
  `t()` only makes sense somewhere markup content can be evaluated
  (anywhere `context` is available).
+ If a key is missing from the current locale's dictionary, it falls back
  to the fallback locale's dictionary. That means a new locale doesn't need
  every key filled in at once; whatever's missing just shows up in
  `_fallback-locale` (English, for iarticle) until it's translated.
+ If the entry is a `function` it's called directly; otherwise the content
  is returned as-is --- so callers don't need to care whether they're
  calling `t("abstract")` or `t("chapter", n)`; both go through the same
  `t(key, ..args)` shape.

= Wiring it into the template body

Once the string table and `t()` exist, the template body just calls them
from its own `set`/`show` rules.

== Heading labels

```typst
show heading.where(level: 1): it => {
  let label = context {
    if it.numbering == none { none } else {
      let n = numbering(it.numbering, ..counter(heading).at(it.location()))
      t(if _in-appendix.get() { "appendix" } else { top-level-key }, n)
    }
  }
  block(above: 1.8em, below: 1em)[#label #it.body]
}
```

The heading number `n` is built first, with `numbering()`, and then handed
to `t(key, n)` --- separating "build the number" from "how the number
combines with the label (prefix/suffix/omit)" keeps every language-specific
difference contained to the string table. `top-level-key` is `"section"`
for `iarticle` and `"chapter"` for `ireport`, which is how one builder
function produces two templates (see `_document` in `lib.typ`).

== Figure/table captions

```typst
show figure.where(kind: table): set figure(supplement: t("table"))
show figure.where(kind: image): set figure(supplement: t("figure"))
```

Overriding `figure()`'s `supplement` per `kind` is all it takes: every
subsequent `#figure(table(...), caption: [...])` automatically switches to
the localized "Table 1" / "表 1". The table and figure captions in this
document itself are localized exactly this way.

== Contents, abstract, and references headings

```typst
set bibliography(title: t("references"))
// ...
outline(title: t("contents"))
// ...
text(weight: "bold")[#t("abstract")]
```

Each one is just `t(key)` passed straight into a built-in Typst parameter
(`bibliography(title: ..)`, `outline(title: ..)`) --- none of the built-in
elements need to be rewritten to localize them.

= Handling fonts

It's not just text; fonts need to switch per locale too. iarticle keeps a
"Latin serif/sans stack" and a "per-locale CJK addition" separate, and
concatenates only what's actually needed.

```typst
#let default-latin-serif-font = ("New Computer Modern",)
#let default-cjk-serif-font = (
  ja: ("Noto Serif JP", "Noto Serif CJK JP"),
)

#let _font-stack(locale, latin, cjk-by-locale) = {
  latin + cjk-by-locale.at(locale, default: ())
}
```

There are two reasons for this.

+ Typst resolves fonts per character, not per document (it walks the list
  and uses the first font that actually contains a given character), so a
  single "Latin base + CJK addition" stack is what keeps mixed-script text
  correct --- an English proper noun or a code snippet inside Japanese
  prose still renders in the right font. There's no need to swap the whole
  stack per `lang`.
+ Typst warns once for every named font family in a `set text(font: ..)`
  call that isn't installed, whether or not that font was ever actually
  needed for a given document. Always including CJK fonts would make an
  English document warn about missing Japanese fonts for no reason. Keying
  the addition by locale (`cjk-by-locale.at(locale, default: ())`) means an
  `lang: "en"` document stays silent, while a `lang: "ja"` document looks
  for the fonts it actually needs.

#figure(
  rect(width: 5cm, height: 2.5cm, stroke: 0.5pt)[
    #align(center + horizon)[
      Latin base #sym.arrow.r + CJK addition\
      (keyed by locale)
    ]
  ],
  caption: [
    The font stack concatenation. Leaving `serif-font`/`sans-font` at
    `auto` uses this combined stack; passing either explicitly at the call
    site skips the automatic concatenation entirely (mix in a locale's CJK
    fonts yourself if you want them alongside an explicit override).
  ],
)

= Adding a new locale

Putting all of this together, adding one new locale (say, `fr`) to your own
template looks like this:

+ Create `l10n/fr.typ` with the same set of keys as `l10n/en.typ`, filled
  in as `#let strings = (...)`. If the label/number combination differs
  from English, make the relevant key a function (`n => [...]`) rather
  than plain content.
+ Add `"fr"` to `_supported-locales`.
+ If the language needs characters a Latin font can't render (as with
  CJK), add `fr: (...)` to the CJK table in `default-*-font` (nothing to
  do here for a language that Latin fonts already cover).
+ If the language has a script `lang` alone can't disambiguate (Simplified
  vs. Traditional Chinese, say), extend `_locale-for` to also look at
  `region`. An ordinary language, uniquely determined by `lang`/`region`,
  needs none of this.
+ Compile one document with `#show: mytemplate.with(lang: "fr", ...)` to
  check it. Thanks to the fallback, missing a key or two won't break the
  document --- it just renders in English until translated --- but don't
  ship it that way; confirm every key is filled in before calling it done.

The goal of this design is that adding a locale is "add one file, add one
line to a list" and nothing more --- `t()` itself and the template's
`show`/`set` rules never need to change.

#appendix[
  = Porting checklist

  A summary of the key points for porting this same mechanism into your
  own template.

  - Factor locale resolution (`lang`/`region` → locale name) into its own
    function, and have the rest of the template go through it rather than
    reading `lang`/`region` directly.
  - Collect strings into a dictionary keyed by the English word for each
    slot, with one file per locale.
  - Design any label-plus-number item as a function from the start, since
    the combination can vary by language.
  - Have the lookup function read `text.lang`/`text.region` inside
    `context`, and fall back to the fallback locale for missing keys.
  - Don't swap fonts wholesale per locale; use one stack made of a shared
    Latin base plus a per-locale addition.
  - Keep adding a new locale down to "add one file, register it in one
    list", without touching the lookup function or the template body.

  See `lib.typ` for the full implementation, `l10n/en.typ` / `l10n/ja.typ`
  for the string tables themselves, and `samples/article-{en,ja}.typ` /
  `samples/report-{en,ja}.typ` for complete documents with translated
  headings and captions in place.
]
