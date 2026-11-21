# frosted-facts

US-style **Nutrition Facts** panels, **per-100 g nutrition tables** (EU style) and **Mifflin-St Jeor** energy helpers for Typst.

```typ
#import "@preview/frosted-facts:0.1.0": *

#nutrition-label(
  servings: 1, serving-size: "1 medium (118 g)", calories: 105,
  fat: 0.4, sat: 0.1, trans: 0, chol: 0, sodium: 1,
  carbs: 27, fiber: 3.1, sugars: 14, protein: 1.3,
)

#nutrition-table((("Energy", "143 kcal", "72 kcal"), ("Protein", "12.6 g", "6.3 g")), portion: "1 egg (50 g)")

#tdee(70, 175, 30, "male", activity: 1.55)  // ≈ 2556 kcal/day
```

% Daily Values use FDA reference amounts. The package only typesets the values you give it; it does not check labelling rules. Example values: USDA FoodData Central.

Calorie, TDEE and macro calculators with the same formulas: [snowbelly.app](https://snowbelly.app/tools/calorie-calculator/). A LaTeX version is on CTAN (`nutritionfacts`).

MIT License.
