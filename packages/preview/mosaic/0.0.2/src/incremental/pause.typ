// Construction and validation of source-order incremental pause markers.
#import "../shared.typ": tag, is-record

#let pause-field-keys = ("kind", "mosaic")

#let is-pause(value) = is-record(value, "pause", pause-field-keys, "pause")

#let pause-segments(children) = {
  let segments = ((),)
  for child in children {
    if is-pause(child) {
      segments.push(())
    } else {
      segments.last().push(child)
    }
  }
  segments
}

#let has-pause(children) = children.any(is-pause)

#let pause-schedule(children, duration) = {
  let result = ()
  let start = 1
  // A segment can span no step of its own yet still carry authored content —
  // a segment holding only a speaker note has duration zero. Such children
  // ride with the next spanning segment (or the last one, when nothing
  // follows) rather than being dropped from the schedule.
  let pending = ()
  for segment in pause-segments(children) {
    // A segment with no children of its own spans no step, regardless of what
    // `duration` would say about an empty array in isolation: `array-max(())`
    // returns 1 so a slide with no incremental content still gets one frame,
    // but that top-level fallback must not leak into a genuinely empty
    // segment between two pauses. Folding it here, before `duration` runs,
    // keeps the fallback intact while still collapsing empty leading,
    // trailing, or consecutive pauses.
    let span = if segment.len() == 0 { 0 } else { duration(segment) }
    if span > 0 {
      result.push((children: pending + segment, start: start, duration: span))
      pending = ()
      start += span
    } else {
      pending += segment
    }
  }
  if pending.len() > 0 {
    if result.len() > 0 {
      let last = result.pop()
      last.children += pending
      result.push(last)
    } else {
      result.push((children: pending, start: start, duration: 0))
    }
  }
  result
}

/// Advances subsequent content to the next physical frame.
///
/// This is the least ceremonious way to build a slide: drop a marker where the
/// pause belongs, and everything after it moves to the following frame.
/// Everything before it stays on screen, so the slide accumulates.
///
/// ```typ
/// #mosaic.slide[
///   == Argument
///   The premise.
///   #mosaic.steps.pause
///   The consequence.
///   #mosaic.steps.pause
///   The objection.
/// ]
/// ```
///
/// A pause is a value rather than a function, so it takes no arguments and no
/// body. Compare `steps.on` and `steps.reveal`, which name their steps
/// explicitly and can therefore reach frames out of source order.
///
/// Empty leading, trailing, or consecutive pauses produce no blank frames.
///
/// -> content
#let pause = metadata((
  mosaic: tag,
  kind: "pause",
))
