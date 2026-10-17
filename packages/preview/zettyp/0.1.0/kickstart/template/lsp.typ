// Publish editor semantics without rendering note bodies.
#import ".zettypst/lib.typ": evaluate, load, publish

#let project = load()
#assert.eq(project.issues, ())
#let result = evaluate(project)
#publish(project, result.program, result.execution, export: false)
