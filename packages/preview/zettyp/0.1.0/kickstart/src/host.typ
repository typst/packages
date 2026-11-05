/// Default notebook host adapters
#import "../../core/eval.typ" as eval
#import "../../host/lib.typ" as host

#let snapshot(project-lib) = {
  let project = project-lib.load()
  assert.eq(project.issues, (), message: "knowledge assembly failed")
  let result = project-lib.evaluate(project)
  let final = project-lib.final-observation(result.program, result.execution)
  let errors = project-lib
    .evaluation-issues(result.execution)
    .map(it => repr((
      code: str(it.code),
      message: it.message,
      occurrences: it.occurrences,
    )))
  (project: project, final: final, errors: errors)
}
#let check-errors(state, baseline) = {
  // Multiset comparison preserves repeated diagnostics without source-offset drift.
  let remaining = baseline
  for error in state.errors {
    let index = remaining.position(it => it == error)
    assert(index != none, message: "migration introduced an error: " + error)
    let _ = remaining.remove(index)
  }
}
#let announce-node(note, display-value: none) = eval.announce(
  <host.node>,
  host.node(
    note.id,
    display-value(note.title),
    note.origin,
    note.metadata,
  ),
)
#let notes(state, project-notes: none) = {
  assert(state.final != none, message: "semantic evaluation failed")
  project-notes(state.project, state.final)
}
// Rewrites only the paths array, preserving comments and other settings.
#let manifest-text(before, paths) = {
  let assignment = regex("(?m)^paths\\s*=\\s*\\[[^\\]]*\\]")
  assert.eq(
    before.matches(assignment).len(),
    1,
    message: "manifest needs exactly one paths array",
  )
  before.replace(
    assignment,
    "paths = [" + paths.map(json.encode).join(", ") + "]",
  )
}
#let verification(entry, intent, baseline) = (
  entry: ".zettypst/host/" + entry + ".typ",
  inputs: ("host.request": json.encode(intent + (baseline: baseline))),
)
#let now(value) = {
  assert(type(value) == dictionary)
  datetime(
    year: value.year,
    month: value.month,
    day: value.day,
    hour: value.hour,
    minute: value.minute,
    second: value.second,
  )
}


/// Plan a new default notebook note; file reads remain project-owned.
#let new(
  req,
  state,
  allocate-id: none,
  read-file: none,
  manifest: ".zettypst/source.toml",
) = {
  assert(
    req.keys().all(key => key in ("title", "now")),
    message: "unknown new request field",
  )
  assert(
    type(req.title) == str and req.title.trim() != "",
    message: "title is required",
  )
  let id = str(allocate-id(now(req.now), state.project.state.graph.nodes))
  let path = "note/" + id + ".typ"
  let before = read-file(manifest)
  let paths = toml(bytes(before)).paths
  assert(path not in paths, message: "new path is already registered")
  // Plain text is inserted as a string expression, never as executable markup.
  let content = (
    "#import \"../.zettypst/lib.typ\": *\n#show: zettel\n\n= #text("
      + repr(req.title)
      + ") <"
      + id
      + ">\n"
  )
  host.plan(
    (
      host.create(path, content),
      host.replace(manifest, before, manifest-text(before, paths + (path,))),
    ),
    verification(
      "new-verify",
      (id: id, path: path, title: req.title),
      state.errors,
    ),
  )
}

/// Verify the new note against the evaluated post-state.
#let verify-new(intent, state, project-notes: none, display-value: none) = {
  check-errors(state, intent.baseline)
  let matches = notes(state, project-notes: project-notes).filter(note => (
    note.id == intent.id
  ))
  assert.eq(matches.len(), 1, message: "new node must exist exactly once")
  let note = matches.first()
  assert.eq(note.path, intent.path)
  assert.eq(display-value(note.title), intent.title)
  note
}

/// Plan deletion of one default notebook note.
#let delete(
  req,
  state,
  read-file: none,
  manifest: ".zettypst/source.toml",
) = {
  assert(
    req.keys().all(key => key in ("id", "force", "now")),
    message: "unknown delete request field",
  )
  assert(type(req.id) == str)
  let force = req.at("force", default: false)
  assert(type(force) == bool)
  let matches = state.project.notes.filter(note => note.local.node.id == req.id)
  assert.eq(matches.len(), 1, message: "node does not exist")
  let note = matches.first()
  assert.eq(
    state.project.notes.filter(it => it.path == note.path).len(),
    1,
    message: "delete requires a source containing exactly one node",
  )
  let incoming = state
    .project
    .state
    .graph
    .edges
    .values()
    .filter(
      edge => edge.target == req.id and edge.source != req.id,
    )
  assert(
    force or incoming.len() == 0,
    message: "node has incoming edges; force is required",
  )
  let before = read-file(manifest)
  let paths = toml(bytes(before)).paths
  host.plan(
    (
      host.delete(note.path, read-file(note.path)),
      host.replace(manifest, before, manifest-text(before, paths.filter(
        path => (
          path != note.path
        ),
      ))),
    ),
    verification("delete-verify", (id: req.id, path: note.path), state.errors),
  )
}

/// Verify deletion against the evaluated post-state and source manifest.
#let verify-delete(
  intent,
  state,
  read-file: none,
  manifest: ".zettypst/source.toml",
) = {
  check-errors(state, intent.baseline)
  assert(
    intent.id not in state.project.state.graph.nodes,
    message: "deleted node remains",
  )
  assert(
    intent.path not in toml(bytes(read-file(manifest))).paths,
    message: "deleted source remains registered",
  )
}

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
