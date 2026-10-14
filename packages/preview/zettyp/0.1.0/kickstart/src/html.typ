#import "content.typ": display-value, without-root
#import "card.typ": card, frontmatter

#import "../../site/lib.typ" as site

#let export-html(
  project,
  result,
  final-observation: none,
  project-notes: none,
  route: none,
  card: none,
) = {
  let state = final-observation(result.program, result.execution)
  assert(state != none, message: "semantic evaluation failed")
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
    if target.route == none { return site.unpublished(body) }
    site.node-link(target.id, link(it.target, body))
  }
  for (path, group) in documents {
    document(
      path,
      title: display-value(group.first().title),
      group.map(note => site.node(note.id, card(note))).join(),
    )
  }
  // Titles for search and stack chrome; the page HTML carries everything else.
  site.publish-index(published.map(note => (
    id: note.id,
    route: note.route,
    title: display-value(note.title),
  )))
}
