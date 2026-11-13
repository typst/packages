// touying-ufac-unofficial — components: color emphases, list markers and pills, `#icon`, the boxes (`emph-box`,
// `quote-box`, `eq-box`), `#callout`, `#tag`, `#cols`, the Markdown-like paragraph rewriting (`> box`, `"quote"`, `-> item`, `#arrows`)
// and the deck's `outline`.
#import "@preview/touying:0.7.4": *
#import "constants.typ": colors
#import "utils.typ": *
#import "icons.typ": _icon-source, _icon-svg

// ---------- emphasis ----------

/// Bold text in `c`, with the bold and the italic inside it in `c` too: they become text in that color before the
/// rules of the theme for bold and italic see them. The body of @alert and of the colored emphases.
/// -> content
#let _colored(
  /// Color of the text. -> color
  c,
  /// Text to emphasize. -> content
  body,
) = {
  show strong: it => text(fill: c, it.body)
  show emph: it => text(fill: c, style: "italic", it.body)
  text(fill: c, weight: "bold", body)
}

/// Bold text in UFAC blue, also inside a box (unlike `#alert` and `~~text~~`, which take the color of the box around
/// them). On a dark background (a dark pill, the cover, the header of a table) it turns UFAC yellow, where blue would
/// vanish, or dark blue where the yellow would (a contrast under 3:1, as on `quaternary`, `neutral` and
/// `secondary-dark`). The bold and the italic inside it take its color, as in the other colored emphases.
///
/// ```example
/// A #primary[definition] in blue.
/// ```
/// -> content
#let primary(
  /// Text to emphasize. -> content
  body,
) = context _colored(_emph-color(colors.primary), body)

/// Bold text in the color of the box around it (UFAC blue elsewhere) and UFAC yellow on a dark background (dark blue
/// where the yellow does not read, a contrast under 3:1, as on `quaternary`, `neutral` and `secondary-dark`): the same
/// as the `~~text~~` shorthand, which takes plain text only; this one takes any markup, and its bold and italic take
/// its color. It replaces Touying's `#alert`, so the theme is imported after Touying.
///
/// ```example
/// An #alert[important] word.
/// ```
/// -> content
#let alert(
  /// Text to emphasize. -> content
  body,
) = context {
  _colored(_emph-color(_current-box-color(colors.primary)), body)
}

/// Bold text in UFAC yellow, with the bold and the italic inside it in yellow too. It is weak on white: meant for
/// short labels and dark backgrounds. On a dark background where the yellow does not read (a contrast under 3:1, as
/// on `quaternary`) it turns dark blue. On a light pill, badge or tag, such as the yellow tag, it keeps its color where
/// it reads and otherwise takes the blue of an alert (in a light cell, the dark tone of the cell).
///
/// ```example
/// A #secondary[side note] in yellow.
/// ```
/// -> content
#let secondary(
  /// Text to emphasize. -> content
  body,
) = context _colored(_emph-color(colors.secondary, keep: true), body)

/// Bold text in red, with the bold and the italic inside it in red too, for warnings and problems. On a dark
/// background where the red does not read (a contrast under 3:1, as in a red badge or on the blue of the cover) it
/// turns yellow, or dark blue where the yellow does not read either. On a light pill, badge or tag it keeps its color
/// where it reads and otherwise takes the blue of an alert (in a light cell, the dark tone of the cell).
///
/// ```example
/// #tertiary[Caution:] the ice is thin.
/// ```
/// -> content
#let tertiary(
  /// Text to emphasize. -> content
  body,
) = context _colored(_emph-color(colors.tertiary, keep: true), body)

/// Bold text in green, with the bold and the italic inside it in green too, for advantages and correct answers. On a
/// dark background where the green does not read (a contrast under 3:1, as on the blue of the cover) it turns yellow,
/// or dark blue where the yellow does not read either (in a green badge). On a light pill, badge or tag, such as the
/// yellow tag, it keeps its color where it reads and otherwise takes the blue of an alert (in a light cell, the dark
/// tone of the cell).
///
/// ```example
/// #quaternary[Correct:] the series
/// converges.
/// ```
/// -> content
#let quaternary(
  /// Text to emphasize. -> content
  body,
) = context _colored(_emph-color(colors.quaternary, keep: true), body)

// ---------- list markers and pills ----------
/// Markers of `-` lists by level: filled square, rotated hollow square, smaller hollow circle.
/// -> array
#let _markers(
  /// Color of the three markers. -> color
  color,
) = (
  move(square(fill: color, size: 0.4em, radius: 0.1em), dy: 0.2em),
  move(rotate(square(stroke: color + 2pt, size: 0.3em, radius: 0.1em), -20deg), dy: 0.4em),
  move(circle(stroke: color + 1.2pt, radius: 0.13em), dy: 0.4em),
)
/// Rounded label with white bold text on `color` (subtitles `===`/`====`, exercise/example header). Pushes
/// `kind: "pill"` on the color stack so `*bold*`, `#alert`, `raw` and `#icon` inside it pick readable colors; on a light
/// color (yellow) the text is dark and the inside follows the convention of a light box (`_pill-text`).
/// -> content
#let _pill(
  /// Text of the label. -> content
  body,
  /// Fill of the label. -> color
  color: colors.primary,
) = box(fill: color, radius: 5pt, inset: (x: .7em), outset: (y: .4em),
  _pill-text(color, body))

/// Pill of a subtitle (`===`, `====`): in the color of the box around it, the color of the item inside an exercise
/// (red) or an example (green), and blue elsewhere.
/// -> content
#let _subtitle-pill(
  /// Text of the subtitle. -> content
  body,
) = context _pill(color: _current-box-color(colors.primary), body)

// ---------- icons ----------
/// An icon, already wrapped in a `box` for inline use: a role of the theme (`"caution"` or `"warning"`, `"tip"`, `"info"`, `"note"`,
/// `"exercise"`, `"example"`, `"file"`, `"terminal"`, `"contact"`, `"output"`, `"code"`, `"python"`, …), one of the
/// Octicons the theme ships by its own name (`"alert"`, `"light-bulb"`, `"pencil"`, `"beaker"`, …) or any icon of a
/// collection given with `provide-icons`, as `"collection:name"` (`"octicon:rocket-16"`, `"mdi:home"`). An unknown name
/// is a compile error that says how to get the icon.
///
/// ```example
/// #icon("tip", color: colors.quaternary)
/// A tip,
/// #icon("warning") attention and a big
/// #icon("python", size: 1.6em)
/// ```
/// -> content
#let icon(
  /// Name of the icon. -> str
  name,
  /// Fill color (multicolor logos keep their colors). With `auto` it follows the context like bold text: white inside
  /// a dark pill (a `===` subtitle, the badge of an exercise, the title of an @emph-box), the box or title color inside
  /// @emph-box and `==`, blue inside a light pill, black elsewhere. -> auto | color
  color: auto,
  /// Height of the icon; the width follows its proportions (square for the icons of the theme). -> length
  size: 1em,
  /// Baseline of the box; the default aligns the icon with the text. -> relative
  baseline: 25%,
) = {
  // the name is checked at the call: an unknown one fails here, not deep in the layout
  let source = _icon-source(name)
  context {
    let c = if color != auto { color } else if _in-pill() { white } else { _current-box-color(colors.neutral-darkest) }
    box(baseline: baseline, image(bytes(_icon-svg(source, c)), width: auto, height: size, alt: name, format: "svg"))
  }
}
/// Icon at the start of a pill (the header of an exercise or example, the badge of an @emph-box), followed by a small
/// space and centered on the height of the capitals of the text, whatever its height: the name of an @icon (white in
/// the pill) or any content, such as an image. `none` gives nothing.
/// -> content
#let _pill-icon(
  /// Name of an icon, content or `none`. -> none | str | content
  ic,
  /// Space after the icon, before the text. -> length
  gap: .35em,
) = if ic != none {
  let c = if type(ic) == str { icon(ic, baseline: 0pt) } else { ic }
  context {
    let cap = measure(text(top-edge: "cap-height", bottom-edge: "baseline")[X]).height
    let h = measure(c).height
    let below = (h - cap) / 2
    // the part of the icon below the baseline overflows its box, up to the depth that the end strut of `_pill-line`
    // gives the last line: a title that wraps keeps its first line as deep as the others; a taller icon (content)
    // keeps the excess
    let keep = calc.max(0pt, below - (1em.to-absolute() - cap) / 2)
    box(height: h - below + keep, baseline: keep, c)
  }
  h(gap)
}
/// Line of a pill that may have an icon (the header of an exercise or example, the badge of an @emph-box). It starts
/// with an invisible strut as tall as a pill icon (1em) and placed like one, centered on the capitals, so that the
/// pills with and without an icon have the same height: without it the line is as tall as the capitals, shorter than
/// the icon centered on them. A long title still wraps and the pill grows with it (a fixed height would cut the second
/// line); a taller icon (content) makes the line taller. The strut is in two parts, the one above the baseline at the
/// start and the one below it at the end: on one line they make the same height, and a title that wraps keeps the same
/// space between its lines (a whole strut at the start made the first line deeper than the others).
/// -> content
#let _pill-line(
  /// Content of the pill, with or without a `_pill-icon`. -> content
  body,
) = context {
  let cap = measure(text(top-edge: "cap-height", bottom-edge: "baseline")[X]).height
  let below = (1em.to-absolute() - cap) / 2
  box(width: 0pt, height: 1em.to-absolute() - below)
  body
  box(width: 0pt, height: below, baseline: below)
}

// ---------- boxes ----------
/// Box without title: thin border (the old `note-box`).
/// -> content
#let _note-box(
  /// Border color. -> color
  color,
  /// Content. -> content
  body,
) = block(stroke: 0.05em + color, inset: (x: 1em, y: .7em), radius: 5pt, width: 100%, _flow(body))
/// Box with the title as a badge overlapping the top border (the `boxed-style` of showybox in 0.0.1): the badge is
/// centered on the border line and left-aligned with the body text; the box starts at the top of the badge.
/// Compact insets: badge `x: .8em, y: .3em`, body `x: .9em, top: .45em` (+ half a badge), `bottom: .55em`.
/// -> content
#let _fancy-box(
  /// Border and badge color. -> color
  color,
  /// Text of the badge. -> content
  title,
  /// Content. -> content
  body,
) = {
  // the badge is a pill: `*x*` white, `~~x~~`/`#primary` yellow and `raw` inverted, as in `_pill` (kind "pill")
  let badge = box(fill: color, radius: 5pt, inset: (x: .8em, y: .3em), _pill-text(color, _pill-line(title)))
  // the badge is measured in the width it has inside the box (the container minus the side insets), so that a title
  // that wraps pushes the body down instead of covering it
  layout(size => {
    let h = measure(badge, width: size.width - 1.8em).height
    pad(top: h / 2, block(stroke: 0.05em + color, radius: 5pt, width: 100%, inset: (x: .9em, top: h / 2 + .45em, bottom: .55em), {
      // the badge at the height it was measured with: on a page the slide overflowed to, its content came out with
      // almost no height, and the white title and icon ran below the fill, white on white
      place(top + left, dx: 0.05em, dy: -(h + .45em), box(height: h, badge))
      // a `===` pill that opens the body sticks out of its line (its outset): room for it under the badge
      let first = _first-child(body)
      if type(first) == content and first.func() == heading { v(.4em) }
      _flow(body)
    }))
  })
}
/// The equation when `body` (ignoring spaces) is a single equation, else `none`.
///
/// #test(
///   `_only-eq([$x$]) == $x$`,
///   `_only-eq([ $ x $ ]).block`,
///   `_only-eq([a $x$]) == none`,
/// )
/// -> content | none
#let _only-eq(
  /// Body of an @eq-box. -> content
  body,
) = {
  let ch = _children(body).map(_unstyle).filter(c => not _is-space(c))
  if ch.len() == 1 and ch.first().func() == math.equation { ch.first() } else { none }
}
/// Emphasis box. Without a title it has a thin border; with a title, a badge sits over the top border. Inside the
/// box the `-` markers, the `->` arrow, `*bold*`, `~~text~~` and `#alert`, `==highlight==` and `#underline` take the
/// box color (the dark tone of a light color, such as `secondary-dark` in a `secondary` box); an explicit `#arrows(color:)`, `#arrow-list(color:)`, `#highlight(fill:)` or `#underline(stroke:)` wins. Colors by convention: primary for
/// definitions and what is recalled, quaternary for advantages, tertiary for problems, secondary for side notes.
///
/// ```example
/// #emph-box(color: colors.quaternary,
///   title: [Pros])[
///   - Fast and *simple*
///   - Works with ==highlights==
/// ]
/// #emph-box(color: colors.tertiary,
///   icon: "exercise", title: [Homework])[
///   An icon before the title.
/// ]
/// ```
///
/// Shorthand, always in the primary color: a paragraph whose lines start with `>`; a first line `> == Title` gives the
/// title. Only inline content fits the shorthand. For a framed equation see @eq-box.
/// -> content
#let emph-box(
  /// Color of the border and badge, and of the bold text, markers, arrows and highlights inside. -> color
  color: colors.primary,
  /// Badge over the top border; `none` gives the thin-border box (unless there is an `icon`). -> none | content
  title: none,
  /// Icon at the start of the badge, before the title: the name of an @icon, any content (an image, a symbol) or
  /// `none`. It is centered on the capitals of the title, as in the badges of exercises and examples; without a title it
  /// is the whole badge. The badge has the same height with or without an icon. -> none | str | content
  icon: none,
  /// Content of the box. -> content
  body,
) = {
  set list(marker: _markers(_box-ink(color)))
  set text(fill: colors.neutral-darkest)
  let title = if title == [] { none } else { title }   // an empty title is no title (no empty badge)
  let badge = if icon == none { title } else if title == none { _pill-icon(icon, gap: 0pt) } else {
    [#_pill-icon(icon)#title]
  }
  _in-box(_box-ink(color), if badge == none { _note-box(color, body) } else { _fancy-box(color, badge, body) })
}
/// Equation box: a light frame around a key equation. It goes *inside*
/// the equation, like the `boxeq` of the bookly package, so the equation keeps its centering, spacing and numbering,
/// and a part of an equation can be framed too. The body is written as math, between dollar signs; it is set in
/// display style whatever the spacing around it. A box around the whole equation is padded generously, a box around
/// a part of one tightly, and in both cases the frame holds tall fractions and the limits of sums.
///
/// It also works in a line of text or in an inline equation: there the body is in text style and the box does not
/// change the line spacing.
///
/// ```example
/// The area #eq-box[$A = pi r^2$] and the
/// mean #eq-box[$1/N sum_i x_i$].
/// ```
///
/// ```example
/// $ #eq-box[$E = m c^2$] $
///
/// $ F = #eq-box(
///   color: colors.quaternary,
/// )[$m a$] + f $
/// ```
///
/// Shorthand, always in the primary color: `>` in front of a block equation, on the same line or alone on the line
/// before it.
///
/// ```example
/// > $ sigma^2 = 1/n sum_i (x_i - mu)^2 $
/// ```
/// -> content
#let eq-box(
  /// Base color of the fill and border; `auto` is blue, or the box color inside an @emph-box. -> auto | color
  color: auto,
  /// The equation, as math: `[$x = 2$]` or `($x = 2$)`. -> content
  body,
) = {
  // A content block inside an equation is markup, not math: `#eq-box[x = 2]` would be the upright text "x=2", and
  // `_` or `*` in it would not even parse. Refuse it with a hint rather than render it wrong.
  let ch = _children(body)
  assert(not ch.all(c => _is-text(c) or _is-space(c)), message: "eq-box: write the body as math, between dollar signs: #eq-box[$"
    + ch.map(c => if _is-text(c) { c.text } else { " " }).join() + "$]")
  let eq = _only-eq(body)
  _eq-mark   // tells the shorthand rule that this equation is already boxed (see `_eq-mark`)
  context {
    let where = _eq-ctx.get()   // "whole" | "part" of a block equation, or `none`: running text or inline math
    let c = if color == auto { _current-box-color(colors.primary) } else { color }
    // The content of a `box` inside an equation is not laid out as math, so it becomes an equation of its own: in
    // display style inside a block equation (a nested `$x$` alone would be in text style: small fractions, limits
    // beside the sum), in text style in a line of text, where display style would blow up the line.
    // The frame of an inline equation is trimmed to the text edges (15.97pt against 25.53pt for the same equation as
    // a block, measured 2026-09-18): tall fractions and the limits of a sum stuck out of the box. With the edges at
    // the glyph bounds the frame holds the whole equation; in a line of text a zero-width strut keeps a lone `x` from
    // getting a lower box than its neighbours.
    let inner = if eq == none { body } else {
      set text(top-edge: "bounds", bottom-edge: "bounds")
      if where == none { box(width: 0pt, height: 0.95em, baseline: 0.22em) }
      math.equation(block: false, if where == none { eq.body } else { math.display(eq.body) })
    }
    // No `baseline`: the box keeps the baseline of its content (measured against inset + baseline and against
    // outset, 2026-09-18), so a partly framed equation and a box in a line of text stay aligned. In a line of text
    // the vertical padding is an `outset`, which does not add to the line height.
    let padding = if where == "whole" { (inset: (x: 0.9em, y: 0.45em)) }
      else if where == "part" { (inset: (x: 0.35em, y: 0.3em)) }
      else { (inset: (x: 0.3em), outset: (y: 0.2em)) }
    box(fill: c.lighten(92%), stroke: 0.8pt + c.lighten(35%), radius: if where == none { 0.3em } else { 0.4em }, ..padding, inner)
  }
}

/// Quotation box: a vertical bar on the left. Typst's `#quote(attribution: [Author])[…]` is shown as a `quote-box`
/// too, with the attribution on the right.
///
/// ```example
/// #quote-box(color: colors.primary)[
///   All models are wrong, but some
///   are useful.
/// ]
/// ```
///
/// Shorthand: a paragraph made only of `"quoted"` runs, one per line; each run becomes a box and the colors cycle
/// secondary, primary, quaternary, tertiary. Quotes inside a sentence are left alone.
/// -> content
#let quote-box(
  /// Color of the bar. -> color
  color: colors.secondary,
  /// The quotation. -> content
  body,
) = block(stroke: (left: .25em + color), inset: (left: 1em, y: .6em), width: 100%, body)

// ---------- callouts ----------
/// The kinds of @callout: the color (a key of `colors`) and the icon (a role of `icon`). The colors follow the
/// convention of the theme: red for problems, green for advantages and for examples (as the example slides), blue
/// for what is recalled, gray for what is secondary. `examples` is `example` with the title in the plural.
///
/// #test(
///   `_callout-kinds.caution.color == "tertiary"`,
///   `_callout-kinds.keys() == ("caution", "tip", "remark", "note", "example", "examples")`,
///   `_callout-kinds.example == (color: "quaternary", icon: "example")`,
///   `_callout-kinds.examples == _callout-kinds.example`,
/// )
/// -> dictionary
#let _callout-kinds = (
  caution: (color: "tertiary", icon: "caution"),
  tip: (color: "quaternary", icon: "tip"),
  remark: (color: "primary", icon: "remark"),
  note: (color: "neutral-dark", icon: "note"),
  example: (color: "quaternary", icon: "example"),
  examples: (color: "quaternary", icon: "example"),
)

/// The style `"bar"` of @callout, the box of a printed handout: a 3pt bar on the left, the fill in the color lightened
/// 92%, the icon beside the text, which starts with the label in bold.
/// -> content
#let _callout-bar(
  /// Color of the kind. -> color
  c,
  /// Icon: a name of `icon`, content or `none`. -> none | str | content
  ic,
  /// The label that opens the text, or `none`. -> none | content
  label,
  /// The text. -> content
  body,
) = block(width: 100%, fill: c.lighten(92%), stroke: (left: 3pt + c), radius: (left: 0pt, right: 4pt),
  inset: (left: 0.8em, right: 1em, y: 0.65em), breakable: false, {
    // a body that starts on a new line (`#tip[\n  text]`) starts with a space, which would add to the one after the label
    let ch = utils.trim(_children(body))
    let body = ch.join()
    // a text that opens with a shorthand (`-> item`, `> box`, `"quote"`, a lone `>` before an equation), a list (`-`, `+`)
    // or an `#arrow-list` gets a paragraph of its own, on the line under the label, all with the same room: on the line
    // of the label the paragraph would start with the label, and `show par` would leave the shorthand as text
    let opens-list = ch.len() > 0 and (ch.first().func() in (list.item, enum.item) or ch.first().at("label", default: none) == <ufac-arrow-list>)
    let after-label = if _shorthand(ch) != none or opens-list { parbreak() } else { h(0.35em) }
    // on a light color (the yellow) the markers, the icon, the label and what takes the color of the box are in its
    // dark tone, readable on the fill
    let k = _box-ink(c)
    set list(marker: _markers(k))
    set text(fill: colors.neutral-darkest)
    // top and left: in a layout centered vertically (`grid(align: horizon)`, a section slide) or horizontally (the
    // closing slide), the icon stays on the first line and the text on the left
    _in-box(k, grid(columns: (auto, 1fr), column-gutter: if ic == none { 0pt } else { 0.55em }, align: left + top,
      // the icon (0.9em) centered on the capitals of the first line: the line starts at the top of the cell, at the
      // height of the capitals, and the icon goes up half of what it has more than them
      if ic != none { context {
        let cap = measure(text(top-edge: "cap-height", bottom-edge: "baseline")[X]).height
        let size = 0.9em.to-absolute()
        move(dy: -(size - cap) / 2, if type(ic) == str { icon(ic, color: k, size: size, baseline: 0pt) } else {
          // content that takes the color of the text (an icon of the iconify package): the callout's
          text(fill: k, box(height: size, ic))
        })
      } },
      _flow[#if label != none [#text(weight: "bold", fill: if k == c { c.darken(25%) } else { k }, label)#after-label]#body],
    ))
  })

/// Callout: a box with the color, the icon and the title of its kind, the title in the language of the deck. The
/// default style, `"bar"`, is the box of a printed handout: a bar on the left, a light fill, the icon and the title in
/// bold opening the text ("*Tip.* …", "*Caution!* …"; a text that opens with a list (`-`, `+`, `->` or an @arrow-list), a `>` box, a
/// quote or a `>` before an equation starts on the line under it); `"badge"` is an @emph-box with the title on a badge over the
/// border. Inside it, as in a box, the bold text, the markers and the arrows take its color; a code block keeps its
/// own look. Each kind has a function of its own, with the same options: @caution, @tip, @remark, @note, @example and
/// @examples.
///
/// ```example
/// #callout("caution")[
///   `x*y` with two vectors is an error.
/// ]
/// #callout("tip", style: "badge")[
///   The style with the badge.
/// ]
/// #callout("note", title: [Aside.])[
///   Another title.
/// ]
/// ```
/// -> content
#let callout(
  /// `"caution"` (red, a mistake to avoid), `"tip"` (green, a shortcut), `"remark"` (blue, to recall what was seen:
  /// "Relembrando" / "Reminder" / "Recordando"), `"note"` (gray, something secondary), `"example"` (green, with the
  /// beaker of the example slides, a short example inside an ordinary slide) or `"examples"` (the same, with the title
  /// in the plural: "Exemplos" / "Examples" / "Ejemplos"). -> str
  kind,
  /// `"bar"` (a bar on the left and the title opening the text) or `"badge"` (the title on a badge over the border).
  /// -> str
  style: "bar",
  /// The title; `auto` is the name of the kind in the language of the deck ("Caution" / "Atenção"; in the style `"bar"`
  /// with its punctuation, "Caution!", "¡Precaución!", "Tip."); `none` leaves the icon alone. -> auto | none | content
  title: auto,
  /// The color; `auto` is the one of the kind. -> auto | color
  color: auto,
  /// The icon: a name of `icon`, content or `none`; `auto` is the one of the kind. -> auto | none | str | content
  icon: auto,
  /// The text. -> content
  body,
) = {
  assert(kind in _callout-kinds, message: "callout: unknown kind " + repr(kind) + "; use "
    + _callout-kinds.keys().map(k => "\"" + k + "\"").join(", "))
  assert(style in ("bar", "badge"), message: "callout: style is \"bar\" or \"badge\"")
  let k = _callout-kinds.at(kind)
  let c = if color == auto { colors.at(k.color) } else { color }
  let ic = if icon == auto { k.icon } else { icon }
  if style == "bar" {
    let label = if title == auto { context _words(text.lang).bar.at(kind) } else { title }
    _callout-bar(c, ic, label, body)
  } else {
    // the text on the left in a centered layout, as in the style "bar"
    align(left, emph-box(color: c, icon: ic, title: if title == auto { _tr(kind) } else { title }, body))
  }
}

/// A caution, red, for a mistake to avoid: `#caution[..]` is `#callout("caution")[..]`, with the same options
/// (`style`, `title`, `color`, `icon`).
///
/// ```example
/// #caution[
///   `x*y` with two vectors is an error.
/// ]
/// ```
/// -> content
#let caution(
  /// The options of @callout and the text. -> arguments
  ..args,
) = callout("caution", ..args)

/// A tip, green: `#tip[..]` is `#callout("tip")[..]`, with the same options.
///
/// ```example
/// #tip[The up arrow recalls a command.]
/// ```
/// -> content
#let tip(
  /// The options of @callout and the text. -> arguments
  ..args,
) = callout("tip", ..args)

/// A reminder of what was seen before ("Relembrando" / "Reminder" / "Recordando"), blue:
/// `#remark[..]` is `#callout("remark")[..]`, with the same options.
///
/// ```example
/// #remark[
///   A *function* is a named block of code.
/// ]
/// ```
/// -> content
#let remark(
  /// The options of @callout and the text. -> arguments
  ..args,
) = callout("remark", ..args)

/// A note, gray, for what is secondary: `#note[..]` is `#callout("note")[..]`, with the same options.
///
/// ```example
/// #note[Two versions of the program
///   differ here.]
/// ```
/// -> content
#let note(
  /// The options of @callout and the text. -> arguments
  ..args,
) = callout("note", ..args)

/// An example, green, with the beaker of the example slides ("Exemplo" / "Example" / "Ejemplo"), for a short example
/// inside an ordinary slide; an example that takes the whole slide is `== Title <example>`. `#example[..]` is
/// `#callout("example")[..]`, with the same options. The `example-name` and the `example-icon` of `ufac-theme` change
/// only the example slides; `title:` and `icon:` change the callout.
///
/// ```example
/// #example[
///   The Bay of Fundy has tides of 16 m.
/// ]
/// ```
/// -> content
#let example(
  /// The options of @callout and the text. -> arguments
  ..args,
) = callout("example", ..args)

/// Several examples, as @example with the title in the plural ("Exemplos" / "Examples" / "Ejemplos"):
/// `#examples[..]` is `#callout("examples")[..]`, with the same options.
///
/// ```example
/// #examples[
///   Waves made by the wind:
///   - ripples, a few centimeters long;
///   - swell, which crosses oceans.
/// ]
/// ```
/// -> content
#let examples(
  /// The options of @callout and the text. -> arguments
  ..args,
) = callout("examples", ..args)

// ---------- tag ----------

/// Tag: capitals, spaced and bold, on a color, with rounded corners; by default UFAC yellow, as on the cover
/// ("UNDERGRADUATE THESIS") and on the section slides ("PART 2"). As in a pill, the text is dark blue on a light color
/// (a luma of 70% or more: `secondary` and `secondary-light`, the `-lighter` and `-lightest` tones, `quaternary-light`)
/// and white on the others.
/// The vertical padding is an `outset`, as in @eq-box: in a line of text the tag does not change the height of the line.
///
/// ```example
/// -> `plot3` #tag[new]
/// -> #tag(color: colors.tertiary)[exam]
/// -> #tag(
///   color: colors.quaternary-light,
/// )[optional]
/// ```
/// -> content
#let tag(
  /// The color of the tag. -> color
  color: colors.secondary,
  /// The size of the text, relative to the text around it. -> length
  size: 0.6em,
  /// The text, in capitals. -> content
  body,
) = {
  // the room above and below is half the size of the tag, up to 0.35em of the text around it (the tag of the section
  // slides, at 0.7em): a bigger tag in running text does not reach the line above
  context {
    let room = calc.min((0.5 * size).to-absolute(), 0.35em.to-absolute())
    box(fill: color, radius: 3pt, inset: (x: 0.7 * size), outset: (y: room), text(size: size, tracking: 0.06em,
      top-edge: "cap-height", bottom-edge: "baseline", _pill-text(color, upper(body))))
  }
}

// ---------- columns ----------
/// Columns: a thin wrapper over Touying's `cols` (a `grid`), with an optional divider. Touying's own `side-by-side`
/// (no divider) is still available.
///
/// ```example
/// #cols(divider: true,
///   columns: (1fr, 2fr))[
///   Left
/// ][
///   -> the shorthands work
///   -> inside a column
/// ]
/// ```
/// -> content
#let cols(
  /// Column widths, as Touying accepts them: `auto` (equal widths) or an array such as `(1fr, 2fr)`. -> auto | array
  columns: auto,
  /// Space between the columns. -> length
  gutter: 1em,
  /// A blue vertical bar (2.2pt) between the columns; the gutter is then used as inset. -> bool
  divider: false,
  /// One content block per column. -> content
  ..bodies,
) = {
  // each column gets a leading `parbreak()` (`_flow`) so the paragraph rewrites also work in a single-paragraph column
  let bodies = bodies.pos().map(_flow)
  if divider {
    components.cols(columns: columns, gutter: 0pt,
      inset: (x, _) => (left: if x > 0 { gutter / 2 } else { 0pt }, right: gutter / 2, y: 0pt),
      stroke: (x, _) => (left: if x > 0 { colors.primary + 2.2pt } else { none }),
      ..bodies)
  } else { components.cols(columns: columns, gutter: gutter, ..bodies) }
}

// ---------- paragraph rewriting: `> box`, `"quote"`, `-> item` ----------
/// Drops the leading `>` (and one space) of a text node; a lone `>` disappears.
///
/// #test(
///   `_strip-gt([> item]) == [item]`,
///   `_strip-gt([>item]) == [item]`,
///   `_strip-gt([>]) == none`,
///   `_strip-gt([plain]) == [plain]`,
/// )
/// -> content | none
#let _strip-gt(
  /// A text node. -> content
  c,
) = { let s = c.text; if s == ">" { none } else if s.starts-with("> ") { text(s.slice(2)) } else if s.starts-with(">") { text(s.slice(1)) } else { c } }
/// `> text` → `emph-box`; `> == Title` on the first line → the title. Line breaks inside the paragraph arrive as
/// `[ ]` and the text `> == Title` arrives sliced (`[>] [ ] [==] [ ] [Title] …`), so the title runs until the next
/// child that starts with `>`.
/// -> content
#let _blockquote(
  /// Children of the paragraph. -> array
  children,
) = {
  let title = none; let rest = children
  if rest.len() >= 3 and rest.at(0).text == ">" and _is-space(rest.at(1)) and _is-text(rest.at(2)) and rest.at(2).text == "==" {
    rest = rest.slice(3); let t = ()
    while rest.len() > 0 and not (_is-text(rest.at(0)) and rest.at(0).text.starts-with(">")) { t.push(rest.remove(0)) }
    // the spaces around the title (after `==` and the line break before the next `>`) would widen the badge, more
    // than the one of `emph-box(title: ..)`
    while t.len() > 0 and _is-space(t.first()) { t.remove(0) }
    while t.len() > 0 and _is-space(t.last()) { t.pop() }
    title = t.sum(default: [])
  }
  emph-box(title: title, rest.map(c => if _is-text(c) { _strip-gt(c) } else { c }).filter(c => c != none).sum(default: []))
}
/// A paragraph made only of `"…"` runs (one per line) → one `quote-box` per run, colors cycling
/// secondary → primary → quaternary → tertiary. Anything outside the quotes except spaces cancels the rewrite.
/// -> content | none
#let _quotes(
  /// Children of the paragraph. -> array
  children,
) = {
  let items = (); let cur = none
  for c in children {
    if _is-dq(c) { if cur == none { cur = () } else { items.push(cur); cur = none } }
    else if cur != none { cur.push(c) } else if not _is-space(c) { return none }
  }
  if cur != none or items.len() == 0 { return none }
  let palette = (colors.secondary, colors.primary, colors.quaternary, colors.tertiary)
  items.enumerate().map(((i, it)) => quote-box(color: palette.at(calc.rem(i, palette.len())), it.sum(default: []))).join()
}
/// The `→` marker of the arrow lists: `auto` is the color of the box around it (blue outside one), or white inside a
/// pill (white text on a color), like bold text.
/// -> content
#let _arrow-marker(
  /// Color of the arrow. -> auto | color
  color,
) = if color == auto {
  context text(fill: if _in-pill() { white } else { _current-box-color(colors.primary) }, sym.arrow.r)
} else { text(fill: color, sym.arrow.r) }
/// Consecutive `-> item` lines → a `list` with a `→` marker (blue, the box color inside `emph-box`, or `color`).
/// In markup `->` is not the arrow: Typst emits the text nodes `[-]` and `[> item]` when `-` opens the line
/// without a space; the pair is what is detected here.
/// -> content
#let _arrows(
  /// Children of the paragraph. -> array
  children,
  /// Color of the arrow; `auto` is blue, or the box color inside an @emph-box. -> auto | color
  color,
) = {
  let items = (); let cur = (); let i = 0
  while i < children.len() {
    let c = children.at(i)
    if _is-text(c) and c.text == "-" and i + 1 < children.len() and _is-text(children.at(i + 1)) and children.at(i + 1).text.starts-with(">") {
      if cur != () { items.push(cur); cur = () }
      cur.push(_strip-gt(children.at(i + 1))); i += 2
    } else {
      if _is-space(c) and i + 1 < children.len() and _is-text(children.at(i + 1)) and children.at(i + 1).text == "-" { i += 1; continue }
      cur.push(c); i += 1
    }
  }
  if cur != () { items.push(cur) }
  list(marker: _arrow-marker(color), ..items.map(it => it.sum(default: [])))
}
/// The `show par` rule of the theme. It inspects `it.body.children` (which shorthand they are is `_shorthand`, which the
/// default callout also asks): a lone `>` → signal for the next block
/// equation (@eq-box); a first text child starting with `>` → `emph-box`; first and last children
/// `smartquote(double: true)` → `quote-box`es; `[-]` followed by `[> …]` → arrow list. `\> word` and `-\> word` are
/// escapes (see `_escaped-after`); `\"…\"` already arrives as the text `"`, not as a `smartquote`.
/// `> $x$` (inline equation on the `>` line) does NOT become an `eq-box`, by decision (2026-09-16): the equation
/// reaches `show par` already realized as an opaque `inline` between two `tag`s, without a body. Wrapping every
/// inline equation in a `box` (`show math.equation.where(block: false): it => box(it)`, which arrives with a
/// recoverable `body`) would make it possible, but the side effect on all inline equations is not worth it; it
/// stays a plain box and the limitation is documented.
/// -> content
#let _rewrite-par(
  /// The paragraph. -> content
  it,
  /// Color of the `->` arrows, see @arrows. -> auto | color
  arrow-color: auto,
) = {
  let ch = _children(it.body)
  let kind = _shorthand(ch)
  if kind == "eq" { _key-eq.update(colors.primary) }
  else if kind == "box" { _blockquote(ch) }
  else if kind == "quotes" { _quotes(ch) }
  else if kind == "arrows" { _arrows(ch, arrow-color) }
  else { it }
}
/// Arrow lists with the arrow in another color, for the `-> item` lines of the body, also inside its boxes. The `-> item` shorthand itself
/// needs no function: consecutive lines starting with `->` become one list with a blue arrow (the box color inside an
/// @emph-box). The list must start the paragraph, and `-\> item` escapes it. The function form of `-> item` is
/// @arrow-list, which takes its own `color:`.
///
/// ```example
/// #arrows(color: colors.quaternary)[
///   -> green here
///   -> and here
/// ]
/// ```
/// -> content
#let arrows(
  /// Color of the arrows. -> color
  color: colors.primary,
  /// Content with `-> item` paragraphs. -> content
  body,
) = {
  // the inner `show par` replaces the global one and returns a `list`, so nothing is processed twice
  show par: _rewrite-par.with(arrow-color: color)
  body
}
/// The function form of the `-> item` shorthand: the `-` items of the body get the arrow of `->`, blue, or the color
/// of the box around it, or white in a dark pill. It takes a `-` list, so an item can hold a block or a nested list.
///
/// ```example
/// #arrow-list[
///   - the tide rises
///   - and falls
/// ]
/// ```
/// -> content
#let arrow-list(
  /// Color of the arrows; `auto` follows the box around it, as `->` does. -> auto | color
  color: auto,
  /// A `-` list. -> content
  body,
) = {
  let l = { set list(marker: _arrow-marker(color)); body }
  // the label lets a callout tell it from a `-` list: at its start it goes on the line under the title, as `->` does
  [#l<ufac-arrow-list>]
}

// ---------- outline ----------
/// Outline of the deck: its parts (the `= Title` headings, the "Part N" of the section slides), one per line, with the
/// number in a small pill, the title in bold blue and, after a dotted leader, the number of the section slide (the
/// slide number of the footer, which skips the cover); every line is a link to that slide. In a deck it takes the place of Typst's
/// `outline`, which is still `std.outline`. It goes on a slide of its own, usually the first after the cover:
///
/// ```typ
/// == Contents
/// #outline()
/// ```
/// -> content
#let outline() = context {
  let parts = query(heading.where(level: 1))
  // the number in a pill smaller than the subtitles' (`_pill`), its vertical room outside (`outset`), so that it does
  // not change the height of the line
  let number(n) = box(fill: colors.primary, radius: 3pt, inset: (x: .4em), outset: (y: .25em),
    text(size: .78em, fill: white, weight: "bold", str(n)))
  // one grid for all the parts, so that the titles line up when a number has two digits
  grid(columns: (auto, 1fr, auto), column-gutter: .7em, row-gutter: 1.1em, align: horizon,
    ..parts.map(h => {
      let at = h.location()
      (
        link(at, number(counter(heading).at(at).first())),
        // the title as in the title of a slide (`kind: "title"`): a code chip in it takes the blue of the title
        link(at, [#_in-box(colors.primary, text(fill: colors.primary, weight: "bold", h.body), kind: "title") #box(
          width: 1fr, text(fill: colors.neutral-light, repeat(gap: .3em)[.]))]),
        link(at, text(fill: colors.primary, weight: "bold", str(utils.slide-counter.at(at).first()))),
      )
    }).flatten())
}
