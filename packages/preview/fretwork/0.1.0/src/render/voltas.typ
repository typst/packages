// Voltas: the numbered brackets over first and second endings, and the repeat
// counts that share their lane.
//
// The bracket sits at the very top of a system, above everything else, and spans
// the measures belonging to the ending. Its right end is closed when the ending
// leads back to a repeat and left open when the music carries on — which is the
// convention that tells a first ending from a last one at a glance.
//
// A repeat count — "Play 4 times" over the sign that sends the reader back —
// belongs to the same lane: it is the only other mark that describes a whole
// measure rather than an event, and it sits at the same height as an ending's
// number so the two read as one row of instructions.

#import "../layout/lanes.typ": empty-lane, lane

/// Maximal runs of consecutive measures sharing the same ending.
///
/// Endings are recorded on each measure rather than as index ranges, for the
/// same reason spans are: a volta split across a system break must still draw
/// correctly on both halves.
#let _runs(system) = {
  let runs = ()
  let current = ()
  let active = none
  for m in system.measures {
    if m.measure.volta != none and m.measure.volta == active {
      current.push(m)
    } else {
      if current.len() > 0 { runs.push((volta: active, measures: current)) }
      current = if m.measure.volta == none { () } else { (m,) }
      active = m.measure.volta
    }
  }
  if current.len() > 0 { runs.push((volta: active, measures: current)) }
  runs
}

#let _has-volta(system) = system.measures.any(m => m.measure.volta != none)

/// Measures ending in a repeat that names how many times to play it.
#let _counted(system) = system.measures.filter(m => (
  m.measure.end-repeat and m.measure.at("repeat-count", default: none) != none
))

#let height(theme) = 1.7 * theme.staff-space

/// "Play 4 times", written out rather than set as "x4".
///
/// Twice is "Play twice", not "Play 2 times", which is what the reference
/// sheets say and what anyone reading aloud would.
#let _count-label(n) = if n == 2 { "Play twice" } else { "Play " + str(n) + " times" }

/// "1." for a single ending, "1.–3." for a range.
#let _label(numbers) = {
  if numbers.len() == 1 { return str(numbers.first()) + "." }
  str(numbers.first()) + ".–" + str(numbers.last()) + "."
}

/// Draw the volta brackets for one placed system.
#let draw(theme, system, width) = {
  let sp = theme.staff-space
  let h = height(theme)
  let rule = theme.barline
  let tick = 0.75 * sp
  // The bracket hangs from the top of the lane, leaving its number room below.
  let y = h - tick

  let caption(body) = text(
    font: theme.font,
    size: theme.technique-size,
    weight: 600,
    fill: theme.color,
    top-edge: "cap-height",
    bottom-edge: "baseline",
    body,
  )

  box(width: width, height: h, {
    // Repeat counts first, so an ending bracket starting at the same measure is
    // drawn over rather than under one.
    for m in _counted(system) {
      let body = caption(_count-label(m.measure.repeat-count))
      // Right-aligned on the sign it belongs to, which is where the reader is
      // looking when they reach it — but held clear of the boundary, since the
      // bracket of a following ending starts exactly there.
      place(
        top + left,
        dx: calc.max(0pt, m.end - measure(body).width - 1.3 * sp),
        dy: y + 0.22 * sp,
        body,
      )
    }

    for run in _runs(system) {
      let x0 = run.measures.first().start
      let x1 = run.measures.last().end
      // An ending that leads back to a repeat is closed off; one the music runs
      // out of is left open.
      let closed = run.measures.last().measure.end-repeat

      place(
        top + left,
        dx: x0,
        dy: y,
        rect(width: x1 - x0, height: rule, fill: theme.color, stroke: none),
      )
      place(top + left, dx: x0, dy: y, rect(width: rule, height: tick, fill: theme.color, stroke: none))
      if closed {
        place(
          top + left,
          dx: x1 - rule,
          dy: y,
          rect(width: rule, height: tick, fill: theme.color, stroke: none),
        )
      }
      place(
        top + left,
        dx: x0 + 0.45 * sp,
        dy: y + 0.22 * sp,
        caption(_label(run.volta)),
      )
    }
  })
}

/// The volta lane, collapsing when the music has neither endings nor counts.
#let lane-for(theme, system, width) = {
  if not _has-volta(system) and _counted(system).len() == 0 { return empty-lane }
  lane(height(theme), () => draw(theme, system, width))
}
