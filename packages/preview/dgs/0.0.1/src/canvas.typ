#import "style.typ": parse-color, color-to-hex

/// The DGS canvas - renders geometric objects into a coordinate system.
#let dgs-canvas(
  x1: 0, y1: 0, x2: 10, y2: 10,
  width: 300pt, height: 300pt,
  theme: "light",
  grid: true,
  grid-color: auto,
  grid-width: auto,
  grid-spacing: auto,
  axes: true,
  axis-color: auto,
  axis-width: auto,
  axis-label-size: auto,
  objects: (),
) = {
  // 1. Build point lookup from all dgs-point objects
  let point-lookup = (:)
  for obj in objects {
    if type(obj) == dictionary and "type" in obj and obj.type == "point" and obj.name != none {
      point-lookup.insert(obj.name, obj.coords)
    }
  }

  // 2. Helper to resolve a point reference
  let resolve-pt = (pt) => {
    if type(pt) == array { return pt }
    if type(pt) == str and pt in point-lookup { return point-lookup.at(pt) }
    return pt
  }

  // 3. Resolve all objects (substitute named point references with coords)
  let resolved = objects.map(obj => {
    if type(obj) != dictionary or "type" not in obj { return obj }
    let o = obj
    if o.type == "line" {
      o.insert("from", resolve-pt(o.from))
      o.insert("to", resolve-pt(o.to))
    } else if o.type == "circle" {
      o.insert("center", resolve-pt(o.center))
    } else if o.type == "polygon" {
      o.insert("points", o.points.map(p => resolve-pt(p)))
    } else if o.type == "ellipse" {
      o.insert("center", resolve-pt(o.center))
    } else if o.type == "arc" {
      o.insert("center", resolve-pt(o.center))
    }
    o
  })

  // 4. Build the CBOR payload
  let payload = (
    viewport: (x1: x1 * 1.0, y1: y1 * 1.0, x2: x2 * 1.0, y2: y2 * 1.0,
               width: width / 1pt * 1.0, height: height / 1pt * 1.0),
    theme: theme,
    grid: grid,
    grid-color: if grid-color != auto { grid-color } else { none },
    grid-width: if grid-width != auto { grid-width / 1pt } else { none },
    grid-spacing: if grid-spacing != auto { grid-spacing * 1.0 } else { none },
    axes: axes,
    axis-color: if axis-color != auto { axis-color } else { none },
    axis-width: if axis-width != auto { axis-width / 1pt } else { none },
    axis-label-size: if axis-label-size != auto { axis-label-size / 1pt } else { none },
    objects: resolved,
  )

  // 5. Call WASM plugin
  let dgs = plugin("../wasm/dgs_wasm.wasm")
  let svg-bytes = cbor.encode(payload)
  let svg-result = dgs.render_dgs(svg-bytes)

  // 6. Return SVG as content
  image(svg-result, format: "svg")
}
