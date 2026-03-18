#import "../90-Document/91-Doc-Info.typ": *

// Page
#set page(footer: context {
  set align(center)
  [\u{2015}]
  counter(page).display("  I  ")
  [\u{2015}]
})

// Title Config
#set align(center)

// Logo HHN
#align(right + top, image("HHN_Logo_EN_slim.png"))

// Spacer
#v(30pt)

// Logo UniTyLab
#image(width: 93%, "UniTyLab_Logo_horizontal.png")

// Document Type
#doc-type

// Create Title
#let titleAligned = align(center + horizon,
  [ 
    #heading(supplement: [Title], [Title])<title>
    #text(font: "Lato", weight: "semibold", 2em, doc-title) \
    
    Version #doc-version \
    #doc-date
  ]
)

// Create Author Grid       
#let authos-grid(..authors) = {

  // Get number of authors
  let authorsThis = authors.pos().first()
  let isOdd = calc.odd(authorsThis.len())

  let authorBox(body) = block(
    inset: 16pt,
    fill: luma(225),
    stroke: none,
    width: 100%,
    radius: 6pt,
    body
  )

  grid(
    columns: (1fr, 1fr),
    rows: (auto, auto),
    gutter: 5pt,
    align: center,
    ..{
      for author in authorsThis { 
        let cell-text = [
          #author.fam-name \
          #author.giv-name \
          #author.mtr-no \
          #author.course \
          #author.uni
        ]
        
        if isOdd and author == authorsThis.last() {(
          grid.cell(
            colspan: 2, 
             authorBox(cell-text)
          ),
        )} else {(
           authorBox(cell-text),
        )}
      }
    }
  )  
}

// Display Title and Authors
#stack(
  dir: ttb,
  [#v(1fr, weak: true)],
  titleAligned,
  [#v(0.5fr, weak: true)],
  [
    #underline[Supervision] \
    #name-supervisor1 \
    #name-supervisor2
  ],
  [#v(1fr, weak: true)],
  authos-grid(authors),
  [#v(0.5fr, weak: true)],
)
