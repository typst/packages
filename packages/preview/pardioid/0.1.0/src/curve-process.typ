#import "sampler.typ": process-interval
#import "config.typ"
#import "header.typ": *
#import "utils.typ": *
#import "algorithms.typ": *
#import "style.typ": *

// -> array of dictionary, each dictionary contains two keys, namely `vector-fn` and `t-range`.
//
// Zero cannot be in the interval.
#let process-vector-fn(vector-fn: none, t-range: none) = {
  let is-bounded(t-range) = {
    let arr = t-range.filter(
      it => std.float(it).is-infinite(),
    )
    return arr.len() == 0
  }
  let is-in(num, t-range) = {
    return t-range.first() < num and num < t-range.last()
  }
  let is-half-line(t-range) = {
    let (left, right) = t-range
    if left == -float.inf and right == 0 {
      return true
    }
    if left == 0 and right == float.inf {
      return true
    }
    return false
  }
  let reciprocal(vector-fn: none, t-range: none) = {
    // Use $t -> -1/t$ as the compressing map.
    // $t -> t / (1 + abs(t))$ is not used, because it would require separately handling the `float.nan` produced by `float.inf / float.inf`, which should be treated as $1$.
    assert(not is-in(0, t-range))
    assert(not is-half-line(t-range))
    return (
      vector-fn: t => vector-fn(-1 / t),
      t-range: {
        let map(x) = -1 / x
        (map(t-range.first()), map(t-range.last()))
      },
    )
  }
  let split-at(num, t-range) = {
    assert(is-in(num, t-range))
    return (
      (t-range.first(), num),
      (num, t-range.last()),
    )
  }

  if is-in(0, t-range) {
    return split-at(0, t-range)
      .map(piece => process-vector-fn(
        vector-fn: vector-fn,
        t-range: piece,
      ))
      .flatten()
  }
  // sign-preserving interval
  if is-bounded(t-range) {
    return ((vector-fn: vector-fn, t-range: t-range),)
  }
  // // sign-preserving unbounded interval
  if is-half-line(t-range) {
    let split = range-sign(t-range)
    return split-at(split, t-range)
      .map(piece => process-vector-fn(
        vector-fn: vector-fn,
        t-range: piece,
      ))
      .flatten()
  }
  // Interval with constant sign but not maximal (neither (0, +oo) nor (-oo, 0)); take the reciprocal directly.
  return (
    reciprocal(
      vector-fn: vector-fn,
      t-range: t-range,
    ),
  )
}


#let clip(interval, clip-box: Rect) = {
  let range = liang-barsky(interval, clip-box: clip-box)
  if range == none { return none }

  let (left, right) = interval
  let (x: lx, y: ly) = left
  let (x: rx, y: ry) = right
  let vec = vec-from-to(left, right)
  let (x: dx, y: dy) = vec
  let (u1, u2) = range

  let nlx = lx + u1 * dx
  let nly = ly + u1 * dy
  let nrx = lx + u2 * dx
  let nry = ly + u2 * dy
  let point1 = vec-to-point(Vec(x: nlx, y: nly))
  let point2 = vec-to-point(Vec(x: nrx, y: nry))
  return Interval(left: point1, right: point2, off-view: false, accepted: interval.accepted)
}

#let get-jump-positions(intervals) = {
  let samples = unwindows(intervals.map(simplify-interval))
  let x-samples = samples.map(
    point => {
      (x: point.t, y: point.x)
    },
  )
  let y-samples = samples.map(
    point => {
      (x: point.t, y: point.y)
    },
  )
  let minmod-check = ()
  for s in (x-samples, y-samples) {
    let arr = minmod-edge-detection(s)
    minmod-check += arr
      .enumerate()
      .filter(
        ((idx, val)) => calc.abs(val) > epsilon-for-algo,
      )
      .map(
        ((idx, val)) => idx,
      )
  }
  // sort is unnecessary
  return minmod-check.dedup()
}

#let get-curve-components(
  vector-fn: none,
  t-range: none,
  clip-box: Rect,
  geom-granularity: geom-presets.balanced,
  max-depth: 8,
  init-samples: 150,
  detect-edge: false,
) = {
  assert.ne(t-range, none)

  let arr = process-vector-fn(vector-fn: vector-fn, t-range: t-range)
  let intervals = ()
  for (vector-fn, t-range) in arr {
    intervals += process-interval(
      Interval(
        left: get-point-at(t-range.first(), vector-fn: vector-fn, t-range: t-range),
        right: get-point-at(t-range.last(), vector-fn: vector-fn, t-range: t-range),
        accepted: true,
        off-view: false,
      ),
      vector-fn: vector-fn,
      count: calc.ceil(init-samples / arr.len()),
      geom-granularity: geom-granularity,
      max-depth: max-depth,
      clip-box: clip-box,
    )
  }
  if detect-edge {
    let jumps = get-jump-positions(intervals)
    for i in jumps {
      // `off-view` tip. Used to lift the pen.
      intervals.at(i).off-view = true
    }
  }
  let clipped = intervals.map(
    interval => {
      if interval.off-view {
        // Do not draw `off-view` interval.
        // And lift the pen.
        return none
      }
      if interval.accepted {
        // Accepted interval; geometrically good enough, draw directly.
        return clip(interval, clip-box: clip-box)
      }
      // It has not converged even after reaching the maximum recursion depth, so the geometry is not good.
      // It may be an oscillatory discontinuity (including infinite winding), or the local parameter speed may be too fast.
      // At this point, two nearby points on the curve are known, but points on the line between them are not guaranteed to be near the curve.
      // So use a point cloud instead of connecting them with line segments.
      interval.right = interval.left
      // This `clip` checks whether the left endpoint of the interval is inside the viewport.
      let temp = clip(interval, clip-box: clip-box)
      // none 的作用是标记抬笔的地方
      return (none, temp, none)
    },
  )

  // `filter` removes empty arrays produced by `split` from leading, trailing, or consecutive `none` values.
  let pieces = clipped.flatten().split(none).filter(x => x != ())
  let pieces-simplified = pieces.map(
    piece => {
      unwindows(
        piece.map(simplify-interval.with(include-t: false)),
      )
    },
  )
  if pieces-simplified == () { panic("No points are within view.") }
  let sentinels = pieces-simplified
    .map(
      piece => piece.first(),
    )
    .rev()
  return (
    pieces: pieces-simplified,
    sentinels: sentinels,
  )
}
