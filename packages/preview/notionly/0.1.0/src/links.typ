// NORMAL LINKS
#let linktion(doc, link-decorations: true) = {
  // INLINE LINKS (blue and underlined by default)
  show link: it => {
    // Note: show rules are scoped so we need the conditionals inside them (not the other way around)
    if link-decorations {
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
  preview-image: none,
) = link(url)[
  #box(
    width: 100%,
    stroke: (0.2pt + rgb("#B6B6B4")), // subtle Notion-ish bottom border
    radius: 6pt,
    inset: (x: 1.2em, y: 1.2em),
  )[
    // Two-column
    #let left-width = 68% 
    #let right-width = 32%
    #if (preview-image == none) {
      left-width = 100%
      right-width = 0%
    }
    #grid(
      columns: (left-width, right-width),
      align: horizon,
      
      // Left column: Title + Description + URL
      box()[
        // Title
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
        
        // URL
        #text(
          size: 0.85em,
          fill: blue,
          // font: "custom-font"
        )[
          #underline[#url]
        ]
      ],
      
      // Right column: Preview image
      if preview-image != none and preview-image != "" {
        box(radius: 3pt, clip: true)[
        #image(
          preview-image,
          width: auto,
          height: auto,
          fit: "contain"
        )
        ]
      }
    )
  ]
]

// EMBED ELEMENT
#let embed(
  url
) = {
  block(
    link(url)[
      #box(
        inset: 1em, 
        stroke: gray + 0.5pt,
        width: 100%,
        radius: 4pt
      )[
        EMBED ELEMENT: ↗️ #url
      ]
    ]
  )
}

// LINK PREVIEW
#let link-preview(
  url
) = {
  block(
    link(url)[
      #box(
        inset: 1em, 
        stroke: gray + 0.5pt,
        width: 100%,
        radius: 4pt
      )[
        LINK PREVIEW: ↗️ #url
      ]
    ]
  )
}

// CHILD PAGE
#let child-page(
  url,
  icon: "📄",
  title
) = {
  block(
    link(url)[
      #box(
        inset: 1em, 
        stroke: gray + 0.5pt,
        width: 100%,
        radius: 4pt
      )[
        #icon #url
      ]
    ]
  )
}
