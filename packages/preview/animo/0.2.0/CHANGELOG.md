<!--
SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
SPDX-License-Identifier: Apache-2.0
-->

# Changelog

All notable changes to Animo are documented on this page.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Effort-based Versioning](https://jacobtomlinson.dev/effver/).

## [Unreleased]

(no changes yet)

## [0.2.0] - 2026-10-11

This release adds slide transitions and morphs.
It also moves the settings of a slide into its timeline,
so a deck written for 0.1.1 that passes such settings to `slide` needs small edits
before it compiles.
The main points for an upgrade are:

- Slides can enter with `push`, `cover`, `uncover` or `wipe` beside the crossfade.
  A slide sets its transition with `init(..)`,
  and the `transition:` argument of the show rule sets it for the whole deck.
- `transition: morph()` on a structural primitive moves the letters, shapes and images
  that both versions of a region share to their new places, and fades the rest.
- The HTML presentation lays out the body of a slide once,
  so a slide with several epochs is smaller, compiles faster and loads faster.
- **Breaking:** the `transition:`, `wait:`, `hold:` and `handout:` arguments move from `slide`
  to `init(..)` in the timeline, and a hard cut is written as `duration: 0`.
- **Breaking:** four smaller changes can alter an existing deck.
  They concern a stated `duration:` in a deck whose duration is zero,
  a structural primitive on a `wrap: none` tag outside a region,
  two regions that change inside one region, and a tag that is both moved and scaled.
  Each one is described under *Changes*.
- Most fixes concern the HTML presentation, such as gradients lost after a deep link,
  and slides with nested regions that failed to compile cleanly in every output type.

### Added

- Add `init(..)` to the timeline, which is about the initial state of a slide.
  It takes the transition into the slide as its first argument, and `duration:`, `wait:`,
  `hold:` and `handout:` as keywords.
  It is written at most once, before the first `sub`.
- Add the `push`, `cover`, `uncover` and `wipe` slide transitions beside the crossfade.
  Each takes a `direction`, which is `ltr`, `rtl`, `ttb` or `btt`.
  A step back over a slide boundary plays the transition of that boundary backwards.
- Add a transition function per transition to the `anim` module:
  `crossfade()`, `push(direction:)`, `cover(direction:)`, `uncover(direction:)`
  and `wipe(direction:)`.
  Typst refuses a misspelt parameter at the call, and an editor shows the parameters.
- Add a `transition:` argument to the show rule, which is the transition of every slide whose
  `init` names none, `anim.crossfade()` by default.
- Add a `transition:` argument to `replace`, `remove`, `apply` and `reset`,
  which names the transition that carries the changed region across the boundary.
  It takes `auto`, `crossfade()` or `morph()`.
- Add the `morph()` transition for a region, written as the `transition:` of a structural
  primitive.
  It moves the content that both versions of the region share to its new place
  and fades the rest.
  `init` and the show rule refuse it.
  The demo deck `morph.typ` shows it.
  The morph pairs the content of the two versions as follows:
  - Letters are matched by their shape, so a reflowing paragraph needs no tags.
  - Shapes and images are matched in reading order.
    A shape is matched when its outline and its stroke width are the same in both versions,
    whatever its color, and an image when it is the same image at the same size.
    What sits inside a clipped box is matched only when the box stays where it is.
  - A shape whose size changes while its kind stays is resized,
    such as the bar of a fraction that widens, a box that grows around its words
    or a circle that becomes an ellipse.
    Its outline and the width of its stroke change on the way, and rounded corners keep their
    shape.
    A shape is resized only into one between the same two matched neighbours
    and inside the same tags.
    Webkit, which does not animate the outline of a shape, fades it instead.
  - A shape turns into another of a different outline, such as a square into a circle,
    a star into a pentagon or an arrow into a line,
    when a tag that the primitive changes holds exactly one shape that is not matched otherwise
    before and after the step.
    The outline, the colors and the width of the stroke change on the way.
    Webkit fades the two shapes instead.
  - A tag moves as one piece, unless the primitive changes that tag or a tag inside it.
    The morph then matches the content inside the tag.
- Announce the position of the HTML presentation as events on the root element:
  `animo:position`, `animo:leave`, `animo:enter` and `animo:mode`.
  They are sent after the page, the URL fragment and the clock have been updated.
  The root element also carries the active input mode as `data-animo-mode`.
- Ignore key presses and clicks inside an element with the attribute `data-animo-control`.
- Write the `<title>`, the `lang` and the `<meta>` elements of the HTML presentation
  from `set document(..)` and `set text(lang: ..)`.
- Add a `handout` key to the dictionary a `per-subslide` callback receives,
  which says whether the handout keeps that subslide, in every output type.
- Add `output-type()`, which returns `"html"`, `"presentation"` or `"handout"`
  and gives the same answer inside a slide as outside one.
- Add `animo-logo(fill:, ..)`, which draws the logo of Animo as an image in any color,
  and `made-with-animo(fill:, height:)`, which draws a badge that places the logo beside the
  words "made with Animo".
  Both take the color of the surrounding text by default.
  The title slides of the demo decks show the badge.

### Changes

- **Breaking:** remove the `transition:`, `wait:`, `hold:` and `handout:` arguments of `slide`.
  They are written on `init(..)` in the timeline instead,
  as in `#slide(animation: anim.init(anim.push(), wait: 2))[..]`.
- **Breaking:** write a hard cut as a duration of zero, as in `init(duration: 0)`,
  rather than as `transition: none`.
  A duration of zero on a structural primitive is a hard cut of its region.
- **Breaking:** make `primitive-duration:` and `transition-duration:` of the show rule defaults.
  A primitive or an `init` that states a `duration:` now moves when the deck's
  duration is zero.
  In a deck with `transition-duration: 0`, a slide that names a transition has to state its
  `duration:` as well to be seen moving.
  A reader who asked for reduced motion still sees every step snap,
  because Animo signals reduced motion with the custom property `--animo-motion: none`
  instead of zeroing the two durations of the deck.
- **Breaking:** refuse a structural primitive on a `wrap: none` tag that no region holds,
  in every output type. The HTML presentation used to crossfade the whole slide for it.
  Give the tag a wrapper, as in `wrap: auto`, `box` or `block`, or put a region around it.
- **Breaking:** cross an epoch boundary with the outermost region around what changed.
  Two operations of one step that change two regions inside one region now have to agree
  about their timing and their transition, as two operations inside one region do.
- **Breaking:** a `scale` grows a tag from its anchor on an axis that a `move` placed with
  `x`, `y` or `relto`, so a tag that is both moved and scaled lands its scaled corner on the
  target.
  An axis that was never placed, or only shifted with `dx`/`dy`, still grows about the centre
  of the box.
  A deck that added half the growth as a `dx`/`dy` shift to land a scaled corner no longer
  needs it.
- Lay the body of a slide out once in the HTML presentation, and place an epoch stack of one
  rendering per epoch in every region whose content changes, instead of one rendering of the
  whole slide per epoch.
  A slide with several epochs is smaller, compiles faster and loads faster in the browser,
  most of all when little of it changes.
  The paged outputs are unchanged.
- Place the slides of the HTML presentation in a `.animo-stage` element inside `.animo-deck`.
  The stage is the visible rectangle, and it clips and isolates the crossfade between slides.
- Call the decks that demonstrate the features of Animo demo decks,
  and move them from `examples/` to `demos/`, on the site as well.
  Every page of the Presentation Author Guide has a demo deck that covers it,
  using only what that page and the pages before it explain,
  and the title slide of a demo deck links to that page.
  The decks `motion.typ`, `content.typ` and `pan.typ` are renamed to `continuous.typ`,
  `structural.typ` and `viewport.typ`,
  and `slides.typ`, `tags.typ`, `regions.typ`, `morph.typ` and `handouts.typ` are new.

### Fixes

- Draw a gradient and a clip path on every slide of the HTML presentation.
  A slide reached by a deep link, a reload or a step back lost them
  when another slide used the same gradient or clip path,
  which turned the gradient background recipe into white slides.
- Give pointer events only to the slide that is shown in the HTML presentation.
  After a step back, the slide that was just left stayed on top of the one shown
  and received the clicks meant for it.
- Pause and resume only the animations that Animo started.
  The pause key used to pause every animation of the page, including the animations of the author.
- Stop typst from warning "content labelled multiple times"
  for a tag or a `#place` in a region inside another region,
  on a slide with more than one epoch.
- Let three regions nest, and two regions inside a tag or with a `move` with `relto` on the slide.
  Such a slide used to fail to converge within the five passes of layout that typst allows.
- Scale a tag about the centre of its box in the HTML presentation, as the paged outputs do.
  The browser used to scale about the centre of the ink,
  so a scaled tag whose ink does not fill its box landed elsewhere than in the handout.
  Firefox placed that centre outside the ink when a path in the tag carried a `translate`.
- Crossfade a region without a blend in the HTML presentation.
  A region whose content changes used to carry `mix-blend-mode: plus-lighter`, also at rest,
  so the browser drew the region through a layer, which moved some glyph edges,
  and firefox drew every frame of a crossfade several times more slowly.
  The ink that both versions of a region share is now drawn once and stays as it is,
  and in chromium and firefox a region at rest is drawn exactly as the same content
  without a region.
  Where two different texts overlap, a crossfade now dissolves them as two layers
  rather than adding them.

## [0.1.1] - 2026-09-18

### Fixes

- Reduce the typst dependency from 0.15.1 to 0.15.0.
- Simplify package build script.

## [0.1.0] - 2026-09-17

This is the initial release of Animo.

[0.1.0]: https://github.com/reproducible-reporting/animo/releases/tag/v0.1.0
[0.1.1]: https://github.com/reproducible-reporting/animo/releases/tag/v0.1.1
[0.2.0]: https://github.com/reproducible-reporting/animo/releases/tag/v0.2.0
[unreleased]: https://github.com/reproducible-reporting/animo
