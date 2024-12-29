#import "@preview/cetz:0.2.2": canvas
#import "@preview/tidy:0.3.0"

/// Draws a block circuit diagram
///
/// This function is also available at the package root
///
/// - body (none, array, element): A code block in which draw functions have been called
/// - length (length, ratio): Optional base unit
/// -> none
#let circuit(body, length: 2em) = {
  set text(font: "Source Sans 3")
  canvas(length: length, body)
}