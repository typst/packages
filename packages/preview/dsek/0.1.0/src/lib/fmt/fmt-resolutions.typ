#import "../misc/text.typ": to-text
#import "../utils/translate.typ": translate, translate-str
#import "fmt-references.typ": ref-id

/// Formats a bullet list as operative clauses ("att"-lista / "to"-list).
///
/// Applied automatically to all lists inside `plain-document` via `show list: resolutions`,
/// so it rarely needs to be called directly. A list is only reformatted when
/// *every* item begins with the resolution term; otherwise the list is rendered
/// unchanged, so regular bullet lists are unaffected.
///
/// Sub-items (created with a nested numbered list `+`) are rendered in italics
/// as an elaboration of the clause above them.
///
/// - enumerate (bool, auto): Whether to number each clause.
///                           `auto` enumerates when there are more than 3 items.
/// - term (str, auto): The resolution keyword.
///                     `auto` detects it from document language (`"att"` for Swedish, `"to"` for English).
///
/// -> content
#let resolutions(enumerate: auto, term: auto, unstyled) = {
  // Copy the parameters into the context.
  let enumerate = enumerate
  let term = term

  if term == auto {
    term = translate-str("att", "to")
  }

  let elements = unstyled.children.filter(e => e != [ ])

  if enumerate == auto {
    enumerate = elements.len() > 3
  }

  if elements.any(e => not to-text(e).starts-with(term + " ")) { return unstyled }

  let fmt(x) = to-text(x).replace(count: 1, regex(term + " ?"), "")

  let clause_counter = counter("resolutions")
  clause_counter.update(0)

  show list: set par(justify: false)

  list(
    tight: false,
    indent: 0pt,
    marker: {
      clause_counter.step()

      let number = if enumerate {
        // context is needed here for clause_counter to display correctly
        context align(center, text(fill: gray, size: 0.8em, clause_counter.display()))
      }

      box(width: 1em, number)
      strong(term)
    },
    ..elements.map(element => {
      // If there is any formatting (bold, italic, etc), "flatten" only the text until that point so the formatting is kept.
      if element.body.has("children") {
        // Lists inside this list are parsed as just being indented one step from a normal list
        // (which does makes sense, since they technically are)
        // So we offset the markers by one to make it seem like they are top-level again
        set list(marker: ([–], [•], [‣]))

        // Descriptions are made by creating a numbered numbered sublist.
        show enum: sublist => {
          set text(style: "italic")
          set list(marker: none)
          parbreak()
          sublist.children.map(child => list.item(child.body)).join(parbreak())
          parbreak()
        }

        let children = element.body.children

        // Edge case if someone starts formatting something immediately after the term.
        let from = if children.first() == [#term] { 2 } else { 1 }

        fmt(children.first()) + children.slice(from, children.len()).join()
      } else {
        fmt(element)
      }
    }),
  )
}
