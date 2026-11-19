#import "@preview/kindling-packing-list:0.1.0": packing-sheet, meal-plan, starter-list

#set page(paper: "us-letter", margin: 1.6cm)
#set text(font: ("Libertinus Serif", "New Computer Modern"), lang: "en")

// Page 1: the packing list. Edit trip.camp ("# Section", "- [ ] item",
// "- [x] packed") or replace read("trip.camp") with starter-list.
// Themes: "forest", "lake", "desert", "ember", "slate".
#packing-sheet(
  camp: read("trip.camp"),
  trip: "Lake weekend",
  dates: "Fri - Sun",
  people: 4,
  days: 3,
  hot: true,
  theme: "forest",
  extra: 6,
  notes: [Keep the cooler at 40F / 4C or below (USDA). Check the campground's
    food storage and fire rules before you leave.],
)

#pagebreak()

// Page 2: the meal plan. Fill cells here, or leave them blank and write by hand.
#meal-plan(
  trip: "Lake weekend",
  dates: "Fri - Sun",
  people: 4,
  day-names: ("Friday", "Saturday", "Sunday"),
  theme: "forest",
  plan: (
    "Friday": (Dinner: [Foil-pack tacos (ground beef, frozen at home)]),
    "Saturday": (
      Breakfast: [Skillet eggs, tortillas],
      Lunch: [Sandwiches from the cooler],
      Dinner: [Grilled chicken, corn],
      "Cooler / shop": [Ice day 2; corn, limes],
    ),
    "Sunday": (Breakfast: [Oatmeal, coffee], Lunch: [Leftovers before the drive]),
  ),
)
