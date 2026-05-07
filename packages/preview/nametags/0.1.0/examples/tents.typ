// Render one folded table tent per row of attendees.csv.
// Print on tabloid (11 x 17), trim to 11 x 8.5 if needed, fold along the
// horizontal center.
//
// From Typst Universe:
//   #import "@preview/nametags:0.1.0": nametent
// From a local checkout:
#import "../lib.typ": nametent

#let rows = csv("attendees.csv").slice(1)  // drop header row

#let left-logo = read("logo-left.png", encoding: none)
#let right-logo = read("logo-right.png", encoding: none)

#for row in rows {
  let (first, last, _, affil2) = row
  nametent(
    name: first + " " + last,
    affiliation: affil2,
    conference: "Annual Research Symposium",
    year: "2026",
    logo-left: left-logo,
    logo-right: right-logo,
  )
}
