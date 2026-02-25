#let linktion(doc, linkDecorations: true) = {
  // INLINE LINKS (blue and underlined by default)
  show link: it => {
    // Note: show rules are scoped so we need the conditionals inside them (not the other way around)
    if linkDecorations {
      set text(fill: blue)
      underline[#it] 
    } else {
      it
    }
  }  
  doc
}

// BOOKMARK BLOCK
#let bookmark(
  url: str,
  title: "",
  description: "",
  previewImage: none,
) = link(url)[
  #box(
    width: 100%,
    stroke: (0.2pt + rgb("#B6B6B4")), // subtle Notion-ish bottom border
    radius: 6pt,
    inset: (x: 1.2em, y: 1.2em),
  )[
    // Two-column layout: text (left) + image (right)
    #let left-width = 68% 
    #let right-width = 32%
    #if (previewImage == none) {
      left-width = 100%
      right-width = 0%
    }
    #grid(
      columns: (left-width, right-width),
      align: horizon,
      
      // Left column: Title + Description + URL
      box()[
        // Title (larger, bold)
        #if title != "" {
          text(
            size: 1.1em,
            weight: "medium",
            fill: rgb("#373530")
          )[ #underline[#title] ]
          linebreak()
        }
        
        // Description
        #if description != "" {
          text(
            size: 0.95em,
            fill: rgb("#6B6B69")
          )[ #description ]
          linebreak()
        }
        
        // URL (small, gray, full-width)
        #text(
          size: 0.85em,
          fill: blue,
          // font: "Inter"
        )[
          #underline[#url]
        ]
      ],
      
      // Right column: Preview image
      if previewImage != none and previewImage != "" {
        box(radius: 3pt, clip: true)[
        #image(
          previewImage,
          width: auto,
          height: auto,
          fit: "contain"
        )
        ]
      }
    )
  ]
]


