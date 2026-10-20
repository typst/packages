// The tab staff: string lines, fret numbers, barlines and the TAB mark.
//
// The load-bearing visual requirement is that a string line must never run
// through a fret number. The published sheets this package is modelled on solve
// it by printing the numbers on an opaque white patch; here the lines are drawn
// as segments with a computed gap around each number instead. The result looks
// the same and also survives a tinted page background, and the gap costs
// nothing extra to compute because the glyph width is already measured for
// spacing. `theme(mask: "box")` selects the opaque patch for callers who
// prefer it.
//
// Callers must be inside a context, since glyph widths are measured.

#import "../model.typ": (
  get-technique, has-technique, is-parenthesised, LINK-KINDS, link-to-next, MUTED, prints-fret,
  slide-out,
)
#import "../rational.typ" as r
#import "../layout/beams.typ": flags-of
#import "glyphs.typ" as g
#import "meter.typ"

// Vertical geometry shared by the drawing code and by `overflow-above`, in
// staff spaces measured from the string's own line. Keeping the numbers in one
// place is what lets the reserved height match what is actually drawn.
//
// The figures were read off a 300 dpi rasterisation of the Hal Leonard Guitar
// Notation Legend rather than judged by eye: its hammer-on slur peaks 1.36
// spaces above the note line across a span of 5.4. The tail sits lower than the
// legend's 0.74 so a short slur hugs its digits instead of stranding them.
#let _SLUR-TAIL = 0.52 // where a slur or tie leaves the note line
#let _SLUR-RISE-MAX = 0.84 // how much further a long one climbs
#let _SLUR-RISE-MIN = 0.20 // and the least a short one may
#let _SLUR-SLOPE = 0.155 // rise per unit of span, between those bounds
#let _SLUR-WEIGHT = 0.15 // thickness at the middle, tapering to nothing at the ends

// The line one space up is the hazard: an apex landing on it runs along it and
// reads as merging with it. An apex anywhere in this band is pushed clear —
// down if it was heading under the line, up if it was heading over.
#let _SLUR-BAND-LOW = 0.86
#let _SLUR-BAND-HIGH = 1.16
#let _SLUR-CLEAR-UNDER = 0.82
#let _SLUR-CLEAR-OVER = 1.20

// A slur leaving a number's *side* — which is what stacked numbers in a chord
// force — starts at the upper part of the digit rather than above its cap, so it
// is obvious which number it belongs to. Not at the digit's middle, though:
// level with the line, the arc and the line enclose a sliver and read as one
// closed shape. It then stays low and flat, inside its own string's space, where
// a taller arc would reach the number above.
#let _SLUR-SIDE-TAIL = 0.28
#let _SLUR-SIDE-RISE-MAX = 0.30
#let _SLUR-SIDE-RISE-MIN = 0.16
#let _SLUR-SIDE-SLOPE = 0.07

// A tie hangs *under* its note line, curving down — the mirror of the slur above
// it. Drawn upward it is the same mark as a hammer-on's slur, and nothing in the
// picture tells the reader which one is meant. Hal Leonard never faces this,
// because it draws no tie arcs in tablature at all: the held note is simply not
// struck again, or is set in parentheses, with the tie left to the notation
// staff. A package with no staff to put it on has to draw it, so the reference
// here is Songsterr, which renders tablature alone and flips the tie.
//
// Shallow, so it stays inside its own string's space whatever the span. The
// reference dips 0.83 spaces at its deepest and leaves the line at 0.42, read
// off the same SVG; the cap here is just short of that, leaving a fifth of a
// space to the line below.
#let _TIE-TAIL = 0.40
#let _TIE-DROP-MAX = 0.40
#let _TIE-DROP-MIN = 0.22
#let _TIE-SLOPE = 0.09

// Stacked numbers leave nothing under the digit to hang a tie from — the next
// string's number is right there. A chord's tie leaves the flank instead, a
// little below the middle so it is plainly this number's and not the line's, and
// stays shallower so it clears the number below, whose cap reaches about 0.65
// spaces up towards it.
#let _TIE-SIDE-TAIL = 0.20
#let _TIE-SIDE-DROP-MAX = 0.30

// A bend arrow leaves the side of its fret number rather than the top.
#let _BEND-TAIL = 0.42 // how far above the note line it starts
#let _BEND-MIN-RISE = 1.6 // the shortest arrow drawn, for notes near the top line
#let _BEND-CLEARANCE = 0.5 // how far above the staff a longer one ends

/// How high a slur peaks above the note line, for a given horizontal span.
///
/// The height follows the span rather than being fixed: a long slur rises to the
/// reference height and crosses the line above it at a clear angle, a short one
/// stays flat and sits inside the string spacing. Whatever the span, the apex is
/// then kept out of the band where it would run along that line.
#let slur-apex(theme, span, side: false) = {
  let sp = theme.staff-space
  if side {
    let rise = calc.max(
      _SLUR-SIDE-RISE-MIN * sp,
      calc.min(_SLUR-SIDE-RISE-MAX * sp, span * _SLUR-SIDE-SLOPE),
    )
    return _SLUR-SIDE-TAIL * sp + rise
  }
  let rise = calc.max(_SLUR-RISE-MIN * sp, calc.min(_SLUR-RISE-MAX * sp, span * _SLUR-SLOPE))
  let apex = _SLUR-TAIL + rise / sp
  if apex > _SLUR-BAND-LOW and apex < _SLUR-BAND-HIGH {
    apex = if apex < 1.0 { _SLUR-CLEAR-UNDER } else { _SLUR-CLEAR-OVER }
  }
  apex * sp
}

/// How far a tie dips below the note line, for a given horizontal span.
///
/// Bounded rather than growing with the span, unlike a slur: a tie must stay in
/// its own string's space however long it is, since the line and the number
/// below it are both close.
#let tie-depth(theme, span, side: false) = {
  let sp = theme.staff-space
  let tail = if side { _TIE-SIDE-TAIL } else { _TIE-TAIL }
  let most = if side { _TIE-SIDE-DROP-MAX } else { _TIE-DROP-MAX }
  tail * sp + calc.max(_TIE-DROP-MIN * sp, calc.min(most * sp, span * _TIE-SLOPE))
}

/// Where a bend arrow's head sits, as a y in staff coordinates.
///
/// Arrows end just above the staff rather than a fixed distance above their own
/// note, so that within a system they all reach the same height — which is how
/// the reference sets them. Notes near the top line would give an arrow too
/// short to read, so there is a floor on the length.
#let bend-head-y(theme, y) = {
  let sp = theme.staff-space
  calc.min(y - _BEND-MIN-RISE * sp, -_BEND-CLEARANCE * sp)
}

/// Vertical extent of the staff: string 1 sits at y = 0.
#let height(theme, strings) = (strings - 1) * theme.staff-space

/// y-position of a string's line, counted from the top of the staff.
#let string-y(theme, string) = (string - 1) * theme.staff-space

// A rest is drawn *inside* the staff, in the place a note would have taken —
// not in the rhythm lane, which carries only what describes a note that sounds.
// Read off `research/TNT_0001.png`, a tab-only sheet in exactly this format: its
// eighth rests span 1.50 to 2.67 staff spaces below the top line, so their
// centre sits at 2.08 of a five-space staff, a little above its middle. Nothing
// is drawn above them at all — no stem and no flag, the rest glyph carrying its
// own duration.
#let _REST-CENTRE = 0.417 // of the staff height
/// Where a rest is centred, and the line a whole or half rest is measured from.
///
/// Both fall out of `_REST-CENTRE`: the block rests round it to an actual line,
/// since hanging under or sitting on one is the only thing that tells them
/// apart, and the rest are centred on the unrounded height.
#let rest-anchor(theme, strings) = {
  let h = height(theme, strings)
  (
    centre: _REST-CENTRE * h,
    line: calc.round(_REST-CENTRE * (strings - 1)) * theme.staff-space,
  )
}

/// How much smaller a grace note's fret number is set than a real one.
///
/// Small enough to read at a glance as an ornament rather than as a beat, but
/// not so small it stops being legible against the string lines it sits on.
#let GRACE-SCALE = 0.68

/// A fret number, set for measurement and for drawing.
///
/// The edges are pinned to the glyph itself rather than to the line box, so the
/// measured height *is* the cap height and centring the box on a string line
/// centres the digits on it exactly.
#let fret-label(theme, fret, grace: false, ghost: false) = {
  let muted = fret == MUTED
  let body = if muted { "x" } else { str(fret) }
  text(
    font: theme.font,
    size: theme.fret-size * (if grace { GRACE-SCALE } else { 1.0 }),
    weight: 500,
    fill: theme.color,
    number-width: "tabular",
    // Parentheses reach below the baseline and above the cap, so pinning the
    // edges to the digit would clip them. A ghost note measures its own box.
    top-edge: if ghost { "bounds" } else if muted { "x-height" } else { "cap-height" },
    bottom-edge: if ghost { "bounds" } else { "baseline" },
    if ghost { "(" + body + ")" } else { body },
  )
}

/// The glyph a rest event prints, or `none` for anything else.
///
/// One definition for both the spacing pass and the drawing pass, so a rest
/// cannot be measured at one size and drawn at another. `none` covers both a
/// note and a rest whose length is unknown — an imported tab with no rhythm
/// cannot say how long a silence is, and drawing a guess would be worse.
#let rest-glyph(theme, ev, fill: black) = {
  if ev.kind != "rest" { return none }
  let flags = flags-of(ev)
  if flags == none { return none }
  g.rest-for(theme.staff-space, flags, fill: fill)
}

/// The frets a note is linked to by a hammer-on, pull-off or slide.
///
/// These print as further numbers on the same string, joined to the first by a
/// slur or a slide line, and share the parent event's duration. A link written
/// with no target fret is not one of them: it runs to the next event that plays
/// the string, which already prints its own number and carries its own value,
/// and is drawn like a tie instead — see `link-to-next`.
#let link-targets(n) = {
  n
    .techniques
    .filter(t => t.kind in LINK-KINDS and t.at("fret", default: none) != none)
    .map(t => (kind: t.kind, fret: t.fret, legato: t.at("legato", default: true)))
}

/// Gap between a note and a fret it is linked to.
///
/// Wide enough for the slur joining them to read as an arc. Published sheets set
/// the two numbers of a hammer-on a whole event apart, because there they are
/// separate events; here they share one, so this is the compromise.
#let _link-gap(theme) = 1.15 * theme.staff-space

/// How far a link or a tie runs when the note at its other end is on another
/// system.
///
/// Both halves are drawn the same length, so a note held or slid across the
/// break reads as one mark cut in two rather than as two different ones.
#let _system-tail(theme) = 1.6 * theme.staff-space

/// One end of a slur, named so that two connectors meeting there can be found.
///
/// A joint is a place a legato mark attaches: an event, a string, and how far
/// along that note's own run of printed targets it is — step 0 being the note's
/// own number. Naming them is what lets the runs be folded without the drawing
/// code having to re-derive from geometry which arc ends where another begins.
#let _joint(event, string, step) = str(event) + "/" + str(string) + "/" + str(step)

/// Half the width of the number a tie or a link lands on.
///
/// The arc has to stop at the digit's near edge rather than at its centre, and a
/// parenthesised number is the wider one — measuring the bare digit would end
/// the arc inside the opening bracket. Zero where the note prints no number at
/// all: the far end of a tie is then a place on the line, not a digit, and an
/// arc stopping short of it would hang in the air.
///
/// Must be called from a context, since type is measured.
#let _landing-half(theme, note) = {
  if not prints-fret(note) { return 0pt }
  measure(fret-label(theme, note.fret, ghost: is-parenthesised(note))).width / 2
}

/// The next event after `index` that plays `string`, or `none`.
#let _next-on-string(placed, index, string) = {
  for j in range(index + 1, placed.len()) {
    if placed.at(j).event.notes.any(o => o.string == string) { return j }
  }
  none
}

/// Whether a note is carried on to the next event by a link that draws a slur.
///
/// A shift slide draws its line and no arc — the target is picked again, so
/// there is no one gesture to arch over — and so ends a run rather than
/// continuing it.
#let _legato-link(n) = {
  let link = link-to-next(n)
  if link != none and link.at("legato", default: true) { link } else { none }
}

/// The last event a run of legato links leaving `index` on `string` reaches, or
/// `none` when it leaves the system before reaching one.
///
/// A hammer-on into a pull-off into a slide is *one* gesture and is drawn as one
/// slur, so the height the lane must reserve follows the whole run rather than
/// its first pair: the apex grows with the span. Every step forward is a link
/// with no target fret, which is the only form that joins two independently
/// timed events, so the walk is the same one `_fold-slurs` makes over the
/// connectors — read off the music here because the lane is measured before
/// anything is drawn.
#let _legato-run-end(placed, index, string) = {
  let at = index
  let reached = none
  while true {
    let note = placed.at(at).event.notes.find(o => o.string == string)
    if note == none or _legato-link(note) == none { break }
    let next = _next-on-string(placed, at, string)
    if next == none { break }
    reached = next
    at = next
  }
  reached
}

/// Width an event's fret numbers occupy.
///
/// `total` covers everything the event prints, including linked targets, and
/// governs how much room the spacing engine reserves. `anchor` is the width of
/// the event's own number, which is what every lane aligns on.
///
/// Must be called from a context, since it measures type.
#let event-metrics(theme, ev) = {
  // A rest takes room on the staff like a number does, and has to claim it here
  // or the fast ones — whose duration buys them almost no width — are drawn on
  // top of their neighbours.
  let rest = rest-glyph(theme, ev)
  if rest != none { return (total: rest.width, anchor: rest.width) }
  if ev.notes.len() == 0 { return (total: 0pt, anchor: 0pt) }
  let gap = _link-gap(theme)
  let grace = ev.at("grace", default: none) != none
  // A note's own number may be parenthesised; a fret it is linked to is not,
  // the ghost mark belonging to the strike rather than to the run.
  //
  // The far end of a tie prints no number and still claims its width. The room
  // is what the tie is *drawn in*: measured at nothing, a held thirty-second is
  // spaced by its duration alone, which is almost no width at all, and the arc
  // has nowhere to arch. Published sheets leave the same column empty.
  let label(fret, ghost: false) = fret-label(theme, fret, grace: grace, ghost: ghost)
  let own(n) = label(n.fret, ghost: is-parenthesised(n))
  let anchor = ev.notes.map(n => measure(own(n)).width).fold(0pt, calc.max)
  let total = ev
    .notes
    .map(n => {
      let widths = (
        (measure(own(n)).width,)
          + link-targets(n).map(t => measure(label(t.fret)).width)
      )
      widths.fold(0pt, (a, b) => a + b) + gap * (widths.len() - 1)
    })
    .fold(0pt, calc.max)
  (total: calc.max(total, anchor), anchor: anchor)
}

/// Merge overlapping intervals, given as `(start, end)` pairs.
#let _merge(intervals) = {
  let sorted = intervals.sorted(key: iv => iv.start)
  let merged = ()
  for iv in sorted {
    if merged.len() > 0 and iv.start <= merged.last().end {
      let last = merged.pop()
      merged.push((start: last.start, end: calc.max(last.end, iv.end)))
    } else {
      merged.push(iv)
    }
  }
  merged
}

/// Draw one string line from 0 to `width`, skipping the given gaps.
#let _line-with-gaps(theme, y, width, gaps) = {
  let segments = ()
  let cursor = 0pt
  for gap in gaps {
    if gap.start > cursor { segments.push((cursor, gap.start)) }
    cursor = calc.max(cursor, gap.end)
  }
  if cursor < width { segments.push((cursor, width)) }

  segments
    .map(((a, b)) => place(
      top + left,
      dx: a,
      dy: y - theme.line / 2,
      rect(width: b - a, height: theme.line, fill: theme.color, stroke: none),
    ))
    .join()
}

// The ornate repeat sign, traced pixel by pixel off a published rock tab. With
// the heavy bar's outer edge at x = 0 and the staff's edge at y = 0, and the
// staff space as the unit, the serif's outline runs:
//
//   - the outer boundary leaves the bar 0.54 up and sweeps to a tip at
//     (1.13, 1.00), climbing steeply in x at first and then levelling off;
//   - the inner boundary returns from that tip almost straight down to the bar's
//     *inner* edge at 0.125 up, bulging outwards by about 0.12 on the way.
//
// It is a horn whose base is the bar itself, which is why the bar also runs past
// the staff by the 0.54 where the outer boundary leaves it. Tracing the rendered
// result back the same way puts it within 0.05 of the reference over most of its
// height and 0.12 at the tip; what remains is the heavy bar, which is 0.45 spaces
// thick here against the reference's 0.33.

/// How far an ornate repeat sign's serifs reach beyond the staff.
#let repeat-serif-reach(theme) = 1.15 * theme.staff-space

/// How far the heavy bar of an ornate repeat runs past the staff.
#let _repeat-overhang(theme) = 0.54 * theme.staff-space

/// One flared serif of an engraved repeat sign.
///
/// `x` is the heavy bar's *outer* edge and `y` the staff edge it grows from.
/// `dir` is +1 to flare right, as a repeat that opens does, and `up` whether it
/// grows above the staff or below it.
#let _repeat-serif(theme, x, y, dir, up) = {
  let sp = theme.staff-space
  let heavy = theme.heavy-barline
  let v = if up { -1.0 } else { 1.0 }
  let px(d) = x + dir * d * sp
  let py(d) = y + v * d * sp

  place(top + left, dx: 0pt, dy: 0pt, curve(
    fill: theme.color,
    stroke: none,
    curve.move((px(0), py(0.54))),
    curve.cubic((px(0.60), py(0.61)), (px(1.02), py(0.84)), (px(1.16), py(1.02))),
    curve.cubic((px(1.20), py(0.78)), (px(0.78), py(0.42)), (x + dir * heavy, py(0.125))),
    curve.close(mode: "straight"),
  ))
}

/// A barline of the given kind, as `(width, body)`.
///
/// Barlines are drawn heavier than string lines so the metre reads at a glance,
/// and the closing and repeat forms use the conventional thin-then-thick pair.
/// With `theme(repeat-style: "ornate")` the repeat signs also get the flared
/// serifs of an engraved one.
#let barline(theme, h, kind) = {
  let sp = theme.staff-space
  let thin = theme.barline
  let heavy = theme.heavy-barline
  let gap = 0.28 * sp
  let ornate = theme.repeat-style == "ornate"

  // The serifs grow from the heavy bar's inner edge, at both ends of the staff.
  let serifs(x, dir) = if not ornate { none } else {
    _repeat-serif(theme, x, 0pt, dir, true) + _repeat-serif(theme, x, h, dir, false)
  }

  let overhang = if ornate { _repeat-overhang(theme) } else { 0pt }
  let bar(x, w) = place(
    top + left,
    dx: x,
    dy: if w == heavy { -overhang } else { 0pt },
    rect(
      width: w,
      height: if w == heavy { h + 2 * overhang } else { h },
      fill: theme.color,
      stroke: none,
    ),
  )
  let dots(x) = {
    let d = g.repeat-dots(sp, h, fill: theme.color)
    place(top + left, dx: x, dy: 0pt, d.body)
  }
  let dots-w = 0.28 * sp

  if kind == "single" {
    (width: thin, body: bar(0pt, thin))
  } else if kind == "double" {
    (width: thin * 2 + gap, body: bar(0pt, thin) + bar(thin + gap, thin))
  } else if kind == "final" {
    (width: thin + gap + heavy, body: bar(0pt, thin) + bar(thin + gap, heavy))
  } else if kind == "repeat-start" {
    (
      width: heavy + gap + thin + gap + dots-w,
      body: (
        bar(0pt, heavy)
          + bar(heavy + gap, thin)
          + dots(heavy + gap + thin + gap)
          + serifs(0pt, 1)
      ),
    )
  } else if kind == "repeat-end" {
    let heavy-x = dots-w + gap + thin + gap
    (
      width: heavy-x + heavy,
      body: dots(0pt) + bar(dots-w + gap, thin) + bar(heavy-x, heavy) + serifs(heavy-x + heavy, -1),
    )
  } else {
    panic("tabstaff: unknown barline kind '" + kind + "'")
  }
}

/// The curve both slurs and ties are drawn as.
///
/// A filled lens rather than a stroked curve, so it swells in the middle and
/// tapers to a point at each end the way an engraved slur does. A
/// constant-thickness stroke reads as a wire.
///
/// `tail` is how far from the note line it leaves, `reach` how far from that
/// line it gets at its furthest; `down` mirrors the whole thing under the line.
#let _arc(theme, x0, x1, y, tail, reach, down: false) = {
  let dir = if down { -1.0 } else { 1.0 }
  let span = x1 - x0
  let ends = y - dir * tail
  // A cubic peaks at three quarters of its control offset, so the controls sit
  // further from the line than the apex they produce.
  let lift = (reach - tail) * 4 / 3
  let outer = ends - dir * lift
  let inner = outer + dir * _SLUR-WEIGHT * theme.staff-space * 4 / 3

  place(top + left, dx: 0pt, dy: 0pt, curve(
    fill: theme.color,
    stroke: none,
    curve.move((x0, ends)),
    curve.cubic((x0 + span * 0.3, outer), (x0 + span * 0.7, outer), (x1, ends)),
    curve.cubic((x0 + span * 0.7, inner), (x0 + span * 0.3, inner), (x0, ends)),
    curve.close(mode: "straight"),
  ))
}

/// The slur joining a hammer-on or pull-off to its target.
///
/// Hal Leonard prints the same slur for both: which one it is follows from
/// whether the pitch rises or falls, so no letter is needed.
#let _slur(theme, x0, x1, y, side: false) = {
  let tail = (if side { _SLUR-SIDE-TAIL } else { _SLUR-TAIL }) * theme.staff-space
  _arc(theme, x0, x1, y, tail, slur-apex(theme, x1 - x0, side: side))
}

/// Fold every run of legato links on one string into a single slur.
///
/// A hammer-on into a pull-off into a slide is *one* gesture, and published
/// sheets arch one slur over the whole of it. Drawn pair by pair the arcs meet
/// at the notes between and come out as a row of bumps, which reads as several
/// separate articulations — and on a fast run they are so short that each is
/// nearly flat.
///
/// Only the arc is merged. The lines are per pair and stay so: a slide draws its
/// own diagonal between its own two numbers, and there is nothing about the run
/// that could be said by one long one.
///
/// A connector that can carry a slur names the joint it leaves and the joint it
/// arrives at, so the run is followed from one's `to` to the next one's `from`
/// rather than guessed from the geometry. Anything with no slur to give — a
/// shift slide, whose target is picked again; a tie; a mark trailing off the end
/// of the system, which arrives nowhere — has no joints to be followed and so
/// stands alone, and ends the run it was part of.
#let _fold-slurs(connectors) = {
  // Every slur-bearing connector, by the joint it leaves.
  let leaving = (:)
  for (i, c) in connectors.enumerate() {
    if c.at("chain", default: none) != none and c.legato {
      leaving.insert(c.chain.from, i)
    }
  }
  // The joints a run arrives at, so that only the first link of one opens a slur.
  let arriving = (:)
  for (_, i) in leaving {
    let to = connectors.at(i).chain.to
    if to != none and to in leaving { arriving.insert(to, true) }
  }

  // A folded connector keeps its line and gives up its arc to the run's.
  let out = connectors.map(c => if c.at("chain", default: none) != none and c.legato {
    c + (legato: false)
  } else { c })

  for (joint, i) in leaving {
    if joint in arriving { continue }
    let first = connectors.at(i)
    let last = first
    // A chord at either end pins the slur to the numbers' flanks and keeps it
    // flat, since a stacked number leaves no room over it.
    let side = first.side
    while last.chain.to != none and last.chain.to in leaving {
      last = connectors.at(leaving.at(last.chain.to))
      side = side or last.side
    }
    out.push((kind: "slur", from: first.from, to: last.to, y: first.y, side: side))
  }
  out
}

/// The tie joining a note to the next strike of the same string.
#let _tie(theme, x0, x1, y, side: false) = {
  let tail = (if side { _TIE-SIDE-TAIL } else { _TIE-TAIL }) * theme.staff-space
  _arc(theme, x0, x1, y, tail, tie-depth(theme, x1 - x0, side: side), down: true)
}

/// The diagonal joining a slide to its target.
#let _slide-line(theme, x0, x1, y, rising) = {
  let sp = theme.staff-space
  let rise = 0.28 * sp
  place(top + left, dx: 0pt, dy: 0pt, curve(
    stroke: (paint: theme.color, thickness: 0.09 * sp, cap: "round"),
    curve.move((x0 + 0.1 * sp, y + (if rising { rise } else { -rise }))),
    curve.line((x1 - 0.1 * sp, y + (if rising { -rise } else { rise }))),
  ))
}

/// The wavy line a pick scrape leaves along the string it is dragged down.
///
/// Drawn *in* the staff, on the string's own line, because that is where both
/// references put the gesture: Hal Leonard's legend writes `P.S.` above the
/// staff and an `X` on the string, and Songsterr runs a wave from that `X` to
/// the note the scrape lands on. The wave alone used to be set above the staff,
/// beside the words, which said the scrape happened somewhere near the music
/// rather than on one string of it.
///
/// Measured off `research/pickscrape.svg`: the wave spans the gap between the
/// two numbers, starting about a third of a string above the line and ending as
/// far below it.
///
/// That tilt is structural, not decoration. The string line runs unbroken under
/// the wave, and a wave laid flat along it comes out as one thick dashed rule
/// with the string lost inside — drawn that way first, and unreadable. Tilting
/// it lets the two cross once, in the middle, and the wave reads as a wave for
/// the whole of its length. It says nothing about which way the pick was
/// dragged: the legend has that "down (or up)", and the model carries no
/// direction to draw from.
#let _SCRAPE-DROP = 0.67 // how far the wave falls over its length, in staff spaces

#let _scrape-line(theme, x0, x1, y) = {
  let sp = theme.staff-space
  let span = calc.max(0.8 * sp, x1 - x0)
  let drop = _SCRAPE-DROP * sp
  let wave = g.wavy(sp, span, fill: theme.color)
  place(
    top + left,
    dx: x0,
    dy: y - drop / 2 - wave.height / 2,
    rotate(calc.atan2(span / 1pt, drop / 1pt), origin: left + horizon, wave.body),
  )
}

/// The interval a bend is written with: `full`, `1/2`, `1/4`.
#let bend-label(theme, amount) = {
  let size = if r.eq(amount, r.rat(1)) {
    "full"
  } else if amount.den == 1 {
    str(amount.num)
  } else {
    str(amount.num) + "/" + str(amount.den)
  }
  text(font: theme.font, size: theme.bend-size, weight: 500, fill: theme.color, size)
}

/// An arrowhead pointing along the y axis.
///
/// `half-width` and `length` are in staff spaces; `waist` is how far the base
/// bows back towards the tip, so `0` gives a plain triangle. The defaults are
/// the bend arrow's: narrow, long and slightly concave, which is how the Hal
/// Leonard legend draws the head of a bend.
///
/// An arpeggio's is a different mark and passes its own: measured off the
/// reference, a solid triangle as wide as it is tall — 0.54 spaces each way,
/// exactly twice the width of the squiggle it caps — with a flat base. Drawn at
/// the bend's proportions it reads as a stray tick rather than an arrowhead.
#let _arrowhead(theme, x, y, down: false, half-width: 0.20, length: 0.55, waist: 0.15) = {
  let sp = theme.staff-space
  let d = if down { -1.0 } else { 1.0 }
  place(top + left, dx: 0pt, dy: 0pt, curve(
    fill: theme.color,
    stroke: none,
    curve.move((x, y)),
    curve.line((x - half-width * sp, y + d * length * sp)),
    curve.cubic(
      (x - half-width * 0.35 * sp, y + d * (length - waist) * sp),
      (x + half-width * 0.35 * sp, y + d * (length - waist) * sp),
      (x + half-width * sp, y + d * length * sp),
    ),
    curve.close(mode: "straight"),
  ))
}

/// The arpeggio and rake arrowhead, in staff spaces.
#let _ARPEGGIO-HEAD = (half-width: 0.27, length: 0.54)

/// A bend arrow, leaving the side of the fret number it belongs to.
///
/// A bend that is *held* carries a dashed rule on from the arrowhead at the
/// height it reached, for as long as the pitch stays up. Without it a held bend
/// reads as bent and released at once, and how long it is held has to be
/// guessed from the ties — the rule is what states it.
///
/// That is also why a release is drawn as **two** arrows rather than as one
/// stroke curving over: up, hold, down is three things, and the hold has to sit
/// between the two arrowheads where it can be seen. The Hal Leonard legend
/// draws the single stroke, and this followed it until the hold arrived; a
/// stroke already curving downwards has nowhere to hang a horizontal rule.
///
/// `hold` is where the rule ends for a bend held by a tie, or `none`. `slot-x`
/// and `alloc` are the event's own slot; a release is kept inside it, so a bend
/// in a bar of sixteenths tightens up rather than running into the next event.
#let _bend-arrow(theme, x, half-width, y, bend, slot-x, alloc, hold: none) = {
  let sp = theme.staff-space
  let tail-x = x + half-width + 0.08 * sp
  let tail-y = y - _BEND-TAIL * sp
  let head-y = bend-head-y(theme, y)
  let head-base = head-y + 0.55 * sp
  let tip-x = tail-x + calc.min(0.9 * sp, alloc * 0.35)
  let stroke = (paint: theme.color, thickness: 0.085 * sp, cap: "round")
  // The same dashed rule the palm mute and let ring spans use, so the page has
  // one vocabulary for "this carries on". The reference measures its dash at a
  // third of a staff space and its gap at a quarter, which is that rule within
  // the error of reading it off a raster.
  let dashed = (
    paint: theme.color,
    thickness: 0.07 * sp,
    dash: (array: (0.30 * sp, 0.30 * sp), phase: 0pt),
  )
  // How far past the arrowhead the rule starts, so it does not touch it.
  let clear = 0.24 * sp
  // The descent is short and steep, so nearly all of a release is hold.
  let drop = 0.7 * sp
  // Where a release lands. The floor is what keeps the hold between the two
  // arrowheads long enough to read as one — measured on the reference, the two
  // stand 2.2 staff spaces apart — and the event's own right edge is the cap,
  // so the floor can never push the gesture into the next event.
  let reach = calc.max(1.5 * sp, calc.min(2.8 * sp, alloc * 0.55))
  let back-x = calc.max(
    tip-x + drop,
    calc.min(tip-x + reach, slot-x + alloc - 0.4 * sp),
  )

  // Up to the arrowhead. A pre-bend is already bent when the string is struck,
  // so it gets a straight arrow; the curve is what shows the pitch rising after
  // the attack.
  place(top + left, dx: 0pt, dy: 0pt, curve(
    stroke: stroke,
    curve.move((tail-x, tail-y)),
    if bend.pre {
      curve.line((tip-x, head-base))
    } else {
      curve.cubic(
        (tail-x + (tip-x - tail-x) * 0.8, tail-y),
        (tip-x, tail-y - (tail-y - head-y) * 0.55),
        (tip-x, head-base),
      )
    },
  ))
  _arrowhead(theme, tip-x, head-y)

  let label = bend-label(theme, bend.amount)
  let size = measure(label)
  // Centred over the arrowhead, but never past the event's own allocation.
  let label-x = calc.min(
    tip-x - size.width / 2,
    x + alloc - theme.min-event-gap / 2 - size.width,
  )
  // Clear of the dashed hold, which runs at the arrowhead's own height.
  place(
    top + left,
    dx: calc.max(label-x, x - 0.3 * sp),
    dy: head-y - size.height - 0.32 * sp,
    label,
  )

  // The hold: to where the release turns back down, or to the end of the tie
  // that carries the bend.
  let hold-end = if bend.release { back-x - drop } else { hold }
  if hold-end != none and hold-end > tip-x + clear {
    place(top + left, dx: tip-x + clear, dy: head-y, line(
      length: hold-end - tip-x - clear,
      stroke: dashed,
    ))
  }

  if bend.release {
    // A second arrow, starting where the hold leaves off and falling back to
    // the note's own line.
    place(top + left, dx: 0pt, dy: 0pt, curve(
      stroke: stroke,
      curve.move((hold-end, head-y)),
      curve.cubic(
        (back-x, head-y),
        (back-x, head-y + (tail-y - head-y) * 0.45),
        (back-x, tail-y - 0.55 * sp),
      ),
    ))
    _arrowhead(theme, back-x, tail-y, down: true)
  }
}

/// Whether the system carries a repeat sign drawn with serifs.
#let _has-repeat(theme, system) = {
  theme.repeat-style == "ornate" and system
    .measures
    .any(m => m.measure.start-repeat or m.measure.end-repeat)
}

/// How far the drawing reaches above the top string line.
///
/// Bends and slurs are anchored to their own string, so how much room they need
/// above the staff depends on which string that is: the same bend needs far more
/// clearance on string 1 than on string 6. Reserving the space — rather than
/// relying on the box not clipping — is what keeps a bend from colliding with
/// the rhythm lane above it.
///
/// Must be called from a context: the bend label is measured.
#let overflow-above(theme, system) = {
  let sp = theme.staff-space
  let over = if _has-repeat(theme, system) { repeat-serif-reach(theme) } else { 0pt }
  let placed = system.measures.map(m => m.events).flatten()
  for (i, pe) in placed.enumerate() {
    for n in pe.event.notes {
      let y = string-y(theme, n.string)
      let bend = get-technique(n, "bend")
      if bend != none {
        let head = bend-head-y(theme, y)
        over = calc.max(over, -head + measure(bend-label(theme, bend.amount)).height + 0.3 * sp)
      }
      let side = pe.event.notes.len() > 1
      if link-targets(n).len() > 0 {
        // The event's allocation covers everything it prints, so for linked
        // targets it bounds the slur's span from above — and the apex grows
        // with the span, so an upper bound reserves enough.
        over = calc.max(over, slur-apex(theme, pe.alloc, side: side) + 0.15 * sp - y)
      }
      // A link to the next event is bounded by nothing of the kind: the note it
      // runs to may be several events away and in another measure, exactly as a
      // tie's may be, so the span is measured the same way `overflow-below`
      // measures a tie's — and a run of legato links is drawn as one slur, so
      // the span runs to the end of the run rather than to the next note.
      if link-to-next(n) != none {
        let end = if _legato-link(n) == none {
          _next-on-string(placed, i, n.string)
        } else { _legato-run-end(placed, i, n.string) }
        let span = if end == none { pe.alloc } else { calc.max(pe.alloc, placed.at(end).x - pe.x) }
        over = calc.max(over, slur-apex(theme, span, side: side) + 0.15 * sp - y)
      }
      // The incoming half of one, and a slide out of a note: both are only ever
      // the tail's length.
      if n.at("linked-in", default: none) != none or slide-out(n) != none {
        over = calc.max(over, slur-apex(theme, _system-tail(theme), side: side) + 0.15 * sp - y)
      }
      if n.techniques.any(t => t.kind == "rake") {
        over = calc.max(over, 0.45 * sp + theme.technique-size * 1.3 - y)
      }
    }
  }
  over
}

/// How far the drawing reaches below the bottom string line.
///
/// A fret number is centred on its line, so half of one on the lowest string
/// hangs below the staff whatever the music does. A tie on that lowest string
/// hangs further, since ties are drawn under their line.
///
/// Must be called from a context: the fret label is measured.
#let overflow-below(theme, strings, system) = {
  let sp = theme.staff-space
  let bottom = string-y(theme, strings)
  let below = measure(fret-label(theme, 0)).height / 2 + 0.15 * sp
  if _has-repeat(theme, system) {
    below = calc.max(below, repeat-serif-reach(theme))
  }
  let placed = system.measures.map(m => m.events).flatten()
  for (i, pe) in placed.enumerate() {
    for n in pe.event.notes {
      let starts = n.techniques.any(t => t.kind == "tie")
      // The incoming half of a tie whose first note is on the line above dips
      // below its line too, and is drawn on a note that carries no tie itself.
      let arrives = n.at("tied-in", default: false)
      if not (starts or arrives) { continue }
      // A tie runs to the next event that plays this string, which may be
      // several events away — over rests, past other strings' notes — so its
      // span can far exceed the allocation, and the dip grows with the span.
      let span = if starts { pe.alloc } else { _system-tail(theme) }
      if starts {
        for j in range(i + 1, placed.len()) {
          if placed.at(j).event.notes.any(o => o.string == n.string) {
            span = calc.max(span, placed.at(j).x - pe.x)
            break
          }
        }
      }
      let side = pe.event.notes.len() > 1
      let reach = string-y(theme, n.string) + tie-depth(theme, span, side: side) + 0.15 * sp
      below = calc.max(below, reach - bottom)
    }
  }
  below
}

/// The vertical TAB mark that opens every system.
///
/// Returns `(width, bands, body)`. `bands` gives each letter's extent as
/// `(top, bottom, x0, x1)`, so a string line can be broken exactly where a
/// letter sits on it — and left whole where none does. Breaking every line for
/// the mark's full height clips the outermost ones, which have nothing over
/// them.
///
/// Must be called from a context: the letters are measured.
#let tab-mark(theme, strings) = {
  let sp = theme.staff-space
  let h = height(theme, strings)
  let cap = h / 4.8
  let gap = cap * 0.3
  let total = 3 * cap + 2 * gap
  let inset = 0.45 * sp
  let letters = ("T", "A", "B")

  let styled(letter) = text(
    font: theme.font,
    size: cap / 0.72,
    weight: 700,
    fill: theme.color,
    top-edge: "cap-height",
    bottom-edge: "baseline",
    letter,
  )
  let widths = letters.map(l => measure(styled(l)).width)
  let ink = widths.fold(0pt, calc.max)
  let top-of(i) = (h - total) / 2 + i * (cap + gap)

  (
    width: inset + ink,
    bands: letters
      .enumerate()
      .map(((i, _)) => (
        top: top-of(i),
        bottom: top-of(i) + cap,
        x0: inset,
        x1: inset + widths.at(i),
      )),
    body: box(width: theme.tab-mark-width, height: h, {
      for (i, letter) in letters.enumerate() {
        place(top + left, dx: inset, dy: top-of(i), styled(letter))
      }
    }),
  )
}

/// Draw the tab staff for one placed system.
///
/// `system` comes from `layout/system.typ` and carries the x-position of every
/// event; `width` is the full system width including the indent.
///
/// `overflow` is the room to leave above the top string line for bends and
/// slurs, from `overflow-above`. The staff is pushed down by that much, and the
/// box also allows for what hangs below the bottom line, so the returned box
/// contains everything it draws.
#let draw(theme, strings, system, width, overflow: 0pt) = {
  let sp = theme.staff-space
  let h = height(theme, strings)

  // 1. Fret numbers, measured up front: their widths decide both the gaps in
  //    the string lines and where the digits are drawn. Linked targets are
  //    numbers too, so they are laid out here and joined by a connector.
  let placed = system.measures.map(m => m.events).flatten()
  let labels = ()
  let connectors = ()
  // An arpeggio or a rake is a wavy line beside the chord, spanning the strings
  // it touches — string-anchored, so it belongs here rather than in a lane.
  let strokes = ()
  // Rests, which stand where a note would have stood.
  let rests = ()
  let anchor = rest-anchor(theme, strings)
  for pe in placed {
    let glyph = rest-glyph(theme, pe.event, fill: theme.color)
    if glyph == none { continue }
    let flags = flags-of(pe.event)
    // A whole rest hangs below its line and a half rest sits on it; everything
    // else is centred where a note would be.
    let top = if flags <= -2 {
      anchor.line
    } else if flags == -1 {
      anchor.line - glyph.height
    } else { anchor.centre - glyph.height / 2 }
    rests.push((x: pe.x - glyph.width / 2, top: top, glyph: glyph))
  }
  for (i, pe) in placed.enumerate() {
    // A grace note's numbers — its own and any it is linked to — are set small,
    // which is the whole of how the staff shows that it is an ornament.
    let grace = pe.event.at("grace", default: none) != none
    let label(fret, ghost: false) = fret-label(theme, fret, grace: grace, ghost: ghost)
    for n in pe.event.notes {
      // A note the string is merely holding prints no number: the tie's arc is
      // what says it sounds on, and a digit there reads as a fresh attack. It
      // still has a position — where the arc lands, and where the rhythm lane
      // writes its value — so only the drawing goes, not the note.
      let body = if prints-fret(n) { label(n.fret, ghost: is-parenthesised(n)) } else { [] }
      let size = measure(body)
      let y = string-y(theme, n.string)
      if prints-fret(n) {
        labels.push((x: pe.x, string: n.string, w: size.width, h: size.height, body: body))
      }

      // A slur springs from the top *centre* of a lone number, as the legend
      // sets it. That is impossible when numbers are stacked in a chord — the
      // arc would run into the one above — so a chord attaches at the sides
      // instead, which is what published sheets do with their tied chords.
      let stacked = pe.event.notes.len() > 1
      let cursor = pe.x + size.width / 2
      let from-fret = n.fret
      let from-x = if stacked { cursor } else { pe.x }
      for (step, target) in link-targets(n).enumerate() {
        let tbody = label(target.fret)
        let tsize = measure(tbody)
        // A hammer-on or a slide reaches its target at once, so the number sits
        // a link's gap away. A pick scrape reaches its at the *end* of the drag,
        // and the drag lasts the note's whole value — so the number goes to the
        // far side of the event's own slot and the wave spans everything
        // between. A slot too narrow for that falls back to the link gap, which
        // is what keeps a scrape written on a short note from running backwards.
        let near = cursor + _link-gap(theme) + tsize.width / 2
        let tx = if target.kind == "scrape" {
          calc.max(near, pe.left + pe.alloc - theme.min-event-gap - tsize.width / 2)
        } else { near }
        labels.push((x: tx, string: n.string, w: tsize.width, h: tsize.height, body: tbody))
        connectors.push((
          kind: target.kind,
          legato: target.legato,
          from: from-x,
          to: if stacked { tx - tsize.width / 2 } else { tx },
          edge: (cursor, tx - tsize.width / 2),
          side: stacked,
          y: y,
          // A pick scrape starts on a dead string, which has no fret to compare
          // against — and needs none, since its wave is drawn level whichever
          // way the pick travelled.
          rising: (
            type(target.fret) == int and type(from-fret) == int and target.fret > from-fret
          ),
          // A pick scrape draws its wave and no arc, so it joins no run: the
          // drag *is* the gesture, and it ends whatever run it lands in.
          chain: if target.kind == "scrape" {
            none
          } else {
            (from: _joint(i, n.string, step), to: _joint(i, n.string, step + 1))
          },
        ))
        cursor = tx + tsize.width / 2
        from-x = tx
        from-fret = target.fret
      }

      // Where a tie on this note finally stops, following the chain through
      // every event that holds the string without striking it again. A bend is
      // held for exactly that long, so this is how far its dashed rule reaches.
      // `none` when nothing later plays the string, which is the tie trailing
      // off the end of a system.
      let tie-end = none
      if n.techniques.any(t => t.kind == "tie") {
        let j = i
        let holding = true
        while holding {
          holding = false
          for k in range(j + 1, placed.len()) {
            let landed = placed.at(k).event.notes.find(o => o.string == n.string)
            if landed == none { continue }
            j = k
            holding = landed.techniques.any(t => t.kind == "tie")
            break
          }
        }
        if j != i { tie-end = j }
      }

      // A tie runs to the next event that plays this string. When that event
      // falls on the next system the tie trails off instead, which is the
      // conventional way of showing a note held across the break.
      if n.techniques.any(t => t.kind == "tie") {
        let target-x = none
        let target-edge = none
        for j in range(i + 1, placed.len()) {
          let later = placed.at(j).event.notes.filter(o => o.string == n.string)
          if later.len() > 0 {
            target-x = placed.at(j).x
            target-edge = placed.at(j).x - _landing-half(theme, later.first())
            break
          }
        }
        let trail = cursor + _system-tail(theme)
        connectors.push((
          kind: "tie",
          legato: true,
          from: if stacked { cursor } else { pe.x },
          to: if target-x != none { if stacked { target-edge } else { target-x } } else { trail },
          edge: (cursor, if target-edge != none { target-edge } else { trail }),
          side: stacked,
          y: y,
          rising: false,
        ))
      }

      // A link written with no target fret runs to the next event that plays
      // this string, exactly as a tie does — the two notes are separate events
      // with their own values, so there is no second number beside this one and
      // nothing to hang the arc on but the note itself. Where that event falls
      // on the next system the link trails off, and the system it lands on draws
      // the other half from `linked-in`.
      let link = link-to-next(n)
      if link != none {
        let target = _next-on-string(placed, i, n.string)
        let target-x = none
        let target-edge = none
        let target-fret = none
        if target != none {
          let later = placed.at(target).event.notes.find(o => o.string == n.string)
          target-x = placed.at(target).x
          target-edge = target-x - _landing-half(theme, later)
          target-fret = later.fret
        }
        let trail = cursor + _system-tail(theme)
        connectors.push((
          kind: link.kind,
          legato: link.at("legato", default: true),
          from: if stacked { cursor } else { pe.x },
          to: if target-x != none { if stacked { target-edge } else { target-x } } else { trail },
          edge: (cursor, if target-edge != none { target-edge } else { trail }),
          side: stacked,
          y: y,
          // A slide trailing off the end of a system has no fret to compare
          // against, and a dead string cannot be compared to one at all. Both
          // fall back to a downward line, which is what sliding out of a note
          // conventionally is.
          rising: (
            type(target-fret) == int and type(n.fret) == int and target-fret > n.fret
          ),
          // The joint this leaves is past every target the note printed itself;
          // the one it arrives at is that note's own number. A link running off
          // the end of the system arrives nowhere, so its run stops here — as
          // does a pick scrape, which draws its wave and no arc.
          chain: if link.kind == "scrape" {
            none
          } else {
            (
              from: _joint(i, n.string, link-targets(n).len()),
              to: if target == none { none } else { _joint(target, n.string, 0) },
            )
          },
        ))
      }

      // A slide *out* of the note reaches nothing, so there is no note to find
      // and no half of it on another system: it is a stroke of its own length
      // leaving the number, in the direction the source named.
      let out = slide-out(n)
      if out != none {
        let tail = cursor + _system-tail(theme)
        connectors.push((
          kind: "slide",
          legato: out.at("legato", default: true),
          from: if stacked { cursor } else { pe.x },
          to: tail,
          edge: (cursor, tail),
          side: stacked,
          y: y,
          rising: out.out == "up",
        ))
      }

      // The other half of a link or a tie whose first note is on the line
      // above. A system is drawn on its own and cannot look back past its first
      // event, so the mark left on this note is the only trace of where it came
      // from — and when an earlier event here does play the string, the whole
      // arc has already been drawn and this would double it.
      let carried = (
        i > 0 and placed.slice(0, i).any(q => q.event.notes.any(o => o.string == n.string))
      )
      let arriving = if n.at("linked-in", default: none) != none {
        n.linked-in
      } else if n.at("tied-in", default: false) {
        (kind: "tie", legato: true)
      } else { none }
      if arriving != none and not carried {
        let edge = pe.x - size.width / 2
        let lead = calc.max(0pt, edge - _system-tail(theme))
        connectors.push((
          kind: arriving.kind,
          legato: arriving.at("legato", default: true),
          from: lead,
          to: if stacked { edge } else { pe.x },
          edge: (lead, edge),
          side: stacked,
          y: y,
          rising: false,
        ))
      }

      let bend = get-technique(n, "bend")
      if bend != none {
        connectors.push((
          kind: "bend",
          from: pe.x,
          half-width: size.width / 2,
          y: y,
          bend: bend,
          slot: pe.left,
          alloc: pe.alloc,
          // A bent note that is tied is a bend *held*: the pitch stays up for
          // as long as the note sounds, and the rule says so as far as the last
          // event of the tie. It ends with that event's allocation rather than
          // at its number, since what is held is the sound, not the digit.
          hold: if tie-end == none {
            none
          } else {
            let last = placed.at(tie-end)
            last.left + last.alloc - 0.8 * theme.staff-space
          },
        ))
      }
    }
  }

  for pe in placed {
    for kind in ("arpeggiate", "rake") {
      let found = pe.event.notes.map(n => get-technique(n, kind)).find(t => t != none)
      if found == none { continue }
      let rows = pe.event.notes.map(n => n.string)
      let widest = pe
        .event
        .notes
        .map(n => measure(fret-label(theme, n.fret)).width)
        .fold(0pt, calc.max)
      strokes.push((
        kind: kind,
        // A downstroke runs thick string to thin — from the bottom of the staff
        // to the top — so its arrowhead is the upper one. That is also the
        // unmarked default an engraver assumes, which is why a bare `A` means
        // it.
        dir: found.at("dir", default: "down"),
        x: pe.x - widest / 2 - 0.45 * sp,
        top: string-y(theme, calc.min(..rows)) - 0.45 * sp,
        bottom: string-y(theme, calc.max(..rows)) + 0.45 * sp,
      ))
    }
  }

  // 2. String lines, broken around the numbers that sit on them. The TAB mark
  //    is not one of them: the reference sheets run their lines straight through
  //    it and let the letters sit over the top, and breaking them there leaves
  //    the outermost lines looking clipped.
  let mark = tab-mark(theme, strings)
  let lines = ()
  for s in range(1, strings + 1) {
    let y = string-y(theme, s)
    // The TAB letters knock the line out too, but only the lines they cross:
    // the outermost ones have no letter over them and stay whole.
    let mark-gaps = mark
      .bands
      .filter(b => y >= b.top - theme.gap-padding and y <= b.bottom + theme.gap-padding)
      .map(b => (start: b.x0 - theme.gap-padding, end: b.x1 + theme.gap-padding))
    let number-gaps = if theme.mask == "gap" {
      labels
        .filter(l => l.string == s)
        .map(l => (
          start: l.x - l.w / 2 - theme.gap-padding,
          end: l.x + l.w / 2 + theme.gap-padding,
        ))
    } else { () }
    // A rest crosses whatever lines it happens to span, and the gap is taken
    // from the ink at each line's own height rather than from the glyph's box:
    // a quarter rest is a narrow zigzag, and a line grazing its corner needs
    // nothing like the room one through its middle does. The clearance around
    // that ink is the same `gap-padding` a fret number gets, on every side —
    // which is also why the band is padded vertically, so a line passing just
    // outside the ink still clears it.
    //
    // The block rests are the exception: they are *measured* from their line,
    // so it has to run behind them or there is nothing left to tell a whole
    // rest from a half one.
    let rest-gaps = ()
    for rest in rests {
      if rest.glyph.height <= 0.5 * sp { continue }
      let span = g.ink-span(
        rest.glyph,
        y - rest.top - theme.gap-padding,
        y - rest.top + theme.gap-padding,
      )
      if span == none { continue }
      rest-gaps.push((
        start: rest.x + span.start - theme.gap-padding,
        end: rest.x + span.end + theme.gap-padding,
      ))
    }
    lines.push(_line-with-gaps(theme, y, width, _merge(mark-gaps + number-gaps + rest-gaps)))
  }

  // 3. Barlines. Every system opens with one at the staff edge; each measure
  //    then draws its own opening repeat sign and its closing barline.
  let bars = ()
  bars.push(barline(theme, h, "single").body)

  for m in system.measures {
    if m.measure.start-repeat {
      let b = barline(theme, h, "repeat-start")
      bars.push(place(top + left, dx: m.start, dy: 0pt, b.body))
    }
    let kind = if m.measure.end-repeat {
      "repeat-end"
    } else if m.measure.end == "final" {
      "final"
    } else if m.measure.end == "double" { "double" } else { "single" }
    let b = barline(theme, h, kind)
    bars.push(place(top + left, dx: m.end - b.width, dy: 0pt, b.body))
  }

  box(width: width, height: overflow + h + overflow-below(theme, strings, system), place(top + left, dy: overflow, box(
    width: width,
    height: h,
    {
      lines.join()
      bars.join()
      place(top + left, dx: 0pt, dy: 0pt, mark.body)

      // Time signatures, drawn over the lines rather than knocking them out —
      // the same choice the TAB mark makes, and what the reference sheets do.
      for pm in system.measures {
        if pm.meter == none { continue }
        place(top + left, dx: pm.meter.x, dy: 0pt, meter.draw(
          theme,
          strings,
          pm.time,
          pm.meter.width,
        ))
      }

      for l in labels {
        // An opaque patch instead of a broken line, when asked for.
        if theme.mask == "box" {
          place(
            top + left,
            dx: l.x - l.w / 2 - theme.gap-padding,
            dy: string-y(theme, l.string) - l.h / 2 - 0.1 * sp,
            rect(
              width: l.w + 2 * theme.gap-padding,
              height: l.h + 0.2 * sp,
              fill: white,
              stroke: none,
            ),
          )
        }
        place(
          top + left,
          dx: l.x - l.w / 2,
          dy: string-y(theme, l.string) - l.h / 2,
          l.body,
        )
      }

      for rest in rests {
        place(top + left, dx: rest.x, dy: rest.top, rest.glyph.body)
      }

      for st in strokes {
        // The squiggle stops exactly where the head begins rather than running
        // under it, which is how the reference sets the two: the arrow caps the
        // wave, it does not sit on top of it.
        let head = _ARPEGGIO-HEAD.length * sp
        let up = st.dir == "down"
        let y0 = st.top + (if up { head } else { 0pt })
        let y1 = st.bottom - (if up { 0pt } else { head })
        let wave = g.wavy(sp, y1 - y0, vertical: true, fill: theme.color)
        place(top + left, dx: st.x - wave.width, dy: y0, wave.body)
        _arrowhead(
          theme,
          st.x - wave.width / 2,
          if up { st.top } else { st.bottom },
          down: not up,
          half-width: _ARPEGGIO-HEAD.half-width,
          length: _ARPEGGIO-HEAD.length,
          waist: 0.0,
        )
        if st.kind == "rake" {
          place(
            top + left,
            dx: st.x - wave.width - 0.1 * sp,
            dy: st.top - theme.technique-size * 1.15,
            text(
              font: theme.font,
              size: theme.technique-size,
              fill: theme.color,
              top-edge: "cap-height",
              bottom-edge: "baseline",
              "rake",
            ),
          )
        }
      }

      // Connectors are drawn last so they sit over the numbers they join. What
      // they reach above the top string line is reserved by `overflow-above`.
      // Folding turns each run of linked notes into one `slur` and leaves the
      // links themselves to draw their lines, so `legato` here means "still owes
      // an arc of its own".
      for c in _fold-slurs(connectors) {
        if c.kind == "bend" {
          _bend-arrow(theme, c.from, c.half-width, c.y, c.bend, c.slot, c.alloc, hold: c.hold)
        } else if c.kind == "slur" {
          _slur(theme, c.from, c.to, c.y, side: c.side)
        } else if c.kind == "slide" {
          // The slide line runs between the numbers' facing edges; the slur over
          // them attaches wherever the event's shape allows.
          _slide-line(theme, c.edge.at(0), c.edge.at(1), c.y, c.rising)
          if c.legato { _slur(theme, c.from, c.to, c.y, side: c.side) }
        } else if c.kind == "scrape" {
          _scrape-line(theme, c.edge.at(0), c.edge.at(1), c.y)
        } else if c.kind == "tie" {
          _tie(theme, c.from, c.to, c.y, side: c.side)
        } else if c.legato {
          _slur(theme, c.from, c.to, c.y, side: c.side)
        }
      }
    },
  )))
}
