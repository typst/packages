
// Formating Config of the Pre-Document
#let format-doc-pre(body) = {
  
  // Set - Pages
  // --------------------------------------------------------
  set page(footer: context {
    set align(center)
    [\u{2015}]
    counter(page).display("  I  ")
    [\u{2015}]
  })

  
  // Set - Headings
  // --------------------------------------------------------
  set heading(numbering: "I.")

  
  // Body
  // --------------------------------------------------------
  body  
}
