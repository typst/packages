// Projects — name (optionally linked), italic description, date
// range, bulleted highlights, pill-tagged keywords. JSON Resume's
// `projects[]` schema; `entity` / `type` / `roles` are accepted but
// unrendered. Entries without a `name` are skipped to avoid an
// orphan heading.

#import "../internal/text.typ": _present, styled-link
#import "../internal/primitives.typ": term, _join_with_dividers, _tag_row
#import "../internal/dates.typ": _format_date_range

#let _projects(entries, labels, prefs) = {
  let valid = entries.filter(p => _present(p.at("name", default: none)))
  if valid.len() == 0 { return }
  [== #labels.projects]
  _join_with_dividers(valid, project => block(breakable: false, {
    let url = project.at("url", default: none)
    [=== #styled-link(project.name, dest: url)]
    let description = project.at("description", default: none)
    if _present(description) {
      // Softer than `name()` (which is bold + accent) so the
      // description doesn't compete visually with a linked title.
      // Wrapped in a block so the gap to the term row below matches
      // the institution-line → term spacing in `_experience` /
      // `_education`; using a bare `linebreak()` here leaves no
      // paragraph spacing.
      block(below: 0.6em, emph(description))
    }
    term(_format_date_range(project, prefs, labels))
    for bullet in project.at("highlights", default: ()) [- #bullet]
    _tag_row(project.at("keywords", default: ()))
  }))
}
