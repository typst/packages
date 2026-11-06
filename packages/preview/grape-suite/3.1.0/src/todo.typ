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

#let todo(..content) = {
    metadata(("type": "todo", content: content.pos().join[]))

    highlight(fill: magenta.lighten(90%), text(fill: magenta,
        if content.pos().len() > 0 {
            strong[To do: ] + content.pos().join[]
        } else {
            strong[To do]
        })
    )
}

#let list-todos() = context {
    let todo-list = query(metadata).filter(e => if type(e.value) == dictionary and "type" in e.value { e.value.type == "todo" } else { false })

    show link: text.with(fill: magenta)
    set text(fill: magenta)
    if type(todo-list) == array and todo-list.len() > 0 {
        strong([To do:])

        list(tight: false, ..todo-list.map(e =>
            strong[p. #e.location().page()] +
            if e.value.content != none { [: #e.value.content] }))
    }
}