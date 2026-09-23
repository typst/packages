// Breaking music into systems, and placing events along each one.
//
// The result is a single array of x-positions per system, shared by every lane
// drawn on it. That sharing is deliberate: a chord name, a rhythm stem and a
// fret number belonging to the same event must line up vertically, and a
// notation staff added later lines up for free by consuming the same positions.

#import "../rational.typ" as r
#import "../tuning.typ": string-count
#import "spacing.typ": barline-allowance, measure-natural, measure-total, meter-allowance

/// Pack measures greedily into systems.
///
/// `widths` holds one packed width per measure — its natural width plus its
/// barline allowance. `indent` is what the system start consumes before any
/// music, i.e. the vertical TAB mark.
///
/// A measure wider than the whole line still gets a system of its own rather
/// than being dropped.
#let pack(widths, available, indent) = {
  let limit = available - indent
  let systems = ()
  let current = ()
  let used = 0pt

  for (i, w) in widths.enumerate() {
    if current.len() > 0 and used + w > limit {
      systems.push(current)
      current = ()
      used = 0pt
    }
    current.push(i)
    used += w
  }
  if current.len() > 0 { systems.push(current) }
  systems
}

/// How far to stretch a system so it reaches the right margin.
///
/// Justification is proportional: one factor applied to every natural width,
/// so measures keep their relative sizes and a bar of sixteenths does not end
/// up as wide as a bar of whole notes.
///
/// A passage that fills **one** system and stops is left unstretched when it is
/// barely started, the way the last line of a paragraph is — four events spread
/// across a full page read as a mistake rather than as music, and a riff quoted
/// on its own is the common case.
///
/// The system that *closes* a longer passage is spaced at the **density of the
/// one above it** instead: `previous` is that system's factor, and this one is
/// stretched by no more, and never past the margin. Left at its natural width it
/// says its bars are shorter than the bars above — and two bars that do not fit
/// on one line are a bar to the system, usually the same bar twice, which is
/// exactly where a reader sees that the page is lying. Stretched to the margin
/// regardless it says the opposite, spreading a two-note tail over a whole line.
/// Matching the density says neither: the closing system is written like the
/// rest of the music, and stops where the music stops.
#let justify-factor(stretchable, available, alone: false, previous: none, min-fill: 0.65) = {
  if stretchable <= 0pt { return 1.0 }
  let factor = available / stretchable
  // Overfull: it has to be squeezed whatever else is true of it.
  if factor <= 1.0 { return factor }
  if alone and available > 0pt and stretchable / available < min-fill { return 1.0 }
  // Never *tighter* than natural, however tight the system above had to be.
  if previous != none { return calc.min(factor, calc.max(1.0, previous)) }
  factor
}

/// Assign an x-position to every event in one system.
///
/// Returns `(measures: (…), width: length)`, where each measure carries its
/// start and end x and its events carry the x at which their fret number is
/// centred. Barline allowances are *not* scaled: a repeat sign is a fixed piece
/// of graphic, so only the music between barlines stretches.
#let place-system(theme, strings, measures, times, naturals, glyph-widths, indices, factor, indent, show-time: true) = {
  let x = indent
  let placed = ()

  for mi in indices {
    let m = measures.at(mi)
    let start = x
    if m.start-repeat { x += 1.1 * theme.staff-space }
    // A time signature is leading furniture: it stands between the opening
    // barline and the first note, so its room comes off the front of the
    // measure rather than the back, where the closing barline's does.
    let meter-x = x
    let meter = meter-allowance(theme, strings, m, times.at(mi), show-time and mi == 0)
    x += meter
    x += theme.measure-padding * factor

    let events = ()
    for (i, ev) in m.events.enumerate() {
      let alloc = naturals.at(mi).events.at(i) * factor
      let gw = glyph-widths.at(mi).at(i, default: (total: 0pt, anchor: 0pt))
      events.push((
        event: ev,
        // Aligned on the event's own number, not on the whole run it prints, so
        // a rhythm stem stays over the note it belongs to even when a hammer-on
        // target follows it.
        x: x + gw.anchor / 2 + theme.min-event-gap / 2,
        left: x,
        alloc: alloc,
        glyph-width: gw.total,
      ))
      x += alloc
    }

    x += theme.measure-padding * factor
    x += barline-allowance(theme, m) - (if m.start-repeat { 1.1 * theme.staff-space } else { 0pt })
    placed.push((
      index: mi,
      measure: m,
      // The signature in force here, not merely one declared here: renderers
      // need it for beam grouping and for the count row.
      time: times.at(mi),
      // Where to print that signature, and `none` where it is not printed —
      // so the renderer draws what it is told rather than re-deciding.
      meter: if meter > 0pt { (x: meter-x, width: meter) } else { none },
      start: start,
      end: x,
      events: events,
    ))
  }

  (measures: placed, width: x)
}

/// Widen allocations so that two syllables cannot collide.
///
/// Fret numbers are narrow and centred on their own event, so one independent
/// width per event describes them completely, which is all `event-natural`
/// returns. Syllables are not like that: one is routinely wider than the room
/// its note bought, and how much room it needs depends on its *neighbour* —
/// the gap between events *i* and *i+1* has to hold half of each syllable and
/// air between them. That is a relation between two events rather than a width
/// of one.
///
/// It also crosses barlines, which is why it is applied here, to the whole part
/// in order, rather than inside `measure-natural`, which sees one measure.
#let _widen-for-lyrics(theme, measures, naturals, glyph-widths) = {
  let lyric-of(mi, i) = (
    glyph-widths.at(mi, default: ()).at(i, default: (:)).at("lyric", default: 0pt)
  )
  // One sequence over the whole part, so the last syllable of a measure still
  // keeps the first syllable of the next one away from it.
  let seq = ()
  for (mi, meas) in measures.enumerate() {
    for i in range(meas.events.len()) { seq.push((mi, i)) }
  }
  if seq.all(((mi, i)) => lyric-of(mi, i) == 0pt) { return naturals }

  let needed = measures.map(meas => meas.events.map(_ => 0pt))
  for (k, pair) in seq.enumerate() {
    let (mi, i) = pair
    let here = lyric-of(mi, i)
    let next = if k + 1 < seq.len() { lyric-of(..seq.at(k + 1)) } else { 0pt }
    if here == 0pt and next == 0pt { continue }
    let row = needed.at(mi)
    row.at(i) = (here + next) / 2 + theme.lyric-gap
    needed.at(mi) = row
  }

  naturals
    .enumerate()
    .map(((mi, n)) => {
      let widths = n.events.enumerate().map(((i, w)) => calc.max(w, needed.at(mi).at(i)))
      (events: widths, total: measure-total(theme, widths))
    })
}

/// Widen a measure until the syllables sung across it stop colliding.
///
/// [`_widen-for-lyrics`] handles the ones hung on events: each buys its room with
/// the event it sits on. A syllable placed by its own moment buys none — the bar
/// is spaced for what it *plays*, and a bar the part rests through is one whole
/// rest wide however much is sung over it. A bridge of five such bars with six
/// words falling across two of them came out with the words on top of each other.
///
/// The width follows from the moments themselves: two syllables an eighth of a
/// bar apart need the bar to be eight times the room the two of them take. The
/// widest such demand wins, and only within one verse — two verses are two lanes
/// and cannot collide however close they fall.
///
/// The shortfall is spread across the measure's events in proportion, so a bar
/// widened for its words still spaces its music evenly.
#let _widen-for-floating(theme, times, naturals, floating-widths) = {
  naturals
    .enumerate()
    .map(((mi, n)) => {
      let here = floating-widths.at(mi, default: ())
      let sig = times.at(mi)
      let bar = sig.at(0) / sig.at(1)
      if here.len() < 2 or bar <= 0 { return n }

      let wanted = 0pt
      for verse in here.map(s => s.verse).dedup() {
        let lane = here.filter(s => s.verse == verse).sorted(key: s => r.to-float(s.position))
        for k in range(1, lane.len()) {
          let (a, b) = (lane.at(k - 1), lane.at(k))
          let apart = (r.to-float(b.position) - r.to-float(a.position)) / bar
          if apart <= 0 { continue }
          wanted = calc.max(wanted, ((a.width + b.width) / 2 + theme.lyric-gap) / apart)
        }
      }

      let have = n.events.fold(0pt, (a, b) => a + b)
      if wanted <= have or have <= 0pt { return n }
      let widths = n.events.map(w => w * (wanted / have))
      (events: widths, total: measure-total(theme, widths))
    })
}

/// Break a part into placed systems.
///
/// `glyph-widths` is a per-measure array of per-event widths, measured by the
/// caller. `available` is the usable line width.
/// `show-time` prints the signature in force at the first measure. A passage
/// set as its own `tab` block gets one; a later block of the same piece, or a
/// later section of one imported tab, passes `false` so the reader is not told
/// twice.
#let layout-part(
  theme,
  part,
  glyph-widths,
  available,
  indent,
  show-time: true,
  floating-widths: (),
) = {
  // The signature in force at each measure, carried forward in one pass —
  // calling `time-signature-at` per measure rescans the part each time, which
  // is quadratic over the piece.
  let times = ()
  let sig = part.time
  for m in part.measures {
    if m.time != none { sig = m.time }
    times.push(sig)
  }
  let strings = string-count(part.tuning)
  let naturals = _widen-for-floating(
    theme,
    times,
    _widen-for-lyrics(
      theme,
      part.measures,
      part
        .measures
        .enumerate()
        .map(((i, m)) => measure-natural(theme, m, glyph-widths.at(i, default: ()))),
      glyph-widths,
    ),
    floating-widths,
  )
  // Furniture: fixed graphic that never stretches with justification.
  let furniture(i) = (
    barline-allowance(theme, part.measures.at(i))
      + meter-allowance(theme, strings, part.measures.at(i), times.at(i), show-time and i == 0)
  )
  let packed-widths = part
    .measures
    .enumerate()
    .map(((i, _)) => naturals.at(i).total + furniture(i))

  let groups = pack(packed-widths, available, indent)

  // Sequential rather than a `map`: the system that closes the part is spaced
  // against the one above it, so its factor is not knowable on its own.
  let factors = ()
  for (gi, indices) in groups.enumerate() {
    let fixed = indices.fold(0pt, (acc, mi) => acc + furniture(mi))
    let stretchable = indices.fold(0pt, (acc, mi) => acc + naturals.at(mi).total)
    factors.push(justify-factor(
      stretchable,
      available - indent - fixed,
      alone: groups.len() == 1,
      previous: if gi > 0 and gi == groups.len() - 1 { factors.at(gi - 1) } else { none },
    ))
  }

  groups
    .enumerate()
    .map(((gi, indices)) => place-system(
      theme,
      strings,
      part.measures,
      times,
      naturals,
      glyph-widths,
      indices,
      factors.at(gi),
      indent,
      show-time: show-time,
    ))
}
