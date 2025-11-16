Of course, here is a polished version of your `README.md` with corrections and improvements for clarity and readability.

***

# melt

**WARNING: This package is still under development. APIs are unstable and may change without notice.**

A [Typst](https://typst.app/) package for introspecting fonts.

`melt` provides low-level access to font information by combining Typst's internal font data with the `ttf-parser` library through a WebAssembly plugin. It allows you to extract detailed information about fonts directly within your Typst documents.

The name "melt" is a nod to traditional metal typesetting, where font characters (types) were cast from molten metal.

## Usage

First, add the package to your project:

```typst
#import "@preview/melt:0.1.0": *
```

Then, you can use the provided functions to inspect your font files. For example, to get information about a font:

```typst
// Read the font file as raw bytes.
#let font-data = read("your-font.ttf", encoding: none)

// Get information about the first font in the file.
#let info = font-info(font-data)

// Now you can access the font's properties.
#info.properties.names.full-name
#info.metrics.x-height

// Check if the font contains a specific character.
#contains(info, "x".to-unicode())
```

## Example: Fake Bold

Once you have parsed the fonts used in your document, you can perform more advanced operations. This example demonstrates how to create a "fake bold" effect that adjusts its spacing based on whether the font is monospace.

```typ
#import "@preview/melt:0.1.0": *

// Assume the following fonts exist in an 'assets' folder.
#let monaco-parsed = font-info(read("assets/Monaco.ttf", encoding: none))
#let sourcehansans-parsed = fonts-collection-info(read("assets/SourceHanSans.ttc", encoding: none))

// Create a dictionary to easily look up parsed font info by family name.
#let parsed-fonts = (
  (monaco-parsed, ..sourcehansans-parsed)
    .map(
      it => (lower(it.typst.family), it),
    )
    .to-dict()
)

// A function to create a "fake bold" effect by adding a stroke.
// It intelligently adjusts tracking for non-monospace fonts.
// Original idea: https://github.com/typst/typst/issues/2157#issuecomment-1635393083
#let fakebold(txt, stroke: 1) = {
  context {
    let font-info = parsed-fonts.at(text.font, default: none)
    let is-mono = if font-info != none { font-info.typst.is_monospace } else { false }

    text(
      tracking: if is-mono { 0em } else { stroke * 0.001em },
      stroke: (stroke * 0.001em) + text.fill,
      txt,
    )
  }
}

#set text(font: "Source Han Sans", lang: "cn")

#fakebold("Hello, World!", stroke: 20) \
#fakebold("Hello, World!", stroke: 50)

#set text(font: "Monaco")

#fakebold("Hello, World!", stroke: 20)\
#fakebold("Hello, World!", stroke: 50)
```

## API Reference

### `fonts-collection-info`

Parses a font file (or a font collection) and returns an array of dictionaries, with each dictionary containing information about a single font.

- `data`: `bytes` — The raw data of the font file.
- **Returns**: `array` of font information dictionaries. See `font-info` for the structure of each dictionary.

### `font-info`

A convenience function to get information about a single font. It is especially useful for font files that contain only one font.

- `data`: `bytes` — The raw data of the font file.
- `index`: `integer` (optional, default: `0`) — The index of the font to inspect in a font collection.
- **Returns**: `dictionary` containing the font information with the following keys:
    - `properties`: A dictionary with the font's names, scripts, and features.
        - `names`: Contains various name strings from the font's `name` table (e.g., `family`, `full-name`, `postscript-name`). _Note: These may differ from what Typst uses. See `typst.family` for the name recognized by Typst._ All possible entries (would be `none` if not existing in ttf `name` table):
          - `ps_name`
          - `family`
          - `subfamily`
          - `version`
          - `full_name`
          - `unique_id`
          - `typographic_family`
          - `typographic_subfamily`
          - `designer`
  copyright: Option<FontName>,
        - `scripts`: A list of supported script and language tags from the font's `GSUB` and `GPOS` tables.
          _Note: This might not be the list of the font's intended scripts and languages._
        - `features`: A list of supported OpenType feature tags.
    - `metrics`: A dictionary with various font metrics. This mirrors Typst's internal `FontMetrics` structure.
        - `units_per_em`: `integer`
        - `italic_angle`: `float` (degrees)
        - All other metrics (e.g., `ascender`, `descender`, `x-height`) are in `em` units.
    - `typst`: A dictionary containing font information as seen by Typst's engine. This mirrors the internal `FontInfo` structure, with flags converted to booleans for convenience.
        - `coverage`: The internal representation of Unicode coverage. Use this with the `contains` function to check for character support.

### `contains`

Checks if a given codepoint is present in the font's coverage data.

- `parsed-data`: `dictionary` — The font information dictionary from `font-info` or `fonts-collection-info`.
- `codepoint`: `integer` — The Unicode codepoint to check.
- **Returns**: `boolean` indicating whether the codepoint is covered by the font.

## Known Limitations

- Due to Typst's security model, this package cannot access system-installed fonts. You must provide the font file directly by reading it from a local path.

## License

This project is licensed under the MIT License.
