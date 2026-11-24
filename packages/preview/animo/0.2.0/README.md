<!--
SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
SPDX-License-Identifier: Apache-2.0
-->

# Animo

[![Package on Typst Universe](https://img.shields.io/badge/universe-animo-239dad?logo=typst&logoColor=white)](https://typst.app/universe/package/animo)
[![Latest release on GitHub](https://img.shields.io/github/v/release/reproducible-reporting/animo?logo=github&label=release)](https://github.com/reproducible-reporting/animo/releases)
[![Supported typst release](https://img.shields.io/badge/typst-0.15.0-239dad?logo=typst&logoColor=white)](https://github.com/typst/typst/releases/tag/v0.15.0)
[![Documentation site](https://img.shields.io/badge/docs-animo-blue)](https://reproducible-reporting.github.io/animo/)
[![Status of the test suite](https://github.com/reproducible-reporting/animo/actions/workflows/pytest.yml/badge.svg)](https://github.com/reproducible-reporting/animo/actions/workflows/pytest.yml)
[![Status of the pre-commit hooks](https://results.pre-commit.ci/badge/github/reproducible-reporting/animo/main.svg)](https://results.pre-commit.ci/latest/github/reproducible-reporting/animo/main)
[![Status of the documentation build](https://github.com/reproducible-reporting/animo/actions/workflows/zensical.yml/badge.svg)](https://github.com/reproducible-reporting/animo/actions/workflows/zensical.yml)
[![Status of the release build](https://github.com/reproducible-reporting/animo/actions/workflows/release.yml/badge.svg)](https://github.com/reproducible-reporting/animo/actions/workflows/release.yml)
[![Status of the weekly probes](https://github.com/reproducible-reporting/animo/actions/workflows/probes.yml/badge.svg)](https://github.com/reproducible-reporting/animo/actions/workflows/probes.yml)
[![Apache-2.0 license](https://img.shields.io/badge/license-Apache--2.0-green)](https://github.com/reproducible-reporting/animo/blob/v0.2.0/LICENSES/Apache-2.0.txt)

<!-- snipwise.md BEGIN tagline -->

Build dynamic HTML and static PDF presentations using [typst](https://typst.app/) from a single source.

<!-- snipwise.md END tagline -->

The [short tour of Animo](https://reproducible-reporting.github.io/animo/demos/tour.html)
gives a quick impression of its capabilities.

A minimal deck with one slide and one animation looks like this:

```typst
#import "@preview/animo:0.2.0": *
#show: animo.with(width: 16cm, height: 9cm, margin: 1cm)

#slide(animation: {
  import anim: *
  sub(reveal("punchline"))
})[
  What makes a good punchline?

  #tag("punchline")[Timing.]
]
```

The body of a slide defines the contents and tags the parts an animation may address.
The `animation` argument says when and how tagged parts move or change.

Key features:

- One source file compiles to an animated HTML deck, a presentation PDF and a handout PDF.
- The HTML presentation comes with a runtime that supports visual effects,
  such as moving, scaling, fading, replacing, resetting, hiding, revealing and morphing content.
- Slides are drawn on a canvas that can be larger than the slide, so the deck can pan over it.
- Plain typst inside a slide: no template machinery and no theme to learn.
- Every position in a deck is a URL, so a deep link lands on a subslide.
- Content and animation stay separate, so a slide body reads as a document.
- Extensive validation of HTML outputs against different browser engines with [playwright](https://playwright.dev).

## Demos

Each demo deck shows, slide by slide, features that the Presentation Author Guide explains.
Most demo decks accompany one page of the guide, and their title slide links to that page.

| Deck                                                                                                 | Shows                                                       | Open                                                                                                                                                                                                                                                                                                                                                                                            |
| ---------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`hello.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/hello.typ)           | The smallest deck that animates: one slide, one reveal.     | <a href="https://reproducible-reporting.github.io/animo/demos/hello.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/hello-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/hello-handouts.pdf" target="_blank" rel="noopener">handouts</a>                |
| [`slides.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/slides.typ)         | Margins, backgrounds, overlays and slide transitions.       | <a href="https://reproducible-reporting.github.io/animo/demos/slides.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/slides-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/slides-handouts.pdf" target="_blank" rel="noopener">handouts</a>             |
| [`tags.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/tags.typ)             | Where a tag may sit, and how it starts out.                 | <a href="https://reproducible-reporting.github.io/animo/demos/tags.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/tags-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/tags-handouts.pdf" target="_blank" rel="noopener">handouts</a>                   |
| [`continuous.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/continuous.typ) | Moving and scaling, and the four timing keywords.           | <a href="https://reproducible-reporting.github.io/animo/demos/continuous.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/continuous-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/continuous-handouts.pdf" target="_blank" rel="noopener">handouts</a> |
| [`structural.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/structural.typ) | Content replaced, removed, restyled and reset.              | <a href="https://reproducible-reporting.github.io/animo/demos/structural.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/structural-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/structural-handouts.pdf" target="_blank" rel="noopener">handouts</a> |
| [`viewport.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/viewport.typ)     | A canvas larger than the slide, travelled over by panning.  | <a href="https://reproducible-reporting.github.io/animo/demos/viewport.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/viewport-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/viewport-handouts.pdf" target="_blank" rel="noopener">handouts</a>       |
| [`regions.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/regions.typ)       | Areas that reflow around a change inside a fixed footprint. | <a href="https://reproducible-reporting.github.io/animo/demos/regions.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/regions-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/regions-handouts.pdf" target="_blank" rel="noopener">handouts</a>          |
| [`morph.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/morph.typ)           | Paragraphs, equations and shapes that morph as they change. | <a href="https://reproducible-reporting.github.io/animo/demos/morph.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/morph-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/morph-handouts.pdf" target="_blank" rel="noopener">handouts</a>                |
| [`numbering.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/numbering.typ)   | Slide and subslide numbers, and a progress bar.             | <a href="https://reproducible-reporting.github.io/animo/demos/numbering.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/numbering-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/numbering-handouts.pdf" target="_blank" rel="noopener">handouts</a>    |
| [`handouts.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/handouts.typ)     | The states the handout keeps, and why to keep more.         | <a href="https://reproducible-reporting.github.io/animo/demos/handouts.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/handouts-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/handouts-handouts.pdf" target="_blank" rel="noopener">handouts</a>       |
| [`tour.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/tour.typ)             | Every feature of Animo in one deck.                         | <a href="https://reproducible-reporting.github.io/animo/demos/tour.html" target="_blank" rel="noopener">HTML</a> · <a href="https://reproducible-reporting.github.io/animo/demos/tour-presentation.pdf" target="_blank" rel="noopener">PDF</a> · <a href="https://reproducible-reporting.github.io/animo/demos/tour-handouts.pdf" target="_blank" rel="noopener">handouts</a>                   |

A deck opens in a new tab.
Step through the HTML version with the arrow keys or a click.
Most decks import the colors, the title slide, the styles and the slide wrapper they share
from the auxiliary file
[`_common.typ`](https://github.com/reproducible-reporting/animo/blob/v0.2.0/demos/_common.typ),
so a copy of such a deck needs `_common.typ` in the same directory.

## The Animo Logo

Animo exports its logo in two forms.
`animo-logo` draws the logo alone, as an image in any color.
`made-with-animo` draws a badge that places the logo beside the words "made with Animo".
Both take the color of the surrounding text, unless their `fill:` argument names a color.

If Animo helped you make a presentation, you are welcome to show the badge on your deck.
Showing it is optional, and a corner of the title slide is a good place for it:

```typst
#slide[
  = A Talk About Something
  #place(bottom + right, made-with-animo(height: 1cm))
]
```

The title slide of each demo deck that links to the guide shows the badge in white.

## Status

Animo is currently a proof of concept.
API stability is not strictly guaranteed before a 1.0 release, but no major breaking changes are planned.
Despite the version number, it already has enough features to make a complete presentation,
with a unique approach to animations.

## Where to Go Next

- [Presentation Author Guide](https://reproducible-reporting.github.io/animo/slides/),
  which covers everything from writing a slide up to what a deck costs to compile
- [Reference](https://reproducible-reporting.github.io/animo/reference/),
  every public name and its arguments
- [Animo Development Guide](https://reproducible-reporting.github.io/animo/development/),
  for changing Animo itself
- [planning/design.md](https://github.com/reproducible-reporting/animo/blob/v0.2.0/planning/design.md), the specification,
  including the reasoning behind every decision, and
  [planning/findings.md](https://github.com/reproducible-reporting/animo/blob/v0.2.0/planning/findings.md), the verified typst and browser behaviour it
  rests on
- [CONTRIBUTING.md](https://github.com/reproducible-reporting/animo/blob/v0.2.0/CONTRIBUTING.md)

## License

Apache-2.0. See [LICENSES/Apache-2.0.txt](https://github.com/reproducible-reporting/animo/blob/v0.2.0/LICENSES/Apache-2.0.txt).
