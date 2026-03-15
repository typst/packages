#import "devices.typ": devices

// Access to the brands
#let brands() = devices.keys()
// Access to the models for a given brand
#let models(brand) = devices.at(brand).keys()

#let get-spec(brand, model) = {
  let brand-models = devices.at(brand, default: none)
  assert(
    brand-models != none,
    message: "Brand not found: "
      + brand
      + ". Available: "
      + brands().join(", "),
  )
  let spec = brand-models.at(model, default: none)
  assert(
    spec != none,
    message: "Model not found: "
      + model
      + " for brand "
      + brand
      + ". Available: "
      + models(brand).join(", "),
  )
  return spec
}


#let get-size(brand, model) = {
  let spec = get-spec(brand, model)
  return (spec.width, spec.height)
}

#let get-toolbar(brand, model) = {
  let spec = get-spec(brand, model)
  return spec.toolbar
}

#let setup(brand, model, toolbar-pos: none, base-margin: auto, body) = {
  // Device size
  let (w, h) = get-size(brand, model)

  // Margin
  // Create a margin variable with default values
  let m = if type(base-margin) == dictionary {
    (top: 0mm, bottom: 0mm, left: 0mm, right: 0mm) + base-margin
  } else {
    (
      top: base-margin,
      bottom: base-margin,
      left: base-margin,
      right: base-margin,
    )
  }

  // Update the margin with the toolbar width for the selected sides
  let toolbar-width = get-toolbar(brand, model)
  if toolbar-pos != none and toolbar-width != none {
    let positions = if type(toolbar-pos) == array {
      toolbar-pos
    } else {
      (toolbar-pos,)
    }
    for pos in positions {
      m.insert(str(pos), toolbar-width)
    }
  }

  // Page setup
  set page(width: w, height: h, margin: m)

  body
}

