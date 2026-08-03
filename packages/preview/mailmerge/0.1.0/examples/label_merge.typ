// examples/label_merge.typ - Address Labels & Badge Grid Mail Merge Example

#import "../lib.typ": mail-merge-labels, presets, field, fmt-field, join-fields, if-field

// 1. Address Labels (using Avery 5160 preset with cut lines enabled)
#mail-merge-labels(
  csv("data/clients.csv", row-type: dictionary),
  preset: presets.avery-5160,
  show-cut-lines: true,
  record => [
    #align(top + left)[
      #text(size: 9pt, weight: "bold")[#fmt-field(record, "First Name") #fmt-field(record, "Last Name")] \
      #text(size: 8pt)[
        #if-field(record, "Company", c => [#c \ ])
        #field(record, "Address 1") \
        #if-field(record, "Address 2", a => [#a \ ])
        #join-fields(record, ("City", "State"), separator: ", ") #field(record, "Zip")
      ]
    ]
  ]
)

#pagebreak()

// 2. Conference Name Badges (2 columns x 3 rows per page with custom styling)
#mail-merge-labels(
  csv("data/badges.csv", row-type: dictionary),
  columns: 2,
  rows: 3,
  height: 2.8in,
  column-gutter: 0.25in,
  row-gutter: 0.2in,
  show-cut-lines: 1pt + rgb("#cbd5e0"),
  fill: record => if field(record, "VIP") == "Yes" { rgb("#fffaf0") } else { rgb("#ffffff") },
  record => [
    #align(center)[
      #v(0.5em)
      #text(size: 9pt, weight: "bold", tracking: 0.15em, fill: rgb("#4a5568"))[GLOBAL TECH SUMMIT 2026]
      #v(0.3em)
      #line(length: 80%, stroke: 1.5pt + rgb("#3182ce"))
      #v(0.8em)

      #text(size: 18pt, weight: "bold", fill: rgb("#1a202c"))[
        #fmt-field(record, "First Name") \ #fmt-field(record, "Last Name")
      ]

      #v(0.4em)
      #text(size: 10pt, style: "italic", fill: rgb("#2b6cb0"))[#field(record, "Title")] \
      #text(size: 11pt, weight: "medium")[#field(record, "Company")]

      #v(0.8em)
      #let role-bg = if field(record, "Role") == "Speaker" { rgb("#ebf8ff") } else { rgb("#f7fafc") }
      #let role-fg = if field(record, "Role") == "Speaker" { rgb("#2b6cb0") } else { rgb("#4a5568") }
      #rect(
        fill: role-bg,
        stroke: 0.5pt + role-fg,
        radius: 3pt,
        inset: (x: 8pt, y: 3pt),
        text(size: 8pt, weight: "bold", fill: role-fg)[#upper(field(record, "Role"))]
      )
    ]
  ]
)
