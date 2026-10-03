// touying-ufac-unofficial — internal helpers: content inspection, the context color stack, the `raw` gate and code box,
// backslash escapes, exercise/example labels, the current-subtitle query and the footer pieces.
// Names starting with `_` are not part of the public API (Typst has no private bindings, so they stay reachable).
#import "@preview/touying:0.7.4": *
#import "@preview/linguify:0.5.0": linguify
#import "constants.typ": colors, ufac-logo

// ---------- content inspection ----------
#let _seq = [].func()
#let _children(it) = if it.func() == _seq { it.children } else { (it,) }
#let _styled = { set text(fill: red); [x] }.func()
/// Already-realized content arrives as `styled(child: …)`; peel the layers off.
///
/// #test(`_unstyle({ set text(fill: red); [x] }) == [x]`, `_unstyle([x]) == [x]`)
/// -> content
#let _unstyle(
  /// Any content. -> content
  c,
) = { while c.func() == _styled { c = c.child }; c }
#let _is-space(c) = c == [ ]
#let _is-text(c) = c.func() == text and c.has("text")
#let _is-dq(c) = c.func() == smartquote and c.double
/// Level-3 heading before or after layout: `depth` exists before layout, `level` only after it.
///
/// #test(`_is-h3(heading(depth: 3)[x])`, `not _is-h3(heading(depth: 2)[x])`, `not _is-h3([x])`)
/// -> bool
#let _is-h3(
  /// Any content. -> content
  c,
) = c.func() == heading and (c.at("depth", default: none) == 3 or c.at("level", default: none) == 3)
/// Strips empty contents (`[]`, `[ ]`, `parbreak()`, `linebreak()`) from both ends of an array of children
/// (the theme's own, so that it does not depend on where Touying keeps its `trim`: 0.7.4 exports `utils.trim`, 0.8 moved it
/// to `core.tree`, which is not exported).
///
/// #test(
///   `_trim(([ ], [a], parbreak(), [b], [ ], [])) == ([a], parbreak(), [b])`,
///   `_trim(([ ], parbreak())) == ()`,
///   `_trim(()) == ()`,
/// )
/// -> array
#let _trim(
  /// Children of a sequence. -> array
  arr,
  /// What counts as empty. -> array
  empty: ([], [ ], parbreak(), linebreak()),
) = {
  let i = 0; let j = arr.len()
  while i < j and arr.at(i) in empty { i += 1 }
  while j > i and arr.at(j - 1) in empty { j -= 1 }
  arr.slice(i, j)
}
#let _first-child(body) = { let ch = _trim(_children(body)); if ch.len() > 0 { ch.first() } else { none } }
/// A body made of a single paragraph inside a `block`/`grid` does not become a `par` element (Typst treats it as
/// inline content), so the `show par` rewrites (`->`, `> `, `"…"`) never run. A leading `parbreak()` forces the
/// paragraph without adding space.
/// -> content
#let _flow(
  /// Body of a box or column. -> content
  body,
) = { parbreak(); body }

// ---------- context color stack ----------
/// Stack of `(color:, kind:)` entries, `kind` ∈ "box" | "pill" | "title", pushed by `emph-box` (body: "box";
/// title badge: "pill"), `_pill`, the slide header ("title") and the section title ("title"). `*bold*`,
/// `==highlight==`, the `->` arrow, `#underline`, `#icon` and inline `raw` read the color at layout time (in
/// `context`): in the `> box` form the paragraph reaches `show par` already realized (strong/highlight become
/// `styled(...)` with black/yellow baked in), so set/show rules inside the box cannot reach them anymore; a `state`
/// resolves at the right place. Inline `raw` uses light tones in boxes and titles and dark tones with light text in pills.
/// -> state
#let _box-color = state("ufac-box-color", ())
#let _in-box(color, body, kind: "box") = {
  _box-color.update(s => s + ((color: color, kind: kind),))
  body
  _box-color.update(s => s.slice(0, -1))
}
#let _current-box-color(fallback) = { let s = _box-color.get(); if s.len() == 0 { fallback } else { s.last().color } }
#let _in-pill() = { let s = _box-color.get(); s.len() > 0 and s.last().kind == "pill" }
/// Emphasis color readable in the current context: inside a pill (white text on the color) the blue of
/// `#alert`/`#primary` would vanish, so it becomes UFAC yellow (like the underline, already yellow in pills);
/// elsewhere the requested color.
/// -> color
#let _emph-color(
  /// Requested color. -> color
  c,
) = if _in-pill() { colors.secondary } else { c }

// ---------- raw gate and code box ----------
/// True inside any `raw` (inline or block): the `==x==` shorthand is not applied there.
/// -> state
#let _in-raw = state("ufac-in-raw", false)
/// Marks the inside of every `raw` (inline and block) so the `==x==` rule stays literal there. In `init` it comes
/// after `codly-init` (innermost rule: it runs first, so the marks also wrap codly's output). codly's `local`
/// installs its own, even more inner `show raw.where(block: true)` that converts the `raw` before the `init` rule
/// sees it; that is why the theme re-exports a `local` that applies the gate inside the body (`no-codly` and
/// `codly-range` only touch state and need nothing).
/// -> content
#let _gate-raw(
  /// Content whose `raw` elements are marked. -> content
  body,
) = { show raw: it => { _in-raw.update(true); it; _in-raw.update(false) }; body }
/// Box of a code block, drawn by the theme OUTSIDE codly's lines: codly's `inset` is per line (cell, ×1.5), so
/// enlarging it opens space between the lines instead of padding between the border and the code (the language
/// label used to touch the border). The rule is inner to codly's (it wraps the `raw` in a block and codly transforms
/// the `raw` inside; codly itself is left without fill/stroke). An outer rule would not work: codly's output is no
/// longer `raw`. For the same reason as the gate it also goes inside `local`. With `#no-codly` (state
/// `codly-enabled` = false) the plain raw is kept.
/// -> content
#let _code-box(
  /// Content whose code blocks are boxed. -> content
  body,
  /// Fill of the box. -> color
  fill: luma(247),
  /// Border of the box. -> stroke
  stroke: .5pt + luma(210),
  /// Corner radius of the box. -> length
  radius: .35em,
  /// Padding between the border and the code. -> length | dictionary
  inset: (x: .3em, y: .3em),
) = {
  show raw.where(block: true): it => context {
    if state("codly-enabled", true).get() {
      block(width: 100%, fill: fill, stroke: stroke, radius: radius, inset: inset, breakable: false, it)
    } else { it }
  }
  body
}

// ---------- key-equation signal ----------
/// Set (to a color) by a lone `>` line: the next block equation gets an `eq-box` (see `show math.equation`
/// in `init`, which consumes the signal).
/// -> state
#let _key-eq = state("ufac-key-eq", none)
/// Invisible marker that `eq-box` leaves in front of its box. The `show math.equation` rule of the shorthand rebuilds
/// the equation with an `eq-box` inside, and the rebuilt equation goes through the same rule: the state cannot stop it
/// (within one layout pass a new location does not see the `update(none)` yet, so the rule recursed forever), a
/// structural check can.
/// -> content
#let _eq-mark = metadata("ufac-eq-box")
/// Where an `eq-box` sits, set by the `show math.equation` rule around every block equation that holds one: "whole"
/// (the box is the whole equation: display style, generous padding), "part" (a part of a block equation: display
/// style, tight padding) or `none` (running text or an inline equation: text style, tight padding that does not
/// add to the line height).
/// -> state
#let _eq-ctx = state("ufac-eq-ctx", none)
/// Children of a content with nested sequences and styles flattened, spaces dropped.
/// -> array
#let _flat(
  /// Any content. -> content
  c,
) = { let c = _unstyle(c); if c.func() == _seq { c.children.map(_flat).flatten() } else if _is-space(c) { () } else { (c,) } }
/// True when the body of an equation is nothing but one `eq-box` (its mark followed by its box).
///
/// #test(
///   `_is-whole-eq-box($#_eq-mark#box[x]$.body)`,
///   `not _is-whole-eq-box($y = #_eq-mark#box[x]$.body)`,
///   `not _is-whole-eq-box($x$.body)`,
/// )
/// -> bool
#let _is-whole-eq-box(
  /// Body of an equation. -> content
  c,
) = { let f = _flat(c); f.len() == 2 and f.first() == _eq-mark }
/// True when the content holds an @_eq-mark, i.e. an `eq-box`.
///
/// #test(`_has-eq-mark([a #_eq-mark b])`, `_has-eq-mark($x + #[#_eq-mark y]$.body)`, `not _has-eq-mark($x + y$.body)`)
/// -> bool
#let _has-eq-mark(
  /// Body of an equation. -> content
  c,
) = { let c = _unstyle(c); c == _eq-mark or (c.func() == _seq and c.children.any(_has-eq-mark)) }

// ---------- backslash escapes ----------
/// Without the backslash, Typst's lexer merges `> word` (and `-> word`) into a single text node; with `\>` the sign
/// arrives alone, followed by (a space and) a text node starting with a letter or digit. That is what tells an
/// escape apart. If what follows is not a word (`==`, `*x*`, `(a)`), both forms are identical and the escape is not
/// recognized. `\"` arrives as the text `"`, not as a `smartquote`, so quotes need no special handling.
///
/// #test(
///   `_alnum-start("word")`, `_alnum-start("1st")`, `_alnum-start("água")`,
///   `not _alnum-start("== T")`, `not _alnum-start("")`, `not _alnum-start(" x")`,
/// )
/// -> bool
#let _alnum-start(
  /// Text that follows the escaped sign. -> str
  s,
) = s.len() > 0 and s.clusters().first().match(regex("[\p{L}\p{N}]")) != none
#let _escaped-after(ch, i) = {
  if i < ch.len() and _is-space(ch.at(i)) { i += 1 }
  i < ch.len() and _is-text(ch.at(i)) and _alnum-start(ch.at(i).text)
}

// ---------- exercise / example labels ----------
/// Kind of a heading label: `<exercise>`/`<exercise-id>` → "exercise", `<example>`/`<example-id>` → "example",
/// otherwise `none`. The suffix (id) changes nothing on the slide; it only makes the label unique so the slide can
/// be cited with `@exercise-id` / `@example-id`.
///
/// #test(
///   `_label-kind(label("exercise")) == "exercise"`,
///   `_label-kind(label("exercise-ogata")) == "exercise"`,
///   `_label-kind(label("example-xor")) == "example"`,
///   `_label-kind(label("exercises")) == none`,
///   `_label-kind(label("eq-y")) == none`,
///   `_label-kind(none) == none`,
/// )
/// -> str | none
#let _label-kind(
  /// Label of a level-2 heading, or `none`. -> label | none
  lbl,
) = {
  if lbl == none { return none }
  let s = str(lbl)
  if s == "exercise" or s.starts-with("exercise-") { "exercise" } else if s == "example" or s.starts-with("example-") { "example" }
}
/// Localized names (linguify database `lang.toml`: pt, en, es; unknown languages fall back to Portuguese).
/// -> dictionary
#let _lang-db = toml("lang.toml")
/// `lang` parameter of the theme → `(lang:, region:)` for `set text`: "pt"/"pt-br" (region BR by default), "en", "es";
/// an explicit region may follow the code (`en-US`, `es-MX`); anything else is an error.
///
/// #test(
///   `_lang-parse("pt-br") == (lang: "pt", region: "BR")`,
///   `_lang-parse("pt") == (lang: "pt", region: "BR")`,
///   `_lang-parse("pt-PT") == (lang: "pt", region: "PT")`,
///   `_lang-parse("en") == (lang: "en", region: none)`,
///   `_lang-parse("en_us") == (lang: "en", region: "US")`,
///   `_lang-parse("ES-mx") == (lang: "es", region: "MX")`,
/// )
/// -> dictionary
#let _lang-parse(
  /// The `lang` parameter of the theme. -> str
  lang,
) = {
  assert(type(lang) == str, message: "lang must be a string (\"pt-br\", \"en\" or \"es\"), got " + repr(lang))
  let parts = lower(lang).replace("_", "-").split("-")
  let code = parts.first()
  assert(code in ("pt", "en", "es"), message: "unknown lang \"" + lang + "\": use \"pt-br\" (or \"pt\"), \"en\" or \"es\"")
  let region = if parts.len() > 1 { upper(parts.at(1)) } else if code == "pt" { "BR" } else { none }
  (lang: code, region: region)
}
/// Name shown for `key` ("exercise", "example", "part"): the theme parameter `<key>-name` when given, otherwise the
/// translation for the current `text.lang` (contextual content from linguify).
/// -> content
#let _name(
  /// Touying's `self`. -> dictionary
  self,
  /// `"exercise"`, `"example"` or `"part"`. -> str
  key,
) = { let v = self.store.at(key + "-name", default: auto); if v == auto { linguify(key, from: _lang-db) } else { v } }
/// `(name, color)` of a kind: the name comes from the theme store or the translation, the color from the palette.
/// -> array
#let _kind-style(
  /// Touying's `self`. -> dictionary
  self,
  /// `"exercise"` or `"example"`. -> str
  kind,
) = if kind == "exercise" { (_name(self, "exercise"), self.colors.tertiary) } else { (_name(self, "example"), self.colors.quaternary) }
/// Index of an "Exercise"/"Example": position among the level-2 headings of the same kind whose page is ≤ the given
/// page (page based, like `utils.current-heading`, because the header is laid out before the body). The headings
/// re-emitted by Touying on `---` continuations do not show up in `query`, only the original, which keeps the count simple.
/// -> int
#let _kind-index(
  /// `"exercise"` or `"example"`. -> str
  kind,
  /// Page of the slide. -> int
  page,
) = query(heading.where(level: 2)).filter(x => _label-kind(x.at("label", default: none)) == kind and x.location().page() <= page).len()

// ---------- current subtitle (level-3 heading, repeated after `---`) ----------
/// Last level-3 heading between the current `==` and `here()`, or `none`. Touying re-emits the `==` at every
/// continuation, so the group of consecutive identical level-2 headings is walked back to its first member.
/// -> content | none
#let _current-subtitle(
  /// Subtitle bodies declared by the slide that is asking, to be ignored. -> array
  skip: (),
) = {
  let h2s = query(heading.where(level: 2).before(here()))
  if h2s.len() == 0 { return none }
  let i = h2s.len() - 1
  while i > 0 and h2s.at(i - 1).body == h2s.at(i).body { i -= 1 }
  let start = h2s.at(i).location()
  // `skip`: subtitles declared by the slide that is asking. With `#pause`, the earlier subpages of the same slide
  // come before `here()` and would otherwise be taken for a subtitle carried over from a previous `---` page.
  let h3s = query(heading.where(level: 3).after(start).before(here())).filter(h => h.body not in skip)
  if h3s.len() > 0 { h3s.last() }
}

// ---------- cover (`#pause`, `#uncover`) ----------
/// Value of the `metadata` marker left after a covered chunk (see @_cover).
/// -> str
#let _veil-end = "ufac-veil-end"
/// Element functions that make a covered chunk block-level.
/// -> array
#let _block-funcs = (list.item, enum.item, terms.item, list, enum, terms, heading, table, grid, figure, block, stack, pad, align, columns, image, rect, quote)
/// True when the content holds a block-level element (or a paragraph break).
///
/// #test(`_is-blocky([- item])`, `_is-blocky([a #parbreak() b])`, `not _is-blocky([plain *text*])`)
/// -> bool
#let _is-blocky(
  /// Any content. -> content
  c,
) = {
  let c = _unstyle(c)
  if c.func() == _seq { c.children.any(_is-blocky) }
  else if c.func() == parbreak { true }
  else if c.func() in (raw, math.equation) { c.at("block", default: false) }
  else { c.func() in _block-funcs }
}
/// True when the children are those of a lone shorthand paragraph: `> box`, `"quote"` or `-> item`.
///
/// #test(`_is-shorthand-par(([> box],))`, `_is-shorthand-par(([-], [> item]))`, `not _is-shorthand-par(([text],))`)
/// -> bool
#let _is-shorthand-par(
  /// Trimmed children of the covered body. -> array
  ch,
) = {
  let first = ch.first()
  ((_is-text(first) and first.text.starts-with(">")) or (_is-dq(first) and _is-dq(ch.last()))
    or (_is-text(first) and first.text == "-" and ch.len() > 1 and _is-text(ch.at(1)) and ch.at(1).text.starts-with(">")))
}
/// Covered content stays faintly visible under a veil in the page colour at 85% opacity, as in 0.0.1. Touying's own
/// covers cannot do that for this theme (checked with 0.7.4 and 0.8.0, 2026-09-18): `alpha-changing-cover` (0.8) fades `fill`/`stroke` fields
/// by rebuilding the content tree before layout and `cover-with-rect` splits the content into leaves (a thick `strike`
/// over text runs), while the theme colours almost everything later, in show rules and element layout (bold, chips,
/// `===` pills, `> ` boxes, list markers, icons), so those stayed fully visible and a lone shorthand paragraph (`-> item`,
/// `> box`, `"quote"`) was left as literal text.
///
/// `_cover` leaves a block-level chunk in the normal flow, so the layout is identical covered or not, and paints the
/// veil over it afterwards with a `place`d rectangle whose height is the distance between two real positions (the
/// start of the chunk and the point after it): no `measure`, hence no second layout. The `parbreak()` after the chunk
/// forces block mode inside the `context`, which turns a lone shorthand paragraph into a real `par` (§11 of CLAUDE.md).
/// The rectangle's outset reaches what the theme paints outside the layout box (pill outset, quote bar, box stroke).
/// A chunk that breaks across pages cannot be veiled by one rectangle: it is hidden instead (same space, breakable),
/// decided from the end marker of the previous layout pass. Plain running text (no block element, no shorthand) goes to
/// Touying's `cover-with-rect`, which is line-break aware, so a `#pause` in the middle of a paragraph still works; an
/// `#icon` inside such text is the one thing left unveiled.
/// -> content
#let _cover(
  /// Touying's `self`; in Touying 0.8 the sentinel `utils.cover-kind-query` asks for the kind of cover. -> dictionary | none
  self: none,
  /// Arguments forwarded to Touying's `cover-with-rect` (the fallback). -> any
  ..args,
  /// The content to cover. -> content | none
  body,
) = {
  // Touying 0.8 asks the cover for its kind through a sentinel that 0.7.4 does not have: looked up, not referenced
  let kind-query = dictionary(utils).at("cover-kind-query", default: none)
  if kind-query != none and self == kind-query { return "paint" }
  if body == none { return [] }
  let fill = if type(self) == dictionary { self.at("page", default: (:)).at("fill", default: white) } else { white }
  let veil = (if type(fill) == color { fill } else { white }).transparentize(15%)
  let fallback = utils.cover-with-rect(self: self, ..args, fill: veil, body)
  if type(body) != content { return fallback }
  let ch = _trim(_children(_unstyle(body)))
  if ch.len() == 0 { return body }
  let lone-context = ch.len() == 1 and ch.first().func() == [#context none].func()
  if not (_is-blocky(body) or lone-context or _is-shorthand-par(ch)) { return fallback }
  context {
    let s = here().position()
    let ends = query(metadata.where(value: _veil-end).after(here()))
    if ends.len() > 0 and ends.first().location().page() != s.page { hide(body) } else {
      body
      parbreak()
      context { let h = here().position().y - s.y; if h > 0pt { place(start, dy: -h, rect(width: 100%, height: h, outset: (x: .5em, y: .45em), fill: veil)) } }
    }
    metadata(_veil-end)
  }
}

// ---------- footer (ported from 0.0.1) ----------
/// Separator of the default `footer-left` ("CODE · SUBJECT"): a drawn disc (radius 0.18em of the 0.4em footer text,
/// centered on the cap height, filled with the current `text.fill`, so it is white on the cover). The font's middle dot
/// was too small and its bullet (U+2022) is a square (2026-09-18).
/// -> content
#let _sep-dot = box(baseline: 0.18em - 0.36em, context circle(radius: 0.18em, fill: text.fill))
/// Rule line of the footer, in the primary color.
/// -> content
#let _line(
  /// Touying's `self`. -> dictionary
  self,
) = line(stroke: .1em + self.colors.primary, length: 100%)
/// Rule line of the cover, in white.
/// -> content
#let _line-white(
  /// Touying's `self`. -> dictionary
  self,
) = line(stroke: .1em + self.colors.neutral-lightest, length: 100%)

/// One footer/header cell: small upper-case text (0.4em) between rule lines.
/// -> content
#let _cell(
  /// Touying's `self`. -> dictionary
  self,
  /// Arguments of `set text` for the cell. -> any
  ..args,
  /// `"left"`, `"center"` or `"right"`. -> str
  pos: "center",
  /// Length of the rule before the cell. -> length
  pad-left: 0em,
  /// Length of the rule after the cell. -> length
  pad-right: 0em,
  /// White text and rules (the cover). -> bool
  white: false,
  /// Text of the cell. -> content | str
  it,
) = {
  let _content(it) = {
    set text(size: 0.4em, ..args)
    context {
      let get-content(it) = {
        if type(it) == str {
          return h(0.4em) + upper(it) + h(0.4em)
        } else if type(it) == content {
          if measure(it).width > 0pt {
            return h(0.4em) + box(upper(it)) + h(0.4em)
          }
        } else {
          return none
        }
      }
      block(above: 0pt, below: 0pt, outset: 0pt, breakable: false, inset: 1mm, height: 100%, get-content(it))
    }
  }

  set text(fill: if white { self.colors.neutral-lightest } else { self.colors.primary }) if white

  let l = if white { _line-white(self) } else { _line(self) }

  if pos == "center" {
    grid(columns: (pad-left, 1fr, auto, 1fr, pad-right), l, l, _content(it), l, l)
  } else if pos == "left" {
    grid(columns: (pad-left, auto, 1fr, pad-right), l, _content(it), l, l)
  } else if pos == "right" {
    grid(columns: (pad-left, 1fr, auto, pad-right), l, l, _content(it), l)
  }
}

/// Footer of every slide except the cover: rule 1em, UFAC logo (0.64em), rule 1.25em, "CODE - SUBJECT", rule 1fr,
/// author, rule 2em, slide number (0.6em), rule 1em. The last column is as wide as the last slide number.
/// -> content
#let _footer(
  /// Touying's `self`. -> dictionary
  self,
) = {
  set text(self.colors.primary)
  set std.align(bottom)
  context {
    let last-column-size = measure(box(text(utils.last-slide-number, size: 0.6em), inset: 0.4em)).width
    move(grid(
      columns: (1em, auto, auto, auto, last-column-size, 1em),
      rows: 1.5em,
      align: horizon,
      _line(self),
      box(image(bytes(ufac-logo), height: 0.64em), inset: 0.2em),
      _cell(self, pad-left: 1.25em, pos: "left", utils.call-or-display(self, self.store.footer-left)),
      _cell(self, pad-right: 2em, pos: "right", utils.call-or-display(self, self.store.footer-right)),
      _cell(self, pos: "center", size: 0.6em, utils.slide-counter.display()),
      _line(self),
    ), dy: -0.05em)
  }
}
