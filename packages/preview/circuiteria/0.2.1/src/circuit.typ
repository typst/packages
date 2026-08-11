#import "/src/cetz.typ": canvas
#import "@preview/tidy:0.3.0"

/// Draws a block circuit diagram
///
/// This function is also available at the package root
///
/// - body (none, array, element): A code block in which draw functions have been called
/// - length (length, ratio): Optional base unit
/// -> none
#let circuit(body, length: 2em) = {
  canvas(length: length, body)
}
