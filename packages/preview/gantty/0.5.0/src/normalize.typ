#import "@preview/cetz:0.4.2"
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
    x: interval.at("x", default: (:)),
  )
}

/// Calculates the start of the taskgroup from its tasks
#let _subtasks-start(subtasks) = {
  calc.min(
    ..subtasks.map(x => x.intervals.map(y => y.start)).flatten(),
  )
}
/// Gets the end of the taskgroup
#let _subtasks-end(subtasks) = {
  calc.max(
    ..subtasks.map(x => x.intervals.map(y => y.end)).flatten(),
  )
}

#let _subtasks-done(subtasks) = {
  import cetz.util: max
  let last-done = none
  for task in subtasks {
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
        start: _subtasks-start(taskgroup),
        end: _subtasks-end(taskgroup),
        done: _subtasks-done(taskgroup),
      ),
    )
  }
}

#let _normalize-dependency(id-mappings, dependency) = {
  (
    type: dependency.at("type", default: "normal"),
    id: id-mappings.at(dependency.id),
    x: dependency.at("x", default: (:)),
  )
}

#let _normalize-dependencies(id-mappings, tasklike) = {
  if tasklike.keys().contains("dependencies") {
    tasklike.dependencies.map(
      _normalize-dependency.with(id-mappings),
    )
  } else {
    ()
  }
}

/// Normalizes the tasks of a taskgroup, returning the taskgroup
#let _normalize-task(
  id-mappings,
  task,
) = {
  let invalid-combination-msg = "task must either have:
    - both the `start` and `end` keys specified (and, perhaps, a `done` key)
    - the `intervals` key specified
    - `subtasks` be a nonempty array

    task given was:"
  let dependencies = _normalize-dependencies(id-mappings, task)
  let subtasks = task
    .at("subtasks", default: ())
    .map(_normalize-task.with(id-mappings))
  let has_intervals = task.keys().contains("intervals")
  let has_start = task.keys().contains("start")
  let has_end = task.keys().contains("end")
  let has_done = task.keys().contains("done")

  let intervals = if has_start and has_end and not has_intervals {
    (_normalize-interval(task),)
  } else if has_intervals and not (has_start or has_end or has_done) {
    task.intervals.map(_normalize-interval)
  } else if subtasks.len() != 0 {
    (
      (
        start: _subtasks-start(subtasks),
        end: _subtasks-end(subtasks),
        done: _subtasks-done(subtasks),
      ),
    )
  } else {
    assert(false, message: invalid-combination-msg + repr(task))
  }

  (
    name: task.name,
    subtasks: subtasks,
    intervals: intervals,
    dependencies: dependencies,
    x: task.at("x", default: (:)),
  )
}

#let _normalize-milestone(milestone) = (
  name: milestone.name,
  date: parse-datetime(milestone.date),
  x: (
    gantty: (
      today: milestone.at("today", default: false),
      show-date: milestone.at("show-date", default: true),
    ),
  ),
)

#let _gantt-start(gantt) = {
  let start = gantt.at("start", default: none)
  if start == none {
    start = calc.min(
      ..gantt
        .taskgroups
        .map(taskgroup => taskgroup.intervals.map(interval => interval.start))
        .flatten()
        .flatten(),
      ..gantt.milestones.map(x => x.date),
    )
  }
  start
}

#let _gantt-end(gantt) = {
  let end = gantt.at("end", default: none)
  if end == none {
    end = calc.max(
      ..gantt
        .taskgroups
        .map(taskgroup => taskgroup.intervals.map(interval => interval.end))
        .flatten()
        .flatten(),
      ..gantt.milestones.map(x => x.date),
    )
  }
  end
}

#let _id-prepend(dict, element) = {
  let dict2 = (:)
  for (k, v) in dict {
    dict2.insert(k, v.insert(element, 0))
  }
  dict
}

#let _id-mappings-in-task(tasks) = {
  let ids = (:)
  for (task-id, task) in tasks.enumerate() {
    if task.keys().contains("id") {
      ids.insert(task.id, (task-id,))
    }
    let subtasks = task.at("subtasks", default: ())
    for (k, v) in _id-prepend(_id-mappings-in-task(subtasks), task-id) {
      ids.insert(k, v)
    }
  }
  ids
}

#let _id-mappings(gantt) = {
  _id-mappings-in-task(gantt.tasks)
}

/// Makes sure the gantt chart is fully specified.
///
/// You do not normally need to call this function as it is called automatically
/// by gantt.
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
  let gantt = gantt

  if gantt.keys().contains("viewport-snap") {
    panic(
      "viewport-snap has been removed. Set a manual start and end date instead!",
    )
  }

  if not gantt.keys().contains("milestones") {
    gantt.milestones = ()
  } else {
    gantt.milestones = gantt.milestones.map(_normalize-milestone)
  }

  let id-mappings = _id-mappings(gantt)
  gantt.tasks = gantt.tasks.map(
    _normalize-task.with(id-mappings),
  )

  if gantt.keys().contains("start") {
    gantt.start = parse-datetime(gantt.start)
  }

  if gantt.keys().contains("end") {
    gantt.end = parse-datetime(gantt.end)
  }

  gantt.start = _gantt-start(gantt)
  gantt.end = _gantt-end(gantt)

  gantt
}
