# CINECA: A Typst Package to Create Calendars

CINECA Is Not an Electric Calendar App, but a Typst package to create calendars with events.

## Usage

### Day view

`calendar(events, hour-range, minute-height, template, stroke)`

Parameters:

- `events`: An array of events. Each item is a 4-element array:
  - Index of day. Start from 0.
  - Float-style start time.
  - Float-style end time.
  - Event body. Can be anything. Passed to the template.body to show more details.
- `hour-range`: Then range of hours, affacting the range of the calendar. Default: `(8, 20)`.
- `minute-height`: Height of per minute. Each minute occupys a row. This number is to control the height of each row. Default: `0.8pt`.
- `template`: Templates for headers, times, or events. It takes a dictionary of the following entries: `header`, `time`, and `event`. Default: `(:)`.
- `stroke`: A stroke style to control the style of the default stroke, or a function taking two parameters `(x, y)` to control the stroke. The first row is the dates, and the first column is the times. Default: `none`.

> Float-style time means a number representing 24-hour time. The integer part represents the hour. The fractional part represents the minute.

Example:

![](./test/day-view.png)

### Month view

`calendar-month(events, template, sunday-first, ..args)`

- `events`: Event list. Each element is a two-element array.
  - Day. A datetime object.
  - Additional information for showing a day. It actually depends on the template `day-body`. For the deafult template, it requires a content.
- `template`: Templates for headers, times, or events. It takes a dictionary of the following entries: `day-body`, `day-head`, `month-head`, and `layout`.
- `sunday-first`: Whether to put sunday as the first day of a week.
- `..args`: Additional arguments for the calendar's grid.

Example:

```typst
#let events = (
  (datetime(year: 2024, month: 5, day: 1, hour: 9, minute: 0, second: 0), [Lecture]),
  (datetime(year: 2024, month: 5, day: 1, hour: 10, minute: 0, second: 0), [Tutorial]),
  (datetime(year: 2024, month: 5, day: 2, hour: 10, minute: 0, second: 0), [Meeting]),
  (datetime(year: 2024, month: 5, day: 10, hour: 12, minute: 0, second: 0), [Lunch]),
  (datetime(year: 2024, month: 5, day: 25, hour: 8, minute: 0, second: 0), [Train]),
)

#calendar-month(
  events,
  sunday-first: false,
  template: (
    month-head: (content) => strong(content)
  )
)
```

```typst
#let events2 = (
  (datetime(year: 2024, month: 5, day: 1, hour: 9, minute: 0, second: 0), ([Lecture], blue)),
  (datetime(year: 2024, month: 5, day: 1, hour: 10, minute: 0, second: 0), ([Tutorial], red)),
  (datetime(year: 2024, month: 5, day: 1, hour: 11, minute: 0, second: 0), [Lab]),
)

#calendar-month(
  events2,
  sunday-first: true,
  rows: (2em,) * 2 + (8em,),
  template: (
    day-body: (day, events) => {
      show: block.with(width: 100%, height: 100%, inset: 2pt)
      set align(left + top)
      stack(
        spacing: 2pt,
        pad(bottom: 4pt, text(weight: "bold", day.display("[day]"))),
        ..events.map(((d, e)) => {
          let col = if type(e) == array and e.len() > 1 { e.at(1) } else { yellow }
          show: block.with(
            fill: col.lighten(40%),
            stroke: col,
            width: 100%,
            inset: 2pt,
            radius: 2pt
          )
          d.display("[hour]")
          h(4pt)
          if type(e) == array { e.at(0) } else { e }
        })
      )
    }
  )
)
```

![](./test/month-view.png)

### Month-summary view

`calendar-month-summary(events, template, sunday-first, ..args)`

- `events`: Event list. Each element is a two-element array.
  - Day. A datetime object.
  - Additional information for showing a day. It actually depends on the template `day-body`. For the deafult template, it requires an array of two elements.
    - Shape. A function specify how to darw the shape, such as `circle`.
    - Arguments. Further arguments for render a shape.
- `template`: Templates for headers, times, or events. It takes a dictionary of the following entries: `day-body`, `day-head`, `month-head`, and `layout`.
- `sunday-first`: Whether to put sunday as the first day of a week.
- `..args`: Additional arguments for the calendar's grid.

Example:

```typst
#let events = (
  (datetime(year: 2024, month: 05, day: 21), (circle, (stroke: color.green, inset: 2pt))),
  (datetime(year: 2024, month: 05, day: 22), (circle, (stroke: color.green, inset: 2pt))),
  (datetime(year: 2024, month: 05, day: 27), (circle, (stroke: color.green, inset: 2pt))),
  (datetime(year: 2024, month: 05, day: 28), (circle, (stroke: color.blue, inset: 2pt))),
  (datetime(year: 2024, month: 05, day: 29), (circle, (stroke: color.blue, inset: 2pt))),
  (datetime(year: 2024, month: 06, day: 03), (circle, (stroke: color.blue, inset: 2pt))),
  (datetime(year: 2024, month: 06, day: 04), (circle, (stroke: color.yellow, inset: 2pt))),
  (datetime(year: 2024, month: 06, day: 05), (circle, (stroke: color.yellow, inset: 2pt))),
  (datetime(year: 2024, month: 06, day: 10), (circle, (stroke: color.red, inset: 2pt))),
)

#calendar-month-summary(
  events: events
)

#calendar-month-summary(
  events: events,
  sunday-first: true
)

// An empty calendar
#calendar-month-summary(
  events: (
    (datetime(year: 2024, month: 05, day: 21), (none,)),
  ),
  stroke: 1pt,
)
```

![](./test/month-summary.png)

## Limitations

- Page breaking may be incorrect.
- Items will overlap when they happens at the same time.
