#import "header.typ": *
#import "utils.typ": *
#import "config.typ"

/// Given a vector and a rectangular clipping box, returns parameters for the segment inside the box, or `none` if completely outside.
///
/// - interval (Interval):
/// - x-range (array | none): (x-min, x-max) or none. `float.inf` is supported. `none` is equivalent to `(-float.inf, float.inf)`.
/// - y-range (array | none): See `x-range`
/// - config (none):
/// -> (start ratio, end ratio) | none
#let liang-barsky(interval, clip-box: full-rect, config: none) = {
  import calc: max, min
  if clip-box == full-rect {
    return (0.0, 1.0)
  }
  let (x-min, x-max, y-min, y-max) = clip-box
  let (left, right) = interval
  let (x: lx, y: ly) = left
  let (x: rx, y: ry) = right
  let (x: dx, y: dy) = vec-from-to(left, right)
  let p = (-dx, dx, -dy, dy)
  let q = (lx - x-min, x-max - lx, ly - y-min, y-max - ly)
  let (u1, u2) = (0.0, 1.0)
  for i in range(4) {
    let cur-p = p.at(i)
    let cur-q = q.at(i)
    if cur-p == 0 {
      // Line segment parallel to boundary.
      if cur-q < 0 { return none }
    } else {
      let r = cur-q / cur-p
      if cur-p < 0 {
        // Segment enters from outside
        u1 = max(u1, r)
      } else {
        // Segment exits to outside
        u2 = min(u2, r)
      }
    }
  }
  if u1 > u2 {
    // Segment completely outside the window
    return none
  }
  return (u1, u2)
}

// Given sample points, returns estimated jump magnitudes at reconstruction points (midpoints of adjacent samples).
// `samples` is an array where each element must be a dictionary containing `x` and `y` fields.
// Used when `detect-edge` is `true`.
// See Appendix A of link("https://doi.org/10.1137/S0036142903435259")[POLYNOMIAL FITTING FOR EDGE DETECTION IN IRREGULARLY SAMPLED SIGNALS AND IMAGES]
#let minmod-edge-detection(samples, config: config.minmod-edge-detection) = {
  let get-local-points(center, global-points, order: none) = {
    import calc: abs, floor
    let arr = global-points
    let count = order + 1
    let len = arr.len()
    let (left, right) = (0, len - count)
    while left < right {
      let mid = floor((left + right) / 2)
      if abs(arr.at(mid) - center) > abs(arr.at(mid + count) - center) {
        left = mid + 1
      } else {
        right = mid
      }
    }
    // if arr.at(left) > center {
    //   left -= 1
    // } else if arr.at(right) < center {
    //   left += 1
    // }
    let ret = arr.slice(left, count: count)
    assert(ret.first() <= center and ret.last() >= center)
    return ret
  }
  // zero-based prod
  let omega(subscript, upper, local-points) = {
    let arr = ()
    for i in range(upper) {
      if i == subscript { continue }
      // i != subscript
      arr.push(local-points.at(subscript) - local-points.at(i))
    }
    assert.ne(arr, ())
    return arr.product()
  }
  let minmod(arr) = {
    if arr.all(x => x > 0) {
      return calc.min(..arr)
    }
    if arr.all(x => x < 0) {
      return calc.max(..arr)
    }
    return 0
  }
  // --------------------------------- //
  let sorted-samples = samples.sorted(key: ((x,)) => x, by: (l, r) => l < r)
  let N = sorted-samples.len()
  let (max-order,) = config
  let vars = sorted-samples.map(((x,)) => x)
  let vals = sorted-samples.map(((y,)) => y)
  let reconstruction-points = vars
    .windows(2)
    .map(
      ((a, b)) => (a + b) / 2,
    )
  let L = ((),) * max-order
  for m in range(1, max-order, inclusive: true) {
    for j in range(N - 1) {
      let count = m + 1
      // 0, 1,..., N - 2
      let cur-point = reconstruction-points.at(j)
      let local-points = get-local-points(cur-point, vars, order: m)
      let r = local-points.filter(x => x > cur-point).len()

      let c-arr = range(count).map(
        i => {
          config.factorials.at(m) / omega(i, count, local-points)
        },
      )
      let q = c-arr.slice(count - r, count).sum()
      let jump-estimation = (
        range(count)
          .map(
            i => {
              c-arr.at(i) * vals.at(i + j + r - m)
            },
          )
          .sum()
          / q
      )
      L.at(m - 1).push(jump-estimation)
    }
  }
  let L-transposed = range(N - 1).map(
    j => L.map(row => row.at(j)),
  )
  L-transposed.map(minmod)
}

