#import "utils.typ"
#import "options.typ": options, color
#let t-count = counter("task")
#let t-points = state("task-points", ())
#let t-solutions = state("task-solutions", ())

#let total-count() = t-points.final().len()
#let task-points() = t-points.final().map(array.sum.with(default: 0))
#let total-points() = task-points().sum(default:0)

#let t-mark = metadata("task-locator")
#let t-label(lbl) = label("bmim-"+str(lbl)+"-tsk")
#let t-label-sol(lbl) = label("bmim-"+str(lbl)+"-sol")


#let style-heading(lbl, tasknum, name, points, task, lvl:1) = [
  #let opts = options.final()
  #let spell = opts.spell

  #let msg = {
    [#spell.task #context numbering("1.1.a", ..t-count.get())]
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
      str(counter(page).at(loc).first())
    }
    [_Lösung auf #link(loc, msg)._]
  }
]

#let style-enum(lbl, tasknum, name, points, task) = context [
  #let opts = options.final()
  #set enum(numbering: (..n) => context {
    numbering("1.1.a", ..t-count.get())
  })
  + #lbl#task
]

#let solution-inline(solution) = {
  block(
    width: 100%,
    fill: color.red.lighten(0%),
    inset: 2pt,
    breakable: true,
    block(
      stroke: 0.5pt,
      width: 100%,
      fill: white,
      inset: 0.3em,
      breakable: true,
    )[
      *Lösung:*

      #solution
    ]
  )
}

#let solution-bottom = context [
  = Lösungen <bmim:nonumber>
  #for (num, solution) in t-solutions.final().enumerate(start:0) [

    #show heading: set block(above: 0pt)
    #block(above:1.2em, below:0pt,sticky:true, [#t-mark#t-label-sol(num)])
    == Lösung zu #ref(t-label(num)) <bmim:nonumber>

    #solution
  ]
]

#let task(..args) = context {
  let is-super = "points" not in args.named()
  let lbl = args.named().at("label", default: none)

  let points-or-empty = {
    if is-super { () } else { (args.named().points,).flatten() }
  }

  let opts = options.final()
  let wrap = if opts.task-wrap-counter == none {
    (c: counter("task-counter-ignore"), lvl: 0)
  } else {
    ("c", "lvl").zip(opts.task-wrap-counter).fold((:), (acc, it) => {
      acc += (it.first(): it.last())
      acc
    })
  }
  if wrap.lvl != 0 { // check if we need to reset, recursively
    let w = wrap.c.get()
    for i in range(wrap.lvl) {
      if w.at(i) != t-count.get().at(i) {
        t-count.update(
          w.slice(0, wrap.lvl)
        )
        break
      }
    }
  }
  t-count.step(level: wrap.lvl+1)
  t-points.update(p => { p.push(points-or-empty); return p });
  if is-super {
    // store points
    for (sub, arg) in args.pos().slice(1).enumerate() {
      t-points.update(p => {p.last().push(arg.points); return p})
    }
  }

  {
    let tasknum = t-points.get().len()

    let points = t-points.final().at(tasknum, default:())
    let description = if is-super [
          #args.pos().first()

          #args.pos().slice(1).map(it => {
            let lbl = if "label" in it [ #t-mark#it.label ]
            [+ #t-count.step(level:wrap.lvl+2)#lbl #it.description]
          }).join()
    ] else { args.named().description }

    // show descriptions
    (opts.task-show)(
      [#t-mark#t-label(tasknum)] + if lbl != none [#t-mark#lbl],
      tasknum,
      args.named().at("name", default: none),
      points.sum(default:0),
      description
    )

    let show-points(p) = if opts.task-show-points {text(
      fill: color.green,
      grid(
        columns: 2,
        repeat("." + h(2.5pt)),
        [$Sigma$ #p P.]
      )
    )}

    let sol-style = if is-super { (it, p) => [+ #it \ #show-points(p) ] }
                    else { (it, p) => [#it \ #show-points(p) ] }
    let solution = (
      if is-super {
        args.pos().slice(1).map(sub => sub.solution).zip(points)
      } else {(
        (args.named().solution, points.first(default:0)),
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
  let el = it.element
  if el != none and el.func() == metadata and el == t-mark {
    let supp = it.supplement
    if supp == auto {
      supp = opts.spell.task
    }
    let loc = el.location()
    let num = if opts.task-wrap-counter != none { opts.task-wrap-counter.at(1) * "1." } + "1.a"
    let ref-counter = numbering(num, ..t-count.at(loc))
    if utils.is-empty(supp) {
      link(el.location(), ref-counter)
    }
    else {
      link(el.location(), box([#supp~#ref-counter]))
    }
  } else {
    it
  }
}


#let points-table = context {
  let n = total-count()
  let points = task-points()
  show table.cell.where(y: 0): strong

  table(
    columns: (1fr,)*(n + 2),
    rows: (auto, auto, 2em),
    align: center,
    ..range(1,n+1).map(str), $Sigma$, [Note],
    ..points.map(str), str(points.sum(default:0)), [],
    ..range(n+2).map(it => [])
  )
}

#{
  show: it=> page(columns:2, it)
  place(points-table, float:true, scope:"parent", auto)

  let multitask(i) = task(
    [problem description],
    (
      points: 10*i + 1,
      description: [ sub- description #i - 1],
      solution: [sub -sol #i - 1],
    ),
    (
      points: 10*i + 2,
      description: [ sub- description #i - 2],
      solution: [sub -sol #i - 2],
    ),
    (
      points: 10*i + 3,
      description: [ sub- description #i - 3],
      solution: [sub -sol #i - 3],
    ),
    (
      points: 10*i + 4,
      description: [ sub- description #i - 4],
      solution: [sub -sol #i - 4],
    ),
  )

  multitask(1)
  context t-points.get()
  multitask(2)
  context t-points.get()
  multitask(3)
  context t-points.get()
  multitask(4)
  context t-points.get()
  multitask(5)
  context t-points.get()

  task(
    points: 5,
    description: [ single points task description ],
    solution: [ this is how ],
  )

  solution-bottom
}
