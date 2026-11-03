#let _todo-counter = counter("todo-counter")
#let _todo-storage = state("todos", ())

#let _gen-assignee-str(assignee) = {
  if assignee == none {
    return none
  }

  let names-array = if type(assignee) == str {
    (assignee,)
  } else {
    assignee
  }

  names-array.map(n => underline(strong("@" + n))).join(", ")
}

/// Create prefix the body with red "TODO: ".
///
/// ```example
/// #todo[Write this]
/// ```
///
/// -> content
#let todo(
  /// an optional assignee, shown after TODO in braces
  /// -> str
  assignee: none,
  /// the content to show
  /// -> content
  body,
) = {
  _todo-counter.step()

  context {
    let label = label("todo-" + _todo-counter.display())
    let info = (
      body: body,
      assignee: assignee,
      id: _todo-counter.get().first(),
      target: label,
    )

    _todo-storage.update(old => old + (info,))

    if assignee == none {
      [#text(red)[*TODO*: #body] #label]
    } else {
      let assignee-str = _gen-assignee-str(assignee)

      if body != [] {
        [#text(red)[*TODO (#assignee-str)*: #body] #label]
      } else {
        [#text(red)[*TODO (#assignee-str)*] #label]
      }
    }
  }
}

/// Show all TODOs in the document.
///
/// ```example
/// #list-todos()
/// ```
///
/// -> content
#let list-todos(
  /// show only TODOs assigned to this name; has no effect when exclude-unassigned is true
  /// -> str
  show-only: none,
  /// exclude TODOs without an assignee
  /// -> bool
  exclude-unassigned: false,
) = {
  context {
    let todos = _todo-storage.final()
    if todos.len() == 0 { return [] }

    let filtered-todos = todos.filter(item => {
      if exclude-unassigned {
        item.assignee == none
      } else if show-only != none {
        if type(item.assignee) == str {
          item.assignee == show-only
        } else if type(item.assignee) == array {
          show-only in item.assignee
        } else {
          false
        }
      } else {
        true
      }
    })

    if filtered-todos.len() > 0 {
      list(..filtered-todos.map(item => {
        let prefix = text(red)[*TODO-#item.id*]
        let assignee-str = _gen-assignee-str(item.assignee)
        if assignee-str != none {
          prefix = [#prefix (#assignee_str)]
        }

        let tag = link(item.target)[#text(red)[#prefix]]

        list.item([#tag: #item.body])
      }))
    }
  }
}
