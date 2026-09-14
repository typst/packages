#import "plugin.typ": komet-plugin



/// Generates contours from intersecting a function on a 2d rectangular mesh
/// with planes parallel to the z-plane at `z=level`.
///
/// The `z` argument can either be a 
/// - two-dimensional `m×n` array where `m` matches the number of y-values
///   and `n` matches the number of x-values. 
/// - or a function that takes an `x` and a `y` value and returns a 
///   corresponding `z` coordinate. 
/// 
/// The return value is an array with
/// 1. a contour for each level, 
/// 2. where each contour consists of an array of contour lines (there can be more 
///    than one disjoint curve per level), 
/// 3. where each contour line comprises a set of vertices `(x, y)` making up the curve. 
/// 
/// -> array
#let contour(

  /// A one-dimensional array of $x$ data coordinates. 
  /// -> array
  x, 
  
  /// A one-dimensional array of $y$ data coordinates. 
  /// -> array
  y, 

  /// Specifies the z coordinates (heights). 
  /// -> array | function
  z, 

  /// Specifies the levels to compute contours for. 
  /// -> int | float | array. 
  levels

) = {
  if type(z) == function {
    z = y.map(y => x.map(x => z(x, y)))
  }

  if type(levels) in (int, float) {
    levels = (levels,)
  }

  let data = cbor.encode((
    x.map(float),
    y.map(float),
    z.flatten().map(float),
    levels.map(float)
  ))
  cbor(komet-plugin.contour(data)).contours
}
