// These are the Resumania data structures and functions for organizing and
// creating sections of a resume.
//
// This is mostly meant for internal use, but it may also be useful for creating
// custom resume sections.
//
// Here is a usage example:
// ```typst
// #let show-disco(shape, ..) = { text(fill: gray, shape) }

// #let disco-party = section(
//   "Disco!",
//   show-disco,
//   "orb",
//   "dodecahedron",
// )
//
// #show-section(disco-party)
// ```
// -----------------------------------------------------------------------------

#import "debug.typ": *
#import "style.typ"

// A section of the resume.
//
// = Parameters
// - `title`: `any`
//     The title of the section.
// - `show-item`: `function`
//     The function that is used to convert an item into content. It must accept
//     a single positional argument that is an item from `items` and return
//     content or a value that can be directly converted to content.
// - `items`: `any`
//     The items that belong as part of the section. These will be passed to
//     `show-item` when `show-section` is called on the return object of this
//     fucniton. Note that both named items and unnamed items are allowed, but
//     they will be gathered into one list of items, with named items first.
// - `show-section`: `function` | `none`
//     An optional function used to show the section. Instead of the default,
//     this function will be used instead and the whole section dictionary will
//     be passed to it.
#let section(title, show-item, show-section: none, ..items) = {
  return (
    title: title,
    show-item: show-item,
    items: items.named().values() + items.pos(),
    show-section: show-section,
  )
}

// Turn a section into content.
//
// = Parameters
// - `section`: `dictionary`
//     The resume section to show, which should be a dictionary formatted like
//     the one returned from `section`.
#let show-section(section) = {
  let result = none

  let (title, show-item, items, show-section) = section

  if show-section != none {
    return show-section(section)
  }

  title = debug-block(style.section(title), sticky: true)
  result += title

  result += items.map(item =>
      debug-block(show-item(item))
  ).sum()
  return debug-block(result)
}
