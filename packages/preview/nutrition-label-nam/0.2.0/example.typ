#import "@preview/nutrition-label-nam:0.2.0": nutrition-label-nam
//#import "lib.typ": nutrition-label-nam
// =====================================================================
// EXAMPLE USAGE
// =====================================================================
#let sample-data = (
  servings: "8",
  serving_size: "2/3 cup (55g)",
  calories: "230",
  total_fat: (value: 8, unit: "g"),
  saturated_fat: (value: 1, unit: "g"),
  trans_fat: (value: 0, unit: "g"),
  cholesterol: (value: 0, unit: "mg"),
  sodium: (value: 160, unit: "mg"),
  carbohydrate: (value: 37, unit: "g"),
  fiber: (value: 4, unit: "g"),
  sugars: (value: 12, unit: "g"),
  added_sugars: (value: 10, unit: "g"),
  protein: (value: 3, unit: "g"),
  micronutrients: (
    (name: "Vitamin D", key: "vitamin_d", value: 2, unit: "mcg"),
    (name: "Vitamin K", key: "vitamin_k", value: 100, unit: "mcg"),
    (name: "Calcium", key: "calcium", value: 260, unit: "mg"),
    (name: "Iron", key: "iron", value: 8.0, unit: "mg"),
    (name: "Potassium", key: "potassium", value: 240, unit: "mg"),
  ),
)
#nutrition-label-nam(sample-data)
#let sample-data = (
  servings: "8",
  serving_size: "2/3 cup (55g)",
  calories: "230",
  total_fat: (value: 8, unit: "g"),
  saturated_fat: (value: 1, unit: "g"),
  trans_fat: (value: 0, unit: "g"),
  cholesterol: (value: 0, unit: "mg"),
  sodium: (value: 160, unit: "mg"),
  carbohydrate: (value: 37, unit: "g"),
  fiber: (value: 4, unit: "g"),
  sugars: (value: 12, unit: "g"),
  added_sugars: (value: 10, unit: "g"),
  protein: (value: 3, unit: "g"),
  micronutrients: (
  ),
)
#nutrition-label-nam(
  sample-data,
  scale-percent: 66%,
  show-footnote: false,
)
#let sample-data = (
  servings: "8",
  serving_size: "2/3 cup (55g)",
  calories: "230",
  total_fat: (value: 8, unit: "g"),
  saturated_fat: (value: 1, unit: "g"),
  trans_fat: (value: 0, unit: "g"),
  cholesterol: (value: 0, unit: "mg"),
  sodium: (value: 160, unit: "mg"),
  carbohydrate: (value: 37, unit: "g"),
  fiber: (value: 4, unit: "g"),
  sugars: (value: 12, unit: "g"),
  added_sugars: (value: 10, unit: "g"),
  protein: (value: 3, unit: "g"),
  micronutrients: (
    (name: "Vitamin D", key: "vitamin_d", value: 2, unit: "mcg"),
    (name: "Calcium", key: "calcium", value: 260, unit: "mg"),
    (name: "Iron", key: "iron", value: 8.0, unit: "mg"),
    (name: "Potassium", key: "potassium", value: 240, unit: "mg"),
  ),
)
#nutrition-label-nam(
  sample-data,
  font: "Tex Gyre Heros",
  scale-percent: 33%,
  show-footnote: true,
)