// ── WASM plugin ───────────────────────────────────────────────────────────────

#let mando = plugin("../rust_mando.wasm")

// ── content helpers ───────────────────────────────────────────────────────────

/// Recursively extract plain text from a content value.
/// Paragraph breaks become "\n\n", line breaks become "\n".
#let _extract-text(it) = {
  if type(it) == str {
    it
  } else if type(it) == content {
    if it == parbreak()        { "\n\n" }
    else if it == linebreak()  { "\n" }
    else if it.has("text")     { it.text }
    else if it.has("children") { it.children.map(_extract-text).join("") }
    else if it.has("body")     { _extract-text(it.body) }
    else { "" }
  } else { "" }
}

// ── low-level segment API ─────────────────────────────────────────────────────

/// Returns a flat space-separated pīnyīn string (non-Chinese tokens omitted).
/// `style`: "marks" (default) or "numbers"
#let flat(txt, style: "marks") = str(
  mando.pinyin_flat(bytes(txt), bytes(style))
)

/// Returns a raw array of segment dicts: `{word, pinyin}`.
/// `pinyin` is `none` for non-Chinese tokens (punctuation, spaces, Latin).
/// `style`: "marks" (default) or "numbers"
#let segment(txt, style: "marks") = json(
  mando.pinyin_segmented(bytes(txt), bytes(style))
)

/// Segments content (not just strings) by first extracting its plain text.
#let segment-content(it, style: "marks") = segment(
  _extract-text(it), style: style
)

// ── pīnyīn → zhùyīn (bopomofo) conversion ────────────────────────────────────

/// Whole-syllable overrides: null-vowel syllables (zhi/chi/…/zi/ci/si/ri)
/// and y-/w- spelling conventions where the leading letter is not a real
/// bopomofo initial.
#let _zy-specials = (
  "zhi": "ㄓ", "chi": "ㄔ", "shi": "ㄕ", "ri": "ㄖ",
  "zi":  "ㄗ", "ci":  "ㄘ", "si":  "ㄙ",
  // y- syllables
  "yi": "ㄧ", "ya": "ㄧㄚ", "yao": "ㄧㄠ", "you": "ㄧㄡ",
  "yan": "ㄧㄢ", "yang": "ㄧㄤ", "yin": "ㄧㄣ", "ying": "ㄧㄥ",
  "ye": "ㄧㄝ", "yu": "ㄩ",
  "yue": "ㄩㄝ", "yun": "ㄩㄣ", "yuan": "ㄩㄢ", "yong": "ㄩㄥ",
  // w- syllables
  "wu": "ㄨ", "wa": "ㄨㄚ", "wo": "ㄨㄛ", "wai": "ㄨㄞ",
  "wei": "ㄨㄟ", "wan": "ㄨㄢ", "wen": "ㄨㄣ", "wang": "ㄨㄤ",
  "weng": "ㄨㄥ",
)

/// Initials (聲母). zh/ch/sh must precede z/c/s/h.
#let _zy-initials = (
  ("zh","ㄓ"), ("ch","ㄔ"), ("sh","ㄕ"),
  ("b","ㄅ"),  ("p","ㄆ"),  ("m","ㄇ"),  ("f","ㄈ"),
  ("d","ㄉ"),  ("t","ㄊ"),  ("n","ㄋ"),  ("l","ㄌ"),
  ("g","ㄍ"),  ("k","ㄎ"),  ("h","ㄏ"),
  ("j","ㄐ"),  ("q","ㄑ"),  ("x","ㄒ"),
  ("z","ㄗ"),  ("c","ㄘ"),  ("s","ㄙ"),
  ("r","ㄖ"),
)

/// Finals after j/q/x: their "u" is always ü (ㄩ), never ㄨ.
#let _zy-jqx-finals = (
  "u":   "ㄩ",
  "ue":  "ㄩㄝ",
  "uan": "ㄩㄢ",
  "un":  "ㄩㄣ",
  "ong": "ㄩㄥ",
)

/// Finals (韻母), longest-first within each group.
#let _zy-finals = (
  ("iang","ㄧㄤ"), ("uang","ㄨㄤ"),
  ("iong","ㄩㄥ"), ("ueng","ㄨㄥ"),
  ("ian","ㄧㄢ"),  ("iao","ㄧㄠ"),
  ("ing","ㄧㄥ"),  ("uai","ㄨㄞ"),
  ("uan","ㄨㄢ"),  ("uei","ㄨㄟ"),  ("uen","ㄨㄣ"),
  ("van","ㄩㄢ"),  ("üan","ㄩㄢ"),
  ("vn","ㄩㄣ"),   ("ün","ㄩㄣ"),
  ("ve","ㄩㄝ"),   ("üe","ㄩㄝ"),
  ("ang","ㄤ"),    ("eng","ㄥ"),    ("ong","ㄨㄥ"),
  ("ie","ㄧㄝ"),   ("ia","ㄧㄚ"),
  ("in","ㄧㄣ"),
  ("an","ㄢ"),     ("en","ㄣ"),
  ("ao","ㄠ"),     ("ai","ㄞ"),     ("ei","ㄟ"),    ("ou","ㄡ"),
  ("ui","ㄨㄟ"),   ("un","ㄨㄣ"),
  ("ua","ㄨㄚ"),   ("uo","ㄨㄛ"),
  ("iu","ㄧㄡ"),
  ("er","ㄦ"),
  ("a","ㄚ"),      ("o","ㄛ"),      ("e","ㄜ"),
  ("i","ㄧ"),      ("u","ㄨ"),
  ("v","ㄩ"),      ("ü","ㄩ"),
)

/// Tone-number → bopomofo tone mark.
/// Tone 1 = ˉ (U+02C9), 5 = neutral (no mark).
#let _zy-tones = ("1":"ˉ", "2":"ˊ", "3":"ˇ", "4":"ˋ", "5":"")

/// Convert a single pinyin syllable with trailing tone digit (e.g. "pin1")
/// to a bopomofo string with tone mark (e.g. "ㄆㄧㄣˉ").
#let pinyin-to-zhuyin(syllable) = {
  let s = lower(syllable)
  // Strip tone digit
  let tone = ""
  if s.len() > 0 and "12345".contains(s.last()) {
    tone = _zy-tones.at(s.last(), default: "")
    s = s.slice(0, s.len() - 1)
  }
  // Whole-syllable special?
  if s in _zy-specials { return _zy-specials.at(s) + tone }
  // Strip initial
  let init-bopo  = ""
  let init-latin = ""
  for (lat, bopo) in _zy-initials {
    if s.starts-with(lat) {
      init-bopo  = bopo
      init-latin = lat
      s = s.slice(lat.len())
      break
    }
  }
  // j/q/x + u-based finals → ü
  if init-latin in ("j","q","x") and s in _zy-jqx-finals {
    return init-bopo + _zy-jqx-finals.at(s) + tone
  }
  // General final lookup
  let fin-bopo = ""
  for (lat, bopo) in _zy-finals {
    if s == lat { fin-bopo = bopo; break }
  }
  init-bopo + fin-bopo + tone
}

/// Convert an array of pinyin-numbers syllables to an array of zhuyin strings,
/// one bopomofo string per syllable.
/// e.g. ("bei3","jing1") → ("ㄅㄟˇ","ㄐㄧㄥˉ")
#let syllables-to-zhuyin(syllables) = syllables.map(pinyin-to-zhuyin)
