# Deixis

[![Typst Universe](https://img.shields.io/badge/Typst_Universe-deixis-239DAE?logo=typst)](https://typst.app/universe/package/deixis)
[![Deixis automated test suite status](https://github.com/inspiros/typst-deixis/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/inspiros/typst-deixis/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.2.0/assets/readme/hero.svg" width="1100" alt="Deixis — Point to What Matters: a colorful collage of highlights, an equation callout, shared notes, diagram connections, an editorial comment, a native footnote, a note outline, and a table with its own local notes.">

**Notes, highlights, and connections for Typst.** Keep explanations beside their
subjects, share one note across several passages, or connect the parts of an
image, equation, or diagram. Use it in articles, edited texts, and presentation
slides.

[Get started](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/getting-started.md) · [Website](https://inspiros.github.io/typst-deixis/) · [Read the guide](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/README.md) ·
[PDF manual](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/manual.pdf?raw=true) · [Browse examples](https://github.com/inspiros/typst-deixis/tree/v0.2.0/examples)

Requires **Typst 0.15.0+**.

## Start With A Note

```typst
#import "@preview/deixis:0.2.0": *
#show: deixis-setup-notes

A useful result#deixis-footnote[A short explanation.]
is easier to read when its details have a place.
```

Simple wrappers create the mark and explanation together. Choose native
footnotes, margin notes, inset callouts, inline explanations, or collected
endnotes. Connections and custom styling are optional.

For shorter calls, [write with short names](#write-with-short-names) such as
`footnote` and `margin-note`.

## One Explanation, Several Passages

<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.2.0/assets/readme/reading.svg" width="700" alt="A one-page document: a margin note explains a shared assumption that is marked twice with the same number, a region around the sample-mean equation connects to its own margin note, and a native footnote sits in the page footer.">

Name an annotation with `id:` and reuse it with `of:`. The passages share one
number and one body:

```typst
#deixis-margin-note(id: <assumption>, connector: "right-angle")[shared assumption][
  Several passages can point to this same note.
]
Return to the #deixis-mark(of: <assumption>)[same assumption] later.
```

A reused mark adds a navigation point rather than another note; add
`deixis-connect` when it also needs a drawn connection. Margin notes need room
beside the text; they pack, and can spill onto existing pages.

[Complete document](https://github.com/inspiros/typst-deixis/blob/v0.2.0/examples/annotated-reading.typ) ·
[Shared notes](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/shared-notes.md) · [Appearance](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/appearance.md)

## Explain The Equation

<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.2.0/assets/readme/equation.svg" width="1000" alt="Bayes' rule with three highlighted regions connected to explanations of the posterior, evidence update, and prior.">

Regions follow the measured content. Add precise callouts to equations, code,
images, or tables; choose their colors and connectors independently. The
routing API also connects your own objects, with optional obstacle avoidance;
the diagram in the banner above uses it.

[Editable equation](https://github.com/inspiros/typst-deixis/blob/v0.2.0/examples/annotated-equation.typ) ·
[Regions and pins](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/regions.md) ·
[Connect your own objects](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/document-routing.md)

## Review In Draft, Read In Final

<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.2.0/assets/readme/review.svg" width="1000" alt="Two builds of the same passage: the draft has Ada's editorial comment and connector; the final keeps the passage and source footnote while omitting the review annotation.">

`deixis-comment` writes an editorial comment in its own `"review"` series, with
lettered markers that stay apart from source notes:

```typst
The #deixis-comment(author: "Ada", status: "open")[proposed method][
  State the conditions under which this claim holds.]
```

A final build omits that series while preserving the marked passage and the
document's other notes:

```typst
#deixis-set(omit: (series: ("review",)))
```

The comparison renders the same source twice, with `--input final=false` and
`--input final=true`. Author and status fields can also drive custom review lists.

[Editable review](https://github.com/inspiros/typst-deixis/blob/v0.2.0/examples/editorial-review.typ) ·
[Draft/final guide](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/review-comments.md) ·
[Editorial apparatus and glossaries](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/editorial-recipes.md)

## Reveal Notes With Your Slides

<img src="https://raw.githubusercontent.com/inspiros/typst-deixis/v0.2.0/assets/readme/slides.svg" width="1000" alt="Two frames of a Touying slide: the first shows one footnoted line; after the pause, a highlighted idea, its connector and callout, and a second footnote appear together.">

Annotations follow [Touying](https://typst.app/universe/package/touying) reveals.
A highlight, its connector and callout, or a page footnote appears with the
content it explains, while earlier notes stay on screen. Install setup in the
slide setting and let the theme own the page layers.

[Editable slides](https://github.com/inspiros/typst-deixis/blob/v0.2.0/examples/touying-reveals.typ) ·
[Touying integration](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/rendering.md#presentation-frameworks)

## Write With Short Names

The opt-in `short` module offers every public function without the `deixis-`
prefix. They are the same functions, with the same options:

```typst
#import "@preview/deixis:0.2.0": short
#import short: *
#show: setup-notes
#configure(stroke: teal)

A useful result#footnote[A short explanation.]
#note-block[A local table#footnote[Collected at the end of its block.]]
```

`configure` is `deixis-set`, and `note-block` is `deixis-block`, so native
`set` and `block` keep working. A wildcard import shadows native `footnote` and
`ref`; use `std.footnote` and `std.ref` for those functions. In math it also shadows `attach` and
`arrowhead`; use `std.math.attach` and `std.sym.arrowhead`. Import
`short as dx` to keep names separate and write `dx.footnote`.
See [short names](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/getting-started.md#optional-short-names).

## Install

Requires **Typst 0.15.0+**. Import Deixis from Typst Universe:

```typst
#import "@preview/deixis:0.2.0": *
```

Typst downloads the package automatically. Upgrading from 0.1.1? See the
[compatibility and migration guide](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/compatibility.md#migrate-from-011).

## Go Further

| Task | Guide |
| --- | --- |
| Pick a note type and placement | [Getting started](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/getting-started.md) · [Body ownership](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/ownership.md) |
| Keep notes with tables or figures | [Local collections](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/blocks.md) · [Scopes](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/scopes.md) |
| Annotate presentation reveals | [Touying integration](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/rendering.md#presentation-frameworks) |
| Restart markers per page or reset counters | [Counters](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/counters.md) |
| Build annotation lists and indexes | [Queries](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/queries.md) · [Outlines](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/outlines.md) |
| Style notes or replace a renderer | [Configuration](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/configuration.md) · [Custom renderers](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/custom-renderers.md) |
| Update an older document | [Compatibility and migration](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/guides/compatibility.md) |

The [PDF manual](https://github.com/inspiros/typst-deixis/blob/v0.2.0/docs/manual.pdf?raw=true) includes a guided introduction,
23 worked examples with source beside output, and a reference for every public API.
The [searchable website](https://inspiros.github.io/typst-deixis/) combines the guides, examples, and API reference. See
[CONTRIBUTING](https://github.com/inspiros/typst-deixis/blob/v0.2.0/CONTRIBUTING.md#local-website-and-agent-skill) for local build and
serving commands. The
[Deixis agent skill](https://github.com/inspiros/typst-deixis/blob/v0.2.0/skills/deixis/SKILL.md) includes checked authoring recipes.

For development, checks and artwork generation, see [CONTRIBUTING](https://github.com/inspiros/typst-deixis/blob/v0.2.0/CONTRIBUTING.md).

## Acknowledgements

Related work inspired parts of Deixis:
[drafting](https://github.com/ntjess/typst-drafting),
[dashy-todo](https://github.com/Otto-AA/dashy-todo),
[marge](https://github.com/EpicEricEE/typst-marge),
[pinit](https://github.com/OrangeX4/typst-pinit), and
[Rik's endnotes implementation](https://forum.typst.app/t/an-endnotes-implementation-with-headings-and-cross-referencing/7760).

## License

MIT licensed; see [LICENSE](LICENSE). Report bugs or suggest improvements on
[GitHub](https://github.com/inspiros/typst-deixis/issues).
