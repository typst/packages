// `{name, keywords}` groups, one row each: skills' as tags, the
// name as a category tag and the keywords wrapping under the first of
// them; interests' as a line of text.

#import "../context.typ": _theme
#import "../design/styles.typ": _unjustified
#import "../primitives.typ": _tag-gap, _tag-row, tag
#import "../util/values.typ": _present

// The dash is `text(...)`, not markup, so it can't parse as a list
// bullet. The `_tag-gap` after it mirrors the gap `tag()` leaves on
// its left, so the dash sits centred between the tags. The hanging
// indent is the label's measured width, so wrapped keywords line up
// under the first; a label wider than `keyword-row.indent-max` of the
// column hangs nothing, so its keywords keep room to wrap. A group's
// optional `mark` (a skill level: dots or its text) follows the label.
// A group without a name (JSON Resume doesn't require one) has no
// category tag; with no mark either, its keywords start the row.
#let _keyword-rows(groups) = _unjustified(context {
  let theme = _theme()
  let (gap, dash, indent-max) = theme.keyword-row
  let row-gap = gap * text.size
  layout(size => for group in groups {
    let name = group.at("name", default: none)
    let named = _present(name)
    let mark = group.at("mark", default: none)
    let label = if named or mark != none {
      if named { tag(name, category: true) }
      if mark != none {
        mark
        _tag-gap(theme, text.size)
      }
      text(dash)
      _tag-gap(theme, text.size)
    }
    let keywords = group.keywords
    let indent = measure(label).width
    block(above: 0pt, below: row-gap, par(
      hanging-indent: if indent > indent-max * size.width { 0pt } else {
        indent
      },
      leading: row-gap,
      {
        label
        _tag-row(keywords)
      },
    ))
  })
})

// `Music: Trad, Jazz`, one line per group, the name in the emphasis
// colour and `treatment.label` (bold by default); a group without a
// name, its items alone. Quieter than
// `_keyword-rows`' tags, for groups a reader skims past.
#let _label-rows(groups) = _unjustified(context {
  let (separator, treatment, colours) = _theme()
  par(
    groups
      .map(group => {
        let name = group.at("name", default: none)
        if _present(name) [#text(
            fill: colours.emphasis,
            (treatment.label)(name),
          )#separator.label]
        group.keywords.join(separator.items)
      })
      .join(linebreak()),
  )
})
