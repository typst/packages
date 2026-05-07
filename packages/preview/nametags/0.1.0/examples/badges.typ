// Render one 4x3 in badge per row of attendees.csv.
//
// From Typst Universe:
//   #import "@preview/nametags:0.1.0": nametag
// From a local checkout:
#import "../lib.typ": nametag

// CSV columns: First, Last, Affil1 (department), Affil2 (institution)
#let rows = csv("attendees.csv").slice(1)  // drop header row

// Load logos once as bytes; the package re-uses them on every page.
#let left-logo = read("logo-left.png", encoding: none)
#let right-logo = read("logo-right.png", encoding: none)

#for row in rows {
  let (first, last, affil1, affil2) = row
  nametag(
    name: first + " " + last,
    affiliation: affil2,
    subaffiliation: affil1,
    conference: "Annual Research Symposium",
    year: "2026",
    logo-left: left-logo,
    logo-right: right-logo,
  )
}
