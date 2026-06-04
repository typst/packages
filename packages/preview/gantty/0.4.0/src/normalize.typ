#import "@preview/cetz:0.4.1"
#import "style.typ": default-style
#import "datetime.typ": parse-datetime

/// Ensures an interview contains a start, end, and done date
#let _normalize-interval(interval) = {
  let done = if interval.keys().contains("done") {
    parse-datetime(interval.done)
  } else {
    none
  }
  (
    start: parse-datetime(interval.start),
    end: parse-datetime(interval.end),
    done: done,
  )
}

/// Calculates the start of the taskgroup from its tasks
#let _calculate-taskgroup-start(taskgroup) = {
  calc.min(
    ..taskgroup.tasks.map(x => x.intervals.map(y => y.start)).flatten(),
  )
}
/// Gets the end of the taskgroup
#let _calculate-taskgroup-end(taskgroup) = {
  calc.max(
    ..taskgroup.tasks.map(x => x.intervals.map(y => y.end)).flatten(),
  )
}

#let _calculate-taskgroup-done(taskgroup) = {
  import cetz.util: max
  let last-done = none
  for task in taskgroup.tasks {
    for interval in task.intervals {
      let done = interval.at("done", default: none)
      if done == none {
        last-done = none
        break
      } else {
        last-done = max(last-done, done)
      }
    }
  }
  last-done
}

#let _taskgroup-intervals(taskgroup) = {
  if taskgroup.keys().contains("intervals") {
    taskgroup.intervals.map(_normalize-interval)
  } else {
    (
      (
        start: _calculate-taskgroup-start(taskgroup),
        end: _calculate-taskgroup-end(taskgroup),
        done: _calculate-taskgroup-done(taskgroup),
      ),
    )
  }
}

/// Normalizes the tasks of a taskgroup, returning the taskgroup
#let _normalize-taskgroup-tasks(
  taskgroup,
) = (
  ..taskgroup,
  tasks: taskgroup
    .at("tasks", default: ())
    .map(task => {
      let has_intervals = task.keys().contains("intervals")
      let has_start = task.keys().contains("start")
      let has_end = task.keys().contains("end")
      if has_start != has_end {
        panic(
          "Tasks must contain both `start` and `end` or use `intervals`",
          task,
        )
      } else if has_start == has_intervals {
        panic(
          "Tasks must contain EITHER (`start` and `end`) or `intervals`",
          task,
        )
      } else if has_start {
        (
          name: task.name,
          intervals: (_normalize-interval(task),),
        )
      } else if has_intervals {
        (
          name: task.name,
          intervals: task.intervals.map(_normalize-interval),
        )
      } else {
        panic(
          "unreachable! if you see this error please file an issue at https://gitlab.com/john_t/typst-gantty/-/issues",
        )
      }
    }),
)

#let _normalize-taskgroup(taskgroup) = {
  let taskgroup = _normalize-taskgroup-tasks(taskgroup)
  (
    name: taskgroup.name,
    tasks: taskgroup.tasks,
    intervals: _taskgroup-intervals(taskgroup),
  )
}

#let _normalize-milestone(milestone) = (
  name: milestone.name,
  date: parse-datetime(milestone.date),
)

/// Makes sure the gantt chart is fully specified.
///
/// You do not normally need to call this function as it is called automatically
/// by @gantt.
///
/// Notably this function ensures that the gantt chart has:
///
/// - all the needed style parameters
/// - a today milestone if `gantt.show-today` is `true`
/// - all its tasks specified in interval format, not start and end
/// - all datetimes are parsed
///
/// -> dictionary
#let normalize-gantt(
  /// A valid gantt chart.
  /// -> dictionary
  gantt,
) = {
  import cetz: util.merge-dictionary
  let gantt = gantt

  gantt.insert("style", merge-dictionary(default-style, gantt.at(
    "style",
    default: (:),
  )))

  if not gantt.keys().contains("today-localized") {
    gantt.today-localized = [Today]
  }

  if not gantt.keys().contains("milestones") {
    gantt.milestones = ()
  }

  if gantt.at("show-today", default: false) {
    gantt.milestones.push((
      name: gantt.today-localized,
      date: datetime.today(),
      today: true,
    ))
  }

  gantt.taskgroups = gantt.taskgroups.map(_normalize-taskgroup)

  if gantt.keys().contains("start") {
    gantt.start = parse-datetime(gantt.start)
  }

  if gantt.keys().contains("end") {
    gantt.end = parse-datetime(gantt.end)
  }

  gantt.milestones = gantt.milestones.map(_normalize-milestone)

  gantt
}
