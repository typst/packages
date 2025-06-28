# Typst Nutrition Label

A configurable template to generate FDA-style nutrition fact labels in Typst. 

## Usage

First, import the package:
``` typst
#import "@preview/nutrition-label-nam:0.2.0": nutrition-label-nam
```

Then, define your data and call the function:
``` typst
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
  font: "Tex Gyre Heros", // default is "Liberation Sans" because it's likely preinstalled, but "Tex Gyre Heros" is closer to the FDA recommendation "Helvetica" and can be installed for free. I never tested Helvetica because I don't have access to it.
  scale-percent: 100%, // default is 100%
  show-footnote: true, // default is true
)
```
## Font
The default font is "Liberation Sans" because it's likely preinstalled, but "Tex Gyre Heros" is closer to the FDA recommendation "Helvetica" and can be installed for free. I never tested Helvetica because I don't have access to it.

![image](https://github.com/user-attachments/assets/7dddb279-ad14-431a-a970-b1bcfda8297d)

## Key for micronutrients and daily value percentage calculation

Per FDA the DV for protein and trans fat is not printed on the label. But here is a list of all the micronutrients the [FDA has published daily values](https://www.fda.gov/food/nutrition-facts-label/daily-value-nutrition-and-supplement-facts-labels) on their page. There is no unit conversion, so please use the units printed here for the label as well. This will then calculate the DV% for you. This calculation is provided as-is, and you need to make sure all the values are correct. If you use the label on your product, make sure to follow FDA guidelines. We are not liable for any mislabeling. 

``` typst
#let daily-values = (
  added_sugars: 50, // g
  biotin: 30, // mcg
  calcium: 1300, // mg
  carbohydrate: 275, // g
  chloride: 2300, // mg
  choline: 550, // mg
  cholesterol: 300, // mg
  chromium: 35, // mcg
  copper: 0.9, // mg
  fiber: 28, // g
  folate: 400, // mcg DFE
  iodine: 150, // mcg
  iron: 18, // mg
  magnesium: 420, // mg
  manganese: 2.3, // mg
  molybdenum: 45, // mcg
  niacin: 16, // mg NE
  pantothenic_acid: 5, // mg
  phosphorus: 1250, // mg
  potassium: 4700, // mg
  protein: 50, // g
  riboflavin: 1.3, // mg
  saturated_fat: 20, // g
  selenium: 55, // mcg
  sodium: 2300, // mg
  thiamin: 1.2, // mg
  total_fat: 78, // g
  vitamin_a: 900, // mcg RAE
  vitamin_b6: 1.7, // mg
  vitamin_b12: 2.4, // mcg
  vitamin_c: 90, // mg
  vitamin_d: 20, // mcg
  vitamin_e: 15, // mg alpha-tocopherol
  vitamin_k: 120, // mcg
  zinc: 11, // mg
)
```


[Link to example.typ](example.typ)  
[Link to example.pdf](example.pdf)  

