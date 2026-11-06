
// Formating Config of the Post-Document
#let format-doc-post(body) = {
  
  // Set - Pages
  // --------------------------------------------------------
  set page(footer: context {
    set align(center)
    [\u{2015}]
    counter(page).display("  1  ")
    [\u{2015}]
  })

  
  // Set - Headings
  // --------------------------------------------------------
  set heading(numbering: none)

   
  // Body
  // --------------------------------------------------------
  body
}
