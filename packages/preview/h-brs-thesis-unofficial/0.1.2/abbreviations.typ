#import "@preview/abbr:0.3.0"

#let load-abbreviations(abbr-csv-content) = {
  if abbr-csv-content != none {
    for line in abbr-csv-content.split("\n") {
      let row = line.replace("\r", "").trim()
      if row != "" {
        abbr.make(row.split(","))
      }
    }
  }
}

#let print-abbreviations(strings) = {
  pagebreak()
  {
    set heading(numbering: none)

    // Align abbreviations (which are displayed in a table) with the heading
    set table(inset: (left: 0pt, right: 5pt, top: 5pt, bottom: 5pt))
    abbr.list(title: strings.abbreviations_title, columns: 1)
  }
}
