// treemap.typ - Treemap chart (squarified layout)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container

/// Renders a treemap chart displaying hierarchical data as nested rectangles
/// sized proportionally to their values.
///
/// Uses a squarified layout algorithm for visually balanced aspect ratios.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels inside rectangles
/// - gap (length): Gap between rectangles
/// - theme (none, dictionary): Theme overrides
/// -> content
#let treemap(
  data,
  width: 300pt,
  height: 200pt,
  title: none,
  show-values: true,
  gap: 1.5pt,
  theme: none,
) = {
  validate-simple-data(data, "treemap")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let n = values.len()
  if n == 0 { return }

  // Build index-sorted pairs by value descending
  let indexed = array.range(n).map(i => (idx: i, val: values.at(i)))
  let sorted = indexed.sorted(key: item => -item.val)

  let total = values.sum()
  if total == 0 { total = 1 }

  // Squarified treemap layout algorithm
  // Returns array of (idx, x, y, w, h) rectangles
  let layout-rects = {
    // We'll use a strip-based squarified approach
    // For each strip we greedily add items while the worst aspect ratio improves
    let rects = ()
    let remaining = sorted
    let rx = 0.0    // remaining area x
    let ry = 0.0    // remaining area y
    let rw = width / 1pt  // remaining width (unitless)
    let rh = height / 1pt // remaining height (unitless)
    let remaining-total = total

    // Worst aspect ratio of a strip: given items with values, laid out along
    // a strip of length `side`, with total area `strip-area` for those items
    let worst-ratio(strip-values, side, strip-area) = {
      if strip-values.len() == 0 or side == 0 or strip-area == 0 { return 999.0 }
      let worst = 0.0
      for v in strip-values {
        let item-area = strip-area * (v / strip-values.sum())
        if item-area == 0 { continue }
        let other-side = item-area / side
        let ratio = if side > other-side { side / other-side } else { other-side / side }
        if ratio > worst { worst = ratio }
      }
      worst
    }

    while remaining.len() > 0 {
      if rw <= 0 or rh <= 0 { break }

      let total-area = rw * rh
      // Fraction of total value that maps to remaining area
      let area-scale = total-area / calc.max(remaining-total, 0.001)

      // Determine the short side (we lay strips along the short side)
      let short-side = calc.min(rw, rh)
      let horizontal = rw >= rh  // strips go left-to-right if wider

      let strip = ()
      let strip-vals = ()
      let strip-value-sum = 0

      // Greedily add items to strip
      for (si, item) in remaining.enumerate() {
        let new-vals = strip-vals + (item.val,)
        let new-sum = strip-value-sum + item.val
        let strip-area = new-sum * area-scale

        let new-ratio = worst-ratio(new-vals, short-side, strip-area)

        if strip-vals.len() > 0 {
          let old-area = strip-value-sum * area-scale
          let old-ratio = worst-ratio(strip-vals, short-side, old-area)
          if new-ratio > old-ratio {
            // Adding this item makes it worse, stop here
            break
          }
        }

        strip.push(item)
        strip-vals = new-vals
        strip-value-sum = new-sum
      }

      // If no items added (shouldn't happen), force one
      if strip.len() == 0 {
        strip = (remaining.at(0),)
        strip-vals = (remaining.at(0).val,)
        strip-value-sum = remaining.at(0).val
      }

      // Lay out the strip
      let strip-area = strip-value-sum * area-scale
      let strip-thickness = if short-side > 0 { strip-area / short-side } else { 0 }

      let offset = 0.0
      for item in strip {
        let item-frac = if strip-value-sum > 0 { item.val / strip-value-sum } else { 1.0 / strip.len() }
        let item-length = short-side * item-frac

        if horizontal {
          // Strip goes left-to-right, items stacked top-to-bottom
          rects.push((
            idx: item.idx,
            x: rx,
            y: ry + offset,
            w: strip-thickness,
            h: item-length,
          ))
        } else {
          // Strip goes top-to-bottom, items laid left-to-right
          rects.push((
            idx: item.idx,
            x: rx + offset,
            y: ry,
            w: item-length,
            h: strip-thickness,
          ))
        }

        offset += item-length
      }

      // Shrink remaining area
      if horizontal {
        rx += strip-thickness
        rw -= strip-thickness
      } else {
        ry += strip-thickness
        rh -= strip-thickness
      }

      remaining-total -= strip-value-sum
      remaining = remaining.slice(strip.len())
    }

    rects
  }

  // Render
  let gap-val = gap / 1pt

  chart-container(width, height, title, t, extra-height: 10pt)[
    #box(width: width, height: height)[
      #for r in layout-rects {
        let i = r.idx
        let rx = r.x * 1pt + gap / 2
        let ry = r.y * 1pt + gap / 2
        let rw = calc.max(r.w * 1pt - gap, 0pt)
        let rh = calc.max(r.h * 1pt - gap, 0pt)

        // Rectangle fill
        place(
          left + top,
          dx: rx,
          dy: ry,
          rect(
            width: rw,
            height: rh,
            fill: get-color(t, i),
            stroke: none,
            radius: 2pt,
          )
        )

        // Label and value text (only if rectangle is large enough)
        if rw > 20pt and rh > 14pt {
          let label-text = labels.at(i)
          let value-text = str(values.at(i))

          place(
            left + top,
            dx: rx + 4pt,
            dy: ry + 3pt,
            box(width: rw - 8pt, clip: true)[
              #text(
                size: calc.min(t.value-label-size, rh / 3),
                fill: white,
                weight: "bold",
              )[#label-text]
            ]
          )

          if show-values and rh > 26pt {
            place(
              left + top,
              dx: rx + 4pt,
              dy: ry + 3pt + calc.min(t.value-label-size, rh / 3) + 2pt,
              box(width: rw - 8pt, clip: true)[
                #text(
                  size: calc.min(t.value-label-size * 0.85, rh / 4),
                  fill: white.transparentize(20%),
                )[#value-text]
              ]
            )
          }
        }
      }
    ]
  ]
}
