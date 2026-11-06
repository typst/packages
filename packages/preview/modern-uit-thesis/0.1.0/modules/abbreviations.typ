// TODO: Update when 0.4.2 is published
// #import "@preview/glossarium:0.4.2": make-glossary, print-glossary, gls, glspl
#import "glossarium.typ": print-glossary

// Only print short and long, disregard rest
#let custom-print-title(entry) = {
  let short = entry.at("short")
  let long = entry.at("long", default: "")
  [#strong(smallcaps(short)) #h(0.5em) #long]
}

#let abbreviations-page(abbreviations) = {
  // --- List of Abbreviations ---
  pagebreak(weak: true, to: "even")
  align(left)[
    = List of Abbreviations
    #v(1em)
    #print-glossary(
      abbreviations,
      user-print-title: custom-print-title,
      // Show all terms even if they are not referenced
      show-all: true,
      // Disable back references in abbreviations list
      disable-back-references: true
    )
  ]
}
