#import "@preview/zettyp-core:0.1.0": (
  eval, graph, knowledge, observation, policy, vocabulary,
)
#import "@preview/zettyp-lsp:0.1.0" as lsp

// Persist this label in source; used contains the assembled string identities.
#let allocate-id(now, used) = {
  assert(type(now) == datetime and now.year() != none and now.hour() != none)
  assert(type(used) == array and used.all(id => type(id) == str))
  let base = now.display("[year][month][day]T[hour][minute][second]")
  let candidate = base
  let suffix = 0
  while candidate in used {
    suffix += 1
    candidate = base + "-" + str(suffix)
  }
  label(candidate)
}

#let lifecycle = vocabulary.register(
  "lifecycle",
  active: "active",
  legacy: "legacy",
  archived: "archived",
)
#let colors = vocabulary.register(
  "relation",
  ref: <zk.ref>,
  replaces: <zk.replaces>,
  evolves-from: <zk.evolves-from>,
)
#let emit = metadata

#let zk_metadata(
  aliases: (),
  abstract: "",
  tags: (),
  relation: lifecycle.active,
) = {
  assert(type(aliases) == array and aliases.all(it => type(it) == str))
  assert(type(abstract) == str and type(tags) == array)
  assert(relation in lifecycle.values(), message: "unknown lifecycle state")
  (
    value: (relation: relation),
    data: (aliases: aliases, abstract: abstract, tags: tags),
  )
}

// Shallow: declarations through sequences/styles. Deep: rendered bodies too.
// References and metadata are leaves: never walk supplements or payloads.
#let elements(body, deep: false) = {
  if type(body) == array {
    return body.map(it => elements(it, deep: deep)).flatten()
  }
  if type(body) != content { return () }
  if body.func() in (ref, emit) { return (body,) }
  let fields = body.fields()
  let keys = if deep { ("children", "child", "body") } else if (
    "styles" in fields
  ) {
    ("children", "child")
  } else { ("children",) }
  let key = keys.find(key => key in fields)
  if key == none { (body,) } else { elements(fields.at(key), deep: deep) }
}

#let declarations(body, protocol, deep: false) = (
  elements(body, deep: deep)
    .filter(it => (
      it.func() == emit
        and type(it.value) == dictionary
        and it.value.at("protocol", default: none) == protocol
        and it.value.at("version", default: none) == 1
    ))
    .map(it => it.value)
)
#let references(body) = elements(body, deep: true).filter(it => (
  it.func() == ref
))

#let colored-edge(color, body) = {
  assert(color in (colors.replaces, colors.evolves-from))
  emit((protocol: "zettyp.dependency", version: 1, color: color, body: body))
  body
}
#let replaces = colored-edge.with(colors.replaces)
#let evolves-from = colored-edge.with(colors.evolves-from)

#let read-note(body, metadata: zk_metadata()) = {
  assert(type(body) == content, message: "note body must be content")
  let roots = elements(body).filter(it => {
    if it.func() != heading { return false }
    let fields = it.fields()
    let level = fields.at("level", default: auto)
    if level == auto { level = fields.at("depth", default: none) }
    level == 1
  })
  assert.eq(
    roots.len(),
    1,
    message: "note requires exactly one level-one root heading",
  )
  let root = roots.first()
  let identity = root.fields().at("label", default: none)
  assert(
    type(identity) == label,
    message: "note root heading requires a persistent label",
  )
  let id = str(identity)
  let outgoing = (
    references(body).map(origin => (origin: origin, color: colors.ref))
      + declarations(body, "zettyp.dependency", deep: true)
        .map(marker => (
          references(marker.body).map(origin => (
            origin: origin,
            color: marker.color,
          ))
        ))
        .flatten()
  )
  knowledge.local(
    id,
    value: metadata.value,
    data: metadata.data + (title: root.body),
    origin: root,
    references: outgoing
      .enumerate()
      .map(((index, item)) => knowledge.reference(
        str(id.len()) + ":" + id + "/ref/" + str(index),
        target: str(item.origin.target),
        value: (relation: item.color),
        origin: item.origin,
      )),
  )
}
#let note = knowledge.raw-to-local(read-note)

#let zettel(metadata: zk_metadata, body) = {
  assert(
    type(metadata) == function,
    message: "zettel metadata must be a configured function",
  )
  emit((
    protocol: "zettyp.note",
    version: 1,
    local: (note.observe)(body, metadata: metadata()),
    body: body,
  ))
}
#let observations(body) = declarations(body, "zettyp.note")

// Loading is explicit: importing this configuration never reads the manifest.
#let load(manifest: "/.zettypst/source.toml") = {
  let paths = toml(manifest).at("paths", default: none)
  assert(
    type(paths) == array and paths.all(path => type(path) == str),
    message: "source manifest requires an array of paths",
  )
  assert.eq(paths.dedup().len(), paths.len(), message: "duplicate source path")
  assert(
    paths.all(path => (
      not path.contains("\\")
        and path.split("/").all(part => part not in ("", ".", ".."))
    )),
    message: "source paths must be project-relative with forward slashes",
  )
  let notes = paths
    .map(path => {
      let records = observations(include ("/" + path))
      assert(
        records.len() > 0,
        message: "source has no zettel declaration: " + path,
      )
      records.map(record => record + (path: path))
    })
    .flatten()
  knowledge.assemble(notes.map(note => note.local)) + (notes: notes)
}

// Group only the dependency view; original edge occurrences remain intact.
#let dependency-groups(state) = {
  let ids = state
    .graph
    .edges
    .keys()
    .filter(id => (
      state.values.edges.at(id).relation
        in (colors.replaces, colors.evolves-from)
    ))
  ids
    .map(id => state.graph.edges.at(id))
    .dedup()
    .map(edge => (
      edge + (occurrences: ids.filter(id => state.graph.edges.at(id) == edge))
    ))
}

#let reachable(edges, start, target) = {
  let pending = (start,)
  let visited = ()
  while pending.len() > 0 {
    let id = pending.pop()
    if id == target { return true }
    if id in visited { continue }
    visited.push(id)
    pending += edges.filter(edge => edge.source == id).map(edge => edge.target)
  }
  false
}

#let relation-issues(state, origins) = {
  let groups = dependency-groups(state)
  groups
    .map(group => {
      let kinds = group
        .occurrences
        .map(id => state.values.edges.at(id).relation)
        .dedup()
      let endpoints = repr(group.source) + " -> " + repr(group.target)
      let problems = (
        (
          if kinds.len() > 1 {
            (
              (
                code: <zk.relation.color-conflict>,
                message: "conflicting dependency colors: " + endpoints,
              ),
            )
          } else { () }
        )
          + (
            // Only edges on a cycle are diagnosed, not edges entering or leaving it.
            if reachable(groups, group.target, group.source) {
              (
                (
                  code: <zk.relation.cycle>,
                  message: "dependency graph contains a cycle through "
                    + endpoints,
                ),
              )
            } else { () }
          )
      )
      problems.map(issue => (
        issue
          + (
            occurrences: group.occurrences,
            origins: group.occurrences.map(id => origins.edges.at(id)),
          )
      ))
    })
    .flatten()
}

#let successors(state, id) = {
  let incoming = graph.incoming(state.graph, id)
  let sources(color) = incoming
    .filter(edge => state.values.edges.at(edge).relation == color)
    .map(edge => state.graph.edges.at(edge).source)
    .dedup()
  (
    replaced-by: sources(colors.replaces),
    evolved-into: sources(colors.evolves-from),
  )
}

#let derive-lifecycle(state) = graph.assign(state, nodes: (
  state
    .values
    .nodes
    .pairs()
    .fold((:), (values, pair) => {
      let (id, value) = pair
      let next = successors(state, id)
      let relation = if next.replaced-by.len() > 0 {
        lifecycle.archived
      } else if next.evolved-into.len() > 0 { lifecycle.legacy } else {
        value.relation
      }
      values.insert(id, value + (relation: relation))
      values
    })
))

// Each evaluation starts from the original locals, never a derived snapshot.
#let evaluate(project) = {
  assert(
    project.state != none,
    message: "resolve knowledge assembly issues before evaluation",
  )
  let lifecycle-rule = policy.function(
    "lifecycle",
    derive-lifecycle,
    check: state => relation-issues(state, project.origins),
  )
  let assembled = policy.assemble(
    ((lifecycle-rule.invoke)(inputs: ("initial",), output: "semantic"),),
    inputs: ("initial",),
    output: "semantic",
  )
  assert.eq(assembled.issues, ())
  (
    flow: assembled.flow,
    execution: policy.evaluate(
      assembled.flow,
      topology: project.state.graph,
      inputs: (project.state,),
    ),
  )
}

// Navigation belongs to the initial graph, independently of policy success.
#let navigation(project) = {
  let edges = project
    .state
    .graph
    .edges
    .pairs()
    .filter(((id, edge)) => (
      project.state.values.edges.at(id).relation == colors.ref
    ))
  let nodes = project.state.graph.nodes.map(id => (
    id: id,
    origin: project.origins.nodes.at(id),
    definition: project.origins.nodes.at(id),
    references: edges
      .filter(pair => pair.at(1).target == id)
      .map(pair => project.origins.edges.at(pair.at(0))),
  ))
  // A reference inside a heading takes priority over the heading's range.
  (
    edges.map(((id, edge)) => (
      nodes.find(node => node.id == edge.target)
        + (origin: project.origins.edges.at(id))
    ))
      + nodes
  )
}

#let display-value(value) = {
  if type(value) == content {
    elements(value, deep: true)
      .map(it => {
        if repr(it.func()) == "space" { " " } else if (
          it.func() in (linebreak, parbreak)
        ) { "\n" } else { it.fields().at("text", default: repr(it)) }
      })
      .join()
  } else if type(value) == array {
    value.map(display-value).join(", ")
  } else if (
    type(value) == dictionary
      and value in (lifecycle.values() + colors.values())
  ) {
    display-value(value.value)
  } else if type(value) in (str, label) { str(value) } else { repr(value) }
}

#let project-notes(project, state) = project.notes.map(note => {
  let id = note.local.node.id
  let data = project.data.at(id)
  let title = data.remove("title")
  (
    id: id,
    title: title,
    path: note.path,
    metadata: data + state.values.nodes.at(id) + successors(state, id),
    origin: project.origins.nodes.at(id),
  )
})

#let final-observation(flow, execution) = {
  let prepared = observation.prepare(flow, (
    observation.bind("final", observer: state => state, at: flow.output),
  ))
  assert.eq(prepared.issues, ())
  let verified = observation.verify(prepared.plan)
  assert.eq(verified.issues, ())
  observation.query(observation.collect(verified.plan, execution), "final")
}

#let announce-editor(project, execution, final) = {
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
  if final.status == "available" {
    let notes = project-notes(project, final.value)
    for target in targets {
      let note = notes.find(note => note.id == target.id)
      lsp.announce(lsp.effect-kinds.hover, lsp.hover(
        applies-to: target.origin,
        contents: (
          kind: "plaintext",
          value: display-value(note.title)
            + "\n@"
            + note.id
            + "\n\n"
            + note
              .metadata
              .keys()
              .sorted()
              .map(key => (
                key + ": " + display-value(note.metadata.at(key))
              ))
              .join("\n"),
        ),
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
  let issues = execution
    .results
    .values()
    .filter(it => it.status == "failure")
    .map(it => it.issues)
    .flatten()
  for issue in issues {
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

#let announce-project(project, final) = {
  if final.status == "available" {
    eval.announce(
      <zk.notes>,
      project-notes(project, final.value).map(note => (
        note + (origin: eval.inspect(note.origin))
      )),
    )
    eval.announce(<zk.graph>, (
      state: final.value,
      origins: (
        nodes: project
          .origins
          .nodes
          .pairs()
          .fold((:), (all, pair) => {
            all.insert(pair.at(0), eval.inspect(pair.at(1)))
            all
          }),
        edges: project
          .origins
          .edges
          .pairs()
          .fold((:), (all, pair) => {
            all.insert(pair.at(0), eval.inspect(pair.at(1)))
            all
          }),
      ),
    ))
  }
  eval.announce(<zk.references.unclassified>, project.unclassified.map(item => (
    item + (origin: eval.inspect(item.origin))
  )))
}

#let publish(project, flow, execution, editor: true, export: true) = {
  assert(
    project.state != none,
    message: "resolve knowledge assembly issues before publication",
  )
  let final = final-observation(flow, execution)
  if editor { announce-editor(project, execution, final) }
  if export { announce-project(project, final) }
}
