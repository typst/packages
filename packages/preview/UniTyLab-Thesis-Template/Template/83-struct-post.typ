#import "config.typ": *

// Post Document Config
#let doc-post(body) = {

  // Heading
  set heading(numbering: none)
  
  // Page
  set page(footer: context {
    set align(center)
    [\u{2015}]
    counter(page).display("  1  ")
    [\u{2015}]
  })
  
  body
}
