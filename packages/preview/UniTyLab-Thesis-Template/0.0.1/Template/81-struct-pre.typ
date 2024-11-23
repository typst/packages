#import "config.typ": *

// Pre Document Config
#let doc-pre(body) = {

  // Heading
  set heading(numbering: "I.")

  // Page
  set page(footer: context {
    set align(center)
    [\u{2015}]
    counter(page).display("  I  ")
    [\u{2015}]
  })

  body
}
