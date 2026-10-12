#import ".zettypst/lib.typ": evaluate, load, publish

#let project = load()
#assert.eq(project.issues, ())
#let result = evaluate(project)
#assert.eq(result.execution.output.status, "success", message: repr(
  result.execution.output,
))
#publish(project, result.flow, result.execution, editor: false)

// Use the target heading's title for ordinary references.
#show ref: it => {
  if it.element != none and it.element.func() == heading {
    link(it.target)[[#it.element.body]]
  } else {
    it
  }
}

#for note in project.notes {
  note.body
}
