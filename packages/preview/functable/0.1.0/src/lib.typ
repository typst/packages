/// Draw a sign/variation table (tableau de signes et de variations)
/// in the French tkz-tab style.
///
/// The table supports:
/// - Multiple factor rows (f' factors) with their signs
/// - A summary row (f' or f sign)
/// - A variation row with diagonal arrows and optional function values
/// - A second factor block (f'' factors) separated by a double line
/// - A convexity row with ∪/∩ symbols
/// - Hors-domaine (HD) intervals rendered as hatched bands
/// - Poles / valeurs interdites rendered as double bars (‖)
/// - Automatic merging of zeros shared across factors
///
/// ```typst
/// #sign-table(
///   factors: (
///     (expr: $x - 1$, zeros: ((value: $1$, approx: 1),), signs: ("-", "+")),
///     (expr: $x + 2$, zeros: ((value: $-2$, approx: -2),), signs: ("-", "+")),
///   ),
///   summary-label: $f'(x)$,
///   variation: true,
///   variation-label: $f(x)$,
/// )
/// ```
///
/// - factors (array): Array of factor definitions for f'. Each is a dictionary with:
///   - `expr` (content): Math expression for the row label
///   - `zeros` (array): Zero declarations, each with `value` (content) and `approx` (float).
///     Optional per-zero keys:
///     - `pole` (bool): marks a valeur interdite of f — double bar in summary,
///       variation and convexity rows; breaks variation arrows
///     - `summary-mark` (content or "bar" or "hd"): custom marker in summary row only
///     - `mark` (content or "bar" or "hd"): custom marker in factor and summary rows.
///       `"bar"` draws a double bar; `"hd"` continues the hors-domaine hatch through
///       the point (f' undefined at a domain boundary, not an asymptote).
///   - `signs` (array): Sign in each interval ("+" or "-"). `""` = blank; `"HD"` =
///     hors-domaine (hatched band, no sign, no arrow)
///   - `interdit` (bool): All zeros of this factor are forbidden values of f (shorthand
///     for setting `pole: true` on each zero)
/// - summary-label (content, none): Label for the f' summary row. `none` hides it.
/// - variation (bool): Show a variation row with diagonal arrows.
/// - variation-label (content, none): Label for the variation row.
/// - variation-values (array): Function values to overlay on the variation row.
///   Each entry: `(at: <approx>, label: <content>, pos: "top"|"bottom"|"arrow"|"auto")`.
/// - bounds (auto, none, dictionary): Domain bound labels in the x header.
///   `auto` renders $-oo$ and $+oo$; `none` hides both; a dictionary
///   `(left: ..., right: ...)` uses custom labels.
/// - start-value (content, none): Function value at the left end of the variation row.
/// - start-pos ("auto", "top", "bottom"): Vertical position of start-value.
/// - end-value (content, none): Function value at the right end of the variation row.
/// - end-pos ("auto", "top", "bottom"): Vertical position of end-value.
/// - col-width (length): Width of each interval column (default 1.5cm).
/// - zero-col-width (length): Width allocated per zero/pole column (default 1.4cm). Currently unused; reserved for future layout modes.
/// - row-height (length): Height of sign/factor rows (default 0.9cm).
/// - var-row-height (auto, length): Height of variation and convexity rows.
///   `auto` grows to fit the tallest overlaid value label.
/// - second-factors (array): Factor rows for f'', same structure as `factors`.
/// - second-summary-label (content, none): Label for the f'' summary row.
/// - convexity (bool): Show a convexity row with ∪ (f''>0) and ∩ (f''<0) symbols.
/// - convexity-label (content, none): Label for the convexity row.
/// - hd-fill (color): Fill color for HD bands when `hd-style: "fill"` (default light blue).
/// - hd-style (string): HD band rendering — `"hatch"` (diagonal lines), `"fill"` (solid tint), or `"blank"` (no fill).
/// - show-facteurs (bool): Show the rotated "facteur(s)" strip at the far left spanning the factor rows.
#let sign-table(
  factors: (),
  summary-label: none,
  variation: false,
  variation-label: none,
  variation-values: (),
  bounds: auto,
  start-value: none,
  start-pos: "auto",
  end-value: none,
  end-pos: "auto",
  col-width: 1.5cm,
  zero-col-width: 1.4cm,
  row-height: 0.9cm,
  var-row-height: auto,
  second-factors: (),
  second-summary-label: none,
  convexity: false,
  convexity-label: none,
  hd-fill: rgb("#cfe2f3"),
  hd-style: "hatch",
  show-facteurs: true,
) = {
  // Collect and merge zeros from all factors (f' and f''), sorted by approx.
  let all-zeros = ()
  for factor in factors + second-factors {
    if "zeros" in factor {
      for zero in factor.zeros {
        let idx = none
        for (j, z) in all-zeros.enumerate() {
          if z.approx == zero.approx { idx = j; break }
        }
        if idx == none {
          all-zeros.push(zero)
        } else {
          all-zeros.at(idx) = zero + all-zeros.at(idx)
        }
      }
    }
  }
  all-zeros = all-zeros.sorted(key: z => z.approx)

  let num-zeros = all-zeros.len()
  let num-intervals = num-zeros + 1

  let factor-has-zero-at(factor, approx) = {
    if "zeros" not in factor { return false }
    for fz in factor.zeros {
      if fz.approx == approx { return true }
    }
    return false
  }

  // Test point well inside interval i (not at any zero).
  // For outer intervals: offset by half the adjacent gap, minimum 1.0.
  let test-point-in(i) = {
    if num-zeros == 0 { return 0.0 }
    if i == 0 {
      let z0 = all-zeros.at(0).approx
      let gap = if num-zeros > 1 { (all-zeros.at(1).approx - z0) / 2 } else { 1.0 }
      z0 - calc.max(gap, 1.0)
    } else if i == num-intervals - 1 {
      let zn = all-zeros.at(num-zeros - 1).approx
      let gap = if num-zeros > 1 { (zn - all-zeros.at(num-zeros - 2).approx) / 2 } else { 1.0 }
      zn + calc.max(gap, 1.0)
    } else {
      (all-zeros.at(i - 1).approx + all-zeros.at(i).approx) / 2
    }
  }

  // Map a factor's interval index (counting only its own zeros) to the global
  // interval index, then return its sign. If the factor has a `fn` key and no
  // `signs`, evaluate the function at a test point to infer the sign.
  let get-factor-sign-in-interval(factor, interval-idx) = {
    if "signs" in factor and factor.signs.len() > 0 {
      let local-interval = 0
      for (i, global-zero) in all-zeros.enumerate() {
        if i < interval-idx {
          if factor-has-zero-at(factor, global-zero.approx) { local-interval += 1 }
        }
      }
      if local-interval < factor.signs.len() { return factor.signs.at(local-interval) }
      return factor.signs.last()
    } else if "fn" in factor {
      let x = test-point-in(interval-idx)
      let result = (factor.fn)(x)
      if result == none { return "HD" }
      if result > 0 { "+" } else if result < 0 { "-" } else { "" }
    } else { "+" }
  }

  // Summary sign = product of factor signs; first non-+/- propagates (HD, blank).
  let get-summary-sign-in-interval(interval-idx) = {
    let negative-count = 0
    for factor in factors {
      let sign = get-factor-sign-in-interval(factor, interval-idx)
      if sign != "+" and sign != "-" { return sign }
      if sign == "-" { negative-count += 1 }
    }
    if calc.rem(negative-count, 2) == 0 { "+" } else { "-" }
  }

  let get-second-summary-sign-in-interval(interval-idx) = {
    let negative-count = 0
    for factor in second-factors {
      let sign = get-factor-sign-in-interval(factor, interval-idx)
      if sign != "+" and sign != "-" { return sign }
      if sign == "-" { negative-count += 1 }
    }
    if calc.rem(negative-count, 2) == 0 { "+" } else { "-" }
  }

  let is-zero-interdit(zero) = {
    for factor in factors {
      if "interdit" in factor and factor.interdit {
        if factor-has-zero-at(factor, zero.approx) { return true }
      }
    }
    return false
  }

  let is-pole(zero) = {
    if zero.at("pole", default: false) { return true }
    return is-zero-interdit(zero)
  }

  // Double vertical bar — valeur interdite / pôle marker.
  let pole-bar(h) = box(width: 6pt, height: h, {
    place(left, dx: 1pt, line(start: (0pt, 0pt), end: (0pt, h), stroke: 1.2pt))
    place(left, dx: 5pt, line(start: (0pt, 0pt), end: (0pt, h), stroke: 1.2pt))
  })

  context {

  // Use text bounds edges so tall math (fractions, matrices) is measured correctly.
  let bounded(c) = {
    set text(top-edge: "bounds", bottom-edge: "bounds")
    c
  }

  let resolved-bounds = if bounds == auto { (left: $-oo$, right: $+oo$) } else { bounds }
  let left-bound = if resolved-bounds == none { none } else { resolved-bounds.at("left", default: none) }
  let right-bound = if resolved-bounds == none { none } else { resolved-bounds.at("right", default: none) }

  // Header row grows to fit the tallest zero/bound label (e.g. display fractions).
  let header-height = {
    let h = row-height
    for bound in (left-bound, right-bound) {
      if bound != none {
        let m = measure(bounded([*#bound*]))
        if m.height + 8pt > h { h = m.height + 8pt }
      }
    }
    for zero in all-zeros {
      let m = measure(bounded([*#zero.value*]))
      if m.height + 8pt > h { h = m.height + 8pt }
    }
    h
  }

  // Label column widens to fit the widest row label.
  let label-width = {
    let w = 2.8cm
    for f in factors + second-factors {
      if "expr" in f {
        let m = measure([*#f.expr*])
        if m.width + 12pt > w { w = m.width + 12pt }
      }
    }
    for l in (summary-label, variation-label, second-summary-label, convexity-label) {
      if l != none {
        let m = measure([*#l*])
        if m.width + 12pt > w { w = m.width + 12pt }
      }
    }
    w
  }

  let facteurs-strip = show-facteurs and factors.len() > 0 and summary-label != none
  let facteurs2-strip = show-facteurs and second-factors.len() > 0 and second-summary-label != none
  let strip-w = if facteurs-strip or facteurs2-strip { 0.5cm } else { 0pt }
  let facteurs-text(n) = rotate(-90deg, reflow: true,
    text(size: 8pt, if n == 1 { "fact." } else { "facteurs" })
  )
  let lbl-w = strip-w + label-width
  let value-box(label) = box(fill: white, inset: (x: 2pt, y: 1pt), bounded(label))

  let has-bounds = left-bound != none or right-bound != none
  let bound-gutter = if has-bounds {
    let w = 0pt
    for bound in (left-bound, right-bound) {
      if bound != none {
        let m = measure(value-box(bound))
        if m.width / 2 + 4pt > w { w = m.width / 2 + 4pt }
      }
    }
    calc.max(0.42cm, w)
  } else { 0pt }
  let x-bound-left = lbl-w + bound-gutter
  let x-at-zero(i) = x-bound-left + (i + 1) * col-width
  let x-itvl-center(i) = x-bound-left + i * col-width + col-width / 2
  let x-itvl-left(i)   = x-bound-left + i * col-width
  let x-itvl-right(i)  = x-bound-left + (i + 1) * col-width

  // Resolve variation values and auto-position them.
  let auto-interior-pos(k) = {
    let l = get-summary-sign-in-interval(k)
    let r = get-summary-sign-in-interval(k + 1)
    let is-sign(s) = s == "+" or s == "-"
    if is-sign(l) and is-sign(r) {
      if l == "+" and r == "-" { "top" }
      else if l == "-" and r == "+" { "bottom" }
      else { "arrow" }
    } else if is-sign(r) {
      if r == "+" { "bottom" } else { "top" }
    } else if is-sign(l) {
      if l == "+" { "top" } else { "bottom" }
    } else { "bottom" }
  }
  let zero-values = ()
  for (i, zero) in all-zeros.enumerate() {
    for v in variation-values {
      if calc.abs(zero.approx - v.at) < 1e-6 {
        let pos = v.at("pos", default: "auto")
        if pos == "auto" { pos = auto-interior-pos(i) }
        let b = value-box(v.label)
        zero-values.push((i: i, pos: pos, body: b, size: measure(b)))
      }
    }
  }
  let start-val = if start-value != none {
    let pos = if start-pos == "auto" {
      if get-summary-sign-in-interval(0) == "+" { "bottom" } else { "top" }
    } else { start-pos }
    let b = value-box(start-value)
    (pos: pos, body: b, size: measure(b))
  } else { none }
  let end-val = if end-value != none {
    let pos = if end-pos == "auto" {
      if get-summary-sign-in-interval(num-intervals - 1) == "+" { "top" } else { "bottom" }
    } else { end-pos }
    let b = value-box(end-value)
    (pos: pos, body: b, size: measure(b))
  } else { none }

  let has-var-values = zero-values.len() > 0 or start-val != none or end-val != none
  let var-row-height = if var-row-height == auto {
    if has-var-values {
      let max-h = 0pt
      let all-vals = zero-values
      if start-val != none { all-vals.push(start-val) }
      if end-val != none { all-vals.push(end-val) }
      for v in all-vals {
        if v.size.height > max-h { max-h = v.size.height }
      }
      calc.max(1.6cm, max-h + 0.9cm)
    } else { 1.2cm }
  } else { var-row-height }
  let double-line-gap = 5pt

  let has-second-block = second-factors.len() > 0 or second-summary-label != none
  let second-block-rows = second-factors.len() + (if second-summary-label != none { 1 } else { 0 })

  let num-rows = factors.len() + (if summary-label != none { 1 } else { 0 })
  let total-width = lbl-w + 2 * bound-gutter + num-intervals * col-width
  let total-height = (
    header-height + num-rows * row-height
    + (if variation { var-row-height + double-line-gap } else { 0cm })
    + (if has-second-block { second-block-rows * row-height + double-line-gap } else { 0cm })
    + (if convexity { var-row-height + double-line-gap } else { 0cm })
  )

  let dotted-stroke = (thickness: 0.5pt, dash: "densely-dotted")
  let stub-gap = 2pt
  let border-stubs(x, y-a, y-b) = {
    if y-b - y-a > 2.5pt {
      place(top + left, dx: x, dy: y-a,
        line(start: (0pt, 0pt), end: (0pt, y-b - y-a), stroke: dotted-stroke)
      )
    }
  }

  // Overlay content centred on a zero's vertical grid line, with a white
  // background strip that masks the grid line and dotted stubs above/below.
  let in-zero-cell(i, y-row-top, h, content) = {
    place(top + left, dx: x-at-zero(i) - 0.25cm, dy: y-row-top,
      box(fill: white, width: 0.5cm, height: h)
    )
    let b = box(fill: white, inset: (x: 2pt, y: 1pt))[#bounded(content)]
    let m = measure(b)
    border-stubs(x-at-zero(i), y-row-top, y-row-top + (h - m.height) / 2 - stub-gap)
    border-stubs(x-at-zero(i), y-row-top + (h + m.height) / 2 + stub-gap, y-row-top + h)
    place(top + left,
      dx: x-at-zero(i) - m.width / 2,
      dy: y-row-top + (h - m.height) / 2,
      b
    )
  }

  let in-bound-cell(x, y-row-top, h, content) = {
    place(top + left, dx: x - 0.25cm, dy: y-row-top,
      box(fill: white, width: 0.5cm, height: h)
    )
    let b = box(fill: white, inset: (x: 2pt, y: 1pt))[#bounded(content)]
    let m = measure(b)
    place(top + left,
      dx: x - m.width / 2,
      dy: y-row-top + (h - m.height) / 2,
      b
    )
  }

  let in-itvl-cell(i, y-row-top, h, content) = {
    place(top + left, dx: x-itvl-left(i), dy: y-row-top,
      box(width: col-width, height: h, align(center + horizon)[#content])
    )
  }

  // HD band fill: phase-aligned hatch across the full table width.
  let hd-band-fill = if hd-style == "hatch" {
    tiling(size: (4pt, 4pt), relative: "parent")[#line(start: (0pt, 4pt), end: (4pt, 0pt), stroke: 0.4pt + gray)]
  } else if hd-style == "fill" {
    hd-fill.lighten(40%)
  } else { none }

  // Return maximal runs of consecutive "HD" intervals.
  let hd-runs(sign-fn) = {
    let runs = ()
    let start = none
    for i in range(num-intervals) {
      if sign-fn(i) == "HD" {
        if start == none { start = i }
      } else if start != none {
        runs.push((start, i - 1))
        start = none
      }
    }
    if start != none { runs.push((start, num-intervals - 1)) }
    runs
  }

  let hd-band(i-a, i-b, y, h) = if hd-band-fill != none {
    place(top + left, dx: x-itvl-left(i-a), dy: y,
      rect(width: (i-b - i-a + 1) * col-width, height: h, fill: hd-band-fill, stroke: none)
    )
  }

  // Continue the HD hatch through a zero/pole strip (no asymptote implied).
  let hd-through(i, y, h) = if hd-band-fill != none {
    place(top + left, dx: x-at-zero(i) - 0.25cm, dy: y,
      rect(width: 0.5cm, height: h, fill: hd-band-fill, stroke: none)
    )
  }

  box(width: total-width, height: total-height, {
    place(top + left, rect(width: total-width, height: total-height, stroke: 0.5pt, fill: none))

    place(top + left, dx: lbl-w,
      line(start: (0pt, 0pt), end: (0pt, total-height), stroke: 0.5pt)
    )

    // Vertical zero lines — only in sign rows, not in variation/convexity rows.
    let y-sign-bottom = header-height + num-rows * row-height
    let line-segments = ((0pt, y-sign-bottom),)
    if has-second-block {
      let y2 = y-sign-bottom + (if variation { var-row-height + double-line-gap } else { 0cm })
      line-segments.push((y2, y2 + double-line-gap + second-block-rows * row-height))
    }
    for i in range(num-zeros) {
      for (y-a, y-b) in line-segments {
        place(top + left, dx: x-at-zero(i), dy: y-a,
          line(start: (0pt, 0pt), end: (0pt, y-b - y-a), stroke: 0.5pt)
        )
      }
    }

    // Header row
    place(top + left, dx: lbl-w / 2, dy: header-height / 2,
      box(width: 0pt, height: 0pt, align(center + horizon)[*$x$*])
    )
    if left-bound != none {
      in-bound-cell(x-itvl-left(0), 0pt, header-height, [*#left-bound*])
    }
    if right-bound != none {
      in-bound-cell(x-itvl-right(num-intervals - 1), 0pt, header-height, [*#right-bound*])
    }
    for (i, zero) in all-zeros.enumerate() {
      in-zero-cell(i, 0pt, header-height, [*#zero.value*])
    }

    let render-sign(sign) = {
      if sign == "+" { $+$ }
      else if sign == "-" { $minus$ }
      else if sign != "" and sign != "HD" { sign }
    }

    let resolve-mark(m) = if m == "bar" { pole-bar(row-height - 6pt) } else { m }
    let zero-marker(zero) = {
      if "mark" in zero { resolve-mark(zero.mark) } else { $0$ }
    }
    let summary-marker(zero) = {
      if "summary-mark" in zero { resolve-mark(zero.summary-mark) }
      else if "mark" in zero { resolve-mark(zero.mark) }
      else if is-pole(zero) { pole-bar(row-height - 6pt) }
      else { $0$ }
    }

    // Factor rows
    for (row-idx, factor) in factors.enumerate() {
      let y-top = header-height + row-idx * row-height
      if "expr" in factor {
        place(top + left, dx: strip-w + 4pt, dy: y-top,
          box(width: label-width - 8pt, height: row-height,
            align(center + horizon)[*#factor.expr*]
          )
        )
      }
      for i in range(num-intervals) {
        let sign = get-factor-sign-in-interval(factor, i)
        if sign == "HD" { hd-band(i, i, y-top, row-height) }
        else { in-itvl-cell(i, y-top, row-height, render-sign(sign)) }
      }
      for (i, zero) in all-zeros.enumerate() {
        if factor-has-zero-at(factor, zero.approx) {
          if zero.at("mark", default: none) == "hd" { hd-through(i, y-top, row-height) }
          else { in-zero-cell(i, y-top, row-height, zero-marker(zero)) }
        }
      }
    }

    // Summary row (f' or f sign)
    if summary-label != none {
      let row-idx = factors.len()
      let y-top = header-height + row-idx * row-height
      place(top + left, dx: 4pt, dy: y-top,
        box(width: lbl-w - 8pt, height: row-height,
          align(center + horizon)[*#summary-label*]
        )
      )
      for i in range(num-intervals) {
        let sign = get-summary-sign-in-interval(i)
        if sign == "HD" { hd-band(i, i, y-top, row-height) }
        else { in-itvl-cell(i, y-top, row-height, render-sign(sign)) }
      }
      for (i, zero) in all-zeros.enumerate() {
        let m = zero.at("summary-mark", default: zero.at("mark", default: none))
        if m == "hd" { hd-through(i, y-top, row-height) }
        else { in-zero-cell(i, y-top, row-height, summary-marker(zero)) }
      }
    }

    // "facteur(s)" strip and its closing vertical line
    if facteurs-strip {
      let h = factors.len() * row-height
      place(top + left, dx: strip-w, dy: header-height,
        line(start: (0pt, 0pt), end: (0pt, h), stroke: 0.5pt)
      )
      place(top + left, dy: header-height,
        box(width: strip-w, height: h, align(center + horizon, facteurs-text(factors.len())))
      )
    }

    // Horizontal row separators (drawn after content so they paint over white fills)
    for row in range(num-rows) {
      let x0 = if facteurs-strip and row >= 1 and row < factors.len() { strip-w } else { 0pt }
      place(top + left, dx: x0, dy: header-height + row * row-height,
        line(start: (0pt, 0pt), end: (total-width - x0, 0pt), stroke: 0.5pt)
      )
    }

    // Variation row
    if variation {
      let y-double-line = header-height + num-rows * row-height
      let y-top = y-double-line + double-line-gap
      let y-bottom = y-top + var-row-height
      let y-center = (y-top + y-bottom) / 2

      for (i-a, i-b) in hd-runs(get-summary-sign-in-interval) {
        hd-band(i-a, i-b, y-top, var-row-height)
      }

      place(top + left, dy: y-double-line,
        line(start: (0pt, 0pt), end: (total-width, 0pt), stroke: 0.5pt)
      )

      if variation-label != none {
        place(top + left, dx: lbl-w / 2, dy: y-center,
          box(width: 0pt, height: 0pt, align(center + horizon)[*#variation-label*])
        )
      }

      // Build arrow spans: break at poles and sign changes.
      let margin-h = calc.min(0.25cm, col-width * 0.22)
      let margin-v = 0.3cm
      let spans = ()
      let span-start = 0
      let current-sign = get-summary-sign-in-interval(0)
      for interval-idx in range(1, num-intervals) {
        let sign = get-summary-sign-in-interval(interval-idx)
        let zero-between = all-zeros.at(interval-idx - 1)
        let pole-here = is-pole(zero-between)
        if sign != current-sign or pole-here {
          spans.push((start: span-start, end: interval-idx - 1, sign: current-sign))
          span-start = interval-idx
          current-sign = sign
        }
      }
      spans.push((start: span-start, end: num-intervals - 1, sign: current-sign))

      for (i, zero) in all-zeros.enumerate() {
        if is-pole(zero) {
          in-zero-cell(i, y-top, var-row-height, pole-bar(var-row-height - 4pt))
        }
      }

      place(top + left, dy: y-double-line + double-line-gap,
        line(start: (0pt, 0pt), end: (total-width, 0pt), stroke: 0.5pt)
      )

      // Arrow geometry: value labels pin near row edges; arrows stop short of them.
      let margin-v = 0.25cm
      let pad-v = 4pt
      let tip-gap = 3pt

      let cy-of(pos, h) = if pos == "top" { y-top + pad-v + h / 2 } else { y-bottom - pad-v - h / 2 }
      let start-cx = if start-val != none { lbl-w + 3pt + start-val.size.width / 2 } else { 0pt }
      let end-cx = if end-val != none { total-width - 3pt - end-val.size.width / 2 } else { 0pt }
      let zero-val-at(i, want) = {
        for v in zero-values {
          if v.i == i and v.pos == want { return v }
        }
        none
      }

      let geoms = ()
      for span in spans {
        if span.sign != "+" and span.sign != "-" { geoms.push(none); continue }
        let up = span.sign == "+"
        let sx = x-itvl-left(span.start) + margin-h
        let sy = if up { y-bottom - margin-v } else { y-top + margin-v }
        let s-box = none
        let ex = x-itvl-right(span.end) - margin-h
        let ey = if up { y-top + margin-v } else { y-bottom - margin-v }
        let e-box = none
        let want-l = if up { "bottom" } else { "top" }
        if span.start == 0 {
          if start-val != none and start-val.pos == want-l {
            sx = start-cx
            sy = cy-of(want-l, start-val.size.height)
            s-box = start-val.size
          }
        } else {
          let v = zero-val-at(span.start - 1, want-l)
          if v != none {
            sx = x-at-zero(span.start - 1)
            sy = cy-of(want-l, v.size.height)
            s-box = v.size
          }
        }
        let want-r = if up { "top" } else { "bottom" }
        if span.end == num-intervals - 1 {
          if end-val != none and end-val.pos == want-r {
            ex = end-cx
            ey = cy-of(want-r, end-val.size.height)
            e-box = end-val.size
          }
        } else {
          let v = zero-val-at(span.end, want-r)
          if v != none {
            ex = x-at-zero(span.end)
            ey = cy-of(want-r, v.size.height)
            e-box = v.size
          }
        }
        let dx = float((ex - sx) / 1pt)
        let dy = float((ey - sy) / 1pt)
        let exit-t(bx) = {
          if bx == none { return 0.0 }
          let hw = float((bx.width / 2 + tip-gap) / 1pt)
          let hh = float((bx.height / 2 + tip-gap) / 1pt)
          let tx = if calc.abs(dx) < 0.01 { 1e9 } else { hw / calc.abs(dx) }
          let ty = if calc.abs(dy) < 0.01 { 1e9 } else { hh / calc.abs(dy) }
          calc.min(tx, ty)
        }
        let t0 = exit-t(s-box)
        let t1 = 1.0 - exit-t(e-box)
        let seg = (t1 - t0) * calc.sqrt(dx * dx + dy * dy)
        if seg < 6.0 { geoms.push(none); continue }
        geoms.push((
          x1: sx + t0 * dx * 1pt, y1: sy + t0 * dy * 1pt,
          x2: sx + t1 * dx * 1pt, y2: sy + t1 * dy * 1pt,
        ))
      }

      for g in geoms {
        if g == none { continue }
        place(top + left, dx: g.x1, dy: g.y1,
          line(start: (0pt, 0pt), end: (g.x2 - g.x1, g.y2 - g.y1), stroke: 0.5pt)
        )
      }

      // Value labels on the variation row
      for v in zero-values {
        let cx = x-at-zero(v.i)
        if v.pos == "arrow" {
          let cy = (y-top + y-bottom) / 2
          for (k, span) in spans.enumerate() {
            if span.sign != "+" and span.sign != "-" { continue }
            if span.start <= v.i and v.i < span.end {
              let g = geoms.at(k)
              if g != none and g.x2 > g.x1 + 1pt {
                let t = float((cx - g.x1) / (g.x2 - g.x1))
                cy = g.y1 + t * (g.y2 - g.y1)
              }
              break
            }
          }
          let half = v.size.height / 2
          let cy-min = y-top + pad-v + half
          let cy-max = y-bottom - pad-v - half
          let cyc = if cy < cy-min { cy-min } else if cy > cy-max { cy-max } else { cy }
          border-stubs(cx, y-top, cyc - half - stub-gap)
          border-stubs(cx, cyc + half + stub-gap, y-bottom)
          place(top + left, dx: cx - v.size.width / 2, dy: cyc - half, v.body)
        } else {
          let cy = cy-of(v.pos, v.size.height)
          border-stubs(cx, y-top, cy - v.size.height / 2 - stub-gap)
          border-stubs(cx, cy + v.size.height / 2 + stub-gap, y-bottom)
          place(top + left, dx: cx - v.size.width / 2,
            dy: cy-of(v.pos, v.size.height) - v.size.height / 2, v.body)
        }
      }
      if start-val != none {
        place(top + left, dx: start-cx - start-val.size.width / 2,
          dy: cy-of(start-val.pos, start-val.size.height) - start-val.size.height / 2, start-val.body)
      }
      if end-val != none {
        place(top + left, dx: end-cx - end-val.size.width / 2,
          dy: cy-of(end-val.pos, end-val.size.height) - end-val.size.height / 2, end-val.body)
      }

      // Arrowheads drawn last (on top of labels)
      for g in geoms {
        if g == none { continue }
        let arrow-len = 7pt
        let arrow-width = 3pt
        let dx-val = float((g.x2 - g.x1) / 1pt)
        let dy-val = float((g.y2 - g.y1) / 1pt)
        let length = calc.sqrt(dx-val * dx-val + dy-val * dy-val)
        let ux = dx-val / length
        let uy = dy-val / length
        let back-x = -ux * float(arrow-len / 1pt)
        let back-y = -uy * float(arrow-len / 1pt)
        let perp-x = -uy * float(arrow-width / 1pt)
        let perp-y = ux * float(arrow-width / 1pt)
        place(top + left, dx: g.x2, dy: g.y2,
          polygon(
            fill: black,
            (0pt, 0pt),
            ((back-x + perp-x) * 1pt, (back-y + perp-y) * 1pt),
            ((back-x - perp-x) * 1pt, (back-y - perp-y) * 1pt),
          )
        )
      }
    }

    // Second derivative block (f'' factors + summary + convexity)
    if has-second-block or convexity {
      let y-second-start = (
        header-height + num-rows * row-height
        + (if variation { var-row-height + double-line-gap } else { 0cm })
      )

      place(top + left, dy: y-second-start,
        line(start: (0pt, 0pt), end: (total-width, 0pt), stroke: 0.5pt)
      )
      place(top + left, dy: y-second-start + double-line-gap,
        line(start: (0pt, 0pt), end: (total-width, 0pt), stroke: 0.5pt)
      )

      for (row-idx, factor) in second-factors.enumerate() {
        let y-top = y-second-start + double-line-gap + row-idx * row-height
        if "expr" in factor {
          place(top + left, dx: strip-w + 4pt, dy: y-top,
            box(width: label-width - 8pt, height: row-height,
              align(center + horizon)[*#factor.expr*]
            )
          )
        }
        for i in range(num-intervals) {
          let sign = get-factor-sign-in-interval(factor, i)
          if sign == "HD" { hd-band(i, i, y-top, row-height) }
          else { in-itvl-cell(i, y-top, row-height, render-sign(sign)) }
        }
        for (i, zero) in all-zeros.enumerate() {
          if factor-has-zero-at(factor, zero.approx) {
            in-zero-cell(i, y-top, row-height, zero-marker(zero))
          }
        }
      }

      if second-summary-label != none {
        let row-idx = second-factors.len()
        let y-top = y-second-start + double-line-gap + row-idx * row-height
        place(top + left, dx: 4pt, dy: y-top,
          box(width: lbl-w - 8pt, height: row-height,
            align(center + horizon)[*#second-summary-label*]
          )
        )
        for i in range(num-intervals) {
          let sign = get-second-summary-sign-in-interval(i)
          if sign == "HD" { hd-band(i, i, y-top, row-height) }
          else { in-itvl-cell(i, y-top, row-height, render-sign(sign)) }
        }
        for (i, zero) in all-zeros.enumerate() {
          let is-second-zero = second-factors.any(f =>
            "zeros" in f and f.zeros.any(z => z.approx == zero.approx)
          )
          if is-second-zero {
            let m = zero.at("summary-mark", default: zero.at("mark", default: none))
            if m == "hd" { hd-through(i, y-top, row-height) }
            else { in-zero-cell(i, y-top, row-height, summary-marker(zero)) }
          }
        }
      }

      if facteurs2-strip {
        let h = second-factors.len() * row-height
        let y0 = y-second-start + double-line-gap
        place(top + left, dx: strip-w, dy: y0,
          line(start: (0pt, 0pt), end: (0pt, h), stroke: 0.5pt)
        )
        place(top + left, dy: y0,
          box(width: strip-w, height: h, align(center + horizon, facteurs-text(second-factors.len())))
        )
      }

      for r in range(second-block-rows) {
        let x0 = if facteurs2-strip and r >= 1 and r < second-factors.len() { strip-w } else { 0pt }
        place(top + left, dx: x0, dy: y-second-start + double-line-gap + r * row-height,
          line(start: (0pt, 0pt), end: (total-width - x0, 0pt), stroke: 0.5pt)
        )
      }

      // Convexity row
      if convexity {
        let y-conv-base = y-second-start + double-line-gap + second-block-rows * row-height
        let y-conv-top = y-conv-base + double-line-gap
        let y-conv-bottom = y-conv-top + var-row-height
        let y-center = (y-conv-top + y-conv-bottom) / 2

        for (i-a, i-b) in hd-runs(get-second-summary-sign-in-interval) {
          hd-band(i-a, i-b, y-conv-top, var-row-height)
        }

        place(top + left, dy: y-conv-base,
          line(start: (0pt, 0pt), end: (total-width, 0pt), stroke: 0.5pt)
        )
        place(top + left, dy: y-conv-base + double-line-gap,
          line(start: (0pt, 0pt), end: (total-width, 0pt), stroke: 0.5pt)
        )

        if convexity-label != none {
          place(top + left, dx: lbl-w / 2, dy: y-center,
            box(width: 0pt, height: 0pt, align(center + horizon)[*#convexity-label*])
          )
        }

        for i in range(num-intervals) {
          let sign = get-second-summary-sign-in-interval(i)
          place(top + left, dx: x-itvl-left(i), dy: y-conv-top,
            box(width: col-width, height: var-row-height,
              align(center + horizon)[
                #if sign == "+" { $union$ } else if sign == "-" { $inter$ }
              ]
            )
          )
        }

        let bar-h = var-row-height - 4pt
        for (i, zero) in all-zeros.enumerate() {
          if is-pole(zero) {
            place(top + left,
              dx: x-at-zero(i) - 3pt,
              dy: y-center - bar-h / 2,
              pole-bar(bar-h)
            )
          }
        }
      }
    }

    // Outer border redrawn last: white masking strips near table edges overlap it.
    place(top + left, rect(width: total-width, height: total-height, stroke: 0.5pt, fill: none))
  })

  } // end context
}


/// Draw a function values table (tableau de valeurs) with an x row and
/// one or more f(x) rows.
///
/// Each entry in `x-values` can be:
/// - A **number** (int or float): displayed as `$number$` and passed to `fn` for computation.
/// - A **dictionary** `(display: content, value: number)`: custom display with numeric value for `fn`.
/// - **Content**: displayed as-is; no auto-computation for this column.
///
/// Each row dictionary supports either `values` (explicit content array) or
/// `fn` (a Typst function `x => number`) for auto-computation from numeric x entries.
///
/// ```typst
/// #fun-table(
///   x-values: (-2, -1, 0, 1, 2),
///   rows: (
///     (label: $f(x)$, fn: x => x * x - 1),
///   ),
/// )
/// ```
///
/// - x-values (array): x column headers. Numbers are displayed in math mode and
///   forwarded to `fn`. Dictionaries `(display, value)` use a custom display with a
///   numeric value. Content is displayed as-is with no computation.
/// - x-label (content): Label for the x row (default $x$).
/// - rows (array): One entry per function row. Each is a dictionary with:
///   - `label` (content): Row label (e.g. $f(x)$).
///   - `values` (array): Explicit content cells, one per x column. Use `none` for blank.
///   - `fn` (function): A Typst function `x => number` used when `x-values` entries are numeric.
///     Takes precedence over `values` for numeric x columns; `values` takes precedence otherwise.
///   - `format` (function, none): How to render a computed number → content. Default: smart
///     integer/decimal formatting. Provide `x => str(x)` or `x => [#x]` to customise.
/// - col-width (length): Column width (default 1.5cm).
/// - row-height (length): Row height (default 0.9cm).
/// - label-width (length, auto): Width of the label column. `auto` sizes to fit.
/// - stroke (stroke): Table stroke (default 0.5pt).
/// - decimals (int, auto): Decimal places for auto-computed values. `auto` trims trailing zeros.
#let fun-table(
  x-values: (),
  x-label: $x$,
  rows: (),
  col-width: 1.5cm,
  row-height: 0.9cm,
  label-width: auto,
  stroke: 0.5pt,
  decimals: auto,
) = {
  // Resolve each x entry into (display: content, value: number or none).
  let resolved-x = x-values.map(entry => {
    if type(entry) == int or type(entry) == float {
      (display: $#entry$, value: entry)
    } else if type(entry) == dictionary and "display" in entry and "value" in entry {
      entry
    } else {
      (display: entry, value: none)
    }
  })

  // Format a computed number as content.
  let default-format(n) = {
    if type(n) == int { $#n$ }
    else {
      let rounded = if decimals == auto {
        // Trim trailing zeros: try up to 10 decimal places.
        let s = str(calc.round(n, digits: 10))
        // Remove trailing zeros after decimal point.
        if "." in s {
          let trimmed = s.trim("0", at: end, repeat: true)
          trimmed.trim(".", at: end, repeat: true)
        } else { s }
      } else {
        str(calc.round(n, digits: decimals))
      }
      $#rounded$
    }
  }

  // Resolve row values: either explicit or computed via fn.
  let resolved-rows = rows.map(row => {
    let fmt = if "format" in row { row.format } else { default-format }
    let has-fn = "fn" in row
    let explicit = if "values" in row { row.values } else { () }
    let cells = resolved-x.enumerate().map(((i, rx)) => {
      if has-fn and rx.value != none {
        let computed = (row.fn)(rx.value)
        if computed == none { none } else { fmt(computed) }
      } else if i < explicit.len() {
        explicit.at(i)
      } else {
        none
      }
    })
    (label: row.label, cells: cells)
  })

  context {
  let bounded(c) = { set text(top-edge: "bounds", bottom-edge: "bounds"); c }

  let lbl-w = if label-width == auto {
    let w = 2.2cm
    for row in rows {
      let m = measure([*#row.label*])
      if m.width + 12pt > w { w = m.width + 12pt }
    }
    let m = measure([*#x-label*])
    if m.width + 12pt > w { w = m.width + 12pt }
    w
  } else { label-width }

  // Header row height grows to fit tall x values.
  let header-height = {
    let h = row-height
    for rx in resolved-x {
      let m = measure(bounded([*#rx.display*]))
      if m.height + 8pt > h { h = m.height + 8pt }
    }
    h
  }

  let num-cols = resolved-x.len()
  let num-rows = resolved-rows.len()
  let total-width = lbl-w + num-cols * col-width
  let total-height = header-height + num-rows * row-height

  box(width: total-width, height: total-height, {
    place(top + left, rect(width: total-width, height: total-height, stroke: stroke, fill: none))

    place(top + left, dx: lbl-w,
      line(start: (0pt, 0pt), end: (0pt, total-height), stroke: stroke)
    )

    for i in range(1, num-cols) {
      place(top + left, dx: lbl-w + i * col-width,
        line(start: (0pt, 0pt), end: (0pt, total-height), stroke: stroke)
      )
    }

    place(top + left, dx: 0pt, dy: 0pt,
      box(width: lbl-w, height: header-height, align(center + horizon)[*#x-label*])
    )

    for (i, rx) in resolved-x.enumerate() {
      place(top + left, dx: lbl-w + i * col-width, dy: 0pt,
        box(width: col-width, height: header-height,
          align(center + horizon)[*#rx.display*]
        )
      )
    }

    for (row-idx, row) in resolved-rows.enumerate() {
      let y-top = header-height + row-idx * row-height
      place(top + left, dy: y-top,
        line(start: (0pt, 0pt), end: (total-width, 0pt), stroke: stroke)
      )
      place(top + left, dx: 0pt, dy: y-top,
        box(width: lbl-w, height: row-height, align(center + horizon)[*#row.label*])
      )
      for (i, v) in row.cells.enumerate() {
        if v != none {
          place(top + left, dx: lbl-w + i * col-width, dy: y-top,
            box(width: col-width, height: row-height, align(center + horizon)[#v])
          )
        }
      }
    }

    place(top + left, rect(width: total-width, height: total-height, stroke: stroke, fill: none))
  })

  } // end context
}
