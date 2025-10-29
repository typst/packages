#let tally(body, color: yellow) = {
  let todo-list = state("todo-list", ())
  let reg = regex("TODO:(.+)")
  show reg: it => context {
    let todo = it.text.match(reg).captures.at(0).trim()
    let here = here()
    todo-list.update(lst => lst + ((todo, here),))
    highlight(fill: color)[TODO: #todo]
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
