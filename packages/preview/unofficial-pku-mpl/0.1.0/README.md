<div align="center">

# pkumpl-typst

### A Typst Template for PKU Modern Physics Laboratory Reports

*Unofficial template. Ported from the [`revtex4-2`]-based [`PKUMpLtX`] (v2.1.6)*

[![Built with Typst](https://img.shields.io/badge/built%20with-Typst-239dad.svg)](https://typst.app/)
[![Supported platforms: macOS, Linux, Windows](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](#)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/license-CC%20BY--SA%204.0-blue.svg)](./LICENSE)

English | [中文](./README_zh.md)

</div>

## Overview

A Typst template for the *Modern Physics Laboratory* course at Peking University, ported from the LaTeX template [`PKUMpLtX`]. This project is an independent, unofficial Typst implementation.

## Features

- **Revtex-Faithful Layout** — Matches `revtex4-2` preprint style for body 12pt, line spacing, heading spacing, and numbering
- **Chinese Typography** — Roman/Sans/Mono mapped to Songti/Heiti/Fangsong with correct italic fallbacks; five font presets (`macos`, `windows`, `noto`, `notofandol`, `fandol`)
- **APS Bibliography** — `apsrev4-2` style approximated via a bundled CSL file; native `.bib` reading
- **Ruled Tables** — `ruled-table` reproduces the `ruledtabular` top-and-bottom double-line style
- **Frontmatter** — One `frontmatter(..)` call renders title, author, affiliation, date, abstract, and keywords; the abstract follows `mpltx.cls` with 11pt text, 400pt width, a 2em first-line indent, and an approximately 16.9pt baseline distance
- **Colored Links** — Cross-references, citations, and URLs colored per the LaTeX `hyperref` defaults

## Quick Start

**Prerequisites:** [Typst](https://github.com/typst/typst#installation) installed.

From the package (once published to Typst Universe):

```bash
typst init @preview/unofficial-pku-mpl:0.1.0
```

From source, to preview the full demo:

```bash
git clone https://github.com/xjsongphy/pkumpl-typst && cd pkumpl-typst
typst compile demo.typ
```

For live preview, `typst watch demo.typ`. All source files must be UTF-8 encoded.

## Typst Quick Start

New to Typst? Start with the official [Typst tutorial](https://typst.app/docs/tutorial/), or read the [Chinese Typst tutorial](https://typst.dev/docs/tutorial/). For agent-assisted Typst work, see the [Claude Typst skill](https://github.com/lucifer1004/claude-skill-typst).

### Package structure

The two Typst files have the following roles:

- `mplts.typ` is the package entrypoint and contains the reusable layout, typography, numbering, figure/table, bibliography, and helper-function implementation.
- `template/main.typ` is the initialized user document. It imports the published package and contains report content plus examples.
- `template/bibli.bib` and `template/american-physics-society.csl` are copied into new projects.

### Font Options

`font={macos|windows|noto|notofandol|fandol}` (default `macos`):

|         | Roman  | Sans Serif | Monospace |
| :-----: | :----: | :--------: | :-------: |
| Upright | Songti |   Heiti    |  Fangsong |
| Italic  | Fangsong |  Kaiti   |  Kaiti    |

Latin text uses New Computer Modern. The package does not bundle fonts, as required by Typst Universe. Install the CJK fonts needed by the selected preset locally:

- `macos`: Songti SC, PingFang SC, STFangsong, and Kaiti SC (macOS)
- `windows`: SimSun/STSong, Microsoft YaHei/DengXian, FangSong, and KaiTi (Windows)
- `noto`: Noto Serif CJK SC and Noto Sans CJK SC
- `fandol`: FandolSong, FandolHei, FandolFang, and FandolKai
- `notofandol`: Noto Serif/Sans CJK SC plus FandolFang/FandolKai

Use `noto` or `fandol` for a reproducible cross-platform setup. `macos` remains the default because it most closely matches the upstream LaTeX rendering on macOS. Run `typst fonts` to inspect the names visible to your Typst installation.

## Feedback

Found a bug or have a suggestion? Please [open an issue](https://github.com/xjsongphy/pkumpl-typst/issues). Pull requests are welcome.

---

## References

- [`PKUMpLtX`] — Original LaTeX template (revtex4-2 based), by the Modern Physics Lab, Peking University
- [`pkuthss-typst`](https://github.com/pku-typst/pkuthss-typst) — Peking University thesis Typst template, referenced for package structure and publishing practice
- [`revtex4-2`] — APS revtex class
- [CSL styles](https://github.com/citation-style-language/styles) — Source of the APS bibliography style
- [`fandol`] — Fandol Chinese fonts

## Copyright

+ Copyright (C) 2013–2026. Modern Phys. Lab, School of Phys., Peking Univ.
+ Copyright (C) 2013–2014. Sun Sibai <niasw@pku.edu.cn>
+ Copyright (C) 2013. Cao Chuanwu
+ Copyright (C) 2021–2026. Lin Xuchen <linxc@pku.edu.cn>
+ Copyright (C) 2026. Song Xinjie <xjsongphy@stu.pku.edu.cn>

## Third-party materials and licensing

This project is an independent Typst implementation derived from the layout and
example materials of [`PKUMpLtX`](https://github.com/CastleStar14654/PKUMpLtX),
the original LaTeX template for the Peking University Modern Physics Laboratory.
The adapted upstream material is distributed under the Creative Commons
Attribution-ShareAlike 4.0 International License; the upstream copyright notices
are preserved above and in [`LICENSE`].

The following files are derived from or copied from upstream materials:

- `fig/instruments.png`
- `fig/figsample.pdf`
- `figgen.py`
- `fig.mplstyle`
- `bibli.bib` (with additional entries for this Typst example)

The APS CSL file and its copy under `template/` carry their own metadata and are
licensed under the Creative Commons Attribution-ShareAlike 3.0 License. They
remain subject to that upstream license and are not relicensed by this project's
CC BY-SA 4.0 license.

This project does not bundle Peking University logos, seals, fonts, or other
official university brand assets.

## License

Released under the [Creative Commons Attribution-ShareAlike 4.0 International](./LICENSE) (CC BY-SA 4.0).

[`mplts.typ`]: ./mplts.typ
[`demo.typ`]: ./demo.typ
[`PKUMpLtX`]: https://github.com/CastleStar14654/PKUMpLtX
[`revtex4-2`]: https://www.ctan.org/pkg/revtex
[`fandol`]: https://www.ctan.org/pkg/fandol
[`image`]: https://typst.app/docs/reference/visualize/image/
