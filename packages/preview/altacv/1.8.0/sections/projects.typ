// Projects (JSON Resume `projects[]`). Entries cluster under `====`
// subheadings only when at least one has a `type`; an all-untyped list
// renders flat. Entries without a `name` are skipped.

#import "../internal/text.typ": _field, _string_at
#import "../internal/primitives.typ": (
  _entry, _group_by_type, _grouped_section, _section,
)
#import "../internal/dates.typ": _format_date_range

// The client or company (`entity`) mirrors `publications[].publisher`.
#let _render_project(project, (labels, prefs, ..)) = _entry(
  title: project.name,
  url: _field(project, "url"),
  subtitle: _field(project, "entity"),
  roles: project.at("roles", default: ()),
  period: _format_date_range(project, prefs, labels),
  summary: _field(project, "summary"),
  highlights: project.at("highlights", default: ()),
  tags: project.at("keywords", default: ()),
)

#let _projects(entries, ctx) = {
  let (labels, ..) = ctx
  let valid = entries.filter(p => _field(p, "name") != none)
  let render(p) = _render_project(p, ctx)

  // Flat unless some entry has a usable `type`, so the common untyped
  // case gets no redundant subheadings. Untyped entries in a mixed list
  // pool under `labels.otherProjects`.
  if not valid.any(p => _string_at(p, "type") != none) {
    _section(labels.projects, valid, render)
  } else {
    _grouped_section(
      labels.projects,
      _group_by_type(valid, labels.otherProjects),
      (group, _) => group,
      render,
    )
  }
}
