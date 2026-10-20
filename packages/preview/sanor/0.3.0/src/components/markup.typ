#import "component.typ"

/// Markup component constructor
/// 
/// Example usage:
/// ```typ
/// #import components.markup as mc 
/// #let new-markup-component = mc.new("name", func) 
/// ```
/// 
/// -> object
#let new(
  /// Default name for the component
  /// -> str
  name,
  /// Function to create the component
  /// -> function
  func,
  /// Modifier to apply on the component in hidden case
  /// -> case | function
  hidden: component.case(hide),
  /// Keyword arguments of cases with their name as the key.
  /// -> arguments
  ..defined-cases,
) = component.new(name, func, hidden: hidden, ..defined-cases)

// Usage:
// ```example
// #let my-rect = mc.rect.with(
//   defined-cases: (yellow: case(fill: yellow)),
//   radius: 0.5em,
//   inset: 0.5em,
// )
// #my-rect(tag, name: "r1")[A rounded rectangle]
// ```
#let rect = new("rect", std.rect)
#let circle = new("circle", std.circle)
#let ellipse = new("ellipse", std.ellipse)
#let curve = new("curve", std.curve)
#let line = new("line", line)
#let block = new("block", std.block)
#let polygon = new("polygon", std.polygon)
#let box = new("block", std.box)
#let text = new("text", std.text)
#let equation = new("equation", std.math.equation)
#let table = new("table", std.table)
#let grid = new("grid", std.grid)
#let grid-cell = new("grid-cell", std.grid.cell)
#let table-cell = new("table-cell", std.table.cell)
#let image = new("image", std.image)
#let figure = new("figure", std.figure)
