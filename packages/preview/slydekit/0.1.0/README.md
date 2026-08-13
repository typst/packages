# Slydekit

[![Generic badge](https://img.shields.io/badge/Version-0.1.0-cornflowerblue.svg)](https://github.com/maucejo/slidekit/releases/tag/0.1.0)
[![MIT License](https://img.shields.io/badge/License-MIT-forestgreen)](https://github.com/maucejo/slydekit/blob/a1f47a7bf38311d8b8fe77e826f6cb54396fa630/LICENSE)
[![Stable](https://img.shields.io/badge/docs-stable-mediumpurple)](https://maucejo.github.io/slydekit/)

Slydekit is a Typst presentation framework designed to make slide creation simple and flexible. Its theme system, inspired by Bookly, makes it straightforward to design and integrate new themes.

Presentations are built directly from document headings, with five predefined themes included out of the box. Slydekit offers a lightweight but complete set of tools for incremental content reveals, slide navigation, styled boxes, and citation handling. The entire framework relies on Typst’s native state and query system, avoiding the need for an additional templating layer.

## Import and initialization

Slydekit is used as a #show rule at the top of your document. Everything else in the file is written as ordinary Typst content: headings become sections and slides, and no #slide[...] wrapper is required.

```typ
#import "@preview/slydekit:0.1.0": *

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
| `handout` | Handout mode |

Structuring content is purely heading-driven:

- a level-1 heading (`= Section`) opens a new section and resets the progress indicators;
- a level-2 heading (`== Slide title`) opens a new slide, equivalent to calling `#slide[...]` directly;
- `#slide(steps: n)[...]` can be used explicitly when a slide needs a manual override on its number of reveal steps, or a `label:` for cross-referencing with `@ref`.

## Disclaimer

Slydekit borrows or adapts some of the codes provided by Polylux and Touying for implementing some slide elements. This covers:

- animation: Slydekit slightly adapts the `item-by-item` and `alternatives` functions from Polylux.

- outline: Slydekit adapts and extends the `progressive-outline` and `mini-slides` and borrows `adaptive-columns` from Touying.

## Main features

**Automatic, document-first slide creation.** Slides come from headings, so a talk reads like a normal Typst document. `#slide` is still available for explicit control (custom step counts, labels).

**A full incremental-reveal vocabulary, all built on one primitive.** `#pause`, `#uncover(..)`, and `#only(..)` behave like their Beamer/Touying equivalents. Everything else in the vocabulary is a thin wrapper around that same `uncover`/`only` mechanism rather than a parallel implementation, so it inherits its correctness and its `cover-fn` hook automatically:

- `item-by-item(start: n, body)` does the same for a `list`, `enum`, or `terms` block. It filters the direct children for `list.item`/`enum.item`/`terms.item` and reveals each in place, without ever reconstructing the container, so native list styling (markers, spacing, `#set list(..)`) is untouched
- `alternatives(start: n, repeat-last: bool, ..options)` shows one option per step in the same footprint, with `repeat-last: true` keeping the final option on screen instead of disappearing once its step is past.
- `#meanwhile` splits a slide's top-level flow into parallel tracks at the point it's used, each with its own local `#pause` chain, advancing on the same subslide clock instead of one long concatenated sequence. This reproduces Touying's `#meanwhile` directly: `First #pause Second #meanwhile Third #pause Fourth` shows *First, Third* on the first step and all four on the second
- `track(body)` splits its own content at `#pause` independently of the slide's main flow, so two adjacent columns (typically inside a `#grid(..)`) can each carry their own pause sequence, synchronized on the same subslide clock rather than concatenated into one long chain
- `reveal(..)` exposes the same step logic as a plain boolean instead of content, so CeTZ drawings or Fletcher diagrams can conditionally show elements and still reserve their layout space via a `hide-fn` callback (`cetz.draw.hide(bounds: true)`, for instance)
- `uncover`/`only` also accept a `cover-fn` argument for the same purpose when the content being hidden isn't a boolean-gated diagram but ordinary content that a third-party package wants to mask its own way

**Five built-in themes sharing one architecture.** `metropolis`, `simple`, `fancy`, `cambfurt`, and `chalkboard` (with a color variant) each define the same six-function contract: `theme`, `title`, `toc`, `focus-slide`, `link-box`, `boxeq`, `box`. Because a theme is just a dictionary, any theme merges onto `metropolis` as a base, so a partial custom theme only needs to override the pieces it actually changes.

**Two navigation styles, computed automatically.** `"topbar"` shows the current slide title in a running header; `"minislide"` shows a live, per-section mini-outline (`mini-slides()`) with dots tracking the active slide, built entirely from heading and slide queries, no manual bookkeeping.

**Section-aware progress and outline tools.** `section-progress-bar`, `slide-progress-bar`, `tableofcontents`, and `progressive-outline(..)` (a per-slide "you are here" outline with independent numbering for the appendix) all read directly from the document's heading tree.

**A first-class appendix.** `#appendix[...]` restarts slide numbering under an `A.1`-style scheme, and every navigation and outline helper (mini-slides, `show-ref`, `progressive-outline`) is aware of whether a given slide belongs to the main talk or to the appendix.

**Citation and footnote helpers.** `footcite(key)` prints a superscript citation call and silently attaches the full reference as a footnote, for slides where a running bibliography page is impractical.

**A consistent box library.** `info-box`, `tip-box`, `warning-box`, `important-box`, `proof-box`, `question-box`, `code-box`, and the generic `custom-box` share one visual language per theme, colored and iconized consistently.

**Small layout utilities that solve real slide problems.** `adaptive-columns` chooses 1–3 columns depending on measured content height, `full-width` lets a block bleed to the page edge regardless of margin shape, `row-img` lays out one to many logos with sensible left/center/right alignment, and `short-or-long` displays long title in `tableofcontents` slides and the short version in the `minislide` navigation style.

**Localization out of the box.** Strings such as "Outline", "Note", "Tip", or "Proof" are pulled from a JSON dictionary keyed by `lang`, currently covering Chinese, English, French, German, Italian, Spanish and Portuguese

## Comparison with Touying and Polylux

Touying and Polylux are the two most established presentation packages in the Typst ecosystem, and Slydekit deliberately sits close to both in spirit: heading-driven slides, `#pause`/`#uncover`/`#only` semantics, and a theme system. The differences are mostly a matter of scope and defaults.

### Comparison table

| | **Slydekit** | **Touying** | **Polylux** |
|---|---|---|---|
| Slide creation | Heading-driven (`=`, `==`), plus explicit `#slide(..)` for overrides | Heading-driven, plus a richer `#slide[..]` API (waypoints, callback-style animations, cover mode) | Explicit `#slide[..]` calls; headings are not slides by themselves |
| Animation primitives | `#pause`, `#meanwhile`, `#uncover`, `#only` (with a `cover-fn` hook), plus `one-by-one`, `item-by-item`, `alternatives`, `track` for parallel pause chains, and a boolean `reveal()` for CeTZ/Fletcher | `#pause`, `#meanwhile`, `#uncover`, `#only`, `#alternatives`, math-equation animations, native CeTZ/Fletcher integration | `#pause`, `#uncover`, `#only`, plus a lower-level overlay API that most themes build on |
| Built-in themes | 5 (`metropolis`, `simple`, `fancy`, `cambfurt`, `chalkboard`), sharing one merge-onto-`simple` contract | 6 built-in (`simple`, `metropolis`, `dewdrop`, `university`, `aqua`, `stargazer`) plus a large third-party catalogue on Typst Universe | 1 minimal `simple` theme in core; most visual variety comes from independent community packages (e.g. `metropolis-polylux`, `rectangles-polylux`, `helios-polylux`) |
| Navigation / outline | `topbar` or `minislide`, both auto-generated from headings; `progressive-outline` for per-slide mini-TOC | Rich navigation and progress components as part of its component library, theme-dependent | Left to individual themes; core Polylux stays low-level |
| Appendix handling | First-class `#appendix[..]` with independent numbering and appendix-aware navigation | Supported via slide recall / appendix patterns, more manual | Not built in; left to the user or a theme |
| Speaker notes, PPTX/HTML export | Through external packages like presio | Yes — dual-screen speaker notes, PDF/PPTX/HTML export via companion tools | Yes — pdfpc integration for speaker notes and timers |
| Theming model | Fixed functions contract (`theme`, `title`, `toc`, `focus-slide`, `link-box`, `boxeq`, `box`) per theme, merged onto `simple` as a base | A `self` dictionary threaded through the whole rendering pipeline (`utils.merge-dicts` of `config-colors`, `config-info`, `config-page`, `config-common`, ...). Any custom function that wants `self` must be wrapped in `touying-fn-wrapper`/`touying-slide-wrapper`, but in exchange, any new piece of shared config is just a new key in that dictionary, no plumbing required elsewhere | No shared contract in core; themes are separate community packages |
| Scope | Academic-presentation features pre-wired: citations, appendix, boxes, bilingual localization | Broad, general-purpose slide framework, largest feature surface of the three | Minimal core, intentionally low-level, designed to be built upon |

### Summary

Polylux, Touying, and Slydekit represent three distinct approaches to building presentations in Typst. Polylux provides a lightweight, modular core that focuses on presentation mechanics while leaving themes and higher-level components to companion packages. Touying and Slydekit both aim to deliver complete presentation frameworks out of the box, but they pursue that goal through different architectural choices.

Touying centers its design around a shared `self` object that is threaded throughout the rendering pipeline. Any function—including those provided by themes or third-party packages—can declare itself `touying-fn-wrapper`-aware and access or extend this shared configuration without requiring changes elsewhere in the framework. This makes Touying highly extensible, at the cost of a more involved wrapper-based API.

Slydekit instead builds on Typst's native `context`, `state`, and `query` mechanisms. Shared presentation state, such as colors, fonts, or the current subslide index, is exposed directly through Typst rather than collected into a dedicated configuration object. As a result, animation primitives such as `#pause`, `#meanwhile`, `#uncover`, and `#only`, together with the higher-level constructs built upon them, behave as ordinary Typst functions without requiring wrapper objects or special calling conventions.

This does not prevent users from introducing their own persistent state. Theme authors and helper functions can freely declare additional `state()` or `counter()` values whenever needed, independently of Slydekit's core. The only information managed centrally by Slydekit is the state that must remain synchronized with the presentation lifecycle. For example, values initialized once per presentation or updated once per subslide. The difference therefore lies less in extensibility itself than in how shared state is organized. Touying centralizes it in a single configurable object, whereas Slydekit keeps it decentralized and relies on Typst's built-in mechanisms.

Despite these architectural differences, the animation capabilities of Touying and Slydekit are intentionally very similar. Slydekit provides `#pause`, `#meanwhile`, `#uncover`, `#only`, `one-by-one`, `item-by-item`, `alternatives`, `track`, and `reveal`, covering the same core incremental-reveal use cases as Touying, including synchronized parallel reveal chains and incremental mathematical expressions. Where the two projects differ is primarily outside the animation system, since Touying also includes export tooling (PPTX and HTML) and speaker-note support, whereas Slydekit deliberately focuses on PDF presentations and leaves these capabilities to external packages such as Presio.

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

