#import "i18n.typ"
#import "todo.typ": todo, todo-box
#import "ref.typ": impromptu-label

/// Internal helper to process the `points` option of the `task` function.
///
/// Returns a 2-array of the total number of points and how they should be displayed.
/// Multiple points like `points: (1, 3, 1)` get rendered as "1 + 3 + 1".
///
/// -> array
#let _handle_points(points) = {
  let current-points
  let display-points

  if type(points) == int {
    return (points, [#points])
  } else if type(points) == array and points.all(p => type(p) == int) {
    return (points.sum(), points.map(str).intersperse(" + ").sum())
  } else {
    return (none, none)
  }
}

/// Create a task section.
///
/// Use this function as primary way to structure your document.
///
/// *Example*
/// ```typst
/// #task(name: "Pythagorean theorem", points: 1)[
///   _What is the Pythagorean theorem?_
///
///   $ a^2 + b^2 = c^2 $
/// ]
/// ```
/// -> content
#let task(
  /// The name of the task. -> content | str | none
  name: none,
  /// The prefix that is displayed before the task count. -> content | str
  task-prefix: context i18n.translate("Task"),
  /// A label that you can reference or query. -> str | none
  label: none,
  /// The supplement of the task which is used in outlines and references.
  ///
  /// When set to #auto, it uses the same value as `task-prefix`.
  ///
  /// -> auto | content | str | function | none
  supplement: auto,
  /// Set the value of the task counter manually.
  ///
  /// If set to #auto, the counter is not reset.
  /// Regardless of this value, the counter is stepped at the end of the task.
  ///
  /// -> auto | int | function
  counter: auto,
  /// Whether to display the value of the task counter in the task's title. -> bool
  counter-show: true,
  /// Step the task counter by the given number.
  ///
  /// This is applied after the general counter update (see `counter` parameter).
  ///
  /// -> none | int
  skip: none,
  /// Whether to mark the task with a TODO box. -> bool
  todo: false,
  /// Whether to show a warning beside the title if there are any TODOs in the task. -> bool
  todo-show: true,
  /// The layout for the TODO box that may be displayed in the title.
  ///
  /// Set this using the provided `todo-box` function.
  ///
  /// *Example*
  /// ```typst
  /// #task(todo-box: todo-box.with(stroke: none))[
  ///   #todo[Some TODO message.]
  /// ]
  /// ```
  /// -> function
  todo-box: todo-box,
  /// How many points the task can give.
  ///
  /// If there are subtasks, you can specify an array of numbers.
  ///
  /// -> int | array
  points: none,
  /// Whether to show the points on the right side of the page above the task. -> bool
  points-show: true,
  /// The word that is displayed before the points. -> content | str
  points-prefix: context i18n.translate("Points"),
  /// Whether to insert a colbreak before the task.
  ///
  /// Technically, this breaks the column and not the page
  /// but a single-column layout is assumed.
  ///
  /// This does not apply to the very first task
  /// where it usually makes no sense to break before.
  ///
  /// -> bool
  begin-at-new-page: false,
  /// Whether the task is a bonus task. -> bool
  bonus: false,
  /// A styling function applied to the title of bonus tasks. -> function | none
  bonus-style: t => [#t (#context i18n.translate("Bonus"))],
  /// Whether the task is hidden in the score box. -> bool
  hidden: false,
  /// Whether to reset the theorem counter at the start of the task. -> bool
  theorem-counter-reset: false,
  /// Padding above the task. -> auto | length
  space-above: auto,
  /// Padding below the task. -> auto | length
  space-below: 2em,
  /// A function that provides styling to the description of a task. -> function
  task-text-style: emph,
  /// The body of the task.
  /// Either:
  /// - [content]
  /// - [task text][content]
  /// -> content..
  ..body-args,
) = {
  let c = std.counter

  assert(body-args.named().len() == 0, message: "Unexpected named argument.")
  assert(
    body-args.pos().len() == 1 or body-args.pos().len() == 2,
    message: "task expects either [content] or [task text][content] as body arguments.",
  )

  let body-args = body-args.pos()
  let (task-text, body) = (
    if body-args.len() == 2 { body-args.at(0) } else { none },
    if body-args.len() == 2 { body-args.at(1) } else { body-args.at(0) },
  )

  if counter != auto { c("sheetstorm-task").update(counter) }
  if skip != none and type(skip) == int {
    c("sheetstorm-task").update(n => n + skip)
  }

  let (points-number, points-display) = _handle_points(points)

  state("sheetstorm-points").update(points-number)
  state("sheetstorm-bonus").update(bonus)
  state("sheetstorm-hidden-task").update(hidden)
  state("sheetstorm-subtask").update((1,))

  if (todo) {
    c("sheetstorm-todo").step()
  }

  if theorem-counter-reset {
    c("sheetstorm-theorem-count").update(1)
  }

  let maybe-todo = context {
    let curr-task = query(selector(<sheetstorm-task>).before(here()))
      .last()
      .location()
    let curr-task-end = query(selector(<sheetstorm-task-end>).after(here()))
      .first()
      .location()

    let curr-todo-count = c("sheetstorm-todo").at(curr-task-end).first()
    if (curr-todo-count > 0) { todo-box() }
  }

  let title = {
    let text = {
      task-prefix
      if counter-show {
        if task-prefix != "" [ ]
        context c("sheetstorm-task").display()
      }
      if name != none [: #emph(name)]
    }
    if bonus and type(bonus-style) == function {
      text = bonus-style(text)
    }

    text

    if todo-show and maybe-todo != none {
      h(0.7em)
      maybe-todo
    }
  }

  // maybe colbreak before task
  context {
    let is-first-task = (
      query(selector(<sheetstorm-task>).before(here())).len() == 0
    )
    if begin-at-new-page and not is-first-task {
      colbreak(weak: true)
    }
  }

  block(width: 100%, above: space-above, below: space-below)[
    #if label != none {
      if supplement == auto { supplement = task-prefix }
      impromptu-label(
        kind: "sheetstorm-task-label",
        supplement: supplement,
        label,
      )
    }

    #block({
      show heading: box
      [#metadata("sheetstorm-task-start")<sheetstorm-task>]
      [= #title ]
      if points-show and points-display != none {
        h(1fr)
        [(#points-display #points-prefix)]
      }
    })
    #if (task-text != none) {
      block(task-text-style(task-text))
    }

    #body
    #metadata("sheetstorm-task-end")<sheetstorm-task-end>
  ]

  c("sheetstorm-task").step()
  c("sheetstorm-todo").update(0)
}

/// Create a subtask subsection.
///
/// Use this inside of the main `task` sections.
/// Subtasks can be nested.
///
/// *Example*
/// ```typst
/// #task[
///   #subtask[Some task text.][This is the first subtask.]
///   #subtask[
///     #subtask[This is a nested subtask.]
///     #subtask[This is another.]
///   ]
/// ]
/// ```
/// -> content
#let subtask(
  /// The subtask marker.
  ///
  /// When set to #auto, this uses the subtask counter with the given numbering.
  ///
  /// -> auto | str
  marker: auto,
  /// The space between marker and subtask body. -> length
  marker-gap: 0.5em,
  /// A label that you can reference or query. -> str | none
  label: none,
  /// The supplement of the subtask which is used in outlines and references.
  ///
  /// -> content | str | function | none
  supplement: context i18n.translate("Subtask"),
  /// Set the value of the subtask counter (for the current depth) manually.
  ///
  /// If set to #auto, the counter is not reset.
  /// Regardless of this value, the counter is stepped at the end of the subtask.
  ///
  /// -> auto | int | function
  counter: auto,
  /// Step the subtask counter by the given number.
  ///
  /// This is applied after the general counter update (see `counter` parameter).
  ///
  /// -> none | int
  skip: none,
  /// The numbering patterns to use for the subtask markers depending on depth.
  ///
  /// This is an array of strings where the n-th element is the numbering pattern for subtasks of depth n.
  /// A single string is interpreted as a singleton array.
  ///
  /// *Example*
  /// ```typst
  /// #let subtask = subtask.with(numbering: ("1.", "i."), numbering-cycle: true)
  /// #subtask[
  ///   Subtask 1.
  ///   #subtask[Subtask i.]
  ///   #subtask[Subtask ii.]
  /// ]
  /// #subtask[Subtask 2.]
  /// ```
  /// -> array | str
  numbering: ("a)", "1.", "i."),
  /// The default numbering pattern if nothing is specified for the current depth.
  ///
  /// If set to #auto, use the last element of `numbering`.
  ///
  /// -> auto | str
  numbering-default: auto,
  /// Whether to cycle through the provided numbering patterns if nothing is specified for the current depth.
  ///
  /// If this is set, the `numbering-default` option has no effect.
  ///
  /// -> bool
  numbering-cycle: false,
  /// Whether to reset the theorem counter at the start of the subtask. -> bool
  theorem-counter-reset: false,
  /// The minimum indent of the subtask body.
  ///
  /// The indent of the subtask body is the maximum of this value and the width of the marker.
  ///
  /// -> length
  min-indent: 1.2em,
  /// Whether to insert a colbreak before the subtask.
  ///
  /// Technically, this breaks the column and not the page
  /// but a single-column layout is assumed.
  ///
  /// -> bool
  begin-at-new-page: false,
  /// A function that provides styling to the description of a subtask. -> function
  task-text-style: emph,
  /// The body of the subtask.
  /// Either:
  /// - [content]
  /// - [task text][content]
  /// -> content..
  ..body-args,
) = {
  let c = std.counter

  assert(body-args.named().len() == 0, message: "Unexpected named argument.")
  assert(
    body-args.pos().len() == 1 or body-args.pos().len() == 2,
    message: "subtask expects either [content] or [task text][content] as body arguments.",
  )

  let body-args = body-args.pos()
  let (task-text, body) = (
    if body-args.len() == 2 { body-args.at(0) } else { none },
    if body-args.len() == 2 { body-args.at(1) } else { body-args.at(0) },
  )

  if counter != auto {
    state("sheetstorm-subtask").update(xs => {
      let x = xs.pop()
      let update-counter = counter
      if type(update-counter) != function {
        update-counter = _ => counter
      }
      xs.push(update-counter(x))
      xs
    })
  }

  if skip != none and type(skip) == int {
    state("sheetstorm-subtask").update(xs => {
      let x = xs.pop()
      xs.push(x + skip)
      xs
    })
  }

  if theorem-counter-reset {
    c("sheetstorm-theorem-count").update(1)
  }

  let marker = if marker != auto { marker } else {
    context {
      let depth = state("sheetstorm-subtask").get().len() - 1
      let numbering = if type(numbering) == array { numbering } else {
        (numbering,)
      }
      assert(
        numbering.all(p => type(p) == str),
        message: "Numbering pattern is not a string",
      )

      let pattern = if numbering-cycle {
        numbering.at(calc.rem(depth, numbering.len()))
      } else {
        let default = numbering-default
        if numbering-default == auto { default = numbering.last() }
        numbering.at(depth, default: default)
      }

      state("sheetstorm-subtask-pattern").update(pattern)

      let num = state("sheetstorm-subtask").get().last()
      std.numbering(pattern, num)
    }
  }

  if begin-at-new-page {
    colbreak(weak: true)
  }

  grid(
    columns: (auto, auto, 1fr),
    column-gutter: 0em,
    {
      set align(right)

      context box(
        width: calc.max(min-indent.to-absolute(), measure(marker).width),
        inset: 0pt,
        outset: 0pt,
        marker,
      )

      if label != none {
        impromptu-label(
          kind: "sheetstorm-subtask-label",
          supplement: supplement,
          label,
        )
      }
    },
    h(marker-gap),
    {
      state("sheetstorm-subtask").update(xs => {
        xs.push(1)
        xs
      })
      if (task-text != none) {
        block(task-text-style(task-text))
      }
      body

      state("sheetstorm-subtask").update(xs => {
        let _ = xs.pop()
        xs
      })
    },
  )

  state("sheetstorm-subtask").update(xs => {
    let x = xs.pop()
    xs.push(x + 1)
    xs
  })
}
