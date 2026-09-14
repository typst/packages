// Theme definition for a compact glossary layout optimized for space efficiency
//
// This theme provides a dense but readable format with:
// 1. Terms and definitions on same line
// 2. Smaller font size
// 3. Minimal vertical spacing
// 4. Left-aligned groups for quick scanning
// 5. Condensed page references
//
#let theme-compact = (
  // Renders the main glossary section with minimal spacing
  // Parameters:
  //   title: The glossary section title
  //   body: Content containing all groups and entries
  section: (title, body) => {
    set par(leading: 0.65em)
    heading(level: 1, outlined: false, text(weight: "bold", size: 1.1em, title))
    body
  },

  // Renders a group of related glossary terms
  // Parameters:
  //   name: Group name (empty string for ungrouped terms)
  //   index: Zero-based group index
  //   total: Total number of groups
  //   body: Content containing the group's entries
  group: (name, index, total, body) => {
    if name != "" and total > 1 {
      block(
        spacing: 0.5em,
        pad(
          top: 0.5em,
          text(weight: "bold", size: 0.9em, name)
        )
      )
    }
    body
  },

  // Renders a single glossary entry with term, definition, and page references
  // Parameters:
  //   entry: Dictionary containing term data:
  //     - short: Short form of term
  //     - long: Long form of term (optional)
  //     - description: Term description (optional)
  //     - label: Term's dictionary label
  //     - pages: Linked page numbers where term appears
  //   index: Zero-based entry index within group
  //   total: Total entries in group
  entry: (entry, index, total) => {
    // Format term components with minimal spacing
    let term = text(
      size: 0.65em,
      weight: "medium",
      fill: gray.darken(60%),
      entry.short
    )

    let long-form = if entry.long == none {
      []
    } else {
      text(size: 0.65em, fill: gray.darken(20%), [ (#entry.long)])
    }

    let description = if entry.description == none {
      []
    } else {
      text(size: 0.65em, [· #entry.description])
    }

    // Create the complete entry with tight spacing
    block(
      spacing: 0.4em,
      grid(
        columns: (auto, 1fr, auto),
        align: left+bottom,
        gutter: 0.5em,
        // Term and description column
        box[#term#entry.label#long-form #description],
        // Dots....
        repeat(h(0.25em) + text(fill: gray, ".") + h(0.25em)),
        // Page references with smaller font
        text(
          size: 0.6em,
          fill: gray.darken(20%),
          entry.pages
        )
      )
    )
  },
)
