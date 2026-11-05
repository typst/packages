// Beam grouping: which notes are joined by a beam, and how many beams they get.
//
// Grouping follows the time signature rather than the note values alone. Beams
// exist to show how the bar is counted, so a group ends where the metre says it
// may — which is not the same as ending on every beat. `metre.typ` holds those
// rules; this file applies them to a bar of events.

#import "../rational.typ" as r
#import "../model.typ": decompose, sounding-duration
// `beat-unit` is re-exported: it is what parts consecutive tuplets, below.
#import "metre.typ": beam-boundaries, beat-unit

/// How many flags or beams an event's note value carries.
///
/// A quarter has none, an eighth one, a sixteenth two. Half and whole notes
/// return negative counts, which is what marks them as unbeamable.
/// Returns `none` when the duration is unknown or not a written note value.
#let flags-of(ev) = {
  if ev.duration == none { return none }
  let d = decompose(ev.duration)
  if d == none { return none }
  if d.base.num != 1 { return none }
  let k = 0
  while calc.pow(2, k) < d.base.den { k += 1 }
  k - 2
}

/// Number of augmentation dots on an event, or 0.
#let dots-of(ev) = {
  if ev.duration == none { return 0 }
  let d = decompose(ev.duration)
  if d == none { return 0 } else { d.dots }
}

/// Whether an event can carry a beam at all.
///
/// Rests, quarters and longer, and events of unknown duration cannot. Nor can a
/// grace note: it carries its own small flag and is never beamed to the note it
/// ornaments, since beaming the two would say they share a beat, which is the
/// one thing a grace note does not do.
#let _beamable(ev) = {
  let flags = flags-of(ev)
  let grace = ev.at("grace", default: none) != none
  flags != none and flags >= 1 and ev.kind != "rest" and not grace
}

/// Maximal runs of beamable events, each index paired with where it falls in
/// the bar.
///
/// The position is `none` from the first event whose duration is unknown
/// onwards, since there is no grid left to measure against; a run carrying one
/// is never split.
#let _beamable-runs(events) = {
  let runs = ()
  let current = ()
  let position = r.zero

  for (i, ev) in events.enumerate() {
    if _beamable(ev) {
      current.push((index: i, pos: position))
    } else if current.len() > 0 {
      runs.push(current)
      current = ()
    }

    let d = sounding-duration(ev)
    position = if position == none or d == none { none } else { r.add(position, d) }
  }

  if current.len() > 0 { runs.push(current) }
  runs
}

/// The shortest sounding value in a run, which is what chooses its rule.
///
/// Sounding rather than written, so that a triplet of eighths is measured as the
/// twelfth of a whole note it actually occupies.
#let _shortest(events, run) = {
  let shortest = none
  for e in run {
    let d = sounding-duration(events.at(e.index))
    if d != none and (shortest == none or r.lt(d, shortest)) { shortest = d }
  }
  shortest
}

/// Split one run of beamable events at the boundaries its metre allows.
///
/// A boundary parts the run only where an event falls exactly on it. A figure
/// that steps over one — an eighth straddling a beat in a run of sixteenths —
/// stays whole, which is what says the syncopation is deliberate.
#let _split-run(events, run, time) = {
  let bounds = beam-boundaries(time, _shortest(events, run))
  let groups = ()
  let current = ()

  for e in run {
    // Exact, because durations are rational and `rat` normalises: two positions
    // are equal precisely when their dictionaries are.
    let ends-here = e.pos != none and bounds.any(b => b == e.pos)
    if current.len() > 0 and ends-here {
      groups.push(current)
      current = ()
    }
    current.push(e.index)
  }

  if current.len() > 0 { groups.push(current) }
  groups
}

/// Split a measure's events into beam groups.
///
/// Returns an array of arrays of event indices. A group of one is drawn with a
/// flag; a group of two or more is beamed. Events that cannot be beamed end the
/// group they interrupt and form no group of their own.
///
/// The work is done in two passes because the rule depends on what the run turns
/// out to hold: its shortest value chooses the boundaries. So a bar of eighths
/// in 4/4 beams in half-bars, while a single sixteenth among them pulls the
/// whole run back to the beat.
///
/// ```typc
/// // Eight eighths in 4/4 make two groups of four, not four pairs.
/// assert.eq(group-beams(bar, (4, 4)), ((0, 1, 2, 3), (4, 5, 6, 7)))
/// ```
#let group-beams(events, time) = {
  let groups = ()
  for run in _beamable-runs(events) {
    groups += _split-run(events, run, time)
  }
  groups
}

/// Maximal runs within a beam group that share at least `level` beams.
///
/// The primary beam spans the whole group; a secondary beam only spans the
/// notes fast enough to need it, which is why sixteenths inside a group of
/// eighths get a short stub rather than a full second beam.
#let sub-beams(events, group, level) = {
  let runs = ()
  let current = ()
  for i in group {
    let flags = flags-of(events.at(i))
    if flags != none and flags >= level {
      current.push(i)
    } else {
      if current.len() > 0 { runs.push(current) }
      current = ()
    }
  }
  if current.len() > 0 { runs.push(current) }
  runs
}

/// Maximal runs of consecutive events sharing the same tuplet.
///
/// Spans and tuplets are both recorded per event rather than as index ranges,
/// so that a group split across a system break still draws correctly on both
/// halves. Finding the runs is how a renderer recovers the grouping.
///
/// Two triplets written one after the other carry identical records — a triplet
/// is `(count: 3, of: 2)` whichever group it belongs to — so nothing in the
/// events themselves parts them. `time` does, at a beat boundary, which is the
/// rule beam grouping already follows and which a tuplet obeys for the same
/// reason: it exists to say how one beat is divided. Without a signature the
/// two merge, which is what a caller wanting only the ratio asks for.
///
/// ```typc
/// // Two triplets of eighths fill one beat each in 4/4, and get one run apiece.
/// assert(tuplet-runs(bar, time: (4, 4)).len() == 2)
/// ```
#let tuplet-runs(events, time: none) = {
  let unit = beat-unit(time)
  let runs = ()
  let current = ()
  let active = none
  let position = r.zero

  for (i, ev) in events.enumerate() {
    // Exact because durations are rational: the position is on a beat when it
    // divides into whole beats with nothing left over.
    let on-beat = unit != none and r.div(position, unit).den == 1
    if ev.tuplet == active and ev.tuplet != none and not on-beat {
      current.push(i)
    } else {
      if current.len() > 0 { runs.push((tuplet: active, indices: current)) }
      current = if ev.tuplet == none { () } else { (i,) }
      active = ev.tuplet
    }

    let d = sounding-duration(ev)
    if d == none {
      // No duration, no beat grid: the runs that follow can only be told apart
      // by their records, so stop parting them rather than part them wrongly.
      unit = none
    } else {
      position = r.add(position, d)
    }
  }

  if current.len() > 0 { runs.push((tuplet: active, indices: current)) }
  runs
}
