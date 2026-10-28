#import "../colors/palettes.typ": style, palette-grey
#import "../colors/colors.typ": page-palette, fill-ingredients, ingredient-group-color, style-state, set-palette
#import "../assets/fonts.typ": fonts-state
#import "../assets/icons.typ": make-icons
#import "../i18n/i18n.typ": translate
#import "../i18n/translations.typ": i18n-words
#import "constant.typ": column
#import "../checks/check-recipe.typ" : check-recipe

// use a constant to avoid typing errors
#let recipe-meta-name = "recipe"




#let format-authors(authors) = {
  if authors.len() == 1 {
    authors.at(0)
  } else if authors.len() == 2 {
    authors.at(0) + " " + context translate(i18n-words.author_and) + " " + authors.at(1)
  } else {
    let all_but_last = authors.slice(0, authors.len() - 1).join(", ")
    let last = authors.at(authors.len() - 1)
    all_but_last + ", " + context translate(i18n-words.author_and) + " " + last
  }
}

#let recipe(
  name,
  equipment: none,
  ingredients: [],
  instructions: [],
  description: none,
  image: none,
  servings: none,
  prep-time: none,
  cook-time: none,
  notes: none,
  authors: none,
  label: none,
  tags: (),
  change-palette: none,
  sort-title: none
) = context {

  check-recipe(
    name,
    equipment,
    ingredients,
    instructions,
    description,
    image,
    servings,
    prep-time,
    cook-time,
    notes,
    authors,
    label,
    tags,
    change-palette,
    sort-title
  )


  // 1. Header Section
  let head = heading(level: 2, name)
  if label != none {
    [#head #label]     // on attache le label au heading
  } else {
    head
  }

  if change-palette != none {
    set-palette(change-palette)
  }

  metadata((kind: recipe-meta-name, title: name, tags: tags, location: here(), page: here().position().page, sort-title: sort-title))
  
  // Where we get the color palette
  let current-palette = page-palette(here().page())

  // Description & Meta row
  grid(
    columns: (1fr, auto),
    align(start + horizon, {
      if description != none {
        text(font: fonts-state.get().body, style: "italic",  description)
      }
    }),
    align(end + horizon, {
      let colored-icons = make-icons(current-palette.dark)
      set text(font: fonts-state.get().header, size: 0.9em, fill: black)
      let meta = ()
      if servings != none { meta.push([#colored-icons.yield #h(0.3em) #servings]) }
      if prep-time != none { meta.push([#colored-icons.time #h(0.3em) #prep-time]) }
      if cook-time != none { meta.push([#colored-icons.fire #h(0.3em) #cook-time]) }
      if meta.len() > 0 {
        meta.join(h(1.5em))
      }
    })
  )
  
  v(0.1em)
  line(length: 100%, stroke: 0.5pt + current-palette.medium)
  v(1em)

  // to work with one image format when it can be a content or a dictionary
  let recipe-image = none
  if image != none {
    if type(image) == content {
      recipe-image = (column: column.ingredients, content: image)
    } else {
      recipe-image = image
    }
  }

  // to work with one notes format when it can be a content or a dictionary
  let recipe-notes = none
  if notes != none {
    if type(notes) == content {
      recipe-notes = (column: column.ingredients, content: notes)
    } else {
      recipe-notes = notes
    }
  }

  let ingredients-column = {
    
    if recipe-image != none and recipe-image.column == column.ingredients { 
      block(width: 100%, height: auto, clip: true, radius: 0.4em, recipe-image.content)
      v(0.5em)
    }
    let style = style-state.get()

    // equipment
    if equipment != none {
      block(
        fill: white,
        inset: 1.2em,
        radius: 4pt,
        width: 100%,
        stroke: 0.5pt + current-palette.medium,
      )[
        #text(font: fonts-state.get().header, weight: "bold", size: 1.1em, translate(i18n-words.equipment))
        
        #set list(
          marker: box(
            height: 0.8em, width: 0.8em,
            stroke: 1pt + current-palette.dark,
            radius: 2pt,
            baseline: 20%,
          ),
          spacing: 1.5em,
          body-indent: 0.8em
        )
        
        #v(0.8em)
        #set text(size: 0.95em)
        #equipment        
      ]
    }

    

    block(
      fill: fill-ingredients(style, current-palette),
      inset: 1.2em,
      radius: 4pt,
      width: 100%,
      stroke: 0.5pt + current-palette.medium,
    )[
      #text(font: fonts-state.get().header, weight: "bold", size: 1.1em, translate(i18n-words.ingredients))
      
      #set list(
        marker: box(
          height: 0.8em, width: 0.8em,
          stroke: 1pt + current-palette.dark,
          radius: 2pt,
          baseline: 20%,
        ),
        spacing: 1.5em,
        body-indent: 0.8em
      )
      
      #v(0.8em)
      #set text(size: 0.95em)

      #if type(ingredients) == content {
          ingredients
      } else {
        // to know if ingredients is a list of groups of ingredients or a content
        let is-grouped = ingredients.len() > 0 and type(ingredients.first()) == dictionary and "items" in ingredients.first()
      
        if is-grouped {
          for group in ingredients {
            block(breakable: false, {
              // Titre du groupe
              text(font: fonts-state.get().header, weight: "bold", size: 1.1em, fill: ingredient-group-color(style, current-palette), group.at("title", default: ""))
              v(0.4em)
              group.at("items")       
            })
            v(0.4em) // space between groups
          }
        }
      }          
    ]
    // ---- Authors
    if authors != none {
      v(0.5em)
      block(breakable: false, {
    
        let is-multiple = type(authors) == array and authors.len() > 1
    
        let label = if is-multiple {
          translate(i18n-words.authors)
        } else {
          translate(i18n-words.author)
        }
    
        text(
          font: fonts-state.get().header,
          size: 0.9em,
          weight: "bold",
          fill: current-palette.dark,
          label
        )
    
        v(0.1em)
    
        if type(authors) == array {
          text(weight: "bold", size: 0.9em, authors.join(", "))
        } else {
          text(weight: "bold", size: 0.9em, authors)
        }
      })
    }
    

    // ---- notes
    if recipe-notes != none and recipe-notes.column == column.ingredients {
      v(0.5em)
      block(breakable: false, {
        text(font: fonts-state.get().header, size: 0.9em, weight: "bold", fill: current-palette.dark, translate(i18n-words.notes))
        v(0.1em)
        text(style: "italic", size: 0.9em, fill: palette-grey.dark, recipe-notes.content)
      })
    }
  }

  let instructions-column = {
    if recipe-image != none and recipe-image.column == column.instructions { 
      align(center, {
        block(width: 100%, height: auto, clip: true, radius: 0.4em, recipe-image.content)
        v(0.5em)
      })
    }
    
    text(font: fonts-state.get().header, weight: "bold", size: 1.1em, translate(i18n-words.preparation))
    v(1em)
    
    counter("recipe-step").update(0)
    
    set enum(
      numbering: n => context {
        counter("recipe-step").step()
        text(font: fonts-state.get().header, size: 1.2em, weight: "bold", fill: current-palette.dark,
          box(inset: (right: 0.5em), context numbering(translate(i18n-words.step-numbering),counter("recipe-step").get().at(0)))
        )
      }
    )
    set par(leading: 1em, justify: true)
    
    show enum.item: it => {
      pad(bottom: 0.6em, it)
    }
  
    // // to know if instructions is a list of groups of instructions or a content
    let is-grouped = (
      type(instructions) == array
      and instructions.len() > 0
      and type(instructions.first()) == dictionary
      and "steps" in instructions.first()
    )
  
    if is-grouped {
      for section in instructions {
        block(breakable: false, {
          // section title
          text(font: fonts-state.get().header, weight: "bold", size: 1.2em, fill: current-palette.dark,
            section.at("title", default: ""))
          v(0.5em)
          section.at("steps", default: [])
        })
        v(0.6em)
      }
    } else {
      instructions
    }

    // ---- notes secondary
    if recipe-notes != none and recipe-notes.column == column.instructions {
      v(0.5em)
      block(breakable: false, {
        text(font: fonts-state.get().header, size: 0.9em, weight: "bold", fill: current-palette.dark, translate(i18n-words.notes))
        v(0.1em)
        text(style: "italic", size: 0.9em, fill: palette-grey.dark, recipe-notes.content)
      })
    }
  }
   
  grid(
    columns: (35%, 1fr),
    gutter: 2.5em,
    
    // -- Ingredients Column: Ingredients --
    ingredients-column,

    // -- Instruction Column: Instructions --    
    instructions-column
  )
}