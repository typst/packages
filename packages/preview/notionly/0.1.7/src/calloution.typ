#import "notion-colors.typ": *

// ---------- Callout function ----------

#let callout(
  icon: none,
  bg: notion.gray_bg,
  body,
) = {
  // LAYOUT A - No icon/emoji
  if icon == none {
    box(
      width: 100%,
      fill: bg,
      radius: 6pt, // Border-radius
      inset: (x: 16pt, top: 18pt, bottom: 16pt), // Padding
    )[
       #body
    ]
  } else {
    // LAYOUT B - With icon/emoji
    box(
      width: 100%,
      fill: bg,
      radius: 6pt, // Border-radius
      inset: (left: 12pt, right: 14pt, y: 14pt),  // Padding
    )[
      #grid(
        columns: (16pt, 1fr),
        column-gutter: 8pt, // Gap between icon/emoji and text
        align: (left, top), // Top-left align both columns
      )[
        // Left column (icon/emoji)
        #text(size: 14pt)[#icon]
      ][
        // Right column (content)
        #box(
          width: 100%,
          inset: (top: 4pt, bottom: 2pt), 
        )[
          #body
        ]
      ]
    ]
  }
}

