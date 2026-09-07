#let _validate-index(index)={
  if type(index) == str{
    return int(index.find(regex("\d+")))
  }else if type(index) == int{
    return index
  }
  return 1
}

#let direction-to-string=(
  "left",
  "bottom left",
  "bottom right",
  "right",
  "top right",
  "top",
  "top left",
)
#let _validate-direction(direction)={
  return if type(direction) == str{
    if direction == "left"{0}
      else if direction == "bottom-left" or direction == "lower-left"{1}
      else if direction == "bottom" or direction == "down"{2}
      else if direction == "bottom-right" or direction == "lower-right"{3}
      else if direction == "right"{4}
      else if direction == "top-right" or direction == "upper-right"{5}
      else if direction == "top" or direction == "up"{6}
      else if direction == "top-left" or direction == "upper-left"{7}
      else {0}
  } else if type(direction) == int{
    direction
  } else{
    0
  }
}
#let get-language-index(lang)={
  if lang == "en"{0}
  else if lang == "de"{1}
  else{0}
}

#let get-name(index) = {
  let lang-index = get-language-index(text.lang)
  let data = csv("resources/loca.tsv", delimiter:"\t", row-type: dictionary)
  return data.at(lang-index).at(index, default:"")
}

#let fire-sign(
  icon,
  inset:2.5%,
  ..args
)={
  let index = calc.clamp(_validate-index(icon), 1, 19)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  context{
    box(image("resources/fire/F" + index + ".svg", alt: get-name("F" + index), ..args), inset:inset)
  }
}

#let emergency-sign(
  icon,
  inset:2.5%,
  ..args
)={
  let index = calc.clamp(_validate-index(icon), 1, 76)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  context{
    box(image("resources/emergency/E" + index + ".svg", alt: get-name("E" + index), ..args), inset:inset)
  }
}

#let warning-sign(
  icon,
  ..args
)={
  let index = calc.clamp(_validate-index(icon), 1, 89)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  context{
    image("resources/warning/W" + index + ".svg", alt: get-name("W" + index), ..args)
  }
}

#let prohibited-actions-sign(
  icon,
  ..args
)={
  let index = calc.clamp(_validate-index(icon), 1, 81)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  context{
    image("resources/prohibited/P" + index + ".svg", alt: get-name("P" + index), ..args)
  }
  // image("resources/prohibited/P" + index + ".svg", height: height, width: width, alt: "prohibited action sign", fit: fit)
}

#let mandatory-actions-sign(
  icon,
  ..args
)={
  let index = calc.clamp(_validate-index(icon), 1, 72)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  context{
    image("resources/mandatory/M" + index + ".svg", alt: get-name("M" + index), ..args)
  }
}

#let fire-arrow(
  direction: 0,
  inset:2.5%,
  ..args
)={
  direction = _validate-direction(direction)
  let direction-name = direction-to-string.at(direction)
  
  let image-path = if(calc.even(direction)) {
    "resources/arrow/F-Arrow-horizontal.svg"
  } else {
    "resources/arrow/F-Arrow-diagonal.svg"
  }
  direction = int(direction/2) * 90deg
  box(rotate(direction, image(image-path, alt: "arrow pointing at " + direction-name + ", dangerous condition", ..args)), inset:inset)
}

#let emergency-arrow(
  direction: 0,
  inset:2.5%,
  ..args
)={
  direction = _validate-direction(direction)
  let direction-name = direction-to-string.at(direction)
  let image-path = if(calc.even(direction)) {
    "resources/arrow/E-Arrow-horizontal.svg"
  } else {
    "resources/arrow/E-Arrow-diagonal.svg"
  }
  direction = int(direction/2) * 90deg
  box(rotate(direction, image(image-path, alt: "arrow pointing at " + direction-name + ", safe condition", ..args)), inset:inset)
}

#let iso-7010(
  icon,
  inset:2.5%,
  ..args
)={
  let category = lower(icon.at(0))
  let index = int(icon.slice(1))
  
  if category == "f" {fire-sign(index, inset:inset, ..args)}
  else if category == "w" {warning-sign(index, ..args)}
  else if category == "p" {prohibited-actions-sign(index,  ..args)}
  else if category == "e" {emergency-sign(index, inset:inset,  ..args)}
  else if category == "m" {mandatory-actions-sign(index, ..args)}
}

#let iso-3864-colors = (
  signal-yellow: rgb("#F9A900"),
  signal-red: rgb("#9B2423"),
  signal-blue: rgb("#005387"),
  signal-green: rgb("#237F52"),
  signal-white: rgb("#ECECE7"),
  signal-black: rgb("#2B2B2C"),
)
