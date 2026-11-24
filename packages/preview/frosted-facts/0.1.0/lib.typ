// nutrition-label: US-style Nutrition Facts panels and per-100 g nutrition tables.
#let _dv = (fat: 78, sat: 20, chol: 300, sodium: 2300, carbs: 275, fiber: 28, sugars-added: 50, protein: 50)

#let _pct(key, amount) = {
  if key != none and key in _dv and amount != none { str(calc.round(amount / _dv.at(key) * 100)) + "%" } else { "" }
}

/// A US-style Nutrition Facts panel. Amounts are numbers in g or mg as labelled; % Daily Values use FDA reference amounts.
#let nutrition-label(
  servings: none, serving-size: none, calories: 0,
  fat: 0, sat: 0, trans: 0, chol: 0, sodium: 0, carbs: 0, fiber: 0, sugars: 0, protein: 0,
  extras: (), width: 6.4cm, font: ("Helvetica", "Arial"),
) = {
  set text(font: font, size: 8pt)
  set block(spacing: 4pt)
  set par(leading: 0.4em, spacing: 4pt)
  let thin = line(length: 100%, stroke: 0.4pt)
  let row(label, amount, unit, key: none, indent: 0pt, bold: true) = {
    grid(columns: (1fr, auto),
      pad(left: indent)[#if bold [*#label*] else [#label] #amount#unit],
      [*#_pct(key, amount)*])
    thin
  }
  box(width: width, stroke: 0.6pt, inset: 4pt)[
    #text(size: 22pt, weight: "black")[Nutrition Facts]
    #thin #if servings != none [#servings #if servings == 1 [serving] else [servings] per container \ ]
    #if serving-size != none { grid(columns: (1fr, auto), [*Serving size*], [*#serving-size*]) }
    #line(length: 100%, stroke: 6pt) #text(size: 7pt)[*Amount per serving*] \
    #grid(columns: (1fr, auto), align: (left + bottom, right + bottom), text(size: 16pt, weight: "black")[Calories], text(size: 26pt, weight: "black")[#calories])
    #line(length: 100%, stroke: 2.5pt) #align(right, text(size: 7pt)[*% Daily Value\**]) #thin #row("Total Fat", fat, "g", key: "fat")
    #row("Saturated Fat", sat, "g", key: "sat", indent: 1em, bold: false)
    #row([_Trans_ Fat], trans, "g", indent: 1em, bold: false)
    #row("Cholesterol", chol, "mg", key: "chol")
    #row("Sodium", sodium, "mg", key: "sodium")
    #row("Total Carbohydrate", carbs, "g", key: "carbs")
    #row("Dietary Fiber", fiber, "g", key: "fiber", indent: 1em, bold: false)
    #row("Total Sugars", sugars, "g", indent: 1em, bold: false)
    #row("Protein", protein, "g")
    #for (label, amount, unit, pct) in extras { grid(columns: (1fr, auto), [#label #amount#unit], [#pct]); thin }
    #line(length: 100%, stroke: 6pt)
    #text(size: 6pt)[\* The % Daily Value (DV) tells you how much a nutrient in a serving of food contributes to a daily diet. 2,000 calories a day is used for general nutrition advice.]
  ]
}

/// A per-100 g nutrition table (EU style) with an optional per-portion column. rows: array of (name, per100, perPortion).
#let nutrition-table(rows, per: "100 g", portion: none) = {
  let cols = if portion == none { (auto, auto) } else { (auto, auto, auto) }
  table(columns: cols, stroke: (x, y) => if y <= 1 { (top: 0.6pt) } else { none }, align: (left, right, right),
    [*Nutrition*], [*per #per*], ..if portion != none { ([*per #portion*],) },
    ..rows.map(r => if portion == none { (r.at(0), r.at(1)) } else { r }).flatten())
}

/// Daily energy needs with the Mifflin-St Jeor equation (kcal/day). sex: "female" or "male"; activity factor 1.2 to 1.9.
#let bmr(weight-kg, height-cm, age, sex) = 10 * weight-kg + 6.25 * height-cm - 5 * age + if sex == "male" { 5 } else { -161 }
#let tdee(weight-kg, height-cm, age, sex, activity: 1.375) = bmr(weight-kg, height-cm, age, sex) * activity
