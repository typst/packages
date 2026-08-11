#import "@preview/nutrition-label-nam:0.1.0": nutrition-label-nam

// =====================================================================
// EXAMPLE USAGE
// =====================================================================

#let sample-data = (
  servings: "8",
  serving_size: "2/3 cup (55g)",
  calories: "230",
  total_fat: (amount: "8g", dv: "10%"),
  saturated_fat: (amount: "1g", dv: "5%"),
  trans_fat: (amount: "0g",),
  cholesterol: (amount: "0mg", dv: "0%"),
  sodium: (amount: "160mg", dv: "7%"),
  carbohydrate: (amount: "37g", dv: "13%"),
  fiber: (amount: "4g", dv: "14%"),
  sugars: (amount: "12g",),
  added_sugars: (amount: "10g", dv: "20%"),
  protein: (amount: "3g",),
  // Micronutrients are a generic array. Leave out, add, remove, or reorder as needed.
  micronutrients: (
    (name: "Vitamin D", amount: "2mcg", dv: "10%"),
    (name: "Calcium", amount: "260mg", dv: "20%"),
    (name: "Iron", amount: "8mg", dv: "45%"),
    (name: "Potassium", amount: "240mg", dv: "6%"),
  ),
)

#nutrition-label-nam(sample-data)
