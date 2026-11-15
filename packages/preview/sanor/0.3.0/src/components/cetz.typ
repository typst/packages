#import "@preview/cetz:0.5.2" as cetz: draw
#import "component.typ"

/// CeTZ component constructor
/// 
/// Example usage:
/// ```typ 
/// #import components.cetz as cc 
/// #let new-cetz-component = cc.new("name", func)
/// ```
/// 
/// -> object
#let new(
  /// Default name of the component
  /// -> str
  name,
  /// The component's function
  /// -> function
  func,
  /// Named arguments of cases with their name as the key.
  /// -> dictionary
  ..defined-cases,
  /// Default hidden modifier that will apply when the component is in hidden case.
  /// -> function | case
  hidden: draw.hide.with(bounds: true),
) = (name: name, ..args) => component.new(
  name,
  func.with(name: name),
  hidden: hidden,
  ..defined-cases,
)(name: name, ..args)


#let content = new("c-content", draw.content)
#let circle = new("c-circle", draw.circle)
#let rect = new("c-rect", draw.rect)
#let bezier = new("c-bezier", draw.bezier)
#let bezier-through = new("c-bezier-through", draw.bezier-through)
#let rect-around = new("c-rect-around", draw.rect-around)
#let line = new("c-line", draw.line)
#let polygon = new("c-polygon", draw.polygon)
#let grid = new("c-grid", draw.grid)
#let arc = new("c-arc", draw.arc)
#let arc-through = new("c-arc-through", draw.arc-through)
#let circle-through = new("c-circle-through", draw.circle-through)
#let catmull = new("c-catmull", draw.catmull)
#let hobby = new("c-hobby", draw.hobby)
#let n-star = new("c-n-star", draw.n-star)
#let merge-path = new("c-merge-path", draw.merge-path)
#let compound-path = new("c-compound-path", draw.compound-path)
#let svg-path = new("c-svg-path", draw.svg-path)
#let boolean = new("c-boolean", draw.boolean)
#let group = new("c-group", draw.group)
#let intersections = new("c-intersection", draw.intersections)