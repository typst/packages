// right side of page ////////////////////////////////

// box for the current active chapter
#let active_chapter_box(idx, offset, box_height) = place(
  top + right,
  dx: 0pt,
  dy: offset + box_height*(idx - 1),
)[        
  // get current chapter
  #let chapters = query(heading.where(level: 10).before(here()))
  #if chapters.len() > 0 {  
    let current_chapter = chapters.last()

    link(label(current_chapter.supplement.text))[
      #rect(height: box_height, width: 23pt, fill: rgb("#1a1a1a"))
    ]
    place( // ch-index
      center + top,
      dx: -4pt, dy: 4pt,
      text(10pt, font: "Onest", weight: 700, fill: rgb("#fafafa"))[#idx]
    )
    place( // pointer
      center + horizon,
      dx: -9pt,
      rotate(45deg)[#square(height: 10pt, fill: rgb("#1a1a1a"))]
    )
    place( // pointer
      center + horizon,
      dx: -4pt,
      dy: 5.5pt,
      rotate(90deg)[#text(8pt, font: "Onest", weight: 700, fill: rgb("#fafafa"))[#current_chapter.body.text]]
    )
  } 
]


// box for non-active chapters
#let inactive_chapter_box(where, chapter-header, idx, offset, box_height) = place(
  top + where,
  dx: -8pt,
  dy: offset + box_height*(idx),
)[
  // check if we are already in one of the active chapters
  #let chapters = query(heading.where(level: 10).before(here()))
  #if chapters.len() > 0 {  

    let intensity = 200
    // add clickeable element
    link(label(chapter-header.supplement.text))[
      #rect(height: box_height, width: 15pt, stroke: luma(intensity))[#align(center+top)[
    ]]]
    place( // ch-index
      center + top,
      dx: 0pt, dy: 4pt,
      text(10pt, font: "Onest", weight: 700, fill: luma(intensity))[#(idx+1)]
    )
    place( // text
      center + horizon,
      dx: 0.3pt,
      dy: 5pt,
      rotate(90deg)[#text(8pt, font: "Onest", weight: 700, fill: luma(intensity))[#chapter-header.body.text]]
    )
  }
]


// left side of page ////////////////////////////////


// mini version to ensure printing contrast
#let active_chapter_backside_box(idx, offset, box_height) = place(
  top + left,
  dx:-4pt,
  dy: offset + box_height*(idx - 1),
  rect(height: box_height, width: 14pt, fill: rgb("#1a1a1a"))
)