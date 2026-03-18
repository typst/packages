#import "@preview/cetz:0.3.2": canvas, draw, coordinate, util

#let timeline(
  body,
  spacing: 5pt,
  heading-spacing: 10pt,
  show-grid: false,
  grid-style: (stroke: (dash: "dashed", thickness: .5pt, paint: gray)),
  tasks-vline: true,
  line-style: (stroke: 3pt),
  milestone-overhang: 5pt,
  milestone-layout: "in-place",
  box-milestones: true,
  milestone-line-style: (),
  offset: 0,
) = layout(size => canvas.with(debug: false, length: size.width)({
  import draw: *

  let headers = ()
  let tasks = ()
  let flat_tasks = ()
  let milestones = ()
  let n_cols = 0
  let pt = 1 / size.width.pt()

  let heading-spacing = heading-spacing.pt()

  for line in body {
    if line.type == "header" {
      headers.push(line.headers)
      if line.total > n_cols {
        n_cols = line.total
      }
    } else if line.type == "task" or line.type == "taskgroup" {
      tasks.push(line)
    } else if line.type == "milestone" {
      milestones.push(line)
    }
  }

  // Task titles
  group.with(name: "titles")({
    let i = 0
    for task in tasks {
      if task.type == "task" {
        content(
          (rel: (0, 0)),
          task.name,
          anchor: "north",
          name: "task" + str(i),
          padding: spacing,
        )

        anchor(
          "task" + str(i) + "-bottom",
          (rel: (0, 0), to: "task" + str(i) + ".south", update: true),
        )
        anchor(
          "task" + str(i) + "-top",
          (rel: (0, 0), to: "task" + str(i) + ".north-west", update: false),
        )
        anchor(
          "task" + str(i),
          (rel: (0, 0), to: "task" + str(i) + ".east", update: false),
        )

        flat_tasks.push(task)

        i += 1
      } else if task.type == "taskgroup" {
        for t in task.tasks {
          content(
            (rel: (0, 0)),
            t.name,
            anchor: "north",
            name: "task" + str(i),
            padding: spacing,
          )

          anchor(
            "task" + str(i) + "-bottom",
            (rel: (0, 0), to: "task" + str(i) + ".south", update: true),
          )
          anchor(
            "task" + str(i) + "-top",
            (rel: (0, 0), to: "task" + str(i) + ".north-west", update: false),
          )
          anchor(
            "task" + str(i),
            (rel: (0, 0), to: "task" + str(i) + ".east", update: false),
          )

          flat_tasks.push(t)

          i += 1
        }
      }
    }

    if milestone-layout == "aligned" {
      for (i, milestone) in milestones.enumerate() {
        content(
          (rel: (0, 0)),
          milestone.body,
          anchor: "north",
          name: "milestone" + str(i),
          padding: spacing,
        )

        anchor(
          "milestone" + str(i) + "-bottom",
          (rel: (0, 0), to: "milestone" + str(i) + ".south", update: true),
        )
        anchor(
          "milestone" + str(i) + "-right",
          (rel: (0, 0), to: "milestone" + str(i) + ".east", update: false),
        )
        anchor(
          "milestone" + str(i) + "-top",
          (rel: (0, 0), to: "milestone" + str(i) + ".north", update: false),
        )
      }
    }
  })

  // Now that we have laid out the task titles, we can render the task group boxes
  group.with(name: "boxes")(ctx => on-layer.with(1)({
    let start_x = coordinate.resolve(ctx, "titles.north-west").at(1).at(0)
    let end_x = 1 + start_x

    let i = 0
    for group in tasks {
      if group.type != "taskgroup" {
        i += 1
        continue
      }

      let start_i = i
      let group_start = none
      let group_end = none

      for task in group.tasks {
        if group_start == none {
          let start_y = coordinate.resolve(ctx, "titles.task" + str(i) + "-top").at(1).at(1)
          group_start = (start_x, start_y)
        }

        let end_y = coordinate.resolve(ctx, "titles.task" + str(i) + "-bottom").at(1).at(1)
        group_end = (end_x, end_y)

        i += 1
      }

      rect(group_start, group_end, stroke: 1pt)
    }

    if tasks-vline {
      line("titles.north-east", "titles.south-east")
    }

    if box-milestones and milestone-layout == "aligned" {
      let start = none
      let end = none

      for (i, milestone) in milestones.enumerate() {
        if start == none {
          let start_y = coordinate.resolve(ctx, "titles.milestone" + str(i) + "-top").at(1).at(1)
          start = (start_x, start_y)
        }
        let end_y = coordinate.resolve(ctx, "titles.milestone" + str(i) + "-bottom").at(1).at(1)
        end = (end_x, end_y)
      }

      rect(start, end, stroke: 1pt)
    }
  }))

  get-ctx(ctx => {
    let (start_x, start_y, _) = coordinate.resolve(ctx, "titles.north-east").at(1)
    let end_x = 1 + coordinate.resolve(ctx, "titles.north-west").at(1).at(0)
    let end_y = coordinate.resolve(ctx, "titles.south").at(1).at(1)

    group.with(name: "top-headers")({

      // the offset to the start_y, use unit pt
      let current_start_y_offset = 0

      for (i, header) in headers.rev().enumerate() {
        
        // before creat content, find the hightest name, and the height of header will fit it
        let max_name_height = 0
        for group in header {
          for (name, len) in group.titles {
            let name_height = measure(name).height.pt()
            if max_name_height < name_height {
              max_name_height = name_height
            }
          }
        }
        let current_header_height = max_name_height + heading-spacing

        let passed = 0
        for group in header {
          let group_start = none
          let group_end = none

          for (name, len) in group.titles {
            let start = (
              a: (start_x, start_y + (current_start_y_offset + current_header_height) * pt),
              b: (end_x, start_y + (current_start_y_offset + current_header_height) * pt),
              number: passed / n_cols * 100%,
            )

            if group_start == none { group_start = start }

            let end = (
              a: (start_x, start_y + current_start_y_offset * pt),
              b: (end_x, start_y + current_start_y_offset * pt),
              number: (passed + len) / n_cols * 100%,
            )

            group_end = end

            content(start, end, anchor: "north-west", align(center + horizon, name))

            passed += len
          }

          let group_style = (stroke: 1pt + black)
          if "style" in group {
            group_style = group.style
          }
          rect(group_start, group_end, ..group_style)
        }

          // add current height to offset, get the offset of next line of header
          current_start_y_offset = current_start_y_offset + current_header_height
      }
    })

    // Draw the lines
    for (i, task) in flat_tasks.enumerate() {
      let start = "titles.task" + str(i)
      let task_start_y = coordinate.resolve(ctx, "titles.task" + str(i)).at(1).at(1)
      let (task_top_x, task_top_y, _) = coordinate.resolve(ctx, "titles.task" + str(i) + "-top").at(1)
      let task_bottom_y = coordinate.resolve(ctx, "titles.task" + str(i) + "-bottom").at(1).at(1)
      let h = task_top_y - task_bottom_y

      for gantt_line in task.lines {
        let start = (
          a: (start_x, task_start_y),
          b: (end_x, task_start_y),
          number: (gantt_line.from + offset) / n_cols * 100%,
        )

        let end = (
          a: (start_x, task_start_y),
          b: (end_x, task_start_y),
          number: (gantt_line.to + offset) / n_cols * 100%,
        )

        let style = line-style
        if ("style" in gantt_line) { style = gantt_line.style }
        line(start, end, ..style)
      }
    }

    // Grid
    if show-grid != false {
      let month_width = (end_x - start_x) / n_cols

      on-layer.with(-1)({
        // Horizontal
        if show-grid == true or show-grid == "x" {
          for i in range(1, n_cols) {
            line(
              (start_x + month_width * i, start_y),
              (start_x + month_width * i, end_y),
              ..grid-style,
            )
          }
        }

        if show-grid == true or show-grid == "y" {
          for (i, task) in flat_tasks.enumerate() {
            let task_bottom_y = coordinate.resolve(ctx, "titles.task" + str(i) + "-bottom").at(1).at(1)
            line((start_x, task_bottom_y), (end_x, task_bottom_y), ..grid-style)
          }

          if milestone-layout == "aligned" {
            for (i, milestone) in milestones.enumerate() {
              let bottom_y = coordinate.resolve(ctx, "titles.milestone" + str(i) + "-bottom").at(1).at(1)
              line((start_x, bottom_y), (end_x, bottom_y), ..grid-style)
            }
          }
        }

        // Border all around the timeline
        rect("titles.north-west", (end_x, end_y), stroke: black + 1pt)
      })
    }

    // Milestones
    if milestones.len() > 0 {
      let draw-milestone(
        i,
        at: 0,
        body: "",
        style: milestone-line-style,
        overhang: milestone-overhang,
        spacing: spacing,
        anchor: "north",
        type: "milestone",
      ) = {
        if milestone-layout == "in-place" {
          let x = (end_x - start_x) * ((at + offset) / n_cols) + start_x

          get-ctx(ctx => {
            let pos = (x: x, y: end_y - (spacing + overhang).pt() * pt)
            let box_x = x

            let (w, h) = util.measure(ctx, body)
            if x + w / 2 > end_x {
              box_x = end_x - w / 2
            }

            if i != 0 {
              let (prev_end_x, prev_start_y, _) = coordinate.resolve-anchor(ctx, "milestone" + str(i - 1) + ".north-east")
              let prev_end_y = coordinate.resolve-anchor(ctx, "milestone" + str(i - 1) + ".south").at(1)

              if box_x - w / 2 < prev_end_x and pos.y <= prev_start_y and pos.y + h >= prev_end_y {
                pos = (x: x, y: prev_end_y - spacing.pt() * pt * 2)
              }
            }

            line((x, start_y), (rel: (0, overhang.pt() * pt), to: pos), ..style)
            on-layer.with(1)({
              content((box_x, pos.y), anchor: anchor, body, name: "milestone" + str(i))
            })
          })
        } else if milestone-layout == "aligned" {
          let x = (end_x - start_x) * (at / n_cols) + start_x
          let end_y = coordinate.resolve(ctx, "titles.milestone" + str(i) + "-right").at(1).at(1)
          line((x, start_y), (x, end_y), (start_x, end_y), ..style)
        }
      }

      on-layer.with(-0.5)({
        if milestone-layout == "aligned" {
          set-ctx(ctx => {
            ctx.prev.pt = coordinate.resolve(ctx, "titles.south").at(1)
            return ctx
          })
        }
        for (i, milestone) in milestones.enumerate() {
          draw-milestone(i, ..milestone)
        }
      })
    }
  })
}))

#let headerline(..args) = {
  let groups = args.pos()

  let headers = ()
  let current_group = ()
  let total = 0

  let parse_entry(e) = {
    if type(e) == array {
      return e
    } else {
      return (e, 1)
    }
  }

  for grp in groups {
    if type(grp) == array {
      current_group.push(grp)
      total += grp.at(1)
    } else if type(grp) == dictionary {
      if current_group.len() > 0 {
        headers.push(current_group)
      }

      headers.push((titles: grp.group.map(parse_entry)))
      total += grp.group.map(n => parse_entry(n).at(1)).sum()
    } else {
      current_group.push((grp, 1))
      total += 1
    }
  }

  if current_group.len() > 0 {
    headers.push((titles: current_group))
  }

  return ((type: "header", headers: headers, total: total),)
}

#let group(..args) = {
  return (group: args.pos())
}

#let task(name, style: none, ..lines) = {
  let processed_lines = ()

  for line in lines.pos() {
    if type(line) == dictionary {
      processed_lines.push(line)
    } else {
      let (from, to) = line
      if style != none {
        processed_lines.push((from: from, to: to, style: style))
      } else {
        processed_lines.push((from: from, to: to))
      }
    }
  }

  ((type: "task", name: name, lines: processed_lines),)
}

#let taskgroup(title: none, tasks) = {
  let extratask = ()
  if title != none {
    let min = none
    let max = none
    for task in tasks {
      for l in task.lines {
        if min == none or l.from < min {
          min = l.from
        }
        if max == none or l.to > max {
          max = l.to
        }
      }
    }

    extratask = ((type: "task", name: title, lines: ((from: min, to: max),)),)
  }

  ((type: "taskgroup", tasks: extratask + tasks),)
}

#let milestone(body, at: none, ..options) = {
  ((type: "milestone", at: at, body: body, ..options.named()),)
}
