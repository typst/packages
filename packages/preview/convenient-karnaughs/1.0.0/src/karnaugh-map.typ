#import calc: div-euclid, even, inf, max, min, odd, pow, rem-euclid
#import "@preview/tidy:0.4.3": styles.default.show-type

#import "./util.typ": (
  all, cartesian, filter-by-index, imap, indices, is-unique, join, max-by,
  mk-dict, partition, partition-by-index, power-set, set-difference, singleton,
  sum, switch, update, zip, zip-with,
)
#import "./to.typ": to-arguments, to-bool
#import "./rectangle.typ": (
  adjacent-sides, just-insides, merge-rectangles, rectangle,
)
#import "./rectangle.typ" as r
#import "./point.typ": neighbour, point, x, y

#let var-cell-size = 1.5em
#let var-gutter = 0.5em
#let var-stroke = 1pt
#let func-cell-stroke = 1pt
#let function-cell-size = 2em
#let minterm-radius = 0.2em
#let implicant-wrap-outset = 2pt
#let implicant-inset = 2pt

#let no-argument = () => {}
/// -> str
#let _type-error(
  /// -> string
  param,
  /// -> string
  expected,
  /// -> any
  actual: no-argument,
) = (
  ("Invalid `" + param + "` argument: Expected " + expected)
    + if actual != no-argument { ", but got " + str(type(actual)) }
    + "."
)
#let _internal-error(e) = "Internal Error: " + e

#let _arg-error(
  /// -> str | array
  param,
  /// -> str
  expected,
  /// -> any
  actual,
) = {
  let param = if type(param) == str {
    param
  } else if type(param) == array {
    assert(param.len() >= 1, message: _internal-error(
      "Invalid argument param: Expected array to be non-empty, but got "
        + repr(param),
    ))
    let (h, ..ts) = param
    h + ts.map(t => ".at(" + repr(t) + ")").join()
  } else {
    panic(_internal-error(
      "Invalid argument param: Expected str or array, but got " + repr(param),
    ))
  }
  (
    ("Invalid argument " + param + ": ")
      + ("Expected " + expected + ", but got " + repr(actual) + ".")
  )
}

/// -> bool | none
#let _bool-like-arg(
  /// -> str | array
  param,
  /// -> any
  v,
) = if type(v) == bool or v == none {
  v
} else if v == 0 {
  false
} else if v == 1 {
  true
} else if v == -1 {
  none
} else {
  panic(_arg-error(param, "boolean or none or -1 or 0 or 1", v))
}

#let show-bool-like(v) = if v == none { $*$ } else if v { $1$ } else { $0$ }


#let _function-grid-width(vars) = pow(2, div-euclid(vars.len() + 1, 2))
#let _function-grid-height(vars) = pow(2, div-euclid(vars.len(), 2))

/// List of all points in the function grid in row-major order
/// -> array
#let _func-grid-points(
  /// -> array
  vars,
) = {
  let (w, h) = (_function-grid-width(vars), _function-grid-height(vars))
  cartesian(range(h), range(w)).map(((y, x)) => point(x, y))
}

/// The value of variable `var` at position `point` in the function grid.
#let _variable(
  /// Index of the variable. Counts from the back, so the fastest changing
  /// variable has index 0.
  /// -> int
  var,
  /// -> point
  point,
) = {
  let axis = if even(var) { point.x } else { point.y }
  let axis-var = div-euclid(var, 2)
  let p = pow(2, axis-var)
  return to-bool(rem-euclid(div-euclid(axis + p, 2 * p), 2)) // trust me bro
}
/// The value of all variables `vars` at position `point` in the function grid.
#let _assignment(
  /// Array of content. The fastest changing variable is the last element.
  /// -> array
  vars,
  /// -> point
  point,
) = {
  return indices(vars).rev().map(i => _variable(i, point))
}

#let _render-function-grid(
  /// -> function
  f,
  /// -> array
  vars,
) = grid(
  columns: (function-cell-size,) * _function-grid-width(vars),
  rows: (function-cell-size,) * _function-grid-height(vars),
  align: center + horizon,
  stroke: func-cell-stroke,
  .._func-grid-points(vars).map(point => show-bool-like(f(point))),
)

#let all-sides = ("left", "top", "right", "bottom")
#let _render-implicant-rectangle(
  /// -> array
  vars,
  /// -> color
  color,
  /// -> function
  implicant,
  /// -> rectangle
  rect_,
) = {
  let (w, h) = (_function-grid-width(vars), _function-grid-height(vars))
  let wrap-point((x, y)) = point(rem-euclid(x, w), rem-euclid(y, h))
  let wraps(side) = implicant(wrap-point(r.just-outside(side, rect_)))
  let borders = all-sides
    .filter(side => not wraps(side))
    .map(side => just-insides(side, rect_).map(p => (p, side)))
    .join()
  let content = inset-level => {
    let cell-size = function-cell-size
    let (i, o) = (implicant-inset, implicant-wrap-outset)
    let inset(side) = { if wraps(side) { -o } else { (inset-level + 1) * i } }
    place(
      top + left,
      dx: rect_.left * cell-size + inset(r.left),
      dy: rect_.top * cell-size + inset(r.top),
      rect(
        width: r.width(rect_) * cell-size - inset(r.left) - inset(r.right),
        height: r.height(rect_) * cell-size - inset(r.top) - inset(r.bottom),
        fill: color.transparentize(75%),
        stroke: mk-dict(r.all-sides, f: side => if not wraps(side) { color }),
        radius: mk-dict(r.all-corners, f: corner => {
          let round = not adjacent-sides(corner).any(wraps)
          if round { minterm-radius } else { 0em }
        }),
      ),
    )
  }
  (borders: borders, inset-cost: borders.len(), content: content)
}
#let _render-implicants(vars, colors, implicants) = {
  let implicant-infos = implicants
    .enumerate()
    .map(((i, impl)) => {
      merge-rectangles(_func-grid-points(vars).filter(impl))
        .map(rect => _render-implicant-rectangle(vars, colors(i), impl, rect))
        .fold((borders: (), inset-cost: 0, content: _ => []), (acc, cur) => (
          borders: acc.borders + cur.borders,
          inset-cost: acc.inset-cost + cur.inset-cost,
          content: in-lvl => (acc.content)(in-lvl) + (cur.content)(in-lvl),
        ))
    })
  let worker(inset-level, implicant-infos) = {
    if implicant-infos == () { return [] }
    let poss-lvls = power-set(implicant-infos)
      .filter(is_ => is_ != ())
      .filter(is_ => is-unique(..is_.map(i => i.borders).join()))
    let best = max-by(f: is_ => is_.map(i => i.inset-cost).sum(), ..poss-lvls)
    let content = best.map(i => (i.content)(inset-level)).join()
    content + worker(inset-level + 1, set-difference(implicant-infos, best))
  }
  worker(0, implicant-infos)
}

/// -> content
#let _render-line-labels(
  /// -> array
  vars,
  /// -> content
  function-grid,
) = {
  let (w, h) = (_function-grid-width(vars), _function-grid-height(vars))
  let (vars-x, vars-y) = partition-by-index(f: even, vars)
  grid(
    columns: (var-cell-size,) * vars-y.len() + (function-cell-size,) * w,
    rows: (var-cell-size,) * vars-x.len() + (function-cell-size,) * h,
    row-gutter: (0.25em,) * max(0, vars-x.len() - 1)
      + if vars-x.len() > 0 { (0.5em,) }
      + (0em,),
    column-gutter: (0.25em,) * max(0, vars-y.len() - 1)
      + if vars-y.len() > 0 { (0.5em,) }
      + (0em,),
    ..join(("x", "y").map(axis => {
      let other-axis = if axis == "x" { "y" } else { "x" }
      let span = if axis == "x" { "colspan" } else { "rowspan" }
      let axis-vars = filter-by-index(vars, f: i => {
        (if axis == "x" { even } else { odd })(vars.len() - i - 1)
      })
      let border-side = if axis == "x" { "bottom" } else { "right" }
      join(zip-with(indices(axis-vars).rev(), axis-vars, f: (i, var) => {
        let p = calc.pow(2, i)
        if i == axis-vars.len() - 1 {
          return singleton(grid.cell(..to-arguments((
            (axis): (vars.len() - axis-vars.len()) + p,
            (other-axis): axis-vars.len() - 1 - i,
            (span): p,
            stroke: ((border-side): var-stroke),
            align: center + horizon,
            "0": var,
          ))))
        }
        return range(pow(2, axis-vars.len() - i - 2))
          .map(j => singleton(grid.cell(..to-arguments((
            (axis): (vars.len() - axis-vars.len()) + p + 4 * p * j,
            (other-axis): axis-vars.len() - 1 - i,
            (span): 2 * p,
            stroke: ((border-side): var-stroke),
            align: center + horizon,
            "0": var,
          )))))
          .join()
      }))
    })),
    grid.cell.with(x: vars-y.len(), y: vars-x.len(), colspan: w, rowspan: h)(
      function-grid,
    )
  )
}

/// -> content
#let _render-bitstring-labels(
  /// -> array
  vars,
  /// -> content
  function-grid,
) = {
  assert(
    vars.len() <= 8,
    message: "American labels support only up to 8 variables, but got "
      + str(vars.len()),
  )
  let (w, h) = (_function-grid-width(vars), _function-grid-height(vars))
  let i-vars = zip(indices(vars).rev(), vars)
  let (i-vars-x, i-vars-y) = partition(i-vars, f: ((i, _)) => even(i))
  let (label-factor) = (() => {})()
  let label-x = i-vars-x.map(((_, v)) => v).join()
  let label-y = rotate(-90deg, reflow: true, i-vars-y.map(((_, v)) => v).join())
  grid(
    columns: (auto,) * 2 + (function-cell-size,) * w,
    rows: (auto,) * 2 + (function-cell-size,) * h,
    column-gutter: if vars.len() > 1 { (0.75em, 0.5em) } + (0em,),
    row-gutter: if vars.len() > 0 { (0.75em, 0.5em) } + (0em,),
    grid.cell(x: 2, y: 0, colspan: w, align: center + horizon, label-x),
    grid.cell(x: 0, y: 2, rowspan: h, align: center + horizon, label-y),
    ..join(("x", "y").map(axis => {
      let other-axis = if axis == "x" { "y" } else { "x" }
      let span = if axis == "x" { "colspan" } else { "rowspan" }
      let i-axis-vars = if axis == "x" { i-vars-x } else { i-vars-y }
      range(if axis == "x" { w } else { h }).map(a => {
        let point = ((axis): a, (other-axis): -1)
        grid.cell(..to-arguments((
          (axis): a + 2,
          (other-axis): 1,
          align: center + horizon,
          "0": i-axis-vars
            .map(((i, _)) => if _variable(i, point) [1] else [0])
            .join(),
        )))
      })
    })),
    grid.cell(x: 2, y: 2, colspan: w, rowspan: h, function-grid)
  )
}

/// Default value of @karnaugh-map.style exposed as variable. Use this only in
/// case you want to change it and export it as variable. Otherwise just pass
/// a partial styles object into @karnaugh-map.
///
/// ```typc
/// let my-style = (
///   ..default-style,
///   // Overrides here
/// )
/// ```
/// -> dictionary
#let default-style = (
  /// -> array
  implicant-colors: (blue, red, green, purple, yellow, teal, black),
  /// -> "line" | "bitstring" | function
  labels: "line",
)

/// A Karnaugh map.
#let karnaugh-map(
  /// The number or names of the variables, of which there can be arbitrarily
  /// many.
  ///
  /// ```examplec
  /// karnaugh-map(
  ///   vars: 3,
  /// <<<  // or
  /// <<<  vars: ($x_2$, $x_1$, $x_0$),
  ///   (x2, x1, x0) => x0,
  /// )
  /// ```
  /// -> int | array
  vars: none,
  /// The function or an array of the #bool-like function values. If an
  /// array, the order is read off of a truth table where the last variable
  /// changes the fastest.
  ///
  /// #grid(
  ///   columns: 2,
  ///   gutter: 5pt,
  ///   align: horizon,
  ///   block(inset: 5pt, {
  ///     show table.cell.where(x: 2): math.bold
  ///     table(
  ///       columns: 3,
  ///       stroke: none,
  ///       align: center,
  ///       table.header($x_1$, $x_0$, table.vline(), $f$),
  ///       table.hline(),
  ///       $0$, $0$, $0$,
  ///       $0$, $1$, $1$,
  ///       $1$, $0$, $*$,
  ///       $1$, $1$, $*$,
  ///     )
  ///   }),
  ///   ```examplec
  ///   karnaugh-map(
  ///     vars: 2,
  ///     (x1, x0) =>
  ///       if x1 {none} else {x0},
  ///   <<<  // or
  ///   <<<  (false, true, none, none),
  ///   <<<  // or
  ///   <<<  (0, 1, -1, -1),
  ///   )
  ///   ```
  /// )
  /// -> function | array
  f,
  /// A list of implicants, which can either be functions or arrays of
  /// #bool-like values representing variable assignments.
  ///
  /// They are automatically rendered so that no two borders are directly on top
  /// of each other. It even finds the layout with the minimal amount of
  /// adjustments.
  ///
  /// ```examplec
  /// karnaugh-map(
  ///   vars: 3,
  ///   (0, 1, 0, 0, 0, 1, 0, 0),
  ///   implicants: (
  ///     (x2, x1, x0) => not x1 and x0,
  /// <<<    // or
  /// <<<    (none, false, true),
  /// <<<    // or
  /// <<<    (-1, 0, 1),
  ///     (x2, x1, x0) => not x2 and x0,
  ///     // ⬑ automatically adjusted
  ///   )
  /// )
  /// ```
  /// -> array
  implicants: (),
  /// Styling configuration that is merged with the defaults. The dictionary may
  /// contain the following keys:
  ///
  /// #let show-parameter-sub-block = show-parameter-sub-block.with(
  ///   function-name: "karnaugh-map",
  ///   parameter-name: "style"
  /// )
  /// #show-parameter-sub-block("implicant-colors", ("array", "function"))[
  ///   Either a list of colors or a function that calculates a color from the
  ///   implicant index. There must be at least as many colors as implicants.
  ///   ```examplec
  ///   >>> set text(font: "libertinus serif")
  ///   karnaugh-map(
  ///     vars: 2,
  ///     (1, 0, 0, 1),
  ///     implicants: (
  ///       (x1, x0) => not x1 and not x0,
  ///       (x1, x0) => x1 and x0,
  ///     ),
  ///     style: (
  ///       implicant-colors: (black, fuchsia),
  ///     )
  ///   )
  ///   ```
  ///   ```examplec
  ///   >>> set text(font: "libertinus serif")
  ///   karnaugh-map(
  ///     vars: 3,
  ///     (x2, x1, x0) => none,
  ///     implicants: (
  ///       (x2, x1, x0) => not x0 and not x2,
  ///       (x2, x1, x0) => x0 and not x2,
  ///       (x2, x1, x0) => x0 and x2,
  ///       (x2, x1, x0) => not x0 and x2,
  ///     ),
  ///     style: (
  ///       implicant-colors: (i) => {
  ///         color.hsl(-25deg * i, 100%, 50%)
  ///       },
  ///     ),
  ///   )
  ///   ```
  /// ]
  /// #show-parameter-sub-block(
  ///   "labels",
  ///   ("\"bitstring\"", "\"line\"", "function")
  /// )[
  ///   Values `"bitstring"` and `"line"` are presets, but a custom function
  ///   can be provided. It takes the variables and the function grid as
  ///   arguments, where each function grid cell is ```typc 1em``` wide.
  ///   ```examplec
  ///   >>> set text(font: "libertinus serif")
  ///   karnaugh-map(
  ///     vars: 3,
  ///     (x2, x1, x0) => x0,
  ///     style: (
  ///       labels: "bitstring",
  ///     ),
  ///   )
  ///   ```
  ///   ```examplec
  ///   >>> set text(font: "libertinus serif")
  ///   karnaugh-map(
  ///     vars: 3,
  ///     (x2, x1, x0) => x0,
  ///     style: (
  ///       labels: "line",
  ///     ),
  ///   )
  ///   ```
  /// ]
  /// -> dictionary
  style: (
    implicant-colors: (blue, red, green, purple, yellow, teal, black),
    labels: "line",
  ),
) = {
  //===---- parsing arguments (most of this function) -------------------===//
  /// The display names of the variables.
  let vars = if type(vars) == array {
    vars
  } else if type(vars) == int {
    range(vars).map(i => $x_#i$).rev()
  } else {
    panic(_type-error("vars", "array or int", actual: vars))
  }
  /// The value of `f` at position `point`.
  let f = if type(f) == function {
    point => _bool-like-arg("return value of f", f(.._assignment(vars, point)))
  } else if type(f) == array {
    assert(
      f.len() == pow(2, vars.len()),
      message: _arg-error("f", "2^number-of-variables elements", f.len()),
    )
    let f = imap(f, f: (i, v) => _bool-like-arg(("f", i), v))
    point => {
      let a = _assignment(vars, point)
      f.at(sum(default: 0, zip-with(indices(a).rev(), a, f: (i, v) => (
        int(v) * pow(2, i)
      ))))
    }
  } else {
    panic(_arg-error("f", "function or array", f))
  }
  assert(
    type(implicants) == array,
    message: _type-error("implicants", "array", actual: implicants),
  )
  /// For every implicant in `implicants` the value at position `point`.
  let implicants = imap(implicants, f: (i, impl) => if type(impl) == array {
    assert(impl.len() == vars.len(), message: _arg-error(
      ("implicants", i),
      "number-of-variables elements",
      impl.len(),
    ))
    let impl = imap(impl, f: (j, v) => _bool-like-arg(("implicants", i, j), v))
    point => {
      all(zip-with(impl, _assignment(vars, point), f: (expected, actual) => {
        expected == none or expected == actual
      }))
    }
  } else if type(impl) == function {
    point => impl(.._assignment(vars, point))
  } else {
    panic(_arg-error(("implicants", i), "function or array", impl))
  })
  let s = (:..default-style, ..style)
  let style = (
    labels: if s.labels == "line" {
      _render-line-labels
    } else if s.labels == "bitstring" {
      _render-bitstring-labels
    } else if type(s.labels) == function {
      s.labels
    } else {
      panic(_arg-error(
        "style.labels",
        "\"line\" or \"bitstring\" or function",
        s.labels,
      ))
    },
    implicant-colors: if type(s.implicant-colors) == array {
      assert(
        implicants.len() <= s.implicant-colors.len(),
        message: _arg-error(
          "style.colors",
          "at least as many elements as implicants",
          s.implicant-colors.len(),
        ),
      )
      i => s.implicant-colors.at(i)
    } else if type(s.implicant-colors) == function {
      s.implicant-colors
    } else {
      panic(_arg-error("style.colors", "array or function", s.implicant-colors))
    },
  )

  //===---- producing content -------------------------------------------===//
  (style.labels)(vars, {
    place(top + left, _render-function-grid(f, vars))
    let (implicant-colors: colors) = style
    _render-implicants(vars, colors, implicants)
  })
}
