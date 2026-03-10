// =====================================================================
// NUTRITION LABEL  V0.2.0
// =====================================================================
// This function takes a dictionary of data and renders a nutrition label.
// =====================================================================

// =====================================================================
// Daily Values Database (Source: FDA) as of 2025-06-27
// The engine for our automatic percentage calculation.
// Units of Measure Key:
// g = grams
// mg = milligrams
// mcg = micrograms
// mg NE = milligrams of niacin equivalents
// mcg DFE = micrograms of dietary folate equivalents
// mcg RAE = micrograms of retinol activity equivalents
// IU = international units
// https://www.fda.gov/food/nutrition-facts-label/daily-value-nutrition-and-supplement-facts-labels
// =====================================================================
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

// =====================================================================
// NUTRITION LABEL TEMPLATE
// =====================================================================
#let nutrition-label-nam(
  data,
  font: "Liberation Sans",
  scale-percent: 100%,
  show-footnote: true,
) = {
  // A simple helper function to calculate and format the DV percentage.
  let calc-dv(key, value) = {
    if key in daily-values {
      let dv-percent = calc.round(value / daily-values.at(key) * 100)
      return str(dv-percent) + "%"
    }
    return ""
  }

  // Define reusable components for the separator lines.
  let thick-separator() = {
    v(1pt)
    line(length: 100%, stroke: 3pt)
    v(1pt)
  }
  let thicker-separator() = {
    v(3pt)
    line(length: 100%, stroke: 7pt)
    v(3pt)
  }

  
    box[
      #scale(scale-percent, reflow: true)[
      #block[
        #set text(font: font)
        #set par(leading: 0.4em)
        #set block(spacing: 0.5em)

        #rect(width: 3in, stroke: 1pt, inset: (x: 6pt, y: 6pt))[
          #text(weight: "black", size: 29pt)[Nutrition~Facts]
          #line(length: 100%, stroke: 0.5pt)

          #block[
            #set text(size: 12pt)
            #data.servings servings per container \
            *Serving size* #h(1fr) #text(weight: "bold", data.serving_size)
          ]

          #thicker-separator()

          #block[
            #set text(size: 8pt, weight: "black")
            Amount per serving \
            #text(weight: "black", size: 22pt)[*Calories*] #h(1fr) #text(weight: "black", size: 30pt, data.calories)
            #thick-separator()
          ]

          #block[
            #set text(size: 10pt)
            #v(1pt)
            #align(right)[*\% Daily Value\**]
            #line(length: 100%, stroke: 0.5pt)

            *Total Fat* #data.total_fat.value#data.total_fat.unit #h(1fr) *#calc-dv("total_fat", data.total_fat.value)*
            #line(length: 100%, stroke: 0.5pt)

            #h(1em) Saturated Fat #data.saturated_fat.value#data.saturated_fat.unit #h(1fr) *#calc-dv("saturated_fat", data.saturated_fat.value)*
            #line(length: 100%, stroke: 0.5pt)

            #h(1em) _Trans_ Fat #data.trans_fat.value#data.trans_fat.unit #h(1fr)
            #line(length: 100%, stroke: 0.5pt)

            *Cholesterol* #data.cholesterol.value#data.cholesterol.unit #h(1fr) *#calc-dv("cholesterol", data.cholesterol.value)*
            #line(length: 100%, stroke: 0.5pt)

            *Sodium* #data.sodium.value#data.sodium.unit #h(1fr) *#calc-dv("sodium", data.sodium.value)*
            #line(length: 100%, stroke: 0.5pt)

            *Total Carbohydrate* #data.carbohydrate.value#data.carbohydrate.unit #h(1fr) *#calc-dv("carbohydrate", data.carbohydrate.value)*
            #line(length: 100%, stroke: 0.5pt)

            #h(1em) Dietary Fiber #data.fiber.value#data.fiber.unit #h(1fr) *#calc-dv("fiber", data.fiber.value)*
            #line(length: 100%, stroke: 0.5pt)

            #h(1em) Total Sugars #data.sugars.value#data.sugars.unit #h(1fr)
            #pad(left: 2em)[#line(length: 100%, stroke: 0.5pt)]

            #h(2em) Includes #data.added_sugars.value#data.added_sugars.unit Added Sugars #h(1fr) *#calc-dv("added_sugars", data.added_sugars.value)*
            #line(length: 100%, stroke: 0.5pt)

            *Protein* #data.protein.value#data.protein.unit #h(1fr) //*#calc-dv("protein", data.protein.value)*

            #thicker-separator()

            #for (i, nutrient) in data.micronutrients.enumerate() {
              [#nutrient.name #nutrient.value#nutrient.unit #h(1fr) *#calc-dv(nutrient.key, nutrient.value)*]
              if i < data.micronutrients.len() - 1 {
                line(length: 100%, stroke: 0.5pt)
              }
            }
          ]

          #if show-footnote {
            if data.micronutrients.len() >= 1 { thick-separator() }

            text(size: 9pt)[
              \* The \% Daily Value (DV) tells you how much a nutrient in a serving of food contributes to a daily diet. 2,000 calories a day is used for general nutrition advice.
            ]
          }
        ]
      ]
    ]
  ]
}
