Adds rendering support to chemical structure images, directly from their source files in common formats (Reshiki RSK, ChemDraw CDXML, SMILES, MOL, ...).

A WASM plugin wraps [ReShiki](https://reshiki.com/)'s renderer so that chemical drawings are produced as SVG during Typst compilation. Simply import the package and call `#chem-image` with a file path or inline structure string.

## Quick start

```typst
#import "@preview/reshikist:0.3.2": chem-image

// File path — auto-detected from extension
#chem-image("molecule.rsk", width: 30%)

// Inline SMILES string
#chem-image("c1ccccc1", width: 25%)
```

## Supported formats

| Format | How to use |
|--------|-----------|
| **Reshiki RSK** | `#chem-image("molecule.rsk", width: 30%)` |
| **SMILES** | `#chem-image("CCO", width: 25%)` |
| **MOL / SDF** | `#chem-image("molecule.mol", width: 25%)` |
| **CDXML** | `#chem-image("drawing.cdxml", width: 30%)` |
| **RSMI** | `#chem-image("CCO.O=C=O>>CCOC(=O)O", format: "rsmi", width: 40%)` |

When `format` is `"auto"` (the default), the package detects file paths by extension (`.rsk`, `.mol`, `.cdxml`, `.smi`, `.sdf`, `.rxn`) or by path separators. Any other string is treated as an inline SMILES string.

## `chem-image( .. )`

Render a chemical drawing from any supported input.

```typst
#chem-image(
  data,
  format: "auto",
  width: auto,
  height: auto,
  background: "canvas",
  outline-text: false,
  fonts: (),
)
```

**Parameters**

- `data` — `str` (file path or inline SMILES) or `bytes` (raw file contents)
- `format` — `"auto"`, `"rsk"`, `"smiles"`, `"mol"`, `"cdxml"`, `"rxn"`, `"rsmi"`
- `width`, `height` — sizing constraints passed to `#image`
- `background` — `"canvas"`, `"transparent"`, or a `color`
- `outline-text` — convert text to SVG paths (`false` by default)
- `fonts` — array of `.ttf`/`.otf` file paths to load before rendering

Returns an `#image` element, or `none` if the input cannot be rendered.

## Global configuration with `.with()`

Set defaults once at the top of your document so you don't repeat them on every call.

```typst
#import "@preview/reshikist:0.3.2": chem-image

// Short example — outline text and load a custom font
#let chem-image = chem-image.with(outline-text: true, fonts: ("fonts/ChemDraw.ttf",))

#chem-image("molecule.rsk", width: 30%)
#chem-image("c1ccccc1", width: 25%)
```

## Background modes

```typst
// Default canvas background
#chem-image("molecule.rsk")

// Transparent background
#chem-image("molecule.rsk", background: "transparent")

// Custom solid color
#chem-image("molecule.rsk", background: rgb(240, 248, 255))
```

## Outlined text

When `outline-text: true`, text is converted to SVG `<path>` elements. This guarantees identical appearance everywhere, but removes text selectability.

```typst
// Live text (default)
#chem-image("molecule.rsk", width: 30%)

// Outlined text
#chem-image("molecule.rsk", width: 30%, outline-text: true)
```

## Custom fonts

Load TrueType or OpenType fonts into the WASM renderer before drawing. Fonts persist for the duration of Typst compilation.

```typst
#chem-image("molecule.rsk", fonts: ("fonts/ChemDraw.ttf",))
```

Fonts are especially useful with `outline-text: true`, because text-to-path conversion requires the actual font glyphs.

## Examples

All formats demonstrated:

```typst
#import "@preview/reshikist:0.3.2": chem-image

// Reshiki RSK file
#chem-image("pyrrole.rsk", width: 30%)

// MOL file
#chem-image("benzene.mol", width: 25%)

// CDXML file
#chem-image("indole.cdxml", width: 30%)

// Inline SMILES
#chem-image("c1ccccc1", width: 25%)
#chem-image("CC(C)C(C)(C)C", width: 25%)

// Reaction SMILES
#chem-image("CCO.O=C=O>>CCOC(=O)O", format: "rsmi", width: 40%)
```

See the `examples/` directory in this package for complete working files.

## Error handling

If an input cannot be parsed or rendered, the plugin returns empty bytes and the wrapper returns `none`. Your Typst compilation continues instead of halting. Check for missing images if a drawing fails.

## License

The reshikist package is licensed under MIT OR Apache-2.0, matching ReShiki.
Third-party dependencies and assets retain their own terms; see `NOTICE`.
