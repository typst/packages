#let format-task(
  prefix,
  nbr,
  separator,
  include-subtasks,
  it,
  dict,
) = {
  let sep = if type(separator) == array {
    assert.ne(separator.len(), 0, message: "If an array, `task-separator` must have at least one element.")
    separator.at(it.level - 1, default: separator.at(-1))
  } else {
    separator
  }

  let p = if prefix == auto {
    dict.task + " "
  } else if type(prefix) == array {
    assert.ne(prefix.len(), 0, message: "If an array, `task-prefix` must have at least one element.")
    context {
      let c = counter("tuda-task-prefix").get().at(0)
      prefix.at(calc.rem(c, prefix.len()))
    }
  } else {
    prefix
  }

  if include-subtasks or it.level == 1 {
    [#p#nbr#sep]
  } else {
    [#nbr#sep]
  }
}
