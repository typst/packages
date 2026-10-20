// =====================================================
// COMBINATORICS VISUALIZATIONS - Object-Oriented
// =====================================================
// Creates geometry objects for combinatorics visualizations
// that can be rendered in blank-canvas.

// =====================================================
// PERMUTATION OBJECT
// =====================================================

/// Create a permutation data object that can be reused
/// across linear-perm and circular-perm visualizations.
///
/// Parameters:
/// - names: Array of item names/values to display (strings, numbers, or content)
/// - labels: Optional array of position labels (e.g., ("1st", "2nd", ...))
#let permutation(
  names,
  labels: none,
) = (
  type: "permutation",
  names: names,
  labels: labels,
)

// =====================================================
// LINEAR PERMUTATION OBJECT
// =====================================================

/// Create a linear permutation visualization object
///
/// Parameters:
/// - perm: A permutation object created with permutation()
/// - highlight: Optional indices to highlight
/// - origin: Position to place the visualization
/// - style: Optional style overrides
#let linear-perm(
  perm,
  highlight: (),
  origin: (0, 0),
  style: auto,
) = (
  type: "linear-perm",
  items: perm.names,
  labels: perm.labels,
  highlight: highlight,
  origin: origin,
  style: style,
)

// =====================================================
// CIRCULAR PERMUTATION OBJECT
// =====================================================

/// Create a circular permutation visualization object
///
/// Parameters:
/// - perm: A permutation object created with permutation()
/// - radius: Circle radius (default: 1.5)
/// - highlight: Optional indices to highlight
/// - show-arrows: Show direction arrows
/// - origin: Center position
/// - style: Optional style overrides
#let circular-perm(
  perm,
  radius: 1.5,
  highlight: (),
  show-arrows: false,
  origin: (0, 0),
  style: auto,
) = (
  type: "circular-perm",
  items: perm.names,
  labels: perm.labels,
  radius: radius,
  highlight: highlight,
  show-arrows: show-arrows,
  origin: origin,
  style: style,
)

// =====================================================
// BALLS AND BOXES OBJECT
// =====================================================

/// Create a balls-and-boxes visualization object
///
/// Parameters:
/// - n-balls: Number of balls
/// - n-boxes: Number of boxes
/// - distribution: Optional array showing how many balls in each box
/// - balls-identical: Are balls identical? (visual style)
/// - boxes-identical: Are boxes identical? (visual style)
/// - ball-labels: Optional labels for balls
/// - box-labels: Optional labels for boxes
/// - origin: Position to place the visualization
/// - style: Optional style overrides
#let balls-boxes(
  n-balls,
  n-boxes,
  distribution: none,
  balls-identical: false,
  boxes-identical: false,
  ball-labels: auto,
  box-labels: auto,
  origin: (0, 0),
  style: auto,
) = (
  type: "balls-boxes",
  n-balls: n-balls,
  n-boxes: n-boxes,
  distribution: distribution,
  balls-identical: balls-identical,
  boxes-identical: boxes-identical,
  ball-labels: ball-labels,
  box-labels: box-labels,
  origin: origin,
  style: style,
)

// =====================================================
// SUBSET VISUALIZATION OBJECT (Combinations)
// =====================================================

/// Create a subset/combination visualization object
///
/// Parameters:
/// - elements: Array of all elements
/// - subset: Array of indices to highlight as the subset
/// - set-label: Label for the full set
/// - subset-label: Label for the subset
/// - origin: Position
/// - style: Optional style overrides
#let subset-vis(
  elements,
  subset: (),
  set-label: none,
  subset-label: none,
  origin: (0, 0),
  style: auto,
) = (
  type: "subset-vis",
  elements: elements,
  subset: subset,
  set-label: set-label,
  subset-label: subset-label,
  origin: origin,
  style: style,
)

// =====================================================
// COUNTING TREE OBJECT
// =====================================================

/// Create a counting/decision tree visualization object
///
/// Parameters:
/// - levels: Array of arrays for each level's branches
///           e.g., (("A", "B"), ("1", "2", "3"))
/// - origin: Root position
/// - style: Optional style overrides
#let counting-tree(
  levels,
  origin: (0, 0),
  style: auto,
) = (
  type: "counting-tree",
  levels: levels,
  origin: origin,
  style: style,
)

// =====================================================
// PARTITION DIAGRAM OBJECT (Ferrers/Young)
// =====================================================

/// Create a partition visualization object (Ferrers diagram)
///
/// Parameters:
/// - partition: Array of part sizes (e.g., (3, 2, 1) for 3+2+1=6)
/// - origin: Position
/// - style: Optional style overrides
#let partition-vis(
  partition,
  origin: (0, 0),
  style: auto,
) = (
  type: "partition-vis",
  partition: partition,
  origin: origin,
  style: style,
)

// =====================================================
// PIGEONHOLE VISUALIZATION
// =====================================================

/// Create a pigeonhole principle visualization
///
/// Parameters:
/// - n-pigeons: Number of pigeons (items)
/// - n-holes: Number of holes (containers)
/// - origin: Position
/// - style: Optional style overrides
#let pigeonhole(
  n-pigeons,
  n-holes,
  origin: (0, 0),
  style: auto,
) = (
  type: "pigeonhole",
  n-pigeons: n-pigeons,
  n-holes: n-holes,
  origin: origin,
  style: style,
)

// =====================================================
// TYPE CHECKERS
// =====================================================

#let is-permutation(obj) = type(obj) == dictionary and obj.at("type", default: none) == "permutation"
#let is-linear-perm(obj) = type(obj) == dictionary and obj.at("type", default: none) == "linear-perm"
#let is-circular-perm(obj) = type(obj) == dictionary and obj.at("type", default: none) == "circular-perm"
#let is-balls-boxes(obj) = type(obj) == dictionary and obj.at("type", default: none) == "balls-boxes"
#let is-subset-vis(obj) = type(obj) == dictionary and obj.at("type", default: none) == "subset-vis"
#let is-counting-tree(obj) = type(obj) == dictionary and obj.at("type", default: none) == "counting-tree"
#let is-partition-vis(obj) = type(obj) == dictionary and obj.at("type", default: none) == "partition-vis"
#let is-pigeonhole(obj) = type(obj) == dictionary and obj.at("type", default: none) == "pigeonhole"

#let is-combi-obj(obj) = {
  (
    is-linear-perm(obj)
      or is-circular-perm(obj)
      or is-balls-boxes(obj)
      or is-subset-vis(obj)
      or is-counting-tree(obj)
      or is-partition-vis(obj)
      or is-pigeonhole(obj)
  )
}
