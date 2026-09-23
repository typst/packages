// The lyric lanes: one per verse, at the foot of the system.
//
// A syllable is centred on the event it is sung on, exactly as the fret number
// above it is, and an event with nothing to sing is simply left blank. That is
// the layout the reference sheets use — the syllables ride on the guitar's own
// rhythm rather than carrying one of their own, which is also the only layout
// a single stream of events can express.
//
// A word held across several notes is written once, where it starts. The tab
// sheets leave the held notes bare; a vocal score rules an extender to the last
// of them, which `lyric-extender` on the theme asks for. A word broken in two
// carries a hyphen, its own character centred in the gap between the syllables
// rather than tucked against the first — and set at the end of the line where a
// system break falls between the halves.

#import "../layout/lanes.typ": empty-lane, lane
#import "../rational.typ" as r
#import "../model.typ" as md

/// The syllable a verse sings at an event, or `none`.
#let syllable-at(ev, verse) = ev.at("lyrics", default: ()).at(verse, default: none)

/// The syllables a measure sings between its events rather than on one.
///
/// A bar the part rests through is a *single* event, so a phrase sung across it
/// has only that one place to go. These carry their own moment instead — see
/// `_floating`, which is the whole reason a borrowed verse can be set at all.
#let floating-in(meas, verse) = meas.at("floating", default: ()).filter(s => s.verse == verse)

/// How many verses a part carries.
#let verse-count(part) = {
  let n = 0
  for m in part.measures {
    for ev in m.events {
      n = calc.max(n, ev.at("lyrics", default: ()).len())
    }
    for s in m.at("floating", default: ()) {
      n = calc.max(n, s.verse + 1)
    }
  }
  n
}

/// A syllable, set for measurement and for drawing.
#let label(theme, body) = text(
  font: theme.lyric-font,
  size: theme.lyric-size,
  fill: theme.color,
  body,
)

/// The widest syllable an event sings, across every verse.
///
/// This is what the spacing engine reserves room for, so it is measured once
/// here and used both there and when drawing.
///
/// Must be called from a context, since it measures type.
#let event-width(theme, ev) = {
  let widths = ev
    .at("lyrics", default: ())
    .filter(s => s != none and s.kind == "syllable")
    .map(s => measure(label(theme, s.text)).width)
  widths.fold(0pt, calc.max)
}

/// The syllables a measure sings away from its events, with their widths.
///
/// The spacing engine needs these before anything is drawn. A syllable hung on
/// an event bought its room with that event; one placed by its own moment bought
/// none — the bar is spaced for what it *plays*, and a bar the part rests through
/// is one whole rest wide however much is sung across it.
///
/// Must be called from a context, since it measures type.
#let floating-widths(theme, meas) = {
  meas
    .at("floating", default: ())
    .map(s => (
      verse: s.verse,
      position: s.position,
      width: measure(label(theme, s.syllable.text)).width,
    ))
}

/// Height of one verse's lane.
///
/// Measured from a string with both an ascender and a descender rather than
/// from the type size, so a syllable ending in `g` cannot hang into whatever
/// the next lane draws.
#let height(theme) = measure(label(theme, "Hgy")).height

/// Where a moment falls across a placed measure.
///
/// **Not a fraction of the bar's width.** Events are spaced optically — a whole
/// note is nothing like four times a quarter — so a moment read off the bar's
/// width lands nowhere near the note sounding then, and a syllable placed that
/// way collides with the ones sitting on their own events. The moment is
/// interpolated between the *notes* instead, which is the same timeline the
/// event-attached syllables already use, so the two agree.
///
/// A bar with no notes in it — the one a phrase is sung across while the part
/// rests — has nothing to interpolate between, and only there does the bar's own
/// width stand in. A rest is never used as a fixed point: where one is *drawn* is
/// a convention of the notation, not when it begins.
#let _moment-x(pm, position) = {
  let bar = pm.time.at(0) / pm.time.at(1)
  // Fixed points: the bar's two ends, and every note between them at its onset.
  let points = ((0.0, pm.start), (bar, pm.end))
  let at = r.zero
  for pe in pm.events {
    let d = md.sounding-duration(pe.event)
    if d == none { break }
    if pe.event.kind != "rest" { points.push((r.to-float(at), pe.x)) }
    at = r.add(at, d)
  }
  points = points.sorted(key: p => p.at(0))

  let want = r.to-float(position)
  let before = points.first()
  let after = points.last()
  for p in points {
    if p.at(0) <= want { before = p }
  }
  for p in points.rev() {
    if p.at(0) >= want { after = p }
  }
  let span = after.at(0) - before.at(0)
  if span <= 0 { return before.at(1) }
  before.at(1) + (after.at(1) - before.at(1)) * ((want - before.at(0)) / span)
}

/// Draw the syllables a measure sings away from its events, each at its moment.
#let _floating(theme, pm, verse) = {
  for s in floating-in(pm.measure, verse) {
    let body = label(theme, s.syllable.text)
    let size = measure(body)
    place(top + left, dx: _moment-x(pm, s.position) - size.width / 2, dy: 0pt, body)
  }
}

/// The **left edge** of the first thing this verse sings on the system, or `none`.
///
/// Its number goes to the left of that, which is where a printed stanza puts it:
/// against the words rather than out in the margin, so the reader's eye finds it
/// on the way into the line.
///
/// The edge and not the centre. A syllable is *centred* on its moment, so half of
/// it lies left of the x it is placed at; a number set against that x lands on top
/// of the word rather than before it.
#let _first-left(theme, system, verse) = {
  let best = none
  for pm in system.measures {
    for pe in pm.events {
      let s = syllable-at(pe.event, verse)
      if s == none or s.kind != "syllable" { continue }
      let edge = pe.x - measure(label(theme, s.text)).width / 2
      if best == none or edge < best { best = edge }
    }
    for s in floating-in(pm.measure, verse) {
      let edge = (
        _moment-x(pm, s.position) - measure(label(theme, s.syllable.text)).width / 2
      )
      if best == none or edge < best { best = edge }
    }
  }
  best
}

/// Rule out the notes a word is held over, from the syllable to the last of them.
///
/// A vocal score draws this; the published tab sheets do not, writing the word
/// once and leaving the held notes bare — so `lyric-extender` on the theme says
/// which of the two this sheet is. Without it a held note and an unsung one look
/// alike on the page, which is fine for an accompaniment and wrong for a line
/// somebody has to sing.
///
/// The run ends at the next real syllable, and also where the verse stops
/// singing: `none` is not a held note, it is nothing at all.
#let _extender(theme, placed, from-index, verse, from-x) = {
  if not theme.lyric-extender { return }
  let last = none
  for j in range(from-index + 1, placed.len()) {
    let later = syllable-at(placed.at(j).event, verse)
    if later == none or later.kind != "hold" { break }
    last = placed.at(j).x
  }
  if last == none { return }
  let start = from-x + theme.staff-space * 0.2
  if last <= start { return }
  place(
    top + left,
    dx: start,
    // On the baseline of the words it continues, which is where the reader's eye
    // already is: measured down the lane rather than from the staff above it.
    dy: height(theme) * 0.72,
    line(length: last - start, stroke: theme.line * 2),
  )
}

/// Draw one verse for a placed system.
///
/// `numbered` draws the verse's number before its first syllable, which is what
/// tells one stanza's row from another's when a repeated passage carries a
/// different set of words each time round. `tag` replaces that number with
/// whatever the caller wants there — `""` for a row that shares the number over
/// the row above it, which is how one stanza spanning two passes is set.
#let draw(theme, system, width, verse, numbered: false, tag: none) = {
  let placed = system.measures.map(m => m.events).flatten()

  box(width: width, height: height(theme), {
    for pm in system.measures {
      _floating(theme, pm, verse)
    }
    // An empty tag is how two rows share one stanza number: the second is given
    // nothing to print, and the number over the first stands for both.
    let mark = if tag != none { tag } else { str(verse + 1) + "." }
    if numbered and mark != "" {
      let edge = _first-left(theme, system, verse)
      if edge != none {
        let body = label(theme, mark)
        let size = measure(body)
        // Clear of the syllable it precedes, and never off the left edge. The gap is measured
        // in the staff's own unit so it holds at any size, like every other measurement here.
        let gap = theme.staff-space * 0.3
        place(top + left, dx: calc.max(0pt, edge - size.width - gap), dy: 0pt, body)
      }
    }
    for (i, pe) in placed.enumerate() {
      let s = syllable-at(pe.event, verse)
      // A held note carries no word of its own; the extender below is what shows
      // that the word before it is still sounding.
      if s == none or s.kind != "syllable" { continue }
      let body = label(theme, s.text)
      let size = measure(body)
      place(top + left, dx: pe.x - size.width / 2, dy: 0pt, body)
      _extender(theme, placed, i, verse, pe.x + size.width / 2)
      if not s.hyphen { continue }

      // The hyphen belongs to the word rather than to either syllable, so it is
      // centred between them.
      // Past any note the first half is held over: the hyphen belongs between
      // the two halves of the word, not against a note that sings neither.
      let next = none
      for j in range(i + 1, placed.len()) {
        let later = syllable-at(placed.at(j).event, verse)
        if later == none or later.kind != "syllable" { continue }
        next = (x: placed.at(j).x, width: measure(label(theme, later.text)).width)
        break
      }
      let dash = label(theme, "-")
      let dash-size = measure(dash)
      let from = pe.x + size.width / 2
      // A word the system break cuts in two still carries a hyphen, set at the
      // end of the line: it is what tells the reader the word runs on rather
      // than ending there, and it is the half of the mark this line can show.
      if next == none {
        place(top + left, dx: from + theme.staff-space * 0.2, dy: 0pt, dash)
        continue
      }
      let to = next.x - next.width / 2
      // Nothing to centre in when the two syllables already touch.
      if to - from < dash-size.width { continue }
      place(top + left, dx: (from + to - dash-size.width) / 2, dy: 0pt, dash)
    }
  })
}

/// Whether a verse sings anything on this system.
#let sings(system, verse) = system.measures.any(m => (
  m.events.any(pe => syllable-at(pe.event, verse) != none)
    or floating-in(m.measure, verse).len() > 0
))

/// One verse's lane, or an empty lane when it sings nothing on this system.
///
/// `numbered` marks the system where the verse begins, which is the one that
/// carries its number.
#let lane-for(theme, system, width, verse, numbered: false, tag: none) = {
  if not sings(system, verse) { return empty-lane }
  lane(height(theme), () => draw(theme, system, width, verse, numbered: numbered, tag: tag))
}
