#let progressive-outline(
  h1-style: "all",
  h2-style: "all",
  h3-style: "all",
  scope-h2: "current-h1",
  scope-h3: "current-h2",
  show-numbering: true,
) = {
  context {
    let loc = here()
    let all-headings = query(heading.where(outlined: true))

    let is-before(loc1, loc2) = {
      if loc1.page() < loc2.page() {
        return true
      }
      if loc1.page() == loc2.page() and loc1.position().y < loc2.position().y {
        return true
      }
      return false
    }

    let current-h1 = if query(heading.where(outlined: true, level: 1).before(loc)).len() > 0 {
      query(heading.where(outlined: true, level: 1).before(loc)).last()
    } else { none }

    let current-h2 = if query(heading.where(outlined: true, level: 2).before(loc)).len() > 0 {
      query(heading.where(outlined: true, level: 2).before(loc)).last()
    } else { none }

    let current-h3 = if query(heading.where(outlined: true, level: 3).before(loc)).len() > 0 {
      query(heading.where(outlined: true, level: 3).before(loc)).last()
    } else { none }

    let style-heading(heading, style, current) = {
      let content = if show-numbering {
        numbering("1.1.1", ..counter(heading.func()).at(heading.location())) + " " + heading.body
      } else {
        heading.body
      }
      if style == "all" {
        return content
      } else if style == "current" {
        if heading == current {
          return content
        } else {
          return none
        }
      } else if style == "current-and-grayed" {
        if heading == current {
          return content
        } else {
          return text(fill: gray, content)
        }
      } else if style == "none" {
        return none
      } else {
        return content
      }
    }

    for heading in all-headings {
      let styled-heading = if heading.level == 1 {
        style-heading(heading, h1-style, current-h1)
      } else if heading.level == 2 {
        if scope-h2 == "current-h1" and current-h1 != none {
          let parent-h1 = all-headings.rev().find(h => h.level == 1 and is-before(h.location(), heading.location()))
          if parent-h1 != current-h1 {
            continue
          }
        }
        style-heading(heading, h2-style, current-h2)
      } else if heading.level == 3 {
        if scope-h3 == "current-h2" and current-h2 != none {
          let parent-h2 = all-headings.rev().find(h => h.level == 2 and is-before(h.location(), heading.location()))
          if parent-h2 != current-h2 {
            continue
          }
        }
        style-heading(heading, h3-style, current-h3)
      } else {
        heading.body
      }

      if styled-heading != none {
        let indent = 2em * (heading.level - 1)
        block(pad(left: indent, styled-heading))
      }
    }
  }
}

/// Applies dynamic layout with outlines.
#let progressive-layout(doc, show-numbering: true) = {
  // --- Base styles ---
  set text(font: "Arial", size: 22pt)
  set page(
    paper: "presentation-16-9",
    margin: (top: 2cm, bottom: 2cm, x: 2cm),
  )
  set heading(numbering: "1.1.1")

  // --- Display logic ---

  // At the beginning of the document, display the full table of contents.
  outline()

  // For each level 1 heading, display the list of level 2 sub-sections.
  show heading.where(level: 1): it => {
    pagebreak(weak: true) // Each section 1 starts on a new page
    // Display the progressive outline for the current H1, without the heading text itself.
    set text(size: 22pt) // Homogenize font size for the outline
    progressive-outline(h1-style: "current", h2-style: "all", h3-style: "none", show-numbering: show-numbering)
    pagebreak(weak: true) // Start the actual content on a new page
  }

  // For each level 2 heading, display the list of *all* H2s,
  // with the current H2 highlighted.
  show heading.where(level: 2): it => {
    pagebreak(weak: true) // Each H2 starts on a new page
    // Display the progressive outline for the current H2, without the heading text itself.
    set text(size: 22pt) // Homogenize font size for the outline
    progressive-outline(h1-style: "current", h2-style: "current-and-grayed", h3-style: "none", show-numbering: show-numbering)
    pagebreak(weak: true) // Start the actual content on a new page
  }
  // For each level 3 heading, display the list of *all* H3s,
  // with the current H3 highlighted.
  show heading.where(level: 3): it => {
    pagebreak(weak: true) // Each H3 starts on a new page
    // Display the progressive outline for the current H3, without the heading text itself.
    set text(size: 22pt) // Homogenize font size for the outline
    progressive-outline(h1-style: "current", h2-style: "current-and-grayed", h3-style: "current-and-grayed", show-numbering: show-numbering)
    pagebreak(weak: true) // Start the actual content on a new page
  }

  // --- Document content ---
  doc
}