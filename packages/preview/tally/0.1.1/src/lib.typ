#let tally(body, color: yellow) = {
  let todo-list = state("todo-list", ())
  let reg = regex("TODO:.+")
  show reg: it => context {
    let todos = it
      .text
      .matches(regex("TODO:"))
      .map(t => it.text.slice(t.end).trim(reg).trim())
    todo-list.update(todo-list.get() + todos.map(it => (it, here())))
    todos.map(it => highlight(fill: color)[TODO: #it ]).join()
  }

  body
}

#let todo-list = context {
  let todo-list = state("todo-list", ())
  if todo-list.final().len() > 0 {
    heading(outlined: false, [Todo])
  }
  list(
    ..todo-list
      .final()
      .map(it => link(
        it.last(),
        [#{
            let headings = query(selector(heading).before(it.last()))

            if headings.len() > 1 {
              [*#headings.last().body*:]
            }
          } #it.first()],
      )),
  )
}
