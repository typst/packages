// Layouts for the slide body.
//
// Deliberately content functions, not new slide kinds: the splitter in
// `present.typ` turns headings into `slide` and `section`, nothing else.
// A layout is thus something that sits *inside* a slide: it can be nested,
// placed in a grid cell, and faded in with `anim`.
//
// The coloring comes from the theme, and only as a *default*: `color`,
// `fill` and `stroke` are set to `auto` and pick up their value there.
// Anyone running six meaning-colors supplies them at the call site as
// before; the package does not prescribe any.
//
// That is why the box sits inside a `context`: it lives in the slide body
// and only learns there under which theme it is set.

#import "elements.typ": anim-kern
#import "internal.typ": (fit-faktor, fit-mass, fit-meldung, fit-toleranz,
                        hat-pause, im-fit, kurve, step-cursor,
                        umgebungs-block, unloesbar, zeilen-hoehe)
#import "config.typ": doc-word
#import "themes.typ": lesbar, theme-state
#import "richtung.typ": von-rechts

/// A named box: Beamer's `block`.
///
/// `title` sits in a colored bar above it, `number` additionally places a
/// numbered disc in front. Without either, a plain box remains.
///
/// `color`, `fill` and `stroke` take the theme's values on `auto`: its
/// primary color, its card background and its border.
///
/// No `clip: true`: Typst derives a clip path's identifier from the
/// content, and the same box twice on a slide would produce the same
/// identifier. The corners are therefore rounded by the bar itself.
///
/// Six labels for the six parts, so a deck can restyle them without touching
/// the theme. `<ts-card>` is the box itself, and because its surface travels
/// through a `set` rule rather than an argument, `set block(fill: ..)` on
/// that label reaches it. `<ts-card-bar>` is the coloured tab, `<ts-card-title>`
/// the caption, `<ts-card-disc>` the numbered disc, `<ts-card-number>` the
/// numeral in it, `<ts-card-body>` the body.
#let card(
  body,
  title: none,
  number: none,
  color: auto,
  fill: auto,
  stroke: auto,
  radius: auto,
  inset: (x: 12pt, y: 10pt),
  width: 100%,
) = context {
  let t = theme-state.get()
  // Two constructions. `"bar"` is the original: white surface, thin
  // border, colored bar with a small-caps label above it. `"label"` comes
  // from the textbook: no edge, no rounding, a tinted surface, and the
  // caption sits in color *inside* the box instead of on a bar.
  let stil = t.at("box", default: "bar")
  // In a row with a fixed height, the box fills it. Otherwise the shorter
  // of the two would stay at the top and the row would have gained nothing.
  //
  // The measure comes as a length, not as `100%`: a percentage here
  // resolves against the region, not against the grid cell. Measured in
  // practice, only the box's top edge was visible, because the rest lay
  // far below the slide.
  let zeile = zeilen-hoehe.get()
  let eigene-farbe = color != auto
  // In the bar style the color is a *ground* and carries white on it, so it
  // has to stay the theme's strong tone. In the label style the same entry is
  // *text* on the surface, and there the strong tone of a dark palette sits
  // too close to that surface to be read. So that one is measured rather than
  // named. Where the theme's own colors already work, and they do in all five,
  // the measurement returns exactly what stood here before.
  let color = if color != auto { color } else if stil == "label" {
    lesbar(t.surface, t.strong, t.ink)
  } else { t.strong }
  // In the label style, the tint carries the same meaning as the text on
  // it: a box labeled in blue sits on blue, a red one on red. Only someone
  // giving no color gets `surface`: in the textbook theme that is the
  // measured tint of the note box, and it is warmer than a heading color
  // merely lightened.
  let fill = if fill != auto { fill }
              else if stil == "label" and eigene-farbe {
                if t.inverted { color.darken(72%) } else { color.lighten(89%) }
              } else { t.surface }
  let radius = if radius != auto { radius } else if stil == "label" { 0pt } else { 7pt }
  let stroke = if stroke != auto { stroke }
                else if stil == "label" { none } else { 0.7pt + t.border }
  // Surface, border and rounding travel through a `set` rule instead of
  // standing as arguments on the block. Only that way does
  // `show label("ts-card"): set block(fill: ..)` reach the box: an explicit
  // argument beats any rule. What the surrounding document had set is read
  // first and put back inside, or the box's own surface would run on into
  // every block of its body and out over the rounded corners.
  let aussen = umgebungs-block()
  {
  set block(fill: fill, stroke: stroke, radius: radius)
  [#block(
    width: width, height: if zeile == none { auto } else { zeile },
  {
    // Between the bar and the body, Typst would otherwise add its block
    // spacing: measured at 20pt for 17pt text, which left the text hanging
    // 30pt below the head but only 9pt above the bottom edge. Both blocks
    // give it up; the spacing comes solely from `inset`.
    set block(spacing: 0pt, fill: aussen.fill, stroke: aussen.stroke,
              radius: aussen.radius)
    if title != none and stil == "bar" {
      // No `stroke` here. The bar never had one of its own, so it picks up
      // whatever the document set, and the line above has already put that
      // back. Writing `stroke: none` would be an explicit value and would
      // beat a deck's `#set block(stroke: ..)`, which is a change in a deck
      // that uses no label at all.
      set block(fill: color,
                radius: (top-left: radius, top-right: radius))
      [#block(
        width: 100%,
        inset: (x: 11pt, y: 6pt),
        {
          set block(fill: aussen.fill, stroke: aussen.stroke,
                    radius: aussen.radius)
          text(size: 0.62em, weight: "bold", fill: white, tracking: 0.6pt,
               [#upper(title) <ts-card-title>])
        },
      ) <ts-card-bar>]
    }
    block(width: 100%, inset: inset, {
    // In the label style, the caption sits inside the box and shares the
    // inset with the body. Mixed case and in color, not small caps and
    // white: here the label is a heading, not a tab.
    if title != none and stil == "label" {
      block(above: 0pt, below: 0.45em,
        text(size: 0.78em, weight: "bold", fill: color, [#title <ts-card-title>]))
    }
    let rumpf = [#body <ts-card-body>]
    if number == none { rumpf } else {
      grid(
        columns: (auto, 1fr), column-gutter: 8pt, align: (start + top, start + top),
        box(baseline: 0.24em, {
          set circle(fill: color, stroke: none)
          [#circle(
            radius: 0.62em,
            align(center + horizon,
                  text(size: 0.62em, weight: "bold", fill: white,
                       [#str(number) <ts-card-number>])),
          ) <ts-card-disc>]
        }),
        rumpf,
      )
    }
    })
  },
  ) <ts-card>]
  }
}

/// A highlighted key sentence: Beamer's `alertblock`.
///
/// The bar on the edge the writing starts at marks it on every slide at a
/// glance as "the thing to remember", without it looking like a second box.
///
/// Labelled `<ts-callout>`, `<ts-callout-title>` and `<ts-callout-body>`. As
/// in `card`, the surface goes through a `set` rule, so a label rule reaches
/// `fill`, `stroke` and `radius`.
#let callout(
  body,
  title: auto,
  color: auto,
  radius: 7pt,
  inset: (x: 14pt, y: 11pt),
  width: 100%,
) = context {
  let t = theme-state.get()
  // `auto` means "take the document language's default", `none` means "no
  // caption at all". Both must stay distinguishable.
  let title = if title == auto { doc-word("note") } else { title }
  let color = if color == auto { t.accent } else { color }
  // On a dark background, a lightened accent is a spotlight. There the
  // color is darkened instead of lightened, and the caption is lightened.
  let grund = if t.inverted { color.darken(68%) } else { color.lighten(90%) }
  let beschriftung = if t.inverted { color.lighten(15%) } else { color.darken(12%) }
  let zeile = zeilen-hoehe.get()
  // As in `card`: the surface goes through a rule so a label can reach it,
  // and the document's own block style is put back inside.
  let aussen = umgebungs-block()
  {
  // The bar stands where the writing starts. A stroke names sides, not
  // `start`, so the side is picked here; the box is in context already and
  // sees the direction the slide body set.
  let strich = if von-rechts() { (right: 3.5pt + color) } else { (left: 3.5pt + color) }
  set block(fill: grund, stroke: strich, radius: radius)
  [#block(
    width: width, height: if zeile == none { auto } else { zeile },
    inset: inset,
    {
      set block(fill: aussen.fill, stroke: aussen.stroke, radius: aussen.radius)
      // Not text, `v()` and body one after another: between two paragraphs
      // Typst additionally inserts `par.spacing`, 29pt for 24pt text, which
      // adds to the explicit spacing. Measured at 34pt instead of the
      // intended 6. As blocks with `above`/`below` set, only what is
      // written here counts.
      if title != none {
        // Versalien nur da, wo die Karte sie auch nimmt. `upper` stand hier
        // fest, waehrend der Kartentitel dem Theme folgt -- in der
        // Beschriftungsform (`themes.lesson`) standen Karte und Kasten
        // nebeneinander und konnten nie zusammenpassen: "It travels" gegen
        // "IT DOES NOT LAST", obwohl beide gleich geschrieben sind.
        let stil = t.at("box", default: "bar")
        let beschriftet = if stil == "label" { title } else { upper(title) }
        block(above: 0pt, below: 0pt,
          text(size: 0.62em, weight: "bold", fill: beschriftung,
               tracking: if stil == "label" { 0pt } else { 0.6pt },
               [#beschriftet <ts-callout-title>]))
      }
      // Relative to the text size, so the spacing is right at every theme
      // size: fixed points would look too airy at 15pt and cramped at 31pt.
      // More air than in the box: there the colored bar separates label and
      // text, here both sit on the same background and need the spacing.
      block(above: if title == none { 0pt } else { 0.6em }, below: 0pt,
        [#body <ts-callout-body>])
    },
  ) <ts-callout>]
  }
}

/// Two or more columns side by side.
///
/// The name comes from Touying and Polylux, which chose it independently
/// of each other.
///
/// `split` takes the column widths; the default gives the first column a
/// bit more, because that is usually where the illustration sits and the
/// text on the right.
#let side-by-side(
  ..parts,
  split: (1.25fr, 1fr),
  gutter: 18pt,
  align: horizon,
  equal: false,
) = {
  let spalten = parts.pos()
  assert(spalten.len() >= 2,
         message: "typstage: side-by-side() wants at least two columns")
  // `..parts` would otherwise swallow any named argument silently: a typo
  // in `split:` would go unnoticed, and the slide would quietly look
  // different.
  assert(parts.named().len() == 0,
         message: "typstage: side-by-side() does not know "
                + parts.named().keys().join(", ")
                + ". It takes split, gutter, align and equal.")
  let breiten = if spalten.len() == split.len() { split }
                else { (1fr,) * spalten.len() }
  if not equal {
    return grid(columns: breiten, column-gutter: gutter, align: align, ..spalten)
  }
  // Equal-height columns. Without this, each box stands as tall as its
  // own text, and two cards side by side end up different heights even
  // though they are meant to carry the same weight.
  //
  // The route goes through an explicitly set row height: measure the
  // columns first, then fix the largest as `rows`. A `height: 100%` in the
  // box alone would not do it, since a percentage resolves against the
  // region and would make both slide-height.
  let roh = grid(columns: breiten, column-gutter: gutter, align: align, ..spalten)
  layout(available => context {
    // The row's height is that of the grid as it stands on its own, and
    // that is the height of the tallest column. Asking the grid for it is
    // more accurate than computing it: splitting the column widths from
    // `split` by hand would mean weighing `fr` shares, fixed measures and
    // `auto` against each other, and would be off at every rounding.
    //
    // What gets measured is the raw grid, in which no row height is set
    // yet: the boxes in it are as tall as their content, and that is
    // exactly what the measure should be.
    let h = measure(roh, width: available.width).height
    grid(columns: breiten, column-gutter: gutter, align: align, rows: (h,),
      ..spalten.map(p => zeilen-hoehe.update(h) + p + zeilen-hoehe.update(none)))
  })
}

/// A tile grid that staggers itself.
///
/// Each tile appears one step after the previous one: that is the reason
/// this function exists. By hand that means an `anim` per tile with an
/// incremented number or delay.
///
/// `at` behaves as in `anim`: `auto` takes the next free step. `stride: 0`
/// makes all tiles appear on the same step and staggers only through
/// `stagger`, in milliseconds; a wave then runs through the grid.
///
/// `duration` and `easing` are those of `anim` and apply to every tile alike:
/// one grid moves as one thing. `auto` is the presentation's duration and the
/// package's own curve. Without them a deck that wanted a slower tile or a
/// curve with a swing had to leave the grid and write the `anim`s out by hand,
/// which is the very work `tiles` exists to save.
#let tiles(
  ..items,
  columns: auto,
  gutter: 14pt,
  row-gutter: auto,
  at: auto,
  stride: 1,
  stagger: 0,
  enter: "fade-up",
  duration: auto,
  easing: auto,
  // The edge the writing begins at; `std.`, because `start` is a step number
  // further down.
  align: top + std.start,
) = context {
  // Asked here rather than left to the `anim`s below, so the message names the
  // function the deck actually wrote.
  assert(im-fit.get() == 0, message: fit-meldung("tiles"))
  // `..items` would otherwise swallow any named argument without a word: a
  // typo in `columns:` would lay the tiles out on the default and say nothing.
  assert(items.named().len() == 0,
         message: "typstage: tiles() does not know "
                + items.named().keys().join(", ")
                + ". It takes columns, gutter, row-gutter, at, stride, "
                + "stagger, enter, duration, easing and align.")
  let kacheln = items.pos()
  assert(kacheln.len() > 0, message: "typstage: tiles() wants at least one tile")
  assert(at == auto or (type(at) == int and at >= 1),
         message: "typstage: tiles(at: …) takes a step number from 1 upwards, "
           + "or auto. Steps are counted from 1. Not " + repr(at))
  // Null ist hier gewollt -- alle Kacheln auf einem Schritt -- negativ nie.
  assert(type(stride) == int and stride >= 0, message:
    "typstage: tiles(stride: …) is how many steps lie between two tiles, a "
    + "whole number from 0 upwards; 0 puts them all on the same step. Not "
    + repr(stride))
  // Resolved once and then incremented, not `auto` per tile, since
  // otherwise `stride: 0` (all on the same step) could not be expressed at
  // all.
  // Bei `stride: 1` vergibt `track` die Schritte selbst (`at: auto`). Ein aus
  // dem gelesenen Zeiger gerechnetes und hereingereichtes `at` kostet das
  // Dokument sonst seine Konvergenz, sobald eine Kachel etwas außerhalb des
  // Flusses trägt. Bei anderem `stride` liegen Lücken dazwischen, die `track`
  // nicht kennt -- dort bleibt der alte Weg.
  let auto-kette = at == auto and stride == 1
  let start = if at == auto { step-cursor.get().first() + 1 } else { at }
  // Einmal aufgelöst und nicht je Kachel: die Meldung soll `tiles` heißen und
  // nicht `anim`, und ein Name, den es nicht gibt, ist einmal falsch und nicht
  // neunmal. Derselbe Handgriff wie in `stagger`.
  let takt = kurve(easing, "tiles")
  let spalten = if columns == auto { calc.min(kacheln.len(), 3) } else { columns }
  grid(
    columns: if type(spalten) == int { (1fr,) * spalten } else { spalten },
    column-gutter: gutter,
    row-gutter: if row-gutter == auto { gutter } else { row-gutter },
    align: align,
    ..kacheln.enumerate().map(((i, k)) => anim-kern(
      k,
      at: if auto-kette { auto } else { start + i * stride },
      boden: 1,
      enter: enter,
      duration: duration,
      easing: takt,
      delay: i * stagger,
    )),
  )
}

/// A large statement in the middle: the formula that matters.
///
/// Explicitly demands the full width: a tracked element becomes as wide
/// as its content, and a bare `align(center, …)` inside it would have no
/// room to center in and would sit unchanged on the left.
///
/// Labelled `<ts-statement>`. `size` is measured in `em`, so a
/// `set text(size: …)` from a label rule multiplies rather than replaces it.
#let statement(
  body,
  size: 1.6em,
  color: none,
  above: 0.6em,
  below: 0.6em,
) = [#block(width: 100%, {
  v(above)
  // `fill: auto` does not exist for `text`: without a color, none is set
  // at all, so that the surrounding one applies.
  let gesetzt = text(size: size, body)
  align(center, if color == none { gesetzt } else { text(fill: color, gesetzt) })
  v(below)
}) <ts-statement>]

/// Scale one block down to the room it has.
///
/// For the thing whose size the deck does not control: a wide table, a
/// generated diagram, a list that came out of a data file. Without it such a
/// block runs over the edge of the slide. In the PDF it is still to be seen
/// standing there; in the browser the slide sits in a frame of fixed size and
/// whatever reaches past it is cut away.
///
/// ```typ
/// #slide[
///   == Regression results
///   #fit(wrap: false, my-table)
/// ]
/// ```
///
/// `wrap: false` because the block is a table. Everything that lays itself out
/// in columns has to be measured as it stands; see below.
///
/// The block is measured against the place it stands in and scaled
/// geometrically, so it keeps its proportions and what stands around it counts
/// with its new size. No factor is given by hand.
///
/// *Width first, then smaller.* The block is offered the full width before it
/// is measured, so a paragraph or a list breaks into the space instead of
/// shrinking, and only what is still too tall afterwards is scaled. A table, a
/// chart or a drawing would rearrange its own columns instead, which changes
/// the picture rather than its size; `wrap: false` measures such a block
/// exactly as it stands.
///
/// *It only shrinks.* `grow: true` also blows a block up that is smaller than
/// its place, for the one large number that is meant to fill the slide.
/// `shrink: false` takes the shrinking away and leaves only the growing.
///
/// `width` and `height` take `auto`, a length or a ratio. `auto` is the whole
/// place. On `height: auto` the block takes what is left over below whatever
/// stands above it on the slide, so a fit under two bullet points reckons with
/// the bullet points. That has a flip side wherever something encloses the
/// fit: inside a `card` the box becomes slide-tall, is cut off at the bottom,
/// and *whatever follows the card falls off the slide* -- measured in both
/// outputs. It is the `1fr` doing that, not the scaling: a `card` around a
/// bare `block(height: 1fr)` behaves the same. Give `height:` explicitly
/// inside a card, and the fit reckons with that instead.
///
/// *No reveal inside.* Two things do not survive being measured. A `pause` is
/// found by walking the slide body, and a fitted block is a closure that walk
/// cannot enter: measured on a slide carrying two pauses, the step count fell
/// from three to one and nothing said so. And a measured block has no height
/// to reckon against, which is the axis on which a tracked element resolves
/// its size and reserves the room for its marker: measured, an `anim` inside a
/// fit was not scaled at all and ran off the bottom of the slide. `fit` stops
/// with a message instead, for `pause`, `anim`, `stagger`, `alternatives`,
/// `morph`, `tiles`, `video`, `embed`, `flipbook`, `build`, `scene`, `camera`
/// and `cue`, in both outputs. Fit
/// what stands inside the reveal rather than fitting around it:
/// `anim(fit(my-table))` works, `fit(anim(my-table))` is the error.
///
/// `speaker-note` and `bridge-job` are allowed inside a fit. They settle no
/// geometry, and a `measure` commits no state, so both were measured to arrive
/// exactly once. The other direction is the one that does not work: a note
/// made only of a `fit` carries no text, and `speaker-note` refuses it.
///
/// The geometry is adapted from mosaic, which adapted Touying 0.7.4, which
/// credits it to Andreas Kröpelin (Polylux PR #91) and to ntjess.
#let fit(
  body,
  width: auto,
  height: auto,
  wrap: true,
  grow: false,
  shrink: true,
) = {
  // Asked before anything is laid out, and by walking the body, because a
  // pause is a marker and not a call. Everything else announces itself while
  // it is laid out and is caught by `im-fit`.
  assert(not hat-pause(body), message: fit-meldung("pause"))
  im-fit.update(d => d + 1)
  let gebaut = layout(reg => context {
    // No room means nothing to solve. That is not an exotic case: under a
    // `measure` the region comes back unbounded, and `alternatives` and
    // `side-by-side(equal: true)` both measure their content.
    //
    // A hand-given height is not asserted here either, and that was tried.
    // Handing back `block(height: height, body)` looks right for the one case
    // where the fit really does scale the body down to it, but it is a claim
    // the fit does not keep: with a body smaller than the height nothing is
    // grown, with `shrink: false` nothing is shrunk, and under a narrower
    // region the width decides the factor and the block ends up shorter than
    // the height. Measured, `fit(height: 300pt)` around a small body reserved
    // 300pt where 7.24pt is set, and an `alternatives` beside such a fit
    // pushed the rest of the slide to its bottom edge.
    if unloesbar(reg.width) or unloesbar(reg.height) { return body }
    let raum-b = fit-mass(width, reg.width)
    let raum-h = fit-mass(height, reg.height)
    if unloesbar(raum-b) or unloesbar(raum-h) { return body }
    // The full width first, so text breaks instead of shrinking. Capped at the
    // block's own width, or a single short line would be stretched across the
    // slide and then measured as if it were that wide.
    let inhalt = if wrap {
      box(width: calc.min(raum-b, measure(body).width), body)
    } else { body }
    let mass = measure(inhalt)
    // Something without an area has no factor. A line measures 0pt tall, and
    // dividing by that would end the compilation.
    if mass.width <= 0pt or mass.height <= 0pt { return body }
    let f = fit-faktor(mass, raum-b, raum-h)
    let anfassen = ((shrink and f < 100% - fit-toleranz)
                    or (grow and f > 100% + fit-toleranz))
    if anfassen {
      scale(f, origin: top + left, reflow: true, box(width: mass.width, inhalt))
    } else if width == auto {
      // Untouched, not the measured box. `width: auto` is the region's own
      // width, which the body gets from the region anyway, so a block that
      // needs no scaling should stand exactly as it would without the fit.
      // Measured on a paragraph that wraps into its place: the pixels of the
      // slide with the fit and of the slide without it are the same.
      body
    } else {
      // A width given by hand has to hold even when nothing is scaled, or the
      // argument would do nothing at all in that case. Measured: without this,
      // `fit(width: 50%, table)` set the table across the full slide.
      inhalt
    }
  })
  // `1fr` is what turns "the whole height" into "what is left over": in a flow
  // the fixed-size siblings are laid out first and the fraction takes the
  // rest, so a fit below two bullet points reckons with them. Only for
  // `height: auto`; a height given by hand is meant literally.
  if height == auto { block(height: 1fr, gebaut) } else { gebaut }
  im-fit.update(d => d - 1)
}
