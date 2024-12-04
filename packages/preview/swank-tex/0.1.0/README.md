# swank-tex

Typographically correct TeX-family logos for Typst. This package provides
high-quality, properly kerned and positioned logos for TeX, LaTeX, XeTeX, and
related systems, based on the LaTeX metalogo package by Andrew Gilbert Moschou.

## Installation

Add this package to your Typst project:

```typst
#import "@preview/swank-tex:0.1.0": *
```

## Usage

The package provides the following logos as functions:

- `TeX`
- `LaTeX`
- `LaTeX2E`
- `XeTeX`
- `XeLaTeX`
- `LuaTeX`
- `LuaLaTeX`
- `pdfTeX`

Simply call these functions in your document:

```typst
#import "@preview/swank-tex:0.1.0": *

The #TeX typesetting system was created by Donald Knuth.
#LaTeX, created by Leslie Lamport, builds on top of #TeX.

Modern engines like #XeTeX and #LuaTeX extend these capabilities.
```

## Features

- Precise kerning between character pairs based on metalogo's output
- Proper vertical positioning of characters
- Correct scaling of special characters (e.g., the A in LaTeX)
- Uses New Computer Modern font for authentic appearance
- Pixel-matched to the well-established LaTeX metalogo package

## License

Licensed under the [MIT license](LICENSE).

## Acknowledgments

- Based on the LaTeX metalogo package by Andrew Gilbert Moschou
- Inspired by Donald Knuth's original TeX logo specifications
- Thanks to the Typst team for their excellent typesetting system

## Contributing

Contributions are welcome. Please feel free to submit a PR.

## Version History

- 0.1.0: Initial release
  - Basic implementation of all TeX-family logos
  - Proper kerning and positioning
  - Documentation and examples (see tests)
