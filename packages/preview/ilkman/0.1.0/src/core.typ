// ilkman — shared state, translations and helpers
#import "tokens/colors.typ": *
#import "tokens/fonts.typ": *
#import "tokens/sizes.typ": *

// Everything components need to know about the current document.
#let ctx-state = state("ilkman-ctx", (
  mode: "doc",
  lang: "tr",
  pal: palettes.okyanus,
  fonts: font-palettes.mulish,
  sizes: size-scales.doc,
  note-column: 1 / 4,
  info: (title: none, subtitle: none, author: none, date: none, version: none),
))

/// Current context dictionary (call inside `context`).
#let ctx() = ctx-state.get()

/// Text color for light surfaces (boxes, zebra rows, code). In dark slide
/// mode the page text is light, but light boxes still need dark text.
#let box-ink(c) = c.at("box-ink", default: c.pal.ink)

/// Palette for light surfaces such as code blocks.
#let light-pal(c) = c.at("light", default: c.pal)

#let strings = (
  tr: (
    chapter: "Bölüm", contents: "İçindekiler", figure: "Şekil", table: "Tablo",
    listing: "Kod", appendix: "Ek", volume: "Cilt",
    figures-list: "Şekiller", tables-list: "Tablolar",
    info: "Bilgi", tip: "İpucu", warn: "Dikkat", danger: "Tehlike",
    term: "Tanım",
  ),
  en: (
    chapter: "Chapter", contents: "Contents", figure: "Figure", table: "Table",
    listing: "Listing", appendix: "Appendix", volume: "Vol.",
    figures-list: "List of Figures", tables-list: "List of Tables",
    info: "Note", tip: "Tip", warn: "Warning", danger: "Danger",
    term: "Definition",
  ),
)

#let tr(c, key) = strings.at(c.lang, default: strings.en).at(key)

// ---------------------------------------------------------------------------
// Deterministic pseudo-random numbers (for generative cover art)

/// Integer seed derived from any value (usually the title).
#let seed-of(v) = {
  let s = if type(v) == str { v } else if v == none { "ilkman" } else { repr(v) }
  let h = 2166136261
  for b in array(bytes(s)) {
    h = calc.rem(calc.rem(h * 16777619, 4294967296) + b, 4294967296)
  }
  calc.rem(h, 2147483646) + 1
}

/// Returns (values, next-seed): `n` floats in [0, 1).
#let rand-seq(seed, n) = {
  let m = 2147483647
  let s = calc.max(1, calc.rem(seed, m))
  // warm up: the first outputs of a Lehmer generator follow the seed too closely
  for _ in range(16) { s = calc.rem(s * 48271, m) }
  let out = ()
  for _ in range(n) {
    s = calc.rem(s * 48271, m)
    // second, independent stream mixed in to break residual correlation
    let t = calc.rem(s * 69621, m)
    out.push(calc.rem(s + t, m) / m)
  }
  out
}

/// Plain text of a content value (for seeds, metadata, bits art).
#let plain(c) = {
  if c == none { return "" }
  if type(c) == str { return c }
  if type(c) == content {
    if c.has("text") { return c.text }
    if c.has("children") { return c.children.map(plain).join("") }
    if c.has("body") { return plain(c.body) }
    if c.func() == [ ].func() { return " " }
  }
  ""
}

/// Parse "1/2", "1/1/1" or (1, 2) into an array of fr.
#let parse-ratio(r) = {
  let parts = if type(r) == str { r.split("/").map(x => float(x.trim())) } else if type(r) == array { r.map(float) } else if type(r) == int { range(r).map(_ => 1.0) } else { panic("ilkman: ratio must be like \"1/2\" or (1, 2)") }
  parts.map(x => x * 1fr)
}

/// Resolve an alignment string.
#let to-align(a) = {
  if type(a) == alignment { return a }
  (left: left, center: center, right: right, top: top, bottom: bottom, horizon: horizon).at(a)
}
