#import "@preview/cooklang:0.1.0": parse

// Read the cooklang recipe file and parse it to dictionary
#let recipe-cooklang = read("Neapolitan Pizza.cook")
#let recipe = parse(recipe-cooklang)

// Define formatting for ingredients and cookware
#let ingredient(body) = {
  text(fill: rgb(204, 85, 0))[*#body*]
}
#let cookware(body) = {
  text(fill: rgb(34, 139, 34))[*#body*]
}

// BEGIN CONTENT

#set align(center)

#title("Neapolitan Pizza")

Servings: #recipe.metadata.map.servings

#set align(left)

= Ingredients

// loop through ingredients and list them with quantities if available
#for ing in recipe.ingredients {
  if ing.quantity != none {
    [- #ing.quantity.value.value.value #ing.quantity.unit #ingredient[#ing.name]]
  } else {
    [- #ingredient[#ing.name]]
  }
}

= Cookware

// loop through cookware and list it
#for cw in recipe.cookware {
  [- #cookware[#cw.name]]
}

= Instructions

// loop through steps and format them, replacing ingredient and cookware references
#for step in recipe.sections.at(0).content {
  if step.type == "step" {
    let content = []
    for item in step.value.items {
      if item.type == "text" {
        content += [#item.value]
      } else if item.type == "ingredient" {
        content += [#ingredient[#recipe.ingredients.at(item.index).name]]
      } else if item.type == "cookware" {
        content += [#cookware[#recipe.cookware.at(item.index).name]]
      }
    }
    [+ #content]
  }
}
