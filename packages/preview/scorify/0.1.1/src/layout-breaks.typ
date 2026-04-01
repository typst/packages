// layout-breaks.typ - System/line break algorithm
//
// Splits events into systems (lines) based on line-break markers,
// measures-per-line, or available width.

#import "layout-spacing.typ": event-width

/// Split events into measures (delimited by barlines).
/// Each measure is an array of events. Barlines are included at the
/// end of the measure they close.
#let split-into-measures(events) = {
  let measures = ()
  let current = ()
  for event in events {
    current.push(event)
    if event.type == "barline" {
      measures.push(current)
      current = ()
    }
  }
  // Remaining events after the last barline (or if no barlines)
  if current.len() > 0 {
    measures.push(current)
  }
  measures
}

/// Calculate the total layout width of a group of events.
#let measure-width(events) = {
  let w = 0.0
  for ev in events {
    w += event-width(ev)
  }
  w
}

/// Split events at line-break markers.
/// Returns an array of event arrays (one per system).
/// Line-break events are consumed and not included in any system.
#let split-at-line-breaks(events) = {
  let systems = ()
  let current = ()
  for event in events {
    if event.type == "line-break" {
      if current.len() > 0 {
        systems.push(current)
        current = ()
      }
    } else {
      current.push(event)
    }
  }
  if current.len() > 0 {
    systems.push(current)
  }
  systems
}

/// Check if events contain any line-break markers.
#let has-line-breaks(events) = {
  events.any(ev => ev.type == "line-break")
}

/// Determine where to break the music into systems (lines).
///
/// Parameters:
/// - events: flat array of parsed events
/// - available-width: available width in staff-space units (after prefix).
///   If none, returns all events in a single system (unless measures-per-line is set).
/// - measures-per-line: if set, force a break after this many measures.
///
/// Returns: array of event arrays, one per system.
#let compute-system-breaks(events, available-width: none, measures-per-line: none) = {
  let measures = split-into-measures(events)
  if measures.len() == 0 { return ((),) }

  // Fixed measures-per-line mode
  if measures-per-line != none and measures-per-line > 0 {
    let systems = ()
    let current-events = ()
    let measure-count = 0
    for measure in measures {
      current-events += measure
      measure-count += 1
      if measure-count >= measures-per-line {
        systems.push(current-events)
        current-events = ()
        measure-count = 0
      }
    }
    if current-events.len() > 0 {
      systems.push(current-events)
    }
    return systems
  }

  // Width-based breaking
  if available-width == none or available-width <= 0 {
    return (events,)
  }

  let systems = ()
  let current-events = ()
  let current-width = 0.0

  for measure in measures {
    let mw = measure-width(measure)
    if current-events.len() > 0 and current-width + mw > available-width {
      // Start a new system
      systems.push(current-events)
      current-events = ()
      current-width = 0.0
    }
    current-events += measure
    current-width += mw
  }

  // Push the last system
  if current-events.len() > 0 {
    systems.push(current-events)
  }

  systems
}
