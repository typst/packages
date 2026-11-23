# yuhina

English | [繁體中文](README.zh-TW.md)

A shared typesetting base for Traditional Chinese documents in Taiwan, to be imported by [Typst](https://typst.app/) files. Compared with other Chinese typesetting packages, its distinguishing defaults are:

1. It prefers the fonts that ship with the Taiwanese edition of Windows (the most widely used operating system in Taiwan), such as PMingLiU (新細明體), DFKai-SB (標楷體) and Microsoft JhengHei (微軟正黑體), and falls back to openly licensed fonts elsewhere.
2. Headings use the six-level numbering common in Taiwanese documents, "壹、一、(一)", and cross-references print the full heading path, e.g. "見壹、二、(三)".

It also provides inline styles, title and author blocks, and typesetting rules that can be applied one by one (page, paragraph, footnote, list, figure caption, and so on).

The name `yuhina` comes from the [Taiwan yuhina](https://en.wikipedia.org/wiki/Taiwan_yuhina) (冠羽鳳眉), a bird endemic to Taiwan. Its sister packages [bluemagpie](https://github.com/zhenhuang-tw/bluemagpie) (for lecture notes) and [flamegold](https://github.com/zhenhuang-tw/flamegold) (for legal writing) are both built on it.

## Quick start

```typ
#import "@preview/yuhina:0.1.0": *

#show: common-style.with(title: "文件標題", authors: "王小明")

#title-block("文件標題", authors: "王小明")

= 緒論 <intro>

本文的#keyword[重點]如下（@detail[見]）。

== 細節 <detail>

#inquote[行內引用以楷體呈現。]
```

See [`examples/basic.typ`](examples/basic.typ) for a complete example.

When compiling, add `--input USE_WIN=1` on Windows or `--input USE_LINUX=1` on Linux to avoid a flood of missing-font warnings (see [Compile commands](#compile-commands)):

```powershell
typst compile file.typ --input USE_WIN=1
```

### Pitfalls when writing

- Do not break a Chinese sentence across lines in the source. Typst treats the line break as a space and prints "甲， 乙".
- Chinese text right after `@label` becomes part of the label name. Write `#ref(<label>)的` instead, or add a supplement after the label, such as `@label[見]`.

## Requirements

1. [Typst](https://github.com/typst/typst#installation) 0.15.1 or later.
2. Fonts: by default, the Windows/Office fonts Times New Roman, Arial, PMingLiU, DFKai-SB and Microsoft JhengHei UI are preferred. Missing fonts are replaced as described in [Font fallback](#font-fallback).

On the first compilation, Typst downloads this package and its dependency [`@preview/cuti`](https://typst.app/universe/package/cuti) automatically.

## Public API

`#import "@preview/yuhina:0.1.0": *` imports only the names listed below. Names not listed (helpers under `src/`, fallback font lists, and so on) are internal and may change at any time; do not rely on them.

### Typesetting rules

`common-style` applies every rule in the table below, in order. For finer control, apply them one by one instead. Each function is applied with `#show: function` or `#show: function.with(...)` and affects only the content after it.

| Function         | Purpose                                   | Parameters (defaults)                                        |
| ---------------- | ----------------------------------------- | ------------------------------------------------------------ |
| `document-style` | PDF title and authors                     | `title: ""`, `authors: ()`                                   |
| `page-style`     | Paper, margins, centered page number      | `paper: "a4"`, `margin: (x: 3cm, y: 2.5cm)`                  |
| `text-style`     | Fonts, language, CJK bold                 | `font: font-song`, `size: 12pt`                              |
| `par-style`      | Paragraphs                                | `first-line-indent: 0em`, `leading: 1.1em`, `spacing: 1.6em` |
| `quote-style`    | Block quotes                              | `font: font-kai`                                             |
| `list-style`     | Numbered and bulleted lists               | none                                                         |
| `figure-style`   | Figure captions                           | `font: font-kai`                                             |
| `footnote-style` | Footnotes                                 | `font: font-song`, `label-font: font-hei`                    |
| `heading-style`  | Heading numbering and appearance          | `font: font-hei`, `large: false`                             |
| `ref-style`      | Cross-references                          | `large: false` (must match `heading-style`)                  |

Parameters of `common-style`:

| Parameter | Default | Description                                                                                      |
| --------- | ------- | ------------------------------------------------------------------------------------------------ |
| `title`   | `""`    | Title in the PDF metadata (not printed on the page; use `title-block` for the printed title)      |
| `authors` | `()`    | Authors in the PDF metadata, in the same format as for `title-block`                             |
| `large`   | `false` | Whether to add a top level "Ch. 1" above the other levels, for long documents split into chapters |
| `fonts`   | `(:)`   | Font overrides, see [Overriding fonts](#overriding-fonts)                                        |

### Other names

| Name                                                           | Purpose                                                                                                                  |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `font-song`, `font-hei`, `font-kai`, `font-yuan`, `font-fsong` | Font lists: Song (serif), Hei (sans-serif), Kai (regular script), Yuan (rounded) and Fangsong                            |
| `keyword`                                                      | Inline emphasis (bold)                                                                                                   |
| `inquote`                                                      | Inline quotation (Kai by default; set another with the `font` parameter)                                                 |
| `title-block`                                                  | Centered title block with title, subtitle and authors; parameters `title-thanks`, `subtitle`, `authors`, `font`, `weight` |
| `normalize-authors`                                            | Turns authors given as a string, a single dictionary or an array into an array, for custom templates                    |
| `plain-links`                                                  | Removes link styling from the content after it; apply it after the outline so that the outline keeps its internal links |

An author can be a string or a dictionary with `name` and `thanks` (`thanks` is rendered as a footnote); several authors are given as an array mixing both:

```typ
#title-block(
  "文件標題",
  title-thanks: [本文為國立臺灣大學法律學系115學年度第1學期「弄春池生態專題研究」課程（授課教師：生工系共授）的學期報告初稿。],
  subtitle: "副標題",
  authors: ((name: "王小明", thanks: [國立臺灣大學法律學系碩士生，通訊作者。]), "李小華"),
)
```

### Heading numbering

| Level | Number    | With `large: true` |
| ----- | --------- | ------------------ |
| 1     | 壹、      | Ch. 1              |
| 2     | 一、      | 壹、               |
| 3     | (一)      | 一、               |
| 4     | 1.        | (一)               |
| 5     | (1)       | 1.                 |
| 6     | ①         | (1)                |
| 7     | no number | ①                  |

Top-level numbers beyond ten continue as "拾壹、", "貳拾、" and so on. Cross-references print the full path: `@label` gives "壹、二、(三)" and `@label[見]` gives "見壹、二、(三)". References to figures, bibliography entries and other targets are not affected.

Level-1 headings are centered and the other levels are left-aligned; unnumbered headings, such as the outline and bibliography titles, follow the same rule. The space below a heading equals the paragraph spacing, so a heading followed directly by another heading (e.g. "壹、" right before "一、") is spaced the same as a heading followed by body text. The spacing is computed at the body text size in effect where `heading-style` is applied; when applying the rules one by one, apply it after `text-style` and `par-style`.

## Font fallback

Linux and other non-Windows systems usually lack the fonts above. (macOS support is not planned for now, so the fallback lists do not include macOS-only fonts such as Songti TC or PingFang TC.) Each font group (`font-song`, `font-hei`, `font-kai`, `font-yuan`, `font-fsong`) is a list in order of priority, and Typst picks, glyph by glyph, the first installed font that has the glyph. Missing fonts are skipped, but each missing family causes an `unknown font family` warning (the output is unaffected; see [Compile commands](#compile-commands) to avoid the warnings). On a system without the preferred fonts, the fallbacks apply in this order:

| Use                             | Preferred (Windows/Office)                       | Fallback                                                                                                                         |
| ------------------------------- | ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| Body text (Song)                | Times New Roman, PMingLiU                        | Libertinus Serif (bundled with Typst); Noto Serif CJK TC, Source Han Serif TC, Noto Serif TC                                     |
| Headings (Hei)                  | Arial, Microsoft JhengHei UI                     | Libertinus Sans; Noto Sans CJK TC, Source Han Sans TC, Noto Sans TC                                                              |
| Quotes and captions (Kai)       | Times New Roman, DFKai-SB                        | Latin as for Song; TW-MOE-Std-Kai (教育部標準楷書), TW-Kai (全字庫正楷體), LXGW WenKai TC; if none is installed, the Song fallbacks |
| Rounded and Fangsong            | TaiwanPearl, Zhuque Fangsong (install yourself)  | Rounded: the Hei fallbacks; Fangsong: the Song fallbacks                                                                         |

Notes:

- Fallback fonts must be installed by you. We recommend Noto Serif/Sans CJK TC and Libertinus Sans from the [Libertinus](https://github.com/alerque/libertinus) family; Libertinus Serif, the Latin Song fallback, is bundled with Typst. **Install the TC (Traditional Chinese) versions**: if only the JP, SC or other regional versions are installed, Typst may use them, and the same character will take glyph shapes that differ from Taiwanese usage.
- Latin fonts come before CJK fonts in each list, so Latin letters and digits are set in Libertinus Serif (Song) or Libertinus Sans (Hei), and Chinese characters and full-width punctuation in the CJK font. Without Libertinus Sans, Latin letters and digits in Hei fall back to the Latin glyphs of the CJK sans-serif font. Libertinus Sans and Arial have different widths, so line breaks and page counts after fallback may differ from those on Windows.
- Bold: `text-style` decides whether to apply [cuti](https://typst.app/universe/package/cuti) fake bold from the first CJK font in the list, not from the font actually used. In the default lists the first CJK font is PMingLiU or a similar font without a bold face, so when the text falls back to a font with a real bold face, such as Noto, fake bold is still added on top and bold text comes out slightly heavier. For precise control, define your own font list (see [Overriding fonts](#overriding-fonts)) with the CJK font you want in the first CJK position.
- The fallback lists are based on the family names common on each platform; not every platform has been tested. If your fonts have different names, define your own list or open an issue in the repository.

### Compile commands

Typst has no setting to silence `unknown font family` warnings, and a document cannot query which fonts are installed, so the user has to state the environment at compile time (an approach taken from a [discussion on the Typst forum](https://forum.typst.app/t/is-it-possible-to-suppress-the-warning-about-noto-cjk-source-han-duality/2207)). Add `--input` for your operating system:

```powershell
# Windows
typst c file.typ --input USE_WIN=1
typst w file.typ --input USE_WIN=1
```

```sh
# Linux
typst c file.typ --input USE_LINUX=1
typst w file.typ --input USE_LINUX=1
```

The flag value can be `1` or `true`. Without either flag, the full lists above are kept (with warnings for missing fonts); setting both is an error. The fonts used in each mode are:

| Use                       | `USE_WIN=1`                                   | `USE_LINUX=1`                                       |
| ------------------------- | --------------------------------------------- | --------------------------------------------------- |
| Body text (Song)          | Times New Roman, PMingLiU, Libertinus Serif   | Libertinus Serif, Noto Serif CJK TC                 |
| Headings (Hei)            | Arial, Microsoft JhengHei UI                  | Libertinus Sans, Noto Sans CJK TC                   |
| Quotes and captions (Kai) | Times New Roman, DFKai-SB, Libertinus Serif   | Libertinus Serif, TW-MOE-Std-Kai, Noto Serif CJK TC |
| Rounded and Fangsong      | Preferred font (install yourself), then as Hei or Song | Preferred font (install yourself), then as Hei or Song |

Libertinus Serif is bundled with Typst and never causes a warning, so both modes keep it. These settings also apply to every template that imports yuhina, such as flamegold and bluemagpie.

Notes:

- The operating system is not detected automatically; you must add the flag yourself. Using `USE_LINUX` on Windows, or `USE_WIN` on Linux, leaves no usable fallback because the fonts are missing. macOS support is not planned for now, so there is no flag for it.
- `USE_LINUX=1` assumes that Libertinus Sans, Noto Serif CJK TC, Noto Sans CJK TC and TW-MOE-Std-Kai are installed (preferably the TC versions, see above). Missing fonts still cause warnings, and no other fallback is tried. If you installed Source Han, TW-Kai or similar fonts instead, do not set the flag, or define your own lists with the `fonts` parameter of `common-style`.
- Both modes drop the font-level fallback for missing glyphs: for example, a character missing from PMingLiU is no longer taken from Noto. Typst also has a global fallback that does not follow the lists, but this project has not verified its results for rare characters; please check them yourself.
- The preferred Rounded and Fangsong fonts (TaiwanPearl, Zhuque Fangsong) always have to be installed by you; using `font-yuan` or `font-fsong` without them still causes warnings.
- Lists you define with the `fonts` parameter of `common-style` or the `font` parameter of the individual style functions are not affected.
- Live previews in editors such as tinymist need the same `--input` in their own settings, or the preview still shows the warnings.
- The Typst web app is not covered here; its warnings can be dismissed in the interface.

### Optional fonts: Rounded and Fangsong

`font-yuan` (Rounded) and `font-fsong` (Fangsong) use fonts that do not come with the operating system; you need to obtain them yourself. Without them, the Hei or Song fallbacks in the table above are used. This package does not include any fonts, and the font licenses are independent of this package's MIT license. The information below is summarized from each project page (November 2026); the project pages and the license files shipped with the fonts prevail.

| Font                                                              | Name in the list                      | License                                                                                                         | How to get it                                                                       | Notes                                                                                                                                                                                                       |
| ----------------------------------------------------------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [TaiwanPearl 台灣圓體](https://github.com/max32002/TaiwanPearl)   | `TaiwanPearl`                         | SIL Open Font License 1.1; free for commercial use                                                              | Download the ZIP from the project page, or the font files from its `ttf` folder, and install them | Glyphs derived from Source Han Sans and Kosugi Maru; the author notes that it is not a professional font and some symbols or rare characters may be missing. The page mentions only Regular and says nothing about bold, so bold uses fake bold |
| [Zhuque Fangsong 朱雀仿宋](https://github.com/TrionesType/zhuque) | `Zhuque Fangsong (technical preview)` | SIL Open Font License 1.1; free for commercial use, copying and redistribution, but may not be sold by itself, modified or not | From the Releases of the project page (an AtomGit mirror is also listed there)     | The page does not say whether the glyphs follow Taiwanese standards; check before use                                                                                                                       |

OFL 1.1 allows using the fonts in documents and distributing the resulting PDFs. Redistributing the font files themselves must follow the license, including shipping the license file and not selling the fonts by themselves.

**The Zhuque Fangsong family name**: `Zhuque Fangsong (technical preview)`, used by `font-fsong`, is the family name of the preview release. The upstream project page says the stable release is not out yet. If the stable release uses another family name, `font-fsong` will not find it and will use the fallbacks. This package will update the list in a new version; until then, if you have installed the stable release, define your own list:

```typ
#let my-fsong = ("正式版的家族名稱", ..font-fsong)
#text(font: my-fsong)[仿宋文字]
```

### Overriding fonts

The `fonts` parameter of `common-style` overrides fonts. Its keys are `song` (body text and footnotes), `hei` (headings and footnote numbers) and `kai` (block quotes and captions), and its values are font lists; keys not given keep their defaults. Any other key is an error, so that a typo does not silently do nothing.

```typ
// 完全自訂：只使用指定的字型
#show: common-style.with(
  fonts: (song: ("Libertinus Serif", "Noto Serif CJK TC")),
)

// 保留預設的降級順序，只在最前面加上自己的字型
#show: common-style.with(
  fonts: (hei: ("My Sans", ..font-hei)),
)
```

The first example uses only the given fonts; the second keeps the default fallback order and adds a font in front.

`title-block` and `inquote` are not covered by `common-style`; set their fonts with the `font` parameter, e.g. `#title-block("標題", font: font-song)` or `#inquote(font: font-song)[文字]`. `title-block` is bold Hei by default, and its `weight` parameter changes the weight, e.g. regular Kai: `#title-block("標題", font: font-kai, weight: "regular")`. The individual style functions (`text-style`, `heading-style`, and so on) have their own `font` parameter.

When you define a complete list, put the CJK font you want in the first CJK position, because the bold detection (see above) looks at it.

## Versioning

This package follows [Semantic Versioning 2.0.0](https://semver.org/). The public API consists of the names listed under [Public API](#public-api) and their parameters.

- Before 1.0.0: breaking changes (removing or renaming a public name, changing a parameter or a default output) and backward-compatible new features both bump the minor version (e.g. 0.1.0 → 0.2.0); bug fixes bump the patch version (e.g. 0.1.0 → 0.1.1).
- From 1.0.0 on: breaking changes bump the major version, new features the minor version, and bug fixes the patch version.

See the [CHANGELOG](CHANGELOG.md) for the changes in each version.

## Development

### Installing as a local package

To work on this package before a new version is published, install it as a local package. Typst looks for local packages in `%APPDATA%\typst\packages\local\<name>\<version>`; create a directory junction there that points to this repository, so that changes in the repository take effect without copying:

```powershell
$pkg = "$env:APPDATA\typst\packages\local\yuhina\0.1.0"
New-Item -ItemType Directory -Force (Split-Path $pkg) | Out-Null
New-Item -ItemType Junction -Path $pkg -Target (Resolve-Path .)
```

Run this in the repository root; creating a junction does not require administrator rights. Then import with `#import "@local/yuhina:0.1.0": *`. The path contains the version number, so create a new junction after each version bump.

### Tests

Tests use [tytanic](https://github.com/typst-community/tytanic) (0.4.1, which bundles Typst 0.15.1):

```powershell
tt run              # run all tests
tt update footnote  # update the reference image after checking the output
```

When public names are added or removed, also update `tests/api/test.typ`, both READMEs and the CHANGELOG.

## License

This package is released under the [MIT](LICENSE) license. Fonts are not included in this package; see [Optional fonts](#optional-fonts-rounded-and-fangsong) for their licenses.
