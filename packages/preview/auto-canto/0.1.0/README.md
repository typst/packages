## auto-canto

This Typst package provides automatic Cantonese segmentation and romanization
(Jyutping (粵拼) and Yale (耶魯)) by wrapping the
[`rust-canto`](https://crates.io/crates/rust-canto) Rust crate as a WebAssembly
plugin. It integrates seamlessly with the
[`pycantonese-parser`](https://github.com/VincentTam/pycantonese-parser/)
package to render beautiful Cantonese text with ruby characters.

---

### Features

* **Automatic Segmentation**: Breaks Cantonese sentences into meaningful words
using a dictionary-based trie.
* **Multiple Romanizations**: Supports both **Jyutping** and **Yale** (numeric
or diacritics).
* **High Performance**: Powered by a Rust-compiled WASM plugin for fast
processing.
* **Typst Integration**: Provides a `quick-render` function that handles both
segmentation and styling in one go.

---

### Usage

To use this package, ensure the `rust_canto.wasm` file is in your project directory.

```typst
#import "@preview/auto-canto:0.1.0": quick-render

// 36pt font
// use Libertinus Serif first (for ruby text)
// before falling back to Noto Serif CJK HK (for Chinese characters)
#set text(36pt, font: ("Libertinus Serif", "Noto Serif CJK HK"))

// 1. Basic rendering (defaults to Jyutping)
#quick-render("佢係好學生")

// 2. Rendering with Yale romanization
#quick-render("平時會成日睇書", romanization: "yale")

// 3. Customizing the underlying parser's style
#let my-style = (rb-size: 0.7em, rb-color: blue)
#quick-render("廣東話好難學", style: my-style)
```

![example output](example.png)

Live demo on YouTube: https://youtu.be/ivUu91eDfvY

---

### API Reference

#### `quick-render(txt, ..args)`

The primary high-level function. It fetches data from the WASM plugin and
forwards it to the parser.

* `txt`: The Cantonese string to process.
* `..args`: Named arguments forwarded to [`render-word-groups`](https://github.com/VincentTam/pycantonese-parser/blob/7ed67e5d/src/renderer.typ#L10-L15)
(e.g. `romanization`, `style`).

#### `annotate(txt)`

Returns the raw segmented data as an array of dictionaries.

* **Return format**: `array` of `{word: str, jyutping: str, yale: array}`.

#### `to-yale-numeric(jp-str)` / `to-yale-diacritics(jp-str)`

Utility functions to convert space-delimited Jyutping strings into Yale format.

* `numeric`: "gwong2 dung1 waa2" → "gwong2 dung1 wa2".
* `diacritics`: "gwong2 dung1 waa2" → "gwóngdūngwá".

---

### Project Structure

* `lib.typ`: The main entry point containing the Typst wrappers.
* `rust_canto.wasm`: The WebAssembly binary compiled from the `rust-canto`
crate.
* `typst.toml`: Package metadata and dependencies.

### License

MIT

### Contributing

Contributions are welcome! Please open an issue or submit a pull request.
