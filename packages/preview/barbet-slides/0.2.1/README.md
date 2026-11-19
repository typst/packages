# barbet-slides

Slides for law school presentations in Traditional Chinese (zh-Hant-TW), built on [typslides](https://typst.app/universe/package/typslides). The package adds a muted blue palette, a set of line icons, layout components for legal argument (cards, verdict markers, flow nodes, timelines, source lines) and a hidden bibliography for in-slide citations.

The name refers to the Taiwan barbet (_Psilopogon nuchalis_), a bird endemic to Taiwan. This is an unofficial personal project; contributions are welcome. 中文說明見 [README-zh.md](README-zh.md).

## Requirements

- Typst 0.15.0 or later.
- The font [Noto Sans TC](https://fonts.google.com/noto/specimen/Noto+Sans+TC), which packages cannot ship. Install it, or pass another font with `deck.with(font: "...")`.
- typslides 1.4.0 is downloaded automatically on first compile.

## Quick start

Create a new deck from the template:

```sh
typst init @preview/barbet-slides:0.2.1 my-talk
```

Or use the package in an existing file:

```typ
#import "@preview/barbet-slides:0.2.1": *

#show: deck.with()

#front-slide(title: [簡報標題], authors: [報告人])

#title-slide[壹、問題提出]

#slide(title: "爭點")[
  #card(title: [結論], icon: "court")[
    #yes[合憲] \
    #partly[部分違憲]
  ]
  #note(icon: "alert")[#case[111憲判2] 的射程不限於公開道歉。]
  #src(cite(<zhangsan2022>))
]

#hidden-bibliography(path("refs.bib"))
```

`hidden-bibliography` takes a `path(...)` (or bytes from `read(..., encoding: none)`), not a string: a plain string would be resolved relative to the package, not to your file.

## Reference

### Set-up

| Name                                                                                                                                                                 | Description                                                                                                                                                                        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `deck(ratio: "16-9", theme: c.accent, font: "Noto Sans TC", font-size: 18pt, back-color: c.bg, link-style: "color", progress-height: 3pt, lang: "zh", region: "tw")` | Show rule for the whole deck: applies typslides with page numbers and a progress bar, the text language and the table style. `link-style` is `"color"`, `"underline"` or `"both"`. |
| `hidden-bibliography(source, style: "apa")`                                                                                                                          | Loads a bibliography so that `cite` works, without printing the list.                                                                                                              |

typslides functions are re-exported: `front-slide`, `title-slide`, `slide`, `focus-slide`, `blank-slide`, `bibliography-slide`, `table-of-contents`, `cols`, `framed`, `stress`, `pause`, `only`, `uncover` and the colour presets. See the [typslides documentation](https://typst.app/universe/package/typslides) for their parameters.

### Text

| Name                                                             | Description                                                      |
| ---------------------------------------------------------------- | ---------------------------------------------------------------- |
| `hl(body)`                                                       | Bold, accent colour.                                             |
| `hd(body)`                                                       | Bold, heading colour.                                            |
| `case(body)`                                                     | Medium weight, accent colour, for case names and docket numbers. |
| `mute(body)`                                                     | Muted colour.                                                    |
| `small(body, size: 13pt)`                                        | Small, muted note.                                               |
| `chip(body, fill: c.chip-bg, color: c.chip-text)`, `achip(body)` | Inline label; `achip` is the accent variant.                     |

### Verdicts

`yes(body)`, `no(body)`, `maybe(body)` and `partly(body)` put an icon before the text (check, cross, question mark, half-filled circle), so the meaning does not rely on colour alone.

### Blocks

| Name                                                                         | Description                                                                              |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `card(title: none, icon: none, fill: c.surface, stroke: c.border, body)`     | Bordered card with an optional title and icon name.                                      |
| `note(icon: none, body)`                                                     | Soft blue callout with an accent bar on the left.                                        |
| `banner(body, icon: none, size: 16pt)`                                       | Accent bar with white text, for summaries.                                               |
| `excerpt(body, source: none, size: 15pt)`                                    | Block quote with an optional source line.                                                |
| `step(title, body: none, fill: c.surface, stroke: c.border, head: c.accent)` | Full-height box for step diagrams in a grid row.                                         |
| `node(body, tone: "plain", width: 100%, height: auto, size: 15pt)`           | Centred box. `tone` is `"plain"`, `"soft"`, `"accent"` or `"outline"`.                   |
| `num-badge(n, radius: 13pt, tone: "accent")`                                 | Numbered circle aligned with the text line.                                              |
| `rarr`, `darr`                                                               | Right and down arrows for flow diagrams.                                                 |
| `timeline(items, date-size: 22pt, size: 14pt)`                               | Evenly spaced timeline; `items` is an array of `(date, title)` or `(date, title, note)`. |
| `tl-node(date, title, body, result: none, emph: false, height: 6.2cm)`       | Card-style timeline node, for laying out a timeline by hand in a grid.                   |
| `src(..items)`                                                               | Small source line in the bottom-left corner of a slide; items are joined with `；`.      |

### Icons and colours

`ic(name, color: c.accent, size: 1em)` draws an inline icon. Available names: `scale`, `school`, `court`, `user`, `users`, `file`, `check`, `x`, `yes`, `no`, `maybe`, `half`, `book`, `shield`, `speech`, `bulb`, `repair`, `cap`, `mail`, `bell`, `globe`, `search`, `lock`, `coin`, `alert`, `eye`, `eyeoff`, `target`, `pen`, `layers`, `arrow`, `down`, `link`, `vote`, `plus`, `ban`.

`c` is a dictionary of colours: `bg`, `surface`, `border`, `border-soft`, `text`, `heading`, `muted`, `subtle`, `accent`, `accent-hover`, `accent-soft`, `accent-light`, `accent-pale`, `dot-muted`, `chip-bg`, `chip-text`. Avoid defining your own `c` after `import *`.

A complete example is in [examples/minimal.typ](examples/minimal.typ).

## Local development

On Windows, `install.ps1` links the repository into Typst's local package directory with a junction, so edits take effect without copying:

```powershell
.\install.ps1                                                   # @local/barbet-slides:<version>
.\install.ps1 -PackageRoot "$env:APPDATA\typst\packages\preview"  # test the @preview import before release
```

## License

Copyright (C) 2026 Zhen Huang.

barbet-slides is licensed under the GNU General Public License v3.0 or later ([GPL-3.0-or-later](LICENSE)). It imports and re-exports [typslides](https://github.com/manjavacas/typslides), which is itself licensed under GPL-3.0-or-later; barbet-slides uses the same license to stay compatible with it.

The files in `template/`, which `typst init` copies into a new project, are licensed under [MIT-0](LICENSE-MIT-0) instead, so decks created from the template can be used and shared without restriction or attribution.
