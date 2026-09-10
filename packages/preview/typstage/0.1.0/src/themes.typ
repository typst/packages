// The look of a presentation: five themes and the blueprint behind them.
//
// A theme is a *dictionary*. Almost everything in it is a value: a color,
// a font, a measure, or a short word for one of the few construction
// kinds (`header`, `footer`, `progress`). Only two entries are functions:
// the title slide and the section slide. The two are whole pictures, not
// a variation of one another; they could only be described with a dozen
// more switches, and even then they would still all be built the same
// way.
//
//   #show: presentation.with(theme: themes.night)
//   #show: presentation.with(theme: themes.lesson + (accent: blue))
//
// The second line is the whole trick to varying a theme: a theme is a
// dictionary, and `+` overwrites individual entries.
//
// The eight color entries are also a *palette*, and `presentation` takes one
// separately (`palettes.typ`). The difference is what each is for: `+` on a
// theme reaches every entry, including the fonts and the measures, while a
// palette reaches the colors and nothing else, and therefore composes with
// any design. `mit-palette` at the bottom of this file is where the two meet.

#import "config.typ": margins
#import "palettes.typ": contrast, invert-palette, palette-keys

/// The first of the given colors that is readable on `grund`, measured.
///
/// `strong` is the one role a palette cannot settle on its own. In
/// `themes.default` and `themes.editorial` it is a *ground* that carries light
/// text; in `themes.lesson` and `themes.plain` it is the color of the heading
/// *on* the paper. No single color does both once the paper turns dark, so
/// every place that sets `strong`, or `paper`, as text asks here instead of
/// naming a color outright.
///
/// The pick is a measurement, not a lightness rule, and that distinction is
/// the whole point. A muted sage such as `rgb("#aebdb3")` reads as "light" to
/// a luminance rule, yet white on it measures 1.96 to 1. Here the candidates
/// are weighed by `contrast`, and the first one that reaches 4.5 to 1 wins, so
/// the color a theme names first is the one it keeps wherever that color
/// works. Where none reaches it, the strongest of them is taken rather than
/// nothing.
#let lesbar(grund, ..kandidaten) = {
  let ks = kandidaten.pos()
  let gut = ks.find(c => contrast(c, grund) >= 4.5)
  if gut != none { gut } else { ks.sorted(key: c => -contrast(c, grund)).first() }
}

/// The same for a shape rather than for text.
///
/// A bar, a rule, a marker carries no letterforms, so the contract asks 3.0 of
/// it and not the 4.5 body text wants -- the same two numbers the palette
/// report uses. Of the five bundled themes only `default` and `night` draw a
/// progress indicator at all, and on their own grounds their accent measures
/// 3.26 and 9.77, so both keep the accent and nothing moves. It is the ground
/// an inverted slide puts underneath that this answers: night's cyan measures
/// 1.59 against it.
#let sichtbar(grund, ..kandidaten) = {
  let ks = kandidaten.pos()
  let gut = ks.find(c => contrast(c, grund) >= 3.0)
  if gut != none { gut } else { ks.sorted(key: c => -contrast(c, grund)).first() }
}

/// The full-bleed ground of a title or section slide.
///
/// A `set` rule rather than an argument, so a `show label(..): set rect(..)`
/// in a deck reaches it. An explicit `fill:` on the rect could not be
/// overridden by any rule.
#let grund(farbe, marke) = {
  set rect(fill: farbe, stroke: none)
  if marke == "title" {
    [#rect(width: 100%, height: 100%) <ts-title-slide-ground>]
  } else {
    [#rect(width: 100%, height: 100%) <ts-section-slide-ground>]
  }
}

/// One of the short accent strokes a title or section slide is built from.
#let zierlinie(breite, hoehe, farbe, marke) = {
  set rect(fill: farbe, stroke: none)
  if marke == "title" {
    [#rect(width: breite, height: hoehe) <ts-title-slide-rule>]
  } else {
    [#rect(width: breite, height: hoehe) <ts-section-slide-rule>]
  }
}

/// Font arguments that simply leave out a `none`.
///
/// `text(font: none)` does not exist: anyone who does not want to
/// prescribe a font must not set the argument at all.
#let font-args(f) = if f == none { (:) } else { (font: f) }

/// Pieces stacked one below another, with exactly the given spacing.
///
/// The arguments alternate: content, spacing, content, spacing, content.
/// Necessary because Typst inserts `par.spacing` between two paragraphs
/// and `block.spacing` between two blocks: both add to an explicit
/// `v()`. On a title slide with 24pt base text, that was measured at
/// 29pt extra, which pulled the layout apart. Here only what is written
/// counts.
#let stapel(..teile) = {
  let xs = teile.pos()
  for (i, x) in xs.enumerate() {
    if calc.rem(i, 2) == 0 {
      block(above: if i == 0 { 0pt } else { xs.at(i - 1) }, below: 0pt, x)
    }
  }
}

/// How large the title of a section slide is at a given depth.
///
/// One rule for all five themes, so a deck keeps the same hierarchy when it
/// changes theme. `basis` is the size the theme sets for its outermost level.
///
/// Depth 1 is handed back untouched rather than multiplied by 1.0. Not out of
/// care about floating point but out of care about the output: a deck that
/// never names `slide-level` has only depth 1, and its section slides have to
/// come out of this byte for byte as they did before there were levels at
/// all. Below the third level nothing shrinks further; a fourth structure
/// level needs `slide-level: 5`, and by then size is no longer what is
/// missing.
#let ebenen-groesse(basis, d, k) = if d <= 1 { basis * k } else {
  basis * k * (0.8, 0.68).at(calc.min(d, 3) - 2)
}

/// The line above a section title that says what the section hangs under.
///
/// Only from the second structure level on. At the default `slide-level: 2` a
/// deck has exactly one level, `eltern` is always empty, and no theme ever
/// draws this.
///
/// The color is measured, not named: the five section slides stand on five
/// different grounds, three of them dark. `t.muted` is the deck's own subdued
/// color and comes first; where it does not reach 4.5 to 1 against the ground,
/// the candidates the theme's own title falls back to take over.
#let ebenen-pfad(eltern, grund, t, k, ..hell) = text(
  size: 13pt * k, tracking: 0.6pt * k, weight: "regular",
  fill: lesbar(grund, t.muted, ..hell.pos()),
  [#upper(eltern.map(x => [#x]).join([ · ])) <ts-section-slide-parent>])

// ═══════════════════════════════════════════════════════════════════════════
//  Title and section slides
// ═══════════════════════════════════════════════════════════════════════════
//
// Each of these functions receives `(t, s, geo)`: the theme, the slide
// (with `title`, `subtitle`, `author`, `date`, and on a section slide
// `depth` and `parents`) and the canvas.
// `geo.scale` is the factor by which all measures grow along: every
// number below is meant in points of the default canvas and gets
// multiplied by it.

/// The date, as it appears under a title.
///
/// `date` may be either. A `datetime` is set in the local notation;
/// anyone who wants a different one supplies content directly: `date:
/// [15 September 2026]`. Previously, three title slide functions called
/// `display` without asking. An English deck thereby inevitably got
/// "15.09.2026" under the title, and passing content broke the build,
/// because content does not know `display`. The first attempt only fixed
/// this one line here and overlooked the other two places; that is why
/// the conversion now lives in a single place.
#let datum(d) = if type(d) == datetime {
  d.display("[day].[month].[year]")
} else { d }

/// The line with author and date, as it stands under every title slide.
#let by-line(t, s, k) = text(size: 12pt * k, fill: t.muted, [#{
  s.author
  if s.date != none [ · #datum(s.date) ]
} <ts-title-slide-byline>])

// ── default ────────────────────────────────────────────────────────────────

/// Title on the left at half height, with a short accent stroke below it.
#let band-title-slide(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  place(top + left, dx: m.left, dy: geo.height * 0.32, {
    stapel(
      text(..font-args(t.title-font), size: 34pt * k, weight: "bold",
           fill: lesbar(t.paper, t.strong, t.ink),
           [#s.title <ts-title-slide-title>]),
      6pt * k,
      zierlinie(190pt * k, 2.5pt * k, t.accent, "title"),
      8pt * k,
      text(size: 17pt * k, fill: t.muted, [#s.subtitle <ts-title-slide-subtitle>]),
    )
  })
  place(bottom + left, dx: m.left, dy: -m.bottom, by-line(t, s, k))
}

/// Dark full-bleed surface, accent stroke above the title.
#let band-section(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  let d = s.at("depth", default: 1)
  let eltern = s.at("parents", default: ())
  grund(t.strong, "section")
  // Eine Breitengrenze, wie sie die vier anderen Themes schon haben -- ohne
  // sie bekommt der Satz die volle Seitenbreite, um den linken Rand versetzt,
  // und ragt über die rechte Kante; gemessen lief die Elternzeile mitten im
  // Wort aus der Folie, und `overflow` sieht Abschnittsfolien nicht an.
  //
  // Aber nur, wo es Eltern gibt. Der Kasten unbedingt zu setzen legt auch bei
  // Tiefe 1 zwei Gruppen mehr ins SVG, und `theme-default` war danach nicht
  // mehr bytegleich -- dieselbe Falle, an der schon der Entwurf hing. Eine
  // Abschnittsfolie ohne Eltern ist genau die von vorher und bleibt es.
  let rahmen = if eltern.len() > 0 {
    it => block(width: geo.width - m.left - m.right, it)
  } else { it => it }
  place(horizon + left, dx: m.left, rahmen({
    // Built as a list rather than written out, so that at depth 1 exactly the
    // three pieces of before go into `stapel` and the slide is unchanged.
    let teile = (
      zierlinie(62pt * k, 2.5pt * k, t.accent, "section"),
      10pt * k,
      text(..font-args(t.title-font), size: ebenen-groesse(30pt, d, k),
           weight: "bold", fill: lesbar(t.strong, white, t.paper, t.ink),
           [#s.title <ts-section-slide-title>]),
    )
    if eltern.len() > 0 {
      teile = (ebenen-pfad(eltern, t.strong, t, k, white, t.paper, t.ink),
               10pt * k) + teile
    }
    stapel(..teile)
  }))
}

// ── lesson ─────────────────────────────────────────────────────────────────

/// Centered and large, with an accent band across the full width.
#let lesson-title-slide(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  place(top + left, {
    set rect(fill: t.accent, stroke: none)
    [#rect(width: 100%, height: 12pt * k) <ts-title-slide-band>]
  })
  place(center + horizon, dy: -10pt * k, block(width: geo.width - 2 * m.left, {
    set align(center)
    stapel(
      text(..font-args(t.title-font), size: 38pt * k, weight: "bold",
           fill: lesbar(t.paper, t.strong, t.ink),
           [#s.title <ts-title-slide-title>]),
      14pt * k,
      zierlinie(130pt * k, 3pt * k, t.accent, "title"),
      14pt * k,
      text(size: 18pt * k, fill: t.muted, [#s.subtitle <ts-title-slide-subtitle>]),
    )
  }))
  place(bottom + center, dy: -m.bottom, by-line(t, s, k))
}

/// Tinted background, wide accent bar along the left edge.
#let lesson-section(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  let balken = 16pt * k
  // The tinted ground of the section slide. Lightened on a light palette,
  // darkened on a dark one, the same switch `card` and `callout` make: an
  // accent lightened by 88 percent is nearly white, and a full-bleed white
  // section slide in the middle of a dark deck is a flash, not a pause.
  grund(if t.inverted { t.accent.darken(72%) } else { t.accent.lighten(88%) },
        "section")
  place(top + left, {
    set rect(fill: t.accent, stroke: none)
    [#rect(width: balken, height: 100%) <ts-section-slide-bar>]
  })
  let d = s.at("depth", default: 1)
  let eltern = s.at("parents", default: ())
  let boden = if t.inverted { t.accent.darken(72%) } else { t.accent.lighten(88%) }
  place(horizon + left, dx: m.left + balken,
    block(width: geo.width - 2 * m.left - balken, {
      let titel = text(..font-args(t.title-font),
           size: ebenen-groesse(32pt, d, k), weight: "bold",
           fill: lesbar(boden, t.strong, t.ink),
           [#s.title <ts-section-slide-title>])
      // At depth 1 the title stands as bare as before. No `block` around it:
      // in the PDF that changes nothing, but in the HTML it adds a group and
      // fourteen bytes, and the deck of yesterday is then no longer the deck
      // of today.
      if eltern.len() == 0 { titel } else {
        stapel(ebenen-pfad(eltern, boden, t, k, t.strong, t.ink), 8pt * k, titel)
      }
    }))
}

// ── night ──────────────────────────────────────────────────────────────────

/// Everything in the middle, nothing at the edge: in a dark room you only
/// see the bright spots anyway.
#let night-title-slide(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  place(center + horizon, block(width: geo.width * 0.74, {
    set align(center)
    stapel(
      text(..font-args(t.title-font), size: 40pt * k, weight: "bold",
           fill: t.ink, [#s.title <ts-title-slide-title>]),
      16pt * k,
      zierlinie(90pt * k, 2pt * k, t.accent, "title"),
      16pt * k,
      text(size: 17pt * k, fill: t.muted, [#s.subtitle <ts-title-slide-subtitle>]),
    )
  }))
  place(bottom + center, dy: -m.bottom, by-line(t, s, k))
}

/// Two accent lines, with the title in the accent color between them.
#let night-section(t, s, geo) = {
  let k = geo.scale
  let d = s.at("depth", default: 1)
  let eltern = s.at("parents", default: ())
  grund(t.paper, "section")
  place(center + horizon, block(width: geo.width * 0.56, {
    set align(center)
    let teile = (
      zierlinie(100%, 1pt * k, t.accent, "section"),
      18pt * k,
      text(..font-args(t.title-font), size: ebenen-groesse(30pt, d, k),
           weight: "bold", fill: t.accent, [#s.title <ts-section-slide-title>]),
      18pt * k,
      zierlinie(100%, 1pt * k, t.accent, "section"),
    )
    if eltern.len() > 0 {
      teile = (ebenen-pfad(eltern, t.paper, t, k, t.accent, t.ink), 14pt * k) + teile
    }
    stapel(..teile)
  }))
}

// ── plain ──────────────────────────────────────────────────────────────────

/// Only text, left, far down. No stroke, no surface, no color.
#let plain-title-slide(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  place(top + left, dx: m.left, dy: geo.height * 0.42, block(width: geo.width * 0.7, {
    stapel(
      text(..font-args(t.title-font), size: 30pt * k,
           fill: lesbar(t.paper, t.strong, t.ink),
           tracking: 0.3pt * k, [#s.title <ts-title-slide-title>]),
      12pt * k,
      text(size: 15pt * k, fill: t.muted, [#s.subtitle <ts-title-slide-subtitle>]),
    )
  }))
  place(bottom + left, dx: m.left, dy: -m.bottom,
    text(size: 10pt * k, fill: t.muted, [#{
      s.author
      if s.date != none [ · #datum(s.date) ]
    } <ts-title-slide-byline>]))
}

/// The title sits where the slide title would otherwise stand, just at
/// half height.
#let plain-section(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  let d = s.at("depth", default: 1)
  let eltern = s.at("parents", default: ())
  grund(t.paper, "section")
  place(horizon + left, dx: m.left, block(width: geo.width * 0.7, {
    let teile = (
      text(..font-args(t.title-font), size: ebenen-groesse(26pt, d, k),
           fill: lesbar(t.paper, t.strong, t.ink),
           tracking: 0.3pt * k, [#s.title <ts-section-slide-title>]),
      11pt * k,
      zierlinie(40pt * k, 0.8pt * k, t.muted, "section"),
    )
    if eltern.len() > 0 {
      teile = (ebenen-pfad(eltern, t.paper, t, k, t.strong, t.ink), 9pt * k) + teile
    }
    stapel(..teile)
  }))
}

// ── editorial ──────────────────────────────────────────────────────────────

/// A title page: two hairlines, the title between them, the subtitle in
/// italics below.
#let editorial-title-slide(t, s, geo) = {
  let k = geo.scale
  let m = margins(geo)
  grund(t.paper, "title")
  place(center + horizon, dy: -8pt * k, block(width: geo.width * 0.68, {
    set align(center)
    stapel(
      zierlinie(64pt * k, 0.9pt * k, t.accent, "title"),
      18pt * k,
      text(..font-args(t.title-font), size: 34pt * k,
           fill: lesbar(t.paper, t.strong, t.ink),
           tracking: 0.5pt * k, [#s.title <ts-title-slide-title>]),
      12pt * k,
      text(size: 16pt * k, style: "italic", fill: t.muted,
           [#s.subtitle <ts-title-slide-subtitle>]),
      20pt * k,
      zierlinie(64pt * k, 0.9pt * k, t.accent, "title"),
    )
  }))
  place(bottom + center, dy: -m.bottom,
    text(size: 11pt * k, fill: t.muted, tracking: 1.4pt * k, [#upper({
      s.author
      if s.date != none [ · #datum(s.date) ]
    }) <ts-title-slide-byline>]))
}

/// Full-bleed surface in the primary color, title in paper color on top.
#let editorial-section(t, s, geo) = {
  let k = geo.scale
  let d = s.at("depth", default: 1)
  let eltern = s.at("parents", default: ())
  grund(t.strong, "section")
  place(center + horizon, block(width: geo.width * 0.7, {
    set align(center)
    let teile = (
      zierlinie(44pt * k, 0.9pt * k, t.accent, "section"),
      20pt * k,
      text(..font-args(t.title-font), size: ebenen-groesse(30pt, d, k),
           fill: lesbar(t.strong, t.paper, t.ink, white),
           tracking: 0.5pt * k, [#s.title <ts-section-slide-title>]),
    )
    if eltern.len() > 0 {
      teile = (ebenen-pfad(eltern, t.strong, t, k, t.paper, t.ink, white),
               16pt * k) + teile
    }
    stapel(..teile)
  }))
}


// ═══════════════════════════════════════════════════════════════════════════
//  The blueprint
// ═══════════════════════════════════════════════════════════════════════════

/// Builds a theme. Without an argument it produces the default
/// appearance: `themes.default` is exactly that.
///
/// The entries in groups: colors (`paper ink strong accent muted
/// surface border inverted`), typography (`font title-font size
/// title-size weight tracking`), the ordinary slide (`header title-fill
/// rule-size rule-fill head-gap foot-gap band-height box footer
/// footer-rule progress`) and the two whole pictures (`title-slide`,
/// `section`).
///
/// The eight colors are also the entries a *palette* may carry, and that is
/// how a theme is recolored without touching the rest of it. Two of the
/// entries above are colors that are not palette entries, `title-fill` and
/// `rule-fill`, and each may be written either as a color or as a function
/// of the palette, `p => p.strong`. A color stays what it is under every
/// palette; a function is asked again whenever one is applied, and that is
/// what lets the title of a light theme follow into the dark. `rule-fill:
/// none` means the accent and follows it.
///
/// Font sizes: measured against Beamer and Metropolis, where the body
/// text takes up around 3.0% of the slide width and the title 3.9%. The
/// earlier 19pt/23pt were at 2.3% and 2.7%: noticeably smaller than what
/// you would want to read from the back row.
///
/// What the theme draws also carries labels, and those are the second way to
/// reach it. Names follow one scheme, place first and part second. On an
/// ordinary slide `ts-slide-ground`, `ts-slide-header-band`,
/// `ts-slide-header-text`, `ts-slide-header-rule`, `ts-slide-title`,
/// `ts-slide-title-rule`, `ts-slide-footer`, `ts-slide-number`,
/// `ts-slide-footer-rule`, `ts-slide-progress` and `ts-slide-progress-track`;
/// on the title slide `ts-title-slide-ground`, `ts-title-slide-band`,
/// `ts-title-slide-title`, `ts-title-slide-subtitle`, `ts-title-slide-rule`
/// and `ts-title-slide-byline`; on the section slide
/// `ts-section-slide-ground`, `ts-section-slide-bar`,
/// `ts-section-slide-title`, `ts-section-slide-rule` and
/// `ts-section-slide-parent`. A `show` rule on one of them changes type or
/// fill without a key having to exist for it; the keys below stay what they
/// are and keep the arrangement.
///
/// The last of those is the line naming the sections a deeper section hangs
/// under. It exists only from the second structure level on, so a deck at the
/// default `slide-level: 2` never draws it.
///
/// A theme that brings its own `title-slide` or `section` function draws none
/// of those labels, and nothing warns about it. Such a `section` function
/// receives the section record, and there `s.depth` is the heading level and
/// `s.parents` are the titles above it, outermost first. A function that reads
/// neither draws every level alike; nothing breaks, the hierarchy is simply
/// not shown.
///
/// Comments must NOT go into the parameter list: tidy splits it at the
/// commas and expects a colon in every piece; the API reference breaks
/// on that.
#let theme(
  paper: rgb("#fafafa"),
  ink: black,
  strong: rgb("#23303f"),
  accent: rgb("#eb5e28"),
  muted: luma(45%),
  surface: white,
  border: luma(84%),
  inverted: false,
  font: none,
  title-font: none,
  size: 24pt,
  title-size: 31pt,
  weight: "bold",
  tracking: 0pt,
  header: "band",
  title-fill: p => lesbar(p.strong, white, p.paper, p.ink),
  rule-size: 0pt,
  rule-fill: none,
  head-gap: 20pt,
  foot-gap: 24pt,
  band-height: 66pt,
  footer: "fraction",
  footer-rule: 0pt,
  progress: "bar",
  box: "bar",
  title-slide: band-title-slide,
  section: band-section,
) = {
  // A typo in one of these three would otherwise simply do nothing: the
  // footer would stay missing, and nobody would know why.
  assert(header in ("band", "plain", "run"),
         message: "typstage: theme(header: ..) is \"band\", \"plain\" or \"run\"")
  assert(footer in ("fraction", "number", "center", "none"),
         message: "typstage: theme(footer: ..) is \"fraction\", \"number\", "
           + "\"center\" or \"none\"")
  assert(progress in ("bar", "top", "tick", "none"),
         message: "typstage: theme(progress: ..) is \"bar\", \"top\", \"tick\" "
           + "or \"none\"")
  assert(box in ("bar", "label"),
         message: "typstage: theme(box: ..) is \"bar\" or \"label\"")
  (
  paper: paper, ink: ink, strong: strong, accent: accent, muted: muted,
  surface: surface, border: border, inverted: inverted,
  font: font, title-font: if title-font == none { font } else { title-font },
  size: size, title-size: title-size, weight: weight, tracking: tracking,
  header: header, title-fill: title-fill,
  rule-size: rule-size, rule-fill: rule-fill,
  head-gap: head-gap, foot-gap: foot-gap, band-height: band-height,
  footer: footer, footer-rule: footer-rule, progress: progress, box: box,
  title-slide: title-slide, section: section,
  )
}


// ═══════════════════════════════════════════════════════════════════════════
//  The five
// ═══════════════════════════════════════════════════════════════════════════

/// The bundled themes: `themes.default`, `themes.lesson`, `themes.night`,
/// `themes.plain`, `themes.editorial`.
///
/// They are made for different occasions, not the same slide in five
/// colors: the title sits sometimes in a bar, sometimes free, sometimes
/// under a line; the progress indicator grows, or is missing
/// entirely.
#let themes = (
  // The talk in a bright hall. The look typstage has always had, and the
  // default: dark title bar, orange progress.
  default: theme(),

  // The classroom. Larger text, no bar: the title sits on the paper and
  // is underlined by a bold stroke; below, a marker travels along its
  // track, so the class can see how far into the lesson they are.
  // Modeled on German maths textbooks. The colors were not chosen but
  // measured from a sample page of "Fundamente der Mathematik" (Cornelsen,
  // 10th grade): the vermilion of the headings and the note boxes, the
  // cyan blue of the examples and the header line, plus the two tints.
  // What carries meaning there is neither size nor boldness, but *color
  // as meaning*: warm for "this you must know", cool for "this is what it
  // looks like". That is why the heading here is smaller than before and
  // the line beneath it a hairline instead of a bar.
  lesson: theme(
    paper: white,
    ink: rgb("#16181c"),
    // Slightly deeper than the measured #d8391a: on a screen a vermilion
    // glows stronger than on paper.
    strong: rgb("#c1361c"),
    accent: rgb("#2b7fb8"),
    muted: rgb("#767b84"),
    // The tint of the note box. Measured it was #fdf0df; on a slide such
    // a box covers many times the area it has in the book, and the same
    // saturation quickly looks garish there. Hence lighter.
    surface: rgb("#fdf6ee"),
    border: rgb("#f0e2d2"),
    font: ("Source Sans 3", "Source Sans Pro", "Open Sans", "DejaVu Sans"),
    size: 20pt,
    title-size: 24pt,
    // Semibold instead of bold. The heading already stands in its own
    // color and its own size; boldness would be a third signal for the
    // same thing.
    weight: 600,
    // Written as the palette's `strong` rather than as the color itself. The
    // value is the same one; said this way the heading follows into any
    // palette instead of staying vermilion on a dark ground.
    title-fill: p => lesbar(p.paper, p.strong, p.ink),
    // No line under the title. In the book, the colored line belongs to
    // the page's running header, not to the heading; placed underneath it
    // turns two things into one in two colors. The heading carries its
    // hierarchy in its color; it needs nothing more.
    rule-size: 0pt,
    head-gap: 26pt,
    // Header instead of footer: slide number on the left, section on the
    // right, a hairline underneath, exactly like the running header of a
    // textbook page. That drops both at the bottom. The number already
    // stands at the top, and the traveling progress stroke never
    // explained anything the header does not say better: it names the
    // chapter you are in, not merely the fraction.
    header: "run",
    // The hairline under the running header. Same value as the default, said
    // out loud so it follows a palette.
    rule-fill: p => p.accent,
    footer: "none",
    progress: "none",
    box: "label",
    title-slide: lesson-title-slide,
    section: lesson-section,
  ),

  // The dimmed room. Deep background, light text, cool accent; the
  // progress sits as a thin line along the top edge, where it does not
  // dazzle.
  night: theme(
    paper: rgb("#0f1319"),
    ink: rgb("#e6ebf2"),
    strong: rgb("#2c3644"),
    accent: rgb("#5ec8f2"),
    muted: rgb("#8f9bab"),
    surface: rgb("#1a212b"),
    border: rgb("#2e3947"),
    inverted: true,
    font: ("Inter", "Helvetica Neue", "DejaVu Sans"),
    size: 19pt,
    title-size: 24pt,
    header: "plain",
    // The cyan carries the title on the deck's own dark ground, 9.77 to 1.
    // On an inverted slide the ground becomes this palette's ink, and there
    // the same cyan measures 1.59 to 1 -- the pairing the contrast report
    // lists as night's failing one. So it is asked for rather than named, and
    // on the dark ground the answer is still the cyan, byte for byte.
    title-fill: p => lesbar(p.paper, p.accent, p.ink),
    head-gap: 16pt,
    footer: "number",
    progress: "top",
    title-slide: night-title-slide,
    section: night-section,
  ),

  // As little as possible. White, black, one gray: no color, no surface,
  // no progress. The title is small and leaves the body plenty of room;
  // what you see is the content.
  plain: theme(
    paper: white,
    ink: black,
    strong: luma(12%),
    accent: luma(12%),
    muted: luma(55%),
    surface: white,
    border: luma(86%),
    font: ("Helvetica Neue", "Arial", "DejaVu Sans"),
    size: 18pt,
    title-size: 17pt,
    weight: "medium",
    tracking: 0.8pt,
    header: "plain",
    // luma(30%) written as a step off the ink, because `black.lighten(30%)`
    // *is* luma(30%) to the byte. On a dark palette the same expression walks
    // the other way and lifts the title off the ground instead of sinking it.
    title-fill: p => p.ink.lighten(30%),
    head-gap: 34pt,
    foot-gap: 20pt,
    footer: "number",
    progress: "none",
    title-slide: plain-title-slide,
    section: plain-section,
  ),

  // With character: laid paper, an old-style serif, hairlines. The title
  // sits above a fine line, the page number centered under a second one:
  // a book, not a slide.
  editorial: theme(
    paper: rgb("#f7f2e6"),
    ink: rgb("#2a2622"),
    strong: rgb("#7b2d26"),
    accent: rgb("#b4894a"),
    muted: rgb("#8a7f70"),
    surface: rgb("#fffdf7"),
    border: rgb("#ded2ba"),
    font: ("Iowan Old Style", "Charter", "Libertinus Serif"),
    title-font: ("Optima", "Palatino", "Libertinus Serif"),
    // 20pt, not 18pt. Nominally, editorial was tied with plain as the
    // smallest theme, but in reality it was the smallest by far: Iowan
    // sets its x-height at 0.48 of the font size, Inter at 0.55. Measured
    // on a rendered "x", that was 8.64pt against 10.44pt in night and
    // 11.64pt in default, so a quarter smaller than the largest theme,
    // even though the number next to it differed by only six points. At
    // 20pt it is 9.60pt, the same as in lesson (9.72pt). The title grows
    // along with it, otherwise its ratio to the body would fall from 1.33
    // to 1.2.
    size: 20pt,
    title-size: 26pt,
    weight: "regular",
    tracking: 0.5pt,
    header: "plain",
    title-fill: p => lesbar(p.paper, p.strong, p.ink),
    rule-size: 0.9pt,
    rule-fill: p => p.border,
    head-gap: 22pt,
    foot-gap: 30pt,
    footer: "center",
    footer-rule: 0.7pt,
    progress: "none",
    title-slide: editorial-title-slide,
    section: editorial-section,
  ),
)


/// The theme with a palette laid over it, and optionally inverted.
///
/// The one place where a theme and a palette meet. `presentation` calls it for
/// every deck, with an empty palette when none was given, and once more per
/// slide that carries `invert: true`.
///
/// Three steps, in this order. The theme's own eight colors are read out as a
/// palette and the given one is written over it, entry by entry, so a palette
/// of `(accent: blue)` changes the accent and nothing else. If `invert` is
/// set, that palette is turned around by `invert-palette`. Only then are
/// `title-fill` and `rule-fill` resolved, so a theme that wrote them as
/// functions sees the colors the slide will actually be set in.
#let mit-palette(t, p, invert: false) = {
  let farben = (:)
  for k in palette-keys { farben.insert(k, t.at(k)) }
  farben = farben + p
  if invert { farben = invert-palette(farben) }
  let aufloesen(v) = if type(v) == function { v(farben) } else { v }
  t + farben + (
    title-fill: aufloesen(t.title-fill),
    // `none` has meant "the accent" since the first version and keeps meaning
    // it. Resolved here rather than in `theme()` so that it follows a palette
    // instead of freezing the accent the theme was built with.
    rule-fill: if t.rule-fill == none { farben.accent } else { aufloesen(t.rule-fill) },
  )
}


/// The theme currently being set under.
///
/// `card` and `callout` sit *inside* the slide body and know nothing
/// about the presentation on their own. Without this state, every card
/// would have to be handed its colors; this way it fetches them itself.
/// `presentation` writes it once, right at the start, and anyone using a
/// card outside a presentation gets the default.
#let theme-state = state("typstage-theme", mit-palette(themes.default, (:)))
