#import "@preview/pycantonese-parser:0.2.0": *

// Load the plugin
#let canto = plugin("rust_canto.wasm")

/// Internal helper to convert string to bytes for the WASM plugin
#let _to_bytes(txt) = {
  if type(txt) == str { bytes(txt) } else { txt }
}

/// Annotates text into a list of dictionaries containing word, reading, and Yale.
/// Returns: array of {word: str, reading: str, yale: array}
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
/// - txt: The Cantonese string to process
/// - args: Captures named arguments like romanization: "yale" or "jyutping"
#let quick-render(txt, ..args) = {
  // 1. Get the data from your WASM plugin
  let data = json(canto.annotate(bytes(txt)))
  
  // 2. Forward the data and all extra arguments to the parser
  render-word-groups(data, ..args)
}
