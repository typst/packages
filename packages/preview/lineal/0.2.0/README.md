# Lineal

Clean Typst presentations with reusable content components.

Lineal provides a slide theme, composable layouts and components for talks,
teaching material and project reviews. The components also work in ordinary
Typst documents. Content stays editable and selectable in the exported PDF.

![A team update composed with Lineal components](https://raw.githubusercontent.com/ellsphillips/lineal/941f266c40b5b24ba881fded1e6a52d6eafec8de/assets/img/components.png)

## Quick start

Requires **Typst 0.13.1 or newer**. Version 0.2.0 is a release candidate until
the registry submission is published. Use the source checkout or local package
instructions below to try it now.

Create `talk.typ` with the public package API:

```typst
#import "@preview/lineal:0.2.0": lineal-theme, config-info, title-slide, layouts, metric, callout

#show: lineal-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [Project review], author: [Your name]),
)

#title-slide()

= Delivery
== Progress this quarter

#layouts.columns(
  metric(12, label: [Teams onboarded]),
  metric(4, label: [Workshops delivered]),
)
#v(1em)
#callout(title: [Next step])[Share the workshop materials with each team.]
```

Compile with `typst compile --root . talk.typ`. Level-one headings create
section slides with an outline. Level-two headings create content slides.
Deeper headings stay within a slide. Set `footer-progress: false` to hide the
progress bar or customise the running headers and footers.

## Source checkout and local packages

**Version 0.2.0 is a release candidate in this repository.** The published
`0.1.0` package lacks the `lineal-theme` export. Updating a local checkout does
not repair that older registry package.

Clone the repository to compile the current gallery immediately:

```sh
git clone https://github.com/ellsphillips/lineal.git
cd lineal
typst compile --root . demo/main.typ demo/main.pdf
```

To use the quick-start example inside this checkout, change its import path to
`"lib.typ"`. For a reusable local package, run:

```sh
python3 scripts/package --install-local
```

Then use the same API from any project:

```typst
#import "@local/lineal:0.2.0": lineal-theme, config-info, title-slide
#show: lineal-theme.with(config-info(title: [My presentation]))
#title-slide()
== First slide
Your content.
```

Local installation never replaces a published package or modifies the registry
cache. The [release guide](docs/development.md) explains packaging and checks.

## Components

Import individual functions from `lib.typ` or the package entrypoint. Components
inherit the surrounding font and accept local colours and spacing. They do not
require the slide theme, JavaScript or network requests while rendering.

| Component | Use |
| --- | --- |
| `code-block(source, filename: ...)` | Syntax highlighting, file icons, numbered lines, ranges, captions and light/dark styles. |
| `file-icon(filename)` and `file-label(filename)` | SVG file marks and path labels, including a blue Svelte mark for `.svelte.ts`. |
| `callout(title: ..., tone: ...)[body]` | Notes with an optional heading and a semantic accent. |
| `metric(value, label: ..., detail: ..., change: ...)` | A prominent value with explicit context. |
| `steps(items, direction: ...)` | Numbered processes in a vertical or horizontal layout. |
| `data-table(headers, rows)` | Styled tables with repeating headers, alignment and highlighted rows. |
| `comparison(before, after, labels: ...)` | Two labelled content areas with configurable proportions. |
| `quote(author: ..., source: ...)[body]` | Quotations with optional rich attribution. |
| `repository(name: ..., languages: ...)` | A repository link and a language bar with normalised percentages. |
| `lineal-outline()` and `lineal-toc()` | Contextual section navigation and a complete, flowing table of contents. |
| `lineal-progress-bar(variant: ...)` | Logical slide progress with correct section, overlay and handout counts. |

Detailed signatures and working examples:

- [Code blocks and file labels](docs/code-block.md)
- [Callouts, metrics, steps, tables and comparisons](docs/components.md)
- [Layouts, quotes, repositories and theme configuration](docs/layouts.md)
- [Outlines and tables of contents](docs/navigation.md)
- [Progress calculations and counter semantics](docs/progress.md)
- [Heading hierarchy and overlay identity](docs/navigation-model.md)
- [Complete component gallery](https://github.com/ellsphillips/lineal/blob/941f266c40b5b24ba881fded1e6a52d6eafec8de/demo/main.typ)

## Composition

Use the `layouts` namespace for common arrangements:

```typst
#layouts.columns(widths: (2fr, 1fr), gutter: 1em,
  layouts.panel[Main content],
  layouts.panel[Supporting content],
)
```

`layouts.columns` accepts any number of bodies. `layouts.panel` sizes naturally
to its content. `layouts.frame(height: 180pt)[body]` checks vertical overflow
before drawing a fixed frame. The earlier `page-center`, `two-boxes`, `contained`,
`four-columns` and `matrix` layouts remain available.

Native Typst `grid`, `stack`, `table`, figures and links work alongside every
component. Use `config-colors` for the slide frame and named colour options on
components for local styling. See the [layout guide](docs/layouts.md).

## Development

```sh
./scripts/check
python3 scripts/package /tmp/lineal-package
```

The checks compile real examples and package imports, exercise expected errors
and build the gallery. CI runs against Typst 0.13.1 and 0.14.2. Development
scripts require Python 3.11 or newer; consuming Lineal requires only Typst.
See [development and release instructions](docs/development.md).

## Licence

Lineal is MIT licensed. Bundled SVG assets retain their own MIT, ISC or CC0
notices under `src/static/icons/`. Lineal builds on
[Touying](https://github.com/touying-typ/touying) and
[Typst](https://github.com/typst/typst).
