#import "@preview/glossarium:0.5.0": print-glossary

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
      // Disable back references in abbreviations list
      disable-back-references: true
    )
  ]
}
