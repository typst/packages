# Changelog

All notable changes to this package are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), the numbering
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] — unreleased

### Added

- **A footnote's note is revealed with its marker.** A footnote standing inside
  a reveal chain now has its note appear on the same step in the browser, so the
  foot of the slide gives nothing away that the talk has not shown yet. Its
  place is held from the start, so nothing jumps when it arrives. On paper it
  stands from the slide's first step, as before. The step is not carried
  anywhere: `track` lays two reads of `counter(footnote)` around its own body
  and reports the *span* of numbers that fall between them; the overlay takes,
  for each note, the narrowest span containing its number, so a footnote inside
  an `anim` inside a `stagger` gets the step of the `anim`. A footnote in no
  chain finds no span and stands from step one. In the browser the note is no
  longer drawn in the background at all: the background punches a slot the size
  of the line, holding the place and carrying the marker, and the ink comes from
  the overlay. There is therefore exactly one place that draws note ink, and
  nothing that could double. Five earlier attempts of mine all broke the same
  rule, measured: as soon as a value read from the running slide lands in a
  sprite record, the document stops converging -- provided another slide
  follows. A known limit comes with it: block content with an alignment of its
  own inside a note -- a displayed equation, a `figure`, an `#align(center)` --
  reaches both outputs but not the same place, centred in the browser and at the
  start of the line on paper.

- **`#footnote` works on a slide.** It is written as it always was and stands
  at the foot of *its slide*, under a short rule, numbered from one on every
  slide. Reported from a deck where it had squeezed itself into the bottom and
  pushed the content onto a new slide. Typst's own footnote machinery cannot
  work here and is switched off for a deck: it puts its entries at the foot of
  the *text area*, and a slide is a block of exactly page height that leaves
  nothing there. Measured on three slides with one footnote: four pages instead
  of three, the note alone on a page *before* the slide that names it, and in
  the browser on no slide at all. The deck sets the note itself now, in all
  three outputs -- browser, PDF and the handout beside its slide -- and it finds
  footnotes inside the reveal chains too. That last point cost the first
  attempt: a walk through the slide body before it is laid out finds a footnote
  only where it is written, and `stagger` returns a `context`, into which no
  walk can see -- of two footnotes in a `stagger` it found none while both
  markers stood in the type. The notes are therefore asked for by query,
  filtered by slide *and* page: by slide alone they stood three times over
  under `pages: "step"`, by page alone a handout sheet would carry the notes of
  every slide on it. Two new labels, `ts-slide-notes` and `ts-slide-notes-rule`.
  A footnote in a slide *title* now stops the compilation and says why: the
  title is repeated as a running head, in the contents and in the speaker view,
  and every repetition set the footnote again -- the slides after it carried
  the note of their section title instead of their own.

- **Decks that read from the right.** `#set text(lang: "fa")` before the show
  rule, or `#set text(dir: rtl)`, turns the whole slide around. The slide body
  was placed with `place(top + left, …)`, and that alignment beat the `start`
  every paragraph resolves for itself: every line sat on the left while the
  lists and columns around it were already mirrored. The body now hands down
  `start`; the title in its band, the bar beside a `callout`, the footer
  number, the progress bar and the title and section slides mirror along; the
  moving parts carry the direction into their own frames; and a `callout`
  without a title reads its caption in Arabic, Persian or Hebrew. Reported on
  the forum from a Persian deck. Decks that read from the left come out byte
  for byte as before.
- **`build(at: …)`.** A drawing whose stages do not come one click after
  another. `at: (1, 9)` gives two stages, the second from step 9 on, and the
  first holds until then. Until now a stage lay fixed on `start + i`, so a
  picture due on step 9 needed `steps: 9`, and the eight identical stages
  before it were all typeset. Measured on a slide with three diagrams that are
  discussed one after another: ten sprites instead of 22, and the file 2.98 MB
  instead of 3.45 MB. `from` keeps counting stages rather than steps, because
  under `start: auto` a deck cannot know its own step numbers. Reported with a
  worked case; `steps` and `start` are refused beside `at`, rather than
  silently losing to it.

- **`contents()` -- a table of contents that jumps.** One call sets a directory
  of the section slides, and every entry links to its slide: `layout` puts the
  entries in one column or two (`"1x2-fill"` fills the first before flowing
  into the second), `from` and `to` pick a range, `number` and `title` take
  render functions of your own. A section slide carries a link back. Numbers
  come from `section-numbering`, off by default; give it a numbering pattern or
  a function of the section number to switch it on. Contributed as a pull
  request and rebuilt: the entries now take the deck's own palette rather than
  a fixed pair of colours, and the contrast contract holds for them like for
  everything else.
- **`contents(indent: …)` and `contents(highlight: true)`.** A deck with more
  than one structure level now indents the deeper entries instead of setting
  them flush, where two entries could carry the same number and the outline
  said nothing about its own shape; `indent: none` brings the old flat setting
  back. `highlight: true` says where the talk stands -- the running part and
  chapter keep the full ink, everything before and after steps back, which is
  the agenda between two parts. Every entry also carries `when` (`"past"`,
  `"running"`, `"coming"`), so a highlight of your own needs no arithmetic:
  the comparison against `info().levels` was already described in the docs and
  is now done for you. Asked for after 0.1.1 went up for review.
- **A step bar under every tile in the overview.** One field per step: hovering
  shows that step in the tile, clicking jumps straight to it, the running step
  carries the accent. The lower third of a tile belongs to the bar, the upper
  two thirds go to the start of the slide. Slides with a single step have
  nothing to choose and get no fields -- of fourteen tiles in the tour, nine
  would have carried an empty bar. The pinned clock can be resized at its
  edges, too; the middle still moves it, and the cursor says beforehand which
  of the two a drag would do.
- **`pages: "step"` -- a PDF that unfolds.** The PDF has one page per slide and
  every tracked element in its final state; `pages: "step"` gives one page per
  step instead, so the paper turns the way the talk does. Asked for on the
  forum. `#pause`, `anim`, `stagger`, `tiles`, `alternatives`, `build`, `cue`
  and `scene` all take part -- a scene has one page per stop, not per tween
  frame. Hidden pieces keep their space, so nothing reflows from page to page.
  A camera move is left out: on paper there is no camera, and its page would
  stand there twice; in this mode it claims no step of its own. The example
  decks run about 2 to 3 pages per slide.

  The default is unchanged, down to the check deck's byte count. On the way
  three feedback loops had to go, all of the same shape -- the page count must
  not depend on anything that only comes into being while the pages are being
  set, or the document never converges. The step count per slide is therefore
  a state and not a mark (a mark would be laid down again by every page, and
  its count would grow with them), and `alternatives`, `build` and `scene` now
  hand their versions to `track` on paper as well, rather than picking one
  themselves.
- **The manual says how to write with a live deck.** Since Typst 0.15 `typst
  watch` carries its own HTTP server and puts a live-reload line into the page
  it serves. A new section, *While you write*, gives the command, a VS Code
  build task that runs it for the file in front of you, and the fact that makes
  it usable during a talk: the deck comes back on the step it was on, because
  the step stands in the address and is read on load. The section on embedding
  now says what to do when the document to be shown is itself a Typst document
  -- give its content a name and import it instead of framing it. It then
  arrives as the deck's own content: same fonts, sharp at any size, in the PDF,
  and revealable step by step. A frame can do none of that.

### Changed

- **`cue()`: one group, many calls -- and a group belongs to one slide.** A group
  is held together by its name, not by a single call: every `cue("name")[…]`
  contributes points and sets them where it stands, so placing a point freely is
  no longer a special case but simply what happens. Numbers count on across the
  calls of one slide; `start:` and `spacing:` apply per call, and between two
  calls the layout decides. The same name on the next slide is a new group that
  starts again at `1`, so every exercise slide can say `cue("marks", …)` without
  numbering the names apart. `cue-layer` now points at a declared point rather
  than at a number within a span. A tenth point on one slide is refused: the room
  calls with the keys 1 to 9, and a digit with nothing behind it silently becomes
  an ordinary page turn.
- **The runtime files are now `typstage-0.1.1.css` and `typstage-0.1.1.js`.**
  The name carries the version so a CDN can hold several releases side by side
  and no browser serves a stale one from its cache. A deck with
  `assets: "split"` or a CDN writes them out from `runtime-files` and never
  types the name itself; one that inlines them, the default, notices nothing.

### Fixed

- **A footnote inside a reveal chain carried the wrong number in the browser.**
  The body of a tracked element is laid out twice there -- hidden in the
  background and again as its sprite in the overlay, which is the copy the
  viewer sees -- and `counter(footnote)` advanced in both. Measured on three
  footnotes, two of them inside a `stagger`: the markers read 1, 4, 5 while the
  notes beneath them read 1, 2, 3. On paper there are no sprites and the
  numbering was right. The sprite now carries the *place* at which its body
  begins in the background, and sets the counter from it before laying the body
  out again. A place and not a number, and that is the whole difference: a
  recorded counter value would be read back out of the state that the overlay
  then writes the same counter from -- a circle that gains a link per nesting
  level, measured as "value of counter(footnote) did not converge". A place
  follows the structure of the document and stands from the first run.

- **A footnote inside a reveal chain was noted twice.** The body of a tracked
  element is laid out a second time in the browser, as its sprite in the
  overlay, and the note at the foot of the slide was taken from both copies:
  measured, five notes for three footnotes, the two inside a `stagger` twice
  over. On paper there are no sprites and it did not show. The slide now leaves
  the sprite copies out. The numbering of the markers themselves is a separate
  matter and still wrong in the browser for a footnote inside a reveal.

- **An embedded frame was scaled twice in WebKit.** `embed` spans its frame in
  slide points and scales it onto the stage, so that every window shows the
  same crop. That was done with `zoom`, and WebKit applies `zoom` on an iframe
  to the element box *and*, once more, to the painting of the document inside
  it: the content landed at the square of the scale. Measured in Safari 26.4
  at 0.3, where a guest filled 30 % of its frame instead of all of it.
  Reported from a lesson deck with a live preview beside it, where the speaker
  view -- the stage in a small tile, the scale far below one -- showed the
  embedded document far too small while the talk window was right. The frame
  now scales with `transform`, which both engines paint once. The reason that
  once spoke for `zoom` no longer holds either: at 1.71, the scale of an
  ordinary full-screen stage, `zoom` and `transform` come out equally sharp
  side by side. The frame's layout box now stands in slide points and
  overhangs its host wherever the stage scales down, so the host clips it, and
  the scale that converts a pointer into the frame is read from the element
  rather than from `style.zoom`.

- **The reveal chains let `track` hand out their steps.** A chain that read
  the step cursor and passed a *computed* `at` into a tracked element cost the
  document its convergence, as soon as the revealed body carried something out
  of the flow -- a `place` with an offset -- inside a box of fixed size.
  Measured on a class-5 number-line deck: five warnings for `cue`, nine for
  three `stagger` calls, and Typst giving up after five layout passes. `anim`
  never had it, because at `at: auto` it advances the cursor with a plain
  update and reads the value inside `track`'s own context: the number comes
  into being where it is used rather than being handed in from outside. Both
  now take that same path where they can, and so do `alternatives`, `tiles` and
  `build`. Two more things travel with the step: the floor (2 for an `anim`,
  which comes *after* the slide appears; 1 for a chain whose first piece is
  already there) and whether the step is an open span or a single one --
  `alternatives` and `build` let every stage step aside when the next one
  comes, and only the last one stays. `stride` other than 1, `dim`, `morph`, a
  named group, an `at:` list of its own and an explicit `start:` keep the old
  path, which they need for the absolute first step. Every example deck comes
  out with the same steps as before, down to the check deck's byte count.

  `scene` and `camera` had the same symptom for a different reason: not the
  `at` they hand in, but the *advance* they compute from what they read
  (`step-cursor.update(c => calc.max(c, letzter))` with a read-derived
  `letzter`). Both advances turn out to be plain functions of the cursor --
  a scene begins at `calc.max(1, c)` and owns one step per stop -- and are now
  written that way, so nothing read goes into them. Where `start:` or `at:`
  names the step, it comes from the argument and the old line stays.
  `pruefe-konvergenz.py` holds all nine constructs, `anim` among them as the
  control that never had it.
- **A click on a tile in the overview no longer pages on as well.** The tile
  appeared and the deck moved a step further -- measured, a click on tile 3
  landed on step 4. The cause was not the click but its neighbour: `pointerdown`
  closed the overview, and the `click` that followed fell through to the stage,
  where a click means paging. The overview now closes on the click itself, and
  that click is used up.
- **A `cue()` group no longer swallows the steps before it.** The forward arrow
  reveals the next point not yet named, and the group claimed the key as soon
  as its next point lay anywhere ahead -- not only when that point was the next
  stop. On a slide with ordinary steps before the group, one arrow therefore
  jumped straight to the group's first point and skipped every stop between.
  The arrow now falls through and pages normally until the group is due. Every
  probe so far began its group on step 1, where the first point *is* the next
  stop and a premature claim cannot be told from correct behaviour; reported
  from a lesson deck whose three marks came after two questions and a number
  line. Jumping behind the group by hash or `End` still does not fall back
  into it.
- **A centred `anim` on paper.** `anim(align(center, …))` inside a grid column
  was centred in the browser and flush left in the PDF, from one source. The
  HTML branch widens content that wants to centre itself to the room it has;
  the paper branch handed the body back untouched, and an `align` measured as
  narrow as its own ink had nothing left to centre in. Both branches now ask
  the same question. Reported from a deck whose three columns each carried a
  verdict under a diagram.
- **The handout sheet fits its page.** With the notes below the slide
  (`handout: 1` or `2`), and beside a 4:3 slide at three per page, every sheet
  ran a hair over and left a page behind that carried one ruled line. The
  spacing between the rows now takes the place of Typst's paragraph spacing
  instead of adding to it.
- **Room under a 4:3 slide.** At two per page the slide filled its whole share
  of the height and the notes came out with a negative height. At least four
  ruled lines now stay underneath; the slide gives way, not the room.

## [0.1.0] — 2026-08-31

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
