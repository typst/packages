# Pelermaid

Mermaid diagrams for Typst, rendered with [Pele](https://github.com/obsidianmd/pele).

Source: <https://github.com/mohamedamrnady/typst-pelermaid>

Pelermaid is an independent wrapper, not an official Obsidian, Pele, or Mermaid package.

Pele has its own layout engine and visual style. Pelermaid gives you Mermaid syntax inside
Typst; it does not use Mermaid.js and does not promise pixel-identical output to Mermaid.js.
Text measures, spacing, wrapping, and edge routing are Pele's. The bundled Pele release
targets Mermaid 12 syntax.

## Install

Use the published package with Typst 0.15 or newer:

```typ
#import "@preview/pelermaid:0.2.0": mermaid, mermaid-svg, mermaid-result, mermaid-figure, show-mermaid-blocks
```

Typst downloads the package and its dependencies on first use.

## Usage

```typ
#import "@preview/pelermaid:0.2.0": mermaid, mermaid-svg, mermaid-result, mermaid-figure, show-mermaid-blocks

#mermaid("
flowchart TD
    A((Start)) --> B[/Input score/]
    B --> C{Score >= 5?}
    C -->|Yes| D[/Output Pass/]
    C -->|No| E[/Output Fail/]
    D --> F((End))
    E --> F
", width: 60%)
```

`mermaid` embeds an image. `mermaid-svg` returns the sanitized SVG text. `mermaid-result`
returns a dictionary with `ok`, `svg`, `width`, `height`, `type`, and error fields.
`mermaid-figure` wraps the image in a Typst `figure`. `show-mermaid-blocks` renders
`mermaid` raw blocks.

Runnable examples are in [`examples/`](examples/). [`sample.typ`](sample.typ) is a
self-contained tour that imports the extension. The full diagram gallery is attached to each
release as
[`corpus.pdf`](https://github.com/mohamedamrnady/typst-pelermaid/releases/latest/download/corpus.pdf).

### Responsive width

Pele reflows diagrams for the available width. Typst's layout context is enabled by
default and passes the resolved width to Pele as `maxWidth`:

```typ
#let source = "flowchart LR\n    A[Start] --> B[Stop]"
#mermaid(source, width: 100%)
```

Wide diagrams reflow where Pele supports it and are scaled down when they reach Pele's
minimum width. Absolute widths already resolve without consulting the page, so they skip
the layout pass. For fixed natural-size images, or when compile time and memory matter
more than reflow, disable the layout pass explicitly:

```typ
#let source = "flowchart LR\n    A[Start] --> B[Stop]"
#mermaid(source, width: 60%, document-context: false)
```

Pelermaid preserves the direction written in the diagram: a `flowchart LR` stays
left-to-right even when it is wider than the page. Pele's `autoDirection` can flip a wide
left-to-right or right-to-left diagram to top-down when `maxWidth` is below
`directionBreakpoint` (640 px), which changes the diagram's meaning, so Pelermaid disables it
by default. Enable it when fitting the page matters more than the requested direction:

```typ
#let source = "flowchart LR\n    A[Start] --> B[Stop]"
#mermaid(source, options: (auto-direction: true))
```

### Typography and document context

With `document-context: true` (the default), Pelermaid reads the surrounding document:

| Typst value | Used for |
| --- | --- |
| `text.font` | Diagram font family |
| `text.size` | Diagram font size |
| `text.fill` | Diagram foreground |
| `page.fill` | Diagram background; `auto`/`none` gives a transparent canvas |

This means diagrams follow a `#set text(...)` or `#set page(fill: ...)` without extra
configuration. Any explicit `font`, `font-size`, `foreground`, `background`, or `theme`
value wins over the document value. `document-context: false` uses the preset font stacks
and colours only.

Fonts are also used for measurement: the document family is passed to Pele as
`fontFamily`, so labels are measured in the stack that is drawn. `text.font` entries can be
dictionaries with `covers`; only their `name` is copied into CSS, and a generic fallback is
appended when the stack does not already end in one.

The preset stacks are:

```text
font:      'DejaVu Sans', 'Liberation Sans', Arial, sans-serif
font-mono: 'DejaVu Sans Mono', 'Liberation Mono', Consolas, monospace
```

These are broad fallbacks, not a requirement. At minimum, provide a sans-serif font for
proportional text and a monospace font for code-like labels. Typst embeds DejaVu Sans Mono,
Libertinus Serif, and New Computer Modern; DejaVu Sans, Liberation Sans, Arial, and Consolas
come from the operating system. If none of the requested families exist, Typst warns and
falls back to its default font. With the default `document-context: true` the preset stack is
not used anyway: the diagram inherits the document's font, so diagrams match the surrounding
text even on a machine with no extra fonts.

### Text metrics

`measure: "auto"` is the default. It lets Pele estimate label widths with its built-in
per-character width table. This is the best choice for proportional document fonts.

`measure: "mono"` forces a flat 0.6 em advance per character (1.2 em for CJK and other wide
glyphs). It is accurate only when the diagram font is actually monospace. Use it only if you
set a monospace font:

```typ
#let source = "flowchart LR\n    A[Start] --> B[Stop]"
#mermaid(source, measure: "mono", font: ("DejaVu Sans Mono",))
```

Neither mode uses real font metrics, because the runtime has no fonts. Both are estimates.
`measure: "mono"` is exact for monospace advance widths; `measure: "auto"` is a good
approximation for proportional fonts but can still clip unusually wide or narrow glyphs.

`measure` is a Typst-side switch for how label widths are estimated. Pele's `monospace`
option is different: it selects which diagram parts are *drawn* with the monospace family,
such as code-like labels. Use `measure: "mono"` only when you also set a monospace diagram
font; use `options: (monospace: true)` to change which parts use the mono stack without
changing how widths are estimated.

### Themes and options

```typ
#let source = "flowchart LR\n    A[Start] --> B[Stop]"
#mermaid(source,
  base-theme: "auto",            // auto (default), modern, dark, print
  theme: (
    background: rgb("#ffffff"),
    foreground: rgb("#1f2328"),
    "line-color": rgb("#59636e"),
    "font-family": ("DejaVu Sans Mono",),
    radius: 6pt,
    stroke: 1.75pt,
  ),
  series: (rgb("#0969da"), rgb("#1a7f37")),
  options: (max-edges: 2000),
)
```

`base-theme: "auto"`, the default, picks `dark` for dark pages and `modern` otherwise,
then follows the document's foreground and background. It also derives `surface`,
`surface-alt`, `muted`, `line`, and `border` by mixing the page and text colours, so light
text on a dark page gets dark node fills and readable borders instead of the preset's light
surfaces. A document foreground with too little contrast against the page is ignored
rather than made invisible.

An explicit `base-theme` (`"modern"`, `"dark"`, or `"print"`) opts out of document colour
sync and keeps that preset's palette; typography is still inherited. Explicit `theme`
values win over derived colours, in either mode.

`series` sets the chart palette. Short palettes repeat to fill all eight slots instead of
mixing in preset colours; more than eight colours raises an error.

`theme` accepts canonical Pele variables and friendly aliases. Unknown keys raise an error
instead of becoming accidental CSS variables. Renderer options belong in `options`, not in
`theme`; putting one in `theme` raises an error that names the correct dictionary.

Supported renderer options include `font-size`, `font-family`, `font-mono`, `id`,
`max-width`, `responsive`, `auto-direction`, `direction-breakpoint`, `padding`, `limit`,
`max-edges`, `output-limit`, `link-rel`, `link-schemes`, `image-schemes`, `links`, `images`,
`monospace`, and `now`. `icons` is a Pelermaid extension accepted in the same dictionary; see
[Icons](#icons). Diagram source can also carry Mermaid frontmatter configuration.

`layout` is a narrower alias for the layout-related subset of `options`. Prefer `options`;
Pele owns layout, and most "layout" settings are in fact renderer options.

### Icons

Pele does not draw icon packs itself; it asks the host for the inner SVG markup of names like
`fa:user`. Pelermaid bundles the same Lucide subset that [pele.run](https://pele.run) uses,
so common Font Awesome and Material Design Icons spellings work without configuration:

```typ
#mermaid("
flowchart LR
    a@{ icon: \"fa:user\", form: \"square\", label: \"User\" }
    b@{ icon: \"fas fa-twitter\", form: \"circle\" }
    c@{ icon: \"mdi mdi-skull-outline\", form: \"square\" }
    a --> b --> c
")
```

Names are normalized before lookup: the pack prefix (`fa:`, `fas `, `mdi-`) and a trailing
variant such as `-outline` or `-solid` are stripped. `fa:fa-user`, `fas fa-user`, and
`fa-user-outline` all resolve to the Lucide `user` glyph.

Add or override icons with a dictionary of names to inner SVG markup. The bundled set remains
the fallback:

```typ
#let database-icon = "<ellipse cx=\"12\" cy=\"5\" rx=\"9\" ry=\"3\"/><path d=\"M3 5v14a9 3 0 0 0 18 0V5\"/>"

#mermaid(
  "flowchart LR\n  a@{ icon: \"acme:database\", form: \"square\", label: \"DB\" }",
  icons: ("acme:database": database-icon),
)
```

The dictionary is also accepted as `options: (icons: (...))`; explicit values win over earlier
ones. Custom markup is inserted by Pele without filtering, so only pass markup you trust.
Unknown names leave Pele's icon frame empty.

Pele also draws built-in `database`, `server`, `disk`, `internet`, and `cloud` symbols in
`architecture-beta`, and `file` and `folder` in `treeView-beta`, without any resolver.

### Raw blocks

```typ
#show raw.where(lang: "mermaid"): show-mermaid-blocks()
```

### Error handling

`error-mode` accepts `"panic"` (default), `"placeholder"` (a highlighted box), or `"text"`
(plain red text with no box, for inline use):

```typ
#let source = "flowchart LR\n    A[Start] --> B[Stop]"
#mermaid(source, error-mode: "placeholder")
```

`mermaid-result` returns the same error information without raising.

## Diagram support and limits

Pelermaid supports the diagram families Pele supports, including flowchart, sequence, class,
state, ER, gantt, pie, mindmap, timeline, journey, quadrant, XY chart, git graph, sankey,
architecture, block, kanban, packet, radar, treemap, and C4. Some Mermaid features are
intentionally not implemented; Pele reports an error rather than falling back to Mermaid.js.

Pele applies these limits (defaults shown):

| Option | Default | Effect |
| --- | --- | --- |
| `limit` | 50,000 characters | Rejects oversized Mermaid source |
| `maxEdges` | 5,000 edges | Rejects diagrams with too many edges |
| `outputLimit` | 4,000,000 characters | Rejects oversized SVG output |
| `maxWidth` | Typst layout width | Width used for reflow and auto-direction |

Raise a limit only for trusted input. Larger limits increase compile time and memory use.

## Links, images, and security

Pele filters URLs, HTML, and styles before producing SVG. Pelermaid additionally forces
`links: false` and `images: false` by default, so links and external images in the Mermaid
source are dropped rather than embedded.

Even if you enable them with `options: (links: true)` or `options: (images: true)`, Typst's
SVG renderer is not a browser:

- External image references (`<image href="https://...">`) are unlikely to load. Inline
  `data:` URIs are the only portable option, and even those may be dropped.
- SVG links are not reliable in PDF output. Treat linked diagrams as unsupported.
- CSS variables, `color-mix()`, and CSS geometry properties are resolved by the JavaScript
  sanitizer before Typst sees the SVG, because Typst's renderer does not implement them.
- Math labels and some sub/superscript positioning depend on SVG features that Typst's
  renderer may not fully support.

Pelermaid renders Mermaid source through a sandboxed QuickJS runtime, not through a browser.
It does not fetch the source, images, icons, or fonts referenced by a diagram. Icons come
from the bundled Lucide subset or the trusted `icons` dictionary (see [Icons](#icons)).

## Accessibility

`alt` defaults to a generated label such as `"Mermaid flowchart diagram"`. Set a specific
`alt` for diagrams whose meaning matters:

```typ
#mermaid(source, alt: "Flowchart: the user enters a score; scores of five or more pass.")
```

## Notes and limitations

- Pelermaid depends on CtxJS. If an offline or Tinymist setup cannot resolve preview
  packages, vendor CtxJS and change the import in `lib.typ`; see
  [developer.md](developer.md).
- `background: none` produces a transparent canvas. Pele paints several decorations with the
  canvas colour, so edge labels, edge casings, arrow markers, pie labels, sequence-number
  halos, and treemap labels fall back to the opaque `label-bg` (the preset background by
  default). This keeps them visible and stops connector lines showing through label text.
  Override `theme: (label-bg: ...)` to match a custom page colour.
- `mermaid-result` does not read document context, because it returns data rather than
  content. Pass explicit `font`, `foreground`, and `background` values when using it
  outside a document.
- Pelermaid does not implement Mermaid.js's directives or every Mermaid configuration key,
  and it does not load external icon packs. Icon names outside the bundled Lucide subset
  must be supplied through `icons`; otherwise Pele leaves the icon frame empty. Unsupported
  diagram types raise a Pele error.

## Development

See [developer.md](developer.md)
for building, testing, and releasing Pelermaid.

## License

Pelermaid is MIT licensed. `pele.kbc1` bundles Pele (MIT) and a subset of Lucide icons
(ISC); the full texts are in `LICENSES/`. Because the distributed bytecode contains both,
the manifest declares `MIT AND ISC`. See [`LICENSE`](LICENSE) and
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
