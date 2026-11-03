# kinetic-kit

The official [Typst](https://typst.app) template[^1] for doctoral theses published through [KIT Scientific Publishing (KSP)](https://www.ksp.kit.edu/).


## Getting Started

Start a new project from the template with:

```bash
typst init @preview/kinetic-kit:0.1.1
```

Or pick **kinetic-kit** from the template gallery in the [Typst web app](https://typst.app).
Either way you get a ready-to-fill `main.typ`.

To add the template to an existing document instead, import it and apply it with a show rule:

```typst
#import "@preview/kinetic-kit:0.1.1": dissertation

#show: dissertation.with(
  author-firstname: "Max",
  author-surname:   "Mustermann",
  title:            [Title of the Dissertation],
  lang:             "de",
  abstract-de:      include "content/abstract-de.typ",
  abstract-en:      include "content/abstract-en.typ",
  bibliography:     bibliography("bib/references.bib", title: none, style: "ieee"),
)

#include "content/01-introduction.typ"
```

See the [`examples/`](https://github.com/ll-nick/kinetic-kit/blob/v0.1.1/examples/) directory for more complete examples;
the [latest release](https://github.com/ll-nick/kinetic-kit/releases/latest) has them attached as rendered PDFs.

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

When installed this way, imports use `@local/kinetic-kit:0.1.1` in place of `@preview/kinetic-kit:0.1.1`.

The repository also bundles the Libertinus fonts.
Install them into your user font directory with

```bash
mise run install:fonts # or bash mise/tasks/install/fonts
```

</details>

## API Reference

Refer to [`docs/api-reference.pdf`](docs/api-reference.pdf),
for the API documentation auto-generated from the source code.

> Please note: The `thesis()` template is a companion for Bachelor's, Master's, and Diploma theses.
> KSP's endorsement applies to the doctoral thesis template only.
> This companion is provided as a convenience.

<details>
<summary><strong>Doctoral Thesis: <code>dissertation(...)</code></strong></summary>

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `author-title` | `str \| none` | `"M.Sc."` | Academic title preceding the name; `none` to omit |
| `author-firstname` | `str` | `"Max"` | |
| `author-surname` | `str` | `"Mustermann"` | |
| `author-male` | `bool` | `true` | Controls gendered German text on the title page |
| `title` | `content` | | Dissertation title |
| `doc-degree` | `str` | `"Doktors der Ingenieurwissenschaften (Dr.-Ing.)"` | Degree in masculine form |
| `doc-degree-f` | `str` | `"Doktorin der Ingenieurwissenschaften (Dr.-Ing.)"` | Degree in feminine form |
| `department` | `str` | `"KIT-Fakultät für Maschinenbau"` | |
| `university-genitive` | `str` | `"des Karlsruher Instituts für Technologie (KIT)"` | University name in genitive case |
| `lang` | `"de" \| "en"` | `"de"` | Document language |
| `format` | `"a5" \| "17x24" \| "a4"` | `"a5"` | Paper format — `"a5"` (148×210 mm, default), `"17x24"` (170×240 mm), or `"a4"` (210×297 mm) |
| `margin-preset` | `"short" \| "medium" \| "long"` | `"short"` | KSP margin profile keyed on final page count — `short` < 200 pp, `medium` 200–399, `long` ≥ 400 |
| `status-approved` | `bool` | `false` | `false` = eingereicht, `true` = angenommen |
| `exam-date` | `str \| none` | `none` | Date of oral examination; required when `status-approved: true` |
| `main-advisor` | `str \| none` | `none` | Hauptreferent |
| `main-advisor-male` | `bool` | `true` | |
| `co-advisor` | `str \| none` | `none` | Korreferent |
| `co-advisor-male` | `bool` | `true` | |
| `abstract-en` | `content \| none` | `none` | |
| `abstract-de` | `content \| none` | `none` | |
| `acknowledgements` | `content \| none` | `none` | |
| `notation` | `content \| none` | `none` | Symbol/notation list |
| `abbreviations` | `content \| none` | `none` | Abbreviations / acronym list |
| `binding-correction` | `length` | `0mm` | BCOR added to inside margin (8–10 mm for physically bound copies) |
| `colored-links` | `bool` | `true` | KIT Blue hyperlinks (screen); `false` = black (print) |
| `draft` | `bool` | `false` | Show "ENTWURF"/"DRAFT" watermark |
| `draft-info` | `str \| none` | `none` | Optional version string next to watermark (e.g. git SHA) |
| `serif-headings` | `bool` | `false` | Use Libertinus Serif for headings when `true`, Libertinus Sans-Serif when `false` |
| `heading-numbering-depth` | `int` | `3` | Deepest heading level that receives a number; deeper levels are styled but not numbered |
| `own-publications` | `content \| none` | `none` | Back-matter publications list |
| `own-patents` | `content \| none` | `none` | Back-matter patents list |
| `supervised-theses` | `content \| none` | `none` | Back-matter supervised theses list |
| `show-lof` | `bool` | `true` | List of figures |
| `show-lot` | `bool` | `true` | List of tables |
| `show-lol` | `bool` | `false` | List of listings |
| `figure-kinds` | `array` | `()` | Figure kinds beyond `image`/`table`/`raw`, as dicts with `kind`, `supplement`, and optionally `list-title`/`show-list` |
| `bibliography` | `content \| none` | `none` | Pass `bibliography("refs.bib", title: none, style: "ieee")`; template adds a translated heading |
| `appendix` | `content \| none` | `none` | Appendix chapters; template applies A, A.1, … numbering, placed before the back-matter lists |

</details>

<details>
<summary><strong>Bachelor's/Master's/Diploma Thesis: <code>thesis(...)</code></strong></summary>

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `author-firstname` | `str` | `"Max"` | |
| `author-surname` | `str` | `"Mustermann"` | |
| `title` | `content` | | Thesis title |
| `thesis-type` | `str` | `"Masterarbeit"` | e.g. `"Bachelorarbeit"`, `"Diplomarbeit"` |
| `department` | `str` | `"KIT-Fakultät für Maschinenbau"` | |
| `university-genitive` | `str` | `"des Karlsruher Instituts für Technologie (KIT)"` | University name in genitive case |
| `examiner` | `str \| none` | `none` | Erstprüfer |
| `supervisor` | `str \| none` | `none` | Betreuer |
| `date-submitted` | `str \| none` | `none` | |
| `format` | `"a5" \| "17x24" \| "a4"` | `"a5"` | Paper format — `"a5"` (148×210 mm, default), `"17x24"` (170×240 mm), or `"a4"` (210×297 mm) |
| `lang` | `"de" \| "en"` | `"de"` | Document language |
| `margin-preset` | `"short" \| "medium" \| "long"` | `"short"` | KSP margin profile keyed on final page count — `short` < 200 pp, `medium` 200–399, `long` ≥ 400 |
| `binding-correction` | `length` | `0mm` | BCOR added to inside margin (8–10 mm for physically bound copies) |
| `colored-links` | `bool` | `true` | KIT Blue links (screen); `false` = black (print) |
| `draft` | `bool` | `false` | Show "ENTWURF"/"DRAFT" watermark |
| `draft-info` | `str \| none` | `none` | Optional version string next to watermark |
| `serif-headings` | `bool` | `false` | Use Libertinus Serif for headings when `true`, Libertinus Sans-Serif when `false` |
| `heading-numbering-depth` | `int` | `3` | Deepest heading level that receives a number; deeper levels are styled but not numbered |
| `abstract-en` | `content \| none` | `none` | |
| `abstract-de` | `content \| none` | `none` | |
| `acknowledgements` | `content \| none` | `none` | |
| `abbreviations` | `content \| none` | `none` | Abbreviations / acronym list |
| `show-lof` | `bool` | `true` | List of figures |
| `show-lot` | `bool` | `true` | List of tables |
| `show-lol` | `bool` | `false` | List of listings |
| `figure-kinds` | `array` | `()` | Figure kinds beyond `image`/`table`/`raw`, as dicts with `kind`, `supplement`, and optionally `list-title`/`show-list` |
| `bibliography` | `content \| none` | `none` | Pass `bibliography("refs.bib", title: none, style: "ieee")`; template adds a translated heading |
| `appendix` | `content \| none` | `none` | Appendix chapters; template applies A, A.1, … numbering, placed before the back-matter lists |

</details>

## Cookbook

<details>
<summary><strong>Custom document composition</strong></summary>

The `components` namespace exports the individual building blocks for assembling a document without the full `dissertation()` / `thesis()` orchestrator. Use this when the high-level templates don't fit your layout needs. You are responsible for applying the setup wrappers in the correct order.

Available components: `setup-page`, `setup-front-matter`, `setup-content`, `setup-appendix`, `print-dissertation-title`, `print-thesis-title`, `print-toc`, `print-lof`, `print-lot`, `print-lol`, `print-list-of`.

```typst
#import "@preview/kinetic-kit:0.1.1": components, kit-style

#let format = "a5"
#let font-sizes = kit-style.font-sizes-by-format.at(format)

// 1. Apply base KIT formatting (page geometry, fonts, heading styles, …)
#show: components.setup-page.with(
  format: format,
  margin-preset: "short",
  lang: "de",
  colored-links: true,
)

// 2. Front matter — Roman numerals, no heading numbers
#show: components.setup-front-matter

#components.print-dissertation-title(
  [Titel der Dissertation],
  author-title: "M.Sc.",
  author-firstname: "Vorname",
  author-surname: "Nachname",
  department: "KIT-Fakultät für Maschinenbau",
  university-genitive: "des Karlsruher Instituts für Technologie (KIT)",
  format: format,
)

= Abstract
Your abstract here.

#components.print-toc(font-sizes, lang: "de")

// 3. Main content — Arabic numerals, numbered headings
#show: components.setup-content

= Introduction
Your content here.

= References
#bibliography("refs.bib", title: none, style: "ieee")
```

</details>

<details>
<summary><strong>Matching template styles in custom figures</strong></summary>

The `kit-style` namespace exposes the template's visual constants so custom figures and diagrams can match the document's typography and color palette exactly.

```typst
#import "@preview/kinetic-kit:0.1.1": kit-style

// kit-style.fonts                — (serif, sans, mono) font family arrays
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

Typst gives every figure `kind` its own counter and supplement, but only styles the ones it knows: `image`, `table` and `raw`. The template carries strings for exactly those three, because their names are template chrome. Anything else is your document's vocabulary, so you declare it.

**Declaring a kind.** Give it a `supplement`, and a `list-title` if it should get a back-matter list page. Both take either one value or one per language:

```typst
#show: dissertation.with(
  figure-kinds: (
    (
      kind:       "algorithm",
      supplement: (de: [Algorithmus],            en: [Algorithm]),
      list-title: (de: [Algorithmenverzeichnis], en: [List of Algorithms]),
      show-list:  true,
    ),
    // Supplement only — no list page.
    (kind: "theorem", supplement: (de: [Satz], en: [Theorem])),
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

`kind: "algorithm"` must be spelled out. A figure whose body is a raw block is inferred as `kind: raw` otherwise, and lands among the listings.

**The built-in kinds stay out of it.** `image`, `table` and `raw` are configured by `show-lof` / `show-lot` / `show-lol` alone

**List order.** Figures, tables, listings, then your kinds in declaration order. For a different order, place them yourself with `components.print-list-of`, which also sets the state that switches `flex-caption` to its short form.

</details>

<details>
<summary><strong>Draft mode with git SHA watermark</strong></summary>

Set `draft: true` to show an "ENTWURF" (German) or "DRAFT" (English) watermark on every page. Pass `draft-info` for an additional version string:

```typst
#show: dissertation.with(
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

**Important:** `#show: make-glossary` must appear *before* `#show: dissertation.with(...)`. Forgetting this causes silent failure — abbreviations will not expand.

```typst
#import "@preview/kinetic-kit:0.1.1": dissertation
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary

#let abbrevs = (
  (key: "ml",  short: "ML",  long: "Machine Learning"),
  (key: "cnn", short: "CNN", long: "Convolutional Neural Network"),
)

// Must come before #show: dissertation.with(...)
#show: make-glossary
#register-glossary(abbrevs)

#show: dissertation.with(
  // ...
  // The template adds the translated section heading automatically.
  abbreviations: print-glossary(abbrevs),
)

// @ml expands to "Machine Learning (ML)" on first use, "ML" thereafter.
```

For a nicer two-column grid layout (bold abbreviation on the left, long form on the right) instead of the default `print-glossary` output, see the custom `abbrevs-glossary()` helper in [`examples/content/abbreviations.typ`](https://github.com/ll-nick/kinetic-kit/blob/v0.1.1/examples/content/abbreviations.typ).

</details>

<details>
<summary><strong>Margin notes for drafts (Drafting)</strong></summary>

Use the [drafting](https://typst.app/universe/package/drafting) package to add margin notes during writing. Tie `is-draft` to both the watermark and note visibility so they are toggled in one place:

```typst
#import "@preview/kinetic-kit:0.1.1": dissertation
#import "@preview/drafting:0.2.2": set-margin-note-defaults, margin-note

#let is-draft = true
#set-margin-note-defaults(hidden: not is-draft)

#show: dissertation.with(
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
Refer to [CONTRIBUTING.md](https://github.com/ll-nick/kinetic-kit/blob/v0.1.1/CONTRIBUTING.md)
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

