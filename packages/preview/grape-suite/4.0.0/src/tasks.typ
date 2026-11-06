#import "colors.typ" as colors: *

#import "elements.typ" as elements

#let nobreak(body) = block(breakable: false, body)
#let center-block(body) = align(center, block(align(left, body)))

#let make-element(no, title, instruction, body, points, lines, element-type) = {
    let title = (
        if title != none [ --- #title] + h(1fr) + if points > 0 [#points P.]
    )
    let c = get-colors()
    block(
        inset: 7pt,
        stroke: (bottom: (paint: c.primary, dash: "dashed")),
        fill: c.accent-light,
        {
            text(fill: c.primary, strong[#element-type #no] + title)
        },
    )

    block(width: 100%, {
        state("grape-suite-subtask-indent").update((0,))

        if instruction != none and instruction not in ([], [ ]) {
            block(instruction)
        }

        state("grape-suite-subtask-indent").update((0,))

        if body != none and body not in ([], [ ]) { block(body) }

        context {
            if state("grape-suite-show-lines").at(here()) == false {
                return
            }

            for i in range(0, lines) {
                v(0.75cm)
                v(-1.2em)
                line(length: 100%, stroke: black.lighten(50%))
            }
        }
    })
}

#let make-rubric-row(
    show-comment-field: false,
    comment-field-value: none,
    no,
    title,
    extra,
    points,
    rubric,
    task-type,
    extra-task-type,
) = {
    let c = get-colors()
    assert(
        rubric == none or points == rubric.fold(0, (sum, s) => sum + s.at(0)),
        message: "rubric should have the same number of points as the whole task! (task no "
            + str(no)
            + ")",
    )
    let parts = if (rubric == none) { () } else { rubric }
    let e = (
        table.hline(stroke: c.primary),

        table.cell(
            fill: c.accent-light,
            strong(if extra [#extra-task-type ] else [#task-type ])
                + strong(no)
                + if title != none [ --- #title],
        ),

        table.cell(fill: c.accent-light, align(
            center,
            strong[#box(line(length: 0.75cm)) / #points],
        )),

        table.hline(stroke: c.primary),
        ..parts
            .map(s => (
                s.at(1),
                align(center, box(line(length: 0.75cm)) + [ \/ #s.at(0)]),
            ))
            .intersperse(
                table.hline(stroke: (paint: c.primary, dash: "dashed")),
            )
            .flatten(),
    )

    if show-comment-field {
        e.push(table.cell(colspan: 2, comment-field-value))
    }

    return e
}

#let make-grading-rubric(
    show-comment-field: false,
    comment-field-value: none,
    loc,
    rubric-task-header,
    task-type,
    extra-task-type,
    achieved-points,
) = context {
    let tasks = state("grape-suite-tasks").at(loc)

    if tasks == none {
        return
    }
    let (extra-tasks, non-extra-tasks) = tasks
        .filter(t => t.points > 0 and not t.ignore-points)
        .fold(((), ()), (acc, t) => {
            acc.at(if t.extra { 0 } else { 1 }).push(t)
            return acc
        })
    let c = get-colors()
    table(
        columns: (1fr, 3cm),
        stroke: none,
        inset: (x: 1em, y: 0.75em),

        table.cell(fill: c.primary, text(fill: white, align(
            horizon,
            strong(rubric-task-header),
        ))),

        table.vline(stroke: c.primary),

        table.cell(fill: c.primary, text(fill: white, align(
            center,
            strong(achieved-points),
        ))),

        ..(
            non-extra-tasks
                .map(task => make-rubric-row(
                    show-comment-field: show-comment-field,
                    comment-field-value: comment-field-value,
                    task.no,
                    task.title,
                    task.extra,
                    task.points,
                    task.rubric,
                    task.task-type,
                    task.extra-task-type,
                ))
                .flatten()
        ),

        table.cell(colspan: 2, fill: c.primary, v(-10pt)),

        ..(
            extra-tasks
                .map(task => make-rubric-row(
                    show-comment-field: show-comment-field,
                    comment-field-value: comment-field-value,
                    task.no,
                    task.title,
                    task.extra,
                    task.points,
                    task.rubric,
                    task-type,
                    extra-task-type,
                ))
                .flatten()
        ),

        ..(
            if extra-tasks.len() > 0 {
                (table.cell(colspan: 2, fill: c.primary, v(-10pt)),)
            } else { () }
        ).flatten(),

        [],
        [
            #show: align.with(center)

            #let task-points = (
                tasks
                    .filter(e => not e.extra and not e.ignore-points)
                    .map(e => e.points)
                    .sum(default: 0)
            )
            #let extra-points = (
                tasks
                    .filter(e => e.extra and not e.ignore-points)
                    .map(e => e.points)
                    .sum(default: 0)
            )

            #box(line(length: 0.75cm)) /
            #task-points #if extra-points > 0 [ \+ #extra-points]  P.

            #v(-0.5em)
            #line(length: 100%)
            #v(-1em)
            #line(length: 100%)
        ],
    )
}

#let make-points-table(
    header-task: [Task],
    header-points: [Points],
    header-achieved: [Achieved],
) = {
    let tasks = state("grape-suite-tasks").final()
    let tables = calc.ceil(tasks.len() / 10)
    let c = get-colors()

    set table.vline(stroke: c.primary)
    set table.hline(stroke: c.primary)
    set line(stroke: c.primary)
    set text(fill: c.primary)

    show: block.with(
        fill: c.accent-light,
        breakable: false,
        stroke: c.primary,
        inset: 1em,
        width: 100%,
    )

    set align(center)

    for i in range(tables) {
        let tasks = tasks.slice(10 * i, calc.min(tasks.len(), 10 * i + 10))

        table(
            columns: calc.min(10 + 1, tasks.len() + 2),
            stroke: none,

            table.hline(y: 1),
            table.hline(y: 2),

            table.cell(x: 0, y: 0, strong(header-task)),
            table.cell(x: 0, y: 1, strong(header-points)),
            table.cell(x: 0, y: 2, strong(header-achieved)),

            ..(
                tasks
                    .enumerate()
                    .map(((n, e)) => (
                        table.vline(x: n + 1),
                        table.cell(x: n + 1, y: 0)[#e.no],
                        table.cell(x: n + 1, y: 1)[#e.points],
                        table.cell(x: n + 1, y: 2)[#align(bottom, box(
                            line(length: 2em),
                        ))],
                    )),

                table.vline(x: tasks.len() + 1),
                table.cell(y: 0, $sum$),
                table.cell(y: 1)[],
                table.cell(y: 2)[#align(bottom, box(
                    line(length: 2em),
                ))],
            ).flatten()
        )
    }
}

#let make-point-distribution(
    loc,
    message,
    grade-scale,

    header-point-value,
    header-point-grade,
) = {
    let points = state("grape-suite-tasks").final()
    let points-sum = points
        .filter(e => not e.extra and not e.ignore-points)
        .map(e => e.points)
        .sum(default: 0)
    let extrapoints-sum = points
        .filter(e => e.extra and not e.ignore-points)
        .map(e => e.points)
        .sum(default: 0)
    let points-sum-all = points-sum + extrapoints-sum

    if points-sum-all > 0 {
        let c = get-colors()
        set text(fill: c.primary)
        block(
            fill: c.accent-light,
            breakable: false,
            stroke: c.primary,
            inset: 1em,
            width: 100%,
            {
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

                let grade-scale = grade-scale
                    .map(e => {
                        e.at(1) = calc.floor(e.at(1) * points-sum)
                        e
                    })
                    .enumerate()

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
                    }),

                    table.hline(stroke: 1pt + c.primary),

                    strong(header-point-grade),
                    ..grade-scale
                        .rev()
                        .map(e => (
                            table.vline(stroke: 1pt + c.primary),
                            text(size: 0.95em, e.at(1).first()),
                        ))
                        .rev()
                        .flatten(),
                ))
            },
        )
    }
}

#let hint(body) = {
    context {
        let (show-hints,) = state("grape-suite-show-rules").at(here())
        if (not show-hints) { return }

        state("grape-suite-subtask-indent").update((0,))
        elements.hint(body)
    }
};

#let solution(body) = {
    context {
        let (show-solutions,) = state("grape-suite-show-rules").at(here())
        if (not show-solutions) { return }

        state("grape-suite-subtask-indent").update((0,))
        elements.solution(body)
    }
}

#let _type = type
#let task(
    // number of lines to draw if show-lines of exercise-template is enabled
    lines: 0,

    // number of points, subtask points will be added
    points: 0,

    // is extra task?
    extra: false,

    // iff true, ignore points in final sum and grading rubric
    ignore-points: false,

    // description of points awarded for the task: list of tuples of (point_number, description)
    rubric: none,

    // numbering of task
    numbering-format: none,

    // formatting of task title
    instruction-format: none,

    // formatting of task instruction - default: emph
    title-format: none,
    // type of task
    type: none,

    // Title of the task
    title,

    // Instructions for the task
    instruction,

    // optional: body (and optional legacy arguments: solution, hint)
    ..body,
) = (
    counter(if extra { "tasks" } else { "extra-tasks" }).step()
        + context {
            let task-translation-state = state(
                "grape-suite-task-translations",
                (task-type: [Task], extra-task-type: [Extra task]),
            )
            let task-type = task-translation-state.final().task-type
            let extra-task-type = task-translation-state.final().extra-task-type

            let numbering-format = numbering-format
            if numbering-format == none {
                numbering-format = (..c) => numbering(
                    if extra { "1" } else { "A" },
                    ..c,
                )
            }
            let title-format = title-format
            if title-format == none {
                title-format = it => it
            }

            let instruction-format = instruction-format
            if instruction-format == none {
                instruction-format = emph
            }

            let no = numbering-format(
                ..counter(if extra { "tasks" } else { "extra-tasks" }).at(
                    here(),
                ),
            )

            let t = (
                no: no,
                title: if title != none { title-format(title) },
                instruction: if instruction != none {
                    instruction-format(instruction)
                },
                body: body.at(0, default: none),
                rubric: if body.pos().len() > 1
                    and _type(body.pos().at(1)) == array {
                    body.pos().at(1)
                } else { rubric },
                points: points,
                extra: extra,
                ignore-points: ignore-points,
                extra-task-type: if type != none { type } else {
                    extra-task-type
                },
                task-type: if type != none { type } else { task-type },
            )

            if t.body == [] or t.body == [ ] {
                t.body = none
            }

            state("grape-suite-tasks", ()).update(k => {
                k.push(t)
                return k
            })

            state("grape-suite-subtask-indent").update((0,))

            let t = state("grape-suite-tasks")
                .final()
                .filter(e => e.no == t.no and e.title == t.title)
                .first(default: none)

            if t != none {
                make-element(
                    no,
                    t.title,
                    t.instruction,
                    t.body,
                    t.points,
                    lines,
                    if type != none { type } else if t.extra {
                        extra-task-type
                    } else { task-type },
                )
            }
        }
            + if body.pos().len() > 1 {
                if body.pos().len() > 2 {
                    hint(body.at(2))
                }

                if (
                    body.pos().at(1) != none
                        and _type(body.pos().at(1)) != array
                ) {
                    solution(body.at(1))
                }
            }
            + v(0.5cm)
)

#let subtask(
    points: 0,
    tight: false,
    ignore-points: false,
    markers: ("1.", "a)"),
    show-points: true,
    counter: none,
    content,
) = {
    if points != none and type(points) == int and not ignore-points {
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

    context {
        let indent = state("grape-suite-subtask-indent").at(here())

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

        if not tight {
            v(0.25em)
        }

        grid(
            columns: (2em, 1fr),
            column-gutter: 0.75em,
            {
                set align(right)
                numbering(marker, num)
            },
            if points != none and points > 0 and show-points {
                metadata((
                    type: "grape-suite-subtask-points",
                    content: block(width: 7%, [#points P.]),
                ))
                content
            } else {
                content
            },
        )

        if not tight {
            v(0.25em)
        }
    }

    state("grape-suite-subtask-indent", (0,)).update(k => {
        k = k.slice(0, k.len() - 1)

        if k.len() > 0 {
            k.last() = k.last() + 1
        }

        k
    })
}
