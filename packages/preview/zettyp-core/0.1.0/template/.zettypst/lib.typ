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

// The body without its root heading, found as read-note finds it: through
// sequences and styles only. Without the note's own label, it can be repeated
// (in a preview, an expansion) without duplicating the label every link targets.
#let without-root(body, id) = {
  if type(body) != content { return body }
  let fields = body.fields()
  if "children" in fields {
    return fields
      .children
      .filter(it => {
        not (
          it.func() == heading and it.at("label", default: none) == label(id)
        )
      })
      .map(it => without-root(it, id))
      .join()
  }
  if "child" in fields and "styles" in fields {
    return (body.func())(without-root(fields.child, id), fields.styles)
  }
  if body.func() == heading and body.at("label", default: none) == label(id) {
    return []
  }
  body
}

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
    let notes = (:)
    for note in project-notes(project, final.value) {
      notes.insert(note.id, note)
    }
    for target in targets {
      let note = notes.at(target.id)
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

// ---- HTML publication (bundle export) ----------------------------------------
// A route maps a note to its document path; none leaves it unpublished. Notes
// sharing a route share one document. Typst resolves every href between
// documents, so routes are the only addressing rule.
#let route(note) = note.id + "/index.html"

// A card lays out one note: id, title, body (with its root heading), main (the
// body without it), metadata, backlinks and links. Its links are ordinary refs
// to note labels.
#let card(note) = {
  note.body
  if note.backlinks.len() > 0 [
    Backlinks: #note.backlinks.map(it => ref(label(it.id))).join[, ]
  ]
}

// The note whose card is being rendered: the source of the links inside it.
#let rendering = state("zettypst.rendering", none)

#let export-html(project, result, route: route, card: card) = {
  let final = final-observation(result.flow, result.execution)
  assert.eq(final.status, "available", message: "semantic evaluation failed")
  let state = final.value
  let bodies = project.notes.map(it => (it.local.node.id, it.body)).to-dict()
  let notes = (:)
  for note in project-notes(project, state) {
    let path = route(note)
    assert(
      path == none
        or path.ends-with(".html")
          and path.split("/").all(part => part not in ("", ".", "..")),
      message: "route must be a relative .html path or none: " + note.id,
    )
    notes.insert(note.id, note + (route: path))
  }
  // Endpoints of every relation colour, deduplicated, published and non-self.
  let neighbours(id, from, to) = state
    .graph
    .edges
    .values()
    .filter(edge => edge.at(from) == id and edge.at(to) != id)
    .map(edge => edge.at(to))
    .dedup()
    .map(it => notes.at(it))
    .filter(it => it.route != none)

  let published = notes.values().filter(it => it.route != none)
  let documents = (:)
  for note in published {
    let full = (
      note
        + (
          body: bodies.at(note.id),
          main: without-root(bodies.at(note.id), note.id),
          backlinks: neighbours(note.id, "target", "source"),
          links: neighbours(note.id, "source", "target"),
        )
    )
    documents.insert(
      note.route,
      documents.at(note.route, default: ()) + (full,),
    )
  }

  // A reference to a note renders its edge: the link names both endpoints, so
  // the site infers neither from URLs nor from where the link was moved to.
  // Other references stay native.
  show ref: it => {
    let target = notes.at(str(it.target), default: none)
    if target == none { return it }
    let body = if it.supplement in (auto, none, []) { target.title } else {
      it.supplement
    }
    if target.route == none { return html.span(class: "zk-unpublished", body) }
    context html.elem(
      "span",
      attrs: (
        class: "zk-link",
        "data-zk-source": rendering.get(),
        "data-zk-target": target.id,
      ),
      link(it.target, body),
    )
  }
  for (path, group) in documents {
    document(
      path,
      title: display-value(group.first().title),
      group
        .map(note => {
          rendering.update(note.id)
          html.elem("section", attrs: ("data-zk-node": note.id), card(note))
        })
        .join(),
    )
  }
  // Titles for search and stack chrome; the page HTML carries everything else.
  asset("zettypst.json", json.encode(published.map(note => (
    id: note.id,
    route: note.route,
    title: display-value(note.title),
  ))))
}
