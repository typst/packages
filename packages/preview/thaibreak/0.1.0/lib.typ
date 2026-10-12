/// Typst plugin for Thai word segmentation and typographic line breaking.
/// Powered by kamthorn/thai-break (Rust core + dictionary trie).

#let _plugin = plugin("thaibreak.wasm")

/// Break Thai text with a custom marker (default: ZWSP U+200B).
///
/// - `text` (str): Input text containing Thai script.
/// - `marker` (str): Break marker character to insert between words. Default is `\u{200B}`.
/// -> str
#let break-lines(text, marker: "\u{200B}") = {
  str(_plugin.break_lines_with_marker(bytes(text), bytes(marker)))
}

/// Segment Thai text into a list of word tokens.
///
/// - `text` (str): Input text containing Thai script.
/// -> array of str
#let segment-words(text) = {
  let s = str(_plugin.segment_words(bytes(text)))
  if s.len() == 0 {
    ()
  } else {
    s.split("\n")
  }
}

/// Document-level or scoped show rule to enable natural Thai line breaking.
///
/// By default, `mode: "box"` wraps each Thai word in an atomic inline box,
/// which strictly prevents upstream line breakers (e.g. ICU LSTM) from
/// splitting Thai words or tone marks mid-word.
///
/// `mode: "zwsp"` inserts zero-width spaces (`\u{200B}`) at word boundaries,
/// keeping text purely as plain characters.
///
/// Example:
/// ```typ
/// #import "@preview/thaibreak:0.1.0": thai-break
/// #show: thai-break
/// ```
#let thai-break(body, mode: "box", marker: "\u{200B}") = {
  if mode == "box" {
    show regex("[\u{0E00}-\u{0E7F}]+"): it => {
      let words = segment-words(it.text)
      words.map(w => box(w)).join()
    }
    body
  } else {
    show regex("[\u{0E00}-\u{0E7F}]+"): it => {
      break-lines(it.text, marker: marker)
    }
    body
  }
}
