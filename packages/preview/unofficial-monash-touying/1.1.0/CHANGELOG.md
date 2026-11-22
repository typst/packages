# Changelog

## 1.1.0

No breaking changes. Decks written for 1.0.0 compile unchanged.

### New

- `show-monash-frames(labels: ..)` renames environments, "Proof", and the
  ending slide's "Thank you", for shorter names or another language.
- Authors with affiliations: `config-info(author: ..)` accepts
  `(name: .., affiliation: ..)` dictionaries, and `institution` an array.
  The title slide numbers the institutions and marks each name.
- Option `math-font`.
- `show-monash-frames(style: "plain")`: a lighter frame with a rule at the
  left and the name in colour, without a header bar.
- `monash-frame` makes your own environments, activated with
  `show-monash-frames(extra: ..)`.
- `numbered: false` on a single frame, such as
  `#theorem(numbered: false)[..]`.
- Links in both directions: the name of a referenced target ("Theorem 1",
  "Table 2", the number of an equation, anchored text) links back to the
  slide that refers to it, when exactly one other slide does. Turn off with
  `monash-theme(backlinks: false)`.
- `anchor` marks any text as a place to go to and `goto` links to it, with
  the same link back.

### Changed

- References, citations, and other links inside the deck are blue, so that
  every link can be told from ordinary text.
- `exercise` frames are purple and `warning` frames red, so that they differ
  from `example` and read as a warning.
- A proof has a grey rule at the left, in line with the frames, and its end
  mark sits on the line of a closing display equation.
- `ending-slide(title:)` defaults to `auto` instead of the text "Thank you";
  the slide looks the same in an English deck.

## 1.0.0

A general-purpose release with a stable, Typst-style API. Requires Typst
0.15.0 or newer.

### Breaking changes

- Options are renamed to kebab-case: `fontsize` → `font-size`,
  `titlefontsize` → `title-font-size`, `titlecolor` → `title-color`,
  `titlegraphic` → `title-graphic`, `toc` → `outline`. The old names stop
  with an error that names the replacement.
- `toc-args`, `brand-motif`, `motto`, and `progress-position` are removed.
- `title-graphic` no longer accepts a path string, because the path was
  resolved inside the package; pass `image(..)`.
- The default font is Typst's built-in font (`font: auto`) instead of Arial,
  so decks compile without warnings on every platform. Use `font: "Arial"`
  for the previous look.
- A single-argument environment call is now the body: `#theorem[X]` renders
  X as the statement without a title, whereas 0.1.x treated X as the title.
  Write `#theorem[Title][Body]` for both, or `#theorem[Title][]` for a title
  alone. `proof` follows the same rule.
- `note` and `warning` are no longer numbered.
- The package exports a fixed list of names instead of all of Touying.
- Unknown `monash-theme` options are an error.
- Dependencies: Touying 0.8.0 (was 0.7.3), frame-it 2.1.0 (was 2.0.0),
  zebraw 0.6.3.

### New

- Options `font`, `code-font`, `accent-color`, `section-slides`,
  `slide-numbering`, and `footer`.
- `logo` shows your logo in the top-left corner of the title and ending
  slides and on a white panel at the right of the title bar. A dictionary
  `(cover: .., bar: .., bar-fill: ..)` chooses an image per place and the
  panel colour (`none` for a white logo on the blue bar). Logos are scaled
  to fit each place.
- Slide kinds `outline-slide`, `focus-slide`, and `ending-slide`;
  `new-section-slide` is exported.
- Environments `proposition`, `assumption`, `example`, and `exercise`;
  `show-monash-frames(shared-counter: true)`; `#theorem[Body]` without a
  title; `#proof[Body]` and `#proof[Title][Body]`; references show the
  shared number, or the name alone when numbering is off.
- A plain cover drawn with shapes for `title-graphic: none`.
- Compact bibliographies that continue onto further slides, and support for
  Touying's `show-bibliography-as-footnote`.
- A speaker-note panel in theme colours.
- Four example decks, a test suite, and a CI workflow.

### Fixed

- A long title no longer overlaps the author block on the title slide.
- A long slide heading shrinks and wraps instead of being clipped.
- Paragraphs, lists, and equations inside frames no longer overlap.
- Footnotes sit above the footer.
- `progress-bar: false` and `logo` take effect (in 0.1.x `logo` was stored
  but never shown).
- Appendix sections are lettered, left out of outlines, and not counted in
  the slide total.
- A frame on a slide with `#pause` is counted once.
- Long inline code breaks across lines instead of wrapping inside its box;
  inline code in a slide heading or on a focus slide has no code box.
- A level-three heading at the bottom of a page moves to the next page with
  its content.
- With many sections (up to 12) the outline slide and every section divider
  fit on one page.
- Nested list levels have distinct markers and sizes; the slide number is
  larger and darker.

## 0.1.3

### Fixed

- Numbered lists render without a type error.
