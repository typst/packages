// touying-ufac-unofficial — the theme: slide header, `slide`, `exercise-slide`/`example-slide`, the cover, the
// closing and section slides and `ufac-theme` (page, fonts, every set/show rule of the syntax, Touying configuration).
#import "@preview/touying:0.7.4": *
#import "constants.typ": colors
#import "utils.typ": *
#import "components.typ": *
#import "code.typ": _code-rules
#import "info.typ": _info-defaults, _prepare-configs, _deck, _date, _author-names, _authors

// ---------- header ----------
/// Header of a content slide: the current `==` in blue, fit to width. (Exercises and examples have no header: their
/// title is on the badge of their box.)
/// -> content
#let _header(
  /// Touying's `self`. -> dictionary
  self,
) = {
  set std.align(horizon)
  block(inset: (x: 1em), width: 100%, height: 1.5em, context {
    set text(self.colors.primary, size: 1.2em, weight: "bold")
    _in-box(self.colors.primary, utils.display-current-heading(level: 2, setting: utils.fit-to-width.with(grow: false, 100%)), kind: "title")
  })
}

// ---------- slides ----------
// Running subtitles.
// The first body is split at its top-level `===` headings and every segment goes into a one-column `grid` whose
// `grid.header(repeat: true)` re-shows the subtitle pill: Typst repeats that header at the top of every page the
// grid spans, which is the only in-flow mechanism for a running subtitle when the content overflows by itself (a
// page header cannot push the body down). The first page must look like a plain flow, so the heading itself is
// rendered inside the body cell (the theme's `show heading` rule, with the heading's own spacing) and the pill of the
// header row is hidden there: in `context` it checks whether it sits on a later page than the start of its own body
// cell, using two `metadata` markers (`_seg-mark` right before the grid, `_seg-body-mark` first in the cell; the
// header of grid k is preceded by marker k and by no later one). A heading inside the repeated header would be
// introspected once per page, hence the markers. A leading segment without `===` (a `---`/`#pagebreak()`
// continuation) shows the current subtitle from `_current-subtitle()` in the cell, as before, and repeats it the
// same way. The gap under a repeated pill is a `pad`, not `block(below:)`: weak spacing is trimmed at the end of
// the header cell. Between segments a weak `v(1.44em)` restores the heading's default `above` (Typst, levels ≥ 2),
// which is trimmed at the start of the cell. The header keeps the height of the pill on every page, hidden on the
// first one, where the body cell is pulled up by that height: the grid reserves the room of the header from its first
// page, so a header empty there let the continuation pages run into the footer. Only top-level `===` are handled: a
// subtitle nested in `#[ ]`, a column or a box still renders in flow, without repetition.
#let _seg-mark = "ufac-subtitle-segment"
#let _seg-body-mark = "ufac-subtitle-segment-body"
/// True when the header of a subtitle grid is laid out on a later page than the start of its own body cell.
/// -> bool
#let _is-continuation() = {
  let outer = query(metadata.where(value: _seg-mark).before(here()))
  if outer.len() == 0 { return false }
  let inner = query(metadata.where(value: _seg-body-mark).after(outer.last().location()))
  inner.len() > 0 and inner.first().location().page() < here().page()
}
/// One segment of the slide body: a one-column grid whose repeated header re-shows the subtitle pill on the
/// continuation pages.
/// -> content
#let _subtitle-grid(
  /// Function returning the subtitle body, or `none`. -> function
  title,
  /// Content of the segment. -> content
  body,
) = {
  metadata(_seg-mark)
  let pill(t) = pad(bottom: 1em, _subtitle-pill(t))
  grid(columns: 1fr, inset: 0pt, stroke: none,
    // on the first page only the height of the pill, empty
    grid.header(repeat: true, context {
      let t = title()
      if t != none { if _is-continuation() { pill(t) } else { block(height: measure(pill(t)).height) } }
    }),
    { metadata(_seg-body-mark); context { let t = title(); if t != none { v(-measure(pill(t)).height) } }; body })
}
/// Splits the slide body at its top-level `===` headings and wraps every segment in a @_subtitle-grid.
/// -> content
#let _with-running-subtitles(
  /// First body of the slide. -> content
  body,
) = {
  let segments = ((head: none, items: ()),)
  for c in _children(body) {
    if _is-h3(c) { segments.push((head: c, items: ())) } else { segments.last().items.push(c) }
  }
  // subtitles of this very slide: with `#pause` its earlier subpages precede the leading segment (see `_current-subtitle`)
  let own = segments.filter(s => s.head != none).map(s => s.head.body)
  for seg in segments {
    let items = { for c in seg.items { c } }
    if seg.head == none {
      if utils.trim(seg.items).len() > 0 {
        let current() = { let h = _current-subtitle(skip: own); if h != none { h.body } }
        _subtitle-grid(current, { context { let h = _current-subtitle(skip: own); if h != none { block(below: 1em, _subtitle-pill(h.body)) } }; items })
      }
    } else {
      v(1.44em, weak: true)
      _subtitle-grid(() => seg.head.body, { seg.head; items })
    }
  }
}
// ---------- exercises and examples ----------
/// The marker of the start of the solution of an example, alone on its line like Touying's `#pause`: what comes before
/// it is the statement and what comes after it the solution, opened by a dashed line and "Solução." / "Solution." /
/// "Solución." in bold. With a `#pause` right before or right after it, the line, the word and the solution appear on
/// the next step.
/// Written alone, `#solution`, the word ends with a period; `#solution(sep: ":")` ends it with another separator.
///
/// ```typ
/// == The state of water <example>
/// A script that reads the temperature and prints the state of the water.
/// #pause
/// #solution
/// Every condition is an `if`: …
/// ```
/// -> content
#let solution(
  /// What follows the word, in bold: `"."`, `":"`, `[:\ ]` (a colon and a line break) or any content. -> str | content
  sep: ".",
) = metadata((kind: "ufac-solution", word: "solution", sep: sep))

/// The marker of the start of the answer of an exercise: the same as @solution, opened by "Resposta." / "Answer." /
/// "Respuesta.", with the same separator.
/// -> content
#let answer(
  /// What follows the word, in bold: `"."`, `":"`, `[:\ ]` or any content. -> str | content
  sep: ".",
) = metadata((kind: "ufac-solution", word: "answer", sep: sep))

/// The marker of a solution or answer in a body, as `(word, sep)`, or `none`: the marker with its separator, or the bare
/// `#solution` / `#answer`, which Typst writes as a code element with the name of the function (the period).
///
/// #test(`_solution-marker(answer(sep: ":")) == ("answer", ":")`, `_solution-marker([x]) == none`)
/// -> array | none
#let _solution-marker(
  /// A child of a body. -> any
  c,
) = if _is-meta(c, "ufac-solution") { (c.value.word, c.value.at("sep", default: ".")) } else if (
  type(c) == content and c.func() == raw and c.at("lang", default: none) == "typc" and c.text in ("solution", "answer")
) { (c.text, ".") }

/// The opening of a solution: a thin dashed line almost from border to border of the box and the word ("Solução.",
/// "Resposta.") in bold, in the color of the box darkened. The word is in the same paragraph as what follows the
/// marker; before a block (a code block), it is alone on its line. At the top of a slide (a continuation after `---`)
/// there is nothing to separate, and the line is left out.
/// -> content
#let _solution-head(
  /// `"solution"` or `"answer"`. -> str
  word,
  /// Whether to draw the dashed line. -> bool
  line: true,
  /// What follows the word. -> str | content
  sep: ".",
) = {
  // the line goes 0.5em past the text (1em from the border) on each side: almost from border to border
  if line {
    context block(above: 0.65em, below: 0.65em, move(dx: -0.5em, std.line(length: 100% + 1em,
      stroke: (paint: _current-box-color(colors.primary), thickness: 0.4pt, dash: "dashed"))))
  }
  // after a separator that ends with a line break, no space: it would indent the next line
  let tail = if type(sep) != content { () } else if sep.has("children") { sep.children } else { (sep,) }
  while tail.len() > 0 and tail.last() == [ ] { tail = tail.slice(0, -1) }
  let breaks = tail.len() > 0 and tail.last().func() == linebreak
  context {
    text(weight: "bold", fill: _current-box-color(colors.primary).darken(30%), [#_words(text.lang).at(word)#sep])
    if not breaks { h(0.35em) }
  }
}

/// The body of an exercise or example with the solution opened at its marker (`#solution`, `#answer`): the opening
/// takes the place of the marker. The word opens the paragraph that follows the marker; after a blank line, it stays
/// alone on its line and the solution starts in a new paragraph. A `#pause` right after the marker goes before the
/// opening, which then appears with the solution. Done before Touying handles the `#pause`.
/// -> any
#let _split-solution(
  /// A body of the slide. -> any
  body,
) = {
  if type(body) != content or not body.has("children") { return body }
  let ch = body.children
  let i = ch.position(c => _solution-marker(c) != none)
  if i == none { return body }
  let (word, sep) = _solution-marker(ch.at(i))
  let head = ch.slice(0, i)
  let rest = ch.slice(i + 1)
  // the spaces and the paragraph breaks after the marker, and a `#pause` among them, which goes before the opening;
  // a blank line among them (a paragraph break) keeps the solution in a paragraph of its own
  let blank = false
  while rest.len() > 0 and (rest.first().func() in ([ ].func(), parbreak)
    or _is-meta(rest.first(), "touying-jump/pause/meanwhile")) {
    if rest.first().func() == metadata { head.push(rest.first()) }
    if rest.first().func() == parbreak { blank = true }
    rest = rest.slice(1)
  }
  // nothing before the marker but spaces and markers (a continuation after `---`): no line to separate
  let alone = head.all(c => c.func() in ([ ].func(), parbreak, metadata))
  let opening = (_solution-head(word, line: not alone, sep: sep),) + if blank { (parbreak(),) } else { () }
  (head + opening + rest).join()
}

/// The outline of the box of an exercise, open at the bottom: the sides go down, turn a quarter of a circle and end
/// where the line of the footer starts, which closes the box. A `curve`: a block without its bottom border draws only
/// half of the bottom corners, and covering the bottom border with a band of the fill leaves a thread of the border at
/// the edges of the band (the antialiasing of the PDF viewer).
/// -> content
#let _box-outline(
  /// Width. -> length
  w,
  /// Height. -> length
  h,
  /// Radius of the corners. -> length
  r,
  /// Stroke. -> stroke
  stroke,
) = {
  let k = 0.5523 * r   // the control points of a quarter of a circle in a Bézier curve
  curve(stroke: stroke,
    curve.move((r, h)),
    curve.cubic((r - k, h), (0pt, h - r + k), (0pt, h - r)),
    curve.line((0pt, r)),
    curve.cubic((0pt, r - k), (r - k, 0pt), (r, 0pt)),
    curve.line((w - r, 0pt)),
    curve.cubic((w - r + k, 0pt), (w, r - k), (w, r)),
    curve.line((w, h - r)),
    curve.cubic((w, h - r + k), (w - r + k, h), (w - r, h)),
  )
}

/// The size of one slide (in `context`): the page, or half of it with the notes of the speaker on a second screen, to
/// the right or below (`config-common(show-notes-on-second-screen:)`).
/// -> array
#let _slide-size(
  /// Touying's `self`. -> dictionary
  self,
) = {
  let notes = self.at("show-notes-on-second-screen", default: none)
  (if notes == right { page.width / 2 } else { page.width }, if notes == bottom { page.height / 2 } else { page.height })
}

/// The box of an exercise or example, as in a printed handout, drawn on the page: the fill in the color
/// lightened 95%, the badge with the title over the top border and the footer of the slide over the bottom one, in the
/// color of the item, its lines being the bottom border (the outline is open at the bottom and its sides turn into
/// them). It is the background of every page of the slide, so a content longer than one page goes on to the next one,
/// in the same box; the content itself flows in the body of the page, inside the box. The geometry is in absolute
/// lengths: the text of the slides is 22pt and the one of the footer 20pt.
/// -> dictionary
#let _item-page(
  /// Touying's `self`. -> dictionary
  self,
  /// Color of the item. -> color
  c,
  /// The content of the badge. -> content
  badge,
) = {
  let em = 22pt
  // the margin of the box to the page, the top of the badge, the room under the footer, the radius of the corners,
  // the thickness of the lines of the footer (0.1em of 20pt) and its height (1.5em of 20pt)
  let (mx, badge-top, below, r, thick, foot-h) = (1.2 * em, 1.3 * em, 0.5 * em, 6pt, 2pt, 30pt)
  // one line: the strut of `_pill-line` (1em) and the vertical inset (2 × 0.38em); a long title shrinks to fit
  let badge-h = 1.76 * em
  let background = context {
    let (w, h) = _slide-size(self)
    let (y-top, y-bottom) = (badge-top + badge-h / 2, h - below - foot-h / 2)
    let (bw, bh) = (w - 2 * mx, y-bottom - y-top)
    place(top + left, dx: mx, dy: y-top, {
      place(rect(width: bw, height: bh, fill: c.lighten(95%), radius: r))
      place(_box-outline(bw, bh, r, thick + c))
    })
    place(top + left, dx: mx + 0.8 * em, dy: badge-top, box(fill: c, radius: 3pt, inset: (x: 0.7 * em, y: 0.38 * em),
      text(size: em, _pill-text(c, utils.fit-to-width(grow: false, bw - 3.2 * em, _pill-line(badge))))))
  }
  // the footer centered on the bottom border, between the curves of the corners: its lines close the box. It is the
  // footer of the page, not part of the background, which is laid out before the slide counter steps. Touying lays
  // the footer out across the whole width of the page, down to its bottom
  let footer = context place(bottom + left, dx: mx + r, dy: -below, block(width: _slide-size(self).first() - 2 * (mx + r),
    height: foot-h, text(size: 20pt, _footer(self, color: _box-ink(c), rule-color: c, lift: false))))
  // the body inside the box: 1em from the sides, 0.75em under the badge, 0.6em above the footer
  config-page(header: none, footer: footer, background: background,
    margin: (top: badge-top + badge-h + 0.75 * em, bottom: below + foot-h + 0.6 * em, x: mx + em))
}

/// Inside the box of an item only what has no style of its own takes its color (bold text, markers, arrows,
/// highlights, inline code, links), as in an `emph-box`, plus the numbers of the lists, always blue elsewhere; a code
/// block, a callout and an `emph-box` keep theirs.
/// -> content
#let _in-item(
  /// Color of the item. -> color
  c,
  /// The body. -> content
  body,
) = {
  set list(marker: _markers(_box-ink(c)))
  let num(patterns) = (..nums) => {
    let d = nums.pos().len()
    text(fill: _box-ink(c), weight: "bold", numbering(patterns.at(calc.min(d, patterns.len()) - 1), nums.at(-1)))
  }
  set enum(full: true, numbering: num(("1.", "a)", "i.")))
  _in-box(_box-ink(c), body)
}

/// The marker of the continuation of an exercise or example after a `---`, with the heading of the item.
#let _continue-kind = "ufac-continue"

/// Marks the continuations of the exercises and examples. A `---` (or a `#pagebreak()`) inside an exercise breaks the
/// page, and the exercise goes on in the next slide, until a `==` heading of another kind. Touying calls the slide of a
/// continuation without
/// headings (`self.headings` is empty), so it would not know that it is an exercise, and its box changes the margins and
/// drops the header and the footer, which is decided before any `context`. So, before Touying splits the deck, a marker
/// with the heading of the item goes right after every `---` inside an exercise or example (also in the parts with
/// `#set`/`#show`, the `styled` ones, and inside `exercise-slide`/`example-slide`).
/// -> content
#let _mark-continuations(
  /// The deck. -> content
  body,
) = {
  let walk(children, h) = {
    let out = ()
    for c in children {
      if c.func() == heading and c.depth <= 2 {
        // a heading of a section or of a slide ends the item; one of an exercise or example opens another
        h = if c.depth == 2 and _label-kind(c.at("label", default: none)) != none { c } else { none }
        out.push(c)
      } else if utils.is-styled(c) {
        let (inner, after) = walk(if utils.is-sequence(c.child) { c.child.children } else { (c.child,) }, h)
        h = after
        out.push(utils.reconstruct-styled(c, inner))
      } else if utils.is-sequence(c) {
        let (inner, after) = walk(c.children, h)
        h = after
        out.push(inner)
      } else {
        out.push(c)
        // Touying breaks the slide at a `---` and at a `#pagebreak()` alike
        if h != none and (c in ([—], [---]) or c.func() == pagebreak) {
          out.push(metadata((kind: _continue-kind, heading: h)))
        }
      }
    }
    (out.join(), h)
  }
  if utils.is-sequence(body) { walk(body.children, none).first() } else { body }
}

/// The heading of the item that a body continues, if it starts with the marker of a continuation.
/// -> content | none
#let _continued-heading(
  /// The bodies of the slide. -> arguments
  bodies,
) = {
  let first = bodies.pos().at(0, default: none)
  if type(first) != content { return none }
  let ch = if first.has("children") { first.children } else { (first,) }
  let m = ch.find(c => c.func() != [ ].func() and c.func() != parbreak)
  if m != none and _is-meta(m, _continue-kind) { m.value.heading }
}

/// The slide of an exercise or example: the box of the item on the page, without the header (the badge carries the
/// title) and without the footer of the page (it goes into the box, in the color of the item).
/// -> content
#let _item-slide(
  /// Touying's `self`. -> dictionary
  self,
  /// The heading of the item. -> content
  h,
  /// `"exercise"` or `"example"`. -> str
  kind,
  /// Arguments of @slide. -> dictionary
  config, repeat, setting, composer,
  /// The slide bodies. -> array
  bodies,
) = {
  let (name, color) = _kind-style(self, kind)
  let ic = _kind-icon(self, kind)
  let sup = h.at("supplement", default: auto)
  if sup != auto and sup.func() == metadata {
    if sup.value.color != auto { color = sup.value.color }
    if sup.value.icon != auto { ic = sup.value.icon }
  }
  let badge = context [#_pill-icon(ic)#name #self.info.counter-prefix#_kind-index(kind, here().page(), label: h.at("label", default: none), body: h.body)#if h.body != [] [ — #h.body]]
  let self = utils.merge-dicts(self, _item-page(self, color, badge), config)
  // as on a normal slide: every body through `_flow` and a top-level `===` repeated on the overflow pages
  let bodies = bodies.map(_split-solution).map(_flow)
  if bodies.len() > 0 { bodies.at(0) = _with-running-subtitles(bodies.first()) }
  touying-slide(self: self, repeat: repeat, composer: composer, setting: body => _in-item(color, setting(body)),
    ..bodies)
}

/// Default slide of the theme, with header and footer. Every `==` heading opens one, so it is rarely called by
/// hand; the explicit form gives access to Touying's arguments.
///
/// A top-level `===` subtitle is repeated on the continuation pages of the slide. A slide without a title is a `==`
/// heading without text.
///
/// ```typ
/// #slide(composer: (1fr, 2fr))[Left][Right]
/// ```
/// -> content
#let slide(
  /// Slide configuration: a `config-xxx` dictionary (merge several with `utils.merge-dicts`). -> dictionary
  config: (:),
  /// Number of steps; `auto` lets Touying count the animations. -> auto | int
  repeat: auto,
  /// Set/show rules applied to the slide body. -> function
  setting: body => body,
  /// Layout of the bodies, e.g. `(1fr, 2fr)`, as in Touying's `side-by-side`. -> auto | array | function
  composer: auto,
  /// The slide bodies. -> content
  ..bodies,
) = touying-slide-wrapper(self => {
  let hs = self.at("headings", default: ())
  let h = if hs.len() > 0 { hs.last() } else { _continued-heading(bodies) }
  let kind = if h != none and h.depth == 2 { _label-kind(h.at("label", default: none)) }
  if kind != none { return _item-slide(self, h, kind, config, repeat, setting, composer, bodies.pos()) }
  let self = utils.merge-dicts(self, config-page(header: _header, footer: _footer), config)
  // every body goes through `_flow`: since Typst 0.12 a lone text in a container is not a paragraph, so a slide whose
  // content is only a shorthand (`-> item`, `> box`, `"quote"`) never reached the `show par` of the theme
  let bodies = bodies.pos().map(_flow)
  if bodies.len() > 0 { bodies.at(0) = _with-running-subtitles(bodies.first()) }
  touying-slide(self: self, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

// `exercise-slide`/`example-slide` return a level-2 heading with the label followed by the body (no
// `touying-slide-wrapper`: Touying flattens sequences at document level, so `---` inside the body works too). An
// explicit color or icon travels in the heading `supplement`. `depth` is used rather than `level` because Touying
// reads `depth` before layout.

/// `supplement` of the heading of an exercise or example slide: `auto`, or the color and the icon of the slide.
/// -> auto | content
#let _kind-supplement(
  /// Color of the box, or `auto`. -> auto | color
  color,
  /// Icon of the badge, or `auto`. -> auto | none | str | content
  icon,
) = if color == auto and icon == auto { auto } else { metadata((color: color, icon: icon)) }

/// Exercise slide: the red box of an exercise filling the slide, with a pencil and "Exercise 1.N — Title" on its badge,
/// numbered automatically. The function form of `== Title <exercise>`. Only the heading form can carry a unique label
/// (`== Title <exercise-tides>`) and be cited with `@exercise-tides`, which shows "Exercise 1.N" linked to the slide.
///
/// ```typ
/// #exercise-slide(title: [Tide table])[Find the next high tide.]
/// #exercise-slide(title: [Lab],
///   color: colors.primary,
///   icon: "terminal",
/// )[Another color and icon.]
/// ```
/// -> content
#let exercise-slide(
  /// Text after the number, following a dash; empty omits the dash. -> content
  title: [],
  /// Color of the box; `auto` is red (`tertiary`). -> auto | color
  color: auto,
  /// Icon before the name: the name of an `icon`, any content (an image) or `none` for no icon; `auto` is the icon of
  /// the theme, `ufac-theme(exercise-icon:)` (a pencil). -> auto | none | str | content
  icon: auto,
  /// Content of the slide; `---` or `#pagebreak()` inside it continues the same exercise. -> content
  body,
) = [#heading(depth: 2, supplement: _kind-supplement(color, icon), title) <exercise> #body]

/// Example slide: the green box of an example, with a beaker and "Example 1.N — Title" on its badge, with a counter
/// independent from the exercises. The function form of `== Title <example>`; see @exercise-slide.
///
/// ```typ
/// #example-slide(title: [Wave speed])[Longer waves travel faster in deep water.]
/// ```
/// -> content
#let example-slide(
  /// Text after the number, following a dash; empty omits the dash. -> content
  title: [],
  /// Color of the box; `auto` is green (`quaternary`). -> auto | color
  color: auto,
  /// Icon before the name: the name of an `icon`, any content (an image) or `none` for no icon; `auto` is the icon of
  /// the theme, `ufac-theme(example-icon:)` (a beaker). -> auto | none | str | content
  icon: auto,
  /// Content of the slide. -> content
  body,
) = [#heading(depth: 2, supplement: _kind-supplement(color, icon), title) <example> #body]

// ---------- cover ----------
/// The cover styles, the background of the cover and of the closing slide (`ufac-theme(cover-style:)`): the fill of the
/// page and whether it has the bubbles. `"bubbles"`, the default, is the solid UFAC blue with two translucent white
/// bubbles leaving the corners; `"gradient"`, a blue gradient (the blue darkened 35% to the blue, at 60°), with the
/// bubbles; `"plain"`, the blue alone.
///
/// #test(`_cover-styles.keys() == ("bubbles", "gradient", "plain")`, `not _cover-styles.plain.bubbles`)
/// -> dictionary
#let _cover-styles = (
  bubbles: (fill: colors.primary, bubbles: true),
  gradient: (fill: gradient.linear(colors.primary.darken(35%), colors.primary, angle: 60deg), bubbles: true),
  plain: (fill: colors.primary, bubbles: false),
)

/// The translucent white bubbles of the cover style: a large one leaving the top right corner and a smaller one the
/// bottom left; for the `background` of the page, in the size of one slide (the page is twice as large with the notes
/// on a second screen).
/// -> content
#let _bubbles(
  /// Touying's `self`. -> dictionary
  self,
) = {
  let (big, small) = (circle(radius: 8.5cm, fill: white.transparentize(94%)), circle(radius: 5.5cm, fill: white.transparentize(95%)))
  if self.at("show-notes-on-second-screen", default: none) == none {
    place(top + right, dx: 3cm, dy: -4.2cm, big)
    place(bottom + left, dx: -2.6cm, dy: 2.8cm, small)
  } else {
    // from the top left corner: the top right and the bottom left corners of the slide, not of the page
    context {
      let (w, h) = _slide-size(self)
      place(top + left, dx: w - 17cm + 3cm, dy: -4.2cm, big)
      place(top + left, dx: -2.6cm, dy: h - 11cm + 2.8cm, small)
    }
  }
}

/// The blue page of the cover and of the closing slide, with the background of the theme, without header nor footer.
/// -> dictionary
#let _blue-page(
  /// Touying's `self`. -> dictionary
  self,
) = config-page(fill: self.store.at("cover-fill", default: self.colors.primary), header: none, footer: none,
  margin: (x: 1.8em, top: 1.2em, bottom: 1.1em),
  background: if self.store.at("cover-bubbles", default: true) { _bubbles(self) })

/// White content on the blue page, with the convention of the pills (`*bold*`, code and icons readable).
/// -> content
#let _on-blue(
  /// Touying's `self`. -> dictionary
  self,
  /// The content. -> content
  body,
) = {
  set text(fill: self.colors.neutral-lightest)
  _in-box(self.colors.primary, body, kind: "pill")
}

/// A small label in spaced bold capitals, in yellow ("INSTRUCTORS", "ADVISOR").
/// -> content
#let _kicker(
  /// Touying's `self`. -> dictionary
  self,
  /// The label. -> content
  body,
  /// Size of the text. -> length
  size: 0.5em,
) = text(size: size, weight: "bold", fill: self.colors.secondary, tracking: 0.12em, upper(body))

/// The yellow rule under the title of the cover, of the closing slide and of the section slides.
/// -> content
#let _rule(
  /// Touying's `self`. -> dictionary
  self,
  /// Length of the rule. -> length
  length: 2.6cm,
) = line(length: length, stroke: 2.5pt + self.colors.secondary)

/// The logos of the deck in white, at a given height (the logos are sized in `em`, 0.64em high in the footer).
/// -> content | none
#let _logos-white(
  /// Touying's `self`. -> dictionary
  self,
  /// Height of the logos. -> length
  height: 0.9cm,
) = { let l = _logos(self, white: true); if l != none { text(size: height / 0.64, l) } }

/// The size of the text in the positions of the top and of the bottom of the cover, relative to the slide.
#let _slot-size = 0.7em

/// The authors on several lines: the label (`author-label`) and the authors as written, with the `\` breaks and the
/// labels in emphasis (`_Advisor_` becomes "ADVISOR" in yellow, with some room above it).
/// -> content
#let _authors-block(
  /// Touying's `self`. -> dictionary
  self,
  /// Label over the authors, or `none`. -> none | content
  label,
  /// Alignment of the lines. -> alignment
  align: left,
) = block(std.align(align, {
  if label != none { _kicker(self, label); v(0.35em) }
  show emph: it => box(inset: (top: 0.55em), text(size: 0.5em / 0.7, weight: "bold",
    fill: self.colors.secondary, tracking: 0.12em, style: "normal", upper(it.body)))
  text(size: _slot-size, _authors(self))
}))

/// The authors on one line: the label and the names in running text ("A, B and C"); of an author written as free
/// content, the names of its first group, as in the footer of the slides.
/// -> content
#let _authors-line(
  /// Touying's `self`. -> dictionary
  self,
  /// Label before the authors, or `none`. -> none | content
  label,
) = {
  if label != none {
    // the label is smaller than the names: on the same baseline, its middle would be below the middle of the capitals
    // of the names, where the white line passes; it goes up half the difference of the heights of the capitals
    context {
      let cap(size) = measure(text(size: size, weight: "bold", top-edge: "cap-height", bottom-edge: "baseline")[X]).height
      text(baseline: -(cap(_slot-size) - cap(0.5em)) / 2, _kicker(self, label))
    }
    h(0.6em)
  }
  text(size: _slot-size, _author-names(self))
}

/// Whether each layout of the cover has the white line at the bottom.
#let _preset-lines = (stack: false, line: true, top: false)

/// What each layout puts in each position of the cover.
/// -> dictionary
#let _presets(
  /// Touying's `self`. -> dictionary
  self,
  /// Label of the authors, or `none`. -> none | content
  label,
) = {
  let d = _date(self)
  let d = if _given(d) { text(size: _slot-size, fill: white.transparentize(12%), d) }
  let a = _given(_authors(self))
  let logos = _logos-white(self)
  (
    // the authors at the top right, in front of the logos; at the bottom, only the date, in the center
    top: (header-left: logos, header-right: if a { _authors-block(self, label, align: right) }, footer-center: d),
    // the logos at the top left, as in the other styles; one line at the bottom: the authors on the left, the white
    // line and the date
    line: (header-left: logos, footer-left: if a { _authors-line(self, label) }, footer-right: d),
    // the authors on several lines at the bottom left and the date on the right, without the line
    stack: (header-left: logos, footer-left: if a { _authors-block(self, label) }, footer-right: d),
  )
}

/// A band of the cover (the top or the bottom) without the line: the left and right positions with half the width each,
/// or, with something in the center, the center at its width and the sides with the rest, equally.
/// -> content | none
#let _row(
  /// The positions `left`, `center` and `right`. -> dictionary
  slots,
  /// Vertical alignment of the band. -> alignment
  valign,
) = {
  if slots.values().all(c => c == none) { return none }
  if slots.center == none {
    grid(columns: (1fr, 1fr), column-gutter: 1em, align: (left + valign, right + valign), slots.left, slots.right)
  } else {
    grid(columns: (1fr, auto, 1fr), column-gutter: 1em, align: (left + valign, center + valign, right + valign),
      slots.left, slots.center, slots.right)
  }
}

/// Cover: the blue page (`ufac-theme(cover-style:)`) with the logos large at the top left; in the center, the tag
/// (`short-title`), the `title`, the yellow rule, the `short-subtitle` in yellow, the `subtitle` and the content given
/// to it, centered both ways in the room between the top and the bottom; the authors and the date where the
/// `cover-layout` puts them. The institution does not appear (it is for `#info`). The slide counter is frozen, so the cover does
/// not count.
///
/// Each position takes `auto` (what the layout puts there), `none` (nothing), content (such as `#info("date")`), an
/// array (its items that show something, separated by a dot) or a function of `self`, like `footer-left` of the theme;
/// there `self.colors.primary` is the white of the text.
/// The text of the positions is 0.7 of the size of the slide.
///
/// ```typ
/// #title-slide()
/// #title-slide(cover-layout: "top", footer-center: none, footer-right: info("date"))
/// #title-slide[Slides at #link("https://example.com/slides")[example.com/slides]]
/// ```
/// -> content
#let title-slide(
  /// Where the authors and the date go; the logos are at the top left in every layout. `"line"`: the authors on one
  /// line at the bottom left, the white line and the date on the right. `"stack"`: the authors on several lines at the
  /// bottom left and the date on the right, without the line. `"top"`: the authors at the top right and the date in the
  /// center of the bottom, without the line. `auto` is the one of the `flavor` of the deck (`"line"` for a lecture).
  /// -> auto | str
  cover-layout: auto,
  /// Label over the authors ("Instructors"); before them in `"line"`. `auto` is `none`. -> none | auto | content
  author-label: none,
  /// What goes at the top left. -> auto | none | content | array | function
  header-left: auto,
  /// What goes at the top center. -> auto | none | content | array | function
  header-center: auto,
  /// What goes at the top right. -> auto | none | content | array | function
  header-right: auto,
  /// What goes at the bottom left. -> auto | none | content | array | function
  footer-left: auto,
  /// What goes at the bottom center. -> auto | none | content | array | function
  footer-center: auto,
  /// What goes at the bottom right. -> auto | none | content | array | function
  footer-right: auto,
  /// The white line at the bottom, like the one of the footer of the slides: from edge to edge, passing between what
  /// is at the bottom, at the height of the line of the footer. `auto` is the one of the layout. -> auto | bool
  footer-line: auto,
  /// Content in the center, below the titles, `#title-slide[..]`; `#title-slide()` has none. -> content
  ..body,
) = {
  assert("style" not in body.named(),
    message: "title-slide: style is now cover-layout (cover-layout: " + repr(body.named().at("style", default: none)) + ")")
  assert("cover-style" not in body.named(), message: "title-slide: cover-style goes in ufac-theme(cover-style: ..)")
  assert(body.named().len() == 0, message: "title-slide: unknown argument " + repr(body.named().keys().at(0, default: "")))
  assert(body.pos().len() <= 1, message: "title-slide: takes one optional content, `#title-slide[..]`")
  assert(cover-layout == auto or cover-layout in _preset-lines,
    message: "title-slide: cover-layout is auto (the one of the flavor), \"line\", \"stack\" or \"top\"")
  let body = body.pos().at(0, default: none)
  let author-label = if author-label == auto { none } else { author-label }
  // a body that shows nothing (`#title-slide[#provide-icons(..)]`, or `#title-slide[]`) stays on the slide, out of the
  // stack: as an item it added a gap that lifted the titles, and a cover with a body is not scaled down when it does
  // not fit
  let unseen = none
  if body != none and (_unseen(body) or _blank(body)) { unseen = body; body = none }
  touying-slide-wrapper(self => {
    // `auto`: what the `flavor` of the deck recommends (in the store)
    let preset-name = if cover-layout == auto { self.store.at("cover-layout", default: "line") } else { cover-layout }
    let self = utils.merge-dicts(self, _blue-page(self), config-common(freeze-slide-counter: true))
    let i = self.info
    let with-line = if footer-line == auto { _preset-lines.at(preset-name) } else { footer-line }
    let preset = _presets(self, author-label).at(preset-name)
    // the value of a position: the one of the layout, nothing, or the given content (or function of `self`) at the
    // size of the positions
    let slot(name, value) = {
      if value == auto { return preset.at(name, default: none) }
      if value == none { return none }
      // a function gets the white of the text as the primary color, as the function of the logo
      let v = if type(value) == function {
        let s = self
        s.colors.primary = self.colors.neutral-lightest
        value(s)
      } else { value }
      // an array: the items that show something, joined by the dot of the footer
      if type(v) == array { v = context _dot-join(v.filter(x => measure([#x]).width > 0pt)) }
      text(size: _slot-size, v)
    }
    let header = (left: slot("header-left", header-left), center: slot("header-center", header-center),
      right: slot("header-right", header-right))
    let footer = (left: slot("footer-left", footer-left), center: slot("footer-center", footer-center),
      right: slot("footer-right", footer-right))
    touying-slide(self: self, _on-blue(self, {
      unseen
      set par(leading: 0.4em, spacing: 0pt, justify: false)
      // the center: a stack from top to bottom, the tag (`short-title`), the `title`, the rule, the `short-subtitle` and
      // the `subtitle` (together, on two lines) and, last, the body
      let lines = (
        if _given(i.at("short-subtitle", default: none)) { text(size: 1.2em, fill: self.colors.secondary, i.short-subtitle) },
        if _given(i.subtitle) { text(size: 1.2em, i.subtitle) },
      ).filter(x => x != none)
      let items = (
        if _given(i.at("short-title", default: none)) { tag(i.short-title) },
        if _given(i.title) { text(size: 2em, weight: "bold", i.title) },
        // the rule goes with the title: without one, nothing in the middle of the page
        if _given(i.title) { _rule(self) },
        if lines.len() > 0 { lines.join(linebreak()) },
        body,
      ).filter(x => x != none)
      let titles = block(width: 90%, {
        set std.align(center)
        stack(dir: ttb, spacing: 0.75em, ..items)
      })
      let foot = {
        // at the bottom the text sits on its baseline: what is side by side lines up by its last line
        set text(bottom-edge: "baseline")
        if with-line {
          // the line of the footer of the slides, from edge to edge, passing between what is at the bottom and centered
          // on the capitals of its last line; the baseline is 0.55em from the edge, at the height of the footer
          let gap = 0.45em
          let edge = 1.8em - gap
          context {
            let cap = measure(text(size: _slot-size, top-edge: "cap-height", bottom-edge: "baseline")[X]).height
            let line-cell = box(width: 100%, height: cap, std.align(horizon, _line-white(self)))
            let (columns, cells) = ((), ())
            if footer.left != none { columns += (edge, auto); cells += (line-cell, footer.left) }
            if footer.center != none { columns += (1fr, auto, 1fr); cells += (line-cell, footer.center, line-cell) }
            else { columns.push(1fr); cells.push(line-cell) }
            if footer.right != none { columns += (auto, edge); cells += (footer.right, line-cell) }
            move(dx: -1.8em, dy: 0.55em, block(width: 100% + 3.6em,
              grid(columns: columns, column-gutter: gap, align: bottom, ..cells)))
          }
        } else { _row(footer, bottom) }
      }
      // three bands: the top, the center and the bottom. The titles and the body stay in the middle of the center, both
      // ways: in the middle of the page when the top and the bottom have similar heights, and in the middle of the free
      // room when the authors take many lines (at the top or at the bottom), without touching them. A center taller
      // than its room (a long title with many authors) is scaled down whole, with some room around it. Not with a body: Touying's marks
      // (`#pause`, `#alert`) do not go through `layout`
      let middle = if body != none { titles } else {
        layout(size => {
          let h = measure(titles, width: size.width).height
          // scaled with a room of 1em above and below, as the bands of the top and the bottom have no margin of their own
          if h <= size.height { titles } else { scale((size.height - 2em.to-absolute()) / h * 100%, reflow: true, titles) }
        })
      }
      block(width: 100%, height: 100%, grid(columns: 100%, rows: (auto, 1fr, auto), row-gutter: 0.6em,
        _row(header, top), std.align(center + horizon, middle), foot))
    }))
  })
}

// ---------- closing ----------
/// The checks of the arguments of @ending-slide, at the call: `(title, subtitle, body)`.
/// -> array
#let _ending-args(
  /// `title:` of the call. -> auto | none | content
  title,
  /// `subtitle:` of the call. -> auto | none | content
  subtitle,
  /// The other arguments. -> arguments
  args,
) = {
  assert(args.named().len() == 0, message: "ending-slide: unknown argument " + repr(args.named().keys().at(0, default: "")))
  let pos = args.pos()
  if title != auto or subtitle != auto {
    assert(pos.len() <= 1, message: "ending-slide: with title: or subtitle:, give at most one content, the body")
    (title, subtitle, pos.at(0, default: none))
  } else {
    assert(pos.len() <= 3, message: "ending-slide: at most three contents, [title][subtitle][body]")
    (pos.at(0, default: auto), pos.at(1, default: none), pos.at(2, default: none))
  }
}

/// Closing slide: the blue page of the cover, with a large title with the yellow
/// rule under it, a subtitle in yellow and a free body, centered; and the footer of the slides in white (the logos, the
/// title, the authors and the slide number). Without a title it says "Thank you!" in the language of the
/// deck; `title: none` removes the title and the rule.
///
/// Two forms: up to three contents in order, `[title][subtitle][body]`, or the named `title:` and `subtitle:` with
/// the content as the body.
///
/// ```typ
/// #ending-slide()
/// #ending-slide[Good work!][Next lecture: functions][Read chapter 3.]
/// #ending-slide(title: [Questions?], subtitle: [Lab 4 on Friday])[*See you!*]
/// #ending-slide(subtitle: [Questions?])[#info("contact")]
/// ```
/// -> content
#let ending-slide(
  /// The title; `auto` is "Thank you!" in the language of the deck, `none` removes it. -> auto | none | content
  title: auto,
  /// The subtitle, in yellow; `auto` and `none` give none. -> auto | none | content
  subtitle: auto,
  /// Up to three contents, `[title][subtitle][body]`, or the body alone with `title:` or `subtitle:`. -> content
  ..args,
) = {
  let (t, st, body) = _ending-args(title, subtitle, args)
  touying-slide-wrapper(self => {
    let t = if t == auto { _tr("thanks") } else { t }
    let st = if st == auto { none } else { st }
    // the page of the cover, with the footer of the slides in white (the logos, the title, the authors, the number)
    let self = utils.merge-dicts(self, _blue-page(self), config-page(footer: self => _footer(self, white: true),
      margin: (x: 1.8em, top: 1.2em, bottom: 1.75em)))
    let decorate(body) = _on-blue(self, {
      set par(leading: 0.45em, justify: false)
      // no logos at the top: they are in the footer
      std.align(center + horizon, {
        let gap = false   // room before every part but the first
        if t != none {
          block(spacing: 0pt, {
            set par(spacing: 0pt)
            text(size: 2em, weight: "bold", t)
            v(0.6em)
            _rule(self)
          })
          gap = true
        }
        if st != none {
          if gap { v(0.75em) }
          block(spacing: 0pt, text(size: 1.2em, fill: self.colors.secondary, st))
          gap = true
        }
        if body not in (none, []) {
          if gap { v(0.75em) }
          // the body goes through `_flow`, so that a lone `-> item`, `> box` or `"quote"` is rewritten, in a `box` as
          // wide as its content: a list keeps its markers next to its text, aligned at the left of the box, in the
          // center of the page
          box({
            show list: set std.align(left)
            show enum: set std.align(left)
            _flow(body)
          })
        }
      })
    })
    touying-slide(self: self, setting: decorate, if body == none { [] } else { body })
  })
}

// ---------- section ----------
/// Section slide, created by every `= Title`: on the left, "PART N" in the yellow tag, the title in blue and the yellow
/// rule, as on the cover; on the right, the content right after the `=` (typically an `#image`), at the page margin
/// from the edge, in a frame of 12em × 66% of the height of the content area: an image without a size fills it, an
/// image with a size keeps it and shrinks when it is larger than the frame, and a caption wraps at the width of the
/// frame. The theme calls it for every `=`; it is not meant to be called by hand.
/// -> content
#let new-section-slide(
  /// Slide configuration, see @slide.config. -> dictionary
  config: (:),
  /// Heading level, passed by Touying. -> int
  level: 1,
  /// Passed by Touying; the part is always numbered. -> bool
  numbered: true,
  /// Distance between the content (what follows `=`, on the right) and the right edge of the page: `auto` is the page
  /// margin (`1.8em`, the same as the text), `0pt` puts it flush with the edge. -> auto | length
  margin: auto,
  /// Content that follows the `=` heading. -> content
  body,
) = touying-slide-wrapper(self => {
  // The figure of the section has a frame of 12em × 66% of the height, at the right. An image without a size fills
  // it, scaled up or down with its proportions, never cropped (`fit: "contain"`); an image with a size keeps it, and is
  // scaled down whole when it passes the frame, so a small image or an icon (on a line of text, in a callout, in a
  // badge) is left alone. A size relative to the room (`width: 100%`, `height: 50%`) is taken against the frame. The
  // rule reaches an image inside a figure, an `align` or a link too. An image in a line takes its natural size, not
  // the room it is in, hence the measures by hand; the scale goes on the image itself, so a caption sits under it.
  // Typst gives a length as a `relative` (`0% + 8em`): only one with a ratio is relative to the room.
  let has-ratio(x) = type(x) == ratio or (type(x) == relative and x.ratio != 0%)
  let limit(it) = context {
    let (w, h) = (it.at("width", default: auto), it.at("height", default: auto))
    // the frame: 12em wide, and 66% of the height of the slide between its margins (about)
    let (fw, fh) = (12em.to-absolute(), (_slide-size(self).last() - 5em.to-absolute()) * 66%)
    // a relative size is resolved in a box of the width or the height of the frame, at its right
    let it = if has-ratio(w) and has-ratio(h) { box(width: fw, height: fh, std.align(right + horizon, it)) } else if (
      has-ratio(w)
    ) { box(width: fw, std.align(right, it)) } else if has-ratio(h) { box(height: fh, std.align(right + horizon, it)) } else {
      it
    }
    let n = measure(it)
    let f = if (w, h) == (auto, auto) { calc.min(fw / n.width, fh / n.height) } else {
      calc.min(1, fw / n.width, fh / n.height)
    }
    if calc.abs(f - 1) < 0.001 { it } else { scale(f * 100%, reflow: true, it) }
  }
  let body = if body in (none, []) { body } else {
    set image(fit: "contain")
    show image: limit
    // a caption wider than the frame and than the body of its figure wraps at the wider of the two, instead of
    // widening the column, which would push the title and the image; a body wider than the frame (a table, a drawing:
    // only an image is scaled to the frame) keeps its width, so it is never squeezed
    show figure: it => context {
      let w = calc.max(12em.to-absolute(), measure(it.body).width)
      if measure(it).width <= w { it } else { block(width: w, it) }
    }
    body
  }
  // the body goes in the second column of a `grid((1fr, auto))` and is moved by the horizontal page margin, so the
  // grid still reserves its width and the title never runs under it; `margin` pads it on the right inside the move,
  // so it stops that far from the edge
  let slide-body = {
    set std.align(left + horizon)
    let page-margin = self.page.at("margin", default: (:))
    let dx = if type(page-margin) == dictionary { page-margin.at("x", default: 1.8em) } else { page-margin }
    assert(margin == auto or type(margin) == length, message: "new-section-slide: margin is auto (the page margin) or"
      + " a length, such as 0pt (flush with the edge)")
    let gap = if margin == auto { dx } else { margin }
    let body = if body in (none, []) or gap == 0pt { body } else { pad(right: gap, body) }
    grid(columns: (1fr, auto), column-gutter: 1em, {
      set par(leading: 0.4em, spacing: 0pt, justify: false)
      // "PART N" in the yellow tag, the title in blue and the yellow rule, as on the cover
      tag(size: 0.7em, context [#_name(self, "part") #utils.display-current-heading-number(level: 1, numbering: "1")])
      v(0.7em)
      _in-box(self.colors.primary, text(size: 2em, fill: self.colors.primary, weight: "bold",
        utils.display-current-heading(level: 1, numbered: false)), kind: "title")
      v(0.75em)
      _rule(self, length: 3.2cm)
    }, move(dx: dx, body))
  }
  let self = utils.merge-dicts(self, config-page(footer: _footer), config)
  touying-slide(self: self, slide-body)
})

// ---------- rules ----------
// The `init` method of the theme is `_slide-rules` around `_rules`, in that order (the slide rules stay the outermost
// ones). They are separate so that a document that is not a deck (the manual in `docs/`) can apply `_rules` alone, with
// a stand-in `self` (`colors`, `methods.alert`, `info.counter-prefix`, `store`), and keep its own page, font size and headings.

/// Rules that only make sense on a slide: font and size, paragraph spacing and the headings (`=` hidden, `==` blue,
/// `===`/`====` as pills).
/// -> content
#let _slide-rules(
  /// Touying's `self`. -> dictionary
  self,
  /// The deck. -> content
  body,
) = {
  set text(font: "New Computer Modern Sans", size: 22pt, weight: 500, lang: self.store.lang, region: self.store.region)
  set par(leading: 0.55em, spacing: 0.9em)
  set heading(numbering: (..n) => none)
  show heading.where(level: 1): none
  show heading.where(level: 2): set text(fill: self.colors.primary, weight: "bold")
  // `===` and `====` are pills that do not create a slide; a top-level `===` is repeated on every continuation
  // and overflow page by `slide` (grid header), this rule renders the nested ones
  show heading.where(level: 3): it => block(below: 1em, _subtitle-pill(it.body))
  show heading.where(level: 4): it => block(below: 1em, _subtitle-pill(it.body))
  body
}

/// Every other set/show rule of the syntax: lists, enums, bold/italic, underline, highlight, the `==x==`, `~x~` and
/// `~~x~~` shorthands, paragraph rewriting, quotes, references and links, math, code (inline chip, blocks), tables, terms
/// and captions.
/// -> content
#let _rules(
  /// Touying's `self`, or a stand-in with `colors`, `methods.alert`, `info.counter-prefix` and `store`. -> dictionary
  self,
  /// The content. -> content
  body,
  /// Whether code blocks get the code rules of the theme (`_code-rules`); the manual frames its code itself. -> bool
  code: true,
) = {
  set list(marker: _markers(self.colors.secondary))
  // enum numbers: pattern by level, always blue and bold (levels 2+ were yellow until 2026-09-16)
  let num(patterns) = (..nums) => { let d = nums.pos().len(); text(fill: self.colors.primary, weight: "bold", numbering(patterns.at(calc.min(d, patterns.len()) - 1), nums.at(-1))) }
  set enum(full: true, numbering: num(("1.", "a)", "i.")))
  // `#set enum(numbering: "a)")`: rebuild the enum with the alternative pattern order (a `set` would not
  // override an explicit field)
  show enum.where(numbering: "a)"): it => { let f = it.fields(); let ch = f.remove("children"); enum(..f, full: true, numbering: num(("a)", "i.", "1.")), ..ch) }
  // bold and italic: black on a slide; in a light box bold takes the color of the box and italic stays black;
  // elsewhere (a pill, the blue page, a dark cell, the `==` title, the footer, an alert) both take the color of the
  // text around them
  show strong: it => context {
    let s = _box-color.get()
    if s.len() == 0 { set text(fill: self.colors.neutral-darkest); it }
    else if s.last().kind == "box" { set text(fill: s.last().color); it } else { it }
  }
  show emph: it => context {
    let s = _box-color.get()
    if s.len() == 0 or s.last().kind == "box" { set text(fill: self.colors.neutral-darkest); it } else { it }
  }
  // strong underline in UFAC yellow, behind the text and without evading descenders; the text color does not change.
  // Inside `emph-box` (kind "box" only: in pills/titles the yellow stays) it takes the box color; an explicit `stroke:` wins.
  let ul-stroke = .14em + self.colors.secondary
  set underline(stroke: ul-stroke, offset: .12em, evade: false, background: true)
  show underline: it => context {
    let s = _box-color.get()
    if s.len() == 0 or s.last().kind != "box" or it.stroke != ul-stroke { it } else { underline(stroke: .14em + s.last().color, it.body) }
  }
  set highlight(fill: self.colors.secondary-lighter)
  // inside a light box the default highlight becomes `color.lighten(80%)`; on a dark one (a pill, the blue page, a
  // dark cell) the yellow of UFAC, with the text in its blue; an explicit fill is kept (this also avoids recursion)
  show highlight: it => context {
    let s = _box-color.get()
    if s.len() == 0 or it.fill != self.colors.secondary-lighter { it }
    else if s.last().kind == "pill" { highlight(fill: self.colors.secondary, text(fill: self.colors.primary, it.body)) }
    else { highlight(fill: s.last().color.lighten(80%), it.body) }
  }
  // `==x==` → highlight, except inside `raw` (state `_in-raw`, set by the `show raw` gate below `codly-init`).
  // The inner text neither starts nor ends with a space, so the `==` left over by an escape (`=\=x== … ==z==`)
  // or an `a == b == c` in prose does not pair with the following `==`.
  show regex("==([^=\\s](?:[^=\n]*?[^=\\s])?)=="): it => context { if _in-raw.get() { it } else { highlight(it.text.slice(2, -2)) } }
  // Escape `\==x==` / `=\=x==`: the escaped `=` arrives as a lone text node ("="), but Typst merges neighbouring
  // text nodes before matching the regex (and `show par` only sees the paragraph after that). This rule, more
  // inner than the regex, wraps the lone "=" in a `styled` with a redundant `set text` (`tracking: 0pt`):
  // different styles prevent the merge without changing the look. A `box` would also work, but it opens a
  // line-break opportunity between the two `=` (the box is U+FFFC for the line breaker). Cost: one comparison
  // per text node (0.02 s over 301 pages).
  show text: it => if it.text == "=" { text(tracking: 0pt, it) } else { it }
  // `~text~` → underline and `~~text~~` → alert. In markup `~` is the non-breaking space (U+00A0), so the rules
  // look for those spaces in the already-merged text (like `==x==`: plain text only inside; `\~` escapes; in
  // `raw` the `~` is a literal tilde and nothing matches). `~text~` requires start/space/opening bracket before,
  // space/punctuation/end after, and no space at the ends of the inner text, so that `Fig.~1 and Tab.~2` is
  // left alone. The `~~` rule comes last (innermost) to win over `~`, since `\s` also matches U+00A0.
  let ul-re = regex("(^|[\\s(\\[{\"“‘])\u{a0}([^\u{a0}\\s](?:[^\u{a0}]*?[^\u{a0}\\s])?)\u{a0}($|[\\s)\\]}.,;:!?\"”’])")
  show ul-re: it => {
    let m = it.text.match(ul-re).captures
    text(m.at(0)) + underline(m.at(1)) + text(m.at(2))
  }
  show regex("\u{a0}\u{a0}([^\u{a0}]+?)\u{a0}\u{a0}"): it => (self.methods.alert)(self: self, it.text.trim("\u{a0}"))
  show par: _rewrite-par
  show quote: it => quote-box[#it.body #if it.attribution != none { linebreak(); std.align(right, text(size: .85em)[— #it.attribution]) }]
  // links and references inside a colored box (an `emph-box`, a callout, an exercise) in the color of the box,
  // darkened 25%; elsewhere the theme does not color them
  let in-box-color(it) = context {
    let s = _box-color.get()
    if s.len() == 0 or s.last().kind != "box" { it } else { show text: set text(fill: s.last().color.darken(25%)); it }
  }
  show link: in-box-color
  // @exercise-id / @example-id → "Exercício 1.N" / "Exemplo 1.N", bold in the kind's color (also inside a box), linked
  // to the slide.
  // `self.headings` cannot be used: Touying resets it after every `---` (`call-slide-fn-and-reset`).
  show ref: it => {
    let kind = _label-kind(it.target)
    if kind == none { in-box-color(it) } else { context {
      let hs = query(it.target)
      if hs.len() == 0 { it } else {
        let h = hs.first(); let (name, color) = _kind-style(self, kind)
        // the color is a `show text` inside the link, inner to the one of `show link` (the color of a box), so it wins
        link(h.location(), {
          show text: set text(fill: color, weight: "bold")
          [#name #self.info.counter-prefix#_kind-index(kind, h.location().page())]
        })
      }
    } }
  }
  show math.equation: set text(font: "New Computer Modern Math")
  show math.equation.where(block: true): set block(above: 0.55em, below: 0.55em)
  // code: inline `raw` as a gray chip (0.85em); blocks at 0.75em in the box of the theme (see code.typ). Chip colors:
  // gray out of context; inside a title or `emph-box` fill lightest / a light border / text dark of the container
  // color; inside a pill (already dark) fill dark / border darker / text lightest.
  show raw.where(block: false): it => context {
    let s = _box-color.get()
    let (bg, line, ink) = if s.len() == 0 { (luma(247), luma(210), self.colors.neutral-darkest) }
      else if s.last().kind == "pill" { let c = s.last().color; (c.darken(30%), c.darken(55%), c.lighten(85%)) }
      // the border lightened 78%: at 60% it was stronger than the border of the gray chip
      else { let c = s.last().color; (c.lighten(85%), c.lighten(78%), c.darken(30%)) }
    // baseline: -.07em lifts the chip to center it on the cap height (without it the top matches the top of
    // the letters and the bottom hangs 0.14em below the baseline, so the chip looks pushed down).
    // Width: `auto` lets the content wrap inside the chip when it contains spaces (long chips in a narrow
    // column). A single-token chip never wraps: in a column narrower than itself the `box` would be capped to
    // the available width and the text would spill out of the fill (the "y" of `quaternary` in 5 columns,
    // 2026-09-16); so without a space the width is the measured content and the fill covers the text even
    // when it overflows the column.
    let body = text(size: .85em, fill: ink, it)
    let w = if it.text.contains(" ") { auto } else { measure(body).width + .6em }
    box(width: w, fill: bg, stroke: .5pt + line, radius: 3pt, inset: (x: .3em), outset: (y: .2em), baseline: -.07em, body)
  }
  // a bare `#solution` / `#answer` (Typst writes the name of the function, as code) outside the top of an exercise or
  // example, where nothing opens it, is left out, as the marker with a separator (a metadata) is; after the rule of
  // the chip, so that no empty chip is left
  show raw.where(block: false, lang: "typc"): it => if it.text in ("solution", "answer") { none } else { it }
  show raw.where(block: true): set text(size: .75em)
  // code blocks: the box of the theme, or codly 2 when the deck passed it (code.typ)
  show: body => if code { _code-rules(self, body) } else { body }
  // `raw` gate for the `==x==` shorthand (see `_gate-raw`): after the code rules, to be the innermost rule
  show: _gate-raw
  // a lone `>` line set the signal: the next block equation gets an `eq-box` around its body. The equation is rebuilt
  // with the box inside (its numbering and label are kept); the rebuilt one is recognized by `_eq-mark` and left alone.
  show math.equation.where(block: true): it => if _has-eq-mark(it.body) {
    // already boxed: only tell the box where it sits (style and padding, see `_eq-ctx`)
    _eq-ctx.update(if _is-whole-eq-box(it.body) { "whole" } else { "part" }); it; _eq-ctx.update(none)
  } else { context {
    let c = _key-eq.get()
    if c == none { it } else {
      _key-eq.update(none)
      // The label stays on the original equation (attaching it again would duplicate it), which still counts as a
      // numbered equation although it is not drawn: step the counter back so that both share one number.
      let fields = it.fields(); let _ = fields.remove("body"); let _ = fields.remove("label", default: none)
      if it.numbering != none { counter(math.equation).update(n => calc.max(n - 1, 0)) }
      math.equation(..fields, eq-box(color: c, it))
    }
  } }
  // tables, terms and captions, ported from 0.0.1 (blue header with white text and white formulas)
  set table(inset: 0.5em, fill: (_, y) => if y == 0 { self.colors.primary },
    stroke: (x, y) => (y: self.colors.primary, right: self.colors.primary, x: if x > 0 and y == 0 { self.colors.neutral-lightest } else { self.colors.primary }))
  // the header is a pill (white text on the color), so its code chips, `*bold*` and icons follow the pill convention
  show table.cell.where(y: 0): it => { set text(fill: self.colors.neutral-lightest, weight: "bold"); show math.equation: set text(fill: self.colors.neutral-lightest); _in-box(self.colors.primary, it, kind: "pill") }
  // a cell filled with a tone of the palette follows its background, as the boxes and the pills do: on a light tone
  // (`table.cell(fill: colors.secondary-lighter)`) it is a box of the family's `-dark` color, readable on the fill
  // (code chips in light tones of it, `*bold*` in it); on a dark one (`colors.primary`, `colors.tertiary-dark`) it is a
  // pill, with white text as in the header. White (`neutral-lightest`) counts as no fill.
  show table.cell: it => {
    if it.y == 0 or type(it.fill) != color or it.fill == self.colors.neutral-lightest { return it }
    let tones = ("", "-light", "-lighter", "-lightest", "-dark", "-darker", "-darkest")
    let family = ("primary", "secondary", "tertiary", "quaternary", "neutral").find(f =>
      tones.any(t => self.colors.at(f + t, default: none) == it.fill))
    if family == none { it } else if _is-light(it.fill) { _in-box(self.colors.at(family + "-dark"), it, fill: it.fill) } else {
      set text(fill: self.colors.neutral-lightest)
      _in-box(it.fill, it, kind: "pill")
    }
  }
  // the caption is its body alone, without "Figure N", at 0.6 of the size of the text, so that a figure and its caption
  // fit on the slide together with the text around them; the size is a `set` rule, so that a deck gives another one
  // with its own `show figure.caption: set text(size: ..)`
  show figure.caption: set text(size: 0.6em)
  show figure.caption: it => it.body
  set terms(tight: false)
  show terms.item: it => { text(weight: "bold", fill: self.colors.neutral-darkest, it.term + ": "); it.description; linebreak() }
  body
}

// ---------- theme ----------
/// The theme. It sets the page (22pt New Computer Modern Sans, the UFAC header and footer) and every rule of the
/// syntax, and takes Touying's configs as extra arguments.
///
/// ```typ
/// #show: ufac-theme.with(
///   aspect-ratio: "16-9",
///   config-info(
///     subject: [Ocean Science], subject-code: [OCE110],
///     unit-title: [Tides and waves], unit: [Unit III],
///     author: [Prof. Author Name], counter-prefix: [3.],
///   ),
/// )
/// ```
///
/// `config-info` carries the fields of Touying: `title` (the name of the course or of the work), `short-title` (its code
/// or a shorter name: the tag of the cover), `subtitle` (the topic), `short-subtitle` (the lecture or the unit), `author`
/// (one, an array or free content), `date`, `institution`, `logo` and `contact`; the aliases of a course (`subject`,
/// `subject-code`, `unit`, `unit-title`, `course`, `semester`, `year`); the `flavor` of the presentation (`"lecture"` by
/// default); and `counter-prefix`, the prefix of the exercise and example numbers ("Exercise 1.N"; `none` gives
/// "Exercise N", the default of the flavors without units: `"coursework"`, `"tcc"`, `"dissertation"`, `"thesis"`).
/// -> content
#let ufac-theme(
  /// Any ratio accepted by Touying's `utils.page-args-from-aspect-ratio`: `"16-9"`, `"4-3"`, … -> str
  aspect-ratio: "16-9",
  /// Language of the deck: `"pt-br"` (or `"pt"`), `"en"` or `"es"`, optionally with a region (`"en-US"`). It sets
  /// `text.lang`/`region` and the localized names below. -> str
  lang: "pt-br",
  /// Name on the badge of exercise slides; `auto` is Exercício / Exercise / Ejercicio. -> auto | content
  exercise-name: auto,
  /// Name on the badge of example slides; `auto` is Exemplo / Example / Ejemplo. -> auto | content
  example-name: auto,
  /// Icon before the name on the badge of exercise slides: the name of an `icon`, any content (an image or a symbol,
  /// centered on the capitals like the icons) or `none` for no icon. `exercise-slide(icon:)` changes it on one slide.
  /// -> none | str | content | symbol
  exercise-icon: "pencil",
  /// Icon before the name on the badge of example slides, like `exercise-icon`. -> none | str | content | symbol
  example-icon: "beaker",
  /// The word of the tag of the section slides ("PART N"); `auto` is Parte / Part / Parte. -> auto | content
  part-name: auto,
  /// Left text of the footer; a function receives `self`, whose `self.colors.primary` is the color of the footer text
  /// (blue on the slides, white on the closing slide, the color of the box in an exercise or example, its dark tone for
  /// a light color). An array (or a function that returns one) shows its items
  /// separated by a dot, those that show nothing left out; with none left, the footer line runs unbroken. `auto` is the `short-title`, the
  /// `title` and, when the date is a `semester` or a `year`, the date ("AST101 • Astronomy • 2026.2").
  /// -> auto | content | array | function
  footer-left: auto,
  /// Right text of the footer; a function receives `self`, and an array is joined by a dot, as in `footer-left`. `auto`
  /// is the authors in running text ("A, B and C"); of an author written as free content, the names of its first
  /// group. -> auto | content | array | function
  footer-right: auto,
  /// The background of the cover and of the closing slide: `"bubbles"` (the solid UFAC blue with two translucent
  /// bubbles), `"gradient"` (a blue gradient, with the bubbles) or `"plain"` (the blue alone). -> str
  cover-style: "bubbles",
  /// The codly 2 module, when the deck imports it (`#import "@preview/codly:2.0.0" as codly`): the code blocks then go
  /// through codly, with the look of the theme (`codly-ufac-theme`). `none` gives the code box of the theme, without
  /// codly. -> none | module
  codly: none,
  /// Languages added to those of the theme (`code-languages`) or replacing any of them except the output, as
  /// `(name:, icon:)`.
  /// -> dictionary
  code-languages: (:),
  /// Touying configs, typically `config-info(..)`; also `config-common(..)`, `config-page(..)`. -> dictionary
  ..args,
  /// The deck. -> content
  body,
) = {
  let l = _lang-parse(lang)
  assert("logos" not in args.named(), message: "ufac-theme: logos moved to config-info(logo: ..) in 0.3.0")
  // the names before 0.3.0 was published, and the flavor, which goes in config-info
  let old-style = args.named().at("background", default: none)
  assert("background" not in args.named(), message: "ufac-theme: background is now cover-style (cover-style: "
    + repr(if old-style == "circles" { "bubbles" } else { old-style }) + ")")
  // what goes elsewhere, which Touying would take as an unknown config and ignore
  for (key, place) in (("flavor", "config-info(flavor: ..)"), ("kind", "config-info(flavor: ..)"),
    ("cover-layout", "title-slide(cover-layout: ..)"), ("author-label", "title-slide(author-label: ..)")) {
    assert(key not in args.named(), message: "ufac-theme: " + key + " goes in " + place)
  }
  let footer-left = if footer-left != auto { footer-left } else { self => {
    let parts = (self.info.at("short-title", default: none), self.info.title)
    if self.info.at("date-short", default: false) { parts.push(_date(self)) }
    parts
  } }
  let footer-right = if footer-right != auto { footer-right } else { self => _author-names(self) }
  let configs = _prepare-configs(l.lang, args.pos())
  assert(cover-style != "circles", message: "ufac-theme: the cover style \"circles\" is now \"bubbles\"")
  assert(cover-style in _cover-styles, message: "ufac-theme: cover-style is "
    + _cover-styles.keys().map(k => "\"" + k + "\"").join(", "))
  let bg = _cover-styles.at(cover-style)
  assert("section-margin" not in args.named(), message: "ufac-theme: section-margin moved to new-section-slide(margin:)"
    + " in 0.3.0: config-common(new-section-slide-fn: new-section-slide.with(margin: 0pt))")
  for (key, ic) in (("exercise-icon", exercise-icon), ("example-icon", example-icon)) {
    assert(ic == none or type(ic) in (str, content, symbol),
      message: "ufac-theme: " + key + " is the name of an icon, content (an image, a symbol) or none")
  }
  set text(size: 20pt)
  show: touying-slides.with(
    config-page(..utils.page-args-from-aspect-ratio(aspect-ratio), header-ascent: 0em, footer-descent: 0em, margin: (top: 3.25em, bottom: 1.75em, x: 1.8em)),
    config-common(slide-fn: slide, new-section-slide-fn: new-section-slide, receive-body-for-new-section-slide-fn: true, show-strong-with-alert: false),
    config-methods(
      init: (self: none, body) => {
        // the information of the deck, for `#info` (which reads it in `context`, anywhere)
        _deck.update((info: self.info, store: self.store, colors: self.colors,
          datetime-format: self.at("datetime-format", default: auto)))
        _slide-rules(self, _rules(self, body))
      },
      // in the color of the box around it, like bold text (blue elsewhere); yellow in a pill
      alert: (self: none, it) => alert(it),
    ),
    config-colors(..colors),
    config-store(lang: l.lang, region: l.region, exercise-name: exercise-name, example-name: example-name,
      exercise-icon: exercise-icon, example-icon: example-icon, part-name: part-name, footer-left: footer-left,
      footer-right: footer-right, codly: codly, code-languages: code-languages,
      cover-fill: bg.fill, cover-bubbles: bg.bubbles),
    // `author: none`, not `[]`: Touying turns a content author into a string for `set document(author:)` and an empty
    // content gives `none` there, so a deck without `config-info(author:)` failed to compile
    _info-defaults,
    ..configs.before,
    ..configs.configs,
    ..configs.after,
    ..args.named(),
  )
  _mark-continuations(body)
}
