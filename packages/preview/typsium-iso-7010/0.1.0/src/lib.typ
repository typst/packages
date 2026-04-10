#let _validate-index(index)={
  if type(index) == str{
    return int(index.find(regex("\d+")))
  }else if type(index) == int{
    return index
  }
  return 1
}

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

#let fire-sign(
  icon,
  width:auto,
  height:auto,
  fit: "cover",
)={
  let index = calc.clamp(_validate-index(icon), 1, 19)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  image("resources/fire/F" + index + ".svg", height: height, width: width, alt: "fire protection sign", fit: fit)
}

#let emergency-sign(
  icon,
  width:auto,
  height:auto,
  fit: "cover",
)={
  let index = calc.clamp(_validate-index(icon), 1, 70)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  image("resources/emergency/E" + index + ".svg", height: height, width: width, alt: "emergency sign", fit: fit)
}

#let warning-sign(
  icon,
  width:auto,
  height:auto,
  fit: "cover",
)={
  let index = calc.clamp(_validate-index(icon), 1, 80)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  image("resources/warning/W" + index + ".svg", height: height, width: width, alt: "warning hazard sign", fit: fit)
}

#let prohibited-actions-sign(
  icon,
  width:auto,
  height:auto,
  fit: "cover",
)={
  let index = calc.clamp(_validate-index(icon), 1, 75)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  image("resources/prohibited/P" + index + ".svg", height: height, width: width, alt: "prohibited action sign", fit: fit)
}

#let mandatory-actions-sign(
  icon,
  width:auto,
  height:auto,
  fit: "cover",
)={
  let index = calc.clamp(_validate-index(icon), 1, 63)
  index = if index < 10 {"00" + str(index)}
    else if index < 100 {"0"  + str(index)}
  
  image("resources/mandatory/M" + index + ".svg", height: height, width: width, alt: "mandatory action sign", fit: fit)
}

#let fire-arrow(
  direction: 0,
  width:auto,
  height:auto,
  fit: "cover",
)={
  direction = _validate-direction(direction)
  
  let image-path = if(calc.even(direction)) {
    "resources/arrow/F-Arrow-horizontal.svg"
  } else {
    "resources/arrow/F-Arrow-diagonal.svg"
  }
  direction = int(direction/2) * 90
  rotate(direction * 1deg, image(image-path, height: height, width: width, alt: "fire arrow", fit: fit))
}

#let emergency-arrow(
  direction: 0,
  width:auto,
  height:auto,
  fit: "cover",
)={
  direction = _validate-direction(direction)
  
  let image-path = if(calc.even(direction)) {
    "resources/arrow/E-Arrow-horizontal.svg"
  } else {
    "resources/arrow/E-Arrow-diagonal.svg"
  }
  direction = int(direction/2) * 90
  rotate(direction * 1deg, image(image-path, height: height, width: width, alt: "emergency arrow", fit: fit))
}

#let iso-7010(
  icon,
  width:auto,
  height:auto,
  fit: "cover",
)={
  let category = lower(icon.at(0))
  let index = int(icon.slice(1))
  
  if category == "f" {fire-sign(index, width: width, height: height, fit: fit)}
    else if category == "w" {warning-sign(index, width: width, height: height, fit: fit)}
    else if category == "p" {prohibited-actions-sign(index, width: width, height: height, fit: fit)}
    else if category == "e" {emergency-sign(index, width: width, height: height, fit: fit)}
    else if category == "m" {mandatory-actions-sign(index, width: width, height: height, fit: fit)}
}