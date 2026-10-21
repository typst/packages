# kinetic-kit

The official [Typst](https://typst.app) template[^1] for doctoral theses published through [KIT Scientific Publishing (KSP)](https://www.ksp.kit.edu/).


## Getting Started

Start a new project from the template with:

```bash
typst init @preview/kinetic-kit:0.2.1
```

Or pick **kinetic-kit** from the template gallery in the [Typst web app](https://typst.app).
Either way you get a ready-to-fill `main.typ`.

To add the template to an existing document instead, import it and apply it with a show rule:

```typst
#import "@preview/kinetic-kit:0.2.1": thesis

#show: thesis.with(
  lang: "de",
  author-firstname: "Max",
  author-surname: "Mustermann",
  title: [Title of the Dissertation],
  front-matter: [
    #include "content/abstract-de.typ"

    #outline()
  ],
  back-matter: [
    #outline(target: figure.where(kind: image))
    #bibliography("bib/references.bib", style: "ieee")
  ],
)

#include "content/01-introduction.typ"
```

See the [`examples/`](https://github.com/ll-nick/kinetic-kit/blob/v0.2.1/examples/) directory for more complete examples;
the [latest release](https://github.com/ll-nick/kinetic-kit/releases/tag/v0.2.1) has them attached as rendered PDFs.

### Fonts

The template is set in the [Libertinus](https://github.com/alerque/libertinus) font family.

- **Typst web app:** Libertinus is pre-installed, so no additional steps are required.
- **Local compilation:** The Libertinus font family must be installed on your system for the compiler to find it.
You can get it from the [Libertinus releases](https://github.com/alerque/libertinus/releases).
The bundled copy is version 7.051.

<details>
<summary><strong>Local install</strong></summary>

To use a local checkout of [the template's repository](https://github.com/ll-nick/kinetic-kit) as a package
(e.g. while contributing or to get the bleeding-edge version),
follow these steps to install it into your local Typst package directory.

[mise-en-place](https://mise.jdx.dev) is an optional but recommended prerequisite here.
It can be used to install both the template and Typst itself.
However, assuming Typst is installed, each task is a plain shell script, so you can also run the `bash mise/tasks/…` form directly.

Inside your clone of the repository, run either of the following:

```bash
# copy — changes require re-installation (recommended for stability)
mise run install # or bash mise/tasks/install/_default

# symlink — changes apply immediately (recommended during development)
mise run install:editable # or bash mise/tasks/install/editable
```

When installed this way, imports use `@local/kinetic-kit:0.2.1` in place of `@preview/kinetic-kit:0.2.1`.

The repository also bundles the Libertinus fonts.
Install them into your user font directory with

```bash
mise run install:fonts # or bash mise/tasks/install/fonts
```

</details>

## API Reference

Refer to the [API reference](https://github.com/ll-nick/kinetic-kit/releases/download/v0.2.1/api-reference.pdf),
auto-generated from the source code and attached to every release.

Upgrading from 0.1.x? See [MIGRATING.md](https://github.com/ll-nick/kinetic-kit/blob/v0.2.1/MIGRATING.md).

## Cookbook

<details>
<summary><strong>Your own title page</strong></summary>

You can fully customize the title page if you need something other than the default.
The `title-page` parameter accepts content, or a function the template calls with the details it already knows:

```typst
#import "@preview/kinetic-kit:0.2.1": thesis

#let your-custom-title-page(
  title,
  author-firstname: "",
  author-surname: "",
  format: "a5",
  lang: "de",
  ..rest,
) = align(center)[
  #v(2cm)
  #text(size: 20pt, weight: "bold")[#title]
  #v(1cm)
  #author-firstname #author-surname
]

#show: thesis.with(
  title: [Titel der Masterarbeit],
  author-firstname: "Max",
  author-surname: "Mustermann",
  title-page: your-custom-title-page,
)
```

The template supplies `title`, `author-firstname`, `author-surname`, `format` and `lang`,
so they stay in step with the PDF metadata — pre-binding them with `.with()` has no effect.
Take only what you need and let `..rest` absorb the others. Page geometry, and the
suppressed header, footer and page number, are applied for you; a `set page` of your own
overrides them.

Pass `title-page: none` to omit the page entirely, or `doctoral-title-page` (exported at
the top level) to build the default page yourself:

```typst
#import "@preview/kinetic-kit:0.2.1": doctoral-title-page, thesis

#show: thesis.with(
  title: [Titel der Dissertation],
  title-page: doctoral-title-page.with(status-approved: true, exam-date: "12. Mai 2026"),
)
```

</details>

<details>
<summary><strong>Contents, list pages and the bibliography</strong></summary>

Typst's built-in `outline` is styled, named and bookmarked for you,
so the table of contents and the back-matter list pages are ordinary `outline(..)` calls
placed in the `front-matter` / `back-matter` content of `thesis()`.

```typst
#show: thesis.with(
  front-matter: [
    #outline()
  ],
  back-matter: [
    #outline(target: figure.where(kind: image))
    #outline(target: figure.where(kind: table))
    // A kind the template has no word for names itself:
    #outline(title: [Algorithmenverzeichnis], target: figure.where(kind: "algorithm"))
    #bibliography("refs.bib", style: "ieee")
  ],
)
```

Omit `title` on a list page and the template supplies the localized name —
*Abbildungsverzeichnis* / *List of Figures* and so on for `image`, `table` and `raw`.
Pass one to override it, or `title: none` for no heading at all.
Omitting it for a kind the template cannot name is a compile error rather than a page headed *Inhaltsverzeichnis*.

The bibliography is titled the same way:
*Literaturverzeichnis* in German, where Typst's own default is *Bibliografie*.

Unlike Typst's built-in behaviour, a list page (except the table of contents)
gets a heading that is outlined and bookmarked,
so it appears in the table of contents and in the PDF bookmarks.

</details>

<details>
<summary><strong>Matching template styles in custom figures</strong></summary>

The `kit-style` namespace exposes the template's visual constants so custom figures and diagrams can match the document's typography and color palette exactly.

```typst
#import "@preview/kinetic-kit:0.2.1": kit-style

// kit-style.fonts                 — (serif, sans, mono) font family arrays
// kit-style.font-sizes-by-format  — dict keyed by format: font sizes per format
// kit-style.leading               — paragraph line spacing (0.75em)
// kit-style.colors                — KIT color palette (green, blue, red, …)

#figure(
  {
    set text(font: kit-style.fonts.sans, size: kit-style.font-sizes-by-format.at("a5").small)
    rect(
      fill: kit-style.colors.green15,
      stroke: kit-style.colors.green,
      width: 6cm, height: 3cm,
    )
  },
  caption: [A custom figure using template styles.],
)
```

</details>

<details>
<summary><strong>Custom figure kinds (algorithms, theorems, …)</strong></summary>

Typst gives every figure `kind` its own counter and supplement,
but only styles the ones it knows: `image`, `table` and `raw` (code listings).
The template carries strings for exactly those three.
Anything else is your document's vocabulary, so you declare it.

**Declaring a kind.** Give it a `supplement`, either one value or one per language:

```typst
#show: thesis.with(
  figure-kinds: (
    (kind: "algorithm", supplement: (de: [Algorithmus], en: [Algorithm])),
    (kind: "theorem",   supplement: [Theorem]),
  ),
)
```

Then tag the figure:

```typst
#figure(
  algorithm-body,
  caption: [This is an algorithm.],
  kind: "algorithm",
)
```

**List pages.** Put an `outline` call in `back-matter` for each kind you want listed,
in whatever order you want them — the built-in `image`/`table`/`raw` included:

```typst
back-matter: [
  #outline(target: figure.where(kind: image))
  #outline(target: figure.where(kind: table))
  #outline(title: [List of Algorithms], target: figure.where(kind: "algorithm"))
],
```

A declared kind needs a `title` of its own; the template only names `image`, `table` and `raw`.

</details>

<details>
<summary><strong>Draft mode with git SHA watermark</strong></summary>

Set `draft: true` to show an "ENTWURF" (German) or "DRAFT" (English) watermark on every page. Pass `draft-info` for an additional version string:

```typst
#show: thesis.with(
  // ...
  draft:      true,
  draft-info: sys.inputs.at("git-sha", default: none),
)
```

Compile with the SHA injected:

```bash
typst compile --input git-sha=$(git rev-parse --short HEAD) main.typ
```

Set `draft: false` before submission.

</details>

<details>
<summary><strong>Automatic abbreviation expansion (Glossarium)</strong></summary>

Use the [glossarium](https://typst.app/universe/package/glossarium) package for automatic first-use expansion.

**Important:** `#show: make-glossary` must appear *before* `#show: thesis.with(...)`. Forgetting this causes silent failure — abbreviations will not expand.

```typst
#import "@preview/kinetic-kit:0.2.1": thesis
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary

#let abbrevs = (
  (key: "ml",  short: "ML",  long: "Machine Learning"),
  (key: "cnn", short: "CNN", long: "Convolutional Neural Network"),
)

// Must come before #show: thesis.with(...)
#show: make-glossary
#register-glossary(abbrevs)

#show: thesis.with(
  // ...
  front-matter: [
    = List of Abbreviations
    #print-glossary(abbrevs)

    #outline()
  ],
)

// @ml expands to "Machine Learning (ML)" on first use, "ML" thereafter.
```

For a nicer two-column grid layout (bold abbreviation on the left, long form on the right) instead of the default `print-glossary` output, see the custom `abbrevs-glossary()` helper in [`examples/content/abbreviations.typ`](https://github.com/ll-nick/kinetic-kit/blob/v0.2.1/examples/content/abbreviations.typ).

</details>

<details>
<summary><strong>Margin notes for drafts (Drafting)</strong></summary>

Use the [drafting](https://typst.app/universe/package/drafting) package to add margin notes during writing. Tie `is-draft` to both the watermark and note visibility so they are toggled in one place:

```typst
#import "@preview/kinetic-kit:0.2.1": thesis
#import "@preview/drafting:0.2.2": set-margin-note-defaults, margin-note

#let is-draft = true
#set-margin-note-defaults(hidden: not is-draft)

#show: thesis.with(
  // ...
  draft: is-draft,
)

// In your text:
#margin-note[Revisit this paragraph.]
```

Set `is-draft = false` before final compilation to hide all margin notes and remove the watermark.

</details>

## Contributing

Contributions are welcome.
Refer to [CONTRIBUTING.md](https://github.com/ll-nick/kinetic-kit/blob/v0.2.1/CONTRIBUTING.md)
for details and development setup.

## License

Template code: MIT-0 (no attribution required).

## Acknowledgements

This template has been implemented with AI assistance (Claude Code by Anthropic).
The basis for the template are the [KSP handbook](https://www.bibliothek.kit.edu/downloads/KSP/KSP-Manuskripthandbuch.pdf),
the [official KSP LaTeX template](https://gitlab.kit.edu/kit/ksp/ksp-vorlage-a5-de-diss),
as well as [this LaTeX template](https://gitlab.cc-asp.fraunhofer.de/kit-ksp/dissertation-template).
Some inspiration was also drawn from the [TUM-tastic thesis template](https://github.com/santiagonar1/tum-tastic-thesis).


[^1]: This template is provided "as is".
Please note that further technical assistance is currently not available. 

