#import "colors.typ" as colors: *
#import "slides.typ" as slides-lib

#let nobreak(body) = block(breakable: false, body)
#let center-block(body) = align(center, block(align(left, body)))

#let big-heading(title) = pad(bottom: 0.5cm,
        align(center,
            text(fill: purple,
                size: 1.75em,
                strong(title))))

#let make-element(type, no, title, body) = {
    block(inset: 7pt,
        stroke: (bottom: (paint: purple, dash: "dashed")),
        fill: blue.lighten(75%), {

        text(fill: purple, strong[#type #no] + [ --- #title])
    })

    block(body)
    v(0.5cm)
}

#let make-task(no, title, instruction, body, extra, points, lines, extra-task-type, task-type) = {
    make-element(if extra {extra-task-type} else {task-type},
        no,
        title + h(1fr) + if points != none and points > 0 { [#points P.] },
        if instruction != none and instruction not in ([], [ ]) { block(emph(instruction)) } + if body != none { block(body) } +

        locate(loc => {
            if state("grape-suite-show-lines").at(loc) == false {
                return
            }

            for i in range(0, lines) {
                v(0.75cm)
                v(-1.2em)
                line(length: 100%, stroke: black.lighten(50%))
            }
        }))
}

#let make-solution(no, title, instruction, body, extra, points, solution, solution-type) = {
    make-element(solution-type,
        no,
        title + h(1fr) + if points != none and points > 0 { [#points P.] },
        if instruction != none { block(emph(instruction)) } + if body != none { block(body) } + state("grape-suite-subtask-indent").update((0,)) + slides-lib.solution(solution))
}

#let make-hint(no, title, instruction, body, extra, points, hint, hint-type) = {
    make-element(hint-type,
        no,
        title + h(1fr) + if points != none and points > 0 { [#points P.] },
        if instruction != none { block(emph(instruction)) } + if body != none { block(body) } + state("grape-suite-subtask-indent").update((0,)) + slides-lib.hint(hint))
}

#let make-solutions(loc,
    solution-type
) = {
    let tasks = state("grape-suite-tasks").at(loc)

    if tasks == none {
        return
    }

    for task in tasks {
        if task.solution == none {
            continue
        }

        make-solution(task.no,
            task.title,
            task.instruction,
            task.body,
            task.extra,
            task.points,
            task.solution,
            solution-type)
    }
}

#let make-hints(loc,
    hint-type,
) = {
    let tasks = state("grape-suite-tasks").at(loc)

    if tasks == none {
        return
    }

    let tasks = state("grape-suite-tasks").at(loc)

    if tasks == none {
        return
    }

    for task in tasks {
        if task.hint == none {
            continue
        }

        make-hint(task.no,
            task.title,
            task.instruction,
            task.body,
            task.extra,
            task.points,
            task.hint,
            hint-type)
    }
}

#let make-matrix-row(no, title, extra, points, solutions, task-type, extra-task-type) = (
    table.hline(stroke: purple),

    table.cell(fill: blue.lighten(75%),
        strong(if extra [#extra-task-type ] else [#task-type ]) +
        strong[#no --- #title]),

    table.cell(fill: blue.lighten(75%),
        align(center, strong[#box(line(length: 0.75cm)) / #points])),

    table.hline(stroke: purple),

    ..solutions.map(e => (
        e.at(1),
        align(center, box(line(length: 0.75cm)) + [ \/ #e.at(0)]),
        table.hline(stroke: (paint: purple, dash: "dashed")),
    )).flatten()
)

#let make-solution-matrix(loc,
    matrix-task-header,
    task-type,
    extra-task-type,
    achieved-points
) = {
    let tasks = state("grape-suite-tasks").at(loc)

    if tasks == none {
        return
    }

    let tasks = state("grape-suite-tasks").at(loc)

    if tasks == none {
        return
    }

    table(
        columns: (1fr, 3cm),
        stroke: none,
        inset: (x: 1em, y: 0.75em),

        table.cell(fill: purple, text(fill: white,
            align(horizon, strong(matrix-task-header)))),

        table.vline(stroke: purple),

        table.cell(fill: purple, text(fill: white,
            align(center, strong(achieved-points)))),

        ..tasks
            .filter(task =>
                not task.extra and
                task.solution != none and
                type(task.solution) == array)

            .map(task => {
                make-matrix-row(task.no,
                    task.title,
                    task.extra,
                    task.points,
                    task.solution,
                    task-type,
                    extra-task-type)}).flatten(),

        table.cell(colspan: 2, fill: purple, v(-10pt)),

        ..(if tasks.filter(task => task.extra and
                    task.solution != none and
                    type(task.solution) == array).len() > 0 {
            (
                tasks.filter(task =>
                    task.extra and
                    task.solution != none and
                    type(task.solution) == array)

                .map(task => {
                    make-matrix-row(task.no,
                        task.title,
                        task.extra,
                        task.points,
                        task.solution,
                        task-type,
                        extra-task-type)}).flatten(),

                table.cell(colspan: 2, fill: purple, v(-10pt))
            )
        } else { () }).flatten(),

        [], [
            #show: align.with(center)

            #box(line(length: 0.75cm)) /
            #tasks.filter(e => not e.extra).map(e => e.points).sum(default: 0) + #tasks.filter(e => e.extra).map(e => e.points).sum(default: 0) P.

            #v(-0.5em)
            #line(length: 100%)
            #v(-1em)
            #line(length: 100%)
        ]
    )
}

#let make-point-distribution(loc,
    message,
    grade-scale,

    header-point-value,
    header-point-grade
) = {
    let points = state("grape-suite-tasks").at(loc)
    let points-sum = points.filter(e => not e.extra).map(e => e.points).sum(default: 0)
    let extrapoints-sum = points.filter(e => e.extra).map(e => e.points).sum(default: 0)
    let points-sum-all = points-sum + extrapoints-sum

    if points-sum-all > 0 {
        v(1fr)
        set text(fill: purple)
        block(fill: blue.lighten(75%),
            breakable: false,
            stroke: purple,
            inset: 1em,
            width: 100%, {

            message(points-sum, extrapoints-sum)

            let f(from, to) = {
                from = calc.round(from)
                to = calc.round(to)

                if from == to [#from] else [#from -- #to]
            }

            /*
            let n = 3

            let top-socket = points-sum * 0.9
            let bottom-socket = points-sum * 0.5

            let point-distribution = (f(points-sum, top-socket),)
            let last-to = top-socket

            for i in range(0, n) {
                let to = calc.min(last-to - 1, top-socket - (top-socket - bottom-socket) / n * (i + 1))

                point-distribution.push(f(last-to - 1, to))
                last-to = to
            }

            point-distribution.push(f(last-to - 1, 0))
            */

            let grade-scale = grade-scale.map(e => {
                e.at(1) = calc.floor(e.at(1)*points-sum)
                e
            }).enumerate()

            center-block(table(
                columns: grade-scale.len() + 1,
                stroke: none,
                align: center,

                strong(header-point-value), ..grade-scale.map(e => {
                    let (index, (_, p)) = e

                    let last-to = if index > 0 {
                        grade-scale.at(index - 1).last().last() - 1
                    } else {
                        points-sum
                    }

                    let to = calc.min(last-to, p)

                    if index + 1 >= grade-scale.len() {
                        to = 0
                    }

                    if last-to == to [#to] else [#last-to#[--]#to]
                }),//point-distribution,
                    // [#calc.round(points-sum*0.5 - 1) -- 0],

                table.hline(stroke: 1pt + purple),

                strong(header-point-grade),
                ..grade-scale
                    .rev()
                    .map(e => (table.vline(stroke: 1pt + purple), text(size: 0.95em, e.at(1).first())))
                    .rev()
                    .flatten(),
            ))
        })
    }
}

#let task(
    // number of lines to draw if show-lines of exercise-template is enabled
    lines: 0,

    // number of points, subtask points will be added
    points: 0,

    // is extra task?
    extra: false,

    // numbering of task
    numbering-format: none,

    // Titel der Aufgabe
    title,

    // Aufgabenstellung
    instruction,

    // optional: body, solution (see exercise.project(show-solutions-as-matrix: ...) !), hint
    ..args
    ) = counter(if extra { "tasks" } else { "extra-tasks" }).step() + locate(loc => {

    let task-translation-state = state("grape-suite-task-translations", (task-type: [Task], extra-task-type: [Extra task]))
    let task-type = task-translation-state.final(loc).task-type
    let extra-task-type = task-translation-state.final(loc).extra-task-type

    let numbering-format = numbering-format
    if numbering-format == none {
        numbering-format = (..c) => numbering(if extra { "1" } else { "A" }, ..c)
    }

    let args = args.pos()
    let no = numbering-format(..counter(if extra { "tasks" } else { "extra-tasks" }).at(loc))

    let t = (
        no: no,
        title: title,
        instruction: instruction,
        body: args.at(0, default: none),
        solution: args.at(1, default: none),
        hint: args.at(2, default: none),
        points: points,
        extra: extra
    )

    if t.body == [] or t.body == [ ] {
        t.body = none
    }

    state("grape-suite-tasks", ()).update(k => {
        k.push(t)
        return k
    })

    state("grape-suite-subtask-indent").update((0,))

    locate(loc => {
        let t = state("grape-suite-tasks").final(loc).at(state("grape-suite-tasks").at(loc).len() - 1)
        make-task(no,
            title,
            instruction,
            t.body,
            t.extra,
            t.points,
            lines,
            extra-task-type,
            task-type)
    })
})

#let subtask(points: 0,
    tight: false,
    markers: ("1.", "a)"),
    show-points: true,
    counter: none,
    content) = {

    if points != none and type(points) == int {
        state("grape-suite-tasks", ()).update(k => {
            if k.len() == 0 {
                return k
            }

            let li = k.len() - 1
            let e = k.at(li)

            e.points += points

            k.at(li) = e
            return k
        })
    }

    state("grape-suite-subtask-indent", (0,)).update(k => {
        k.push(0)
        k
    })

    locate(loc => {
        let indent = state("grape-suite-subtask-indent").at(loc)

        let num = if counter == none {
            indent.at(indent.len() - 2) + 1
        } else {
            counter
        }

        let marker = if indent.len() - 2 >= markers.len() {
            "i."
        } else {
            markers.at(indent.len() - 2)
        }

        enum(numbering: (_) => numbering(marker, num), tight: tight, if points != none and points > 0 and show-points {
            place(dx: 100%, [#points P.])
            block(width: 95%, content)
        } else {
            content
        })
    })

    state("grape-suite-subtask-indent", (0,)).update(k => {
        k = k.slice(0, k.len() - 1)

        if k.len() > 0 {
            k.last() = k.last() + 1
        }

        k
    })
}