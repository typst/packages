#set page(
  paper: "us-letter",
  flipped: true,
  margin: 1cm,
  footer: none
)

// Set the default font for the document (commented out to increase compatibility)
//#set text(font: "Arial")

// Modify these variables to point to your own data and logo
#let students-data = "students.csv"
#let logo = "assets/uai-negocios-logo-bajada-png.png"

// ----------------------------------------------------------------------------
// Load student data
#let data = csv(students-data, row-type: dictionary)

#for row in data {
  // Center line
  place(
    center + horizon,
    line(length: 100%, stroke: (paint: gray, dash: "dashed", thickness: 0.5pt))
  )
  
  // Main page grid
  grid(
    columns: (100%),
    rows: (50%, 8%, 42%),
    gutter: 0pt,
    
    // --- Upper half (rotated) ---
    grid(
      align: center + horizon,
      rotate(180deg, reflow: true)[
        #block(width: 100%)[
          #text(size: 110pt, weight: "medium", row.FirstName) \
          #text(size: 80pt, row.LastName)
          #v(0.8cm)
          #align(left)[
            #image(logo, width: 8cm)
          ]
        ]
      ]
    ),
    //This is just so the center row has something in it
    v(0cm),
    
    // --- Lower half (normal) ---
    grid(
      align: center + horizon,     
      block(width: 100%)[
        #text(size: 110pt, weight: "medium", row.FirstName) \
        #text(size: 80pt, row.LastName)
        #v(0.8cm)
        #align(left)[
          #image(logo, width: 8cm)
        ]
      ]
    )
  )
  pagebreak(weak: true)
}
