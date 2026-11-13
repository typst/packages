#import "@preview/abbr:0.3.1"

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

    // abbr.list renders its entries in a grid with a fixed inset of 5pt;
    // shift it left so the abbreviations align with the heading
    show grid: pad.with(left: -5pt)
    abbr.list(title: strings.abbreviations_title, columns: 1)
  }
}
