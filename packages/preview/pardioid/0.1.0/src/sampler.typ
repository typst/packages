/// The first parameter of sampler is positional parameter `interval`, and the second is named parameter `vector-fn`.

#import "header.typ": *
#import "config.typ": *
#import "utils.typ": *
#import "algorithms.typ": *

// uniform is based on the parameter `t`
#let uniform-sampler(interval, vector-fn: none, count: none) = {
  let (start, end) = (interval.left.t, interval.right.t)
  let grid = get-uniform-grids(start, end, count: count)
  let points = grid.map(
    t => get-point-at(t, vector-fn: vector-fn, t-range: (start, end)),
  )
  let intervals = ()
  for idx in range(count - 1) {
    intervals.push(Interval(left: points.at(idx), right: points.at(idx + 1), accepted: true, off-view: false))
  }
  intervals
}


#let geom-sampler(
  interval,
  vector-fn: none,
  prev-vec: zero-vec,
  max-depth: 8,
  // Use clip to avoid trivial subdivide
  clip-box: none,
  geom-granularity: geom-presets.balanced,
) = {
  let is-acceptable(prev-vec, interval, geom-granularity: geom-granularity) = {
    let (max-dist-factor, angle-factor, min-dist-factor) = (Geom-granularity().get-factors)(geom-granularity)
    let (left, right) = interval
    let (x: v_x, y: v_y) = vec-from-to(left, right)

    // distance check
    let dist = v_x * v_x + v_y * v_y
    if dist <= min-dist-factor { return true }
    if dist > max-dist-factor { return false }
    // first segment checks distance only
    if (Vec().is-zero)(prev-vec) { return true }

    // angle check
    let (x: prev-dx, y: prev-dy) = prev-vec
    let dot = prev-dx * v_x + prev-dy * v_y
    if dot <= 0 { return false }
    let cross = calc.abs(prev-dx * v_y - prev-dy * v_x)
    return cross <= dot * angle-factor
  }
  let is-off-view(interval, clip-box: none) = {
    // `x-range` and `y-range` support `float.inf`. `none` and `auto` are equivalent to (-float.inf, float.inf)
    let ret = liang-barsky(interval, clip-box: clip-box)
    return ret == none
  }
  let accepted = true
  let off-view = false
  // The default value `none` for `remaining-depth` is itself invalid, used to prevent missing arguments.
  let recursive(prev-vec, interval, remaining-depth: none) = {
    if not is-finite-interval(interval) {
      interval.off-view = true
      return (interval,)
    }
    if remaining-depth <= 0 {
      interval.accepted = false
      return (interval,)
    }
    if is-off-view(interval, clip-box: clip-box) {
      // Segments marked `off-view` are not subdivided further to avoid unnecessary computation.
      // `off-view` also marks clipping points for later processing.
      interval.off-view = true
      return (interval,)
    }
    if is-acceptable(prev-vec, interval, geom-granularity: geom-granularity) {
      return (interval,)
    }

    let (left, right) = interval
    let mid = get-point-at((left.t + right.t) / 2, vector-fn: vector-fn, t-range: (left.t, right.t))
    // `lower` and `upper` represent the two parts of `interval` after bisection.
    let lower = recursive(
      prev-vec,
      Interval(left: left, right: mid, accepted: accepted, off-view: off-view),
      remaining-depth: remaining-depth - 1,
    )
    // `accepted == false` propagates upward.
    if lower.any(interval => interval.accepted == false) {
      lower = lower.map(
        interval => {
          interval.accepted = false
          interval
        },
      )
    }
    prev-vec = if lower.last() != none {
      let (left: lower-left, right: lower-right) = lower.last()
      vec-from-to(lower-left, lower-right)
    } else {
      zero-vec
    }
    let upper = recursive(
      prev-vec,
      Interval(left: mid, right: right, accepted: accepted, off-view: off-view),
      remaining-depth: remaining-depth - 1,
    )
    // `accepted == false` propagates upward.
    if upper.any(interval => interval.accepted == false) {
      upper = upper.map(
        interval => {
          interval.accepted = false
          interval
        },
      )
    }
    return lower + upper
  }
  if not is-finite-interval(interval) {
    interval.off-view = true
    return (interval,)
  }
  recursive(prev-vec, interval, remaining-depth: max-depth)
}




// uniform-sampler + geom-sampler
#let process-interval(
  interval,
  vector-fn: none,
  count: none,
  max-depth: none,
  clip-box: none,
  geom-granularity: geom-presets.balanced,
) = {
  let ret = ()
  let prev-vec = zero-vec
  let intervals = uniform-sampler(interval, vector-fn: vector-fn, count: count)

  for sub in intervals {
    ret += geom-sampler(
      sub,
      vector-fn: vector-fn,
      prev-vec: prev-vec,
      clip-box: clip-box,
      geom-granularity: geom-granularity,
      max-depth: max-depth,
    )
    if ret.last() == none { continue }
    let (left: lower-left, right: lower-right) = ret.last()
    prev-vec = vec-from-to(lower-left, lower-right)
  }
  ret
}
