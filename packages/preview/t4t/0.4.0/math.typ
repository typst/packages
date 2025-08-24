#import "test.typ": same-type

// =================================
//  Math
// =================================

/// Returns an array with the minimum of `a` and `b` as the first element and the maximum as the second:
/// #codesnippet[```typ
/// #let (min, max) = math.minmax(a, b)
/// ```]
/// Works with any comparable type.
///
/// // Tests
/// #test(
///   `math.minmax(50, 60) == (50, 60)`,
///   `math.minmax(60, 50) == (50, 60)`,
///   `math.minmax(5deg, -4deg) == (-4deg, 5deg)`,
///   `math.minmax(-5cm, -4cm) == (-5cm, -4cm)`,
/// )
///
/// - a (integer, float, length, relative length, fraction, ratio): First value.
/// - b (integer, float, length, relative length, fraction, ratio): Second value.
/// -> integer, float, length, relative length, fraction, ratio
#let minmax(a, b) = (
  calc.min(a, b),
  calc.max(a, b),
)

/// Clamps a value between `min` and `max`.
///
/// In contrast to @@clamp() this function works for other values
/// than numbers, as long as they are comparable.
/// #codesnippet[```typ
/// text-size = math.clamp(0.8em, 1.2em, text-size)
/// ```]
/// Works with any comparable type.
///
/// // Tests
/// #test(
///   `math.clamp(0, 100, 50) == 50`,
///   `math.clamp(33%, 99%, 100%) == 99%`,
///   `math.clamp(-5in, 8in, -6in) == -5in`,
///   `math.clamp(-5in, 8in, 4in) == 4in`,
/// )
///
/// - min (integer, float, length, relative length, fraction, ratio): Minimum for `value`.
/// - min (integer, float, length, relative length, fraction, ratio): Maximum for `value`.
/// - value (integer, float, length, relative length, fraction, ratio): The value to clamp.
/// -> any
#let clamp(min, max, value) = {
  assert.eq(type(min), type(max), message: "Can't clamp values of different types!")
  assert.eq(type(min), type(value), message: "Can't clamp values of different types!")
  if value < min {
    return min
  } else if value > max {
    return max
  } else {
    return value
  }
}

/// Calculates the linear interpolation of `t` between `min` and `max`.
///
/// `t` should be a value between 0 and 1, but the interpolation works
/// with other values, too. To constrain the result into the given
/// interval, use @@clamp():
/// #codesnippet[```typ
/// #let width = math.lerp(0%, 100%, x)
/// #let width = math.lerp(0%, 100%, math.clamp(0, 1, x))
/// ```]
///
/// // Tests
/// #test(
///   `math.lerp(0, 100, .5) == 50`,
///   `math.lerp(0%, 100%, 1.1) == 110%`,
///   `math.lerp(-4em, 3em, -2) == -18em`,
///   `math.lerp(56.7, 423.8, 1) == 423.8`,
///   `math.lerp(56.7mm, 423.8mm, 0) == 56.7mm`,
/// )
///
/// - min (integer, float, length, relative length, fraction, ratio): Minimum for `value`.
/// - max (integer, float, length, relative length, fraction, ratio): Maximum for `value`.
/// - t (float): Interpolation parameter .
/// -> integer, float, length, relative length, fraction, ratio
#let lerp(min, max, t) = {
  assert.eq(type(min), type(max), message: "Can't lerp values of different types!")
  return (1 - t) * min + t * max
}

/// Maps a `value` from the interval `[min, max]` into the interval `[range-min, range-max]`:
/// #codesnippet[```typ
/// #let text-weight = int(math.map(8pt, 16pt, 400, 800, text-size))
/// ```]
///
/// The types of `min`, `max` and `value` and the types of `range-min` and `range-max` have to be the same.
///
/// // Tests
/// #test(
///   `math.map(8pt, 16pt, 400, 800, 8pt) == 400`,
///   `math.map(8pt, 16pt, 400, 800, 16pt) == 800`,
///   `math.map(8pt, 16pt, 400, 800, 4pt) == 200`,
///   `math.map(8pt, 16pt, 400, 800, 32pt) == 1600`,
///   `math.map(0%, 100%, 5.6em, 0.8em, 100%) == 0.8em`,
///   `math.map(0%, 100%, 5.6em, 0.8em, 0%) == 5.6em`,
/// )
///
/// - min (integer, float, length, relative length, fraction, ratio): Minimum of the initial interval.
/// - min (integer, float, length, relative length, fraction, ratio): Maximum of the initial interval.
/// - range-min (integer, float, length, relative length, fraction, ratio): Minimum of the target interval.
/// - range-min (integer, float, length, relative length, fraction, ratio): Maximum of the target interval.
/// - value (integer, float, length, relative length, fraction, ratio): The value to map.
/// -> integer, float, length, relative length, fraction, ratio
#let map(min, max, range-min, range-max, value) = {
  assert.eq(type(min), type(max), message: "Can't map values from ranges of different types!")
  assert.eq(type(range-min), type(range-max), message: "Can't map values to ranges of different types!")
  assert.eq(type(min), type(value), message: "Can't map values with different types as the initial range!")
  let t = (value - min) / (max - min)
  return (1 - t) * range-min + t * range-max
}
