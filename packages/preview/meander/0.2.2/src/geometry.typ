// Generalist functions for 1D and 2D geometry

/// Bound a value between `min` and `max`.
/// No constraints on types as long as they support inequality testing.
/// -> any
#let clamp(
  /// Base value.
  /// -> any
  val,
  /// Lower bound.
  /// -> any | none
  min: none,
  /// Upper bound.
  /// -> any | none
  max: none,
) = {
  let val = val
  if min != none and min > val { val = min }
  if max != none and max < val { val = max }
  val
}

/// Testing `a <= b <= c`, helps only computing `b` once.
/// -> bool
#let between(
  /// Lower bound.
  /// -> length
  a,
  /// Tested value.
  /// -> length
  b,
  /// Upper bound. Asserted to be `>= c`.
  /// -> length
  c,
) = {
  assert(a <= c)
  a <= b and b <= c
}

/// Tests if two intervals intersect.
#let intersects(
  /// First interval as a tuple of `(low, high)` in absolute lengths.
  /// -> (length, length)
  i1,
  /// Second interval.
  /// -> (length, length)
  i2,
  /// Set to nonzero to ignore small intersections.
  /// -> length
  tolerance: 0pt,
) = {
  let (l1, r1) = i1
  let (l2, r2) = i2
  assert(l1 <= r1)
  assert(l2 <= r2)
  if r1 < l2 + tolerance { return false }
  if r2 < l1 + tolerance { return false }
  true
}

/// Converts relative and contextual lengths to absolute.
/// The return value will contain each of the arguments once converted,
/// with arguments that contain `'x'` or start with `'w'` being interpreted as
/// horizontal, and arguments that contain `'y'` or start with `'h'` being
/// interpreted as vertical.
/// #v(2cm)
/// ```example
/// #context resolve(
///     (width: 100pt, height: 200pt),
///     x: 10%, y: 50% + 1pt,
///     width: 50%, height: 5pt,
/// )
/// ```
///
/// -> dictionary
#let resolve(
  /// Size of the container as given by the `layout` function.
  /// -> (width: length, height: length)
  size,
  /// -> dictionary
  ..args
) = {
  if "width" not in size { panic(size) }
  let scale-value(rel, max) = {
    let rel = 0% + 0pt + rel
    rel.ratio * max + rel.length.to-absolute()
  }
  // TODO: filter to only convert lengths
  let ans = (:)
  for (arg, val) in args.named() {
    let is-x = arg.at(0) == "x" or arg.last() == "x" or arg.at(0) == "w"
    let is-y = arg.at(0) == "y" or arg.last() == "y" or arg.at(0) == "h"
    if is-x and is-y {
      panic("Cannot infer if " + arg + " is horizontal or vertical")
    } else if is-x {
      ans.insert(arg, scale-value(val, size.width))
    } else if is-y {
      ans.insert(arg, scale-value(val, size.height))
    } else {
      ans.insert(arg, val)
    }
  }
  ans
}

/// Compute the position of the upper left corner, taking into account the
/// alignment and displacement.
/// -> (x: relative, y: relative)
#let align(
  /// Absolute alignment.
  /// -> alignment
  alignment,
  /// Horizontal displacement.
  /// -> relative
  dx: 0pt,
  /// Vertical displacement.
  /// -> relative
  dy: 0pt,
  /// Object width.
  /// -> relative
  width: 0pt,
  /// Object height.
  /// -> relative
  height: 0pt,
) = {
  let x = if alignment.x == left {
    0% + dx
  } else if alignment.x == right {
    100% + dx - width
  } else if alignment.x == center {
    50% + dx - width / 2
  } else {
    0% + dy
  }
  let y = if alignment.y == top {
    0% + dy
  } else if alignment.y == bottom {
    100% + dy - height
  } else if alignment.y == horizon {
    50% + dy - height / 2
  } else {
    0% + dy
  }
  (x: x, y: y)
}


