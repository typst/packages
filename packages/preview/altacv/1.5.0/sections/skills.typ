// `_skills` and `_interests` consume the same JSON Resume
// `{name, keywords}` shape and render identically (a row of pill
// tags led by a "label" pill). The shared layout lives in
// `_name_keywords_section`; the two public renderers differ only in
// which `labels.*` heading they pass.

#import "../internal/state.typ": _body_size_state
#import "../internal/primitives.typ": tag, _tag_row

// `text("-")` (not `[-]`) — markup-bracketed `-` parses as a list-item
// bullet. The trailing `h(...)` after the dash mirrors the gap that
// `tag()` already emits to its left, keeping the label pill visually
// centred between its two whitespace gutters.
#let _name_keywords_section(groups, heading) = {
  // Filter empty-keywords groups up front so we can also skip the
  // section heading: rendering a bare "Skills" with nothing underneath
  // (every group had an empty `keywords:`) reads worse than skipping
  // the section entirely.
  let visible = groups.filter(g => g.at("keywords", default: ()).len() > 0)
  if visible.len() == 0 { return }
  context {
    let body-size = _body_size_state.get()
    let row-gap = 0.7 * body-size
    [== #heading]
    for group in visible {
      block(above: 0pt, below: row-gap, par(hanging-indent: 1em, leading: row-gap, {
        tag(group.name, label: true)
        text("-")
        h(0.25 * body-size)
        _tag_row(group.keywords)
      }))
    }
  }
}

#let _skills(groups, labels) = _name_keywords_section(groups, labels.skills)

#let _interests(groups, labels) = _name_keywords_section(groups, labels.interests)
