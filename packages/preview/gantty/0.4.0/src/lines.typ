#import "@preview/cetz:0.4.1"
#import "util.typ": gantt-range

/// Draws a line between `interval-simple.start` and `interval-simple.end`
#let simple-interval-line(gantt, interval-simple, start-c, end-c) = {
  import cetz.draw: *

  let (start, end, end-m1) = gantt-range(gantt)
  let range = (end - start)


  let fract-start = (interval-simple.start - start) / range * 100%
  let fract-end = (interval-simple.end - start) / range * 100%
  line((start-c, fract-start, end-c), (start-c, fract-end, end-c))
}

/// Draws a line following the interval
///
/// `style` should be a dictionary whose keys reflect `@default-style`'s `tasks`
/// key.
#let interval-line(gantt, interval, style, start, end) = {
  import cetz.draw: *

  let done = interval.at("done")
  if done == none {
    set-style(..style.uncompleted)
    simple-interval-line(gantt, interval, start, end)
  } else {
    let done = done
    if done <= interval.end {
      let t1 = (start: interval.start, end: done)
      set-style(..style.completed-early.timeframe)
      simple-interval-line(gantt, t1, start, end)

      let t2 = (start: done, end: interval.end)
      set-style(..style.completed-early.body)
      simple-interval-line(gantt, t2, start, end)
    } else if done > interval.end {
      set-style(..style.completed-late.body)
      simple-interval-line(gantt, interval, start, end)

      let extra = (start: interval.end, end: done)
      set-style(..style.completed-late.timeframe)
      simple-interval-line(gantt, extra, start, end)
    }
  }
}
