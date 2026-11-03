#import "helpers.typ"
#import "options.typ": options, color
#import "check.typ": assert-set, assert-no-extra
#let t-count = counter("bmim-task")
#let t-points = state("bmim-task-points", ())
#let t-solutions = state("bmim-task-solutions", ())

#let total-count() = t-points.final().len()
#let task-points() = t-points.final().map(array.sum.with(default: 0))
#let total-points() = task-points().sum(default:0)

#let t-mark = metadata("bmim-task-locator")

// Numbering of tasks, prefixed by the wrap counter (e.g. the chapter) if set:
// "1.a" gives "1" for a task and "1.a" for a subtask.
#let task-numbering(opts) = {
  let lvl = if opts.task-wrap-counter == none { 0 } else { opts.task-wrap-counter.at(1) }
  "1." * lvl + "1.a"
}
#let t-label(lbl) = label("bmim-"+str(lbl)+"-tsk")
#let t-label-sol(lbl) = label("bmim-"+str(lbl)+"-sol")


#let style-heading(lbl, tasknum, name, points, task, lvl:1) = [
  #let opts = options.final()
  #let spell = opts.spell

  #let msg = {
    [#spell.task #context numbering(task-numbering(opts), ..t-count.get())]
    if name != none { h(1em) + name }
    h(1fr)
    if opts.task-show-points [#spell.poi: #points]
  }

  #show heading: set block(above: 0pt)
  #block(above:1.2em, below:0pt,sticky:true, lbl)
  #heading(level:lvl, msg, numbering: none)

  #task#parbreak()
  #if opts.show-solution == "bottom" {
    let find = query(t-label-sol(tasknum))
    let loc = if find.len() == 0 { here() } else { find.first().location() }
    let msg = {
      sym.arrow.r.hook
      sym.space.nobreak.narrow
      spell.page
      sym.space.nobreak.narrow
      // in the numbering of the solution page, e.g. roman
      numbering(
        if loc.page-numbering() == none { "1" } else { loc.page-numbering() },
        ..counter(page).at(loc),
      )
    }
    [_#spell.solution-on #link(loc, msg)._]
  }
]

#let style-enum(lbl, tasknum, name, points, task) = context {
  let opts = options.final()
  set enum(numbering: (..n) => context {
    let level = t-count.get().len()
    if level == 3 {
      numbering("a)", t-count.get().at(2))
    } else {
      numbering(task-numbering(opts), ..t-count.get())
    }
  })
  lbl + enum(task)
}

#let solution-inline(solution) = context block(
  width: 100%,
  stroke: 2pt + color.red,
  inset: .5em,
  breakable: true,
)[
  *#options.final().spell.solution:*

  #solution
]

#let solution-bottom = context [
  #let spell = options.final().spell
  // Fixing the enum formatting for the subtasks and their solution
  #set enum(numbering: "a)")

  = #spell.solutions <bmim:nonumber>
  #for (num, solution) in t-solutions.final().enumerate(start:0) [

    #show heading: set block(above: 0pt)
    #block(above:1.2em, below:0pt, sticky:true, [#t-mark#t-label-sol(num)])
    == #spell.solution-to #ref(t-label(num)) <bmim:nonumber>

    #solution
  ]
]

// Solutions of the option show-solution "bottom", on a new page
#let solutions-at-end(show-solution) = if show-solution == "bottom" {
  pagebreak(weak: true)
  solution-bottom
}

#let subtask-keys = ("points", "description", "solution", "label")

// A task is either a single task with `points`, `description` and `solution`,
// or a task with subtasks: a problem description followed by one dictionary
// per subtask, each with the keys `points`, `description`, `solution` and an
// optional `label`.
#let task(
  points: none, // number or array of numbers, none for a task with subtasks
  description: none,
  solution: none,
  label: none,
  name: none,
  ..args, // task with subtasks: problem description, subtask dictionaries
) = context {
  assert-no-extra(args, "task")
  let is-super = points == none
  let subtasks = args.pos().slice(calc.min(1, args.pos().len()))
  if is-super {
    assert(args.pos().len() > 0, message:
      "task needs either 'points', 'description' and 'solution', " +
      "or a problem description followed by subtasks"
    )
    assert(description == none and solution == none, message:
      "Arguments 'description' and 'solution' of task are not allowed " +
      "for a task with subtasks, set them per subtask"
    )
    for (i, sub) in subtasks.enumerate() {
      let of = "subtask " + str(i + 1)
      assert(type(sub) == dictionary, message:
        "Subtask " + str(i + 1) + " of task must be a dictionary with " +
        "points, description and solution, but was " + repr(sub)
      )
      for key in sub.keys() {
        assert(key in subtask-keys, message:
          "Unknown key '" + key + "' of " + of + ", known keys are [" +
          subtask-keys.map(repr).join(", ") + "]"
        )
      }
      for key in ("points", "description", "solution") {
        assert-set(key, sub.at(key, default: none), of: of)
      }
    }
  } else {
    assert(args.pos().len() == 0, message:
      "task with 'points' takes no positional arguments, " +
      "use 'description' instead"
    )
    assert-set("description", description, of: "task")
    assert-set("solution", solution, of: "task")
  }
  let lbl = label

  let points-or-empty = {
    if is-super { () } else { (points,).flatten() }
  }

  let opts = options.final()
  // counter and level (e.g. the chapter) after which the task numbers restart
  let (wrap, lvl) = if opts.task-wrap-counter == none { (none, 0) } else { opts.task-wrap-counter }
  if wrap != none { // check if we need to reset, recursively
    let w = wrap.get()
    for i in range(lvl) {
      if w.at(i) != t-count.get().at(i) {
        t-count.update(
          w.slice(0, lvl)
        )
        break
      }
    }
  }
  t-count.step(level: lvl+1)
  t-points.update(p => { p.push(points-or-empty); return p });
  if is-super {
    // store points
    for sub in subtasks {
      t-points.update(p => {p.last().push(sub.points); return p})
    }
  }

  {
    // Fixing the enum formatting for the subtasks and their solution
    set enum(numbering: "a)")
    let tasknum = t-points.get().len()

    let points = t-points.final().at(tasknum, default:())
    let enum-cnt = t-count.step(level:lvl+2)
    let description = if is-super {
      args.pos().first()
      enum-cnt
      subtasks.map(it => {
        let lbl = if "label" in it [ #t-mark#it.label ]
        [+ #lbl #it.description #enum-cnt]
      }).join()
    } else { description }

    // show descriptions
    (opts.task-show)(
      [#t-mark#t-label(tasknum)] + if lbl != none [#t-mark#lbl],
      tasknum,
      name,
      points.sum(default:0),
      description
    )

    let show-points(p) = if opts.task-show-points {text(
      fill: color.green,
      grid(
        columns: 2,
        repeat("." + h(2.5pt)),
        [$Sigma$ #p #opts.spell.points-short]
      )
    )}

    // subtasks: one enum item per solution
    let sol-style(it, p) = {
      let body = [#it \ #show-points(p) ]
      if is-super { enum.item(body) } else { body }
    }
    let solution = (
      if is-super {
        subtasks.map(sub => sub.solution).zip(points)
      } else {(
        (solution, points.first(default:0)),
      )}
    ).map(tmp => sol-style(..tmp)).join()

    // inline solutions
    if opts.show-solution == "inline" {
        solution-inline[

          #solution
        ]
    } else if opts.show-solution == "bottom" {
      t-solutions.update(p => { p.push(solution); return p})
    }
  }
}

#let show-ref(it) = {
  let opts = options.final()
  helpers.marked-ref(it, t-mark, opts.spell.task,
    loc => numbering(task-numbering(opts), ..t-count.at(loc)))
}


#let points-table = context {
  let spell = options.final().spell
  let n = total-count()
  let points = task-points()
  show table.cell.where(y: 0): strong

  table(
    columns: (1fr,)*(n + 2),
    rows: (auto, auto, 2em),
    align: center,
    ..range(1,n+1).map(str), $Sigma$, spell.mark,
    ..points.map(str), str(points.sum(default:0)), [],
    ..range(n+2).map(it => [])
  )
}
