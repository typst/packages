// ===========================================================================
//  chalkdeck — classroom-styled presentations for Typst.
//
//  A small slide package built around DRAWN backdrops: a classroom
//  blackboard with its wooden frame and chalk tray, a punched notebook
//  page, graph paper, or nothing at all. Every colour is a palette key, so
//  the same woodwork gives a green board, a whiteboard, a navy one or an
//  oak frame.
//
//    #import "@preview/chalkdeck:0.1.0": *
//    #show: chalkdeck.with(theme: "blackboard", title: [..], author: [..])
//    #slide(title: [Slide 1])[ .. ]
//
//  Right-to-left is a first-class case, not an afterthought: titles,
//  bullets, block rules and the footline all follow `text.dir`, and the
//  Arabic examples in `examples/` are part of the test suite.
//
//  The blackboard backdrop is converted coordinate for coordinate from the
//  TikZ source of Kazuki Maeda's `kmbeamer` Blackboard theme (MIT), not
//  measured off a screenshot; its palette is `kmbeamer_color.sty` verbatim.
//
//  Copyright (c) 2026 FERGOUS Abdelhak. MIT licence.
// ===========================================================================

// ---------------------------------------------------------------------------
//  self-contained drawing primitives
//
//  The package has no dependencies: these four are all it needs, and they
//  are small enough that vendoring them beats pulling in a geometry
//  library. Coordinates are in CENTIMETRES with y running UP, which is why
//  every drawing takes a `flip` — the page's y runs down.
// ---------------------------------------------------------------------------

#let _arc-pts(centre, r, a0, a1, n: 40) = range(n + 1).map(i => {
  let a = (a0 + (a1 - a0) * i / n) * 1deg
  (centre.at(0) + r * calc.cos(a), centre.at(1) + r * calc.sin(a))
})

#let _circle-pts(centre, r, n: 64) = _arc-pts(centre, r, 0, 360, n: n)

/// One or more polylines, as a single `curve`.
#let _lines(paths, flip: 0cm, closed: false, ..style) = {
  let segs = ()
  for path in paths {
    if path.len() < 2 { continue }
    let p0 = path.first()
    segs.push(curve.move((p0.at(0) * 1cm, flip - p0.at(1) * 1cm)))
    for p in path.slice(1) {
      segs.push(curve.line((p.at(0) * 1cm, flip - p.at(1) * 1cm)))
    }
    if closed { segs.push(curve.close(mode: "straight")) }
  }
  if segs.len() == 0 { return none }
  curve(..style, ..segs)
}

/// Fill a set of contours as one region.
#let _fill(contours, flip: 0cm, ..style) = _lines(
  contours, flip: flip, closed: true, fill-rule: "even-odd",
  stroke: none, ..style)

#let _cm(l) = if type(l) == length { l / 1cm } else { l }

/// The languages written right-to-left, named once so the backdrop, the
/// margin and the furniture can never disagree about which edge leads.
#let _rtl-langs = ("ar", "he", "fa", "ur", "ps", "syr", "dv", "ku", "yi")

/// True when the surrounding text runs right-to-left.
#let is-rtl() = {
  if text.dir == auto { _rtl-langs.contains(text.lang) } else { text.dir == rtl }
}

// ---------------------------------------------------------------------------
//  palettes
// ---------------------------------------------------------------------------

/// `kmbeamer_color.sty`, verbatim — the 28 names its themes draw on.
#let chalk-colours = (
  gray33:       rgb("#333333"),
  midnightblue: rgb("#00152D"),
  navyblue:     rgb("#1F2F54"),
  ultramarine:  rgb("#4B64A1"),
  water:        rgb("#A9CEEC"),
  sepia:        rgb("#4A3B2A"),
  brown:        rgb("#763900"),
  goldbrown:    rgb("#C47600"),
  satsuma:      rgb("#FA8000"),
  deepgreen:    rgb("#005731"),
  bottlegreen:  rgb("#264435"),
  tokiwa:       rgb("#357C4C"),
  indigo:       rgb("#234794"),
  chartreuse:   rgb("#7FFF00"),
  kerria:       rgb("#FFA500"),
  vermilion:    rgb("#ED514E"),
  madder:       rgb("#B22D35"),
  maroon:       rgb("#682A2B"),
  tomato:       rgb("#FF6347"),
  snow:         rgb("#F1F1F1"),
  whiteee:      rgb("#EEEEEC"),
  midyellow:    rgb("#FAD43A"),
  lemonchiffon: rgb("#FFFACD"),
  gold:         rgb("#FFD700"),
  concrete:     rgb("#F3F3F3"),
  denim:        rgb("#1776C7"),
  tamarillo:    rgb("#A31515"),
  jellybean:    rgb("#247690"),
)

/// The keys every palette carries.
///
///   bg          the page behind everything
///   fg          body text
///   structure   headings, bullets, rules — beamer's `structure`
///   alert       `slide-alert`
///   title       the title on the title slide
///   muted       the footline
///
/// A board backdrop uses four more: `board`, `frame-lit`, `frame-dim` and
/// `plate`. They are ignored by the flat backdrops, so one dictionary
/// serves every theme.
#let chalk-palettes = (
  // kmbeamer's Blackboard, verbatim
  blackboard: (
    bg:        chalk-colours.bottlegreen,
    fg:        chalk-colours.snow,
    structure: chalk-colours.water,
    alert:     chalk-colours.midyellow,
    title:     chalk-colours.water,
    muted:     chalk-colours.water,
    board:     chalk-colours.bottlegreen,
    frame-lit: chalk-colours.kerria,
    frame-dim: chalk-colours.brown,
    plate:     chalk-colours.goldbrown,
  ),
  // a whiteboard, the same woodwork in aluminium
  whiteboard: (
    bg:        rgb("#F7F7F4"),
    fg:        rgb("#1A1A1A"),
    structure: rgb("#1776C7"),
    alert:     rgb("#A31515"),
    title:     rgb("#1776C7"),
    muted:     rgb("#7A7A7A"),
    board:     rgb("#F7F7F4"),
    frame-lit: rgb("#D8DCE0"),
    frame-dim: rgb("#8E979E"),
    plate:     rgb("#B9C0C6"),
  ),
  // kmbeamer's DarkConsole
  darkconsole: (
    bg:        chalk-colours.gray33,
    fg:        chalk-colours.whiteee,
    structure: chalk-colours.gold,
    alert:     chalk-colours.tomato,
    title:     chalk-colours.chartreuse,
    muted:     chalk-colours.gold,
  ),
  // kmbeamer's LightConsole
  lightconsole: (
    bg:        chalk-colours.concrete,
    fg:        black,
    structure: chalk-colours.denim,
    alert:     chalk-colours.tamarillo,
    title:     chalk-colours.denim,
    muted:     chalk-colours.denim,
  ),
  // kmbeamer's Notebook
  notebook: (
    bg:        rgb("#FFFFF0"),          // ivory
    fg:        black,
    structure: rgb("#4169E1"),          // royalblue
    alert:     rgb("#DC143C"),          // crimson
    title:     rgb("#4169E1"),
    muted:     rgb("#00336F"),
    rule:      rgb("#00336F"),          // the ruled lines
  ),
  // For paper. No backdrop, no flooded background, and colours chosen to
  // survive a monochrome laser: the structure blue and the alert red are
  // dark enough to stay legible when they come out as greys, and nothing
  // relies on a coloured field behind the text. A deck printed from
  // `blackboard` costs a cartridge of toner and reads worse than this.
  print: (
    bg:        white,
    fg:        black,
    structure: rgb("#1A3E6E"),
    alert:     rgb("#A81E14"),
    title:     rgb("#1A3E6E"),
    muted:     rgb("#4A4A4A"),
    rule:      rgb("#1A3E6E"),
  ),
  // a slate-grey deck of our own
  slate: (
    bg:        rgb("#22262B"),
    fg:        rgb("#E8EAED"),
    structure: rgb("#7FB2E5"),
    alert:     rgb("#FFB454"),
    title:     rgb("#7FB2E5"),
    muted:     rgb("#8A929B"),
    board:     rgb("#22262B"),
    frame-lit: rgb("#4A5057"),
    frame-dim: rgb("#14171A"),
    plate:     rgb("#31373E"),
  ),
)

/// Which backdrop each theme uses by default.
#let chalk-backdrops = (
  blackboard:   "board",
  whiteboard:   "board",
  slate:        "board",
  darkconsole:  "plain",
  lightconsole: "plain",
  notebook:     "notebook",
  print:        none,
)

#let _config = state("chalkdeck-config", (
  palette: chalk-palettes.blackboard,
  muted: chalk-colours.water,
  footer: true,
  clock: none,
))

// ---------------------------------------------------------------------------
//  the clock
// ---------------------------------------------------------------------------

/// powerdot's `clock` option puts a small digital clock in the corner "which
/// you can use to check the time left for your presentation". Its clock is
/// NOT typeset text: reading `powerdot.dtx`, it is a PDF form field driven
/// by Acrobat JavaScript — `app.setInterval("pdshowtime()", 1000)` rewriting
/// a `/Widget` annotation every second. It therefore ticks in Acrobat and
/// shows nothing anywhere else.
///
/// Typst can emit neither: it has no form-field markup, and it deliberately
/// does not know the time — `datetime.today()` gives the date, but `.hour()`
/// is `none`. From INSIDE Typst a ticking clock is therefore impossible.
///
/// But the trick is a property of the PDF, not of the typesetter, so it can
/// be applied from outside. Both clocks are offered:
///
/// - the default PACES the talk. Given its length it prints, on each slide,
///   the time you should be at when you reach it: glance at the corner,
///   glance at your watch. No viewer support, works on paper.
/// - `(live: true)` leaves an invisible `#CLK#` marker in the corner, and
///   `tools/pdfclock.py` covers each marker with a read-only `/Widget` and
///   attaches `app.setInterval` — powerdot's own mechanism, with powerdot's
///   own limitation: it ticks in Acrobat and is inert elsewhere.
#let _fmt-mmss(secs) = {
  let s = calc.round(calc.max(0, secs))
  let h = calc.floor(s / 3600)
  let m = calc.floor(calc.rem(s, 3600) / 60)
  let r = calc.rem(s, 60)
  let pad(n) = if n < 10 { "0" + str(n) } else { str(n) }
  if h > 0 { str(h) + ":" + pad(m) + ":" + pad(r) } else { str(m) + ":" + pad(r) }
}

/// Render the clock for slide `n` of `total`.
///
/// `spec` is a duration (the length of the talk), a dictionary
/// `(total: 45min, mode: "elapsed" | "remaining" | "both")`, or a function
/// `(n, total) => content` for a caller who wants something else entirely.
#let _clock-body(spec, n, total, p) = {
  if type(spec) == function { return spec(n, total) }
  let cfg = if type(spec) == dictionary { spec } else { (total: spec) }
  // A LIVE clock is a PDF form field, and Typst cannot write one. What it
  // can do is leave a marker the size and shape of the clock: transparent
  // text, so it is in the content stream and `pdfclock.py` can find it with
  // `search_for`, but nothing shows on paper. The post-pass covers each
  // marker with a `/Widget` and attaches the `app.setInterval` script — the
  // very mechanism powerdot uses. Without the post-pass the deck is simply
  // a deck with an empty corner.
  if cfg.at("live", default: false) {
    return text(fill: rgb(0, 0, 0, 0), "#CLK#")
  }
  let len = cfg.at("total", default: none)
  if len == none { return none }
  // Typst has no `45min` literal — it is `duration(minutes: 45)`, which is a
  // mouthful for the commonest thing anyone will write. A plain number is
  // taken as MINUTES so `clock: 45` says what it looks like.
  if type(len) in (int, float) { len = duration(minutes: int(len)) }
  let mode = cfg.at("mode", default: "elapsed")
  // The pace is measured in slides ARRIVED at: you reach slide 1 at 0:00 and
  // slide n after (n - 1) of the deck's `total` slides have been spoken.
  let secs = len.seconds() * calc.max(0, n - 1) / calc.max(1, total)
  if mode == "remaining" { _fmt-mmss(len.seconds() - secs) }
  else if mode == "both" {
    _fmt-mmss(secs) + " / " + _fmt-mmss(len.seconds())
  } else { _fmt-mmss(secs) }
}

#let slide-section-no = counter("chalkdeck-section")
#let slide-no = counter("chalkdeck-slide-no")
#let slide-section-name = state("chalkdeck-section-name", none)

// ---------------------------------------------------------------------------
//  backdrops
// ---------------------------------------------------------------------------

/// The classroom board: frame, plate, slate, grid and chalk tray.
///
/// Converted coordinate for coordinate from `kmbeamer`'s own TikZ source
/// (see §13x), then given its colours from the palette so the same woodwork
/// serves a green board, a whiteboard or anything else.
#let backdrop-board(w, h, p, grid: true, tray: true) = {
  let flip = h * 1cm
  let sx = w / 12.8
  let sy = h / 9.6
  let P(x, y) = (x / 10 * sx, h - (-y) / 10 * sy)
  let quad(pts, fill) = place(top + left,
    _fill((pts.map(q => P(q.at(0), q.at(1))),), flip: flip, fill: fill))
  let rect(x0, y0, x1, y1, fill) = quad(
    ((x0, y0), (x1, y0), (x1, y1), (x0, y1)), fill)

  let board = p.at("board", default: p.bg)
  let lit = p.at("frame-lit", default: chalk-colours.kerria)
  let dim = p.at("frame-dim", default: chalk-colours.brown)
  let plate = p.at("plate", default: chalk-colours.goldbrown)

  rect(0, 0, 128, -96, board)
  // outer frame — the two dark pieces are MITRED, as upstream draws them:
  // the light falls from the top left, so the far edges are in shadow and
  // their corners are cut at 45°.
  rect(0, 0, 128, -1, lit)
  rect(0, 0, 1, -96, lit)
  quad(((0, -96), (1, -95), (128, -95), (128, -96)), dim)
  quad(((128, 0), (127, -1), (127, -96), (128, -96)), dim)
  // frame plate
  rect(1, -1, 127, -3, plate)
  rect(1, -1, 3, -95, plate)
  rect(125, -1, 127, -95, plate)
  rect(1, -93, 127, -95, plate)
  // inner frame
  rect(3, -3, 125, -4, dim)
  rect(3, -3, 4, -93, dim)
  quad(((3, -93), (4, -92), (125, -92), (125, -93)), lit)
  quad(((125, -3), (124, -4), (124, -93), (125, -93)), lit)

  // the 1 mm ruling: `[grid][step=1mm,color=bottlegreen!102]`, two per cent
  // off the board. Not meant to be read, only to give the surface a tooth.
  if grid {
    let g = if luma(board).components().first() > 50% {
      board.darken(4%)
    } else { board.lighten(6%) }
    let x = 4.0
    while x < 124 {
      place(top + left, _lines(((P(x, -4), P(x, -92)),), flip: flip,
        stroke: (paint: g, thickness: 0.2pt)))
      x = x + 1
    }
    let y = 4.0
    while y < 92 {
      place(top + left, _lines(((P(4, -y), P(124, -y)),), flip: flip,
        stroke: (paint: g, thickness: 0.2pt)))
      y = y + 1
    }
  }

  if tray {
    rect(106.5, -91, 117.5, -93, chalk-colours.navyblue)
    rect(106, -89.5, 118, -91, chalk-colours.satsuma)
    rect(111, -91, 113, -88, chalk-colours.sepia)
    for cx in (107, 109.5, 112, 114.5, 117) {
      place(top + left, _fill((_circle-pts(P(cx, -90.25), 0.04 * sx,
        n: 18),), flip: flip, fill: chalk-colours.deepgreen))
    }
    for (x0, x1, col) in ((70, 80, chalk-colours.snow),
                          (82, 92, chalk-colours.midyellow),
                          (94, 104, chalk-colours.water)) {
      rect(x0, -91.5, x1, -92.25, col)
      rect(x0, -92.25, x1, -93, luma(140))
    }
  }
}

/// Nothing but the page colour.
#let backdrop-plain(w, h, p) = {
  place(top + left, rect(width: w * 1cm, height: h * 1cm, fill: p.bg))
}

/// A sheet of ruled paper with a punched margin, after kmbeamer's Notebook.
///
/// Upstream rules three heavy lines — two under the header, one above the
/// footer — and punches a column of holes down the leading edge every
/// 1 em. The holes are drawn as a shaded circle with a lighter crescent, so
/// the sheet reads as pierced rather than spotted.
///
/// Every measurement here is quoted for the reference sheet (9.6 cm tall)
/// and then multiplied by `unit`. That is not decoration: the rules are
/// furniture the TEXT has to clear, and a backdrop whose furniture stays
/// 0.62 cm from the top while the sheet shrinks to a gallery thumbnail
/// lands its two header rules straight through the first line. Scaling the
/// whole sheet keeps the clearance a constant FRACTION, so the same
/// backdrop is safe at any size. `nb-metrics` publishes the numbers the
/// margin is computed from, so the two can never drift apart.
#let nb-metrics = (
  head: 0.62,     // first header rule, from the top
  head2: 0.80,    // second header rule, from the top
  foot: 0.80,     // the footer rule, from the bottom
  gap: 0.35,      // clearance between the last rule and the text
  hole-x: 0.52,   // centre of the punched column
  hole-r: 0.115,
  pitch: 0.62,    // upstream's 1 em
  inset: 1.15,    // where the ruling starts, past the holes
  ref: 9.6,       // the height all of the above is quoted for
)

#let backdrop-notebook(w, h, p, unit: auto, mirror: false) = {
  let m = nb-metrics
  let u = if unit != auto { unit } else { h / m.ref }
  let flip = h * 1cm
  let col = p.at("rule", default: p.structure)
  // A punched sheet is held by its LEADING edge, so under `dir: rtl` the
  // holes belong on the right; `mirror` flips x about the sheet's middle.
  let X(x) = if mirror { w - x } else { x }
  place(top + left, rect(width: w * 1cm, height: h * 1cm, fill: p.bg))
  // a hairline still has to read on paper, so the stroke has a floor
  let th = calc.max(0.5, 1.0 * u) * 1pt
  let line(y) = place(top + left,
    _lines(((( X(m.inset * u), y), (X(w - 0.5 * u), y)),),
      flip: flip, stroke: (paint: col, thickness: th)))
  // The header pair sits ABOVE the text, so the top margin must clear it —
  // see `chalkdeck`, where the notebook backdrop gets its own margin. Ruling
  // them at the same height as the title is what made the two collide.
  line(h - m.head * u)
  line(h - m.head2 * u)
  line(m.foot * u)
  // the punched holes, every 0.62 cm as upstream's 1 em
  let pitch = m.pitch * u
  let n = int((h - 1.0 * u) / pitch)
  for i in range(n) {
    let cy = h - (m.head - 0.07) * u - i * pitch
    if cy < 0.45 * u { continue }
    place(top + left,
      _fill((_circle-pts((X(m.hole-x * u), cy), m.hole-r * u, n: 22),),
        flip: flip, fill: p.bg.darken(24%)))
    place(top + left,
      _fill((_circle-pts((X(m.hole-x * u), cy + 0.02 * u), 0.095 * u,
        n: 22),), flip: flip, fill: p.bg.lighten(45%)))
  }
}

/// Faint graph paper.
#let backdrop-grid(w, h, p, step: 0.5) = {
  let flip = h * 1cm
  place(top + left, rect(width: w * 1cm, height: h * 1cm, fill: p.bg))
  let g = if luma(p.bg).components().first() > 50% { p.bg.darken(7%) }
           else { p.bg.lighten(9%) }
  let x = step
  while x < w {
    place(top + left, _lines((((x, 0.0), (x, h)),), flip: flip,
      stroke: (paint: g, thickness: 0.3pt)))
    x = x + step
  }
  let y = step
  while y < h {
    place(top + left, _lines((((0.0, y), (w, y)),), flip: flip,
      stroke: (paint: g, thickness: 0.3pt)))
    y = y + step
  }
}

// ---------------------------------------------------------------------------
//  the document
// ---------------------------------------------------------------------------

/// The paper sizes a deck can be cut to, in centimetres.
///
/// `4-3` is upstream's own 128 x 96 mm and stays the reference: the board is
/// drawn on that canvas and scaled to whatever is asked for. The screen
/// shapes keep its 9.6 cm height so a deck changes shape without changing
/// type size; the paper sizes are the real ISO/US sheets, landscape, for a
/// deck that is going to be printed or handed out as a PDF.
#let chalk-papers = (
  "4-3":    (12.8, 9.6),     // upstream, 128 x 96 mm
  "16-9":   (16.0, 9.0),
  "16-10":  (15.36, 9.6),
  "3-2":    (14.4, 9.6),
  "5-4":    (12.0, 9.6),
  "1-1":    (9.6, 9.6),
  "a4":     (29.7, 21.0),
  "a5":     (21.0, 14.8),
  "letter": (27.94, 21.59),
  "b5":     (25.0, 17.6),
)

/// Resolve `ratio:` to a `(width, height)` pair in centimetres.
///
/// Accepts a name from `chalk-papers`, a `(w, h)` array of lengths or plain
/// numbers-as-centimetres, or a dictionary `(width:, height:)`. An unknown
/// NAME is an error rather than a silent fallback: `ratio: "16-10"` used to
/// come out 4:3, and a deck that quietly ignores what it was asked for is
/// worse than one that refuses.
#let _paper(r) = {
  if type(r) == str {
    let k = lower(r).replace(":", "-").replace("x", "-")
    assert(k in chalk-papers,
      message: "chalkdeck: unknown paper " + r + " — one of "
        + chalk-papers.keys().join(", ") + ", or a (width, height) pair")
    chalk-papers.at(k)
  } else if type(r) == array {
    assert(r.len() == 2, message: "chalkdeck: ratio must be (width, height)")
    (_cm(r.first()), _cm(r.last()))
  } else if type(r) == dictionary {
    (_cm(r.width), _cm(r.height))
  } else {
    panic("chalkdeck: ratio must be a name, an array or a dictionary")
  }
}

/// A deck of slides.
///
///   theme      one of `slide-palettes`; sets palette, backdrop and fonts
///   palette    a dictionary MERGED into the theme's — `(bg: navy)` is
///              enough to recolour the board and nothing else
///   backdrop   "board" | "plain" | "notebook" | "grid" | none, or a
///              function `(w, h, palette) => content`
///   ratio      a name from `chalk-papers` ("4-3", "16-9", "a4", …), or a
///              size of your own: `(20cm, 12cm)` or `(width: .., height: ..)`
///   clock      a clock in the top corner: a duration (`45min`), a
///              dictionary `(total: 45min, mode: "elapsed"|"remaining"|
///              "both")`, or `(n, total) => content`. By default it PACES
///              the talk — Typst has no access to the time of day. For a
///              real ticking clock pass `(live: true)` and run the deck
///              through `tools/pdfclock.py`, which adds the PDF form field
///              and JavaScript that powerdot uses.
#let chalkdeck(
  title: none,
  subtitle: none,
  author: none,
  institute: none,
  date: none,
  theme: "blackboard",
  palette: (:),
  backdrop: auto,
  grid: true,
  tray: true,
  ratio: "4-3",
  size: auto,
  font: ("FreeSans", "DejaVu Sans"),
  mono: ("FreeMono", "DejaVu Sans Mono"),
  lang: "en",
  dir: auto,
  margin: auto,
  footer: true,
  clock: none,
  body,
) = {
  // A palette is MERGED, not replaced: the common wish is "this theme, but
  // a different background", and spelling out ten keys to change one is no
  // kind of customisation.
  let base = chalk-palettes.at(theme, default: chalk-palettes.blackboard)
  let p = base + palette
  let bd = if backdrop != auto { backdrop }
           else { chalk-backdrops.at(theme, default: "plain") }
  let (w, h) = _paper(ratio)
  // Resolved once: the backdrop's furniture and the text margin must agree
  // about which edge leads, and `is-rtl()` needs a context the page setup
  // does not have.
  let r2l-doc = if dir != auto { dir == rtl } else { _rtl-langs.contains(lang) }

  // The board eats 4 mm of woodwork on every side; a flat backdrop does not,
  // so the text margin follows the backdrop rather than being one number.
  //
  // The board's woodwork is drawn on the 12.8 x 9.6 canvas and SCALED, so a
  // margin quoted in centimetres only clears it at one size: on A4 the frame
  // grows to 9.3 mm and a fixed 9 mm margin puts the text under the wood.
  // The clearance is therefore a fraction of the sheet, exactly as the
  // notebook's is, with a floor so a tiny deck still has a gutter.
  let m = if margin != auto { margin }
          else if bd == "board" {
            let sx = w / 12.8
            let sy = h / 9.6
            (left: calc.max(0.55, 0.9 * sx) * 1cm,
             right: calc.max(0.55, 0.9 * sx) * 1cm,
             top: calc.max(0.55, 1.0 * sy) * 1cm,
             bottom: calc.max(0.65, 1.15 * sy) * 1cm)
          } else if bd == "notebook" {
            // Clears the punched column on the leading edge and the two
            // header rules at the top — READ OFF `nb-metrics` rather than
            // typed again, so a change to the ruling moves the text with
            // it. The margin mirrors under `dir: rtl` because the holes do.
            let u = h / nb-metrics.ref
            let far = (nb-metrics.inset + 0.30) * u * 1cm
            let near = 0.9cm
            (left: if r2l-doc { near } else { far },
             right: if r2l-doc { far } else { near },
             top: (nb-metrics.head2 + nb-metrics.gap) * u * 1cm,
             bottom: (nb-metrics.foot + nb-metrics.gap) * u * 1cm)
          } else {
            // a bare sheet has no furniture to clear, but a margin that
            // stays at 1 cm looks starved on A4 and cramped on a square
            (x: calc.max(0.6, 1.0 * w / 12.8) * 1cm,
             y: calc.max(0.6, 0.95 * h / 9.6) * 1cm)
          }

  let draw = if type(bd) == function { bd }
             else if bd == "board" {
               (w2, h2, p2) => backdrop-board(w2, h2, p2, grid: grid,
                 tray: tray)
             }
             else if bd == "notebook" {
               (w2, h2, p2) => backdrop-notebook(w2, h2, p2,
                 mirror: r2l-doc)
             }
             else if bd == "grid" { backdrop-grid }
             else if bd == none { (w2, h2, p2) => none }
             else { backdrop-plain }

  // A slide is read whole, so the type is a fraction of the sheet, not an
  // absolute size. Scaling UP only: the screen shapes all stand about 9.6 cm
  // tall and keep their 11 pt exactly as before, while an A4 handout gets
  // type in proportion to its paper instead of 11 pt lost on a big page.
  let sz = if size != auto { size }
           else { 11pt * calc.max(1.0, h / 9.6) }

  set text(font: font, size: sz, lang: lang, fill: p.fg,
    ..(if dir != auto { (dir: dir) } else { () }))
  // `raw` has no `font` key; the monospace family is a text rule
  show raw: set text(font: mono)
  set par(justify: false, leading: 0.72em)
  _config.update(c => c + (palette: p, muted: p.at("muted",
    default: p.structure), footer: footer, clock: clock))

  set page(width: w * 1cm, height: h * 1cm, margin: m,
    fill: p.bg, background: draw(w, h, p))

  if title != none {
    slide-no.step()
    page[
      #v(1fr)
      #align(center, {
        text(fill: p.at("title", default: p.structure), weight: "bold",
          size: 1.35em, title)
        if subtitle != none {
          linebreak(); v(0.25em)
          text(size: 0.82em, subtitle)
        }
      })
      #v(1fr)
      #align(center, { author; if institute != none [ (#institute)] })
      #v(1fr)
      #if date != none { align(center, text(size: 0.9em, date)) }
      #v(1fr)
    ]
  }
  body
}

/// One slide.
#let slide(body, title: none, footer: auto, clock: auto) = {
  slide-no.step()
  context {
    let c = _config.get()
    let p = c.palette
    let show-foot = if footer != auto { footer } else { c.footer }
    let cl = if clock != auto { clock } else { c.clock }
    page({
      // The clock is `place`d, so it is drawn OUTSIDE the flow and steals no
      // room from the title — a slide with a clock lays out exactly like one
      // without. It goes in the top corner on the trailing edge: right under
      // ltr, left under rtl, the corner the eye is not reading from.
      if cl != none {
        place(top + right, dx: 0cm, dy: -0.30cm, context {
          let r2l = is-rtl()
          let n = slide-no.get().first()
          let tot = slide-no.final().first()
          let txt = _clock-body(cl, n, tot, p)
          if txt == none { return }
          box(width: 100%, {
            // A time is a NUMBER: `12:30` is reordered under `dir: rtl`
            // exactly as the slide count was, so it is pinned with `place`
            // and set ltr in a box of its own.
            place(if r2l { left } else { right },
              box(text(dir: ltr, size: 0.52em, weight: "bold",
                fill: c.muted, txt)))
          })
        })
      }
      if title != none {
        block(width: 100%, below: 0.55em, text(
          fill: p.at("title", default: p.structure), weight: "bold",
          size: 1.12em, title))
      }
      body
      if show-foot {
        place(bottom + left, dx: 0cm, dy: 0.42cm, context {
          let r2l = is-rtl()
          let n = slide-section-no.get().first()
          let nm = slide-section-name.get()
          let sec = if n > 0 and nm != none { [#n.~#nm] }
                    else if n > 0 { [#n.] } else { [] }
          set text(size: 0.52em, weight: "bold", fill: c.muted)
          // A `grid` already lays its columns out in READING order, so under
          // `dir: rtl` the first cell is on the right by itself. Mirroring
          // the cells' own `align` as well flipped them a second time, and
          // the slide number came out reading `11 / 5`.
          // `n / total` is a NUMBER, not a phrase: under `dir: rtl` a bare
          // `5 / 11` is reordered into `11 / 5`, i.e. the wrong slide. It is
          // pinned with `place` at each end instead — absolute placement is
          // not reordered — and set ltr inside a box of its own, so the box
          // still takes its natural width.
          let num = box(text(dir: ltr,
            context [#slide-no.display() / #slide-no.final().first()]))
          box(width: 100%, height: 0.42cm, {
            place(if r2l { right } else { left }, sec)
            place(if r2l { left } else { right }, num)
          })
        })
      }
    })
  }
}

/// A numbered section divider.
#let slide-section(name) = {
  slide-section-no.step()
  slide-section-name.update(name)
  slide-no.step()
  context {
    let p = _config.get().palette
    page[
      #v(1fr)
      #align(center, text(fill: p.at("title", default: p.structure),
        weight: "bold", size: 1.5em,
        [#slide-section-no.get().first(). #name]))
      #v(1fr)
    ]
  }
}

/// A titled block, set off by a rule down its leading edge.
///
/// The rule must be exactly as tall as the block, and two obvious ways both
/// fail: `place(rect(height: 100%))` measures the PAGE, and `measure()` on a
/// full-width block reports the page height for the same reason. A `stroke`
/// on the block itself is drawn to the block's own height, whatever the
/// content turns out to be.
#let slide-block(body, title: none, kind: none, colour: auto) = context {
  let p = _config.get().palette
  let col = if colour != auto { colour } else { p.structure }
  let r2l = is-rtl()
  block(width: 100%, inset: (y: 0.12cm),
    block(width: 100%,
      inset: (left: if r2l { 0pt } else { 0.32cm },
              right: if r2l { 0.32cm } else { 0pt }),
      stroke: (left: if r2l { none } else { 1.2pt + col },
               right: if r2l { 1.2pt + col } else { none }), {
        if title != none or kind != none {
          block(below: 0.35em, text(fill: col, weight: "bold", {
            if kind != none { kind }
            if title != none [ (#title)]
          }))
        }
        body
      }))
}

/// A bulleted or numbered list in the structure colour.
#let slide-list(..items, kind: "itemize", colour: auto) = context {
  let p = _config.get().palette
  let col = if colour != auto { colour } else { p.structure }
  let r2l = is-rtl()
  let n = items.pos().len()
  block(width: 100%, {
    for (i, it) in items.pos().enumerate() {
      let mark = if kind == "enumerate" {
        text(fill: col, weight: "bold", [#(i + 1).])
      } else {
        text(fill: col, [#sym.circle.small])
      }
      grid(columns: (auto, 1fr), column-gutter: 0.28cm, mark, it)
      if i + 1 < n { v(0.20em) }
    }
  })
}

/// Two or more columns on one slide.
#let slide-columns(..cols, gutter: 0.7cm) = grid(
  columns: cols.pos().map(_ => 1fr), column-gutter: gutter, ..cols.pos())

/// Alerted text.
#let slide-alert(body) = context {
  text(fill: _config.get().palette.alert, body)
}

/// The current palette, for a caller drawing its own furniture.
#let slide-palette() = _config.get().palette
