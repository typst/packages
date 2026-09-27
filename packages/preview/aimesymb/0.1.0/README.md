# aimesymb

`aimesymb` ports most of LaTeX's `amssymb` package to Typst. It provides
familiar AMS symbols such as `boxdot`, `nleqslant`, and `lrcorner` for use
directly in Typst equations.

## Requirements

- Typst 0.14.0 or newer.
- The `AMS Symbols A 10` and `AMS Symbols B 10` companion fonts.

Download the MATH-enabled companion fonts:

- [AMSSymbolsA10-Regular.otf](https://raw.githubusercontent.com/AprilGrimoire/aimesymb/v0.1.0/fonts/AMSSymbolsA10-Regular.otf)
- [AMSSymbolsB10-Regular.otf](https://raw.githubusercontent.com/AprilGrimoire/aimesymb/v0.1.0/fonts/AMSSymbolsB10-Regular.otf)

Typst Universe does not include font binaries in package downloads. Install
both files in your user font directory so Typst can find them automatically:

- Linux: `~/.local/share/fonts/aimesymb/`
- macOS: `~/Library/Fonts/`
- Windows: right-click each file and choose **Install for me**.

On Linux, refresh the font cache with `fc-cache -f` after copying the files.
Restart Typst or your editor if it was already running. In the Typst web app,
upload both OTF files to the document project instead.

## Usage

```typst
#import "@preview/aimesymb:0.1.0": *

$ A boxdot B $
$ x nleqslant y $
$ X varsubsetneqq Y $
$ bb(R) subseteqq RR $
```

The exported names follow LaTeX's `amssymb` and `amsfonts` interfaces without
the leading backslash. For example, `\boxdot` and `\nleqslant` become
`boxdot` and `nleqslant` inside a Typst equation.

For a local development install, import the package as:

```typst
#import "@local/aimesymb:0.1.0": *
```

Once installed, the companion fonts work with both import forms without extra
compiler options. No show or set rule is required: every exported AMS symbol
carries its own font selection. The companion family names are fixed to
`AMS Symbols A 10` and `AMS Symbols B 10`; surrounding math retains its
existing font and style.

## Coverage

- All AMS symbols declared by LaTeX's `amssymb` package, plus symbols loaded
  transitively from `amsfonts`.
- AMS ordinary, binary, relation, opening, and closing math classes.
- AMS's exceptional `Bbbk` symbol.
- The `dashrightarrow`, `dashleftarrow`, and `Join` composites.

The companion fonts are derived from BaKoMa's 10-point `msam10` and `msbm10`
OpenType/CFF files. Their original outlines and horizontal metrics are
preserved. The derived files add a Unicode/private-use cmap and an OpenType
MATH table, including 70% and 50% script scaling.

Named AMS symbols use non-overlapping private-use codepoints to preserve the
exact AMSa or AMSb slot without assigning inaccurate Unicode semantics. As a
result, PDF text extraction reports private-use characters for those symbols.

`mathbb` and `Bbb` forward to Typst's built-in `math.bb`; they do not select
the AMSb double-struck glyphs. The `mathfrak`, `frak`, `bold`, `widehat`, and
`widetilde` compatibility names likewise forward to Typst's built-ins.

## API

- All supported AMS symbol names are exported individually.
- `mathbb`, `mathfrak`, `Bbb`, `frak`, `bold`, `widehat`, and `widetilde`
  provide compatibility spellings backed by Typst's built-ins.

See [`examples/catalog.typ`](examples/catalog.typ) for the complete symbol
catalog.

## Development

The source repository contains the generated companion fonts for testing.
Rebuild and verify them from the vendored BaKoMa sources with:

```sh
python3 scripts/build_fonts.py
make test
```

The build checks source hashes, reloads each generated font, validates its
cmap and MATH table, and confirms that every original outline and horizontal
metric remains unchanged. The rendering tests disable font fallback.

## License

The Typst and build sources are MIT-licensed. The companion fonts are modified
BaKoMa fonts and remain under the
[BaKoMa Fonts Licence](fonts/LICENSE-BaKoMa.txt), which permits modification
and redistribution when its notices and original-font location are retained.
Each generated OTF embeds the full license, author statement, modification
notice, and original CTAN location.
