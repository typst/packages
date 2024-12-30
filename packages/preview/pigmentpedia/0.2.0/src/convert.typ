
// Convert hexadecimal color values to decimal for RGB
#let hex-to-dec(hex-str) = {
  if type(hex-str) == "color" { return none } // skip color types
  let hex-str = upper(hex-str) // convert to uppercase for easier handling
  let decimal-value = 0
  let power = 0

  for hex-value in hex-str.rev() {
    // check if is an int within a string
    let count = 0
    for digit in "0123456789" {
      if hex-value == digit {
        hex-value = count
        break
      }
      count += 1
    }

    if type(hex-value) == "integer" {
      decimal-value += int(hex-value) * calc.pow(16, power)
    } else if "A".to-unicode() <= hex-value.to-unicode() and hex-value.to-unicode() <= "F".to-unicode() {
      decimal-value += (hex-value.to-unicode() - "A".to-unicode() + 10) * calc.pow(16, power)
    } else {
      "Invalid hexadecimal character: " + hex-value
    }
    power += 1
  }

  return decimal-value
}

// Convert the decimal value of the color into RGB
#let dec-to-rgb(dec-value) = {
  let color = dec-value
  let hxa = (0, 0, 0)
  let hxi-count = 0
  let rgb-count = 0
  let hxv = ""

  if type(color) == "color" {
    color = str(color.to-hex()).trim("#")
  } else if type(color) == "string" {
    color = color.trim("#")
  }

  if type(color) == "integer" {
    color = str(color)
  }

  for i in color {
    if hxi-count == 2 {
      hxa.at(rgb-count) = hex-to-dec(hxv)
      // move to next color space R/G/B
      if rgb-count != 2 { rgb-count += 1 }
      hxi-count = 0 // reset
      hxv = "" // reset
    } else {
      hxv += str(i) // collect HEX pairs
      hxi-count += 1 // next value in hex pair
    }
  }

  return hxa
}
