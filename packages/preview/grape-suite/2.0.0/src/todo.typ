#import "colors.typ": magenta
#let todo-state = state("grape-suite-todos", ())

#let make-todo-label(loc) = {
    return ("todo-label-" +
        str(loc.page()) + "-" +
        repr(loc.position().x) + "-" +
        repr(loc.position().y) + "-" +
        str(todo-state.at(loc).len()))
}

#let hide-todos() = state("grape-suite-list-todos").update(false)

#let todo(..content) = context {
    if state("grape-suite-list-todos", true).at(here()) == false {
        return
    }

    let label-name = make-todo-label(here())

    highlight(fill: magenta.lighten(90%), text(fill: magenta,
        if content.pos().len() > 0 {
            strong[To do: ] + content.pos().join[]
        } else {
            strong[To do]
        })
    )
    [#label(label-name)]

    todo-state.update(t => {
        t.push((page: counter(page).at(here()).first(), label: label-name, content: content.pos().join[]))
        t
    })
}

#let list-todos() = context {
    let todo-list = todo-state.final()

    show link: text.with(fill: magenta)
    set text(fill: magenta)
    if type(todo-list) == array and todo-list.len() > 0 {
        strong([To do:])

        list(tight: false, ..todo-list.map(e =>
            strong[p. #e.page] +
            if e.content != none { [: #e.content] }))
    }
}
