# Changelog

All notable changes to this package are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), the numbering
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — unreleased

First release.

### The idea

One Typst file becomes an animated HTML talk and a PDF handout. Typst sets,
the browser moves: magic-move morphing, staggered reveals, slide transitions,
media, and GeoGebra applets that follow the steps of the slide.

### What is in it

- **Two notations for a deck.** Headings, or `slide()` calls as arguments —
  the same deck either way.
- **Revealing.** `#pause`, `anim`, `stagger`, `alternatives`, `build`, `cue`
  and `scene`, all counted in steps rather than pages.
- **Moving.** `morph` carries a shape from where it stood to where it now
  stands — between slides and, since it grew the second half, from step to
  step within one. `pin` pairs what an outline alone would mispair.
- **Layout.** `card`, `callout`, `side-by-side`, `tiles`, `statement`, `fit`.
- **Media.** `video`, `flipbook`, `embed`, and a bridge that posts jobs into an
  embedded document step by step. `typstage-geogebra` builds on it.
- **Five themes and five palettes**, each measured against a contrast contract
  of seven pairs before it ships.
- **A speaker view** in a second window: the current slide as the drawing
  surface, the note beside it, elapsed time, the planned length, a class clock,
  a preview of the next step, and a pen. `speaker-view` says what of it to
  show.
- **A PDF from the same source**: one page per slide, every tracked element in
  its final state, and a handout of up to six slides per page.

### Known limits

- Typst's HTML export is experimental; every HTML run needs `--features html`.
- The manual is fuller in German than in English.
- GeoGebra is not in the box: a typeset applet fetches it at run time and
  stands under GeoGebra's own terms.
