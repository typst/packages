# Shuimu-touying-zen: Minimalist Tsinghua Theme for Touying

English | [简体中文](README.zh.md)

Rebuilt from the minimalist theme of [THU-PPT-Theme](https://github.com/atomiechen/THU-PPT-Theme). The original deck is 16:9 at 960 × 540 pt and uses Tsinghua purple `#660874` (see the [color specification](https://vi.tsinghua.edu.cn/gk/xxbz/scgf.htm)), a grey cover title box, a vertical rule on the outline slides, and horizontal bars at the top and bottom of content slides.

## Files

- `theme.typ`: the reusable theme and slide functions.
- `assets/`: department logos, the campus silhouette, and their `-ink` variants (SVG, some also PDF). Keep this whole directory when you copy the template.
- `tools/binarize.py`: an optional binarization script for turning bitmaps into pure black-and-white assets.
- `gallery/`: example pages and sources for generating the svgs.

## Getting started

Edit `main.typ` directly. In VS Code you can use the existing Tinymist preview and PDF export; you can also run the following in this directory:

```powershell
typst compile main.typ main.pdf
typst watch main.typ main.pdf
```

This version was compiled and verified locally with Tinymist 0.15.6, with the dependency pinned to `@preview/touying:0.7.4`. The first build on a new machine downloads Touying and its dependencies. By default the theme uses `SimHei` for Chinese and `Arial` for English, with math in the separate `New Computer Modern Math`; the footer subtitle uses `STXinwei` for Chinese and `Arial` for English. The bundled `main.typ` overrides `font` with `("Arial", "Noto Sans SC")` and leaves `subtitle-font` unchanged. On another machine, make sure these fonts are available, or pass substitutes through the corresponding options.

Minimal example:

```typst
#import "@preview/touying:0.7.4": *
#import "@preview/shuimu-touying-zen:0.1.0": *

#show: group-meeting-theme.with(
  config-info(
    title: [Talk title],
    subtitle: [PhD forum],
    author: [Your name],
    institution: [Department of Physics, Tsinghua University],
    date: datetime.today(),
  ),
)

#title-slide()
#outline-slide()

= Background
== Research question

- First question
- Second question

= This week's progress
== Main results

Your text here.

#closing-slide()
```

`= Heading` defines a section and `== Heading` starts a new slide. The `Part 01` / `Part 02` label in the top-left corner follows the current section automatically. Before every section, a highlighted outline is shown once: the row of the current section (square marker included) is Tsinghua purple and the other rows are grey. The cover and outline slides count towards the logical page number but do not display it. Several animation steps share a single page number.

## Theme options

Every option below goes into `group-meeting-theme.with(...)`:

| Option | Default | Purpose |
| --- | --- | --- |
| `primary` | `tsinghua-purple` | Color of the bars, the vertical rule, headings, and emphasized text; also drives the recoloring of preset SVG logos |
| `font` | `("Arial", "SimHei")` | English and Chinese fonts |
| `math-font` | `"New Computer Modern Math"` | Math font, independent of the global font |
| `subtitle-font` | `("Arial", "STXinwei")` | English and Chinese fonts of the footer subtitle |
| `body-size` | `22pt` | Body text size |
| `title-size` | `28pt` | Size of the title at the top of a content slide; long titles are shrunk as needed |
| `section-slides` | `true` | Insert the highlighted outline of the current section automatically; `false` disables it |
| `outline-v-spacing` | `auto` | Spacing between all outline entries; distributed evenly by default, can be set to a length such as `32pt` |
| `show-contents` | `true` | Whether to show outlines; `false` hides them |
| `part-prefix` | `"Part"` | Prefix of the section number in the top-left corner |
| `footer` | `auto` | Shows the date and subtitle by default; custom content overrides it and `none` hides it |
| `show-page-number` | `true` | Whether to show the page number on content slides |
| `cover-logo-name` | `"university-logo.svg"` | Preset file in `assets/` used as the cover/outline logo |
| `header-logo-name` | `"university-logo.svg"` | Preset file in `assets/` used as the logo at the top right of content slides |
| `cover-logo` | `none` | Sets the cover/outline logo directly; takes precedence over `cover-logo-name` |
| `header-logo` | `none` | Sets the header logo directly; takes precedence over `header-logo-name` |
| `campus` | `none` | Sets the silhouette in the bottom-right corner directly; when unset (`none`) the preset `campus.svg` is loaded instead |

For example, to change the bar background color and the cover logo:

```typst
#show: group-meeting-theme.with(
  primary: rgb("194f6b"),
  cover-logo-name: "phys-logo.svg",
  config-info(title: [Talk title]),
)
```

### Logos and silhouette

A logo comes from one of **two sources**. The `-name` options pick a preset, while `cover-logo` / `header-logo` / `campus` provide custom content:

1. **Repository presets**: `cover-logo-name` and `header-logo-name` take a filename from `assets/`, both defaulting to `"university-logo.svg"`; when `campus` is left unset, `assets/campus.svg` is used.
2. **Custom content**: `cover-logo`, `header-logo`, and `campus` accept `image(...)`, a path string, or arbitrary Typst content. Anything other than `none` **overrides** the corresponding preset.

When reading a preset SVG, the theme replaces the Tsinghua purple placeholder `#660874` with the primary color:

| Position | Replacement rule |
| --- | --- |
| `cover-logo-name` | Only `#660874` → `primary`; the logo follows the primary color |
| `header-logo-name` | **Every** fill → white (the top of a content slide is a colored bar, so the logo is knocked out) |
| `campus` (preset) | Only `#660874` → `primary` |

Measured with `primary: blue` the cover logo renders as `#005795`, and with `primary: red` as `#D62728`.

**An image passed in directly is never recolored** and keeps its own colors. So:

- To let a logo follow the primary color, use a `-name` preset (or pass an SVG that already uses that color).
- To keep a logo in its original colors, pass it directly: `cover-logo: image("assets/university-logo.svg")`.

Available presets:

| Preset | Description |
| --- | --- |
| `university-logo.svg` | Tsinghua University emblem (default) |
| `phys-logo.svg` | Department of Physics |
| `EE-logo.svg` | Department of Electronic Engineering |
| `energy-power-logo.svg` | Department of Energy and Power Engineering |
| `arts-logo.svg` | Academy of Arts and Design |
| `journalism-logo.svg` | School of Journalism and Communication |
| `campus.svg` | Campus silhouette (the default silhouette) |

A path string is opened as an image automatically: `cover-logo: "assets/my-logo.png"` is the same as `cover-logo: image("assets/my-logo.png")`.

**On hiding**: passing `none` to these three options means "use the preset/default", **not** "hide". To really hide one, pass a fully transparent image (such as a 1×1 transparent PNG). Do not pass empty content `[]`, which makes `scale-to-fit` fail with a division by zero.

Besides the primary color `tsinghua-purple` (Tsinghua purple `#660874`, the default of `primary`), the theme also exports the following color variables, which can be used directly in `text`, lines, or charts:

```typst
#text(tsinghua-magenta)[Magenta]  // #D93379, usable as an alternative primary
#text(red)[Red]                   // #D62728
#text(blue)[Blue]                 // #005795
#text(green)[Green]               // #1A5F1A
#text(orange)[Orange]             // #C45C00
```

## Slides and content

### Cover

```typst
// Title, author, and institution are centered; date and subtitle go to the bottom left.
#title-slide()

// Or set the title, logo, and extra content of this slide individually.
// The logo is passed as an image and is not recolored (unlike the theme's cover-logo-name).
#title-slide(title: [Title], subtitle: [PhD forum talk],
  logo: image("assets/phys-logo.svg"), extra: [Group name])
```

Keep the cover title within about two lines; the title box has a fixed size, so a long title has to be wrapped manually or trimmed.

By default `config-info.subtitle` appears only after the date in the footer, for example `2026-09-07    PhD forum talk`. The date and the subtitle (Chinese and English alike) are both 18pt, separated by 18pt. The cover footer is Tsinghua purple: its left edge aligns with the left edge of the title box (47.18pt), and the bottom edge of its text aligns with the bottom edge of the campus image in the bottom-right corner (515.25pt); the closing slide reuses this position. The content footer is white and shares a baseline with the page number inside the bottom bar, vertically centered. The overview outline and the highlighted section outlines show no footer. If you want to keep the side-by-side title of the original deck, you can still call `#title-slide(inline-subtitle: true)` explicitly.

### Outline

`#outline-slide()` collects all level-1 headings automatically and builds a clickable table of contents. The text block is centered on the vertical midline of the whole slide (270pt), with equal space above and below, clear of the top title, the logo, and the campus silhouette at the bottom. Without explicit spacing, several rows fill the entire available text area evenly (120–420pt); with only one section, that row sits in the middle of the slide. You can also pass the entries and the vertical spacing manually:

```typst
#outline-slide(title: [Contents], v-spacing: 32pt, items: (
  [Background],
  [This week's progress],
  [Next steps],
))
```

The default outline suits roughly 3–5 sections; when entries are too long or too many, split them across several slides and pass `items` to each.

A slide-level `v-spacing` overrides the global `outline-v-spacing`; when both are `auto`, the whitespace is distributed automatically. A manual spacing is the net gap between neighbouring entries, in which case the whole group of entries is centered vertically instead of being laid out from the top. `active: 2` highlights row 2 manually, `active: auto` highlights the current section, and `active: none` gives an overview outline without highlighting. The automatic section outlines need no manual call.

### Content slides and two columns

```typst
// A level-2 heading: the section number is read automatically.
== Experimental results

Your text here.

// Create a slide explicitly and set its top text.
#slide(title: [Experimental results], part: [Part 02])[
  Your text here.
]

// The column ratio is adjustable.
#slide(title: [Theoretical model], composer: (1fr, 1fr))[
  Left column content.
][
  $ E = m c^2 $
]
```

Content slides accept Typst lists, math, `image`, `table`, `figure`, and so on. To keep one slide per page, the theme disables automatic page breaking on overflow and enables Touying's content overflow warning. When a warning appears, reduce the content or split the slide manually.

### Animations and handouts

```typst
== Step by step

First step.

#pause

Second step.
```

To export a handout, add `config-common(handout: true)` to the theme options; each slide then keeps only its final step. `#meanwhile`, speaker notes, and so on keep using the interfaces provided by Touying.

### Closing slide

```typst
#closing-slide(body: [Thank you!], subtitle: [Questions welcome])
```

## Assets and credits

The logos in `assets/` use Tsinghua purple `#660874` as a placeholder that the theme replaces (see "Logos and silhouette" above). The cover box, the vertical rule of the outline, and the bars of content slides are all native Typst shapes, so text, tables, and math stay editable.

The logos are taken from the [Tsinghua University visual identity guidelines](https://vi.tsinghua.edu.cn/gk/xxbz/xh.htm) and from publicly available department material; the `campus` silhouette comes from a rendering of the original deck. For Typst compatibility some SVGs had a background rectangle removed, the transform of a clipping group moved onto the paths, and the canvas margin tightened. Rights to the logos and images remain with their owners and are unaffected by the conversion into a template.

Font rendering, paragraph spacing, and the SVG logos differ slightly from the original PPT; this template keeps the main geometry and design of the original.

For the Touying API, see the [official documentation](https://touying-typ.github.io/docs/intro) and the [0.7.4 package page](https://typst.app/universe/package/touying/).

## Preview
![Cover page](gallery/example-page-01.png)
![An automatically generated TOC](gallery/example-page-02.png)
![ToC before each section](gallery/example-page-03.png)
![Main text](gallery/example-page-05.png)
![Acknowledgment page](gallery/example-page-10.png)
