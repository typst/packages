# Touying Ambrosia

[![Typst Universe](https://img.shields.io/badge/Universe-0.1.0-239DAE?logo=typst)](https://typst.app/universe/package/touying-ambrosia) [![Continuous integration status for Touying Ambrosia tests](https://github.com/inspiros/touying-ambrosia/actions/workflows/checks.yml/badge.svg?branch=master)](https://github.com/inspiros/touying-ambrosia/actions/workflows/checks.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/thumbnail.svg" alt="Touying Ambrosia: project logo beside light and dark slides with different layouts, palettes, and navigators" width="1000">

A configurable presentation theme for **Typst 0.15+** and **Touying 0.8.0**. Choose your slide geometry, colors, and branding independently, and keep the same authoring tools as your presentation changes.

Ambrosia takes its name from the food of the Greek gods: one theme, many flavors.

[Start from the template on Typst Universe](https://typst.app/universe/package/touying-ambrosia), or import the package in an existing presentation.

Read the **[online manual](https://inspiros.github.io/touying-ambrosia/v0.1.0/)**
for searchable guides with copyable code beside rendered slides, or use the
[user guide sources](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/README.md) and [illustrated PDF manual](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/manual.pdf) for a
guided tour and selected typed API references. The [manual source](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/manual.typ)
is editable in a Typst IDE; `python3 scripts/render-manual.py` refreshes the PDF.
Its slide snapshots are bundled, so ordinary compilation needs no preview-generation step.

[Browse the demo](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/demo.pdf) · [See linked slide previews](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/slide-previews.pdf)

[Browse the API](https://inspiros.github.io/touying-ambrosia/v0.1.0/api.html) · [Draft with an agent](https://inspiros.github.io/touying-ambrosia/v0.1.0/agent-skill.html)
using the optional Ambrosia skill.

## Start A Presentation

```typst
#import "@preview/touying-ambrosia:0.1.0": *
#show: ambrosia-theme.with(
  flavor: "minimal", palette: "ocean",
  config-info(title: [A Research Presentation], author: [Presenter]),
)

#title-slide()
#outline-slide()

= Introduction
== A Clear Result
#ambrosia-block(style: "poster", kind: "success", title: [Observation])[
  State one useful finding and explain its evidence.
  #pause
  Add a qualification when you are ready.
]

#ending-slide(title: [Questions?])[]
```

To initialize the complete starter locally:

```sh
typst init @preview/touying-ambrosia:0.1.0 my-slides
```

The core starts without a logo or watermark symbol. Supply your own branding, or use the complete [starter](template/template.typ), which opts into Ambrosia's project logo. It includes companion helpers and a bibliography: copy the whole template directory when starting a document.

## Choose A Flavor

`flavor` selects a coordinated composition: header/footer treatment, logo positions, title/ending geometry, spacing, and component defaults. It also suggests a navigator; an explicit `navigation` choice replaces that suggestion and reserves its own space. Every flavor accepts every palette. See [what a flavor defines](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/flavors.md).

The comparison below holds the content and `ocean` palette constant. Header geometry, navigation, logo placement, and footer treatment show the differences between layouts.

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/layouts.webp" width="1000" alt="Seven Ambrosia layouts presenting identical content in the ocean palette">

| Flavor | Character |
| --- | --- |
| `portico` | Metadata band, optional contrasting outline panel, flat surfaces, compact footer |
| `minimal` (default) | Quiet heading, inset logo, compact footer |
| `simple` | Spacious classic layout |
| `cambridge` | Current section/subsection band; level-three slide headings |
| `darmstadt` | Structured bands and miniature slide navigation |
| `dewdrop` | Lightweight miniature slide navigation |
| `stargazer` | Linked section tabs and an accent heading |

<details>
<summary>Compare Title Slides</summary>

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/covers.webp" width="1000" alt="The seven title-slide layouts using the same content and palette">

</details>

Most flavors use level-two headings (`==`) for slides; Cambridge uses level three (`===`). The low-level `slide(...)` helper works in every flavor. Build your own descriptor with `ambrosia-flavor(base: "minimal", name: "My Layout", ...)`; see [extensions](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/extensions.md).

## Choose A Title Layout

`title-layout` changes the opening independently of flavor: `"stacked"`, `"header"`,
`"split"`, `"plain"`, `"featured"`, or `"cover"`. The header preset puts all title logos in a reserved top
band. `title-logos` accepts a complete ordered list, including just one university
logo; no lab/institution roles are required. `title-slide(layout: ..., logos: ...)`
overrides one cover. Extend a preset with `ambrosia-title-layout` for typography,
alignment, logo sizing, and panel treatment; fully custom renderers remain available.
See the [guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/title-layouts.md) and [editable comparison](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/title-layouts.typ).

The featured preset gives the primary logo collection prominence and places partner
marks in a smaller row, as in the [demo](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/demo.typ). Cover supplies a
full-page color or optional photograph. Author cards automatically flow into
balanced rows; four authors use a two-by-two grid when space allows.

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/title-layouts.webp" width="1000" alt="Stacked, header, split, plain, featured, and cover title layouts with the same metadata and project logo">

## Choose An Ending Layout

`ending-layout` offers `"centered"`, `"plain"`, `"split"`, and `"cover"`.
The split preset pairs takeaways with a contact/logo card. Cover also accepts an
optional photograph. Override one closing with `ending-slide(layout: ...)` or
adjust a preset with `ambrosia-ending-layout`. Bodies retain native slide flow,
footnotes, citations, and reveals. See the [guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/ending-layouts.md) and
[editable example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/ending-layouts.typ).

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/ending-layouts.webp" width="1000" alt="Centered, plain, split, and cover ending layouts with the same closing message">

## Choose Or Compose A Palette

Twelve curated presets cover light paper, warm colors, and dark backgrounds. Colors are semantic roles, so blocks, headings, captions, navigation, and logos can adapt together.

Each card uses the same typography and structure, showing the page background, accent, body text, and alternate surface. Layout and palette choices combine independently.

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/palettes.webp" width="1000" alt="Twelve palette cards comparing light and dark backgrounds, text, accents, and surfaces">

| Mode | Presets |
| --- | --- |
| Light | `light`, `ocean`, `forest`, `sand`, `rose`, `slate` |
| Dark | `nocturne`, `nebula`, `midnight`, `evergreen`, `ember`, `graphite` |

To try a particular pair in your IDE, open [the gallery source](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/gallery.typ), edit `flavor` and `palette` near the top, and preview. Change `view` to inspect a cover, component, or the palette cards.

```typst
#let fieldwork = ambrosia-palette(
  base: "light", name: "Fieldwork", primary: rgb("2b6b51"),
)
#show: ambrosia-theme.with(palette: fieldwork)
#slide(title: [Our Colors])[#ambrosia-palette-showcase()]
```

Use `rotate: 35deg` for a relative OKLCH hue rotation, or override roles such as `background`, `surface`, and `foreground`. The showcase displays the actual current colors, including local slide overrides. See [palettes](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/palettes.md) and the [editable palette example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/palettes.typ).

## Components

The previews below render the actual package components. Each is reusable across every flavor and palette; the linked guides describe its parameters.

| Preview | Component And Purpose |
| --- | --- |
| <img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-blocks.webp" width="420" alt="Plain, framed, poster, outlined, stripe, and tabbed blocks"> | **Blocks** — `ambrosia-block` groups content with a title. `style` selects one of six geometries, including a centered title tab; `kind` selects a semantic accent. Supports nesting, pauses, optional shadows, and watermarks. `ambrosia-shadow` can decorate custom content too. [Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/utilities.md) · [Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/utilities.typ) |
| <img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-annotations.webp" width="420" alt="Badges, alert emphasis, and a source note"> | **Annotations** — `alert` emphasizes a phrase; `muted` and `subtle` reduce prominence while inheriting text size; `ambrosia-badge` adds a compact status label, optionally `shadowed: true`; `ambrosia-source-note` credits a local figure or dataset without a footnote. [Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/utilities.md) |
| <img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-citations.webp" width="420" alt="Matching native and footnote citation labels with a full reference"> | **Citations** — native `cite` / `@key`, `footcite`, and bibliography slides share compact author-year labels. Footcite places a full entry below the slide and respects animation visibility. [Guide](https://inspiros.github.io/touying-ambrosia/v0.1.0/citations.html) · [Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/utilities.typ) |
| <img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-people.webp" width="420" alt="Authors with linked symbolic affiliations and individual emails"> | **People** — structured authors, linked institutions, personal/shared emails, and configurable affiliation numbering. `ambrosia-affiliation` inserts a marker manually. [Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/people.md) · [Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/collaboration.typ) |
| <img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-palette-component.webp" width="420" alt="The current palette's actual color roles and hex codes"> | **Palette Showcase** — `ambrosia-palette-showcase` displays the actual colors in use, including institution accents and per-slide overrides. Select roles, columns, labels, and hex codes. [Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/palettes.md) · [Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/palettes.typ) |
| <img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-navigation-buttons.webp" width="420" alt="Transparent first, previous, section, outline, next, and last controls"> | **Navigation Buttons** — `ambrosia-navigation-buttons` links to logical slides, sections, and outlines. Place it manually or enable the automatic footer controls. Unavailable destinations are dimmed. [Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/navigation.md) · [Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/navigation.typ) |
| <img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-slide-preview.webp" width="420" alt="Framed thumbnails linking backwards and forwards to other slides"> | **Slide Previews** — `ambrosia-slide-preview` makes clickable minislides, including a chosen animation frame. An optional exporter creates exact SVG snapshots; placeholders work before generation. [Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/slide-previews.md) · [Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/slide-previews.typ) |
| <img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-roadmap.webp" width="420" alt="A research roadmap with phases, task tracks, and milestone markers"> | **Roadmaps** — `ambrosia-roadmap` presents project plans with concurrent tracks, optional detail drawers, current time, and milestones. Colors follow the palette; dense plans fit within a height budget. [Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/roadmap.md) · [Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/roadmap.typ) |

```typst
#ambrosia-block(style: "stripe", kind: "info", title: [Evidence])[
  Keep one idea together.
  #ambrosia-badge(kind: "success", shadowed: true)[Validated]
]
```

Native block code receives a palette surface; block quotations receive an accent
stripe. Inline forms retain their native layout. Use `code-style: "plain"` or
`quote-style: "plain"` to disable either treatment. See the
[text/code example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/text-and-code.typ) and [utility guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/utilities.md).

The default text size is **18pt**, with tables at `0.85em`, captions at `0.8em`, and footnotes at `0.65em`. Metadata, outlines, and footer labels fit their available space. Cambridge and Darmstadt place their logo in a reserved footer row; `footer-logo: false` hides it and restores that space. `footer-logo-height` controls its size. See [metadata and footer controls](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/people.md).

## Keep Citation Identities Stable

Native `#cite(<knuth84>)`, shorthand `@knuth84`, `footcite`, and `bibliography-slide` use matching compact labels such as **[Knuth1984a]** by default. Typst's own CSL engine handles disambiguation and bibliography links; no external bibliography package is needed.

```typst
Normal @knuth84. A footnote reference #footcite(<knuth84>).
#bibliography-slide("references.bib")
```

Footcite includes a full reference at the foot of its first logical slide and respects animation visibility. It also supports local, presentation-wide numeric, key, and custom markers. Multiple bibliographies can use explicit scopes when keys overlap.

For conventional citation formatting, set `cite-marker: "native"` and `bibliography-marker: "native"`, then choose your bibliography style. Explicit `cite(..., style: "apa")` remains available. See [citation controls](https://inspiros.github.io/touying-ambrosia/v0.1.0/citations.html).

## Authors And Branding

Structured authors link to institutions through configurable superscripts and can have individual email addresses. Set `affiliation-numbering: "*"` for native footnote symbols, `"1"` for numbers, or supply a numbering function. Shared emails, short footer names, and repeated covers are supported. See [metadata](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/people.md).

`primary-logos` accepts one or more marks to repeat in the flavor's ordinary
branding positions; `logos` holds title partners. Choose `title-logo-distribution: "grouped"` for primary marks on the left and partners on the right of horizontal
cover rows. The neutral default remains `"equal"`. See [branding](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/branding.md)
and the [editable example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/branding.typ).

The starter and gallery use Ambrosia's own logo without partner logos. The [full demo](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/demo.typ) and [collaboration example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/collaboration.typ) use fictional Kyklo Laboratory branding to show multi-institution layouts. Those institutions are illustrative, not affiliations of the package.

You can create an institution wrapper with its own logos, color presets, and flavors while reusing all core behavior. See [the extension guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/extensions.md) and the [GREYC wrapper](https://github.com/inspiros/touying-greyc-ambrosia).

## Slides And Navigation

Choose a slide helper to match the purpose of the content:

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/slide-types.webp" width="1000" alt="Title, outline, section, focus, image, and ending slide examples">

| Helper | Purpose |
| --- | --- |
| `title-slide` | Fitted title, authors, affiliations, and branding |
| `outline-slide` | A fitted, linked list, section cards, or connected path |
| `section-slide` | A deliberate transition to a new part of the talk |
| `focus-slide` | One statement with minimal distraction |
| `image-slide` | Full-page imagery with optional caption and credit |
| `ending-slide` | Closing message and contact details |
| `bibliography-slide` | References with consistent citation identities |
| `backup-slide`, `appendix` | Supporting material with appropriate slide counts |

Automatic section dividers focus on the current branch of the outline. `#show: appendix` keeps supporting slides visible while freezing the main slide total. See [presentation patterns](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/presentation-patterns.md) and [slide helper options](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/utilities.md).

### Image Captions

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/image-captions.webp" width="1000" alt="Bottom and top caption bands, plus top right and bottom left caption cards on the same photograph">

`image-slide` accepts native `caption-position` alignments, plus `caption-width`
and `caption-margin` for inset cards. Panel and text colors are configurable;
captions are measured to fit. [Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/image-slides.md) · [Editable Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/image-slides.typ)

### Agenda Styles

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/agendas.webp" width="1000" alt="List, cards, and connected path agendas, each shown as an overview and a focused section transition">

Use `agenda-style: "cards"` or `"path"` on the theme; `style:` on
`outline-slide` or `new-section-slide` overrides it locally. `"list"` remains
the compact default. Cards suit short talks and fall back to the list for a long
agenda. All styles preserve links, logical slide numbers, measured fitting,
section introductions, and main/appendix scope.
Agenda text defaults to `1.15em`; set `agenda-text-size` on the theme or
`text-size` on one helper. Chapter summaries use a quiet accent panel; chapters
without summary content add no panel or extra summary gap.
Use `outline-fill: repeat[.]` on the theme or `outline-slide(fill: repeat[.])` for dotted leaders.

[Guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/agendas.md) · [Editable Example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/agendas.typ)

## Navigation

Navigation can be selected independently of flavor. Existing presets retain their defaults; `none` releases structural navigation space.

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/navigation.webp" width="1000" alt="Tabs, dots, context, tree strips, two panes, breadcrumbs, section segments, and left/right sidebars using one layout and palette">

```typst
#show: ambrosia-theme.with(
  flavor: "minimal", navigation: "sidebar",
  navigation-side: "right", navigation-width: 9em, navigation-depth: 2,
  navigation-buttons: true, section-progress: true,
)
```

Header choices are `"tabs"`, `"dots"`, `"context"`, `"tree"` (a stacked current path), and `"panes"` (section/subsection selectors). `"breadcrumbs"` reuses the title slot; `"sidebar"` reserves a bounded outline column. `"segments"` puts linked section segments and progress within each section in a reserved footer row. Long outlines and segmented rails window around the current branch. Global progress, section progress, and transparent buttons remain independent. Main/appendix context and logical-slide counting are shared; animation frames do not inflate progress. See [navigation](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/navigation.md), its [editable example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/navigation.typ).

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/navigation-tree.webp" width="1000" alt="Three-level tree navigation in Cambridge: talk title, section, and subsection in thin linked strips above the slide title">

Tree keeps the current path visible in two or three rows. The slide title stays
below it; `navigation-depth: 1` limits Cambridge to the talk/section pair.

## Extra: Presenter Notes

Presenter notes are a Touying feature, re-exported by Ambrosia. Use a compatible
presenter viewer or editor; pdfpc is one option. Split-page PDFs need a viewer
that separates audience slides from the notes region; ordinary viewers display
both. See the [optional workflow guide](https://inspiros.github.io/touying-ambrosia/v0.1.0/speaker-notes.html) and
[editable example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/speaker-notes.typ), including an optional Typst bundle
export that writes both files together.

## Sharing The Theme

`#ambrosia-credit-card()` is an optional, palette-aware card with the package
logo, repository link, and a bundled QR code. It works in normal slides and
endings; `qr: false` hides the code. Nothing is inserted automatically.

<img src="https://raw.githubusercontent.com/inspiros/touying-ambrosia/v0.1.0/assets/gallery/component-credits.webp" width="650" alt="Optional Touying Ambrosia credit card with a repository QR code">

The repository link provides source, examples, and current installation
instructions independently of the installed package version. The QRs are static
SVGs included in the package, so online users need no generator. See
[credit options](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/credits.md) and the [credits/acknowledgements example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/credits.typ).

## Linked Slide Previews

`ambrosia-slide-preview` places a clickable framed thumbnail of another slide. It supports forward/backward targets and selected animation frames. Exact snapshots use exported SVGs; placeholders keep the source editable before generation. A small optional Python/Typst script builds the requested previews without replaying live counters or citations in the host slide. See [the guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/slide-previews.md) and [example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/slide-previews.typ).

No clone or PyPI installation is needed: [download the single helper file](https://github.com/inspiros/touying-ambrosia/raw/v0.1.0/scripts/render-slide-previews.py).
It runs locally with Python and the Typst CLI. Browser-only projects can use
uploaded slide images; exact snapshots require a local export somewhere and
uploading the resulting SVGs/manifest. The Universe import cannot run Python.

## Try The Examples In Your IDE

Open an example in Tinymist or another Typst IDE and start its preview. Its `@preview` import loads the published package. For checkout changes, follow the [development setup](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/CONTRIBUTING.md). Change the defaults near the top of the source to compare layouts and colors; no command-line input is required. Optional `--input` values remain available for batch rendering.

| Source | Demonstrates |
| --- | --- |
| [gallery](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/gallery.typ) | Editable layout, palette, component, and slide-type comparisons |
| [sample](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/sample.typ) | Small project-branded presentation |
| [neutral](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/neutral.typ) | Completely unbranded starting point |
| [demo](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/demo.typ) | Fictional lab branding, blocks, citations, palette showcase, image slide, appendix |
| [utilities](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/utilities.typ) | Container styles, badge shadows, native/footnote citations, slide patterns |
| [palettes](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/palettes.typ) | Editable primary colors and hue rotation |
| [collaboration](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/collaboration.typ) | Multiple authors, affiliations, emails, and short metadata |
| [text and code](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/text-and-code.typ) | Text hierarchy, native code panels, and quotations with attribution |
| [branding](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/branding.typ) | Multiple repeated primary marks and optional left/right partner groups |
| [title layouts](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/title-layouts.typ) | Independent cover presets, header-only logos, equal partners, and local overrides |
| [ending layouts](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/ending-layouts.typ) | Closing messages, takeaways/contact cards, photograph covers, and local overrides |
| [credits](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/credits.typ) | Optional package credits, static QR codes, and acknowledgement composition |
| [agendas](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/agendas.typ) | Overview/divider styles, shared fitting, current-section focus, and local overrides |
| [speaker notes](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/speaker-notes.typ) | Private pdfpc sidecars, split/notes-only output, and optional bundle export |
| [navigation](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/navigation.typ) | Configurable header/sidebar navigation, breadcrumbs, buttons, and section progress |
| [slide-previews](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/slide-previews.typ) | Clickable slide thumbnails, forward links, and selected animation frames |
| [image captions](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/image-slides.typ) | Native band/corner placement, widths, margins, and light panels |
| [roadmap](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/roadmap.typ) | Project/event timelines, custom units, fractional durations, and detail drawers |

Use the scoped API (`ambrosia.block`, `ambrosia.badge`, `ambrosia.navigation-buttons`, etc.) when combining packages. See the complete [public API](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/api.md).

## Contributing

For checkout setup, tests, artwork generation, and release preparation, see
[CONTRIBUTING.md](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/CONTRIBUTING.md).

## License

MIT licensed; see [LICENSE](LICENSE). The modified shadow renderer derives from
[shadowed 0.3.0](https://github.com/T1mVo/shadowed), by Tim Voßhenrich; its
[original MIT notice](src/vendor/LICENSE-shadowed) is retained.
