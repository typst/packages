// Theme definition for a two-column glossary layout with hierarchical sections
//
// This theme provides formatting for three levels of glossary content:
// 1. Section: The overall glossary container
// 2. Groups: Optional categorization of related terms
// 3. Entries: Individual glossary terms and their definitions
//
#let theme-twocol = (
  // Renders the main glossary section as a two-column layout
  // Parameters:
  //   title: The glossary section title
  //   body: Content containing all groups and entries
  section: (title, body) => {
    set par.line(numbering: none)
    heading(level: 1, title)
    columns(2, body)
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
    // Format the short form and optional long form of the term
    let short-display = text(weight: "regular", entry.short)
    let long-display = if entry.long == none {
      []
    } else {
      [#h(0.25em) -- #entry.long]
    }

    // Format the optional description
    let description = if entry.description == none {
      []
    } else {
      [: #entry.description]
    }

    // Render the complete entry with dotted leader line to page numbers
    text(
      size: 0.75em,
      weight: "light",
      grid(
        columns: (auto,1fr,1em,auto),
        align: (left, center, center, right),
        [#short-display#entry.label#long-display#description],  // Term with label
        [#repeat(h(0.25em) + "." + h(0.25em))],  // Dotted leader line
        [ . ], // A 1em wide dot so we definitely get some break between term and pages
        [#entry.pages]                 // Page references
      )
    )
  },
)
