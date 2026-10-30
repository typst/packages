// SWOT: strengths, weaknesses, opportunities and threats as a 2x2 of cards.
// Import with:  #import "swot.typ": swot
//
//   #swot([- Team], [- Budget], [- New market], [- Competition])
#import "cards.typ": cards

#let swot(
  strengths, weaknesses, opportunities, threats,
  titles: ([Strengths], [Weaknesses], [Opportunities], [Threats]),
  colors: (rgb("#73c25a"), rgb("#e64553"), rgb("#74c7ec"), rgb("#f9a64f")),
  ..style,
) = cards(
  range(4).map(i => (titles.at(i), (strengths, weaknesses, opportunities, threats).at(i), colors.at(i))),
  columns: 2, ..style)
