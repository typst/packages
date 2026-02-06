/*
  File: convert.typ
  Author: neuralpain
  Date Modified: 2025-04-20

  Description: Module for converting colors from
  HEX to decimal and RGB.
*/

/// Convert a color value to `HEX` string.
///
/// - c (color): Color to convert.
/// -> str
#let color-to-hex(c) = {
  if type(c) == color {
    return str(c.to-hex()).trim("#")
  } else if type(c) == str {
    return str(c.trim("#"))
  }
}

/// Convert individual `HEX` channel pairs to decimal numbers representing `RGB`.
///
/// - hex-str (str): `HEX` string to convert.
/// -> int
#let hex-to-dec(hex-str) = {
  if type(hex-str) == color { return none } // skip color types
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
    power += 1  // increase power factor for next position
  }

  return decimal-value
}

/// Convert the decimal value of the color into `RGB`.
///
/// - color (color): Color to convert.
/// -> color
#let get-rgb-array(_color) = {
  let rgb-array = (0, 0, 0) // hex-rgb array
  let hex-pair-index = 0    // hex pair index count
  let rgb-index = 0         // hex-rgb array index
  let hex-pair-value = ""   // hex pair value

  let hex-color = color-to-hex(_color)

  for i in hex-color {
    if hex-pair-index == 2 {
      rgb-array.at(rgb-index) = hex-to-dec(hex-pair-value) // add hex pair to current RGB index
      rgb-index += 1        // move to next R/G/B channel
      hex-pair-index  = 0   // reset
      hex-pair-value  = ""  // reset
    } else {
      hex-pair-value += str(i)  // collect HEX pairs
      hex-pair-index += 1   // next value in hex pair
    }
  }

  return rgb-array
}
