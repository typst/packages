// Projects — name (optionally linked), optional `entity` subtitle,
// italic description, date range, bulleted highlights, `roles` pills,
// keyword pills. JSON Resume's `projects[]` schema. When at least one
// entry carries a `type`, entries cluster under `====` subheadings
// (mirroring `publications[].type`); an all-untyped list renders flat.
// Entries without a `name` are skipped to avoid an orphan heading.

#import "../internal/state.typ": _body_colour
#import "../internal/text.typ": _present, styled-link
#import "../internal/primitives.typ": term, _group_by, _join_with_dividers, _tag_row
#import "../internal/dates.typ": _format_date_range

// One project entry block — shared by the flat and grouped layouts.
#let _render_project(project, labels, prefs) = block(breakable: false, {
  let url = project.at("url", default: none)
  [=== #styled-link(project.name, dest: url)]
  // Small body-colour subtitle under the title — the company / client
  // the project belonged to, distinct from the project name. Mirrors
  // `publications[].publisher`.
  let entity = project.at("entity", default: none)
  if _present(entity) {
    block(below: 0.5em, text(0.85em, fill: _body_colour, entity))
  }
  let description = project.at("description", default: none)
  if _present(description) {
    // Softer than `name()` (which is bold + accent) so the description
    // doesn't compete visually with a linked title. Wrapped in a block
    // so the gap to the roles / term row below matches the
    // institution-line → term spacing in `_experience` / `_education`;
    // using a bare `linebreak()` here leaves no paragraph spacing.
    block(below: 0.6em, emph(description))
  }
  // `roles` — the person's role(s) on the project — render as a row of
  // darker (label-variant) pills just below the description and above
  // the date row, set apart from the lighter keyword pills at the foot
  // of the entry. The block puts them on their own line.
  let roles = project.at("roles", default: ())
  if roles.len() > 0 { block(below: 0.4em, _tag_row(roles, label: true)) }
  term(_format_date_range(project, prefs, labels))
  for bullet in project.at("highlights", default: ()) [- #bullet]
  _tag_row(project.at("keywords", default: ()))
})

#let _projects(entries, labels, prefs) = {
  let valid = entries.filter(p => _present(p.at("name", default: none)))
  if valid.len() == 0 { return }
  [== #labels.projects]

  // `type` is an optional JSON Resume field. Cluster by it only when at
  // least one entry carries a usable (non-empty string) value —
  // otherwise render flat, so the common (untyped) case stays free of
  // redundant subheadings and matches the pre-grouping output. Untyped
  // entries in a mixed list pool under `labels.otherProjects`.
  let is-typed(p) = type(p.at("type", default: none)) == str and _present(p.at("type", default: none))
  if not valid.any(is-typed) {
    _join_with_dividers(valid, p => _render_project(p, labels, prefs))
  } else {
    // Groups render in first-occurrence order, matching the
    // publications clustering.
    let groups = _group_by(valid, p => if is-typed(p) { p.type } else { labels.otherProjects })
    for (group, items) in groups.pairs() [
      ==== #group

      #_join_with_dividers(items, p => _render_project(p, labels, prefs))
    ]
  }
}
