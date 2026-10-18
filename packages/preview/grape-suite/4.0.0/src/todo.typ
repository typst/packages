#import "colors.typ": get-colors
#let todo-state = state("grape-suite-todos", ())

#let make-todo-label(loc) = {
    return (
        "todo-label-"
            + str(loc.page())
            + "-"
            + repr(loc.position().x)
            + "-"
            + repr(loc.position().y)
            + "-"
            + str(todo-state.at(loc).len())
    )
}

#let hide-todos() = state("grape-suite-list-todos").update(false)

#let todo(..content) = context {
    let c = get-colors()
    metadata(("type": "todo", content: content.pos().join[]))

    highlight(fill: c.highlight-light, text(fill: c.highlight, if content
        .pos()
        .len()
        > 0 {
        strong[To do: ] + content.pos().join[]
    } else {
        strong[To do]
    }))
}

#let list-todos() = context {
    let c = get-colors()
    let todo-list = query(metadata).filter(e => if type(e.value) == dictionary
        and "type" in e.value { e.value.type == "todo" } else { false })

    show link: text.with(fill: c.highlight)
    set text(fill: c.highlight)
    if type(todo-list) == array and todo-list.len() > 0 {
        strong([To do:])

        list(tight: false, ..todo-list.map(e => link(e.location())[
            #strong[p. #e.location().page()]
            #if e.value.content != none { [: #e.value.content] }]))
    }
}
