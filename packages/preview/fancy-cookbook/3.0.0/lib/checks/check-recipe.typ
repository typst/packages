#import "./tools.typ": *
#import "../content/constant.typ" : column

#let check-ingredients(value) = {
  let expected-keys = (
    title: (str, content),
    items: (content,)
  )
  
  check-type("ingredients",value,(str, content, array))
  
  if type(value) == array {
    for elt in value {
      check-expected-keys("element in ingredients",elt, expected-keys)
    }
  }
}

#let check-instructions(value) = {
  let expected-keys = (
    title: (str, content),
    steps: (content,)
  )
  
  check-type("instructions",value,(str, content, array))
  
  if type(value) == array {
    for elt in value {
      check-expected-keys("element in instructions",elt, expected-keys)
    }
  }
}

#let check-image(value) = {
  if value != none {
    let expected-keys = (
      content: (content,),
      column: (str,)
    )
    
    check-type("image", value, (content, dictionary))
  
    if type(value) == dictionary {
      check-expected-keys("image", value, expected-keys)
      assert(value.column in column,
        message: "`image.column` must contain one of the two values \"ingredients\" or \"instructions\", use the dictionary column to avoid mistakes")
    }  
  }
}

#let check-notes(value) = {
  if value != none {
    let expected-keys = (
      content: (content,),
      column: (str,)
    )
    
    check-type("notes", value, (content, dictionary))
  
    if type(value) == dictionary {
      check-expected-keys("notes", value, expected-keys)
      assert(value.column in column,
        message: "`image.column` must contain one of the two values \"ingredients\" or \"instructions\", use the dictionary column to avoid mistakes")
    }  
  }
}

#let check-authors(value) = {
  if value != none {
    check-type("authors",value, (str, content, array))

    if type(value) == array {
      for elt in value {
        check-type("elt in authors",value, (str, content))
      }
    }
  }
}

#let check-tags(value) = {
  if value != none {
    check-type("tags",value, (array, str, content))

    if type(value) == array {
      for elt in value {
        check-type("elt in tags",elt, (str, content))
      }
    }
  }
}

#let check-change-palette(value) = {
  if value != none {
    check-type("palette", value, (dictionary,))
    let expected-keys = (
      dark: (color,),
      medium:  (color,),
      light:  (color,)
    )
  }
}



#let check-recipe(name,
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
  labl,
  tags,
  change-palette,
  sort-title
) = {
  check-type("name",name, (str,content))
  check-type("equipment",equipment, (str,content), with-none: true)
  check-ingredients(ingredients)
  check-instructions(instructions)
  check-type("description",description, (str,content), with-none: true)
  check-image(image)
  check-type("servings",servings, (int, str, content), with-none: true)
  check-type("prep-time", prep-time, (str, content), with-none: true)
  check-type("cook-time",name, (str, content), with-none: true)
  check-notes(notes)
  check-authors(authors)
  check-type("label",labl, (label,), with-none: true)
  check-tags(tags)
  check-change-palette(change-palette)
  check-type("sort-title",sort-title, (str, content), with-none: true)
}