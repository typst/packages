# Changelog

All notable changes to this package are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), the numbering
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] — unreleased

### Presenter controls and automatic reveals (breaking)

- Automatic reveal chains start at step 2, including a chain at the start of
  a slide. Explicit `at: 1` and `start: 1` remain available.
- Cue arrows reveal the next unselected item; reversing also resets its range.
- Pinned clocks follow stage resizing in both windows immediately.
- GeoGebra uses a fixed logical viewport, so automatic axis labels remain
  identical when resizing the stage or changing browser zoom.
- Presenter media buttons and timelines control stage video/audio. `k` toggles
  play/pause and `j`/`l` seek ten seconds; manual controls override an active
  scheduled video until the slide is re-entered.
- A second draggable divider sets the notes/next-slide width ratio independently
  of slide height. The chosen ratio is retained across resizing and reloads.
- `speaker-view: (shortcuts: false)` hides shortcut help initially; `h` and the
  `?` button toggle it during the presentation and remember the session choice.
- Light/dark moves from `l` to `Shift+L`. `h`, `j`, and `k` are no longer
  available as custom sound keys.


### Media and release-candidate fixes

- `audio(src)` accepts local files and direct audio URLs, with presenter controls.
- Audio, video and YouTube share `start`, `end` and `loop` for selected segments.
  Seeking stays within the segment; `ends-at` schedules the selected duration.
- `room.clock.sound` optionally plays a file or URL once when the timer reaches
  zero, on the stage only. Cancellation and restoring an expired timer are silent.
- Presenter scrubbing follows real mouse/touch movement, previews locally and
  sends one seek on release. Cancellation does not seek.
- YouTube uses its actual displayed viewport and hides its control bar by default
  (`?controls=1` restores it). Branding and streaming quality remain provider-controlled.
- GeoGebra preserves its logical viewport while rendering at display scale and DPR.
- Hidden shortcut help occupies no space; help stays beside the light/dark button.
- Coarse countdowns retain their initial duration until the first interval passes.
- `vortragen` and its handout measure equal card heights from their text, including
  fallback fonts. `geogebra-sprecher` aligns captions and construction at steps 2–5.
- New browser regressions cover these behaviors, including painted card bounds,
  GeoGebra bridge messages, clipped playback and real pointer gestures.

### Added

- The tour demonstrates YouTube controls, the presenter dividers, hidden
  shortcut help and reveals starting at step 2. The two `0.1.2-ho-*` examples
  are published in both galleries as handout PDFs.

- YouTube embed URLs (including youtube-nocookie.com) load the external IFrame
  API on first display. Presenter play/pause, timeline and `j`/`k`/`l` control
  the stage; the presenter preview follows muted. Leaving or hiding the video
  pauses it. Loading failures, provider errors and autoplay blocks are shown
  alongside the media controls. Serve the deck over HTTP(S) for YouTube.

- **The pointer points.** Reported as "the pointer in presenter view does not
  work", tried in Chrome and Firefox. Measured, it was not a fault but a gap:
  the mode handed the mouse to an embedded frame and did nothing at all on a
  slide without one -- on a text slide it even said so, "nothing to point at on
  this slide", which was true and no help. `m` now lights a dot on the wall
  that follows the mouse across the slide copy in the speaker view. Hovering is
  enough: no button, no key, no new mode. It carries the accent colour at 2.2%
  of the slide width and travels as a fraction of the stage, so a 622-pixel
  stage at the desk and a 1600-pixel canvas in the hall put it in the same
  place. It goes out on
  leaving the slide copy, on losing focus, on reaching for the pen and on a
  change of slide; a change of *step* keeps it, because whoever points at a
  term and uncovers the next line means the same term still. `room: (pointer:
  false)` takes it away, `room: (pointer: (color: …, size: …))` sets it, and
  its colour is free -- a light ring and a dark one around the core carry the
  contrast, measured 10.90 against a light slide and 15.45 on `themes.night`,
  each by the ring that carries on that ground while the other one sinks into
  it. One method for both, and it runs: the dot at the middle of the stage in a
  1600 by 900 hall window at its default 2.2%, the screenshot read unscaled,
  the ground the most frequent colour on the circle of 2.5 radii, the rings the
  most frequent colours at 0.57 and 0.71 radii, computed after WCAG 2.1. That
  is point 16 of `pruefe-zeiger.js` and of `pruefe-zeiger-ff.js`, which measure
  it on `themes.default` and on `themes.night` and complain at a drift of more
  than 0.15; the same two numbers stand in both handbooks and in the runtime's
  comment over the line that gives the dot its colour.
  Embedded frames are untouched: hovering still reaches into nothing, a press
  still goes through, and the dot stands on the frame while it does, which is
  the point. A *mirroring* frame is the one exception, and on purpose: that is
  the frame which takes the mouse itself in pointer mode -- a GeoGebra applet
  is the everyday case -- so the stage stops seeing the hand, and `pointerleave`
  never comes because the frame lies inside the stage. Entering it now takes
  the dot out instead of leaving it where the hand last was. Measured on a real
  GeoGebra applet: the speaker moved from 0.030/0.522 onto the construction at
  0.361/0.522, and the hall went from a dot at 0.030/0.522 to no dot at all,
  with the applet as operable as before. Three things came with it. The old
  note moved from the key to `modusSetzen`, so the button beside it stopped
  being silent, and it is only raised now when a deck has ordered the dot away
  *and* the slide has no frame. A frozen hall no longer accepts anything on
  this channel -- until now a blind click went into a frame two slides behind
  what the speaker was looking at -- and freezing now takes a dot that is
  already on the wall with it: the bar only caught what arrived *during* the
  freeze, so measured at 0.4/0.4 the dot stayed while the desk paged two slides
  on, and it went only when the speaker moved the mouse again. And the runtime's
  check surface carries the dot: `typstage.pruef.zeiger()` reports `aus`,
  `ebene`, `an`, `x`, `y`, `px`, `buehne`, `anteil`, `deckkraft` and `farbe`, and
  `pruef.fassung` rose to 5 because of it, so a run that meets an older deck is
  told instead of quietly measuring zeros.

  Measured in both browsers, each with two real windows over stages of
  different size. Chrome 153 over the DevTools protocol: 0.3/0.7 of a
  622.2-pixel desk stage and of a 1600-pixel hall stage, 13.7 against 35.2
  pixels, 2.2% in both. Firefox 154 over WebDriver BiDi: 0.2996/0.7011 of a
  618.7-pixel desk stage and the same 1600-pixel hall, 13.6 against 35.2 pixels,
  2.2% in both. The two differences are the browsers and not the dot -- Firefox
  lays the desk stage 3.5 pixels narrower at the same 1120x760 window, and BiDi
  rounds a hover to whole pixels, which is the 0.0004 and the 0.0011 in the
  fraction. In both, leaving the stage takes the dot in both windows, a pen
  stroke still draws in the hall with no dot standing on it, hovering sends
  nothing into an embedded frame while a press operates it, a mirroring frame
  takes the dot out, and a desk closed while its dot stands takes the dot out
  of the hall as well -- the hall's own watch notices, since nobody is left to
  send the word. A desk reloaded while its dot stands takes it too, with its
  first hello as a fresh window; until now the dot stayed, still there after
  70 seconds in Chrome and in Firefox, because the watch saw a live partner. The
  road is `PointerEvent`, `getBoundingClientRect`, `postMessage` and
  `requestAnimationFrame`, none of it one browser's own, and the reported "does
  nothing" was browser-independent because there was no dot layer at all.
  `.github/scripts/pruefe-zeiger.js` holds the Chrome side and
  `pruefe-zeiger-ff.js` the Firefox one, each on its own driver, the way
  `pruefe-decks.js` keeps one driver for each browser: Firefox 154 answers
  `--remote-debugging-port` with BiDi only, so the DevTools driver cannot reach
  it.

- **`section-back` -- the link back to the contents, in your own words.** Every
  section slide carries a link back to the contents slide, and until now its
  word was the package's. `presentation.with(section-back: [Back to the
  agenda])` words it differently, a string does the same, `none` takes the link
  away on every section slide, and a function receives one dictionary and
  returns content -- or `none`, and then that one slide goes without. The
  dictionary holds `location` and `contents.number` of the contents slide, the
  default `word` in the deck's language, and `section` with `number`, `title`
  (with the `section-numbering` prefix), `depth` and `parents`. The theme keeps
  the place and the link; the value is only the body, so a `text` of your own
  inside it beats the accent colour -- `section-back: b => text(fill:
  white)[#b.word]` lifts the contrast on `themes.editorial`'s ground from 2.95
  to 9.35. Both numbers by the same method, named so that two measurements of
  one pair do not read as a contradiction: the two colour values themselves,
  the link's colour against the section slide's ground as the theme sets them,
  computed after WCAG 2.1. By that method the accent on the section ground
  reads 3.94 on `default`, 3.76 on `lesson`, 9.77 on `night`, 16.48 on `plain`
  and 2.95 on `editorial`. A page rendered to pixels reads a shade lower,
  because the most frequent pixel of smoothed text is seldom its exact colour.
  A `link()` of your own in the body beats the outer one, which is how the link
  reaches another destination, and equally how a deck loses its way
  back. It rides on the section record and not in a theme key, the same way
  `section-numbering` does, so the handout, the step-by-step slides and
  `bundle()` carry it without a line of their own, and a typo in the name still
  stops the build with the full list of what `presentation` takes. Reported
  along with the question of how to customise the backlink on section slides.

- **`bleed` -- content to the edge of the canvas.** `#bleed[#image("x.jpg",
  width: 100%, height: 100%, fit: "cover")]` fills the slide edge to edge: the
  body's origin is the canvas corner and its room the whole slide, whatever the
  margins, the title and the running header take, and a `place` inside counts
  from that corner even without an anchor. It lies right above the slide's
  ground and under the title and the body. A slide with `bleed` draws no chrome
  -- no running header, number, footer line or progress bar -- on paper, in the
  browser and in its print view; it still counts, and the bar comes back on the
  next slide. `anim`, `cue` and `morph` inside work as anywhere: sprites land
  on the canvas and morph chains to the neighbouring slides fly. It is taken out
  of the body before the pauses are cut, so it must stand at the top of a
  regular slide's body, once, before the first `#pause`; anywhere else the
  build stops with a message saying where. `#bleed(none)` is the empty canvas,
  like `#bleed[]`, so a deck can set its picture conditionally. The overflow
  check does not measure it. Two things to know: the `style` hook of the deck
  wraps the bleed as well, so a hook that pads the body pads the picture, and
  it runs twice on such a slide; and in the handout the bleeding slide is the
  one without a number. Reported from a Year 5 deck that laid four quartet
  cards over a photograph.

- **The digits set the class clock.** `3` starts three minutes, `7` seven, `0`
  ends it again -- for the question at the start of the lesson and the minute of
  talking in pairs, where the hand is on the keyboard anyway and a number is
  shorter than `t`, field, number, Enter. What starts is the *pinned* clock, so
  the question stays on the slide while the time runs and paging does not end it.
  It works without a second window, which is the point: the clock used to be
  reachable only from the speaker view, and one machine at a beamer is how
  anyone actually teaches. On a slide carrying a `cue()` group the digits stay
  with the group -- decided per slide and not per keystroke, because three of
  `adTaste`'s four refusals happen in the middle of a cue slide, the repeated
  press on the same point among them, and each would otherwise have started a
  clock nobody asked for.

- **`room: (clock: (step: 5))` -- how calmly the clock reads.** A clock that
  jumps every second pulls the eye off the task each time; at a step of five it
  moves only every five seconds. The last step still counts down singly, 00:15,
  00:10, 00:05, 00:04, 00:03, 00:02, 00:01, 00:00, because a clock showing 00:00
  for a full five seconds while time is left sends the class home early. The
  step has to divide 60 evenly, checked at compile time: at seven seconds a
  `class-clock(1)` would read 00:56 the moment it starts, which looks like a
  fault of the clock rather than one of the setting. It sits on the deck and not
  on the slide deliberately -- how coarsely a clock reads is a property of the
  eye, and a running clock that changed rhythm on paging would look broken;
  what genuinely varies per slide is the duration, and `class-clock` already
  carries it. `room` is the counterpart to `speaker-view`: what reaches the
  room, against what only the speaker sees. `room: (clock: (digits: false))`
  gives the digits back.

- **`video(ends-at: "08:15")` -- a video that ends on the bell.** A music video
  runs before the lesson and should stop at the moment the lesson begins. The
  runtime reads the video's own length when the slide comes up and starts it far
  enough in that its last frame falls on that minute, so unlocking the room at
  08:11 gives the last four minutes and arriving at 08:07 the last eight. A bell
  further away than the video is long leaves it waiting on its first frame; more
  than an hour away, or an unreadable time, drops the plan and it plays from the
  start, which covers both the machine left on overnight and the minute after
  the bell, where "the next 08:15" would mean twenty-three hours. Blacking out
  and coming back re-computes rather than resumes -- forty seconds of black
  would otherwise move the end by forty seconds. `room: (bell: "08:15")` plus
  `ends-at: auto` moves a lesson from the first period to the third in one line
  instead of one per video.

- **`room: (sounds: (a: "airhorn.mp3"))` -- a sound on a key.** A signal the
  class knows. The deck supplies the file; the package ships no sound, which
  keeps somebody else's recording out of an MIT-licensed package. It is heard in
  the hall and only there -- the speaker sits at the machine, the speakers are
  in the room -- and the command travels as a message of its own rather than on
  the state channel, which repeats every second and would have gonged on every
  re-handshake. Keys the runtime already uses are refused at compile time with
  the free ones listed, and a missing file is reported at load rather than when
  somebody presses the key.

- **The PDF carries an outline again.** A deck used to produce no bookmarks at
  all: the headings that cut it into slides become dictionaries on the way and
  never reach the document, so there was nothing for Typst to build an outline
  from, and the reader's sidebar stayed empty. Each slide now carries a real
  heading that sets nothing -- `hide` takes its ink, `place` its place in the
  flow -- and exists only to be bookmarked. Sections sit at their own depth
  with their slides below them, and the title slide at the top. Measured over
  five example decks: 75 pages pixel for pixel unchanged, and the HTML of three
  of them byte for byte. Under `pages: "step"` the entry belongs to the slide and not to
  each of its step pages. A heading a deck writes inside a slide body no longer
  produces a bookmark of its own: it used to, and under `pages: "step"` it was
  emitted once per step page, so the same name appeared several times pointing
  at pages that did not show it. Reported as bookmarks that "deviate from that
  generated in normal Typst file".

- **The tour shows what this release added, and two more decks use it.**
  `examples/tour.typ` opens with a route -- `contents(highlight: true)` ahead of
  the first section, where it no longer comes out pale -- and each of its
  section slides carries `section-back` in white: the theme sets the link in
  the accent, and the tour's blue on its red section ground measures 1.27 to 1,
  white 5.51. A slide without a title says so about itself. A new section, "In
  the room", gives a slide each to the pointer's dot, to the digits with
  `room: (clock: (step: 5))`, to a horn on `a` and to `video(ends-at: auto)`
  with `room: (bell: "08:15")`. The slide on the dot also names the handle
  that divides the speaker view, in a line of its own and again in its note,
  which the speaker view shows right under that handle. After `contents` two
  more show `section-back` and what the PDF does -- its outline,
  `pages: "step"`, and a
  `stagger(dim: true)` that paper prints whole. The tour went from 39 to 48
  slides, from 107 to 131 step pages and from 20 to 24 handout pages at two per
  sheet, in as many layout runs as before: five for the HTML, four for each
  PDF. `unterrichten` names the key for each burst in its notes, puts the horn
  on `a` and ends on a slide without a title, where `themes.lesson` drops its
  running header. `anziehen` sets its link back in its paper colour, 11.52 to 1
  on the section ground where its accent measures 2.85, and shows both on a
  slide of their own. The horn is `examples/medien/airhorn.mp3`, 1.3 seconds and
  16 320 bytes synthesised with `ffmpeg` from three sawtooth tones -- nobody's
  recording; `examples/medien/PROVENANCE.md` carries the command, which writes
  the same bytes again. And `pruefe-rundgang.py` checks the new keys that have
  no export of their own -- `room`, `clock`, `step`, `sounds`, `bell`,
  `pointer`, `ends-at` and `section-back` -- where they act, and lists `digits`
  and `pages` as quoted, each with its reason. It used to pass a tour that set
  none of them.

### Changed

- **The link back to the contents follows the reading direction.** It was
  placed against the right edge by hand, which is the right edge in a deck that
  reads from the left and the wrong one in a deck that reads from the right.
  Measured on an Arabic `themes.lesson` deck it moves from x 716.2..809.9 to
  x 32.0..125.7, the same 93.7 points wide, and so no longer sits on top of the
  accent bar that `lesson-section` puts along that same edge when the deck is
  mirrored. Decks that read from the left are byte for byte unchanged: every
  page image and page text of the seventeen examples came out the same, and so
  did every HTML file once the `<script>` and `<style>` blocks are cut out. The
  raw HTML is not the same, and not because of this: each of the seventeen grew
  by exactly 16770 bytes, none of them on a slide -- 14619 of runtime, the
  pointer among them, which came in the same step, 2132 of style sheet and the
  19 of the one line `"pointer": true` that the dot adds to every deck's room
  configuration. Of the seventeen, two carry a link back at all -- `anziehen`
  with six and `tour` with five, the same eleven before and after. All of this
  was measured on the examples as they stood before the tour gained its slides
  for this release (above); the tour carries six links since.

- **A slide without a title has no running header.** A bare `==` or
  `slide(none)` used to drop only the title band: under `themes.lesson` slide
  number, section and hairline stayed on top and their height stayed reserved.
  Both go now, on paper, in the chrome layer and in the print view; footer and
  progress stay. Slides with a title are unchanged: measured on the seventeen
  example decks before the tour gained its `bleed` slide, every page image and
  every HTML file came out the same.

- **A title is empty when it draws nothing, not when it has no text.** The
  decision used to go through the heading's plain text, so `== $a^2$`, a logo
  in a `box` or a `context` title counted as no title and vanished without a
  word. Now only nothing, space, `h`/`v` and markers count as empty; `== #h(0pt)`
  stays a slide without a title. Such a heading therefore draws its band and
  its running header now, and the body loses their height: measured under
  `themes.lesson` with a logo in a `box`, the body starts 32.4pt further down
  than before, at 117.6pt from the top instead of 85.2pt. A deck that filled
  such a slide to the brim and builds with `overflow: "error"` can stop where
  it used to go through. The PDF bookmark still follows the text: a heading
  that draws but carries no character -- a picture, an empty `box`, a `context`
  -- gets no entry, because an empty line in the contents is worse than none.

- **`pages: "step"` does not check the PDF for overflow.** Every step page sets
  the same body as the one page per slide, so measuring each of them only
  repeated the same finding once per step -- and the measurement cost a layout
  run that decks looking something up in their body did not have: `geogebra`,
  `geogebra-sprecher` and `tour` did not converge with `overflow` on. The page
  per slide, the handout and the HTML still check, the HTML with the step. A
  deck that builds only its step PDF with `overflow: "error"` no longer stops
  on an overflow there.

- **The runtime files are now `typstage-0.1.2.css` and `typstage-0.1.2.js`.**
  They carry the version, so a deck with `assets: "split"` writes and links the
  new names; nothing changes for the default, which embeds them. The published
  0.1.1 stays exactly as it is on Universe -- its directory is frozen, and this
  is the version that follows it.

- **The pinned clock survives blacking out.** `b` used to hide every clock, on
  the reasoning that whoever blacks out wants to see nothing. That was right for
  the full-screen clock, which covers the hall anyway, and wrong for the pinned
  one: it is not slide content but the instrument of the class that is working,
  and blacking out during group work is meant to take away the distraction, not
  the time. Before, the clock vanished silently and came back with a changed
  number.

### Fixed

- **The slide number stands in the browser where it stands in the PDF.**
  Reported in issue #16: "6/34" whole in the PDF, "6/3" in the browser, its
  last digit under the edge of the stage. In the browser the chrome -- number,
  running header, footer line, progress -- is a layer of its own above the
  stage and missed what the page gives it on paper: it resolved every length in
  `em` against the document's 11pt instead of the theme's size. With
  `presentation(margin: 1em)` the number stood 13pt further right, 25 pixels on
  a 1600-pixel stage, and a shift of its own towards the corner pushed its last
  digit under the edge -- the picture of the report, rebuilt on
  `palettes.parchment`; the report names no `em`, so whether that was its cause
  is open. `#set place(dx: …)` before the show rule moved the chrome on paper
  only, `#set block(inset: …)` in the browser only, `#set block(fill: …)`
  covered the slide body in the browser, and `#set page(flipped: true)` turned
  every page upright. In the browser the chrome now takes the theme's size, a
  deck's `set place` no longer reaches its place nor `set block` its frame, and
  the page is never flipped; the print view and the speaker view follow. The
  manuals gained "Moving the built-in number", and
  `.github/scripts/pruefe-zier.js` compares the chrome in Chrome with the PDF
  page. The example decks come out as before, apart from the progress bar
  below.

- **The progress bar is as thick in the browser as on paper.** The runtime drew
  it 2.5 CSS points high, 3.33 pixels in any window, while the theme means 2.5
  points of the *slide*: 4.75 pixels on a 1600-pixel stage, 5.7 on a 1920-pixel
  one, 9.5 on a 3200-pixel one -- and 1.1 on a phone held upright, where the
  browser's bar came out three times as thick as the printed one. Its height is
  now a share of the stage, 0.5279 % on the default canvas, and measured at 375,
  800, 1600, 1920 and 3200 pixels, with `themes.night`'s bar along the top and
  on a 4:3 deck, it matches the PDF page within a pixel. Eight of the seventeen
  example decks carry a bar, and their HTML differs in that one style value,
  two bytes longer, and in nothing else.

- **A deck's `set block` no longer lends its inset, fill, stroke, width or
  height to the frames the package builds around content.** In Typst 0.15 a
  `rect` and a `layout` take a `set block`'s inset, fill and stroke as well,
  and the browser lays every revealed piece out in such frames, which paper
  does not have. Under `#set block(inset: 8pt)` a word behind a `#pause` came
  out in the browser at less than half its size and 424 pixels off on a
  1600-pixel stage, an `anim(place(bottom + right, …))` vanished, and a
  `scene` and a `flipbook` stood up to 77 pixels further right and 58 lower
  than on paper; in both outputs the frames of `alternatives` and `build`
  squeezed a block of the deck until its text ran out of it. Under
  `#set block(width: 80%)` a block behind a `#pause` came out 236 pixels
  narrower in the browser, and a long footnote was squeezed into 80 % of the
  slide there. These frames, the chrome, the footnote block and the page now
  take none of it -- on paper a footnote now runs the full width too --, while
  the body of a revealed piece, the text of a footnote and a block the deck
  puts into the chrome keep the deck's rule, in the sprite as well -- the body
  of a revealed piece also when the rule stands after `#show: presentation`,
  which reaches a footnote and the chrome in neither output. Still reached,
  alike in both outputs: the theme's grounds, bands and rules and the frame of
  the slide body.

- **A deck's `set box` and `set rect` no longer reach the frames only the
  browser draws.** There a `scene` and a `flipbook` stand in a `box`, a
  `morph` in a line sits in one, and a revealed piece holds its place with a
  marker that is a `rect`. Under `#set box(inset: 8pt)` all three stood 16
  pixels further right and lower than on paper, under `#set box(fill: …,
  stroke: …)` the browser alone drew a frame around a scene and a flip book,
  and under `#set rect(outset: 8pt)` a run behind a `#pause` stood 15 pixels
  further left, fitted into the larger marker.

- **A footnote under a margin in `em` breaks in the browser where it breaks on
  paper.** Its sprite resolved the margin against the document's 11pt instead
  of the theme's size, the gap issue #16 found in the chrome: under
  `presentation(margin: 1em)` it set a long footnote 26pt wider than the slot
  that holds its place, broke it one word later than the PDF, and the runtime
  squeezed it into the slot, its end 10 pixels short on a 1600-pixel stage. The
  sprite now sets the theme's size and the footnote block's, as the slot does,
  and the sixth deck of `pruefe-zier.js` carries such a footnote. The block's
  size matters under a theme size in `em`, where the slot sets it twice; the
  thirteenth deck carries a footnote under `themes.default + (size: 1.3em)`.

- **The print view carries no stage progress bar.** `#ts-fortschritt` was left
  out of the print rule, so printing from the browser put the bar of the slide
  the talk stood on across the first page, over the bar that page carries itself.
  Measured on a four-slide deck printed from its last slide: page one showed a
  bar across 99.9 % of its width instead of its own quarter.

- **Paper prints what the manual promises again.** On paper `after` does
  nothing, the manual says, and a page shows every step at once. Since
  `pages: "step"` arrived, every closed range was cut on the ordinary slide page
  too: `stagger(dim: true)[One][Two][Three]` printed "Three" alone, without a
  warning and with the right page count. Measured on the example decks:
  `mosaic-manifesto` printed one of its three questions, `vortragen` a slide with
  three empty lines and its last sentence, `gliedern` and `unterrichten` a list
  missing its points. The handout went wrong the other way and printed every
  version of an `alternatives`, every stage of a `build` and every stop of a
  `scene` on top of one another. There are now two rules. What is *replaced* --
  a version, a stage, a stop -- stands only in its range, so a slide page and
  the handout show the last one. Everything else stands on a slide page and in
  the handout, and under `pages: "step"` from its first step on; a closed range
  ends there as it does in the talk, and what rests dimmed has not gone.

- **`pages: "step"` builds every example deck, and converges.** Before, three of
  the seventeen stopped with an error (`geogebra` and `geogebra-sprecher` with
  "no applet on this slide", `tour` inside `bridge-targets()`), and five more
  warned that the document did not converge -- which means Typst printed an
  intermediate state: `ziehen` showed the lines beside its scene either never or
  all four from the first stop, `vortragen` put the questions beside the wrong
  point, `mosaic-manifesto` its team rows on the wrong pages. Every cause was
  the same rule broken in a new place, a value read from the running slide
  flowing back into how that slide is set: `stagger(dim: true)` read the step
  cursor instead of letting `track` hand out its steps; `scene-layer`,
  `cue-layer` and `stagger-layer` pushed the cursor to a step they had read;
  a layer's step, read and then carried into `track` as a string, gave the
  element a new identity in every layout run in which the reading still moved;
  counting waited for a reading of whether a deck was being laid out at all
  and so began one run late; `side-by-side(equal: true)` measured cards that
  read the height of the very measurement; and a `cue` group of five points
  checked its digits against a group state that a page added in that run had
  not yet read at its own place, failed on the fifth, and dropped the page. All
  seventeen decks now build without a warning as slides, step by step and as
  a handout, and their HTML is byte for byte what it was.

- **`pages: "step"` has a layout run to spare.** Typst lays a document out at
  most five times, and step by step every example deck needed all five --
  already two slides with one `anim` on the first did, so one lookup more
  anywhere tipped a deck over: a `#context anim[#info().slide.number]` in front
  of that `anim` gave "did not converge". How many pages a slide gets came
  from a state that the slide writes from the step cursor it reads, and a value
  written from a reading arrives one run after the reading. The count is now
  read off the cursor itself, at a mark behind the first page of each slide.
  Measured with `typst compile --timings`: the seventeen decks take four runs
  step by step instead of five and three instead of four as one page per slide
  (`tour` four as before), every page and its text as before, and the two
  slides above converge. Two `presentation` calls in one document no longer
  share their page counts either: both number their slides from one, and each
  got the counts of the last, so a first slide with two reveals came out as one
  page instead of three. `info().step.total` on paper still reads the state and
  with it the count of the last call.

- **`bridge-targets()` with `overflow` on.** It matched the slide number an
  `embed` had written down, and that number is itself a reading, correct one
  layout run after the slide counter. It now reads the slide at the place of
  the mark. The overflow check measures what a slide body prints, and `tour`
  prints `#raw(bridge-targets().join(", "))`: with
  `--input typstage-overflow=record` its HTML did not converge, with four
  warnings "a measured element did not stabilize" on that `raw`. Now it
  converges in the same five runs, and `geogebra` and
  `geogebra-sprecher` take three runs as a checked handout instead of four.
  The `slide` field stays on the mark for a package that reads it.

- **A `cue` group with five or more points under `pages: "step"`.** Every step
  page showed the whole group, see above. The check that no digit goes past 9
  now runs where the gap check already runs, at the end of the deck, with the
  same message.

- **A `cue` group inside another reveal.** `anim(cue("marks")[…])` with a list,
  or a `cue` group as a version of `alternatives`, did not converge in the
  browser as soon as another slide followed: "a measured element did not
  stabilize", twice, and "document did not converge". The browser sets the
  body of a reveal twice, on the slide and again in the layer above it, and
  the second time the group already holds all of its points -- two points came
  out as 1 and 2 on the slide and as 3 and 4 in the layer. That number was
  handed into each point as a finished value and made it a different element
  in each copy. A point now looks its number up where it is set. Some of these
  decks stopped the build instead, with or without a slide after them, because
  the check at the end of the deck counted the points of the second copy too:
  five points counted on to 10 and were refused as "a point 10" that no slide
  shows, a single point with `nr:` was refused as "a digit to two points", and
  a real gap in the numbers was reported as that same doubled digit. The check
  now counts what stands on the slide. On paper nothing changes, and the
  browser output of every example deck is byte for byte what it was.

- **A `scene-layer` in a version of `alternatives` under `pages: "step"`.** A
  scene with a layer as one version of an `alternatives` did not converge
  either: two warnings "a measured element did not stabilize" and "document
  did not converge", measured on one such slide followed by another and on
  three such slides in a row. The version is measured, and a measurement
  settles a layout run late, which left the layer one run short, for two
  reasons. The layer's checks stood around it, and in the first run, where no
  scene is known yet, they failed and took the layer out of that run; they now
  stand beside it. And the layer found its step through a number the scene had
  read and written down; it now reads the step cursor at the scene itself.
  Either change alone fixes one of the two decks. The pages are what they
  were.

- **A box inside a box in `side-by-side(equal: true)`.** A `callout` inside a
  `card` took the full row height and ran out of the card's bottom, and the
  title bar of the shorter card stood in its middle with empty space above it.
  The row height now reaches the boxes of the row and not the boxes inside
  them, and a card's content starts at its top.

- **`contents(highlight: true)` before the first section.** Nothing was running,
  so every entry was dimmed: an opening agenda came out pale throughout. Where
  none of the listed entries is running, the list is now set as it is without
  `highlight`; `entry.when` still says `"coming"` to a renderer of your own.

- **`contents(highlight: true)` after a new part.** The last chapter of the part
  before stayed marked as running until the new part opened a chapter of its
  own: in `= Part A / == Chapter A1 / === s1 / = Part B / === Middle`, "Middle"
  showed "Part A" dimmed and "Chapter A1" in full ink, and `entry.when` said
  `"running"` for it -- in HTML, on slide pages, step pages and in the handout,
  and on the section slide of "Part B" too when a theme sets the contents there.
  `when` compared numbers only, and a level's `number` never goes back. An equal
  number now counts as running only while that level's `index` is not `0`, and
  as past otherwise. The recipe for a progressive agenda in the manual had the
  same gap and now checks `index` as well.

- **The link back to the contents on a section slide.** It read "Back to
  contents" in every language; it now follows `text.lang` like the tab of a
  `callout`. It had no label, so a `show` rule could not reach it; it is now
  `ts-section-slide-back`. And it pointed at the first `contents()` in the
  document: a deck that shows its agenda before every section sent every link
  to the first one, and a deck that puts the contents on the section slide
  itself got a link to the page it stands on. It now points at the nearest
  contents before the section slide, and there is none where the contents
  stands on that slide.

- **A range with a gap is a gap on its step page.** `anim(at: "1,3")` stands on
  steps one and three and is gone on two -- in the browser. Under
  `pages: "step"` the paper knew only where a range begins and ends and printed
  it on the page of step two as well. Measured on a slide with `"2,4-"`,
  `(1, 3)`, `"1-2,4"` (dimmed), `"2-3,5"` and `"5"`: four elements stood on three
  of five step pages where the runtime hides them. The paper now asks the same
  question part by part that the runtime asks, checked against the runtime's
  own function over 594 selectors. `tour` shows it on the slide that says so.

- **A backwards range is refused.** `anim(at: "4-2")` compiled, and the two
  sides read it differently: it covers no step in the browser and none on a
  step page, but the paper took its end from the 4 and the runtime from the 2.
  Measured beside an `anim(at: 2)`: the slide got four steps, the last three
  alike, and the page for the slide and the handout printed an element the talk
  never shows; with `after: "dimmed"` the runtime's own functions put it dimmed
  on steps 3 and 4 without its ever having stood there. `anim` and `morph` now
  stop with a message naming the range and the way round it goes, in a list
  such as `("4-2", 5)` too. No selector the package builds itself runs
  backwards.

- **A heading written as a function call in the heading notation.**
  `#heading(level: 3)[…]` or a bare `#heading[…]` between the slides stopped
  the compile with `field "depth" in heading is not known at this point`,
  pointing into the package: only `==` and `heading(depth: 2)` write the
  depth into the element, and the split read it without asking. It now reads
  an explicit `level` first, then `depth`, then Typst's default of 1, so
  `heading(level: 3)` counts as `===` and `heading[…]` as `=` -- pixel for
  pixel the same pages in all three paper forms and the same HTML, with and
  without `set heading(numbering: …)`. A subheading meant to stay inside a
  slide goes into a `block`.

- **`stagger` with `stride`, `name` or `morph`.** These read the step cursor and
  worked out each piece's step from it, and under `pages: "step"` they did not
  converge: `stride: 2` gave seven warnings and ten pages instead of five,
  `name:` seven and six instead of three. A `morph` chain did not reserve its
  steps at all, so an `anim` after it fell on the step of its second piece, and
  the slide page lacked every piece past that step. `track` now hands out their
  steps as it does for a plain `stagger`, a named group records the step of each
  piece, and a morph chain takes the steps it uses -- which moves an `auto`
  element behind it to after the chain, where the manual says it belongs.

- **A named morph chain across the edge of a slide.** `stagger(morph: "k")[$u$][$u v$]`
  on one slide and `stagger(morph: "k")[$u v$][$u v w$]` on the next stopped the
  HTML build with "morph(k) on slide 2 starts after step one" -- the very use the
  manual gives a name of your own for; `alternatives(morph: "k")` and a single
  `morph` followed by a chain the same. The check asked every piece, and in a
  chain every piece after the first starts later by design. It now asks the name:
  one morph of it standing from step one is enough. It notes one entry per name
  on a slide, without its steps, and reads the steps where the slide noted them
  at the end of the deck: a `bundle()` whose slide opened with
  `alternatives(morph: true)` or `stagger(morph: true)` gave two convergence
  warnings when the steps sat in the entries. Behind the check sat the
  matching fault in the runtime: at a slide change every morph of that name on
  the new slide was a target, revealed or not, so the second line of the chain
  flew in as a ghost, stood there at full strength for the length of the flight
  and vanished again -- one keypress early. A slide change now flies only into
  what stands on the step it arrives at; going back into an
  `alternatives(morph: "k")` no longer flies into its first version as well.

- **`stagger-layer` looks on its own slide.** The book of named staggers was not
  cleared between slides, unlike those of `cue` and `scene`: a layer naming a
  group that stood only on the slide before found it and took a step of that
  slide, and with a `#pause` ahead of that group the HTML did not converge
  (four warnings). It now stops with the message for a name it does not know,
  which says that a group belongs to one slide. The check reads the book beside
  the layer and no longer around it: in a `bundle()`, a layer behind a `#pause`
  on a slide with a slide after it did not converge once the book was cleared
  (eight warnings), and with a stagger of the same name on that next slide it
  did not converge before either -- in the HTML the layer stood there from step
  one. Both converge now.

- **`tiles` with a `stride` other than 1, and `alternatives(morph: true)`.** The
  same two faults in the two siblings of `stagger`.
  `tiles(stride: 2, [A], [B], [C])` read the step cursor and under
  `pages: "step"` gave eight warnings and ten pages instead of five; `stride: 0`
  with an `anim` after it nine warnings and four pages instead of two, and in
  the browser too once a tile carried something outside the flow.
  `alternatives(morph: true)` took no steps in the browser, with `start` or
  without: an `anim` after `[A], [B], [C]` came on step 2, in the middle of the
  rewriting, while the PDF put it on step 4, and three of them in a row all
  stood on steps 3 and 4. `track` now hands out the steps of `tiles`, and a tile
  that reveals something of its own moves the tiles after it back, as a
  `stagger` piece does; the versions of `alternatives(morph: …)` take their
  steps as the paper counts them, without an update that hangs on a reading, so
  one inside a tile converges as well. As a `bundle`, a slide with two of them
  had warned six times that the document did not converge; it now builds clean.
  One case still counts differently: a version other than the last that reveals
  something of its own does not wait for it in the browser. In
  `alternatives(morph: true, [A #anim[x]], [B])` the browser puts B on step 2
  and never shows x, while the paper shows A, then A with x, then B.
  A morph without a name of its own inside a tile or an `anim` still did not
  converge in the browser as soon as the same slide came again:
  `tiles([K], stagger(morph: true)[R][T])` on two slides warned nine times, and
  the second slide put R and T both on step 6 where the PDF has them on 3 and 4.
  The host sets its body a second time for the sprite, and the running number
  behind the name counted that copy too. It is a counter now, which the sprite
  sets back like the number of a figure: no warning, R and T on 3 and 4, and an
  HTML document behind another output of the same body, built by hand with
  `document()`, numbers its morphs as it does alone.

- **A `video`, `embed`, `flipbook` or `morph` with an `at` past step one.**
  Only an `anim` pulled the step cursor up to the step it names, while the
  runtime counts the highest number in any element's range. `video(at:
  "2,4-")` alone on a slide had four steps in the browser and one on paper, so
  the page per slide was set at step one and left the video out, and
  `pages: "step"` never showed it at all. The HTML refused
  `anim(at: "2-3", after: "dimmed")` beside a `video(at: 4)`, since for the
  check the slide had only three steps, and an `anim` after a `video(at: 3)`
  came on step two, before the video. These four now count like an `anim`
  once their `at` goes past step one, which moves an `auto` element behind
  them to after them, as it does behind an `anim(at: 3)`; at their
  default they still take no step, so the bullets beside an applet start at
  one. On paper `embed` and `flipbook` now take the same path as `video`.
  Before, their
  stand-in stood on every step page of the slide, also where the browser shows
  nothing: `ziehen` printed its flip book on the two step pages before
  `at: "3-"` uncovers it, and an `embed(at: "1")` stayed on every later page.
  The page per slide, the handout and the HTML of all seventeen example decks
  are unchanged, and so is the number of layout runs in all four versions.

- **Numbers under `pages: "step"`.** Every step page of a slide counted again:
  a figure in an `alternatives` was "Figure 3", "Figure 7" and "Figure 11" on
  its three step pages and "Figure 4" on the page per slide, and every later
  number was off. Every kind of figure, equations, headings and a deck's own
  counters now start each step page where the first page of the slide starts
  them. Measured with a figure, an equation and a counter on every slide of
  seven example decks: 276 of 279 marks were off in `tour`, none now.

- **Numbers in the browser.** A tracked element is typeset twice in the HTML,
  once on the slide and once as the sprite that moves, and every counter in it
  counted twice: the two versions of `alternatives(figure(…), figure(…))` read
  "Figure 3" and "Figure 4" in the browser and 1 and 2 on paper, and every
  later slide inherited the lead -- after a few tracked figures, equations and
  a counter, a slide without any animation showed "Figure 8", equation (4) and
  5 where the paper has 5, (3) and 3. A sprite now starts every counter where
  its body starts on the slide and leaves nothing behind for the next: every
  kind of figure, equations, headings and a deck's own counters. Measured with
  a tracked figure, equation and counter on every slide of seven example
  decks, once in `anim` and once in turn in `alternatives`, `stagger`, `build`
  and `anim`: 177 of 184 and 222 of 229 marks were off in the browser, none
  now, and no deck needs a layout run more. The numbering of figures,
  equations and headings now reaches the sprite as well: a
  `#set math.equation(numbering: "(1)")` in the deck did not, so an equation
  in an `alternatives`, `stagger`, `build`, `cue`, `tiles` or `anim` showed no
  number in the browser while the paper showed one. A show rule in the
  document that numbers or counts still does not reach the sprite, and the
  numbers after it now drift the other way: with
  `#show math.equation.where(block: true): set math.equation(numbering: "(1)")`
  an equation two slides after an `anim` and an `alternatives` reads (2) in the
  browser, where it read (6) before and reads (5) on paper. Inside `style` the
  rule reaches both, and the equation reads (5).

- **A reference to a label under `pages: "step"`.** A labelled figure,
  equation or heading on a slide with more than one step stood in the document
  once per step page, and Typst refused every reference to it: `#figure(…)
  <fig>`, `#pause`, `See @fig.` stopped with "label `<fig>` occurs multiple
  times in the document", while the page per slide and the handout built. The
  step pages after the first now set these three without their label, so a
  reference finds the first page of the slide, where it opens, with the number
  every page of it shows, and `query(<fig>)` finds one per slide. Measured on a
  deck of six slides with eight references -- to a figure in the body, in an
  `anim`, in `align` and `grid`, in a `stagger`, to two equations in an
  `alternatives` and to a heading behind a `#pause` --: eight errors before,
  none now, five layout runs as without the references, and every link on the
  first page of its slide. The price is a `show` rule on the label of a figure,
  equation or heading, which no longer reaches the later step pages; measured
  on a slide with `#pause`, a caption coloured through its figure's label is
  red on the first step page and black on the second. A rule on the kind
  (`show figure`) still reaches every page, and so does a rule on any other
  label: a word coloured the same way stays red on both, and none of the
  seventeen example decks changes on any page. Eleven of the example decks,
  given three labelled figures in an `anim` each with a reference to them,
  stopped with three errors apiece and now build in the same four layout runs
  as without them; a slide whose only reveal holds a labelled figure takes one
  run more on its own, four instead of three. A label inside `card`,
  `callout`, `statement`, `fit`, `side-by-side(equal: true)` or `build`, in a
  list item, in a `context` of the deck's own or in one of the three layers is
  out of reach and still stops the build when referenced. The layers are left
  out on purpose: their step settles a layout run later on a new step page, and
  taking the label off there cost valid decks their convergence -- `ziehen` and
  `vortragen`, given a labelled equation in a `scene-layer` or `cue-layer` and
  no reference at all, built without a warning before and with two ("did not
  converge") when the layers were included.

- **A reveal inside a version of `alternatives` that is not the last.** A
  version held exactly one step, and a chain inside it handed out its steps
  after that one, where the version had already gone: in
  `alternatives([A], alternatives([B], [C]), [D])` neither B nor C was ever
  visible, on paper or in the browser, and three step pages were empty. A
  version now holds its range until the steps of its own chain are done. The
  same holds for a `build` stage and for a piece of `stagger(dim: true)` with a
  reveal inside: the piece stays bright until that is done. It needs
  `start: auto`: a `start` written out keeps each version but the last on
  exactly its step, and a chain inside one of them still comes after it has
  gone and is never seen. The paper no longer moves the cursor ahead of such
  versions, so `alternatives(start: 2, [A], [B #stagger([x], [y])], [C])` has
  five step pages, as the browser has five steps, instead of six.

- **A `scene` is clipped on paper as in the browser.** A drawing larger than the
  scene's box ran over the slide on paper while the browser cut it at the box.
  `mosaic-greyscale` gives its counting number two points of headroom, since the
  round tops of its figures reached 0.74 points above the text.

- **Under `pages: "step"` a footnote's note no longer stands before its
  marker.** Every step page carried the notes of the whole slide: on step 1 of
  `alternatives([Fassung eins#footnote[note-eins]], [Fassung
  zwei#footnote[note-zwei]])` the body showed only "Fassung eins", the foot both
  notes, and the same with `#pause`. A note now stands on the step pages on
  which its marker is revealed, following the paper rule -- a replaced version
  takes its note along when it goes, a dimmed piece keeps it -- with the number
  it has in the browser, and the line keeps its place on the other pages, as
  the slot in the browser does.
  For a page per slide and the handout see the next entry. The
  footnote carries a mark with what `track` decided from -- the place of its
  `context`, the `at` as given, and three flags -- and the foot of the page
  decides again, reading at the same place. Carrying the decision itself was
  measured first and costs one layout run more than the body needs: a footnote
  in a `scene-layer` or a `cue-layer` followed by another slide stopped
  converging. The three layers' step functions therefore take a place to read
  at. All seventeen example decks come out of all three versions and the
  browser exactly as before.

- **The note of a replaced version on a page per slide and in the handout.**
  Both print the last version of an `alternatives`, the last stage of a `build`
  and the last stop of a `scene`, and both printed the notes of all of them:
  under "Fassung zwei" stood "1 note-eins" and "2 note-zwei", under the last
  stage of a two-stage `build` three notes for two markers. The note of what
  the page does not show is now hidden with it. Its line stays free, as on a
  step page, so the numbers remain the ones the browser gives; measured on an
  `alternatives`, a `build` and a `scene` with notes, each page per slide is now
  pixel for pixel the last step page of its slide. No step is read for it:
  whether a chain around the footnote is replaced is all these two versions
  ask.

- **A footnote in a chain inside a chain, in the browser.** Its note followed
  the innermost chain only. In `alternatives([Aussen eins #anim(at: "1-")[innen
  #footnote[n-innen]]], [Aussen zwei#footnote[n-zwei]])` the note of "innen"
  kept `data-at="1-"` and stood on step two at full strength while both sprites
  of its version were gone; the notes of a `stagger` inside a version stayed
  through the next version. The runtime caps a sprite by everything it sits in,
  but a note sits at the foot of the slide and in nothing. Its range is now
  worked out from every chain around the footnote, step by step and the way the
  runtime works out the state of the marker, including a dimmed rest; a step
  page already did so. One combination has no single range: a dimmed piece in a
  version that goes later rests first and is then gone. Its note stands at full
  strength for as long as its marker is visible, as on a step page. The frames
  of a `scene` or a `flipbook` count footnotes on without the background's
  numbers and so do not count as a chain around a later footnote. A deck whose
  footnotes sit in one chain at most gets byte for byte the HTML it got.

- **The two windows showed the pinned clock a second apart.** The stage rounded
  down (`Math.floor` on the exact remainder), the speaker view rounded
  (`Math.round` on a value already rounded once in transit), and the same clock
  stands on the same slide in both. At 124.6 seconds left the wall read 2:04 and
  the desk 2:05. Both now go through one function, and the remainder travels
  raw instead of pre-rounded. Under a coarse step the one second would have
  become a whole step: 120 against 125. A second cause sat beside it: the
  speaker view only redrew when the *rounded* second changed, so at 329.5
  seconds left it kept standing at 5:30 while the wall had already moved to
  5:29 -- it now also compares what the pinned clock actually displays.

- **The switch into over-time hung on a coincidence.** Word and signal colour
  were written after the gate that skips a redraw when the text is unchanged,
  and only ever got through because `uhrText` puts the `+` into an otherwise
  empty column, so the text happened to change in the same instant. They now sit
  behind an edge of their own, ahead of that gate -- which is more correct even
  without a step, and necessary with one.

- **The speaker view can be divided by hand.** A handle sits in the seam
  between the running slide and the note: drag it down for more slide, up for
  more note. Mouse, pen and touch go through one path; the arrow keys move it
  in 16-pixel steps, Shift in 64, Home and End go to the stops, and a
  double-click or Enter returns to the default. What is stored is a *fraction*
  of the divisible height and not a pixel count, kept beside the clock in
  `ts-pult:<deck>`: a speaker window is dragged to a beamer, and a height
  measured at 1400x900 is simply wrong at 1920x1080. A deck without speaker
  notes has nothing to divide and gets no handle; where the window is too small
  to divide, the handle steps out of the tab order. Asked for from a lesson deck
  whose notes were long and whose reading strip was three lines high.

- **What an output of a `bundle()` looks up stays in that output.** Typst runs
  introspection across the whole bundle, and the package looked things up in the
  whole bundle rather than in the file being built. The entries of a
  `contents()` in the slide deck and in the handout led into `talk.html`, or
  into `slides.pdf` with `html: none`, and the link back to the contents on a
  section slide led into `handout.pdf` -- from the HTML as well. A footnote's
  note stood three times on the first page of the deck and in the handout,
  collected from every output that has a slide of that number on a page of that
  number. Equations, figures, headings and a deck's own counters carried on from
  one output into the next: on two slides with an equation and a figure each,
  the deck began at "(3)" and "Figure 3", the handout at "(5)". `bundle(pages:
  "step", handout: …)` stopped with "gives a digit to two points on one slide"
  as soon as a `cue` group stood on a slide with more than one step -- `tour`
  and `vortragen` among the examples --, because the check of the HTML and of
  the handout saw the step pages of the deck. And several `document()` calls
  with a `presentation` in one bundle lost step pages and numbered their figures
  on: the step count of a slide was read at the end of the bundle, where the
  last document had written its own. With two HTML documents, the checks at the
  end of the second read what the first had filed: a `camera` whose `pin` stood
  only in the first went through without the message the same deck gives alone.
  Every lookup now stays in its own document, every output after the first sets
  back the counters it moves, and the HTML clears those records when it begins.
  Measured on all seventeen example decks as bundles -- eleven through
  `bundle()`, the six written as arguments through `document()` by hand --, with
  a page per slide and step by step, with and without the HTML: every page,
  every link and the HTML byte for byte as when that output is built alone, in
  as many layout runs as before. A deck outside a bundle is unchanged. The HTML
  now comes after the paper outputs, unless the slide deck comes step by step.
  In front of them, a reveal inside a version of `alternatives` or a stage of
  `build` with a slide after it -- `#alternatives([A], [#anim[x]])` -- gave
  eleven convergence warnings, and in `talk.html` the `x` never came, while the
  HTML built on its own was right; a `cue-layer` behind a `#pause` stood from
  step one. Behind them the HTML comes out as it does alone, and the bundles of
  `theme-lesson`, `tour` and `zeichnen` with a page per slide no longer warn,
  in as many layout runs or fewer. Step by step the same fault moves into the
  step pages instead, so there the HTML stays in front; a deck like the one
  above builds its HTML on its own. Two things Typst keeps across the whole
  bundle, out of the package's reach: a
  deck's own `state` carries on from one output into the next, having no value
  to start over from, and a label stands once in every output -- a reference
  such as `@fig` stops the bundle with "label occurs multiple times in the
  document" although the deck compiles alone, and an `outline(target: figure)`
  lists the figures of every output.

## [0.1.1] — 2026-09-10

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
  calls with the keys 1 to 9. A digit with nothing behind it does nothing at all
  -- on a slide without a group the digits set the class clock instead, see
  0.1.2.
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
