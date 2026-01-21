#import "diagram.typ": diagram
#import "../plot/rect.typ": rect

#import "../typing.typ": set-diagram


/// Creates a color bar using the color information of a colored plot instance 
/// like @scatter or @colormesh. 
/// 
/// This generates a new (usually slim) diagram with a filled gradient 
/// according to the color map used in the plot, appropriate ticks, and 
/// optionally a label. This diagram can be configured through general `set`
/// rules on @diagram and through additional arguments passed through 
/// @colorbar.args. 
/// 
/// ```example
/// #show: lq.set-diagram(height: 3.5cm, width: 4cm)
/// 
/// #let mesh = lq.colormesh(
///   lq.linspace(-0.3, 1.3),
///   lq.linspace(-0.3, 1.3),
///   (x, y) => x * y,
///   map: gradient.linear(..color.map.icefire).sharp(9)
/// )
/// 
/// #lq.diagram(
///   mesh
/// )
/// #lq.colorbar(mesh, thickness: 2mm)
/// ```
#let colorbar(

  /// A plot instance that uses color-coding, e.g., @scatter, @colormesh, @contour, and @quiver. 
  /// -> plot
  plot,


  /// How to orient the colorbar. 
  /// -> "vertical" | "horizontal"
  orientation: "vertical",

  /// The thickness of the colorbar. 
  /// -> length
  thickness: 3mm,

  /// A label to place on the axis. 
  /// -> content
  label: none,

  /// Additional arguments to pass to @diagram. 
  /// -> any
  ..args

) = {
  let cinfo = plot.cinfo
  
  let grad = if orientation == "vertical" {
    rect(
      0%, cinfo.min, 
      width: 100%, 
      height: cinfo.max - cinfo.min, 
      fill: gradient.linear(
        ..cinfo.colormap.stops(), 
        angle: 90deg
      )
    )
  } else if orientation == "horizontal" {
    rect(
      cinfo.min, 0%,
      height: 100%, 
      width: cinfo.max - cinfo.min, 
      fill: gradient.linear(
        ..cinfo.colormap.stops(), 
        angle: 0deg
      )
    )
  }

  
  show: set-diagram(
    grid: none,
    margin: 0%,
  )

  let preset-args = (:)
  if orientation == "vertical" {
    preset-args = (
      width: thickness,
      xaxis: (ticks: none),
      yaxis: (position: right, mirror: (:)),
      yscale: cinfo.norm,
      ylabel: label
    )
  } else if orientation == "horizontal" {
    preset-args = (
      height: thickness,
      yaxis: (ticks: none),
      xaxis: (position: bottom, mirror: (:)),
      xscale: cinfo.norm,
      xlabel: label
    )
  } else {
    assert(false, message: "Unexpected orientation \"" + orientation + "\", possible values are \"horizontal\" and \"vertical\"")
  }

  

  diagram(
    ..preset-args,
    ..args,
    grad
  )
}