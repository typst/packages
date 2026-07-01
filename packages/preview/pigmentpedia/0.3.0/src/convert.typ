/*
  File: convert.typ
  Author: neuralpain
  Date Modified: 2025-01-06

  Description: Module for converting colors from
  HEX to decimal and RGB.
*/

/// Converts a color to `HEX` string.
///
/// - color (color): Color to convert.
/// -> str
#let color-to-hex(color) = {
  if type(color) == "color" {
    return str(color.to-hex()).trim("#")
  } else if type(color) == "string" {
    return str(color.trim("#"))
  }
}

/// Converts `HEX` pairs to decimal for `RGB`.
///
/// - hex-str (str): `HEX` string to convert.
/// -> int
#let hex-to-dec(hex-str) = {
  if type(hex-str) == "color" { return none } // skip color types
  let hex-str = upper(hex-str) // convert to uppercase for easier handling
  let decimal-value = 0
  let power = 0

  for hex-value in hex-str.rev() {
    // check if is an int within a string
    if hex-value in "0123456789" {
      decimal-value += int(hex-value) * calc.pow(16, power)
    } else if "A".to-unicode() <= hex-value.to-unicode() and hex-value.to-unicode() <= "F".to-unicode() {
      decimal-value += (hex-value.to-unicode() - "A".to-unicode() + 10) * calc.pow(16, power)
    }
    // increase power factor for next position
    power += 1
  }

  return decimal-value
}

/// Converts the decimal value of the color into `RGB`.
///
/// - color (color): Color to convert.
/// -> color
#let dec-to-rgb(color) = {
  let hxa = (0, 0, 0) // hex-rgb array
  let hxp-index = 0 // hex pair index count
  let rgb-index = 0 // hex-rgb array index
  let hxp-value = "" // hex pair value

  color = color-to-hex(color)

  for i in color {
    if hxp-index == 2 {
      hxa.at(rgb-index) = hex-to-dec(hxp-value) // add hex pair to current RGB index
      rgb-index += 1 // move to next channel R/G/B
      hxp-index = 0 // reset
      hxp-value = "" // reset
    } else {
      hxp-value += str(i) // collect HEX pairs
      hxp-index += 1 // next value in hex pair
    }
  }

  return hxa
}
