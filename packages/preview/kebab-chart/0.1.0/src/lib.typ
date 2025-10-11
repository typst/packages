#import "@preview/cetz:0.4.2"

#let kebab-chart(
  ticks: 10,
  date-format: "[day] [month repr:short]",
  start-date: auto,
  end-date: auto,
  date-padding: duration(weeks: 1),
  width: 10cm,
  span-height: 0.3cm,
  vertical-padding: 0.6,
  bookmarks: (),
  label-side: "both",
  weekdays: none,
  data,
) = context {
  cetz.canvas({
    import cetz.draw: *

    let LABEL_PADDING = 0.2cm

    /* -------------------------------------------------------------------------- */
    assert(type(data) == array, message: "'data' is expected to be an array")
    /* -------------------------------------------------------------------------- */
    let VALID_LABEL_SIDE = (none, "both", "right", "left")
    assert(
      VALID_LABEL_SIDE.contains(label-side),
      message: "'label_side' is expected to be one of " + repr(VALID_LABEL_SIDE),
    )
    /* -------------------------------------------------------------------------- */
    let weekdays = weekdays
    if weekdays == auto {
      weekdays = ("M", "T", "W", "T", "F", "S", "S")
    }
    assert(
      weekdays == none or (type(weekdays) == array and weekdays.len() == 7),
      message: "invalid value for 'weekdays', expected `none` or a array with 7 elements",
    )
    /* -------------------------------------------------------------------------- */

    let data_start_dt = start-date
    let data_end_dt = end-date

    if data_start_dt == auto {
      let min_date = datetime(year: 5000, month: 12, day: 31)
      for entry in data {
        for span in entry.spans {
          if span.start < min_date {
            min_date = span.start
          }
        }
      }

      data_start_dt = min_date
    }

    if data_end_dt == auto {
      let max_date = datetime(year: 1900, month: 1, day: 1)
      for entry in data {
        for span in entry.spans {
          if span.end > max_date {
            max_date = span.end
          }
        }
      }

      data_end_dt = max_date
    }

    assert(type(data_start_dt) == datetime, message: "'start_date' is expected to be a datetime")
    assert(type(data_end_dt) == datetime, message: "'end_date' is expected to be a datetime")

    let visible_start_dt = data_start_dt - date-padding
    let visible_end_dt = data_end_dt + date-padding

    let DATES = (
      visible_start: visible_start_dt,
      visible_end: visible_end_dt,
      data_start: data_start_dt,
      data_end: data_end_dt,
    )

    /* -------------------------------------------------------------------------- */
    let ticks = ticks
    if type(ticks) == int {
      let tick_duration = (data_end_dt - data_start_dt) / (ticks - 1)
      ticks = range(0, ticks).map(i => data_start_dt + i * tick_duration)
    } else if type(ticks) == function {
      ticks = ticks(DATES)
    }
    assert(type(ticks) == array)
    /* -------------------------------------------------------------------------- */
    let bookmarks = bookmarks
    if type(bookmarks) == function {
      bookmarks = bookmarks(DATES)
    }
    assert(type(bookmarks) == array)
    /* -------------------------------------------------------------------------- */

    let labels_width = 0pt
    if label-side != none {
      for e in data {
        if "label" in e {
          let (width,) = measure(e.label)
          if width > labels_width {
            labels_width = width
          }
        }
      }
    }
    labels_width += LABEL_PADDING
    if label-side == "both" {
      labels_width *= 2
    }

    /* -------------------------------------------------------------------------- */

    let UNIT_PER_DAYS = (width - labels_width) / (visible_end_dt - visible_start_dt).days()

    let dt_to_x(dt, start: visible_start_dt) = (dt - start).days() * UNIT_PER_DAYS

    let is_date_visible(dt) = dt >= visible_start_dt and dt <= visible_end_dt

    let bar(start, end, y, ..params) = {
      let a = dt_to_x(start)
      let b = dt_to_x(end, start: start)
      rect((a, y), (rel: (b, span-height)), anchor: "north", ..params)
    }

    let RIGHT = dt_to_x(visible_end_dt)

    /* -------------------------------------------------------------------------- */

    // Display the "kebabs"
    // The y-axis is rendered from "0" toward negative values
    // so that "kebabs" are ordered top to bottom
    for (i, entry) in data.enumerate() {
      let y = -i * vertical-padding

      if "label" in entry {
        if label-side == "both" or label-side == "left" {
          content(
            (0, y),
            anchor: "east",
            padding: (right: LABEL_PADDING),
            entry.label,
          )
        }
        if label-side == "both" or label-side == "right" {
          content(
            (RIGHT, y),
            anchor: "west",
            padding: (left: LABEL_PADDING),
            entry.label,
          )
        }
      }

      line((0, y), (RIGHT, y), stroke: (dash: "dashed", thickness: 0.5pt))

      for span in entry.spans {
        let fill = span.at("fill", default: auto)
        let stroke = span.at("stroke", default: auto)
        bar(
          span.start,
          span.end,
          y,
          fill: fill,
          stroke: stroke,
        )
      }
    }

    /* -------------------------------------------------------------------------- */

    // Reset the origin so that to bottomest "kebab" is near "0"
    let n = data.len()
    let TOP = (n + 1) * vertical-padding
    set-origin((0, -(n - 0.5) * vertical-padding - 0.5))

    // Display the vertical and horizontals axes
    line((0, 0), (0, TOP))
    line((0, 0), (RIGHT, 0))
    line((RIGHT, 0), (RIGHT, TOP))

    /* -------------------------------------------------------------------------- */

    for tick in ticks {
      let dt
      let content_
      let color

      if type(tick) == datetime {
        dt = tick
        content_ = dt.display(date-format)
        color = auto
      } else if type(tick) == dictionary {
        dt = tick.at("date")
        content_ = tick.at("content")
        color = tick.at("color", default: auto)
      } else {
        panic("invalid tick")
      }

      let x = dt_to_x(dt)

      move-to((x, 0))
      line(
        (rel: (0, -0.2)),
        (rel: (0, 0.4)),
        stroke: (paint: color),
      )
      content((x, 0), anchor: "north", padding: (top: 0.4cm), content_)
    }

    /* -------------------------------------------------------------------------- */

    // Display the bookmarks
    for mark in bookmarks {
      if type(mark.date) == datetime {
        if not is_date_visible(mark.date) {
          continue
        }
      } else {
        let (start, end) = mark.date
        if end <= visible_start_dt or start >= visible_end_dt {
          continue
        }
      }

      let layer = mark.at("position", default: auto)
      let layer = if layer == "below" { -1 } else { 1 }

      on-layer(layer, {
        if type(mark.date) == datetime {
          let x = dt_to_x(mark.date)
          line((x, 0), (x, TOP), stroke: mark.at("stroke", default: auto))
          if "content" in mark {
            content(
              (x, TOP),
              anchor: "south",
              padding: (bottom: 0.15cm),
              mark.content,
            )
          }
        } else {
          let (start, end) = mark.date
          if start < visible_start_dt {
            start = visible_start_dt
          }
          if end > visible_end_dt {
            end = visible_end_dt
          }

          let start = dt_to_x(start)
          let end = dt_to_x(end)
          rect(
            (start, 0),
            (end, TOP),
            fill: mark.at("fill", default: auto),
            stroke: mark.at("stroke", default: auto),
          )
        }
      })
    }

    /* -------------------------------------------------------------------------- */

    if weekdays != none {
      let i = visible_start_dt

      while i < visible_end_dt {
        let a = dt_to_x(i)
        let b = dt_to_x(i + duration(days: 1))

        rect(
          (a, TOP),
          (b, TOP + 0.4),
        )
        content(
          ((a + b) / 2, TOP + 0.2),
          text(size: .7em, weekdays.at(i.weekday() - 1)),
        )

        i += duration(days: 1)
      }
    }

    /* -------------------------------------------------------------------------- */
  })
}
