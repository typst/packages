#import "@preview/cetz:0.5.2" as cetz: draw
#import "component.typ"

/// CeTZ component constructor
/// 
/// -> object
#let ccomp(
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


#let ccontent = ccomp("ccontent", draw.content)
#let ccircle = ccomp("ccircle", draw.circle)
#let crect = ccomp("crect", draw.rect)
#let cbezier = ccomp("cbezier", draw.bezier)
#let cbezier-through = ccomp("cbezier-through", draw.bezier-through)
#let crect-around = ccomp("crect-around", draw.rect-around)
#let cline = ccomp("cline", draw.line)
#let cpolygon = ccomp("cpolygon", draw.polygon)
#let cgrid = ccomp("cgrid", draw.grid)
#let carc = ccomp("carc", draw.arc)
#let carc-through = ccomp("carc-through", draw.arc-through)
#let ccircle-through = ccomp("ccircle-through", draw.circle-through)
#let ccatmull = ccomp("ccatmull", draw.catmull)
#let chobby = ccomp("chobby", draw.hobby)
#let cn-star = ccomp("cn-star", draw.n-star)
#let cmerge-path = ccomp("cmerge-path", draw.merge-path)
#let ccompound-path = ccomp("ccompound-path", draw.compound-path)
#let csvg-path = ccomp("csvg-path", draw.svg-path)
#let cboolean = ccomp("cboolean", draw.boolean)
