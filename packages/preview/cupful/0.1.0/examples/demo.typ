#import "../lib.typ": *

= Banana bread (doubled)

#ingredient(1, "cup", "all-purpose-flour") \
#ingredient(2, "tbsp", "granulated-sugar") \
#ingredient(1, "tsp", "table-salt") \
#ingredient(0.5, "cup", "almond-flour", label: "almond flour", extra: ("almond-flour": 96.0))

#recipe-table(
  ((1.5, "cup", "all-purpose-flour"), (0.75, "cup", "brown-sugar"), (0.5, "cup", "butter"), (1, "tsp", "baking-powder")),
  factor: 2,
)

#assert.eq(grams(1, "cup", "water"), 236.588)
#assert.eq(grams(16, "tbsp", "all-purpose-flour"), 120.0)
#assert.eq(kitchen-round(grams(1, "tsp", "table-salt")), 5.5)
