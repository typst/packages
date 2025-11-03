/*
  File: text-contrast.typ
  Author: neuralpain
  Date Modified: 2025-01-06

  Description: Select the best color for contrast
  based on the background color of the element the
  text is placed on.
*/

#import "convert.typ": dec-to-rgb

/// Get optimal contrast color (black or white) to display text.
///
/// - bg_color (color): Background color the text is placed on.
/// -> color
#let get-contrast-color(bg_color) = {
  let hxa = dec-to-rgb(bg_color) // rgb-esque color array

  // Convert the hex color to RGB
  let r = hxa.at(0)
  let g = hxa.at(1)
  let b = hxa.at(2)

  // Calculate luminance (relative brightness)
  let R = if (r / 255) > 0.03928 { calc.pow(((r + 0.055) / 255), 2.4) } else { (r / 255) / 12.92 }
  let G = if (g / 255) > 0.03928 { calc.pow(((g + 0.055) / 255), 2.4) } else { (g / 255) / 12.92 }
  let B = if (b / 255) > 0.03928 { calc.pow(((b + 0.055) / 255), 2.4) } else { (b / 255) / 12.92 }
  let L = 0.2126 * R + 0.7152 * G + 0.0722 * B

  // Calculate contrast ratio with black and white
  let contrast-black = (L + 0.05) / (0 + 0.05)
  let contrast-white = (1 + 0.05) / (L + 0.05)

  // Determine the best text color based on contrast
  if contrast-black > contrast-white {
    return black
  } else {
    return white
  }
}
