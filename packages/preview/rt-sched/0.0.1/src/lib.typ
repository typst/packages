#import "utils.typ": *
#import "scheduler.typ" as scheduler
#import "@preview/cetz:0.5.3"

#let config = (
  task_height: 0.8cm,
  step_width: 2em,
  colors: none,
)

#let heuristic-len(len_interval) = {
  // interval of 20 -> step_width = 2em
  let x = 40
  return (x / len_interval) * 1em
}

#let task-label(i) = $tau_#i$

#let task-pos(i, t: 0) = {
  (x: t, y: config.task_height * i)
}

#let plot(
  // start of the interval
  from: int,
  // end of the interval (included)
  to: int,
  // number of step used on the x-axis (default: 1)
  step: 1,
  // the taskset display on the plot, the order of the tasks depend on their
  // order in the array (element at index i has index i + 1)
  // each task contains at least the following fields:
  // - o: int, the offset (optional)
  // - c: int, the wcet (mandatory)
  // - d: int, the deadline (mandatory)
  // - t: int, the period (mandatory)
  tasks: array,
  // the configuration of the plot (array)
  // contains the following fields
  // - config.task_height (mandatory)
  //   the height of the tasks
  // - config.step_width (mandatory)
  //   the width of the tasks
  // - config.colors (optional)
  //   the colors from which each task get their color (by index modulo
  //   the number of colors)
  config: (
    task_height: 0.8cm,
    step_width: 2em,
    colors: none,
  ),
  // the scheduling function, if none only the plot is displayed
  // the function take the array of running_jobs and the instant t
  // and return the array sorted with the highest priority task in first
  // position
  scheduler: none,
  // display a mark to indicate an idle unit (default: false)
  display-idle: false,
  // try to find a step_width that enable the plot to be printed on a a4 page
  auto-width: true,
) = {
  cetz.canvas({
    import cetz.draw: *

    if (to - from < 0) {
      panic("Incorrect interval [" + str(from) + ", " + str(to) + ")")
    }

    if (auto-width) {
      config.step_width = heuristic-len(to - from)
    }
    // panic(config.step_width)

    // X-axis ticks
    for j in range(0, to - from, step: step, inclusive: true) {
      let i = config.step_width * j
      // Tick
      line((i, 0), (i, -0.1))
      // Value
      content((i, -0.3), [#(j + from)])
      // Line-separator
      line(
        (i, 0),
        (i, config.task_height * tasks.len()),
        stroke: (dash: "dotted", thickness: 0.6pt, paint: gray),
      )
    }
    // X-axis
    line((0, 0), (config.step_width * (to - from), 0))

    // Y-axis lines
    for task_number in range(1, tasks.len() + 1) {
      let task_pos = task-pos(task_number)
      // Tick
      line((-0.2, task_pos.y), (0, task_pos.y))
      // Y-Label
      content(
        (-0.5, task_pos.y - (config.task_height / 2)),
        task-label(task_number),
      )
      // Line-separator
      line(
        (0, task_pos.y),
        (config.step_width * (to - from), task_pos.y),
        stroke: (dash: "dotted", thickness: 1pt, paint: gray),
      )
      // Y-axis
      line((0, 0), task-pos(tasks.len()))
    }

    // Print a content for task task_id at instant t
    let plot-mark(task_id, t, dx: 0mm, dy: 1mm, ..content) = {
      let task = tasks.at(task_id - 1)
      let task-pos = task-pos(task_id - 1, t: t)
      // Prevent printing the mark outside the plot
      if (t <= to) {
        let x-pos = config.step_width * t
        let y-pos = task-pos.y
        mark(
          (x-pos + dx, y-pos + config.task_height - dy),
          (x-pos + dx, y-pos),
          ..content,
        )
      }
    }

    let plot-release(task_id, t) = {
      let task-pos = task-pos(task_id, t: t)
      // Prevent printing the mark outside the plot
      let x-pos = config.step_width * t
      line(
        (x-pos, task-pos.y - (config.task_height / 4)),
        (x-pos, task-pos.y),
        mark: (start: "barbed", length: config.task_height / 10),
      )
    }

    let plot-deadline(task_id, t) = {
      plot-mark(task_id, t, dy: config.task_height / 2, "x", scale: 0.7)
    }

    let plot-missed-deadline(task_id, t) = {
      plot-mark(
        task_id,
        t,
        dx: config.step_width / 2,
        dy: config.task_height / 2,
        "x",
        stroke: 1pt + red,
      )
    }

    let plot-idle(task_id, t) = {
      plot-mark(task_id, t, dx: config.step_width / 2, dy: config.task_height / 1.5, "<>", fill: black, scale: 0.7)
    }

    let job(task_id, task, t) = {
      // task_id
      // release instant
      // absolute deadline
      // remaining time
      (
        task_id: task_id,
        task: task,
        release: t,
        deadline: t + task.d,
        remaining_computation: task.c,
      )
    }

    let spawn_jobs(tasks, t) = {
      let new_jobs = ()
      for (i, task-param) in tasks.enumerate() {
        let task = i + 1
        if (not task-param.keys().contains("o")) {
          task-param.insert("o", 0)
        }
        if (is-task-asynchronous(task-param)) {
          // Asynchronous case
          if (t == task-param.o) {
            new_jobs.push(job(task, task-param, t))
          } else if (t >= task-param.o + task-param.t) {
            if (calc.rem(t - task-param.o, task-param.t) == 0) {
              new_jobs.push(job(task, task-param, t))
            }
          }
        } else {
          // Synchronous case
          if (calc.rem(t, task-param.t) == 0) {
            new_jobs.push(job(task, task-param, t))
          }
        }
      }
      return new_jobs
    }

    let plot-execution(task_id, t, n: 1, fill: color.blue.transparentize(100%)) = {
      let task = tasks.at(task_id - 1)
      let task-pos = task-pos(task_id - 1, t: t)
      rect(
        (task-pos.x * config.step_width, task-pos.y),
        ((task-pos.x + n) * config.step_width, task-pos.y + config.task_height),
        fill: if (config.keys().contains("colors")) {
          if (config.colors != none) {
            config.colors.at(calc.rem(task_id - 1, config.colors.len()))
          }
        },
        // stroke: 0pt,
      )
    }

    if (scheduler != none) {
      // plot-mark(2, 6, dy: 4mm, "x", stroke: 1pt + red)
      let running_jobs = ()
      let current_job = none
      let deadline_missed = false
      // Schedule
      for t in range(from, to) {
        // Check deadline miss
        for job in running_jobs {
          if (job.deadline <= t and job.remaining_computation != 0) {
            plot-missed-deadline(job.task_id, t)
            deadline_missed = true
          }
        }
        if (deadline_missed) { break }
        // Spawn jobs
        for job in spawn_jobs(tasks, t) {
          running_jobs.push(job)
        }
        // schedule for one step
        // schedule() put the highest priority job at the beginning of the list
        running_jobs = scheduler(running_jobs, t)
        if (running_jobs.len() > 0) {
          plot-execution(running_jobs.at(0).task_id, t)
          running_jobs.at(0).remaining_computation -= 1
          running_jobs = running_jobs.filter(job => job.remaining_computation > 0)
        } else {
          // we have an idle unit (interval ]a, b[ during which the
          // CPU doesn't run anything) => not the same as idle instant !
          if (display-idle) {
            plot-idle(calc.floor((tasks.len() + 1) / 2), t)
          }
        }
      }
    }

    // Task informations
    for task in range(1, tasks.len() + 1) {
      for t in range(from, to, inclusive: true) {
        let task-pos = task-pos(task, t: t)
        // - 1 because tasks starts at 1 but array at 0
        let task-param = tasks.at(task - 1)
        // set offset to 0 if absent
        if (not task-param.keys().contains("o")) {
          task-param.insert("o", 0)
        }
        let x-pos = config.step_width * (t - from)
        // Releases
        if (is-task-asynchronous(task-param)) {
          // Asynchronous case
          if (t == task-param.o) {
            plot-release(task, t)
            plot-deadline(task, t + task-param.d)
          } else if (t >= task-param.o + task-param.t) {
            if (calc.rem(t - task-param.o, task-param.t) == 0) {
              plot-release(task, t)
              plot-deadline(task, t + task-param.d)
            }
          }
        } else {
          // Synchronous case
          if (calc.rem(t, task-param.t) == 0) {
            plot-release(task, t)
            plot-deadline(task, t + task-param.d)
          }
        }
      }
    }
  })
}

// Return a string desribing the taskset (synchronicity and deadline)
#let describe-taskset(tasks) = {
  if is-synchronous(tasks) { "synchronous" } else { "asynchronous" } + " "
  (
    if is-implicit(tasks) { "implicit" } else if is-constrained(tasks) { "constrained" } else { "arbitrary" }
      + "-deadline system"
  )
}

// Return a table displaying the taskset
// If the taskset is synchronous, column "offset" is hidden
#let print-taskset(tasks) = {
  if is-synchronous(tasks) {
    table(
      columns: 4,
      align: center,
      stroke: 0pt,
      [$tau_i$], [$C_i$], [$D_i$], [$T_i$],
      table.hline(stroke: 1pt),
      ..for (i, task) in tasks.enumerate() {
        (
          [$tau_#{ i + 1 }$],
          table.vline(stroke: 1pt),
          [$#task.c$],
          [$#task.d$],
          [$#task.t$],
        )
      },
    )
  } else {
    table(
      columns: 5,
      align: center,
      stroke: 0pt,
      [$tau_i$], [$O_i$], [$C_i$], [$D_i$], [$T_i$],
      table.hline(stroke: 1pt),
      ..for (i, task) in tasks.enumerate() {
        (
          [$tau_#{ i + 1 }$],
          table.vline(stroke: 1pt),
          if (task.keys().contains("o")) [$#task.o$] else [$0$],
          [$#task.c$],
          [$#task.d$],
          [$#task.t$],
        )
      },
    )
  }
}
