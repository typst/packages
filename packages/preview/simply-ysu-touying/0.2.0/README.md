# Touying Slide Theme for Yanshan University

[[中文]](https://github.com/bahayonghang/simply-ysu-touying/blob/4bd7c6513552e5e74b40c7ad1332a3227c9803ef/README.zh.md)

A Yanshan University slide theme for [Touying](https://touying-typ.github.io/touying/zh/) and Typst. Version 0.2.0 follows the layout of a doctoral defense deck: a navy palette, a breadcrumb headline that carries the slide's conclusion, chapter openers, a footer chapter navigation, and a component library for problem–method–conclusion pages. Speaker notes can be compiled into separate notes pages for presenter tools.

| Cover | Chapter opener | Content slide |
| --- | --- | --- |
| ![Cover slide](https://raw.githubusercontent.com/bahayonghang/simply-ysu-touying/4bd7c6513552e5e74b40c7ad1332a3227c9803ef/docs/screenshots/beamer-ysu-cover.png) | ![Chapter opener](https://raw.githubusercontent.com/bahayonghang/simply-ysu-touying/4bd7c6513552e5e74b40c7ad1332a3227c9803ef/docs/screenshots/beamer-ysu-opener.png) | ![Content slide](https://raw.githubusercontent.com/bahayonghang/simply-ysu-touying/4bd7c6513552e5e74b40c7ad1332a3227c9803ef/docs/screenshots/beamer-ysu-content.png) |

## Requirements

- Typst `0.15.0` or later
- `@preview/touying:0.8.0` (imported by the package)

## Quick start

```bash
typst init @preview/simply-ysu-touying:0.2.0 my-slides
cd my-slides
typst compile main.typ
```

A minimal deck:

```typ
#import "@preview/simply-ysu-touying:0.2.0": *

#show: ysu-theme.with(
  aspect-ratio: "16-9",                 // or "4-3"
  nav-labels: ("Background", "Method", "Summary"),
  config-info(
    title: [Presentation Title],
    author: [Your Name],
    supervisor: [Supervisor],
    subject: [Discipline],
    school: [School],
    date: datetime.today(),
    stage: [学术汇报],
    stage-en: [Academic Presentation],
  ),
)

#title-slide()
#outline-slide()

= Background
#chapter-opener(question: [What is the core question of this chapter?], keywords: ([one], [two]))

== 1.1 Motivation
#sub[1.1.1 Optional subsection]
#takeaway[One sentence with the conclusion of this slide; it becomes the headline]

Slide content.

#ending-slide()
```

To work from a cloned repository, import the theme file instead:

```typ
#import "@preview/touying:0.8.0": *
#import "themes/ysu-beamer.typ": *
```

The bundled demo shows every component:

```bash
typst compile --root . examples/beamer-ysu.typ
typst compile --root . --input ratio=4-3 examples/beamer-ysu.typ   # 4:3 pages
```

## Structure pages

| Call | Page |
| --- | --- |
| `title-slide(research-line: ((no:, icon:, label:), ...), note:)` | Cover: white left column with the title, navy right column with the stage tab and research lines |
| `outline-slide(title:, groups: ((from:, to:, tags:, icons:),), note:)` | Contents: one row per level-1 heading; `groups` highlights consecutive core chapters |
| `= Chapter` + `chapter-opener(question:, keywords:, icon:, outline:, bridge:)` | Chapter opener: number, title, question, keywords, the chapter's level-2 headings, and a bridge line |
| `== Slide title` | Content slide; the breadcrumb shows the chapter, the level-2 title and `sub` |
| `sub[...]` / `takeaway[...]` | Breadcrumb subsection / headline sentence of the current slide |
| `slide(composer: (1fr, 1fr))[...][...]` | Free slide with Touying columns; `#pause` works |
| `ending-slide(title:, kicker:, recap: ((title:, chapter:, icon:, body:, tags:), ...), note:)` | Closing page; with `recap` it shows contribution cards |

`ysu-theme` parameters: `aspect-ratio` (`"16-9"` or `"4-3"`), `align` (vertical alignment of slide bodies), `nav-labels` and `nav-full-labels` (footer and opener chapter labels; default: the level-1 headings), `font: (latin:, cjk:)`, `notes` (notes pages, see below).

## Components

| Component | Use |
| --- | --- |
| `hl[...]`, `key[...]` | Bold navy term; bold red key result |
| `tag`, `pill`, `tab-pill`, `edge-label`, `icon-disc` | Labels, capsules and icon discs |
| `conclude(label:, red-label:, pill:)`, `base-bar`, `section-bar` | Full-width conclusion bars and section heads |
| `title-box(title:, icon:, aside:)`, `tblock(title:)` | Card with a navy head (`tblock` is kept as an alias) |
| `group-box(label:, red:)`, `sub-box`, `dash-box`, `label-row` | Grouped points, e.g. problems and methods |
| `block-arrow[...]` | Block arrow with a label between groups |
| `red-frame(label:, center:)` | Red-framed purpose or constraint line |
| `card`, `side-card`, `paper-box`, `points` | Cards, labelled side cards, paper list, numbered points |
| `kpi(label:, value:, basis:, key:)` | Key number with a navy top rule |
| `figure-box(caption:)`, `fig-caption`, `eq-block(number:, note:)`, `eq-number` | Figures and equations in thesis style |
| `reading-card(title:)`, `screen-frame(title:)` | Reading card; night window for field screenshots |
| `result-table(header:, rows:, mark:)` | Results table with a navy header and marked rows |

Colors and gradients (`ysu-navy`, `ysu-red`, `ysu-tint`, `grad-key`, …), `seal()`, `wordmark()` and `logo()` are exported as well.

## Speaker notes

Write `#note[...]` anywhere in a slide; several notes on one slide join as paragraphs. The cover, contents and closing page take a `note:` argument; a chapter opener's note goes right after `= Chapter`.

```typ
#show: ysu-theme.with(
  notes: sys.inputs.at("notes", default: "off") == "on",
  config-info(
    title: [Presentation Title],
    author: [Your Name],
  ),
)

#title-slide(note: [Good morning, my topic is …])

== 1.1 Motivation
#note[First paragraph of the script.

Second paragraph.]
```

```bash
typst compile --root . slides.typ                              # projector version
typst compile --root . --input notes=on slides.typ notes.pdf   # one notes page after each slide
```

Notes pages are as wide as the slide (16 cm × 13.5 cm for 16:9), dark, 18 pt. PDF page labels are `N` for slides and `notes:N` for notes pages, which FerroStage and pympress use to pair them; `examples/check-page-labels.py notes.pdf --expect-notes` checks them. Notes also go to pdfpc. Export the script as JSON with `typst query --root . slides.typ "<ysu-note>" --field value`. Pages split with `#pause` get their notes page after the last subpage only.

## Fonts

Slides use sans-serif. CJK fallback: Source Han Sans → Noto Sans SC → Microsoft YaHei. Latin and digits: Arial. Change it with `font: (latin: (...), cjk: (...))`. If Source Sans 3 is installed, put it first in `latin`.

## Migrating from 0.1.x

0.2.0 is a breaking release.

- Removed `ysu-theme` parameters: `progress-bar`, `watermark`, `footer-columns`, `footer-a` … `footer-d`. The footer now shows author · stage, the chapter navigation (`nav-labels`) and the page number.
- Pages are 16 cm × 9 cm (12 cm × 9 cm for 4:3) instead of `presentation-16-9`; the default body alignment is `horizon`.
- `config-info` gains `supervisor`, `subject`, `school`, `stage` and `stage-en`; the cover uses them, and `institution`, `subtitle` and `short-title` are no longer shown.
- `title-slide(extra:)` is replaced by `research-line:`; `ending-slide` takes `title:`, `kicker:` and `recap:` instead of a body-only page.
- New page markers `sub[...]` and `takeaway[...]`, new `chapter-opener(...)`, and the component library above; `tblock` remains as an alias of `title-box`.
- The palette changes from YSU blue (`#2B69C1`) to navy `#1F296A` with red `#B42318` accents; fonts change from KaiTi / Times New Roman to Source Han Sans / Arial.
- `@preview/cuti` is no longer used: the theme relies on real bold weights instead of fake bold.

## Included files

- `lib.typ`: package entrypoint
- `themes/ysu-beamer.typ`: theme, structure pages and notes
- `themes/components.typ`: component library
- `themes/tokens.typ`: colors, gradients, fonts and logos
- `themes/assets/`: YSU visual assets
- `template/main.typ`: template used by `typst init`

## Licensing and Assets

- Theme and library source files are released under the MIT License.
- `LICENSE` preserves both the upstream QuadnucYard notice and the current Geekyhang notice because this repository adapts upstream work while shipping new YSU-specific source files under the same MIT terms.
- The starter content in `template/main.typ` is additionally available under MIT No Attribution; see [`LICENSE-MIT-0.txt`](./LICENSE-MIT-0.txt).
- University-branded assets in `themes/assets/ysu-*` are not covered by the SPDX license expression in `typst.toml`; see [ASSETS.md](https://github.com/bahayonghang/simply-ysu-touying/blob/4bd7c6513552e5e74b40c7ad1332a3227c9803ef/ASSETS.md) for the file inventory, source links, transformation notes, and reviewer guidance.

## License

Licensed under the [MIT License](LICENSE).
