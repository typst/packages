![logo](https://github.com/bernsteining/scoryst/blob/v0.1.1/test/logo.svg)

# Scoryst - Music Engraving Plugin for Typst

A Typst plugin that renders music notation from multiple formats using
[Verovio](https://www.verovio.org/), compiled to WebAssembly.

## Features

- **6 input formats**: ABC, MusicXML, MEI, Humdrum, Volpiano, CMME
- **5 music fonts**: Leipzig (default), Bravura, Gootville, Leland, Petaluma
- **Full Verovio options**: scale, font, page layout, and all
  [toolkit options](https://book.verovio.org/toolkit-reference/toolkit-options.html)
- **Multi-page support**: render individual pages of long scores
- **Binary font loading**: fonts pre-compiled to binary for instant init

Check the [documentation](https://github.com/bernsteining/scoryst/blob/v0.1.1/test/documentation.pdf) for a full demonstration with examples.

## Usage

```typst
#import "@preview/scoryst:0.1.1": render-music, music-page-count

// ABC notation (auto-detected)
#render-music(read("scarborough-fair.abc"), width: 100%)

// MusicXML (auto-detected)
#render-music(read("adagio.xml"), width: 100%)

// MEI (auto-detected)
#render-music(read("schubert.mei"), width: 100%)

// CMME (requires explicit format)
#render-music(read("cmme.xml"), options: (inputFrom: "cmme"))

// Change font
#render-music(data, options: (font: "Petaluma"))

// Multi-page
#let data = read("adagio.xml")
#let pages = music-page-count(data)
#for p in range(1, pages + 1) {
  render-music(data, page: p, width: 100%)
}
```

### API

**`render-music(data, options: none, page: 1, ..args)`**

Renders music notation to an SVG image. `data` is a string in any supported
format. `..args` are forwarded to Typst's `image()` function (`width`,
`height`, `fit`, `alt`).

**`music-page-count(data, options: none)`**

Returns the number of pages for the given music data.

## Known limitations

- **PAE unsupported**: Plaine & Easie Code is disabled — its parser relies on
  wasi syscalls that are stubbed in the WASM environment. We might wanna tackle this in later versions.
- **DARMS unsupported**: It worked but it looks like nobody uses this format so we dropped it.

## License

LGPLv3 - [Verovio's licensing](https://book.verovio.org/introduction/licensing.html)
