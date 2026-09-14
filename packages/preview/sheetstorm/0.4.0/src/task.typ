#import "numbering.typ": custom-enum-numbering
#import "i18n.typ"
#import "todo.typ": todo, todo-box
#import "labelling.typ": impromptu-label

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
  /// Set the numbering for subtasks.
  ///
  /// If you give a numbering, it just sets the enum numbering accordingly.
  /// If you set it to `none`, it disables the custom numbering completely.
  ///
  /// The library provides a handy `custom-enum-numbering` function that is expected to be used
  /// when setting the numbering to a non-trivial value.
  /// The required `enum.full` option is set automatically.
  ///
  /// -> function | str | none
  subtask-numbering: custom-enum-numbering("a)", "1.", "i."),
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
  /// Whether the task is a bonus task. -> bool
  bonus: false,
  /// Whether bonus tasks are marked with a star in the title. -> bool
  bonus-show-star: true,
  /// Whether the task is hidden in the score box. -> bool
  hidden: false,
  /// Padding above the task. -> auto | length
  space-above: auto,
  /// Padding below the task. -> auto | length
  space-below: 2em,
  /// The body of the task. -> content
  content,
) = {
  let c = std.counter

  if counter != auto { c("sheetstorm-task").update(counter) }

  let (points-number, points-display) = _handle_points(points)

  state("sheetstorm-points").update(points-number)
  state("sheetstorm-bonus").update(bonus)
  state("sheetstorm-hidden-task").update(hidden)

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
    task-prefix
    if counter-show {
      if task-prefix != "" [ ]
      context c("sheetstorm-task").display()
    }
    if name != none [: #emph(name)]
    if bonus and bonus-show-star [\*]

    if todo-show and maybe-todo != none {
      h(0.7em)
      maybe-todo
    }
  }

  block(width: 100%, above: space-above, below: space-below)[
    #set enum(
      full: type(subtask-numbering) != str,
      numbering: subtask-numbering,
    ) if subtask-numbering != none

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
    #content
    #metadata("sheetstorm-task-end")<sheetstorm-task-end>
  ]

  c("sheetstorm-task").step()
  c("sheetstorm-todo").update(0)
}
