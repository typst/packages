#let definitions = yaml("validate.yml")

#let inner-validate(definition, value) = {
  if definition.type == "any" {
    return
  }
  if str(type(value)) == definition.type {
    // Handle special cases for some types
    if definition.type == "string" {
      if definition.keys().contains("allowed") {
        if not definition.allowed.contains(value) {
          panic(
            "Argument `"
              + definition.name
              + "` should be either "
              + definition
                .allowed
                .map(it => "`" + it + "`")
                .join(", ", last: " or "),
          )
        }
      }
    } else if definition.type == "array" {
      for (index, v) in value.enumerate() {
        let def = definition.contains
        def.name = definition.name + "[" + str(index) + "]"
        inner-validate(def, v)
      }
    } else if definition.type == "dictionary" {
      for field in definition.fields {
        let (name, v) = field.pairs().first()
        if not value.keys().contains(name) {
          panic(
            "Argument `"
              + definition.name
              + "` does not contain key `"
              + name
              + "`!",
          )
        }
        let def = v
        def.name = definition.name + "." + name
        inner-validate(def, value.at(name))
      }
    }
  } else {
    panic(
      "Argument `"
        + definition.name
        + "` should be type `"
        + definition.type
        + "`, but was of type `"
        + type(value)
        + "`!"
        + if definition.keys().contains("guide") {
          " Formatting: " + definition.guide
        } else { "" },
    )
  }
}

#let validate(name, value) = {
  let definition = definitions.at(name)

  // Check if optional and none
  if definition.optional and value == none {
    return
  }

  definition.name = name
  inner-validate(definition, value)
}
