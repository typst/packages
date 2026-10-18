// touying-ufac-unofficial — the theme: slide header, `slide`, `empty-slide`, `exercise-slide`/`example-slide`, the
// section and title slides and `ufac-theme` (page, fonts, every set/show rule of the syntax, codly setup, Touying
// configuration).
#import "@preview/touying:0.7.4": *
#import "@preview/codly:1.3.0": codly, codly-init
#import "constants.typ": colors, ufac-logo, code-languages
#import "utils.typ": *
#import "components.typ": *

// ---------- header ----------
/// Header of a content slide: the current `==` in blue (fit to width), or, when the heading carries an
/// `<exercise…>`/`<example…>` label, a pill "Exercise 1.N (Title)" / "Example 1.N (Title)" in the kind's color.
/// An explicit color from `exercise-slide(color:)` travels in the heading's `supplement` as `metadata((color: …))`.
/// -> content
#let _header(
  /// Touying's `self`. -> dictionary
  self,
) = {
  set std.align(horizon)
  block(inset: (x: 1em), width: 100%, height: 1.5em, context {
    let h = utils.current-heading(level: 2, depth: 2)
    let kind = if h != none { _label-kind(h.at("label", default: none)) } else { none }
    if kind != none {
      let (name, color) = _kind-style(self, kind)
      let sup = h.at("supplement", default: auto); if sup != auto and sup.func() == metadata { color = sup.value.color }
      _pill(color: color)[#name #self.info.counter-prefix#_kind-index(kind, here().page())#if h.body != [] [ (#h.body)]]
    } else {
      set text(self.colors.primary, size: 1.2em, weight: "bold")
      _in-box(self.colors.primary, utils.display-current-heading(level: 2, setting: utils.fit-to-width.with(grow: false, 100%)), kind: "title")
    }
  })
}

// ---------- slides ----------
// Running subtitles.
// The first body is split at its top-level `===` headings and every segment goes into a one-column `grid` whose
// `grid.header(repeat: true)` re-shows the subtitle pill: Typst repeats that header at the top of every page the
// grid spans, which is the only in-flow mechanism for a running subtitle when the content overflows by itself (a
// page header cannot push the body down). The first page must stay pixel-identical to a plain flow, so the heading
// itself is rendered inside the body cell (the theme's `show heading` rule, with the heading's own spacing) and the
// header row is empty there: in `context` it checks whether it sits on a later page than the start of its own body
// cell, using two `metadata` markers (`_seg-mark` right before the grid, `_seg-body-mark` first in the cell; the
// header of grid k is preceded by marker k and by no later one). A heading inside the repeated header would be
// introspected once per page, hence the markers. A leading segment without `===` (a `---`/`#pagebreak()`
// continuation) shows the current subtitle from `_current-subtitle()` in the cell, as before, and repeats it the
// same way. The gap under a repeated pill is a `pad`, not `block(below:)`: weak spacing is trimmed at the end of
// the header cell. Between segments a weak `v(1.44em)` restores the heading's default `above` (Typst, levels ≥ 2),
// which is trimmed at the start of the cell. Only top-level `===` are handled: a subtitle nested in `#[ ]`, a
// column or a box still renders in flow, without repetition.
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
  grid(columns: 1fr, inset: 0pt, stroke: none,
    grid.header(repeat: true, context { if _is-continuation() { let t = title(); if t != none { pad(bottom: 1em, _pill(t)) } } }),
    { metadata(_seg-body-mark); body })
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
      if _trim(seg.items).len() > 0 {
        let current() = { let h = _current-subtitle(skip: own); if h != none { h.body } }
        _subtitle-grid(current, { context { let h = _current-subtitle(skip: own); if h != none { block(below: 1em, _pill(h.body)) } }; items })
      }
    } else {
      v(1.44em, weak: true)
      _subtitle-grid(() => seg.head.body, { seg.head; items })
    }
  }
}
/// Default slide of the theme, with header and footer. Every `==` heading opens one, so it is rarely called by
/// hand; the explicit form gives access to Touying's arguments.
///
/// A top-level `===` subtitle is repeated at the top of every continuation page of the slide, whether the page comes
/// from `---`, from `#pagebreak()` or from content that overflows by itself, unless the continuation starts with
/// another `===`. A subtitle nested in `#[ ]`, a column or a box is not repeated.
///
/// ```typ
/// #slide(composer: (1fr, 2fr))[Left][Right]
/// ```
/// -> content
#let slide(
  /// Slide configuration: a `config-xxx` dictionary (merge several with `utils.merge-dicts`). -> dictionary
  config: (:),
  /// Number of subslides; `auto` lets Touying count the animations. -> auto | int
  repeat: auto,
  /// Set/show rules applied to the slide body. -> function
  setting: body => body,
  /// Layout of the bodies, e.g. `(1fr, 2fr)`, as in Touying's `side-by-side`. -> auto | array | function
  composer: auto,
  /// The slide bodies. -> content
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(self, config-page(header: _header, footer: _footer), config)
  let bodies = bodies.pos()
  if bodies.len() > 0 { bodies.at(0) = _with-running-subtitles(bodies.first()) }
  touying-slide(self: self, repeat: repeat, setting: setting, composer: composer, ..bodies)
})

/// Slide without the header but with the footer (Touying's `empty-slide` removes both). Same arguments as @slide.
/// -> content
#let empty-slide(
  /// Slide configuration, see @slide.config. -> dictionary
  config: (:),
  /// Number of subslides. -> auto | int
  repeat: auto,
  /// Set/show rules applied to the slide body. -> function
  setting: body => body,
  /// Layout of the bodies. -> auto | array | function
  composer: auto,
  /// The slide bodies. -> content
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(self, config-page(footer: _footer), config)
  touying-slide(self: self, repeat: repeat, setting: setting, composer: composer, ..bodies.pos())
})

// `exercise-slide`/`example-slide` return a level-2 heading with the label followed by the body (no
// `touying-slide-wrapper`: Touying flattens sequences at document level, so `---` inside the body works too). An
// explicit color travels in the heading `supplement`. `depth` is used rather than `level` because Touying reads
// `depth` before layout.

/// Exercise slide: the header becomes a pill "Exercise 1.N (Title)", numbered automatically. The function form of
/// `== Title <exercise>`. Only the heading form can carry a unique label (`== Title <exercise-ogata>`) and be cited
/// with `@exercise-ogata`, which shows "Exercise 1.N" linked to the slide.
///
/// ```typ
/// #exercise-slide(title: [Ogata 4.6])[Find the transfer function.]
/// ```
/// -> content
#let exercise-slide(
  /// Text in parentheses after the number; empty omits the parentheses. -> content
  title: [],
  /// Color of the pill; `auto` is red (`tertiary`). -> auto | color
  color: auto,
  /// Content of the slide; `---` inside it continues the same exercise. -> content
  body,
) = [#heading(depth: 2, supplement: if color == auto { auto } else { metadata((color: color)) }, title) <exercise> #body]

/// Example slide: a pill "Example 1.N (Title)", with a counter independent from the exercises. The function form
/// of `== Title <example>`; see @exercise-slide.
///
/// ```typ
/// #example-slide(title: [XOR network])[Two hidden neurons are enough.]
/// ```
/// -> content
#let example-slide(
  /// Text in parentheses after the number; empty omits the parentheses. -> content
  title: [],
  /// Color of the pill; `auto` is green (`quaternary`). -> auto | color
  color: auto,
  /// Content of the slide. -> content
  body,
) = [#heading(depth: 2, supplement: if color == auto { auto } else { metadata((color: color)) }, title) <example> #body]

/// Section slide, created by every `= Title`: "Part N: Title" in blue on the left and the content right after the
/// `=` (typically an `#image`) on the right, flush with the page edge. `#pad(right: 1.8em)[#image(..)]` restores the
/// page margin. Not meant to be called by hand.
/// -> content
#let new-section-slide(
  /// Slide configuration, see @slide.config. -> dictionary
  config: (:),
  /// Heading level, passed by Touying. -> int
  level: 1,
  /// Passed by Touying; the part is always numbered. -> bool
  numbered: true,
  /// Content that follows the `=` heading. -> content
  body,
) = touying-slide-wrapper(self => {
  // the body goes in the second column of a `grid((1fr, auto))` and is moved by the horizontal page margin, so the
  // grid still reserves its width and the title never runs under it
  let slide-body = {
    set std.align(left + horizon)
    set image(width: 12em, height: 66%)
    let margin = self.page.at("margin", default: (:))
    let dx = if type(margin) == dictionary { margin.at("x", default: 1.8em) } else { margin }
    grid(columns: (1fr, auto), {
      set text(size: 2em, fill: self.colors.primary, weight: "bold")
      _in-box(self.colors.primary, context [#_name(self, "part") #utils.display-current-heading-number(level: 1, numbering: "1"): \ #utils.display-current-heading(level: 1, numbered: false)], kind: "title")
    }, move(dx: dx, body))
  }
  let self = utils.merge-dicts(self, config-page(footer: _footer), config)
  touying-slide(self: self, slide-body)
})

/// Cover: blue page with the subject (large, white), the subtitle (yellow) and the title (white) of `config-info`
/// centered, `footer-left`/`footer-right` in white at the top and the white logo at the bottom. The slide counter is
/// frozen, so the cover does not count.
/// -> content
#let title-slide() = touying-slide-wrapper(self => {
  let footer(self) = {
    set std.align(bottom)
    move(grid(columns: (1em, auto, 1fr), rows: 1.5em, align: horizon,
      _line-white(self),
      box(image(bytes(ufac-logo.replace("#0c4da2", "#fff")), height: 0.64em), inset: 0.2em),
      _line-white(self)), dy: -0.05em)
  }
  let header(self) = {
    set text(self.colors.neutral-lightest)
    set std.align(center + top)
    show: block.with(width: 100%, height: 1.3em)
    grid(columns: (auto, auto), rows: 1.5em, align: horizon,
      _cell(self, pad-left: 1em, pos: "left", white: true, utils.call-or-display(self, self.store.footer-left)),
      _cell(self, pad-right: 1em, pos: "right", white: true, utils.call-or-display(self, self.store.footer-right)))
  }
  let self = utils.merge-dicts(self, config-page(fill: self.colors.primary, header: header, footer: footer), config-common(freeze-slide-counter: true))
  touying-slide(self: self, std.align(center + horizon, {
    text(size: 2em, fill: white, weight: "bold", self.info.subject); parbreak()
    text(size: 1.2em, fill: self.colors.secondary, self.info.subtitle); linebreak()
    text(size: 1.2em, fill: white, self.info.title)
  }))
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
  show heading.where(level: 3): it => block(below: 1em, _pill(it.body))
  show heading.where(level: 4): it => block(below: 1em, _pill(it.body))
  body
}

/// Every other set/show rule of the syntax: lists, enums, bold/italic, underline, highlight, the `==x==`, `~x~` and
/// `~~x~~` shorthands, paragraph rewriting, quotes, references, math, code (inline chip, codly blocks), tables, terms
/// and captions.
/// -> content
#let _rules(
  /// Touying's `self`, or a stand-in with `colors`, `methods.alert`, `info.counter-prefix` and `store`. -> dictionary
  self,
  /// The content. -> content
  body,
  /// Look of the code-block box: `fill`, `stroke`, `radius` and `inset` of `_code-box` (the manual frames its code differently). -> dictionary
  code-box: (:),
) = {
  set list(marker: _markers(self.colors.secondary))
  // enum numbers: pattern by level, always blue and bold (levels 2+ were yellow until 2026-09-16)
  let num(patterns) = (..nums) => { let d = nums.pos().len(); text(fill: self.colors.primary, weight: "bold", numbering(patterns.at(calc.min(d, patterns.len()) - 1), nums.at(-1))) }
  set enum(full: true, numbering: num(("1.", "a)", "i.")))
  // `#set enum(numbering: "a)")`: rebuild the enum with the alternative pattern order (a `set` would not
  // override an explicit field)
  show enum.where(numbering: "a)"): it => { let f = it.fields(); let ch = f.remove("children"); enum(..f, full: true, numbering: num(("a)", "i.", "1.")), ..ch) }
  // bold: black; the box color inside `emph-box` and the `==` title; white inside a pill (the pill color would hide it)
  show strong: it => context { set text(fill: if _in-pill() { white } else { _current-box-color(self.colors.neutral-darkest) }); it }
  show emph: set text(fill: self.colors.neutral-darkest)
  // strong underline in UFAC yellow, behind the text and without evading descenders; the text color does not change.
  // Inside `emph-box` (kind "box" only: in pills/titles the yellow stays) it takes the box color; an explicit `stroke:` wins.
  let ul-stroke = .14em + self.colors.secondary
  set underline(stroke: ul-stroke, offset: .12em, evade: false, background: true)
  show underline: it => context {
    let s = _box-color.get()
    if s.len() == 0 or s.last().kind != "box" or it.stroke != ul-stroke { it } else { underline(stroke: .14em + s.last().color, it.body) }
  }
  set highlight(fill: self.colors.secondary-lighter)
  // inside a box the default highlight becomes `color.lighten(80%)`; an explicit fill is kept (this also avoids recursion)
  show highlight: it => context {
    let s = _box-color.get()
    if s.len() == 0 or it.fill != self.colors.secondary-lighter { it } else { highlight(fill: s.last().color.lighten(80%), it.body) }
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
  // @exercise-id / @example-id → "Exercício 1.N" / "Exemplo 1.N", bold in the kind's color, linked to the slide.
  // `self.headings` cannot be used: Touying resets it after every `---` (`call-slide-fn-and-reset`).
  show ref: it => {
    let kind = _label-kind(it.target)
    if kind == none { it } else { context {
      let hs = query(it.target)
      if hs.len() == 0 { it } else {
        let h = hs.first(); let (name, color) = _kind-style(self, kind)
        link(h.location(), text(fill: color, weight: "bold")[#name #self.info.counter-prefix#_kind-index(kind, h.location().page())])
      }
    } }
  }
  show math.equation: set text(font: "New Computer Modern Math")
  show math.equation.where(block: true): set block(above: 0.55em, below: 0.55em)
  // code: inline `raw` as a gray chip (0.85em); blocks at 0.75em via codly (gray numbers, no zebra nor language
  // header, smart indent, never split across pages). Chip colors: gray out of context; inside a title or
  // `emph-box` fill lightest / border lighter / text dark of the container color; inside a pill (already dark)
  // fill dark / border darker / text lightest.
  show raw.where(block: false): it => context {
    let s = _box-color.get()
    let (bg, line, ink) = if s.len() == 0 { (luma(247), luma(210), self.colors.neutral-darkest) }
      else if s.last().kind == "pill" { let c = s.last().color; (c.darken(30%), c.darken(55%), c.lighten(85%)) }
      else { let c = s.last().color; (c.lighten(85%), c.lighten(60%), c.darken(30%)) }
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
  show raw.where(block: true): set text(size: .75em)
  show: codly-init.with()
  codly(
    // language label (`#local(display-name: true)`): codly's default moves it 0.32em out of the line (it
    // invaded the right border of the `_code-box`) and gives it 0.32em of vertical padding, taller than the line
    // (it touched the top border); with y: .1em it fits the first line like a pill (variants measured 2026-09-16)
    lang-outset: (x: 0pt, y: 0pt),
    lang-inset: (x: .32em, y: .1em),
    languages: code-languages,
    display-name: false, display-icon: false, zebra-fill: none, fill: none, stroke: none,
    radius: 0pt, inset: (x: .3em, y: .16em), number-format: n => text(fill: luma(160), size: .8em, str(n)),
    smart-indent: true, breakable: false,
  )
  // `raw` gate for the `==x==` shorthand (see `_gate-raw`): after `codly-init`, to be the innermost rule
  show: _gate-raw
  show: _code-box.with(..code-box)   // block box (see `_code-box`): also inner to codly's rule
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
  show table.cell.where(y: 0): it => { set text(fill: self.colors.neutral-lightest, weight: "bold"); show math.equation: set text(fill: self.colors.neutral-lightest); it }
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
///     title: [Training and evaluation], subtitle: [Units III and IV],
///     author: [Prof. Name], subject: [Neural Networks], subject-code: [PPGEE016],
///     counter-prefix: [1.],
///   ),
/// )
/// ```
///
/// `config-info` carries `subject`, `subtitle`, `title`, `author`, `subject-code` and `counter-prefix`, the prefix of
/// the exercise and example numbers ("Exercise 1.N"; `none` gives "Exercise N").
/// -> content
#let ufac-theme(
  /// Any ratio accepted by Touying's `utils.page-args-from-aspect-ratio`: `"16-9"`, `"4-3"`, … -> str
  aspect-ratio: "16-9",
  /// Language of the deck: `"pt-br"` (or `"pt"`), `"en"` or `"es"`, optionally with a region (`"en-US"`). It sets
  /// `text.lang`/`region` and the localized names below. -> str
  lang: "pt-br",
  /// Name in the pill of exercise slides; `auto` is Exercício / Exercise / Ejercicio. -> auto | content
  exercise-name: auto,
  /// Name in the pill of example slides; `auto` is Exemplo / Example / Ejemplo. -> auto | content
  example-name: auto,
  /// Prefix of the section slide ("Part N:"); `auto` is Parte / Part / Parte. -> auto | content
  part-name: auto,
  /// Left text of the footer; a function receives `self`. `auto` is the subject code, a dot and the subject (the dot
  /// only when both are given). -> auto | content | function
  footer-left: auto,
  /// Right text of the footer; a function receives `self`. `auto` is the author. -> auto | content | function
  footer-right: auto,
  /// Touying configs, typically `config-info(..)`; also `config-common(..)`, `config-page(..)`. -> dictionary
  ..args,
  /// The deck. -> content
  body,
) = {
  let l = _lang-parse(lang)
  let given(x) = x not in (none, [], "")
  let footer-left = if footer-left != auto { footer-left } else {
    self => (self.info.subject-code, self.info.subject).filter(given).join(" " + _sep-dot + " ")
  }
  let footer-right = if footer-right != auto { footer-right } else { self => self.info.author }
  set text(size: 20pt)
  show: touying-slides.with(
    config-page(..utils.page-args-from-aspect-ratio(aspect-ratio), header-ascent: 0em, footer-descent: 0em, margin: (top: 3.25em, bottom: 1.75em, x: 1.8em)),
    config-common(slide-fn: slide, new-section-slide-fn: new-section-slide, receive-body-for-new-section-slide-fn: true, show-strong-with-alert: false),
    config-methods(
      init: (self: none, body) => _slide-rules(self, _rules(self, body)),
      alert: (self: none, it) => context text(fill: _emph-color(self.colors.primary), weight: "bold", it),
      cover: _cover,   // veil in the page colour at 85% over the laid-out content (see `_cover` in utils.typ)
    ),
    config-colors(..colors),
    config-store(lang: l.lang, region: l.region, exercise-name: exercise-name, example-name: example-name, part-name: part-name, footer-left: footer-left, footer-right: footer-right),
    // `author: none`, not `[]`: Touying turns a content author into a string for `set document(author:)` and an empty
    // content gives `none` there, so a deck without `config-info(author:)` failed to compile
    config-info(title: [], subtitle: [], subject: [], subject-code: [], author: none, counter-prefix: [1.]),
    ..args,
  )
  body
}
