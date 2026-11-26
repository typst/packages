// Projects (JSON Resume `projects[]`). Entries cluster under `====`
// subheadings only when at least one has a `type`; an all-untyped list
// renders flat. Entries without a `name` are skipped.

#import "../internal/util/fields.typ": _field
#import "../internal/data/cv.typ": _entry-period, _entry-type, _type-groups
#import "../internal/components/entry.typ": _entry
#import "../internal/primitives.typ": _icon-heading
#import "../internal/components/frame.typ": _grouped-section, _section

// The client or company (`entity`) leads the facts line, as an
// organisation does; it mirrors `publications[].publisher`.
#let _render-project(project, (labels, format-date, ..)) = _entry(
  labels,
  title: project.name,
  url: _field(project, "url"),
  org: _field(project, "entity"),
  roles: project.at("roles", default: ()),
  period: _entry-period(project, format-date, labels.present),
  summary: _field(project, "summary"),
  highlights: project.at("highlights", default: ()),
  keywords: project.at("keywords", default: ()),
)

#let _projects(entries, ctx) = {
  let (labels, prefs, ..) = ctx
  let render(p) = _render-project(p, ctx)

  // Flat unless some entry has a usable `type`, so the common untyped
  // case gets no redundant subheadings. Untyped entries in a mixed list
  // pool under `labels.other-projects`.
  if not entries.any(p => _entry-type(p) != none) {
    _section(labels.projects, entries, render)
  } else {
    _grouped-section(
      labels.projects,
      _type-groups(entries, untyped: labels.other-projects).to-dict(),
      // `project-icons` is lowercase-keyed (`_canonical-preferences`); a
      // group it doesn't map gets `folder`.
      (group, _) => _icon-heading(
        prefs.project-icons.at(lower(group), default: "folder"),
        group,
      ),
      render,
    )
  }
}
