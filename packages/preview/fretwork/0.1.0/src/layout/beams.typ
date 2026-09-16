// Beam grouping: which notes are joined by a beam, and how many beams they get.
//
// Grouping follows the time signature rather than the note values alone. Beams
// exist to show where the beats are, so a group never crosses a beat boundary
// even when the durations would allow it.

#import "../rational.typ" as r
#import "../model.typ": decompose, sounding-duration

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

/// The rhythmic unit that beams may not cross, as a rational.
///
/// Simple metres group by their own beat: a quarter in 4/4, an eighth in 3/8.
/// Compound metres — 6/8, 9/8, 12/8 — group by the dotted beat of three.
#let beat-unit(time) = {
  if time == none { return none }
  let (beats, unit) = time
  let compound = unit >= 8 and calc.rem(beats, 3) == 0 and beats > 3
  if compound { r.rat(3, den: unit) } else { r.rat(1, den: unit) }
}

/// Split a measure's events into beam groups.
///
/// Returns an array of arrays of event indices. A group of one is drawn with a
/// flag; a group of two or more is beamed. Events that cannot be beamed — rests,
/// quarters and longer, unknown durations — end the group they interrupt and
/// form no group of their own.
#let group-beams(events, time) = {
  let unit = beat-unit(time)
  let groups = ()
  let current = ()
  let position = r.zero

  for (i, ev) in events.enumerate() {
    let flags = flags-of(ev)
    // A grace note carries its own small flag and is never beamed to the note
    // it ornaments: beaming the two would say they share a beat, which is the
    // one thing a grace note does not do.
    let grace = ev.at("grace", default: none) != none
    let beamable = flags != none and flags >= 1 and ev.kind != "rest" and not grace

    // A group ends at a beat boundary, so beams keep showing where the beats
    // are even in a bar of unbroken sixteenths.
    // Exact because durations are rational: the position is on a beat when it
    // divides into whole beats with nothing left over.
    let on-beat = unit != none and r.div(position, unit).den == 1

    if not beamable {
      if current.len() > 0 { groups.push(current) }
      current = ()
    } else {
      if current.len() > 0 and on-beat {
        groups.push(current)
        current = ()
      }
      current.push(i)
    }

    let d = sounding-duration(ev)
    if d == none {
      // Without a duration there is no beat grid left to follow.
      if current.len() > 0 { groups.push(current) }
      current = ()
    } else {
      position = r.add(position, d)
    }
  }

  if current.len() > 0 { groups.push(current) }
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
#let tuplet-runs(events) = {
  let runs = ()
  let current = ()
  let active = none
  for (i, ev) in events.enumerate() {
    if ev.tuplet == active and ev.tuplet != none {
      current.push(i)
    } else {
      if current.len() > 0 { runs.push((tuplet: active, indices: current)) }
      current = if ev.tuplet == none { () } else { (i,) }
      active = ev.tuplet
    }
  }
  if current.len() > 0 { runs.push((tuplet: active, indices: current)) }
  runs
}
