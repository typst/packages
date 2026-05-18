![logo](https://github.com/bernsteining/scoryst/blob/v0.1.1/test/logo.svg)

# Scoryst - Music Engraving Plugin for Typst

A Typst plugin to render music notation from multiple formats using
[Verovio](https://www.verovio.org/), compiled to WASM.

## Features

- **8 input formats**: ABC, MusicXML, MEI, Humdrum, EsAC, PAE, Volpiano, CMME
- **5 [SMuFL](https://www.smufl.org/)-compliant music fonts**: Leipzig (default), Bravura, Gootville, Leland, Petaluma
- **Full Verovio options**: scale, font, page layout, and all
  [toolkit options](https://book.verovio.org/toolkit-reference/toolkit-options.html)
- **Multi-page support**: render individual pages of long scores
- **Binary font loading**: fonts pre-compiled to binary for instant init

Check the [documentation](https://github.com/bernsteining/scoryst/blob/v0.1.2/test/documentation.pdf?raw=1) for a full demonstration with examples.

## Usage

Some formats are too verbose to write inline here, so only compact formats are written inline here.

```typst
#import "@preview/scoryst:0.1.2": score, pages

// ABC notation (auto-detected)
#score("X:1\nM:4/4\nK:C\nCDEF|GABc|")

// MusicXML (auto-detected)
#score(read("adagio.xml"))

// MEI (auto-detected)
#score(read("schubert.mei"))

// Humdrum (auto-detected)
#score(read("sample-humdrum.krn"))

// EsAC - Essen Associative Code (auto-detected)
#score(read("hildebrandslied.esac"))

// PAE - Plaine & Easie Code (requires explicit format)
#score("@clef:G-2\n@keysig:\n@timesig:4/4\n@data:''4CDEF/GABc", options: (inputFrom: "pae"))

// Volpiano (requires explicit format)
#score("1---g--h-ij---hgf--g--hg---k--lk--k7", options: (inputFrom: "volpiano"))

// CMME (requires explicit format)
#score(read("cmme.xml"), options: (inputFrom: "cmme"))

// Change font
#score(data, options: (font: "Petaluma"))

// Multi-page
#let data = read("adagio.xml")
#let n = pages(data)
#for p in range(1, n + 1) {
  score(data, page: p)
}
```

### API

**`score(data, options: none, page: 1, ..args)`**

Renders music notation to an SVG image. `data` is a string in any supported
format. `..args` are forwarded to Typst's `image()` function (`width`,
`height`, `fit`, `alt`).

**`pages(data, options: none)`**

Returns the number of pages for the given music data.

### Verovio Options

Options are passed as a Typst dictionary and map directly to
[Verovio's toolkit options](https://book.verovio.org/toolkit-reference/toolkit-options.html).

| Option | Default | Description |
|--------|---------|-------------|
| `adjustPageHeight` | `true` | Crop SVG height to content |
| `adjustPageWidth` | `false` | Crop SVG width to content |
| `scale` | `100` | Scale factor (percent) |
| `font` | `"Leipzig"` | Music font: Leipzig, Bravura, Gootville, Leland, Petaluma |
| `inputFrom` | `"auto"` | Format: auto, mei, musicxml, abc, humdrum, esac, pae, volpiano, cmme |
| `pageWidth` | `2100` | Page width (MEI units) |
| `pageHeight` | `2970` | Page height (MEI units) |
| `pageMarginTop` | `50` | Top margin |
| `pageMarginBottom` | `50` | Bottom margin |
| `pageMarginLeft` | `50` | Left margin |
| `pageMarginRight` | `50` | Right margin |
| `landscape` | `false` | Landscape orientation |
| `breaks` | `"auto"` | Line breaks: auto, line, encoded, none |
| `condense` | `"auto"` | Condense: auto, none, encoded |
| `transpose` | `""` | Transpose (e.g. "M2" for major second up) |
| `header` | `"auto"` | Header: auto, none, encoded |
| `footer` | `"auto"` | Footer: auto, none, encoded |
| `spacingStaff` | `12` | Spacing between staves |
| `spacingSystem` | `12` | Spacing between systems |
| `spacingLinear` | `0.25` | Linear spacing factor |
| `spacingNonLinear` | `0.6` | Non-linear spacing factor |
| `unit` | `9` | Base unit size (half staff space) |
| `stemWidth` | `0.2` | Stem width |
| `barLineWidth` | `0.3` | Bar line width |
| `staffLineWidth` | `0.15` | Staff line width |
| `lyricSize` | `4.5` | Lyrics font size |
| `hairpinSize` | `3.0` | Hairpin height |
| `svgViewBox` | `false` | Use viewBox instead of width/height |
| `svgRemoveXlink` | `false` | Use href instead of xlink:href |
| `svgBoundingBoxes` | `false` | Add bounding box rects (debug) |
| `removeIds` | `false` | Strip element IDs from SVG |
| `smuflTextFont` | `"embedded"` | SMuFL text font: embedded, linked, none |

