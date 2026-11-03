// cupful: turn US cup / tablespoon / teaspoon measures into grams inside Typst documents.
//
// Densities are grams per US customary cup (236.588 ml). Water is physics; every other
// value is a packing CONVENTION (flour spooned and levelled, brown sugar packed, and so on),
// not a measured constant. A dipped-and-packed cup of flour weighs noticeably more.

#let ml-per-cup = 236.588

/// Grams per US cup for common baking and cooking ingredients.
#let densities = (
  "water": 236.588,
  "milk": 244.0,
  "all-purpose-flour": 120.0,
  "bread-flour": 127.0,
  "cake-flour": 114.0,
  "whole-wheat-flour": 120.0,
  "granulated-sugar": 200.0,
  "brown-sugar": 220.0,
  "powdered-sugar": 120.0,
  "butter": 227.0,
  "vegetable-oil": 218.0,
  "honey": 340.0,
  "maple-syrup": 322.0,
  "cocoa-powder": 85.0,
  "rolled-oats": 90.0,
  "white-rice": 185.0,
  "table-salt": 273.0,
  "baking-powder": 221.0,
)

/// Volume units expressed as fractions of one US cup.
#let units = (
  "cup": 1,
  "tbsp": 1 / 16,
  "tsp": 1 / 48,
  "ml": 1 / ml-per-cup,
)

/// Grams for `amount` of `unit` of `ingredient`.
/// `extra` lets a document add or override densities, e.g. (almond-flour: 96.0).
#let grams(amount, unit, ingredient, extra: (:)) = {
  let table = densities + extra
  assert(unit in units, message: "cupful: unknown unit '" + unit + "' (use cup, tbsp, tsp or ml)")
  assert(ingredient in table, message: "cupful: no density for '" + ingredient + "'; pass it via extra")
  amount * units.at(unit) * table.at(ingredient)
}

/// Round to a kitchen-friendly precision: whole grams from 10 g up, 0.5 g below that.
#let kitchen-round(g) = if g >= 10 { calc.round(g) } else { calc.round(g * 2) / 2 }

/// Content such as "1 cup all-purpose flour (120 g)".
#let ingredient(amount, unit, name, label: none, extra: (:)) = {
  let g = kitchen-round(grams(amount, unit, name, extra: extra))
  let shown = if label == none { name.replace("-", " ") } else { label }
  [#amount #unit #shown (#g g)]
}

/// A two-column table of ingredient lines and gram weights, scaled by `factor`.
/// `items` is an array of (amount, unit, ingredient) arrays.
#let recipe-table(items, factor: 1, extra: (:)) = table(
  columns: (1fr, auto),
  align: (left, right),
  table.header([*Ingredient*], [*Grams*]),
  ..items.map(((amount, unit, name)) => (
    [#(amount * factor) #unit #name.replace("-", " ")],
    [#kitchen-round(grams(amount * factor, unit, name, extra: extra)) g],
  )).flatten(),
)
