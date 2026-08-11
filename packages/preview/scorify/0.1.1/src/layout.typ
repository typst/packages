// layout.typ - Layout engine
//
// Takes parsed events + configuration and produces laid-out events
// with x,y positions for the renderer.

#import "model.typ": make-laid-out-event
#import "pitch.typ": staff-position, auto-stem-direction, compute-stem-end-y
#import "layout-spacing.typ": compute-event-positions, total-events-width
#import "constants.typ": *

/// Layout a single staff's events.
///
/// Parameters:
/// - events: array of parsed events
/// - clef: the initial clef string
/// - staff-space: size of one staff space (length)
/// - available-width: available horizontal width (in staff spaces, or none for unlimited)
///
/// Returns: dictionary with:
///   - items: array of laid-out events (each has x, y, event, stem-dir, stem-y-end)
///   - total-width: total width in staff spaces
#let layout-staff(
  events,
  clef: "treble",
  staff-space: default-staff-space,
  available-width: none,
) = {
  let positions = compute-event-positions(events)
  let items = ()
  let current-clef = clef

  for (i, event) in events.enumerate() {
    let pos-info = positions.at(i)
    let x = pos-info.x
    let y = 0.0
    let stem-dir = none
    let stem-y-end = none

    if event.type == "note" {
      // Compute staff position and Y coordinate
      let sp = staff-position(event.name, event.octave, clef: current-clef)
      y = -sp / 2.0
      stem-dir = auto-stem-direction(sp)
      stem-y-end = compute-stem-end-y(y, sp, stem-dir, 1.0)
      items.push(make-laid-out-event(event, x: x, y: y, stem-dir: stem-dir, stem-y-end: stem-y-end))
    } else if event.type == "chord" {
      // Compute per-note staff positions and y values
      let sp-list = event.notes.map(n => staff-position(n.name, n.octave, clef: current-clef))
      let y-list  = sp-list.map(spos => -spos / 2.0)
      // Stem direction from average staff position
      let avg-sp = sp-list.fold(0.0, (acc, spos) => acc + spos) / sp-list.len()
      stem-dir = auto-stem-direction(avg-sp)
      // Primary note (stem-base): bottom note for stem-up, top note for stem-down
      let primary-sp = if stem-dir == "up" {
        sp-list.fold(sp-list.at(0), calc.max)
      } else {
        sp-list.fold(sp-list.at(0), calc.min)
      }
      y = -primary-sp / 2.0
      // Stem tip extends from the note furthest in the stem direction
      let tip-sp = if stem-dir == "up" {
        sp-list.fold(sp-list.at(0), calc.min)
      } else {
        sp-list.fold(sp-list.at(0), calc.max)
      }
      let tip-y = -tip-sp / 2.0
      stem-y-end = compute-stem-end-y(tip-y, tip-sp, stem-dir, 1.0)
      // Store per-note y values and staff positions alongside the layout item
      items.push((
        event: event,
        x: x,
        y: y,
        stem-dir: stem-dir,
        stem-y-end: stem-y-end,
        chord-ys: y-list,
        chord-staff-positions: sp-list,
      ))
    } else if event.type == "rest" {
      // Rests are centered vertically on the staff
      if event.duration == 1 {
        y = -1.0
      } else if event.duration == 2 {
        y = -2.0
      } else {
        y = -2.0
      }
      items.push(make-laid-out-event(event, x: x, y: y, stem-dir: stem-dir, stem-y-end: stem-y-end))
    } else if event.type == "clef" {
      current-clef = event.clef
      items.push(make-laid-out-event(event, x: x, y: y, stem-dir: stem-dir, stem-y-end: stem-y-end))
    } else {
      items.push(make-laid-out-event(event, x: x, y: y, stem-dir: stem-dir, stem-y-end: stem-y-end))
    }
  }

  let tw = total-events-width(events)

  (
    items: items,
    total-width: tw,
    clef: clef,
  )
}

/// Layout an entire score (multiple staves).
#let layout-score(
  staves-events,
  staves-config,
  staff-space: default-staff-space,
  available-width: none,
) = {
  let laid-out-staves = ()

  for (i, events) in staves-events.enumerate() {
    let config = staves-config.at(i)
    let clef = config.at("clef", default: "treble")
    let result = layout-staff(
      events,
      clef: clef,
      staff-space: staff-space,
      available-width: available-width,
    )
    laid-out-staves.push(result)
  }

  laid-out-staves
}
