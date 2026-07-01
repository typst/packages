# untypsignia.typ: unofficial typesetter's insignia emulations

The `untypsignia` is a 3rd-party, unofficial, unendorsed Typst package that exposes commands for
rendering, as `content` texts, some typesetters names in a stylized fashion, emulating their
respective _insignia_, i.e., marks by which they are known.

## Name

The package name is a blend of:

- "un", from "unofficial",
- "typ", from "Typst", and
- "signia", from "insignia", which means marks by which anything is known.

## Description

The typical use case of `untypsignia` in Typst is to emulate a given typesetting system's mark,
if available, when referring to them, in sentences like: "This document is typeset in `XYZ`", as
traditionally done in `TeX` systems and derivatives thereof.

Currently available insignia emulations include:

- `TeX`,
- `LaTeX`, and
- `typst`.

## Font Requirements

For best emulating the rendering of "typst", the `"Buenard"` font [Buenard - Google
Fonts](https://fonts.google.com/specimen/Buenard) must be installed, as to best approach the
rendering shown in Typst's own documentation, shown below:

![typst](https://typst.app/assets/images/typst.svg)

For the `TeX` system and it's derivatives, the `"New Computer Modern"` font is required.

## Usage

The package exposes the following few, parameterless, functions:

- `#texmark()`,
- `#latexmark()`, and
- `#typstmark()`.

Each such command to output their respective namesake signus emulation, in the document's
current `text` settings, with the exception of font — meaning text size, color, etc... will
apply to the signus emulation.

Aditionally, the signus emulation is produced, as `contexts` text inside a `box` — hence not
images — so as to avoid hyphenation to take place.

## Example

```typst
#set page(width: auto, height: auto, margin: 12pt, fill: rgb("19181f"))
#set par(leading: 1.5em)
#set text(font: "TeX Gyre Termes", fill: rgb("80f4b6"))

#import "@preview/untypsignia:0.1.0": *

#let say() = [I prefer #typstmark() over #texmark() or #latexmark().]

#for sz in (20, 16, 14, 12, 10, 8) {
  set text(size: sz * 1pt)
  say()
  linebreak()
}
```

This example results in a 1-page document like this one:

![Compiled
Example](https://github.com/cnaak/untypsignia.typ/blob/d9e215df04264a4e76a23d9f7130fe4670857733/thumbnail.png)

## Citing

This package can be cited with the following bibliography database entry:

```yml
untypsignia-package:
  type: Web
  author: Naaktgeboren, C.
  title:
    value: "untypsignia: unofficial typesetter's insignia emulations"
  url: https://github.com/cnaak/untypsignia.typ
  version: 0.1.0
  date: 2024-08
```

