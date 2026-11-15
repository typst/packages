#import ".zettypst/lib.typ": evaluate, final-observation, load, publish

#let project = load()
#assert.eq(project.issues, ())
#let result = evaluate(project)
#assert(
  final-observation(result.program, result.execution) != none,
  message: "semantic evaluation failed",
)
#publish(project, result.program, result.execution, editor: false)

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
