<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/bernsteining/scoryst/refs/tags/v0.1.3/test/logo.svg">
  <img alt="a treble clef and two notes as a logo" src="https://raw.githubusercontent.com/bernsteining/scoryst/refs/tags/v0.1.1/test/logo.svg">
</picture>

# Scoryst - Music Engraving Plugin for Typst

A Typst plugin to render music notation from multiple formats using
[Verovio](https://www.verovio.org/), compiled to WASM.

## Features

- **8 input formats**: [ABC](https://en.wikipedia.org/wiki/ABC_notation), [MusicXML](https://en.wikipedia.org/wiki/MusicXML), [MEI](https://music-encoding.org/), [Humdrum](https://wiki.ccarh.org/images/6/6e/Humdrum-File-Format.pdf), [EsAC](https://wiki.ccarh.org/wiki/EsAC), [PAE](https://www.iaml.info/plaine-easie-code/), [Volpiano](https://cantusdatabase.org/static/documents/2.%20Volpiano%20Protocols.pdf), [CMME](https://www.cmme.org/)
- **5 [SMuFL](https://www.smufl.org/)-compliant music fonts**: Leipzig (default), Bravura, Gootville, Leland, Petaluma
- **Full Verovio options**: scale, font, page layout, and all
  [toolkit options](https://book.verovio.org/toolkit-reference/toolkit-options.html)
- **Multi-page support**: render individual pages of long scores
- **Binary font loading**: fonts pre-compiled to binary for instant init

Check the [documentation](https://raw.githubusercontent.com/bernsteining/scoryst/refs/tags/v0.1.3/test/documentation.pdf) for a full demonstration with examples.

## Usage

Some formats are too verbose to write inline here, so only compact formats are written inline here.

```typst
#import "@preview/scoryst:0.1.3": score, pages

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
#score("@clef:G-2\n@keysig:\n@timesig:4/4\n@data:''4CDEF/GABc", options: (input-from: "pae"))

// Volpiano (requires explicit format)
#score("1---g--h-ij---hgf--g--hg---k--lk--k7", options: (input-from: "volpiano"))

// CMME (requires explicit format)
#score(read("cmme.xml"), options: (input-from: "cmme"))

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
Both kebab-case and camelCase keys are accepted (e.g. `adjust-page-height` or `adjustPageHeight`).

| Option | Default | Description |
|--------|---------|-------------|
| `adjust-page-height` | `true` | Crop SVG height to content |
| `adjust-page-width` | `false` | Crop SVG width to content |
| `scale` | `100` | Scale factor (percent) |
| `font` | `"Leipzig"` | Music font: Leipzig, Bravura, Gootville, Leland, Petaluma |
| `input-from` | `"auto"` | Format: auto, mei, musicxml, abc, humdrum, esac, pae, volpiano, cmme |
| `page-width` | `2100` | Page width (MEI units) |
| `page-height` | `2970` | Page height (MEI units) |
| `page-margin-top` | `50` | Top margin |
| `page-margin-bottom` | `50` | Bottom margin |
| `page-margin-left` | `50` | Left margin |
| `page-margin-right` | `50` | Right margin |
| `landscape` | `false` | Landscape orientation |
| `breaks` | `"auto"` | Line breaks: auto, line, encoded, none |
| `condense` | `"auto"` | Condense: auto, none, encoded |
| `transpose` | `""` | Transpose (e.g. "M2" for major second up) |
| `header` | `"auto"` | Header: auto, none, encoded |
| `footer` | `"auto"` | Footer: auto, none, encoded |
| `spacing-staff` | `12` | Spacing between staves |
| `spacing-system` | `12` | Spacing between systems |
| `spacing-linear` | `0.25` | Linear spacing factor |
| `spacing-non-linear` | `0.6` | Non-linear spacing factor |
| `unit` | `9` | Base unit size (half staff space) |
| `stem-width` | `0.2` | Stem width |
| `bar-line-width` | `0.3` | Bar line width |
| `staff-line-width` | `0.15` | Staff line width |
| `lyric-size` | `4.5` | Lyrics font size |
| `hairpin-size` | `3.0` | Hairpin height |
| `svg-view-box` | `false` | Use viewBox instead of width/height |
| `svg-remove-xlink` | `false` | Use href instead of xlink:href |
| `svg-bounding-boxes` | `false` | Add bounding box rects (debug) |
| `remove-ids` | `false` | Strip element IDs from SVG |
| `smufl-text-font` | `"embedded"` | SMuFL text font: embedded, linked, none |
| `pedal-style` | `"auto"` | Pedal marking style: auto, line, pedstar, altpedstar |
| `font-fallback` | `"Leipzig"` | Music font fallback for missing glyphs: Leipzig, Bravura |
| `lyric-elision` | `"regular"` | Lyric elision width: regular, narrow, wide, unicode |
| `multi-rest-style` | `"auto"` | Multi-measure rest style: auto, default, block, symbols |
| `system-divider` | `"none"` | System divider display: none, auto, left, left-right |
| `duration-equivalence` | `"brevis"` | Mensural duration equivalence: brevis, semibrevis, minima |
| `ligature-oblique` | `"auto"` | Ligature oblique shape: auto, straight, curved |
| `mensural-responsive-view` | `"none"` | Mensural responsive view: none, auto, selection |

