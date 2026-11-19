// Math-safe and i18n-aware plain-text serialization, prose word counting,
// `<thyme-word-hint>` tracking, reading-time estimation, and full-byte content hashing.

#let _space-func = [ ].func()
#let _hex-digits = (
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
)

// Internal depth counter tracking active non-primary `#tr(...)` branches in HTML mode
// so `<thyme-word-hint>` inside secondary language branches never inflates primary word counts.
#let _tr-nonprimary-depth = state("thyme/tr-nonprimary", 0)

// Extract the primary (or requested `lang`) branch from a `<thyme-tr-meta>` dictionary.
#let _tr-primary(meta-val, preferred-lang: none) = {
  let entries = meta-val.at("entries", default: (:))
  if entries.len() == 0 {
    none
  } else if preferred-lang != none and preferred-lang in entries {
    entries.at(preferred-lang)
  } else {
    entries.values().first()
  }
}

/// Convert arbitrary Typst content (including `raw`, `math.equation`, and `#tr(...)`
/// translated nodes) or primitive values into a plain `str`.
///
/// When `#tr(en: [...], de: [...])` nodes are encountered, only the requested `lang`
/// (or first declared language when `lang` is `none`) is extracted so `<title>`,
/// meta descriptions, and RSS / Atom feeds never concatenate translations.
/// -> str
#let to-plain-text(
  /// Value or content tree to flatten into plain UTF-8 text.
  /// -> any
  it,
  /// Optional preferred language code when flattening `#tr(...)` nodes.
  /// -> str | none
  lang: none,
) = {
  let go(x) = to-plain-text(x, lang: lang)
  if it == none {
    ""
  } else if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it == [ ] or it.func() == _space-func {
    " "
  } else if it.func() == parbreak or it.func() == linebreak {
    "\n"
  } else if it.func() == smartquote {
    if it.at("double", default: true) { "\"" } else { "'" }
  } else if it.func() == metadata {
    if (
      type(it.value) == dictionary and it.value.at("thyme-tr", default: false)
    ) {
      let branch = _tr-primary(it.value, preferred-lang: lang)
      if branch != none { go(branch) } else { "" }
    } else {
      ""
    }
  } else if it.has("text") {
    if type(it.text) == str { it.text } else { go(it.text) }
  } else if it.has("children") {
    if it.children.len() == 0 { "" } else { it.children.map(go).join("") }
  } else if it.has("body") {
    go(it.body)
  } else if it.has("child") {
    go(it.child)
  } else if it.has("base") {
    let s = go(it.base)
    for k in ("tl", "bl") {
      if it.has(k) and it.at(k) != none { s = go(it.at(k)) + s }
    }
    if it.has("accent") and it.accent != none { s += go(it.accent) }
    if it.has("b") and it.b != none { s += "_" + go(it.b) }
    if it.has("t") and it.t != none { s += "^" + go(it.t) }
    for k in ("br", "tr") {
      if it.has(k) and it.at(k) != none { s += go(it.at(k)) }
    }
    s
  } else if it.has("num") and it.has("denom") {
    go(it.num) + "/" + go(it.denom)
  } else if it.has("radicand") {
    let idx = if it.has("index") and it.index != none { go(it.index) } else {
      ""
    }
    idx + "√(" + go(it.radicand) + ")"
  } else if it.func() == math.primes and it.has("count") {
    "'" * it.count
  } else {
    ""
  }
}

// Extract prose words from Typst content (skipping math equations, footnotes,
// multi-line code listings, and secondary `#tr(...)` translation branches).
#let _to-word-text(it) = {
  if it == none {
    " "
  } else if type(it) == str {
    it
  } else if type(it) != content {
    " "
  } else {
    let fn = it.func()
    if fn == math.equation or fn == footnote {
      " "
    } else if fn == metadata {
      if (
        type(it.value) == dictionary and it.value.at("thyme-tr", default: false)
      ) {
        let branch = _tr-primary(it.value)
        if branch != none { " " + _to-word-text(branch) + " " } else { " " }
      } else {
        " "
      }
    } else if it.has("text") and type(it.text) == str {
      if fn == raw and it.at("block", default: false) {
        " "
      } else {
        it.text
      }
    } else if fn == parbreak or fn == linebreak or it == [ ] {
      " "
    } else if fn == smartquote {
      if it.at("double", default: true) { " " } else { "'" }
    } else if fn == table or fn == grid {
      " " + it.children.map(ch => " " + _to-word-text(ch) + " ").join(" ") + " "
    } else if it.has("children") {
      if it.children.len() > 0 { it.children.map(_to-word-text).join() } else {
        " "
      }
    } else if it.has("body") {
      let sep = if fn in (heading, list.item, enum.item, par, block) {
        " "
      } else { "" }
      sep + _to-word-text(it.body) + sep
    } else if it.has("child") {
      _to-word-text(it.child)
    } else {
      " "
    }
  }
}

/// Count prose words in arbitrary Typst content (Unicode-letter aware for English,
/// German umlauts / `ß`, and accented Latin scripts; counts only the primary branch
/// of `#tr(...)` translated blocks and excludes multi-line fenced code blocks).
/// -> int
#let count-words(
  /// Content block to count words in.
  /// -> content | str | none
  body,
) = {
  _to-word-text(body).matches(regex("[\\p{L}\\p{N}]+(?:[-'\\u{2019}][\\p{L}\\p{N}]+)*")).len()
}

/// Emit a zero-footprint `<thyme-word-hint>` marker from inside `context`-wrapped
/// components (`sbox`, `proof`, `sidenote`, `callout`, `epigraph`, etc.)
/// so pages and posts compute full-document prose word counts without double-counting
/// nested components or secondary `#tr(...)` branches.
/// -> content
#let word-hint(
  /// Content fragments rendered inside a `context` closure.
  /// -> any
  ..parts,
) = {
  let n = parts.pos().fold(0, (acc, p) => acc + count-words(p))
  if n == 0 {
    []
  } else {
    context {
      if _tr-nonprimary-depth.get() == 0 {
        [#metadata(n)<thyme-word-hint>]
      }
    }
  }
}

/// Estimate reading time in minutes from a prose word count.
/// -> int
#let estimate-reading-minutes(
  /// Total prose word count.
  /// -> int
  words,
  /// Reading speed in words per minute.
  /// -> int
  wpm: 200,
) = {
  calc.max(1, calc.ceil(words / wpm))
}

/// Sum `base-words` with all `<thyme-word-hint>` markers emitted inside `doc-el`
/// (or inside the body region following `here()` in standalone single-file mode).
/// Must be called inside `context`.
/// -> int
#let query-body-words(base-words, doc-el: none) = {
  let hints = if doc-el != none {
    query(selector(<thyme-word-hint>).within(doc-el.location()))
  } else {
    let starts = query(<thyme-body-start>)
    let ends = query(<thyme-body-end>)
    if starts.len() > 0 and ends.len() > 0 {
      query(
        selector(<thyme-word-hint>).after(starts.last().location()).before(ends.last().location()),
      )
    } else {
      query(<thyme-word-hint>)
    }
  }
  base-words + hints.fold(0, (acc, m) => acc + m.value)
}

/// Compute a deterministic 8-hex-character digest over 100% of the bytes in `data`
/// (`str` or `bytes`) via 32-bit word mixing for content-addressed asset cache keys
/// (e.g. `css/style.css?v=8f3a1c02`).
/// -> str
#let short-hash(data) = {
  let bs = if type(data) == bytes { data } else { bytes(str(data)) }
  let mod = 4294967296
  let prime = 16777619
  let h = 2166136261
  let n = bs.len()
  let full-end = n - calc.rem(n, 4)
  let i = 0
  while i < full-end {
    let word = int.from-bytes(
      bs.slice(i, i + 4),
      endian: "little",
      signed: false,
    )
    h = calc.rem(h.bit-xor(word) * prime, mod)
    i += 4
  }
  while i < n {
    h = calc.rem(h.bit-xor(bs.at(i)) * prime, mod)
    i += 1
  }
  h = calc.rem(h.bit-xor(n) * prime, mod)
  let out = ""
  let rem = h
  for _ in range(8) {
    out = _hex-digits.at(calc.rem(rem, 16)) + out
    rem = calc.quo(rem, 16)
  }
  out
}
