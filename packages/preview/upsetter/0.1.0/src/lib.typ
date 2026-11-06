#import "package.typ": _parse-inter-key, _make-sets, _make-index, _plot

/// Parse a dictionary mapping set identifiers to indices and a
/// set intersection dictionary into an array-like "possibly sparse"
/// dictionary that has the following properties:
///
/// - `t`: accessor function for the array
/// - `iter`: iterator for the parsed intersection values
/// - `s`: array of string intersection keys
#let _parse-inter(
  /// -> dictionary
  sets,
  /// -> dictionary
  inter,
  /// -> str
  delim
) = {
  let n = sets.len()
  let m = 1.bit-lshift(n)

  let dense = inter.len() >= calc.sqrt(m)

  let (parsed, key-fn) = if dense {
    (((0, none),) * m, it => it)
  } else {
    ((:), str)
  }

  let u = ()

  for (k, v) in inter {
    let sets-in-inter-dict = _parse-inter-key(k, delim)
    let index = _make-index(sets, sets-in-inter-dict.keys())

    let (prev, s) = parsed.at(key-fn(index), default: (0, none))

    if s == none {
      s = k
      u.push(k)
    }
    
    parsed.at(key-fn(index)) = (
      prev + v,
      s
    )
  }

  return (
    t: it => parsed.at(key-fn(it)),
    iter: if dense {
      () => parsed
    } else {
      () => parsed.values()
    },
    s: u
  )
}

#let _normalize-sort-key(sort-key) = {
  if type(sort-key) == array {
    sort-key.map(it => if type(it) == array {
      it
    } else {
      (it, "asc")
    })
  } else {
    ((sort-key, "asc"),)
  }
}

/// Renders an UpSet plot displaying the intersections of the given sets.
///
/// If the `sets` array is specified, the order in which the sets appear will be
/// used to sort the sets internally. If it is omitted, the sets will be sorted
/// according to the order in which they appear by traversing the dictionary of
/// intersections and processing each set in each intersection, in order.
///
/// Returns a `cetz.draw.group` object that has to be used inside a `context`. Either
/// `width` or `height` (but not both) must be specified. Prefer specifying the width
/// when using a vertical orientation and the height when using a horizontal orientation.
///
/// #example(mode: "code", ratio: 0.65, scale-preview: 100%, ```
/// context {
///   let plot = upsetter.plot(
///     sets: (
///       "Cats", "Dogs", "Fish",
///       "Birds", "Turtles"
///     ),
///     sort-key: (
///       ("arity", "asc"),
///       ("size", "desc")
///     ),
///     width: 7,
///     orientation: "v",
///     (
///       "": 17,      // No pets
///       "Cats": 44,
///       "Dogs": 52,
///       "Cats+Dogs": 23,
///       // This is allowed, the
///       // counts will be added
///       "Fish+Dogs": 11,
///       "Dogs+Fish": 2,
///       "Cats+Dogs+Fish": 7,
///       "Turtles": 3,
///       "Cats+Dogs+Fish+Turtles": 1
///       // No one has birds
///     )
///   )
///
///   v(3.5em)
///
///   figure(
///     cetz.canvas(plot),
///     caption: [Pet Ownership]
///   )
/// }
/// ```)
///
/// In the example above, we could avoid specifying `sets` if
/// someone had birds, or if we made `upsetter` aware of the
/// `"Birds"` category by adding a dummy intersection of size
/// 0 involving birds.
///
/// As the example above also shows, the empty set is represented
/// by the empty string.
///
/// -> context
#let plot(
  /// Legends for plot axes. -> dictionary
  legends: (inter: "Intersection Size", sets: "Set Size"),
  /// Array of identifiers of sets to be displayed. -> array | none
  sets: none,
  /// Labels for the sets. If not specified, the identifiers will be used
  /// as labels.
  ///
  /// -> array | none
  labels: none,
  /// Plot orientation. -> "h" | "v"
  orientation: "h",
  /// Criteria used to sort the intersections. Can be a string or an array
  /// of strings or an array of arrays where the first entry is a string and
  /// the second entry is either `"asc"` or `"desc"` (for ascending or descending
  /// sort, respectively). When an array is used, the keys will be used in order,
  /// in case there are ties.
  ///
  /// Specifying just a string is equivalent to one array entry with ascending sort.
  ///
  /// - `"natural"`: natural order of the intersections, determined by comparing
  ///   the sets in the intersections in the order in which they have been specified,
  ///   in the first occurrence of the corresponding intersection in the dictionary.
  /// - `"size"`: size of the intersection.
  /// - `"arity"`: arity/number of sets in each intersection.
  ///
  /// -> "natural" | "size" | "arity" | array 
  sort-key: (("size", "desc"),),
  /// Delimiter used in the intersection dictionary. -> str
  delim: "+",
  /// Show axes and ticks when plotting set sizes and intersection sizes.
  ///
  /// -> bool
  show-axes: true,
  /// Tick step used when plotting intersection sizes.
  ///
  /// -> float | auto
  inter-tick-step: auto,
  /// Tick step used when plotting set sizes.
  ///
  /// -> float | auto
  sets-tick-step: auto,
  /// Show empty intersections that have been specified in the intersection
  /// dictionary.
  ///
  /// -> bool
  show-empty-inter: false,
  /// Plot width in CeTZ units. -> float | auto
  width: auto,
  /// Plot height in CeTZ units. -> float | auto
  height: auto,
  /// Ratio of space on the main plot axis (orientation-dependent) used to
  /// plot set sizes.
  ///
  /// -> float
  set-plot-ratio: 0.4,
  /// Ratio of space on the secondary plot axis (orientation-dependent) used
  /// to plot intersection sizes.
  ///
  /// -> float
  inter-plot-ratio: 0.6,
  /// Intersection dictionary. Each entry has a string key consisting of a
  /// list of sets that are in the intersection and a value corresponding
  /// to the size of the intersection.
  /// 
  /// -> dictionary
  inter
) = {
  assert(
    (width == auto) != (height == auto),
    message: "either width or height (but not both) must be specified"
  )

  let within(x, a, b) = a <= x and x <= b

  assert(within(set-plot-ratio, 0.05, 0.95), message: "extreme values for set size plot ratio")
  assert(within(inter-plot-ratio, 0.05, 0.95), message: "extreme values for intersection size plot ratio")

  let sets = if sets == none {
    _make-sets(inter, delim)
  } else {
    sets.enumerate().map(it => it.rev()).to-dict()
  }

  if labels == none {
    labels = sets.keys()
  }

  let sort-key = _normalize-sort-key(sort-key)
  let parsed-inter = _parse-inter(sets, inter, delim)

  if not show-empty-inter {
    let t = parsed-inter.t
    
    parsed-inter.s = parsed-inter.s.filter(
      s => {
        let (size, _) = t(_make-index(sets, _parse-inter-key(s, delim).keys()))
        size != 0
      }
    )
  }

  return _plot(legends, sets, inter, parsed-inter, labels, orientation, sort-key, delim, width, height, set-plot-ratio, inter-plot-ratio, show-axes)
}
