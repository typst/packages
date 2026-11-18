#import "@preview/kindling-packing-list:0.1.0": packing-sheet, starter-list

#set page(paper: "us-letter", margin: 1.6cm)
#set text(font: ("Libertinus Serif", "New Computer Modern"), lang: "en")

// Edit trip.camp (one item per line, "# Section", "- [ ] item", "- [x] packed")
// or replace read("trip.camp") with starter-list.
#packing-sheet(
  camp: read("trip.camp"),
  trip: "Lake weekend",
  dates: "Fri - Sun",
  people: 4,
  days: 2,
  hot: true,
  extra: 6,
  notes: [Keep the cooler at 40F / 4C or below (USDA). Check the campground's
    food storage and fire rules before you leave.],
)
