// `_skills` and `_interests` share the JSON Resume `{name, keywords}`
// shape and render identically, differing only in heading.

#import "../internal/state.typ": _body_size_state
#import "../internal/primitives.typ": _section_frame, _tag_gap, _tag_row, tag

// `text("-")`, not `[-]`, which markup parses as a list bullet. The
// `_tag_gap` after it mirrors the gap `tag()` leaves on its left, so
// the dash sits centred between the pills.
#let _name_keywords_section(groups, key, (labels, ..)) = {
  // Drop groups with no keywords first, so a section with none left
  // skips its heading rather than rendering it bare.
  let visible = groups.filter(g => g.at("keywords", default: ()).len() > 0)
  _section_frame(labels.at(key), visible, context {
    let body-size = _body_size_state.get()
    let row-gap = 0.7 * body-size
    for group in visible {
      block(above: 0pt, below: row-gap, par(
        hanging-indent: 1em,
        leading: row-gap,
        {
          tag(group.name, label: true)
          text("-")
          _tag_gap(body-size)
          _tag_row(group.keywords)
        },
      ))
    }
  })
}

#let _skills(groups, ctx) = _name_keywords_section(groups, "skills", ctx)

#let _interests(groups, ctx) = _name_keywords_section(
  groups,
  "interests",
  ctx,
)
