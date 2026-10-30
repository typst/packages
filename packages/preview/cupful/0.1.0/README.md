# cupful

Weigh your recipes. `cupful` converts US cup, tablespoon, teaspoon and millilitre measures of
common ingredients into grams, so a recipe written in Typst can print both.

```typ
#import "@preview/cupful:0.1.0": *

#ingredient(1, "cup", "all-purpose-flour")   // 1 cup all purpose flour (120 g)
#ingredient(2, "tbsp", "granulated-sugar")    // 2 tbsp granulated sugar (25 g)

#recipe-table(
  ((1.5, "cup", "all-purpose-flour"), (0.75, "cup", "brown-sugar"), (0.5, "cup", "butter")),
  factor: 2,  // double the recipe
)
```

## Functions

- `grams(amount, unit, ingredient, extra: (:))` returns a float. Units are `cup`, `tbsp` (1/16 cup), `tsp` (1/48 cup) and `ml`.
- `ingredient(amount, unit, name, label: none, extra: (:))` returns content like `1 cup all purpose flour (120 g)`.
- `recipe-table(items, factor: 1, extra: (:))` builds an ingredient/grams table, optionally scaled.
- `kitchen-round(g)` rounds to whole grams from 10 g up and to 0.5 g below that.
- `densities` is the built-in dictionary of grams per US cup. Add your own with `extra: ("almond-flour": 96.0)`.

## Where the numbers come from

One US customary cup is 236.588 ml, and water is 236.588 g per cup. Every other density is a
**packing convention**: flour is spooned and levelled, brown sugar is packed, and so on. These
are not physical constants. A dipped-and-packed cup of flour holds noticeably more than 120 g.
The table is the same set of conventions used by the
[Ingredient Calculator cups-to-grams converter](https://ingredientcalculator.com/cups-to-grams),
which covers more ingredients and explains why a cup of flour can weigh different amounts.

| ingredient | g per cup |
|---|---|
| water | 236.588 |
| milk | 244 |
| all-purpose / whole-wheat flour | 120 |
| bread flour | 127 |
| cake flour | 114 |
| granulated sugar | 200 |
| brown sugar | 220 |
| powdered sugar | 120 |
| butter | 227 |
| vegetable oil | 218 |
| honey | 340 |
| maple syrup | 322 |
| cocoa powder | 85 |
| rolled oats | 90 |
| white rice | 185 |
| table salt | 273 |
| baking powder | 221 |

MIT licensed.
