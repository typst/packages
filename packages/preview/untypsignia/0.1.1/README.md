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
- `Typst` (see below)

Despite there's no such a thing as a Typst "official" typography, according to this post on
[Discord](https://discord.com/channels/1054443721975922748/1054443722592497796/1107039477714665522),
it can be typeset with "whatever font" the surrounding text is being typeset. Moreover, Typst
[branding page](https://typst.app/legal/brand/) requires capitalization of the initial "T"
whenever the name is used in prose. Therefore, the "Typst" support in this package is a mere,
still unofficial, implementation of the capitalization of "Typst" in the currently used font.

## Font Requirements

For the `TeX` system and it's derivatives, the `"New Computer Modern"` font is required.

## Usage

The package exposes the following few, parameterless, functions:

- `#texmark()`,
- `#latexmark()`, and
- `#typstmark()`.

Except for the `#typstmark()`, each such command outputs their respective namesake signus
emulation, in the document's current `text` settings, with the exception of font — meaning text
size, color, etc... will apply to the signus emulation.

Aditionally, the signus emulation is produced, as `contexts` text inside a `box` — hence not
images — so as to avoid hyphenation to take place. This also applies to the `#typstmark()`
function, for lack of specific guidance, and also because "Typst" is a short word.

## Example

```typst
#set page(width: auto, height: auto, margin: 12pt, fill: rgb("19181f"))
#set par(leading: 1.5em)
#set text(font: "Rouge Script", fill: rgb("80f4b6"))

#import "@preview/untypsignia:0.1.1": *

#let say() = [I prefer #typstmark() over #texmark() or #latexmark().]

#for sz in (20, 16, 14, 12, 10, 8) {
  set text(size: sz * 1pt)
  say()
  linebreak()
}
```

This example results in a 1-page document like this one:

![Compiled
Example](https://github.com/cnaak/untypsignia.typ/blob/86b221379931edcbfa91b50159a4ff930ecbec47/thumbnail.png)

## Citing

This package can be cited with the following bibliography database entry:

```yml
untypsignia-package:
  type: Web
  author: Naaktgeboren, C.
  title:
    value: "untypsignia: unofficial typesetter's insignia emulations"
  url: https://github.com/cnaak/untypsignia.typ
  version: 0.1.1
  date: 2024-08
```

