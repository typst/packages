// Section scaffolding: the section's heading and its entries with a
// separator between neighbours, optionally clustered under group
// headings. A heading's level is its place in the document's outline
// (the name 1, a section 2, a group 3, an entry 3 or, under a group,
// 4), so tagged PDF and the bookmarks nest; its role, and so its look,
// is an internal label (`design/styles.typ`).

#import "../primitives.typ": divider

// Empty `entries` renders nothing, not even the heading, so callers
// filter unusable entries first and no heading is orphaned.
#let _section-frame(title, entries, body) = if entries.len() > 0 {
  [#heading(depth: 1, title)<alta-internal-section>]
  body
}

// Each entry unbreakable, with `separator` between neighbours only, so
// a section doesn't end on a stray rule.
#let _entry-blocks(entries, render-entry, separator: divider()) = (
  entries.map(e => block(breakable: false, render-entry(e))).join(separator)
)

#let _section(heading, entries, render-entry, separator: divider()) = (
  _section-frame(
    heading,
    entries,
    _entry-blocks(entries, render-entry, separator: separator),
  )
)

// `_section` with entries clustered under `====` subheadings, one per
// `groups` key (`_type-groups`, as a dictionary); `subheading(key, items)` gives each
// subheading's text.
#let _grouped-section(
  title,
  groups,
  subheading,
  render-entry,
  separator: divider(),
) = _section-frame(title, groups, {
  for (key, items) in groups.pairs() {
    [#heading(depth: 2, subheading(key, items))<alta-internal-group>]
    // A level deeper, so the group's entries nest under it: over the
    // offset already in effect (standalone's), as a set rule replaces it.
    context {
      set heading(offset: heading.offset + 1)
      _entry-blocks(items, render-entry, separator: separator)
    }
  }
})
