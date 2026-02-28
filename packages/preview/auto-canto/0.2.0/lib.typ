#import "@preview/pycantonese-parser:0.2.0": *

// Load the plugin
#let canto = plugin("rust_canto.wasm")

/// Internal helper to convert string to bytes for the WASM plugin
#let _to_bytes(txt) = {
  if type(txt) == str { bytes(txt) } else { txt }
}

/// Internal helper to extract text
#let _extract-text(it) = {
  if type(it) == str {
    it
  } else if type(it) == content {
    if it.has("text") {
      it.text
    } else if it.has("children") {
      it.children.map(_extract-text).join("")
    } else if it.has("body") {
      _extract-text(it.body)
    } else if it == [ ] {
      " "
    } else {
      ""
    }
  } else {
    ""
  }
}

/// Annotates text into a list of dictionaries containing word, jyutping, and Yale.
/// Returns: array of {word: str, jyutping: str, yale: array}
#let annotate(txt) = {
  json(canto.annotate(_to_bytes(txt)))
}

/// Converts a space-delimited Jyutping string to Yale with tone numbers.
/// Example: "gwong2 dung1 waa2" → "gwong2 dung1 wa2"
#let to-yale-numeric(jp-str) = {
  str(canto.to_yale_numeric(_to_bytes(jp-str)))
}

/// Converts a space-delimited Jyutping string to Yale with diacritics.
/// Example: "gwong2 dung1 waa2" → "gwóngdūngwá"
#let to-yale-diacritics(jp-str) = {
  str(canto.to_yale_diacritics(_to_bytes(jp-str)))
}

/// A flexible wrapper that segments text and forwards all styling 
/// parameters to the parser's rendering function.
/// - it: The item containing Cantonese string to process
/// - args: Captures named arguments like romanization: "yale" or "jyutping"
#let quick-render(it, ..args) = {
  // 1. Extract text from item
  let txt = _extract-text(it)

  // 2. Get the data from the WASM plugin
  let data = json(canto.annotate(bytes(txt)))

  // 3. Forward the data and all extra arguments to the parser
  render-word-groups(data, ..args)
}

/// Render Cantonese text with jyutcitzi annotations above each word.
/// The caller must pass the `jyutcitzi` function from @preview/se-jyutcitzi.
///
/// Example:
///   #import "@preview/se-jyutcitzi:0.3.2": jyutcitzi
///   #import "@preview/auto-canto:0.2.0": jyutcit-ruby
///   #jyutcit-ruby(it, jyutcitzi: jyutcitzi)
#let jyutcit-ruby(it, jyutcitzi: none, style: (:)) = {
  assert(jyutcitzi != none, message: "jyutcit-ruby requires the jyutcitzi function from @preview/se-jyutcitzi")
  let default-style = (
    rb-color:    rgb("#ff0000"),
    rb-size:     0.8em,
    word-sep:    0.2em,
    char-jp-sep: 0.2em,
  )
  let s = default-style + style
  let data = annotate(_extract-text(it))
  [
    #for item in data {
      if item.word == "\n" { text[\ ]; continue }
      let ruby-txt = jyutcitzi(item.jyutping)
      if ruby-txt != none {
        box(stack(
          dir: ttb,
          spacing: s.char-jp-sep,
          align(center, text(s.rb-size, s.rb-color, ruby-txt)),
          align(bottom + center, box(height: 1em, text(1em, item.word))),
        ))
      } else {
        text(1em, item.word)
      }
      h(s.word-sep)
    }
    #h(-s.word-sep)
  ]
}
