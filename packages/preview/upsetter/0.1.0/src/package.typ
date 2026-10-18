#import "deps.typ": *
#import "chart.typ": _barchart, _interchart
#import "common.typ": _parse-inter-key

/// Given a dictionary of set identifiers and
/// an array of sets in an intersection, return
/// the index (bitmask) of the intersection.
///
/// -> int
#let _make-index(
  /// -> dictionary
  sets,
  /// -> array
  sets-in-inter
) = {
  let index = 0

  for s in sets-in-inter {
    index = index.bit-or(1.bit-lshift(sets.at(s)))
  }

  return index
}

/// Get a dictionary of set identifiers from a dictionary of intersections.
/// -> dictionary
#let _make-sets(
  /// -> dictionary
  inter,
  /// -> string
  delim
) = {
  let seen = (:)

  for (k, _) in inter {
    seen = _parse-inter-key(k, delim, seen: seen)
  }

  return seen
}

#let _plot(
  /// -> dictionary
  legends,
  /// -> dictionary
  sets,
  /// -> dictionary
  inter,
  parsed-inter,
  /// -> array
  labels,
  /// -> "h" | "v"
  orientation,
  /// -> array
  sort-key,
  /// -> str
  delim,
  /// -> float | auto
  width,
  /// -> float | auto
  height,
  /// -> float
  set-plot-ratio,
  /// -> float
  inter-plot-ratio,
  /// -> bool
  show-axes
) = {
  // To reverse the direction when sorting in descending order,
  // the keys are multiplied by -1.
  let c(dir) = if dir == "desc" { -1 } else { 1 }
  let t = parsed-inter.t

  // Map of sort key functions.
  //
  // Each function takes an intersection string as a parameter
  // and returns a key (which may be an array).
  let sort-key-fn-map = (
    natural: (dir, s) => {
      let sets-in-inter = _parse-inter-key(s, delim).keys()

      sets-in-inter.map(it => c(dir) * sets.at(it))
    },
    size: (dir, s) => {
      let sets-in-inter = _parse-inter-key(s, delim).keys()
      let index = _make-index(sets, sets-in-inter)

      let (size, _) = t(index)

      c(dir) * size
    },
    arity: (dir, s) => {
      let sets-in-inter = _parse-inter-key(s, delim).keys()

      c(dir) * sets-in-inter.len()
    }
  )

  let sort-fns = sort-key.map(((key-fn-id, dir)) => {
    sort-key-fn-map.at(key-fn-id).with(dir)
  })

  let inter-sorted = parsed-inter.s.sorted(key: it => {
    sort-fns.map(f => f(it)).flatten()
  })

  cetz.draw.group({
    import cetz.draw: group, set-origin, content

    // Size of each intersection
    let inter-data = inter-sorted.map(s => {
      let sets-in-inter = _parse-inter-key(s, delim).keys()
      let index = _make-index(sets, sets-in-inter)

      let (size, _) = t(index)

      size
    })

    // Size of each set, obtained by traversing all the intersections
    let sets-data = (0,) * sets.len()

    for (v, s) in (parsed-inter.iter)() {
      if s == none {
        continue
      }

      let sets-in-inter = _parse-inter-key(s, delim).keys()
      
      for s in sets-in-inter {
        sets-data.at(sets.at(s)) += v
      }
    }

    let opposite(orientation) = {
      (h: "v", v: "h").at(orientation)
    }

    let (n-sets, n-inter) = (sets-data.len(), inter-data.len())

    let (max-label-w, max-label-h) = {
      let measures = labels.map(it => measure([] + it))

      (
        calc.max(..measures.map(it => it.width.cm())),
        calc.max(..measures.map(it => it.height.cm()))
      )
    }

    // Padding around each set label
    let label-padding = calc.max(0.25, 0.075 * calc.max(max-label-w, max-label-h))
    // Space that will have to be reserved for set labels across the main axis
    let label-f = max-label-w + 2 * label-padding

    assert(
      height == auto or orientation != "v" or height - label-f > 0,
      message: "height too small to fit the plot (labels might be too wide)"
    )
    
    assert(
      width == auto or orientation != "h" or width - label-f > 0,
      message: "width too small to fit the plot (labels might be too wide)"
    )

    assert(
      height == auto or orientation != "h" or height * (1 - inter-plot-ratio) > max-label-h * labels.len(),
      message: "height too small to fit labels (labels might be too tall, try decreasing inter-plot-ratio)"
    )

    assert(
      width == auto or orientation != "v" or width * (1 - inter-plot-ratio) > max-label-h * labels.len(),
      message: "width too small to fit labels (labels might be too tall, try decreasing inter-plot-ratio)"
    )
    
    // Gap factor (in relation to bar width). The default value
    // should always work when plotting the intersections, but when
    // plotting the sets it may not be sufficient for displaying big
    // labels, so we do an exponential search to find a better value.
    let gap-inter-f = 0.25
    let gap-sets-f = 0.25

    let (left, right) = (-1, -1)
    let exp-search = true

    let margin = 0.05

    let search-eps = 0.05

    let p

    // XXX: this is rather overengineered and probably not needed
    while true {
      // The relation between an axis length (l/L), the corresponding ratio (r/R),
      // the bar width (w), the gap factor (g/G) and the number of elements plotted on
      // the opposite axis (n/m) is used (after rearranging/isolating the terms) in
      // `k` to figure out the bar width and in `u` to figure out the missing axis
      // length value (width/height).
      //
      // `l`, `r`, `n` and `g` are complementary to `L`, `R`, `m` and `G`.
      let k(l, r, n, g) = /* w = */ (1 - r) * l / (n + g * (n + 1))
      let u(w, R, m, G) = /* L = */ (m + G * (m + 1)) * w / (1 - R)

      if width == auto {
        if orientation == "h" {
          let bar-width = k(height, inter-plot-ratio, n-sets, gap-sets-f)
          let width = u(bar-width, set-plot-ratio, n-inter, gap-inter-f)

          p = (width, height, bar-width)
        } else {
          let bar-width = k(height, set-plot-ratio, n-inter, gap-inter-f)
          let width = u(bar-width, inter-plot-ratio, n-sets, gap-sets-f)

          p = (width, height, bar-width)
        }
      } else {
        if orientation == "h" {
          let bar-width = k(width, set-plot-ratio, n-inter, gap-inter-f)
          let height = u(bar-width, inter-plot-ratio, n-sets, gap-sets-f)

          p = (width, height, bar-width)
        } else {
          let bar-width = k(width, inter-plot-ratio, n-sets, gap-sets-f)
          let height = u(bar-width, set-plot-ratio, n-inter, gap-inter-f)

          p = (width, height, bar-width)
        }
      }

      let (_, _, bar-width) = p

      if exp-search {
        if max-label-h < bar-width * (1 + gap-sets-f) {
          exp-search = false
          (left, right) = (gap-sets-f / 2, gap-sets-f)
        } else {
          gap-sets-f *= 2
        }
      } else {
        if max-label-h < bar-width * (1 + gap-sets-f) {
          if right - left < search-eps {
            break
          }
          
          left = gap-sets-f
        } else {
          right = gap-sets-f
        }

        gap-sets-f = (left + right) / 2
      }

      if gap-sets-f > 0.5 {
        gap-inter-f = 0.5
      }
    }

    let (width, height, bar-width) = p

    let inter-plot-length = (h: height, v: width).at(orientation)
    let set-plot-length = (h: width, v: height).at(orientation)

    group(
      name: "inter-bar",
      {
        if orientation == "v" {
          set-origin((-width * inter-plot-ratio, -height * (1 - set-plot-ratio) - label-f))
        }
        
        _barchart(
          legends.inter,
          orientation,
          inter-data,
          max-length: inter-plot-ratio * inter-plot-length,
          width: bar-width,
          gap: bar-width * gap-inter-f,
          show-axes: show-axes
        )
      }
    )
 
    group(
      name: "sets-bar",
      {
        if orientation == "h" {
          set-origin((-width * set-plot-ratio - label-f, -n-sets * bar-width * (1 + gap-sets-f) - bar-width * gap-sets-f))
        }

        _barchart(
          legends.sets,
          opposite(orientation),
          sets-data,
          max-length: set-plot-ratio * set-plot-length,
          width: bar-width,
          gap: bar-width * gap-sets-f,
          show-axes: show-axes
        )
      }
    )

    group(
      name: "sets-labels",
      {
        if orientation == "h" {
          set-origin((-label-f + label-padding, -bar-width * gap-sets-f))

          for (i, label) in labels.enumerate() {
            content(
              (max-label-w / 2, -bar-width * (i * (1 + gap-sets-f) + 1/2)),
              label
            )
          }
        } else {
          set-origin((bar-width * gap-sets-f, -label-f + label-padding))
          
          for (i, label) in labels.enumerate() {
            content(
              (bar-width * (i * (1 + gap-sets-f) + 1/2), max-label-w / 2),
              label,
              angle: 90deg
            ) 
          }
        }
      }
    )

    group(
      name: "inter",
      {
        let r = (h: inter-plot-ratio, v: set-plot-ratio).at(orientation)
        let l = (h: 0, v: label-f).at(orientation)
        
        set-origin((0, -height * (1 - r) - l))

        _interchart(
          orientation,
          sets,
          inter-sorted,
          delim,
          width: bar-width,
          gap-inter: bar-width * gap-inter-f,
          gap-sets: bar-width * gap-sets-f
        )
      }
    )
  })
}
