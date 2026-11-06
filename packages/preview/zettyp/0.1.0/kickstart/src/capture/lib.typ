/// Capture plans and default notebook entrypoints.
#import "plan.typ": merge-bibliography, plan, verify
#import "defaults.typ" as defaults
#import "../host.typ" as notebook-host
#import "../../../host/lib.typ" as host
#import "../../../core/eval.typ" as eval

#let capture(
  project-lib,
  read-file: none,
  settings: none,
  allocate-id: notebook-host.allocate-id,
  manifest: ".zettypst/source.toml",
) = {
  let state = notebook-host.snapshot(project-lib)
  let register-note(path) = {
    let before = read-file(manifest)
    let paths = toml(bytes(before)).paths
    (
      host.replace(manifest, before, notebook-host.manifest-text(
        before,
        paths + (path,),
      )),
    )
  }
  eval.announce(<host.plan>, plan(
    host.request(),
    nodes: notebook-host.notes(state, project-notes: project-lib.project-notes),
    settings: settings,
    read-file: read-file,
    allocate-id: value => str(allocate-id(
      notebook-host.now(value),
      state.project.state.graph.nodes,
    )),
    note-path: id => "note/" + id + ".typ",
    register-note: register-note,
    verification: intent => notebook-host.verification(
      "capture-verify",
      intent,
      state.errors,
    ),
  ))
}

#let verify-capture(project-lib, read-file: none) = {
  let intent = host.request()
  let state = notebook-host.snapshot(project-lib)
  notebook-host.check-errors(state, intent.baseline)
  let candidates = notebook-host
    .notes(state, project-notes: project-lib.project-notes)
    .map(note => (
      note + (title: project-lib.display-value(note.title))
    ))
  let note = verify(intent, nodes: candidates, read-file: read-file)
  notebook-host.announce-node(note, display-value: project-lib.display-value)
}
