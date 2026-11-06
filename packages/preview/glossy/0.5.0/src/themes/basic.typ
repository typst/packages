// Theme definition for a basic single-column glossary layout
//
// This theme provides a traditional glossary format with:
// 1. Bold terms
// 2. Indented descriptions
// 3. Simple page references
// 4. Optional group headings
//
#let theme-basic = (
  // Renders the main glossary section as a single column
  // Parameters:
  //   title: The glossary section title
  //   body: Content containing all groups and entries
  section: (title, body) => {
    heading(level: 1, title)
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
      heading(level: 2, name)
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
    // Format the term parts
    let term = text(weight: "bold", entry.short)
    let long-form = if entry.long == none {
      []
    } else {
      [, #entry.long]
    }

    // Format the description with proper spacing
    let description = if entry.description == none {
      []
    } else {
      [: #entry.description]
    }

    // Create the complete entry with hanging indent
    block(
      spacing: 0.5em,
      pad(
        left: 1em,
        bottom: 0.5em,
        block(
          [#term#entry.label#long-form#description #h(1em) (pp. #entry.pages)]
        )
      )
    )
  },
)
