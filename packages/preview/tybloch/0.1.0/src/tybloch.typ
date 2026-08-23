#import "utils.typ": cartesian-to-spherical, spherical-to-cartesian
#import "draw.typ": _draw-bloch


/// Draws a Bloch sphere from the #math.theta and #math.phi angles. The magnitude is 1 by default.
///
/// *Example*
///
/// ```example
/// #import tybloch: bloch-from-spherical
///
/// #bloch-from-spherical(45deg, 45deg)
/// ```
///
/// -> content
#let bloch-from-spherical(
  /// Theta angle from the Z axis
  /// -> angle
  theta,
  /// Phi angle from the X axis
  /// -> angle
  phi,
  /// Magnitude
  /// -> float
  r: 1,
  /// Color for the state vector
  /// -> color
  state-color: purple,
  /// Whether to show the projection of the state vector on the XY plane.
  /// -> bool
  show-projections: true,
) = {
  _draw-bloch(r * 2, theta, phi, state-color, show-projections)
}


/// Draws the evolution from an initial vector to a final state using
/// spherical linear interpolation (slerp).
///
/// *Example*
/// ```example
/// #import tybloch: bloch-state-linear-evolution
///
/// #bloch-state-linear-evolution(
///   (1, 0deg, 0deg),
///   (1, 90deg, 90deg),
///   number-of-shadows: 9,
/// )
/// ```
///
/// -> content
#let bloch-state-linear-evolution(
  /// Initial state as an array of `(r, theta, phi)`
  /// -> array
  initial-state,
  /// Final state as an array of `(r, theta, phi)`
  /// -> array
  final-state,
  /// Number of shadows between initial and final state
  /// -> int
  number-of-shadows: 3,
  /// Color of the state
  /// -> color
  state-color: purple,
) = {
  _draw-bloch(
    ..initial-state,
    state-color,
    false,
    final-state: final-state,
    evolution: true,
    number-of-shadows: number-of-shadows,
  )
}

/// Draws the evolution of an initial state around a given rotation axis using
/// Rodrigues' rotation formula.
///
/// *Example*
/// ```example
/// #import tybloch: bloch-state-rotation-evolution
///
/// #bloch-state-rotation-evolution(
///   (1, 25deg, 90deg),
///   (0deg, 0deg),
///   360deg,
///   number-of-shadows: 11,
/// )
/// ```
///
/// -> content
#let bloch-state-rotation-evolution(
  /// Initial state as an array of `(r, theta, phi)`
  /// -> array
  initial-state,
  /// Rotation axis as an array of `(theta, phi)`
  /// -> array
  rotation-axis,
  /// Total rotation angle
  /// -> angle
  rotation-angle,
  /// Number of shadows between initial and final state
  /// -> int
  number-of-shadows: 3,
  /// Color of the state
  /// -> color
  state-color: purple,
) = {
  let rotation-axis = (1, rotation-axis.at(0), rotation-axis.at(1))
  _draw-bloch(
    ..initial-state,
    state-color,
    false,
    evolution: true,
    rotation-axis: rotation-axis,
    rotation-angle: rotation-angle,
    number-of-shadows: number-of-shadows,
  )
}
