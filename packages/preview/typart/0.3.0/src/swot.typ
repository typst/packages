// SWOT: strengths, weaknesses, opportunities and threats as a 2x2 of cards.
// Import with:  #import "swot.typ": swot
//
//   #swot([- Team], [- Budget], [- New market], [- Competition])
#import "common.typ": _theme, default-theme
#import "cards.typ": cards

#let swot(
  strengths, weaknesses, opportunities, threats,
  titles: ([Strengths], [Weaknesses], [Opportunities], [Threats]),
  fills: auto,
  ..style,
) = context {
  // auto: the green, red, sky and amber of the palette
  let look = style.named().pairs().filter(((key, _)) => key in default-theme).to-dict()
  let palette = _theme("swot", style.named().at("theme", default: (:)), arguments(..look)).palette
  let fills = if fills == auto { (1, 3, 4, 2).map(k => palette.at(calc.rem(k, palette.len()))) } else { fills }
  if not (type(fills) == array and fills.len() == 4) { assert(false, message: "swot: `fills` is auto or four colours, got " + repr(fills)) }
  cards(
    range(4).map(i => (titles.at(i), (strengths, weaknesses, opportunities, threats).at(i), fills.at(i))),
    columns: 2, ..style)
}
