# Oxford Typst branding

Reusable University of Oxford branding for Typst documents and presentations.
It uses Oxford Blue (`#002147`) by default and prefers the approved Roboto and
Noto Serif typefaces.

## Use

### Published versions

Once a version is published on Typst Universe, import it directly:

```typst
#import "@preview/oxford-brand:0.1.1": presentation
```

### Local development

Before publication, or while testing changes, install this checkout locally.
There are two options:

1. **Permanent install:** copy the repository into Typst's local package path. Future changes to this checkout will not be picked up automatically.
2. **Dynamic install:** create a symbolic link to this checkout. Changes here are then available immediately.

First run `typst info` and note the `Package path`. The commands below assume
macOS or Linux and should be run from the repository root, replacing
`<package-path>` with that path.

### 1. Permanent install

For a permanent install:

```sh
mkdir -p "<package-path>/local/oxford-brand"
cp -R . "<package-path>/local/oxford-brand/0.1.1"
```

### 2. Dynamic install

For a dynamic install, use a symbolic link instead of copying. The link must
point to this repository and be named `0.1.1`:

```sh
ln -sfn "$PWD" "<package-path>/local/oxford-brand/0.1.1"
```

Import the local development version with:

```typst
#import "@local/oxford-brand:0.1.1": presentation
```

The package has no default document type. Use the exported building blocks in
your own Typst source. The files under `template/` are implementation modules;
the document and presentation sources are examples for development.

Compile the document example:

```sh
typst compile template/document.typ oxford-document.pdf --root .
```

## Presentations

`template/presentation.typ` provides reusable 16:9 slide layouts. Configure
the identity once, then call the layouts; `examples/dummy-presentation.typ` is
only a demonstration of those calls.

```typst
#import "template/presentation.typ": presentation

#let slides = presentation(
  secondary-logo: "assets/oxford-rse-square.svg",
)

#(slides.title_image)([Research software at Oxford], "hero.jpg")
#(slides.text_figure)(
  [A practical partnership],
  lead: [Embedded expertise alongside research teams.],
  body: [Supporting research from first prototype to lasting software.],
  picture: "hero.jpg",
)

#let chart = [#circle(radius: 1in, fill: rgb("#1D42A6"))]
#(slides.two_column_figure)(
  [Delivery], [Plan], [Define the approach.], [Build], [Create the software.],
  visual: chart,
)
```

Available layouts are `title_image`, `title` (with `dark: true` for the Oxford
Blue variant), `section`, `text_only`, `text_figure`, `two_column`,
`two_column_figure`, `three_column`, `box_grid`, `image_caption`, `figure`,
`visual_caption`, and `contact`. Required
content is positional; optional fields such as `lead`, `body`, `picture`,
`visual`, `credit`, and `social` are named. `visual` accepts any Typst content,
such as a `figure`, chart, diagram or graphic; it takes precedence over
`picture`. `secondary` accepts a department name as text; `secondary-logo`
accepts an image path for a paired logo.

`visual_caption` provides a branded title banner, content area and lower
logo lock-up for a chart, diagram, code block or command-line example. Supply
native Typst content through `visual`; this keeps code-highlighting packages
optional and lets a document choose its own styling tool:

```typst
#(slides.visual_caption)(
  [A command-line workflow],
  visual: [#raw("$ typst compile deck.typ deck.pdf", block: true)],
)
```

`box_grid` creates an equal-size matrix in the standard slide content area.
Use `nrows: 4, ncols: 1` for a list. Box numbers are one-based;
`highlighted` uses Oxford Royal Blue and `deactivated` uses a faded version of
the standard box palette:

```typst
#(slides.box_grid)(
  [Delivery stages],
  ([Discover], [Design], [Build], [Sustain]),
  nrows: 4,
  ncols: 1,
  highlighted: (3,),
  deactivated: (4,),
)
```

Compile the supplied deck:

```sh
typst compile examples/dummy-presentation.typ oxford-presentation.pdf --root .
```

## Fonts

Install [Roboto](https://fonts.google.com/specimen/Roboto) and
[Noto Serif](https://fonts.google.com/noto/specimen/Noto+Serif) from Google
Fonts before compiling for the intended Oxford typography. The template names
those fonts first and falls back to Arial and Times New Roman when they are not
installed; Typst's `unknown font family` warning makes that substitution visible.

For a new document, import the template and supply only the options you need:

```typst
#import "template/oxford.typ": oxford, title-block, colours

#show: oxford.with(
  accent: "royal-blue",
  secondary: "Research Software Engineering Group\\
Doctoral Training Centre, MPLS",
)

#title-block("Report title", author: "Your name")
```

`accent` accepts every Oxford RGB palette name in `colours`, including `blue`,
`mauve`, `peach`, `red`, `orange`, `green`, `royal-blue`, `aqua`, and the neutral
colours. Oxford Blue remains in headings and document identity irrespective of
the selected accent.

For a departmental or group identity, use the supplied square RSE mark as the
secondary logo. It is paired with the University logo and official notched
separator:

```typst
#show: oxford.with(secondary-logo: "assets/oxford-rse-square.svg")
```

The cropped mark is derived from the [official RSE/DTC logo
SVG](https://www.rse.ox.ac.uk/sites/default/files/rse/site-logo/2024_oxrse_next_to_oxford.svg);
the original is retained in `references/`. Use it only in this paired lock-up,
not as a standalone University identifier.

## Assets and brand use

`assets/` contains the supplied official RGB square and rectangle logo artwork.
The square logo is the default; select the rectangle only when vertical space is
restricted:

```typst
#show: oxford.with(
  logo: "assets/oxford-logo-rectangle-rgb.png",
  logo-width: 31mm,
  secondary-logo: "assets/oxford-rse-square.svg",
)
```

The supplied EPS separator files are retained in `assets/` for professional
design workflows; the PNG separator is used by Typst. Do not modify,
recolour, crop, or remove the logo keyline. Check final material against the
[Oxford brand guidelines](https://www.ox.ac.uk/about/the-university/brand/guidelines),
particularly the logo clear-space and multiple-identifier rules.
