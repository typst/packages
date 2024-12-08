#set page("a4", flipped: false)
#import "@preview/cetz:0.3.1"
#import cetz: coordinate

= EPQ Plan

#let default-style = (
  milestones: (
    normal: (stroke: (paint: black, thickness: 1pt)),
    today: (stroke: (paint: red, thickness: 1pt)),
  ),
  gridlines: (
    task-dividers: (stroke: (paint: luma(66%), thickness: 0.5pt)),
    years: (stroke: (paint: luma(66%), thickness: 1pt)),
    months: (stroke: (paint: luma(66%), thickness: 0.7pt)),
    weeks: (stroke: (paint: luma(66%), thickness: 0.2pt)),
    days: (stroke: (paint: luma(66%), thickness: 0.1pt)),
  ),
  groups: (
    uncompleted: (stroke: (paint: black, thickness: 3pt)),
    completed-early: (
      timeframe: (stroke: (paint: olive, thickness: 3pt)),
      body: (stroke: (paint: black, thickness: 3pt)),
    ),
    completed-late: (
      timeframe: (stroke: (paint: orange, thickness: 3pt)),
      body: (stroke: (paint: black, thickness: 3pt)),
    ),
  ),
  tasks: (
    uncompleted: (stroke: (paint: luma(33%), thickness: 2pt)),
    completed-early: (
      timeframe: (stroke: (paint: olive, thickness: 2pt)),
      body: (stroke: (paint: luma(33%), thickness: 2pt)),
    ),
    completed-late: (
      timeframe: (stroke: (paint: orange, thickness: 2pt)),
      body: (stroke: (paint: luma(33%), thickness: 2pt)),
    ),
  ),
)

#let form-well(gantt) = {
  let gantt = gantt

  if not gantt.keys().contains("style") {
    gantt.insert("style", default-style)
  }

  if gantt.at("show-today", default: false) {
    gantt.milestones.push((
      name: [Today],
      date: datetime.today(),
      today: true,
    ))
  }

  gantt
}

#let month-length(datetime) = {
  let year = datetime.year()
  let month = datetime.month()

  let leap-year = (
    (calc.rem(year, 4) == 0) and not (calc.rem(year, 100) == 0)
  ) or calc.rem(year, 400) == 0

  let feb = if leap-year {
    29
  } else {
    28
  }

  (31, feb, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31).at(month - 1)

}

#let parse-datetime(s) = {
  if type(s) == datetime {
    s
  } else {
    datetime(
      year: int(s.slice(0, 4)),
      month: int(s.slice(5, 7)),
      day: int(s.slice(8, 10)),
    )
  }
}

#let get-range(gantt) = {
  let start = none
  let end = none
  let start = calc.min(
    ..gantt
      .taskgroups
      .map(taskgroup => taskgroup.tasks.map(task => parse-datetime(task.start)))
      .flatten(),
    ..gantt.milestones.map(x => parse-datetime(x.date)),
  )
  let end = calc.max(
    ..gantt
      .taskgroups
      .map(taskgroup => taskgroup.tasks.map(task => parse-datetime(task.end)))
      .flatten(),
    ..gantt.milestones.map(x => parse-datetime(x.date)),
  )
  let abs-start = start
  let abs-end = end
  if gantt.viewport-snap == "month" {
    start = datetime(year: start.year(), month: start.month(), day: 1)
    end = datetime(year: end.year(), month: end.month() + 1, day: 1)
  } else if gantt.viewport-snap == "day" { } else {
    panic("Unknown viewport snap: ", gantt.viewport-snap)
  }
  let end-m1 = end - duration(days: 1)

  (abs-start: start, start: start, abs-end: end, end: end, end-m1: end-m1)
}

#let gantt-line-simple(gantt, task) = {
  import cetz.draw: *
  import cetz: coordinate.resolve

  get-ctx(ctx => {
    let bar-east = resolve(ctx, "bars.east").at(1).at(0)
    let bar-west = resolve(ctx, "bars.west").at(1).at(0)
    let width = bar-east - bar-west
    let (start, end, end-m1) = get-range(gantt)

    let task-start = parse-datetime(task.start)
    let task-end = parse-datetime(task.end)

    let rel-start = task-start - start
    let rel-end = task-end - start

    let fract-start = rel-start / (end - start)
    let fract-end = rel-end / (end - start)


    let abs-start = fract-start * width
    let abs-end = fract-end * width

    line((abs-start, 0), (abs-end, 0))
  })
}

#let sidebar(gantt) = {
  let arr = gantt.taskgroups.map(group => (
    align(center, strong(group.name)),
    ..group.tasks.map(task => align(
      center,
      stack(
        dir: ttb,
        task.name,
      ),
    )),
  ))

  let heights = arr.map(x => x.map(y => measure(y).height))

  (
    heights: heights,
    content: block(
      inset: 5pt,
      stack(
        dir: ttb,
        spacing: 10pt,
        ..arr.flatten(),
      ),
    ),
  )
}

// Gets a pseudo-task from a group; as to draw its task-line
#let group-gantt-line(group) = {
  import cetz.util: max
  (
    start: calc.min(
      ..group.tasks.map(x => parse-datetime(x.start)),
    ),
    end: calc.max(
      ..group.tasks.map(x => parse-datetime(x.end)),
    ),
    done: {
      let last-done = none
      for task in group.tasks {
        let done = task.at("done", default: none)
        if done == none {
          last-done = none
          break
        } else {
          last-done = max(last-done, parse-datetime(done))
        }
      }
      last-done
    },
  )
}

#let gantt-line(gantt, tasklike, style) = {
  import cetz.draw: *

  let done = tasklike.at("done", default: none)
  if done != none {
    let done = parse-datetime(done)
    if done <= parse-datetime(tasklike.end) {
      let t1 = (start: tasklike.start, end: done)
      set-style(..style.completed-early.timeframe)
      gantt-line-simple(gantt, t1)

      let t2 = (start: done, end: tasklike.end)
      set-style(..style.completed-early.body)
      gantt-line-simple(gantt, t2)
    } else if done > parse-datetime(tasklike.end) {
      set-style(..style.completed-late.body)
      gantt-line-simple(gantt, tasklike)

      let extra = (start: tasklike.end, end: done)
      set-style(..style.completed-late.timeframe)
      gantt-line-simple(gantt, extra)
    }
  } else {
    set-style(..style.uncompleted)
    gantt-line-simple(gantt, tasklike)
  }
}

#let draw-group-task(gantt, group, group-heights, task-acc) = {
  import cetz.draw: translate, get-ctx, set-style

  let sidebar = sidebar(gantt)
  let sidebar-size = measure(sidebar.content)

  cetz.draw.group(
    anchor: "north-west",
    get-ctx(ctx => {
      set-style(stroke: (paint: black, thickness: 3pt))
      translate(
        y: -task-acc + group-heights.at(0) / 2 + 5pt,
        x: sidebar-size.width,
      )
      gantt-line(gantt, group-gantt-line(group), gantt.style.groups)
    }),
  )
}

#let task-line(gantt, task, task-acc, task-height) = {
  import cetz.draw: *

  let done = task.at("done", default: none)
  group(
    anchor: "north-west",
    {
      set-origin("bars.north-west")
      translate(y: -task-acc - task-height / 2 - 5pt)
      gantt-line(gantt, task, gantt.style.tasks)
    },
  )
}


#let task-lines(gantt, size) = {
  import cetz.draw: *
  import cetz: coordinate.resolve

  let sidebar = sidebar(gantt)
  let sidebar-size = measure(sidebar.content)

  rect(
    "bars.north-west",
    "bars.south-east",
  )

  line((size.width, 0), (size.width, -sidebar-size.height))
  content(
    (0, 0),
    anchor: "north-west",
    sidebar.content,
  )

  get-ctx(ctx => {
    let acc = 0pt

    for (group, group-heights) in gantt.taskgroups.zip(sidebar.heights) {
      let task-acc = acc + group-heights.at(0) + 10pt
      draw-group-task(gantt, group, group-heights, task-acc)

      for (task, task-height) in group.tasks.zip(group-heights.slice(1)) {

        line(
          (sidebar-size.width, -task-acc),
          (size.width, -task-acc),
          ..gantt.style.gridlines.task-dividers,
        )

        task-line(gantt, task, task-acc, task-height)
        task-acc += task-height + 10pt
      }

      let height = group-heights.map(x => x + 10pt).sum()
      acc += height
      line((0, -acc), (size.width, -acc))
    }
  })
}

#let draw-sidebar(gantt) = {
  let sidebar = sidebar(gantt)
  let sidebar-size = measure(sidebar.content)
  import cetz.draw: *

  rect(
    name: "sidebar",
    (0, 0),
    (sidebar-size.width, -sidebar-size.height),
  )
}

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

#let create-header(
  identifier,
  duration-func,
  get-content,
  gridline-style,
  name,
) = {
  import cetz.draw: *
  (gantt, anchor-obj) => {
    let (start, end, end-m1) = get-range(gantt)
    let date-range = (end - start)
    let height = measure([H]).height + 10pt

    rect(
      anchor-obj + ".north-west",
      (rel: (0, height), to: anchor-obj + ".north-east"),
      name: name + "-header",
    )
    let first = true
    let acc = 0.0
    for rel-day in range(int((end - start).days()) + 1) {
      let date = start + duration(days: rel-day)
      if identifier(date) or first {
        let dur = duration-func(gantt, date, first)

        let x = (acc / date-range.days()) * 100%
        let x1 = ((acc + dur) / date-range.days()) * 100%

        line(
          (name + "-header.north-west", x, name + "-header.north-east"),
          (name + "-header.south-west", x, name + "-header.south-east"),
        )
        content-if-fits(
          (name + "-header.south-west", x, name + "-header.south-east"),
          (name + "-header.north-west", x1, name + "-header.north-east"),
          get-content(date),
        )
        line(
          ("bars.north-west", x, "bars.north-east"),
          ("bars.south-west", x, "bars.south-east"),
          ..gridline-style,
        )
        acc += dur
      }
      first = false
    }
  }
}

#let draw-month-header(gantt, anchor-obj) = {
  let (start, end, end-m1) = get-range(gantt)
  create-header(
    date => date.day() == 1,
    (gantt, date, first) => {
      let length = calc.min(month-length(date), (end - date).days())
      if first {
        length += 1 - start.day()
      }
      length
    },
    date => align(center + horizon, strong(date.display("[month repr:short]"))),
    gantt.style.gridlines.months,
    "month",
  )(gantt, anchor-obj)
}

#let draw-week-header(gantt, anchor-obj) = {
  import cetz.draw: *

  create-header(
    date => date.weekday() == 1,
    (gantt, date, first) => {
      let (start, end, end-m1) = get-range(gantt)
      let end-date = date + duration(days: 7)
      if first {
        end-date -= duration(days: date.weekday() - 1)
      }
      (calc.min(end-m1, end-date) - date).days()
    },
    date => pad(2pt, text(0.8em, align(left + horizon, str(date.day())))),
    gantt.style.gridlines.weeks,
    "week",
  )(gantt, anchor-obj)
}

#let draw-year-header(gantt, anchor-obj) = {
  import cetz.draw: *

  create-header(
    date => date.day() == 1 and date.month() == 1,
    (gantt, date, first) => {
      let (start, end, end-m1) = get-range(gantt)
      let end-date = datetime(year: date.year() + 1, month: 1, day: 1)
      (calc.min(end-m1, end-date) - date).days()
    },
    date => align(center + horizon, strong(str(date.year()))),
    gantt.style.gridlines.years,
    "year",
  )(gantt, anchor-obj)
}

#let draw-day-header(gantt, anchor-obj) = {
  import cetz.draw: *

  create-header(
    date => true,
    (gantt, date, first) => 1,
    date => text(0.5em, align(center + horizon, str(date.day()))),
    gantt.style.gridlines.days,
    "day",
  )(gantt, anchor-obj)
}

#let bars-rect(gantt, size) = {
  import cetz.draw: *
  let sidebar = sidebar(gantt)
  let sidebar-size = measure(sidebar.content)
  rect(
    name: "bars",
    (sidebar-size.width, 0),
    (size.width, -sidebar-size.height),
  )
}

#let draw-header(gantt) = {
  let anchor-obj = "bars"
  for header in gantt.headers.rev() {
    if header == "month" {
      draw-month-header(gantt, anchor-obj)
      anchor-obj = "month-header"
    } else if header == "week" {
      draw-week-header(gantt, anchor-obj)
      anchor-obj = "week-header"
    } else if header == "year" {
      draw-year-header(gantt, anchor-obj)
      anchor-obj = "year-header"
    } else if header == "day" {
      draw-day-header(gantt, anchor-obj)
      anchor-obj = "day-header"
    } else {
      panic("Unknown header", header)
    }
  }
}

#let rects-intersect(rect1, rect2) = {
  import calc: min, max
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

#let draw-milestones(gantt, overhang: 5pt) = {
  import cetz.draw: *
  import cetz.coordinate: resolve
  import cetz.util: resolve-number

  let (start, end, end-m1) = get-range(gantt)
  let date-range = (end - start)

  get-ctx(ctx => {
    let used-rects = ()
    let rect-start = resolve(ctx, "bars.north-west").at(1)
    let rect-end = resolve(ctx, "bars.south-east").at(1)
    let overhang = resolve-number(ctx, overhang)

    for milestone in gantt.milestones {
      let today = milestone.at("today", default: false)
      let date = parse-datetime(milestone.date)
      let fract-x = (date - start) / (end - start)
      let x = rect-start.at(0) + fract-x * (rect-end.at(0) - rect-start.at(0))

      let style = if today {
        gantt.style.milestones.today
      } else {
        gantt.style.milestones.normal
      }

      let repr = block(
        inset: 5pt,
        align(center)[
          #set text(style.stroke.paint)
          #strong(milestone.name)#if not today {
            linebreak()
            date.display("[month repr:short] [day]")
          }
        ],
      )

      let coord = (x, rect-end.at(1) - overhang)
      let size = measure(repr)
      let size = (
        width: resolve-number(ctx, size.width),
        height: resolve-number(ctx, size.height),
      )
      let our-rect = (
        x: coord.at(0) - size.width / 2,
        y: coord.at(1),
        ..size,
      )
      while true {
        let again = false
        for used-rect in used-rects {
          if rects-intersect(used-rect, our-rect) {
            our-rect.y = used-rect.y - used-rect.height
            again = true
            break
          }
        }
        if not again {
          break
        }
      }

      coord.at(1) = our-rect.y

      used-rects.push(our-rect)

      line((x, 0), coord, ..style)
      content(
        coord,
        repr,
        anchor: "north",
      )

    }
  })
}

#let gantt(gantt) = (
  context {
    let gantt = form-well(gantt)

    layout(size => {
      cetz.canvas(
        length: size.width,
        {
          bars-rect(gantt, size)
          draw-header(gantt)
          task-lines(gantt, size)
          draw-milestones(gantt)
          draw-sidebar(gantt)
        },
      )
    })
  }
)
