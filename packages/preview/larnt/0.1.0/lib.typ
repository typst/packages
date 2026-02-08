#let larnt = plugin("./larnt_typst_plugin.wasm")

/// The cone shape.
/// Can be warped with `outline()` to create outline cone.
///
/// ```example
/// #image(render(
///   eye: (1.2, -3., 2.),
///   center: (1.2, 0., 0.2),
///   height: 512.,
///   cone(1., (0., 0., 0.), (0., 0., 1.)),
///   outline(cone(1., (2.4, 0., 0.), (2.4, 0., 1.))),
/// ))
/// ```
///
/// -> shape
#let cone(
  /// The radius of the cone.
  /// -> float
  radius,
  /// The starting point of the cone's axis, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  v0,
  /// The ending point of the cone's axis, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  v1,
) = {
  assert(
    type(radius) == float and (v0, v1).all(v => type(v) == array and v.len() == 3 and v.all(i => type(i) == float)),
    message: "cone(radius, v0, v1) expects `radius` be a float and `v0`, `v1` be arrays of 3 floats",
  )
  return (
    Cone: (
      radius: radius,
      v0: v0,
      v1: v1,
    ),
  )
}

/// The cube shape.
///
/// ```example
/// #image(render(
///   eye: (1.25, 2.5, 2.0),
///   center: (1.25, -1., -0.6),
///   step: 0.01,
///   height: 460.,
///   cube((0., 0., 0.), (1., 1., 1.)),
///   cube((1.5, 0., 0.), (2.5, 1., 1.), texture: "Stripes", stripes: 24),
/// ))
/// ```
///
/// -> shape
#let cube(
  /// The minimum corner of the cube, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  min,
  /// The maximum corner of the cube, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  max,
  /// The texture pattern applied to the cube's surface. Can be either "Vanilla" or "Stripes".
  /// -> str
  texture: "Vanilla",
  /// The number of stripes to apply if the "Stripes" texture is selected.
  /// -> int
  stripes: 8,
) = {
  assert(
    (min, max).all(x => type(x) == array and x.len() == 3 and x.all(i => type(i) == float)),
    message: "cube(min, max) expects two array of 3 floats",
  )
  assert(texture in ("Vanilla", "Stripes"), message: "cube(...) texture must be one of Vanilla, Stripes")
  return (
    Cube: (
      min: min,
      max: max,
      texture: texture,
      stripes: stripes,
    ),
  )
}

/// The cylinder shape. Can be warped with `outline()` to create outline cylinder.
///
/// ```example
/// #image(render(
///   eye: (1.2, -3., 3.2),
///   center: (1.2, 0., .2),
///   height: 600.,
///   cylinder(0.7, (0., 0., 0.), (0., 0., 1.)),
///   outline(cylinder(0.7, (2.4, 0., 0.), (2.4, 0., 1.))),
/// ))
/// ```
///
/// -> shape
#let cylinder(
  /// The radius of the cylinder.
  /// -> float
  radius,
  /// The starting point of the cylinder's axis, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  v0,
  /// The ending point of the cylinder's axis, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  v1,
) = {
  assert(
    type(radius) == float and (v0, v1).all(v => type(v) == array and v.len() == 3 and v.all(i => type(i) == float)),
    message: "cylinder(radius, v0, v1) expects `radius` be a float and `v0`, `v1` be arrays of 3 floats",
  )
  return (
    Cylinder: (
      radius: radius,
      v0: v0,
      v1: v1,
    ),
  )
}

/// The sphere shape. Can be warped with `outline()` to create outline sphere.
///
/// ```example
/// #image(render(
///   height: 512.,
///   fovy: 30.,
///   sphere((0., 0., 0.), 1.0),
///   outline(sphere((0., -2.2, 0.), 1.0)),
///   sphere((2.2, 0., 0.), 1.0, texture: "RandomCircles", seed: 42),
///   sphere((0., 2.2, 0.), 1.0, texture: "RandomEquators", seed: 42),
///   sphere((-2.2, 0., 0.), 1.0, texture: "RandomEquators"),
/// ))
/// ```
/// -> shape
#let sphere(
  /// The center of the sphere, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  center,
  /// The radius of the sphere.
  /// -> float
  radius,
  /// The texture pattern applied to the sphere's surface. Can be one of "LatLng", "RandomEquators", or "RandomCircles".
  /// -> str
  texture: "LatLng",
  /// The seed for random texture generation.
  /// -> int
  seed: 0,
) = {
  assert(
    type(center) == array
      and center.len() == 3
      and center.all(i => type(i) == float)
      and type(radius) == float
      and type(texture) == str
      and type(seed) == int,
    message: "sphere(...) expects `center` be an array of 3 floats, `radius` be a float, `texture` be a string, and `seed` be an integer",
  )
  assert(
    texture in ("LatLng", "RandomEquators", "RandomCircles"),
    message: "sphere(...) texture must be one of LatLng, RandomEquators, RandomCircles",
  )
  return (
    Sphere: (
      center: center,
      radius: radius,
      texture: texture,
      seed: seed,
    ),
  )
}

/// The function-defined shape.
///
/// _Note that the function is sampled over a grid defined by `min`, `max`, and `n` due to typst wasm plugin limitations. Then the sampled values are intepolated with bilinear interpolation for rendering._
///
/// ```example
/// #image(render(
///   eye: (4., 3., 3.),
///   center: (0., 0., 1.5),
///   width: 1024.,
///   func((x, y) => 0.3 * (x * x + y * y), (-2., -2., -2.), (2., 2., 4.)),
/// ))
/// ```
///
/// -> shape
#let func(
  /// The function or pre-sampled 2d-array defining the shape's surface.
  /// -> function | array
  func,
  /// The minimum corner of the bounding box, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  min,
  /// The maximum corner of the bounding box, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  max,
  /// The direction of the shape's surface. Can be either "Below" or "Above".
  /// -> str
  direction: "Below",
  /// The texture pattern of the shape's surface. Can be one of "Grid", "Spiral", or "Swirl".
  ///
  /// ```example
  /// #let (min, max) = ((-1., -1., -1.), (1., 1., 1.))
  /// #image(render(
  ///   eye: (2.5, 0.4, 1.5),
  ///   func((x, y) => x * y, min, max, texture: "Spiral", step: .01),
  ///   func((x, y) => 0.0, min, max, step: .01),
  /// ))
  /// ```
  ///
  /// -> str
  texture: "Grid",
  /// The number of samples along each axis if `func` is a function. Higher number of samples results in more accurate rendering but longer rendering time.
  /// -> int
  n: 50,
  /// The step size for the intersect algorithm. Smaller step size results in more accurate occlusion rendering but longer rendering time.
  ///
  /// ```example
  /// #let f(x, y) = 0.7 * calc.sin(calc.sqrt(20 * (x * x + y * y)))
  /// #let (min, max) = ((-4., -4., -4.), (4., 4., 4.))
  /// #image(
  ///   render(
  ///     eye: (14., 5., 14.),
  ///     center: (0., 5., 0.),
  ///     height: 640.,
  ///     step: 0.01,
  ///     func(f, min, max, step: .5),
  ///     translate(func(f, min, max, step: 5.), (0., 10., 0.)),
  ///   ),
  /// )
  /// ```
  ///
  /// -> float
  step: 0.05,
) = {
  assert(
    (type(func) == function or type(func) == array)
      and type(min) == array
      and min.len() == 3
      and min.all(i => type(i) == float)
      and type(max) == array
      and max.len() == 3
      and max.all(i => type(i) == float)
      and type(direction) == str
      and type(texture) == str,
    message: "func(...) expects `func` be a function or array, `min` and `max` be arrays of 3 floats, `direction` and `texture` be strings",
  )
  assert(
    direction in ("Below", "Above"),
    message: "func(...) direction must be one of Below, Above",
  )
  assert(
    texture in ("Grid", "Spiral", "Swirl"),
    message: "func(...) texture must be one of Grid, Spiral, or Swirl",
  )
  assert(step > 0, message: "func(...) step must be a positive float")
  return (
    Function: (
      samples: if type(func) == function {
        range(n + 1).map(x => range(n + 1).map(y => {
          let x = min.at(0) + (max.at(0) - min.at(0)) * x / n
          let y = min.at(1) + (max.at(1) - min.at(1)) * y / n
          func(x, y)
        }))
      } else {
        func
      },
      bbox: (min, max),
      direction: direction,
      texture: texture,
      step: step,
    ),
  )
}

/// The triangle shape.
///
/// ```example
/// #image(render(
///   eye: (2., 2., 2.),
///   center: (0., 0., 0.),
///   height: 512.,
///   triangle((0., 1., 0.), (1., 0., 0.), (0., 0., 0.)),
///   triangle((0., 1., 0.), (1., 0., 0.), (1., 1., 0.)),
/// ))
/// ```
///
/// -> shape
#let triangle(
  /// The first vertex of the triangle, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  v1,
  /// The second vertex of the triangle, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  v2,
  /// The third vertex of the triangle, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  v3,
) = {
  assert(
    (v1, v2, v3).all(v => type(v) == array and v.len() == 3 and v.all(i => type(i) == float)),
    message: "triangle(v1, v2, v3) expects three arrays of 3 floats",
  )
  return (
    Triangle: (
      v1: v1,
      v2: v2,
      v3: v3,
    ),
  )
}

/// The mesh shape composed of triangles.
///
/// ```example
/// #let (n, r, h) = (8, 1.5, 2.0)
/// #let trs = (
///   (range(0, 360, step: int(360 / n))
///   .map(x => x * 1deg) + (0,))
///   .windows(2).map(x => {
///   let (a, b) = x
///   triangle(
///   (calc.cos(a) * r, calc.sin(a) * r, 0.),
///   (0., 0., h),
///   (calc.cos(b) * r, calc.sin(b) * r, 0.),
///   )
/// }))
/// #image(render(
///   step: 0.01,
///   fovy: 30.,
///   rotate(mesh(trs), (0., 1., 0.), 1.2),
/// ))
/// ```
///
/// -> shape
#let mesh(
  /// An array of triangle shapes.
  /// -> array
  triangles,
) = {
  assert(
    type(triangles) == array
      and triangles.all(t => (
        type(t) == dictionary and "Triangle" in t
      )),
    message: "mesh(triangles) expects an array of triangles",
  )
  return (
    Mesh: triangles,
  )
}

/// The outline wrapper for shapes. Can be used to create outline shapes like outline cone, outline cylinder, outline sphere.
///
/// ```example
/// #let (co, cy, sp) = (
///   cone(.5, (0., 0., 0.), (0., 0., 1.)),
///   cylinder(.5, (0., 0., 0.), (0., 0., 1.)),
///   sphere((0., 0., 0.5), .5),
/// )
/// #image(render(
///   center: (1., 2., 0.),
///   step: 0.01,
///   translate(co, (0., 0., 0.)),
///   translate(cy, (0., 2., 0.)),
///   translate(sp, (0., 4., 0.)),
///   translate(outline(co), (2., 0., 0.)),
///   translate(outline(cy), (2., 2., 0.)),
///   translate(outline(sp), (2., 4., 0.)),
/// ))
/// ```
///
/// -> shape
#let outline(
  /// The shape to be outlined. Must be a cone, cylinder, or sphere.
  /// -> shape
  shape,
) = {
  assert(
    type(shape) == dictionary and ("Cone", "Cylinder", "Sphere").any(s => s in shape),
    message: "outline(shape) expects cone, cylinder, or sphere shape",
  )
  return (
    Outline: shape,
  )
}

/// The difference operation for shapes.
/// Can be used to create complex shapes by subtracting multiple shapes from a base shape.
///
/// ```example
/// #image(render(
///   eye: (3., 2., 2.),
///   center: (0., 0.1, 0.),
///   step: 0.05,
///   fovy: 30.,
///   difference(
///     cube((0., 0., 0.), (1., 1., 1.), texture: "Stripes", stripes: 15),
///     sphere((1., 1., 0.5), 0.5),
///     sphere((0., 1., 0.5), 0.5),
///     sphere((0., 0., 0.5), 0.5),
///     sphere((1., 0., 0.5), 0.5),
///   ),
/// ))
/// ```
///
/// -> shape
#let difference(
  /// The shapes to be subtracted.
  /// The first shape is the base shape, and the subsequent shapes are subtracted from it.
  /// At least two shapes are required.
  /// -> shape
  ..shapes,
) = {
  let shapes = shapes.pos()
  assert(
    shapes.len() >= 2 and shapes.all(s => type(s) == dictionary),
    message: "difference(...) expects two or more shape arguments",
  )
  return (
    Difference: shapes,
  )
}

/// The intersection operation for shapes.
/// Can be used to create complex shapes by intersecting multiple shapes.
///
/// ```example
/// #image(render(
///   eye: (3., 2., 2.),
///   center: (0., 0., 0.5),
///   step: 0.05,
///   fovy: 20.,
///   intersection(
///     sphere((0., 0., 0.5), 0.6),
///     cube((-0.5, -0.5, 0.), (.5, 0.5, 1.0), texture: "Stripes", stripes: 32),
///   ),
/// ))
/// ```
///
/// -> shape
#let intersection(
  /// The shapes to be intersected.
  /// At least two shapes are required.
  /// -> shape
  ..shapes,
) = {
  let shapes = shapes.pos()
  assert(
    shapes.len() >= 2 and shapes.all(s => type(s) == dictionary),
    message: "intersection(...) expects two or more shape arguments",
  )
  return (
    Intersection: shapes,
  )
}

/// Translates a shape by a given vector.
///
/// -> shape
#let translate(
  /// The shape to be translated.
  /// -> shape
  shape,
  /// The translation vector, given as an array of three floats representing the x, y, and z components.
  /// -> array
  v,
) = {
  assert(
    type(shape) == dictionary and type(v) == array and v.len() == 3 and v.all(i => type(i) == float),
    message: "translate(shape, v) expects a shape and an array of 3 floats",
  )
  return (
    Transformation: (
      shape: shape,
      matrix: (Translate: (v: v)),
    ),
  )
}

/// Rotates a shape around a given axis by a specified angle.
///
/// -> shape
#let rotate(
  /// The shape to be rotated.
  /// -> shape
  shape,
  /// The rotation axis, given as an array of three floats representing the x, y, and z components.
  /// -> array
  v,
  /// The rotation angle in radians.
  /// -> float
  a,
) = {
  assert(
    type(shape) == dictionary
      and type(v) == array
      and v.len() == 3
      and v.all(i => type(i) == float)
      and type(a) == float,
    message: "rotate(shape, v, a) expects a shape, an array of 3 floats, and a float",
  )
  return (
    Transformation: (
      shape: shape,
      matrix: (
        Rotate: (
          v: v,
          a: a,
        ),
      ),
    ),
  )
}

/// Scales a shape by given factors along each axis.
///
/// -> shape
#let scale(
  /// The shape to be scaled.
  /// -> shape
  shape,
  /// The scaling factors along the x, y, and z axes, given as an array of three floats.
  /// -> array
  v,
) = {
  assert(
    type(shape) == dictionary and type(v) == array and v.len() == 3 and v.all(i => type(i) == float),
    message: "scale(shape, v) expects a shape and an array of 3 floats",
  )
  return (
    Transformation: (
      shape: shape,
      matrix: (Scale: (v: v)),
    ),
  )
}

/// Renders a 3D scene defined by the given shapes from a specified camera viewpoint.
/// Returns the rendered SVG as bytes.
///
/// ```example
/// #image(render(
///  eye: (2., 7., 5.),
///  center: (1.5, 2., 0.),
///  step: 0.01,
///  cube((0., 0., 0.), (1., 1., 1.)),
///  cube((1.5, 0., 0.), (2.5, 1., 1.), texture: "Stripes", stripes: 8),
///  sphere((0.5, 2., .5), 0.5),
///  sphere((2., 2., .5), 0.5, texture: "RandomCircles"),
///  sphere((0.5, 3.5, .5), 0.5, texture: "RandomEquators"),
///  outline(sphere((2., 3.5, .5), 0.5)),
///  cone(0.5, (-1., 0.5, 0.), (-1., 0.5, 1.)),
///  translate(outline(cone(0.5, (0., 0., 0.), (0., 0., 1.))), (-1., 2.0, 0.)),
///  cylinder(0.5, (3.5, 0.5, 0.), (3.5, 0.5, 1.)),
///  translate(outline(cylinder(0.5, (0., 0., 0.), (0., 0., 1.))), (3.5, 2.0, 0.)),
/// ))
/// ```
///
/// -> bytes
#let render(
  /// The position of the camera in 3D space, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  eye: (5.0, 5.0, 5.0),
  /// The point in 3D space that the camera is looking at, given as an array of three floats representing the x, y, and z coordinates.
  /// -> array
  center: (0.0, 0.0, 0.0),
  /// The up direction for the camera, given as an array of three floats.
  /// -> array
  up: (0.0, 0.0, 1.0),
  /// The width of the output image.
  /// -> float
  width: 720.0,
  /// The height of the output image.
  /// -> float
  height: 720.0,
  /// Field of view of the camera.
  /// -> float
  fovy: 50.0,
  /// The near clipping plane distance.
  /// -> float
  near: 0.1,
  /// The far clipping plane distance.
  /// -> float
  far: 100.0,
  /// The step size for the algorithm. Smaller step size results in more accurate rendering but longer rendering time.
  /// -> float
  step: 0.1,
  /// The 3D shapes to be rendered in the scene.
  /// -> shape
  ..shapes,
) = {
  larnt.render(
    cbor.encode((
      eye: eye,
      center: center,
      up: up,
      width: width,
      height: height,
      fovy: fovy,
      near: near,
      far: far,
      step: step,
    )),
    cbor.encode(shapes.pos()),
  )
}
