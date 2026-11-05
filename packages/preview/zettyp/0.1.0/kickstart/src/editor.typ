#import "note.typ": reference-color
#import "content.typ": display-value
#import "evaluation.typ": evaluation-issues

// Navigation belongs to the initial graph, independently of policy success.
#let navigation(project) = {
  let edges = project
    .state
    .graph
    .edges
    .pairs()
    .filter(((id, edge)) => (
      project.state.values.edges.at(id).relation == reference-color
    ))
  let incoming = (:)
  for (edge-id, edge) in edges {
    let occurrences = incoming.at(edge.target, default: ())
    occurrences.push(project.origins.edges.at(edge-id))
    incoming.insert(edge.target, occurrences)
  }
  let nodes = (:)
  for id in project.state.graph.nodes {
    nodes.insert(id, (
      id: id,
      origin: project.origins.nodes.at(id),
      definition: project.origins.nodes.at(id),
      references: incoming.at(id, default: ()),
    ))
  }
  // A reference inside a heading takes priority over the heading's range.
  (
    edges.map(((id, edge)) => (
      nodes.at(edge.target) + (origin: project.origins.edges.at(id))
    ))
      + project.state.graph.nodes.map(id => nodes.at(id))
  )
}

#let announce-editor(
  lsp,
  project,
  execution,
  final,
  project-notes: none,
  hover: none,
) = {
  let targets = navigation(project)
  for target in targets {
    lsp.announce(lsp.effect-kinds.definition, lsp.definition(
      applies-to: target.origin,
      target: target.definition,
    ))
    lsp.announce(lsp.effect-kinds.references, lsp.references(
      applies-to: target.origin,
      targets: target.references,
      declarations: (target.definition,),
    ))
  }
  if final != none {
    let notes = project-notes(project, final)
      .map(note => (note.id, note))
      .to-dict()
    for target in targets {
      let note = notes.at(target.id)
      lsp.announce(lsp.effect-kinds.hover, lsp.hover(
        applies-to: target.origin,
        contents: hover(note),
      ))
    }
  }
  // Clear every observed source document, including imported reference content.
  let origins = (
    project.origins.nodes.values()
      + project.origins.edges.values()
      + project.unclassified.map(it => it.origin)
  )
  for origin in origins {
    lsp.announce(
      lsp.effect-kinds.publish-diagnostics,
      lsp.publish-diagnostics(document: origin),
    )
  }
  for issue in evaluation-issues(execution) {
    for origin in issue.origins {
      lsp.announce(
        lsp.effect-kinds.publish-diagnostics,
        lsp.publish-diagnostics(
          document: origin,
          diagnostics: (
            lsp.diagnostic(
              origin: origin,
              message: issue.message,
              code: issue.code,
              severity: lsp.severity.error,
              source: "zettypst",
            ),
          ),
        ),
      )
    }
  }
}

#let hover(note) = (
  kind: "plaintext",
  value: display-value(note.title)
    + "\n@"
    + note.id
    + "\n\n"
    + note
      .metadata
      .keys()
      .sorted()
      .map(key => key + ": " + display-value(note.metadata.at(key)))
      .join("\n"),
)
