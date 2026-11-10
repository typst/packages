/// Stack of small cubes on a grid, given as a list from back to front `3251`,
/// then from left to right (separated by commas). A color can be specified
/// at the beginning or the end. With the default colors using none:
/// front $->$ yellow, top $->$ green, right $->$ red. Alternatively, a list of
/// 3 colors can be provided with colors.
/// 
/// `z:0` for front view, `y:0, z:(0,-1)` for top view,
/// `x:0, z:(-1,0)` for right view -> content
#let pile(
  /// list of numbers corresponding to the heights back-to-front, left-to-right-> int | str | array | arguments
  ..a,
  /// Enables a random mode: automatically generates the stack (instead of positional arguments),
  /// with equal or decreasing heights from row to row -> boolean
  random: false,
  /// Width (number of slices along X) in random mode -> int
  width: 3,
  /// Depth (number of digits per slice along Z) in random mode -> int
  depth: 4,
  /// Maximum height (along Y) in random mode -> int
  height: 5,
  /// Seed of the pseudo-random generator for reproducible results:
  /// same seed $->$ same stack; change it to obtain another one -> int
  seed: 1,
  /// Display the level plan (numbered top view) -> boolean
  plan: false,
  /// Display the view labels on the grids -> boolean
  labels: false,
  /// Direction of the first coordinate, default (1,0) -> array
  x:(1,0),
  /// Direction of the second coordinate, default (0,1) -> array
  y:(0,1),
  /// Direction of the third coordinate, default (-0.5,-0.5) -> array
  z:(-.5,-.5),
  /// Stroke multiplier (from 1pt), default 60%, i.e. 0.6pt -> int | float | ratio
  thickness:60%,
  /// Lines in black, default false -> boolean | color
  border-stroke:false,
  /// Add a second view of the assembly from the "right" -> boolean
  side:false,
  /// How much to lighten when using a single color -> float | ratio | array
  light:20%,
  /// Changes the edge size of a base cube -> float | ratio
  draw-scale:.5,
  /// Allows the generated stack to be "exploded" to the right
  /// to make visualization by "slices" easier -> float | int
  x-spread:0,
  /// Allows the generated stack to be "exploded" upward
  /// to make visualization by "layers" easier -> float | int
  y-spread:0,
  /// Allows the generated stack to be "exploded" forward
  /// to make visualization by "slices" easier -> float | int
  z-spread:0,
  /// Provide a list of 3 colors for the three faces (left, right, top) -> array
  colors:(),
  /// Display three grids allowing the student to directly draw
  /// the front, top, and left views -> boolean
  grids:false,
  /// When set to true, display the associated solid's front, top,
  /// and left views on the grids -> boolean
  solution:false,
  /// Separation of the bottom grid (auto = automatically calculated) -> auto | int | float
  below-separation: auto,
  /// Separation of the left grid (auto = automatically calculated) -> auto | int | float
  left-separation: auto,
  /// Separation of the back grid (auto = automatically calculated) -> auto | int | float
  back-separation: auto,
  /// Allows different perspectives:
  /// - true = isometric representation,
  /// - 1 = tikz3d-fr view,
  /// - 2 = first ProfCollege view,
  /// - 3 = second ProfCollege view,
  /// - otherwise = default CeTZ view -> boolean | int
  iso:false,
  /// Spacing from the second view -> length | relative length | fraction
  space:2em,
  /// Allows "holes" (zero height) in the random stack starting from the second stack;
  /// the first stack always remains "full" (height >= 1 everywhere) -> boolean
  holes:false,
  /// Specific random mode:
  /// - 1 (double-min LCG by Gemini),
  /// - 2 and 4 (decreasing LCG inspired by ProfCollege by Claude),
  /// - 3 (suiji package) -> auto | int
  random-mode: auto,
  /// List of views to display among ("top", "front", "right") -> array
  views: ("dessus", "face", "droite"),
  /// Names of the displayed views among ("top", "front", "right") -> array
  views-names: ("Vue de dessus", "Vue de face", "Vue de droite"),
  /// Display axis markers (coordinates) on the ground -> boolean
  axes: false,
  /// Opacity of the cube faces (100% = opaque, 50% = semi-transparent) -> ratio
  opacity: 100%,
  /// Draw the footprint on the ground beneath the stack -> boolean
  shadow: false,
  /// Layout of the 2D grids: "3d" (projected around) or "cote-a-cote" (next to the 3D view) -> str
  disposition: "3d",
  /// Arguments to pass to the box(es) -> dictionary
  box-args:(),
) = {}

/// Construct of small cubes with mixed colors: each number corresponds to
/// the position in the color list (16 max: 1 to 9 and a to g).
/// "0" and "o" represent a hole, "x" uses the first color.
/// Cubes are given as a list of lists: from front to back using a number/string
/// such as `"5432a"`, then layer by layer `btt`, with lists ordered from left to right.
/// 
/// `z:0` for front view, `y:0, z:(0,-1)` for top view,
/// `x:0, z:(-1,0)` for right view -> content
#let building(
  /// list of list of numbers corresponding to the colors back-to-front, bottom to top, left-to-right-> array | arguments
  ..a,
  /// List of up to 16 colors -> array
  color-list:typst16,
  /// Direction of the first coordinate, default (1,0) -> array
  x:(1,0),
  /// Direction of the second coordinate, default (0,1) -> array
  y:(0,1),
  /// Direction of the third coordinate, default (-0.5,-0.5) -> array
  z:(-.5,-.5),
  /// Stroke multiplier (from 1pt), default 60%, i.e. 0.6pt -> int | float | ratio
  thickness:60%,
  /// Lines in black, default false -> boolean | color
  border-stroke:false,
  // Parameter for certain views _rev:false (if true, top to bottom) -> boolean
  _rev:false,
  // Parameter for the bottom view -> boolean
  _dessous:false,
  // Parameter for the back view -> boolean
  _back:false,
  /// How much to lighten when using a single color -> float | ratio | array
  light:20%,
  /// Changes the edge size of a base cube -> float | ratio
  draw-scale:.5,
  /// Allows different perspectives:
  /// - true = isometric representation,
  /// - 1 = tikz3d-fr view,
  /// - 2 = first ProfCollege view,
  /// - 3 = second ProfCollege view,
  /// - otherwise = default CeTZ view -> boolean | int
  iso:false,
  /// Text to place below the stack (for the views) -> str | content
  text:none,
  /// Allows the generated stack to be "exploded" to the right
  /// to make visualization by "slices" easier -> float | int
  x-spread:0,
  /// Allows the generated stack to be "exploded" upward
  /// to make visualization by "layers" easier -> float | int
  y-spread:0,
  /// Allows the generated stack to be "exploded" forward
  /// to make visualization by "slices" easier -> float | int
  z-spread:0,
  /// Arguments to pass to the box -> dictionary
  box-args:(),
) = {}

/// Function that sets the 3D viewing angle for a cetz.canvas using polar (θ) and azimuthal (φ) angles.
/// You have to pass it directly to the canvas, without forgetting to spread
///
/// -> dictionary
#let thetaphi(
  /// polar angle θ -> int | angle
  theta:70,
  /// azimuthal angle φ -> int | angle
  phi:110
) = {}

/// Function used to draw a 3D die.
///
/// Warning, using dice in a canvas Overwrites the transformation matrix!
///
///  -> content | function
#let dice(
  /// true if alone, false if already inside a canvas -> boolean
  standalone: true,
  /// Number of spots on the front face -> int
  front: 1,
  /// Number of spots on the top face -> int
  top: 2,
  /// Drawing scale -> int | float | ratio
  s: 1.0,
  /// Theta angle of the spherical coordinates -> int | float
  theta: 70,
  /// Phi angle of the spherical coordinates -> int | float
  phi: 110,
  /// "D" for right view or "G" for left view -> str
  vue: "D",
  /// Die color, light gray by default -> color
  color: rgb("d3d3d3"),
  /// Spot color -> color
  dot-color: black,
  /// Position of the die's origin -> array
  origin:(0,0,0),
  /// Additional arguments for the box -> dictionary
  box-args:(),
  /// Opacité des dés -> ratio
  opacity:100%,
) = {}

/// Random or non-random roll of $n$ dice. -> content
#let throws(
  /// Number of dice -> int
  n,
  /// List of rolls: none by default, otherwise a list of pairs
  /// (front face, top face) -> none | array
  list: none,
  /// Pseudo-random seed -> int
  seed: 42,
  /// Dice displayed "touching" each other -> boolean
  yams: false,
  /// Horizontal offset of the dice in the row when yams is enabled -> int | float
  yams-h:.1,
  /// Horizontal spacing between dice -> length
  espace-h: 5mm,
  /// Scale factor -> int | float | ratio
  s: 1.0,
  /// List of die colors -> array
  colors: (rgb("d3d3d3"),),
  /// Spot color -> color
  dot-color: black,
  /// Theta angle of the spherical coordinates -> int | float
  theta: 70,
  /// Phi angle of the spherical coordinates -> int | float
  phi: 110,
  /// "D" for right view or "G" for left view -> str
  vue: "D",
  /// Additional arguments for the box -> dictionary
  box-args:(),
  /// Opacité des dés -> ratio
  opacity:100%,
) = {}