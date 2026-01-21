// =====================================================================
// NUTRITION LABEL TEMPLATE
// =====================================================================
// This function takes a dictionary of data and renders a nutrition label.
// =====================================================================
#let nutrition-label-nam(data) = {
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

  // Create a block to act as a styling container.
  block[
    // Use a high-quality Helvetica clone with good weight support. "Tex Gyre Heros" or "Liberation Sans"
    #set text(font: "Liberation Sans")
    #set par(leading: 0.4em)
    #set block(spacing: 0.5em)

    // The main container for the nutrition label, placed inside the styled block.
    #rect(
      width: 3in,
      stroke: 1pt,
      inset: (x: 6pt, y: 6pt),
    )[
      // Use a non-breaking space, heavier weight, and larger size.
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

      // A single, unified block for all nutrients.
      #block[
        #set text(size: 10pt)
        #v(1pt)
        #align(right)[*\% Daily Value\**]
        #line(length: 100%, stroke: 0.5pt)
        
        *Total Fat* #data.total_fat.amount #h(1fr) *#data.total_fat.dv*
        #line(length: 100%, stroke: 0.5pt)
        
        #h(1em) Saturated Fat #data.saturated_fat.amount #h(1fr) *#data.saturated_fat.dv*
        #line(length: 100%, stroke: 0.5pt)

        #h(1em) _Trans_ Fat #data.trans_fat.amount #h(1fr)
        #line(length: 100%, stroke: 0.5pt)

        *Cholesterol* #data.cholesterol.amount #h(1fr) *#data.cholesterol.dv*
        #line(length: 100%, stroke: 0.5pt)

        *Sodium* #data.sodium.amount #h(1fr) *#data.sodium.dv*
        #line(length: 100%, stroke: 0.5pt)
        
        *Total Carbohydrate* #data.carbohydrate.amount #h(1fr) *#data.carbohydrate.dv*
        #line(length: 100%, stroke: 0.5pt)
        
        #h(1em) Dietary Fiber #data.fiber.amount #h(1fr) *#data.fiber.dv*
        #line(length: 100%, stroke: 0.5pt)
        
        #h(1em) Total Sugars #data.sugars.amount #h(1fr)
        #pad(left: 2em)[
          #line(length: 100%, stroke: 0.5pt)
          ]
          #h(2em) Includes #data.added_sugars.amount Added Sugars #h(1fr) *#data.added_sugars.dv*
        #line(length: 100%, stroke: 0.5pt)
        
        *Protein* #data.protein.amount #h(1fr)

        #thicker-separator()

        // Loop through the micronutrients array to generate them dynamically.
        #for (i, nutrient) in data.micronutrients.enumerate() {
          [#nutrient.name #nutrient.amount #h(1fr) *#nutrient.dv*]
          // Don't draw a line after the very last item.
          if i < data.micronutrients.len() - 1 {
            line(length: 100%, stroke: 0.5pt)
          }
        }
      ]
      #if data.micronutrients.len() >= 1 { thick-separator() }
      
      #text(size: 9pt)[
        \* The \% Daily Value (DV) tells you how much a nutrient in a serving of food contributes to a daily diet. 2,000 calories a day is used for general nutrition advice.
      ]
    ]
  ]
}
