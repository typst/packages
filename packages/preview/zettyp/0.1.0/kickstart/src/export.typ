#import "../../core/eval.typ" as eval

#let announce-project(project, final, project-notes: none) = {
  if final != none {
    eval.announce(
      <zk.notes>,
      project-notes(project, final).map(note => (
        note + (origin: eval.inspect(note.origin))
      )),
    )
    eval.announce(<zk.graph>, (
      state: final,
      origins: (
        nodes: project
          .origins
          .nodes
          .pairs()
          .map(((id, origin)) => (id, eval.inspect(origin)))
          .to-dict(),
        edges: project
          .origins
          .edges
          .pairs()
          .map(((id, origin)) => (id, eval.inspect(origin)))
          .to-dict(),
      ),
    ))
  }
  eval.announce(<zk.references.unclassified>, project.unclassified.map(item => (
    item + (origin: eval.inspect(item.origin))
  )))
}

#let publish(
  project,
  program,
  execution,
  final-observation: none,
  editor-output: none,
  project-output: none,
  editor: true,
  export: true,
) = {
  assert(
    project.state != none,
    message: "resolve knowledge assembly issues before publication",
  )
  let final = final-observation(program, execution)
  if editor { editor-output(project, execution, final) }
  if export { project-output(project, final) }
}
