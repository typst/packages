// touying-ufac-unofficial — internal helpers: content inspection, the context color stack, the `raw` gate, backslash
// escapes, exercise/example labels, the localized words, the current-subtitle query and the footer pieces.
// Names starting with `_` are not part of the public API (Typst has no private bindings, so they stay reachable).
#import "@preview/touying:0.7.4": *
#import "constants.typ": colors, _ufac-logo-image

// ---------- content inspection ----------
#let _seq = [].func()
// (`none` is the body of an empty slide, a `== Title` with nothing under it: no children)
#let _children(it) = if it == none { () } else if it.func() == _seq { it.children } else { (it,) }
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
#let _first-child(body) = { let ch = utils.trim(_children(body)); if ch.len() > 0 { ch.first() } else { none } }
/// A `metadata` of a given kind (`value.kind`): a marker of the theme or a `#pause` of Touying.
///
/// #test(`_is-meta(metadata((kind: "k")), "k")`, `not _is-meta(metadata("k"), "k")`, `not _is-meta([x], "k")`)
/// -> bool
#let _is-meta(
  /// Any content. -> content
  c,
  /// The kind. -> str
  kind,
) = c.func() == metadata and type(c.value) == dictionary and c.value.at("kind", default: none) == kind
/// A value that was given: not `none`, `auto`, `[]` nor `""`.
///
/// #test(`_given([x])`, `not _given([])`, `not _given(none)`, `not _given(auto)`, `not _given("")`)
/// -> bool
#let _given(
  /// Any value. -> any
  x,
) = x not in (none, auto, [], "")
/// A value or an array of values, always as an array (`none` is the empty array).
///
/// #test(`_list(none) == ()`, `_list([a]) == ([a],)`, `_list(([a], [b])) == ([a], [b])`, `_list(auto) == (auto,)`)
/// -> array
#let _list(
  /// A value, an array or `none`. -> any
  x,
) = if x == none { () } else if type(x) == array { x } else { (x,) }
/// A value that shows nothing: not given (`_given`), or a text or content made only of spaces and line breaks.
///
/// #test(`_blank([ ])`, `_blank("  ")`, `_blank(none)`, `_blank([])`, `not _blank([x])`, `not _blank([ x ])`)
/// -> bool
#let _blank(
  /// Any value. -> any
  x,
) = if not _given(x) { true } else if type(x) == str { x.trim() == "" } else if type(x) != content { false } else {
  _children(x).all(c => _is-space(c) or c.func() in (linebreak, parbreak))
}
/// Content that is there and shows nothing: only updates of a state or a counter (`#provide-icons(..)`), metadata,
/// spaces and breaks.
///
/// #test(`_unseen([#state("s").update(1)])`, `_unseen([ #metadata(1) ])`, `not _unseen([])`, `not _unseen([x])`)
/// -> bool
#let _unseen(
  /// Any content. -> content
  x,
) = {
  let quiet = ([#state("_").update(none)].func(), [#counter("_").update(0)].func(), metadata)
  let ch = _children(_unstyle(x)).filter(c => not (_is-space(c) or c.func() in (linebreak, parbreak)))
  ch.len() > 0 and ch.all(c => c.func() in quiet)
}
/// A body made of a single paragraph inside a `block`/`grid` does not become a `par` element (Typst treats it as
/// inline content), so the `show par` rewrites (`->`, `> `, `"…"`) never run. A leading `parbreak()` forces the
/// paragraph without adding space.
/// -> content
#let _flow(
  /// Body of a box or column. -> content
  body,
) = { parbreak(); body }

// ---------- context color stack ----------
/// Stack of `(color:, kind:, fill:)` entries, `kind` ∈ "box" | "pill" | "title", and `fill` the background of a light
/// pill or a light cell (`none` elsewhere), for the contrast of a colored emphasis (`_emph-color`). Pushed by
/// `emph-box` (body: "box"; title badge: "pill"), the callouts, the boxes of the exercises and examples, `_pill-text`
/// (a dark pill: "pill"; a light one: "box" in blue, with its `fill`), the slide header ("title"), the section title
/// ("title"), the cells of a table (the header and a dark cell: "pill"; a light cell: "box" with its `fill`), the
/// footer ("title", or "pill" on the closing slide) and the content of the cover ("pill": white on blue). `*bold*`,
/// `==highlight==`, the `->` arrow, `#underline`, `#icon` and inline `raw` read the color at layout time (in
/// `context`): in the `> box` form the paragraph reaches `show par` already realized (strong/highlight become
/// `styled(...)` with black/yellow baked in), so set/show rules inside the box cannot reach them anymore; a `state`
/// resolves at the right place. Inline `raw` uses light tones in boxes and titles and dark tones with light text in pills.
/// -> state
#let _box-color = state("ufac-box-color", ())
/// Relative luminance of a color (WCAG 2), for the contrast of an alert or a colored emphasis with a dark pill (`_emph-color`).
///
/// #test(`calc.abs(_luminance(white) - 1) < 0.001`, `_luminance(black) == 0`)
/// -> float
#let _luminance(
  /// Any color. -> color
  c,
) = {
  let lin(x) = if x <= 0.04045 { x / 12.92 } else { calc.pow((x + 0.055) / 1.055, 2.4) }
  let (r, g, b, ..) = rgb(c).components().map(x => x / 100%)
  0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
}
/// Contrast ratio between two colors (WCAG 2), from 1 to 21.
///
/// #test(`calc.abs(_contrast(white, black) - 21) < 0.01`)
/// -> float
#let _contrast(
  /// A color. -> color
  a,
  /// Another color. -> color
  b,
) = {
  let (x, y) = (_luminance(a), _luminance(b))
  (calc.max(x, y) + 0.05) / (calc.min(x, y) + 0.05)
}
/// True for a light color, on which white text does not read: a luma of 70% or more (`secondary` and
/// `secondary-light`, the `-lighter` and `-lightest` tones, `quaternary-light`). The threshold of the light cells of a
/// table, the pills and the boxes.
///
/// #test(`_is-light(colors.secondary)`, `_is-light(colors.secondary-light)`, `not _is-light(colors.primary)`,
///   `not _is-light(colors.quaternary)`, `_is-light(colors.secondary-lighter)`)
/// -> bool
#let _is-light(
  /// Background color. -> color
  c,
) = luma(c).components().first() >= 70%
/// The ink of a pill, a badge or a tag on `color`: dark blue on a light color (`_is-light`), white on the others.
///
/// #test(`_pill-ink(colors.secondary) != white`, `_pill-ink(colors.primary) == white`, `_pill-ink(colors.quaternary) == white`)
/// -> color
#let _pill-ink(
  /// Fill of the pill. -> color
  color,
) = if _is-light(color) { colors.primary.darken(45%) } else { white }
/// The color of what takes the color of a box (bold, alerts, markers, the footer of an item) on a box of `color`: the
/// color itself, or, for a light one (`_is-light`, the yellow), the `-dark` tone of its family, readable on its fill.
///
/// #test(`_box-ink(colors.secondary) == colors.secondary-dark`, `_box-ink(colors.tertiary) == colors.tertiary`,
///   `_box-ink(colors.primary-lighter) == colors.primary-dark`, `_box-ink(rgb("#eeeeee")) == rgb("#eeeeee").darken(40%)`)
/// -> color
#let _box-ink(
  /// Color of the box. -> color
  color,
) = if not _is-light(color) { color } else {
  let tones = ("", "-light", "-lighter", "-lightest", "-dark", "-darker", "-darkest")
  let family = ("primary", "secondary", "tertiary", "quaternary", "neutral").find(f =>
    tones.any(t => colors.at(f + t, default: none) == color))
  if family == none { color.darken(40%) } else { colors.at(family + "-dark") }
}

#let _in-box(color, body, kind: "box", fill: none) = {
  _box-color.update(s => s + ((color: color, kind: kind, fill: fill),))
  body
  _box-color.update(s => s.slice(0, -1))
}
#let _current-box-color(fallback) = { let s = _box-color.get(); if s.len() == 0 { fallback } else { s.last().color } }
#let _in-pill() = { let s = _box-color.get(); s.len() > 0 and s.last().kind == "pill" }
/// Bold text of a pill on `color`, in its ink (`_pill-ink`): on a dark color, white, with `kind: "pill"` on the color
/// stack (yellow alerts, white bold); on a light one (the yellow), dark blue, and the inside follows a light box in blue.
/// -> content
#let _pill-text(
  /// Fill of the pill. -> color
  color,
  /// Text of the pill. -> content
  body,
) = {
  let ink = _pill-ink(color)
  text(fill: ink, weight: "bold", if ink == white { _in-box(color, body, kind: "pill") } else {
    _in-box(colors.primary, body, fill: color)
  })
}
/// Emphasis color readable in the current context: inside a pill (white text on the color) the blue of
/// `#alert`/`#primary` would vanish, so it becomes UFAC yellow, or, on a fill where the yellow does not read (a
/// contrast under 3:1, as on `quaternary`, `neutral` and `secondary-dark`), the dark blue of the light pills; elsewhere the
/// requested color. With `keep` (`#secondary`, `#tertiary`, `#quaternary`) the requested color stays inside a pill where
/// it reads (a contrast of 3:1 or more with it), and only where it does not becomes the yellow or the dark blue; inside
/// a light pill or a light cell (an entry of the stack with a `fill`), where it does not read, it becomes the color of
/// the box there, that of an alert.
///
/// #test(`_contrast(colors.secondary, colors.primary) >= 3`, `_contrast(colors.secondary, colors.quaternary) < 3`,
///   `_contrast(colors.primary.darken(45%), colors.quaternary) >= 3`, `_contrast(colors.primary.darken(45%), colors.neutral) >= 3`,
///   `_contrast(colors.primary.darken(45%), colors.secondary-dark) >= 3`, `_contrast(colors.quaternary, colors.primary) < 3`,
///   `_contrast(colors.quaternary, colors.primary-dark) >= 3`)
/// -> color
#let _emph-color(
  /// Requested color. -> color
  c,
  /// Keep `c` inside a pill where it reads. -> bool
  keep: false,
) = {
  let s = _box-color.get()
  if s.len() == 0 { return c }
  let top = s.last()
  if top.kind == "pill" {
    if keep and _contrast(c, top.color) >= 3 { c } else if _contrast(colors.secondary, top.color) >= 3 {
      colors.secondary
    } else { colors.primary.darken(45%) }
  } else if keep and top.at("fill", default: none) != none and _contrast(c, top.fill) < 3 { top.color } else { c }
}

// ---------- raw gate and code box ----------
/// True inside any `raw` (inline or block): the `==x==` shorthand is not applied there.
/// -> state
#let _in-raw = state("ufac-in-raw", false)
/// Marks the inside of every `raw` (inline and block) so the `==x==` rule stays literal there. In `init` it comes after
/// the code rules (innermost rule: it runs first, so the marks also wrap the code box and codly's output).
/// -> content
#let _gate-raw(
  /// Content whose `raw` elements are marked. -> content
  body,
) = { show raw: it => { _in-raw.update(true); it; _in-raw.update(false) }; body }
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
/// Which shorthand of the theme's `show par` the paragraph that opens these children is: `"eq"` (a lone `>` before a
/// block equation, `eq-box`), `"box"` (`> text`), `"quotes"` (`"…"` runs and nothing else) or `"arrows"` (`-> item`);
/// `none` if it is none, or if it is escaped (`\> word`, `-\> word`). The paragraph runs until the first paragraph
/// break, list item or block equation, so the children of a whole body (a callout's) can be given.
///
/// #test(
///   `_shorthand(_children([-> a])) == "arrows"`, `_shorthand(_children([> a])) == "box"`,
///   `_shorthand(_children(["a" "b"])) == "quotes"`, `_shorthand(_children([>])) == "eq"`,
///   `_shorthand(_children([\> a])) == none`, `_shorthand(_children(["a" b])) == none`,
///   `_shorthand(_children([a])) == none`, `_shorthand(()) == none`,
/// )
/// -> str | none
#let _shorthand(
  /// Children of a paragraph or of a body. -> array
  ch,
) = {
  let p = ()
  for c in ch {
    if c.func() in (parbreak, list.item, enum.item, terms.item) or (c.func() == math.equation and c.block) { break }
    p.push(c)
  }
  if p.len() == 0 { return none }
  let first = p.first()
  if p.all(c => _is-space(c) or (_is-text(c) and c.text.trim() == ">")) { return "eq" }
  if _is-text(first) and first.text.starts-with(">") and not (first.text == ">" and _escaped-after(p, 1)) { return "box" }
  if _is-dq(first) and _is-dq(p.last()) {
    // only quotes and the spaces between them
    let open = false; let outside = false
    for c in p { if _is-dq(c) { open = not open } else if not open and not _is-space(c) { outside = true } }
    if not open and not outside { return "quotes" }
  }
  if _is-text(first) and first.text == "-" and p.len() > 1 and _is-text(p.at(1)) and p.at(1).text.starts-with(">") and not (p.at(1).text == ">" and _escaped-after(p, 2)) { return "arrows" }
  none
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
/// Localized words of the theme (`lang.toml`: pt, en, es).
/// -> dictionary
#let _lang-db = toml("lang.toml").lang
/// The words of a language (`"pt"`, `"en"`, `"es"`); an unknown language falls back to Portuguese.
///
/// #test(`_words("en").thanks == "Thank you!"`, `_words("fr").and == "e"`, `_words("es").months.len() == 12`)
/// -> dictionary
#let _words(
  /// Language code, as in `text.lang`. -> str
  lang,
) = _lang-db.at(lang, default: _lang-db.pt)
/// A localized word for the current `text.lang` (contextual content), so that a `#set text(lang:)` in the middle of a
/// deck changes it too.
/// -> content
#let _tr(
  /// Key of `lang.toml`: `"exercise"`, `"thanks"`, … -> str
  key,
) = context _words(text.lang).at(key)
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
/// translation for the current `text.lang` (contextual content).
/// -> content
#let _name(
  /// Touying's `self`. -> dictionary
  self,
  /// `"exercise"`, `"example"` or `"part"`. -> str
  key,
) = { let v = self.store.at(key + "-name", default: auto); if v == auto { _tr(key) } else { v } }
/// `(name, color)` of a kind: the name comes from the theme store or the translation, the color from the palette.
/// -> array
#let _kind-style(
  /// Touying's `self`. -> dictionary
  self,
  /// `"exercise"` or `"example"`. -> str
  kind,
) = if kind == "exercise" { (_name(self, "exercise"), self.colors.tertiary) } else { (_name(self, "example"), self.colors.quaternary) }
/// Icon of a kind in its pill: the theme parameter `<kind>-icon` (`ufac-theme(exercise-icon:, example-icon:)`), a
/// pencil for exercises and a beaker for examples when the theme did not set it (a stand-in `self`).
/// -> none | str | content
#let _kind-icon(
  /// Touying's `self`. -> dictionary
  self,
  /// `"exercise"` or `"example"`. -> str
  kind,
) = self.store.at(kind + "-icon", default: if kind == "exercise" { "pencil" } else { "beaker" })
/// Index of an "Exercise"/"Example": position among the level-2 headings of the same kind whose page is ≤ the given
/// page (page based, like `utils.current-heading`, because the header is laid out before the body). The headings
/// re-emitted by Touying on `---` continuations do not show up in `query`, only the original, which keeps the count simple.
/// A `#touying-recall` shows the slide again, its heading and label included: a heading with a named label
/// (`<example-tides>`, the one a recall needs) and the same title as an earlier one counts once, and the slide shown
/// again takes the number of the first. Two slides with the same label by mistake but other titles count twice.
/// -> int
#let _kind-index(
  /// `"exercise"` or `"example"`. -> str
  kind,
  /// Page of the slide. -> int
  page,
  /// Label of the heading of the slide, for the number of a slide shown again. -> none | label
  label: none,
  /// Title of the heading of the slide, with the label. -> none | content
  body: none,
) = {
  let firsts = (); let seen = ()
  for x in query(heading.where(level: 2)) {
    let l = x.at("label", default: none)
    if _label-kind(l) != kind { continue }
    let key = str(l) + repr(x.body)
    if str(l) == kind { firsts.push(x) } else if key not in seen { seen.push(key); firsts.push(x) }
  }
  let page = if label != none and str(label) != kind {
    let first = firsts.find(x => x.label == label and repr(x.body) == repr(body))
    if first == none { page } else { first.location().page() }
  } else { page }
  firsts.filter(x => x.location().page() <= page).len()
}

// ---------- current subtitle (level-3 heading, repeated after `---`) ----------
/// Last level-3 heading between the current `==` and `here()`, or `none`. A `---` continuation has no `==` of its own,
/// so its current `==` is the one of the slide it continues; a new `==` with the same title is a new slide.
/// -> content | none
#let _current-subtitle(
  /// Subtitle bodies declared by the slide that is asking, to be ignored. -> array
  skip: (),
) = {
  let h2s = query(heading.where(level: 2).before(here()))
  if h2s.len() == 0 { return none }
  let start = h2s.last().location()
  // `skip`: subtitles declared by the slide that is asking. With `#pause`, the earlier subpages of the same slide
  // come before `here()` and would otherwise be taken for a subtitle carried over from a previous `---` page.
  let h3s = query(heading.where(level: 3).after(start).before(here())).filter(h => h.body not in skip)
  if h3s.len() > 0 { h3s.last() }
}

// ---------- footer (ported from 0.0.1) ----------
/// Separator of the default `footer-left` ("CODE · SUBJECT"): a drawn disc (radius 0.18em of the 0.4em footer text,
/// centered on the cap height, filled with the current `text.fill`, so it is white on the cover). The font's middle dot
/// was too small and its bullet (U+2022) is a square (2026-09-18).
/// -> content
#let _sep-dot = box(baseline: 0.18em - 0.36em, context circle(radius: 0.18em, fill: text.fill))
/// Items of a text of the footer joined by `_sep-dot`, the empty ones (`_blank`) left out: no dot next to an item that
/// is not there, and `none` when no item is left, so that the rule of the footer runs on without a gap.
///
/// #test(`_dot-join(()) == none`, `_dot-join(([], none, [ ], "")) == none`, `_dot-join(([a], none)) != none`)
/// -> content | none
#let _dot-join(
  /// The items: an array, or one item. -> any
  items,
) = {
  let xs = _list(items).filter(x => not _blank(x)).map(x => [#x])
  if xs.len() > 0 { xs.join([ #_sep-dot ]) }
}
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

/// The pieces of a text that a cut can keep or drop: its characters and spaces, the characters of bold, emphasis, a
/// link and the other styles of text each in its style, and any other element whole (the dot that separates the parts
/// of the footer).
///
/// #test(
///   `_atoms("ab c") == ("a", "b", " ", "c")`,
///   `_atoms([*ab*]) == (strong[a], strong[b])`,
///   `_atoms([a #box[x] b]).len() == 5`,
/// )
/// -> array
#let _atoms(
  /// The text. -> content | str
  it,
) = {
  if type(it) == str { return it.clusters() }
  if it.func() == text { return it.text.clusters() }
  if it.func() == [ ].func() { return (" ",) }
  if it.has("children") { return it.children.map(_atoms).flatten() }
  let restyle(make) = _atoms(it.body).map(a => if a == " " { a } else { make(a) })
  if it.func() in (strong, emph, underline, overline, strike, highlight, smallcaps) {
    let f = it.fields()
    let _ = f.remove("body")
    return restyle(a => (it.func())(..f, a))
  }
  if it.func() == link { return restyle(a => link(it.dest, a)) }
  // a styled piece (`#text(fill: ..)[..]`) is cut as its text, without the style
  if it.has("child") { return _atoms(it.child) }
  (it,)
}

/// True when the content holds code (`raw`), also inside bold, a link or another element with a body.
/// -> bool
#let _has-raw(
  /// The content. -> any
  t,
) = type(t) == content and (t.func() == raw or (t.has("children") and t.children.any(_has-raw))
  or (t.has("body") and _has-raw(t.body)) or (t.has("child") and _has-raw(t.child)))
/// Text in capitals, as the texts of the footer, but for its code (`raw`), which keeps the letters as written, also
/// inside bold, italic, a link, a `#text(..)[..]` and the other elements with a body. A text without code is `upper` as
/// it is.
///
/// #test(
///   `_has-raw(strong[a #raw("b_C")])`,
///   `_has-raw(link("https://example.com")[#raw("b_C")])`,
///   `not _has-raw([a b])`,
///   `_upper-but-raw([a b]) == upper([a b])`,
///   `_upper-but-raw(raw("b_C")) == raw("b_C")`,
///   `_upper-but-raw(link("https://example.com", raw("b_C"))) == link("https://example.com", raw("b_C"))`,
///   `_upper-but-raw(text(fill: red)[#raw("r_V")]) == text(fill: red)[#raw("r_V")]`,
/// )
/// -> content | str
#let _upper-but-raw(
  /// The text. -> content | str
  t,
) = if not _has-raw(t) { upper(t) } else if t.func() == raw { t } else if t.has("children") {
  t.children.map(_upper-but-raw).join(default: [])
} else if utils.is-styled(t) { utils.reconstruct-styled(t, _upper-but-raw(t.child)) } else if t.func() == link {
  link(t.dest, _upper-but-raw(t.body))
} else if t.has("body") {
  let f = t.fields()
  let body = f.remove("body")
  (t.func())(..f, _upper-but-raw(body))
} else { upper(t) }

/// The text of a footer cell on one line: `h(0.4em) + upper(it) + h(0.4em)`, and when that passes `max`, the longest
/// start of the text that fits with "…" after it, cut between its characters (@_atoms). In `context`, with the size of
/// the cell set.
/// -> content
#let _one-line(
  /// Text of the cell. -> content | str
  it,
  /// The widest the text can be, or `none` for any width. -> none | length
  max,
) = {
  let shown(t) = h(0.4em) + box(_upper-but-raw(t)) + h(0.4em)
  if max == none or measure(shown(it)).width <= max { return shown(it) }
  let cs = _atoms(it)
  // what is left before the "…": no space, punctuation or separator (a typed "•" or the dot of the theme) at the end
  let loose(a) = a in (" ", ",", ";", ":", "•", "·", "—", "–", "-") or (type(a) == content and a.func() == box)
  let cut(n) = {
    let kept = cs.slice(0, n)
    while kept.len() > 0 and loose(kept.last()) { kept = kept.slice(0, -1) }
    kept.join(default: "") + "…"
  }
  // a binary search on the number of characters kept
  let (lo, hi) = (0, cs.len())
  while lo < hi {
    let mid = calc.ceil((lo + hi) / 2)
    if measure(shown(cut(mid))).width <= max { lo = mid } else { hi = mid - 1 }
  }
  // a cut inside a word goes back to the end of the word before, when there is one
  if lo < cs.len() and cs.at(lo) != " " {
    let spaces = range(1, lo).filter(i => cs.at(i) == " ")
    if spaces.len() > 0 { lo = spaces.last() }
  }
  shown(cut(lo))
}

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
  /// A `1fr` rule on the free side of a `"left"`/`"right"` cell, so that the cell fills its column. `false` gives the
  /// text and its fixed rule only, at its natural width, for a grid that puts the `1fr` rule between the cells. -> bool
  grow: true,
  /// The widest the text of the cell can be, its inset included: a longer text is cut with "…" (`_one-line`). -> none | length
  max: none,
  /// Text of the cell. -> content | str
  it,
) = {
  let _content(it) = {
    set text(size: 0.4em, ..args)
    context {
      let get-content(it) = {
        // the inset of the block below, 1mm on each side, is part of `max`
        let room = if max == none { none } else { max - 2mm }
        if type(it) == str {
          if it.trim() != "" { return _one-line(it, room) }
        } else if type(it) == content {
          if measure(it).width > 0pt { return _one-line(it, room) }
        } else {
          return none
        }
      }
      // An empty cell has no block: its 1mm inset left a gap in the rule (2026-10-16).
      let c = get-content(it)
      if c != none { block(above: 0pt, below: 0pt, outset: 0pt, breakable: false, inset: 1mm, height: 100%, c) }
    }
  }

  set text(fill: if white { self.colors.neutral-lightest } else { self.colors.primary }) if white

  let l = if white { _line-white(self) } else { _line(self) }

  if pos == "center" {
    grid(columns: (pad-left, 1fr, auto, 1fr, pad-right), l, l, _content(it), l, l)
  } else if pos == "left" and not grow {
    grid(columns: (pad-left, auto), l, _content(it))
  } else if pos == "left" {
    grid(columns: (pad-left, auto, 1fr, pad-right), l, _content(it), l, l)
  } else if pos == "right" and not grow {
    grid(columns: (auto, pad-right), _content(it), l)
  } else if pos == "right" {
    grid(columns: (pad-left, 1fr, auto, pad-right), l, l, _content(it), l)
  }
}

/// The logos of the footer and of the cover (`config-info(logo:)`), in a row separated by a dot. `auto` is the UFAC
/// logo, blue on the slides and white with its yellow shield on the cover; a function receives the color of the
/// footer (the primary color, or white on the cover); content goes as it is. A single logo is the same box as the
/// UFAC logo alone had before the option (0.1.0), so the default footer did not change (2026-10-16). The dot has the
/// size of `_sep-dot` in the 0.4em text (radius 0.18 × 0.4em) and sits in its own cell, centered on the logos.
/// `logo: none` gives no logos.
/// -> content | none
#let _logos(
  /// Touying's `self`. -> dictionary
  self,
  /// White logos and dot, for the cover. -> bool
  white: false,
  /// The logos; `auto` takes those of `config-info(logo:)` (the UFAC logo by default). -> auto | array
  logos: auto,
  /// Color of the logos and the dot, for the footer of an exercise or example: the UFAC logo all in this color, its
  /// shield too. `auto` is the primary color, or white with `white: true`. -> auto | color
  color: auto,
) = {
  let logos = if logos == auto { _list(self.info.at("logo", default: auto)) } else { logos }
  if logos.len() == 0 { return none }
  let mono = color != auto
  let color = if color != auto { color } else if white { self.colors.neutral-lightest } else { self.colors.primary }
  // the UFAC logo keeps its blue on the slides and takes the white of the cover, the shield yellow on both; in one
  // color (`color:`), letters and shield
  let one(logo) = if logo == auto {
    if mono { _ufac-logo-image(color: color, shield: color) } else {
      _ufac-logo-image(color: if white { color } else { auto })
    }
  } else if type(logo) == function { logo(color) } else { logo }
  if logos.len() == 1 { return box(one(logos.first()), inset: 0.2em) }
  let dot = circle(radius: 0.072em, fill: color)
  box(inset: 0.2em, grid(columns: 2 * logos.len() - 1, column-gutter: 0.3em, align: horizon,
    ..logos.map(one).intersperse(dot)))
}

/// Footer of every slide except the cover: rule 1em, the logos (the UFAC logo, 0.64em, by default), rule 1.25em,
/// "CODE • TITLE", rule 1fr, author, rule 2em, slide number (0.6em), rule 1em. The last column is as wide as the
/// last slide number. The two texts take their natural width and the `1fr` rule between them the rest: when each
/// text carried its own `1fr` rule, both cells claimed the whole width and got half of it each, so a long left text
/// broke into two lines with room to spare on the right (2026-10-16). Each text stays on one line: when the two do not
/// fit in the room left by the rules, the logos and the number, the right one gets what the left one leaves (at least a
/// third of the room) and the left one the rest, and a longer text is cut with "…". `white: true` draws it in white, with the white
/// logos of the cover, for the closing slide (`#ending-slide`); `color:` draws it in another color, with the UFAC logo
/// in that color too, for the box of an exercise or example.
/// -> content
#let _footer(
  /// Touying's `self`. -> dictionary
  self,
  /// White text, rules and logos. -> bool
  white: false,
  /// Color of the text, the rules and the logos, instead of the primary color. -> auto | color
  color: auto,
  /// Color of the rules alone, instead of `color`: in the box of an exercise in a light color they are its bottom
  /// border, in the color of the box, and the text and the logo in its dark tone. -> auto | color
  rule-color: auto,
  /// Lift the footer by 0.05em, as on the page. The box of an exercise has its border at the exact middle of the
  /// footer, so its footer is not lifted. -> bool
  lift: true,
) = {
  let mono = color
  let self = self
  if color != auto { self.colors.primary = color }
  let ink = self.colors.primary
  // a function of `footer-left`/`footer-right` gets the color of the text as the primary color, white on the closing
  // slide, as the function of the logo on the cover
  let text-self = self
  if white { text-self.colors.primary = self.colors.neutral-lightest }
  // the rules are drawn from `self.colors.primary`, here and in `_cell`
  if rule-color != auto { self.colors.primary = rule-color }
  set text(if white { self.colors.neutral-lightest } else { ink })
  set std.align(bottom)
  let rule = if white { _line-white(self) } else { _line(self) }
  let footer = context layout(size => {
    let last-column-size = measure(box(text(utils.last-slide-number, size: 0.6em), inset: 0.4em)).width
    let logos = _logos(self, white: white, color: mono)
    // a text of the footer, or what its function returns, may be an array: the items that show something (an empty
    // `#info` has no width) joined by the dot (`_dot-join`)
    let shown(it) = {
      let v = if type(it) == function { it(text-self) } else { it }
      if type(v) == array { _dot-join(v.filter(x => measure([#x]).width > 0pt)) } else { [#v] }
    }
    let (left, right) = (shown(self.store.footer-left), shown(self.store.footer-right))
    // the room of the two texts: the width less the rules (1em, 1.25em, at least 2em between the texts, 2em, 1em),
    // the logos and the number. When both texts do not fit, the right one gets what the left one leaves, at least a
    // third of the room, and the left one the rest
    let room = size.width - measure(logos).width - last-column-size - (7.25em).to-absolute()
    let natural(cell, pad) = measure(cell).width - pad.to-absolute()
    let left-width = natural(_cell(self, pad-left: 1.25em, pos: "left", grow: false, white: white, left), 1.25em)
    let right-max = calc.max(room - left-width, room / 3)
    let right-cell = _cell(self, pad-right: 2em, pos: "right", grow: false, white: white, max: right-max, right)
    let left-max = room - natural(right-cell, 2em)
    move(grid(
      columns: (1em, auto, auto, 1fr, auto, last-column-size, 1em),
      rows: 1.5em,
      align: horizon,
      rule,
      logos,
      _cell(self, pad-left: 1.25em, pos: "left", grow: false, white: white, max: left-max, left),
      rule,
      right-cell,
      _cell(self, pos: "center", size: 0.6em, white: white, context utils.slide-counter.display()),
      rule,
    ), dy: if lift { -0.05em } else { 0pt })
  })
  // the footer is a context of its own, so that its bold and italic take its color: on the blue page a pill, as the
  // rest of the page (an alert in it is yellow), elsewhere a title in the color of its text
  _in-box(ink, footer, kind: if white { "pill" } else { "title" })
}
