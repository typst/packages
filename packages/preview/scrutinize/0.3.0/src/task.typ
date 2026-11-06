#let _label = <scrutinize-task>
#let _start = <scrutinize-start>
#let _end = <scrutinize-end>

/// Encloses the provided body with labels that can be used to limit what tasks are considered
/// during lookup. This is helpful if there are independent exams/sections in the same document, or
/// for this documentation (separate examples).
///
/// The lookup functions in this package properly handle nested scopes.
///
/// Example:
///
/// #{
///   import task: t
///   set heading(numbering: none, outlined: false)
///   show: task.scope
///   example(
///     mode: "markup",
///     ratio: 1.8,
///     scale-preview: 100%,
///     scope: (t: t),
///     ```typ
///     #task.scope[
///       Number of tasks: #context task.all().len()
///       #task.scope[
///         = A (counts) #t()
///       ]
///       = B (counts too) #t()
///     ]
///     = C (doesn't) #t()
///     ```
///   )
/// }
///
/// - body (content): the scope's body
/// -> content
#let scope(body) = {
  import "utils/scope.typ": scope
  scope(_start, _end, body)
}

/// Sets the task data for the most recent heading. This must be called only once per heading;
/// subsequent calls won't do anything. The task metadata can later be accessed using the other
/// functions in this module.
///
/// - ..args (arguments): only named parameters: values to be added to the task's metadata
/// -> content
#let t(..args) = {
  assert(args.pos().len() == 0)
  [#metadata((: ..args.named())) #_label]
}

#let _extract-tasks(tasks-headings, level, depth, top-level: false, flatten: false) = {
  let tasks = ()
  if depth == 0 { return tasks }

  let new-depth = if depth == auto { auto } else { depth - 1 }
  for (i, h) in tasks-headings.enumerate() {
    // we want to only consider headings
    if h.func() != heading { continue }
    // if we leave the requested level, we're done
    if h.level < level {
      if top-level {
        // we're enumerating top-level tasks; keep going but ignore this
        continue
      } else {
        // we just exited the parent task; stop here
        break
      }
    }
    // we want to only consider headings at the requested level
    if h.level > level { continue }

    let task = (heading: h, data: none)
    // we found a heading at i, so if there's task metadata it's at i + 1
    if i + 1 < tasks-headings.len() {
      let candidate = tasks-headings.at(i + 1)
      if candidate.func() == metadata {
        task.data = candidate.value
      }
    }

    if new-depth == 0 {
      // the task is complete, push it
      tasks.push(task)
    } else {
      let subtasks = _extract-tasks(tasks-headings.slice(i + 1), level + 1, new-depth)
      if flatten {
        // push the task and its subtasks separately
        tasks.push(task)
        tasks += subtasks
      } else {
        // push the task after adding the subtasks
        task.subtasks = subtasks
        tasks.push(task)
      }
    }
  }

  tasks
}

/// Looks up the most recently defined heading of a certain level and retrieves the task data, in
/// a dictionary of the following form:
/// - `heading` is the heading that starts the task; through this location information can also be
///   retrieved.
/// - `data` contains any data passed to @@t().
/// - `subtasks` recursively contains more such dictionaries.
/// `subtasks` only exists down to the specified `depth`: if the depth is 1, no subtasks are
/// retrieved, `auto` means an unlimited depth.
///
/// Only tasks within the specified range are considered. For example, if this is called within a
/// @@scope() but the enclosing level 1 heading is _outside_ the scope, this function will not find
/// anything and fail. To still succeed, you need to either increase the range via `from` and `to`,
/// or provide a location via `loc` that is outside the problematic scope.
///
/// This function is contextual and must appear within a ```typ context``` expression.
///
/// Examples:
///
/// #{
///   import task: t
///   set heading(numbering: none, outlined: false)
///   show: task.scope
///   example(
///     mode: "markup",
///     ratio: 1.8,
///     scale-preview: 100%,
///     scope: (t: t),
///     ```typ
///     = Example task
///     #t(points: 2)
///     #context [
///       #let name = task.current().heading.body
///       #let points = task.current().data.points
///       "#name" is worth #points points,
///       or up to #(points + 1) points for great answers!
///     ]
///     ```
///   )
/// }
///
/// #{
///   import task: t
///   set heading(numbering: none, outlined: false)
///   show: task.scope
///   example(
///     mode: "markup",
///     ratio: 1.8,
///     scale-preview: 100%,
///     scope: (t: t),
///     ```typ
///     = Example task
///     #context [
///       #let subtasks = task.current(depth: 2).subtasks
///       #let total = subtasks.map(t => t.data.points).sum()
///       This task gives #total points total.
///     ]
///     == Subtask 1 #t(points: 2)
///     == Subtask 2 #t(points: 2)
///     ```
///   )
/// }
///
/// - level (int): the level of heading to look up
/// - depth (int, auto): the depth to which to also fetch subtasks
/// - from (location, auto, none): the location at which to start looking;
///   `auto` means start of the enclosing @@scope(), `none` means start of the document
/// - to (location, auto, none): the location at which to stop looking;
///   `auto` means end of the enclosing @@scope(), `none` means end of the document
/// - loc (location, auto): the location at which to look; `auto` means `here()`
/// -> dictionary
#let current(level: 1, depth: 1, from: auto, to: auto, loc: auto) = {
  import "utils/scope.typ": enclosing

  let (from, to, loc) = (from, to, loc)
  if loc == auto {
    loc = here()
  }

  if from == auto or to == auto {
    let (_from, _to) = enclosing(_start, _end, loc: loc)
    if from == auto {
      from = if _from != none { _from.location() } else { none }
    }
    if to == auto {
      to = if _to != none { _to.location() } else { none }
    }
  }

  let h = query(heading.where(level: level).before(loc)).last()

  let sel = selector(_label).or(heading).after(h.location())
  if from != none { sel = sel.after(from) }
  if to != none { sel = sel.before(to) }

  let tasks-headings = query(sel)

  _extract-tasks(tasks-headings, level, depth).first()
}

/// Locates all tasks in the document (or scope, or region of the document), which can then be used
/// to create grading keys etc. The return value is an array with elements as described in
/// @@current(), except: if `flatten` is true, there will never be subtasks and instead subtasks
/// down to the specified depth will follow their parent. Note that even then, nesting information
/// is present through `heading.level`.
///
/// Headings of the specified `level` are treated as top-level tasks; any higher level headings,
/// even if they have an associated @@t(), are ignored.
///
/// This function is contextual and must appear within a ```typ context``` expression.
///
/// Examples:
///
/// #{
///   import task: t
///   set heading(numbering: none, outlined: false)
///   show: task.scope
///   example(
///     mode: "markup",
///     ratio: 1.8,
///     scale-preview: 100%,
///     scope: (t: t),
///     ```typ
///     #context [
///       #let tasks = task.all(level: 2)
///       Number of tasks: #tasks.len() \
///       Total points: #tasks.map(t => t.data.points).sum()
///     ]
///     == A #t(points: 2)
///     == B #t(points: 3)
///     === B1 #t(points: 1)
///     ```
///   )
/// }
///
/// #{
///   import task: t
///   set heading(numbering: none, outlined: false)
///   show: task.scope
///   example(
///     mode: "markup",
///     ratio: 1.8,
///     scale-preview: 100%,
///     scope: (t: t),
///     ```typ
///     #context [
///       #let tasks = task.all(level: 3)
///       Number of tasks: #tasks.len() \
///       Total points: #tasks.map(t => t.data.points).sum()
///     ]
///     == Part 1
///     === A #t(points: 2)
///     == Part 2
///     === B #t(points: 3)
///     ```
///   )
/// }
///
/// #{
///   import task: t
///   set heading(numbering: none, outlined: false)
///   show: task.scope
///   example(
///     mode: "markup",
///     ratio: 1.8,
///     scale-preview: 100%,
///     scope: (t: t),
///     ```typ
///     #context [
///       #let tasks = task.all(level: 2, depth: auto,
///           flatten: true)
///       Number of tasks & subtasks: #tasks.len()
///     ]
///     == A
///     === A1 #t(points: 2)
///     === A1 #t(points: 3)
///     == B
///     === B1 #t(points: 1)
///     ```
///   )
/// }
///
/// - level (int): the level of heading to look up
/// - depth (int, auto): the depth to which to also fetch subtasks
/// - from (location, auto, none): the location at which to start looking;
///   `auto` means start of the enclosing @@scope(), `none` means start of the document
/// - to (location, auto, none): the location at which to stop looking;
///   `auto` means end of the enclosing @@scope(), `none` means end of the document
/// - loc (location, auto): the location at which to look; `auto` means `here()`
/// - flatten (boolean): whether to flatten subtasks
/// -> array
#let all(level: 1, depth: 1, from: auto, to: auto, loc: auto, flatten: true) = {
  import "utils/scope.typ": enclosing

  let (from, to, loc) = (from, to, loc)

  if from == auto or to == auto {
    let (_from, _to) = enclosing(_start, _end, loc: loc)
    if from == auto {
      from = if _from != none { _from.location() } else { none }
    }
    if to == auto {
      to = if _to != none { _to.location() } else { none }
    }
  }

  let sel = selector(_label).or(heading)
  if from != none { sel = sel.after(from) }
  if to != none { sel = sel.before(to) }

  let tasks-headings = query(sel)

  _extract-tasks(tasks-headings, level, depth, top-level: true, flatten: flatten)
}
