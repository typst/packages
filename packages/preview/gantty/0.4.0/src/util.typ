#import "@preview/cetz:0.4.1"

/// A very small float
#let EPSILON = 0.0000000000001

/// Checks if two rects intersect
#let rects-intersect(rect1, rect2) = {
  import calc: max, min
  let r1a = (
    x: min(rect1.x, rect1.x + rect1.width),
    y: min(rect1.y, rect1.y + rect1.height),
  )
  let r1b = (
    x: max(rect1.x, rect1.x + rect1.width),
    y: max(rect1.y, rect1.y + rect1.height),
  )

  let r2a = (
    x: min(rect2.x, rect2.x + rect2.width),
    y: min(rect2.y, rect2.y + rect2.height),
  )
  let r2b = (
    x: max(rect2.x, rect2.x + rect2.width),
    y: max(rect2.y, rect2.y + rect2.height),
  )

  let c1 = r1a.x < r2b.x
  let c2 = r1b.x > r2a.x
  let c3 = r1a.y < r2b.y
  let c4 = r1b.y > r2a.y
  c1 and c2 and c3 and c4
}

/// Displays a content between two coördinates if there is sufficent space
#let content-if-fits(c1, c2, ctn) = {
  import cetz.draw: *
  import cetz.util: measure
  import cetz.vector
  import cetz.coordinate: resolve

  get-ctx(ctx => {
    let measured = measure(ctx, ctn)
    let c1 = resolve(ctx, c1).at(1)
    let c2 = resolve(ctx, c2).at(1)
    let size = vector.sub(c2, c1)
    if measured.at(0) < size.at(0) and measured.at(1) < size.at(1) {
      content(c1, c2, ctn)
    }
  })
}

/// Gets the range of the gantt chart.
///
/// Returns an array of the start date, the end date, and one less than
/// the end date.
/// -> array
#let gantt-range(
  /// A gantt chart.
  /// -> dictionary
  gantt,
) = {
  let start = gantt.at("start", default: none)
  let end = gantt.at("end", default: none)
  if start == none {
    start = calc.min(
      ..gantt
        .taskgroups
        .map(taskgroup => taskgroup.tasks.map(task => task.intervals.map(
          interval => {
            interval.start
          },
        )))
        .flatten()
        .flatten(),
      ..gantt.milestones.map(x => x.date),
    )
  }
  if end == none {
    end = calc.max(
      ..gantt
        .taskgroups
        .map(taskgroup => taskgroup.tasks.map(task => task.intervals.map(
          interval => {
            interval.end
          },
        )))
        .flatten()
        .flatten(),
      ..gantt.milestones.map(x => x.date),
    )
  }
  let abs-start = start
  let abs-end = end
  if gantt.viewport-snap == "month" {
    start = datetime(year: start.year(), month: start.month(), day: 1)
    end = datetime(year: end.year(), month: end.month() + 1, day: 1)
  } else if gantt.viewport-snap == "day" {} else {
    panic("Unknown viewport snap: ", gantt.viewport-snap)
  }
  let end-m1 = end - duration(days: 1)

  (abs-start: start, start: start, abs-end: end, end: end, end-m1: end-m1)
}
