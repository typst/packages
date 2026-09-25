# Slydekit

[![Generic badge](https://img.shields.io/badge/Version-0.4.0-cornflowerblue.svg)](https://github.com/maucejo/slidekit/releases/tag/0.4.0)
[![MIT License](https://img.shields.io/badge/License-MIT-forestgreen)](https://github.com/maucejo/slydekit/blob/c1a03c1dae9844e88899df0c017863304cdbb0ff/LICENSE)
[![Stable documentation](https://img.shields.io/badge/docs-stable-mediumpurple)](https://maucejo.github.io/slydekit/)

<p align=center>
<b><em>Simple yet powerful slides</em></b>
</p>

Slydekit is a Typst presentation framework designed to make slide creation simple and flexible. Its theme system, inspired by Bookly, makes it straightforward to design and integrate new themes.

Presentations are built directly from document headings, with five predefined themes included out of the box. Slydekit offers a lightweight but complete set of tools for incremental content reveals, slide navigation, styled boxes, and citation handling. The entire framework relies on Typst’s native state and query system, avoiding the need for an additional templating layer.

## Import and initialization

Slydekit is used as a #show rule at the top of your document. Everything else in the file is written as ordinary Typst content: headings become sections and slides, and no #slide[...] wrapper is required.

```typ
#import "@preview/slydekit:0.4.0": *

#show: slydekit.with(
  title: "Title",
  subtitle: "Subtitle",
  short-title: "Short-title",
  author: "John Doe",
  date: "31 July 2026",
  institution: "Your institution",
  theme: metropolis,
  lang: "fr",
  aspect-ratio: "16-9",
  navigation-style: "topbar",
)

#title-slide

= Introduction

Some introductory content.

== A first slide

This is a slide, created automatically from the level-2 heading above.
```

Every argument to `slydekit(..)` is optional and falls back to a sensible default:

| Argument | Purpose |
|---|---|
| `title`, `subtitle`, `short-title`, `author`, `date`, `institution`, `contact` | Front-matter shown on the title slide |
| `theme` | `metropolis`, `simple`, `fancy`, `cambfurt`, `chalkboard` |
| `fonts` | Dictionary overriding `body`, `math`, `raw` fonts |
| `colors` | Dictionary overriding any of the theme's colors |
| `lang` | `"fr"`, `"en"` — drives both `set text` and the built-in localization strings |
| `aspect-ratio` | `"16-9"` or `"4-3"` |
| `navigation-style` | `"topbar"` or `"minislide"` |
| `title-logo`, `slide-logo` | Logo(s) for the title page and the running footer |
| `section-numbering` | Enables automatic numbering for sections and slides |
| `numbering-pattern` | Customizes the numbering formats for sections and appendices |
| `handout` | Handout mode |
| `slide-level` | The level of the slide in the document hierarchy |
| `slide-align` | The alignment of the slide content |
| `extra-info` | Additional information to display on the slide |

Structuring content is purely heading-driven:

- a level-1 heading (`= Section`) opens a new section and resets the progress indicators;
- a level-2 heading (`== Slide title`) opens a new slide, equivalent to calling `#slide[...]` directly;
- `#slide(steps: n)[...]` can be used explicitly when a slide needs a manual override on its number of reveal steps, or a `label:` for cross-referencing with `@ref`.

Section and slide numbering can be enabled with `section-numbering: true`. By default, regular sections and slides use the `"1.1."` pattern, while appendix sections and slides use `"A.1."`. These formats can be customized with `numbering-pattern`, for example:

```typ
#show: slydekit.with(
  section-numbering: true,
  numbering-pattern: (
    section: "1.1",
    appendix: "A.1",
  ),
)
```

## Disclaimer

Slydekit borrows or adapts some of the codes provided by Polylux and Touying for implementing some slide elements. This covers:

- animation: Slydekit slightly adapts the `item-by-item` and `alternatives` functions from Polylux.

- outline: Slydekit adapts and extends the `progressive-outline`, `mini-slides` and `adaptive-columns` from Touying.

## Main features

**Automatic, document-first slide creation.** Slides come from headings, so a talk reads like a normal Typst document. `#slide` is still available for explicit control (custom step counts, labels).

**A full incremental-reveal vocabulary, all built on one primitive.** `#pause`, `#uncover(..)`, and `#only(..)` behave like their Beamer/Touying equivalents. Everything else in the vocabulary is a thin wrapper around that same `uncover`/`only` mechanism rather than a parallel implementation, so it inherits its correctness and its `cover-fn` hook automatically:

- `item-by-item(start: n, body)` does the same for a `list`, `enum`, or `terms` block. It filters the direct children for `list.item`/`enum.item`/`terms.item` and reveals each in place, without ever reconstructing the container, so native list styling (markers, spacing, `#set list(..)`) is untouched
- `alternatives(start: n, repeat-last: bool, ..options)` shows one option per step in the same footprint, with `repeat-last: true` keeping the final option on screen instead of disappearing once its step is past.
- `#meanwhile` splits a slide's top-level flow into parallel tracks at the point it's used, each with its own local `#pause` chain, advancing on the same subslide clock instead of one long concatenated sequence. This reproduces Touying's `#meanwhile` directly: `First #pause Second #meanwhile Third #pause Fourth` shows *First, Third* on the first step and all four on the second
- `track(body)` splits its own content at `#pause` independently of the slide's main flow, so two adjacent columns (typically inside a `#grid(..)`) can each carry their own pause sequence, synchronized on the same subslide clock rather than concatenated into one long chain
- `draw-reveal(..)` exposes the same step logic as a plain boolean instead of content, so CeTZ drawings or Fletcher diagrams can conditionally show elements and still reserve their layout space via a `hide-fn` callback (`cetz.draw.hide(bounds: true)`, for instance). It replaces the former `reveal(..)` helper
- `code-reveal(..)` progressively reveals and highlights lines of a code block. It supports the built-in `raw-renderer`, `codly-renderer`, and `zebraw-renderer`, as well as custom renderers
- `uncover`/`only` also accept a `cover-fn` argument for the same purpose when the content being hidden isn't a boolean-gated diagram but ordinary content that a third-party package wants to mask its own way

**Five built-in themes sharing one architecture.** `metropolis`, `simple`, `fancy`, `cambfurt`, and `chalkboard` (with a color variant) each define the same six-function contract: `theme`, `title`, `toc`, `focus-slide`, `link-box`, `boxeq`, `custom-box`. Because a theme is just a dictionary, any theme merges onto `metropolis` as a base, so a partial custom theme only needs to override the pieces it actually changes.

**Two navigation styles, computed automatically.** `"topbar"` shows the current slide title in a running header; `"minislide"` shows a live, per-section mini-outline (`mini-slides()`) with dots tracking the active slide, built entirely from heading and slide queries, no manual bookkeeping.

**Section-aware progress and outline tools.** `section-progress-bar`, `slide-progress-bar`, `tableofcontents`, and `progressive-outline(..)` (a per-slide "you are here" outline with independent numbering for the appendix) all read directly from the document's heading tree.

**A first-class appendix.** `#appendix[...]` restarts slide numbering under an `A.1`-style scheme, and every navigation and outline helper (mini-slides, `show-ref`, `progressive-outline`) is aware of whether a given slide belongs to the main talk or to the appendix.

**Citation and footnote helpers.** `footcite(key)` prints a superscript citation call and silently attaches the full reference as a footnote, for slides where a running bibliography page is impractical.

**A consistent box library.** `info-box`, `tip-box`, `warning-box`, `important-box`, `proof-box`, `question-box`, `code-box`, and the generic `custom-box` share one visual language per theme, colored and iconized consistently.

**Small layout utilities that solve real slide problems.** `adaptive-columns` chooses 1–3 columns depending on measured content height, `full-width` lets a block bleed to the page edge regardless of margin shape, `row-img` lays out one to many logos with sensible left/center/right alignment, and `short-or-long` displays long title in `tableofcontents` slides and the short version in the `minislide` navigation style.

**Localization out of the box.** Strings such as "Outline", "Note", "Tip", or "Proof" are pulled from a JSON dictionary keyed by `lang`, currently covering Chinese, English, French, German, Italian, Spanish and Portuguese.

## Themes at a glance

| Theme | Description |
|---|---|
| `metropolis` | Beamer-mtheme inspired: dark header/footer bar, orange accent, progress bar |
| `simple` | Minimal, no background fill, blue accent |
| `fancy` | Warm red-on-slate palette, Lato/Cascadia Code |
| `cambfurt` | Deep red academic look, no background fill |
| `chalkboard` | Light-blue (or red, via `chalkboard-colors-variant`) on a Pennstander-set "handwritten" typeface |

Any theme's colors and fonts can be overridden per presentation via the `colors` and `fonts` arguments to `slydekit(..)`, without needing to fork the theme file.

## Dependencies

* `showybox:2.0.4` : for custom boxes.

## Licence

MIT licensed

Copyright © 2026 Mathieu AUCEJO (maucejo)

