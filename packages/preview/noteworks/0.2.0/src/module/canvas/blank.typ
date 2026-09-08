// =====================================================
// BLANK CANVAS - Simple canvas without axes
// =====================================================

#import "@preview/cetz:0.4.2"
#import "draw.typ": draw-geo
#import "../combi/draw.typ": draw-combi
#import "../combi/combi.typ": is-combi-obj
#import "../trees/mod.typ": draw-tree, is-tree
#import "../dsa/mod.typ": draw-dsa, is-dsa-obj

/// Create a blank canvas for diagrams
/// No axes or grid, just a drawing area.
/// Applies global smart labeling for vectors based on angular span.
///
/// Parameters:
/// - theme: Theme dictionary for styling
/// - size: Canvas dimensions (default: auto)
/// - ..objects: Geometry objects to render
#let blank-canvas(
  theme: (:),
  size: auto,
  ..objects,
) = {
  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let bg-col = theme.at("page-fill", default: none)

  // Flatten input - vec-add/vec-project return arrays
  let flat-objs = ()
  for obj in objects.pos() {
    if type(obj) == array {
      for sub in obj { flat-objs.push(sub) }
    } else {
      flat-objs.push(obj)
    }
  }

  // Collect all vectors for global smart labeling
  let vectors = ()
  let non-vectors = ()
  for obj in flat-objs {
    if type(obj) == dictionary and obj.at("type", default: none) == "vector" {
      vectors.push(obj)
    } else {
      non-vectors.push(obj)
    }
  }

  // Calculate angles for all vectors
  let vec-with-angles = vectors.map(v => {
    let angle = calc.atan2(v.y, v.x).deg()
    let angle = if angle < 0 { angle + 360 } else { angle }
    (vec: v, angle: angle)
  })

  // Sort by angle
  let sorted = vec-with-angles.sorted(key: va => va.angle)
  let all-angles = sorted.map(va => va.angle)

  cetz.canvas({
    import cetz.draw: *
    import "draw.typ": compute-vector-label-pos, draw-geo, format-label

    set-style(stroke: stroke-col, fill: none)
    let bounds = (x: (-10, 10), y: (-10, 10))

    // Draw non-vector objects first
    for obj in non-vectors {
      if type(obj) == dictionary and obj.at("type", default: none) != none {
        if is-combi-obj(obj) {
          draw-combi(obj, theme)
        } else if is-tree(obj) {
          draw-tree(obj, theme)
        } else if is-dsa-obj(obj) {
          draw-dsa(obj, theme)
        } else {
          draw-geo(obj, theme, bounds: bounds)
        }
      } else if type(obj) != dictionary {
        obj
      }
    }

    // Draw vectors with centered pill labels
    for va in sorted {
      let v = va.vec
      let v-col = if v.style != auto and v.style != none and "stroke" in v.style { v.style.stroke } else {
        stroke-col
      }

      // Get vector origin and endpoint
      let origin = v.at("origin", default: (0, 0))
      let sx = if type(origin) == dictionary { origin.x } else { origin.at(0) }
      let sy = if type(origin) == dictionary { origin.y } else { origin.at(1) }
      let ex = sx + v.x
      let ey = sy + v.y

      // Draw vector
      line(
        (sx, sy),
        (ex, ey),
        stroke: (paint: v-col, thickness: 1.5pt),
        mark: (end: "stealth", fill: v-col),
      )

      // Draw label with pill background at midpoint
      if v.at("label", default: none) != none {
        let mx = (sx + ex) / 2
        let my = (sy + ey) / 2
        let pill-half-width = 0.3

        // Background pill
        rect(
          (mx - pill-half-width, my - 0.18),
          (mx + pill-half-width, my + 0.18),
          fill: bg-col,
          stroke: (paint: v-col, thickness: 0.5pt),
          radius: 0.1,
        )

        content(
          (mx, my),
          text(fill: v-col, weight: "bold", format-label(v, v.label)),
          anchor: "center",
        )
      }
    }
  })
}

/// Create a simple canvas with custom drawing commands
/// Useful for direct CeTZ usage with theme styling.
///
/// Parameters:
/// - theme: Theme dictionary for styling
/// - body: CeTZ drawing commands
#let simple-canvas(
  theme: (:),
  body,
) = {
  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)

  cetz.canvas({
    import cetz.draw: *
    set-style(stroke: stroke-col, fill: none)
    body
  })
}
