#import "../widgets.typ": widgets
#import "units.typ" as units

#let (card, statement, bar, bar-chart) = widgets(
  space: units.space,
  font: units.font,
  weight: units.weight,
)

// statement w/ spacing to the surrounding flow text
#let statement = (..args) => block(
  above: units.space.md,
  below: units.space.base,
  {
    statement(..args)
    // compensates the negative spacing after the byline
    if args.named().at("byline", default: none) != none { v(units.space.md) }
  },
)
