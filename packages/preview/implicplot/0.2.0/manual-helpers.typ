// The manual's drawing helpers. Nothing here is part of the plugin's API -
// a chain is points and a raster is bytes; this is one way to draw them.
#import "@preview/implicplot:0.2.0" as ip

#let accent = rgb("#0078d4")
// Opaque on purpose: fill rows overlap by a hair to defeat antialiasing seams,
// which only stays invisible if the colour carries no alpha.
#let tint = color.mix((accent, 18%), (white, 82%))

#let chains-label(n) = if n == 1 [1 chain] else [#n chains]

// A raster as ASCII art, for small demonstrations.
#let art(pixels, width) = raw(
  ip.rows(pixels, width).map(row => row.map(v => if v == 1 { "#" } else { "." }).join()).join("\n"),
)

// Stroke polylines from `contour` into a `size`-square box over `span`.
#let stroke-chains(chains, span, size, weight: 0.7pt, color: accent) = {
  let place-at(p) = (
    size * (p.at(0) - span.at(0)) / (span.at(1) - span.at(0)),
    size * (1 - (p.at(1) - span.at(0)) / (span.at(1) - span.at(0))),
  )
  for chain in chains {
    let points = chain.map(place-at)
    place(curve(
      stroke: weight + color,
      curve.move(points.first()),
      ..points.slice(1).map(p => curve.line(p)),
    ))
  }
}

// Fill the region bounded by CLOSED chains as one vector path; the even-odd
// rule turns containment into holes. A chain that runs off the window would be
// auto-closed with a straight chord and fill the wrong region - that is what
// the raster fill below is for.
#let fill-chains(chains, span, size, fill: tint, stroke: none) = {
  let place-at(p) = (
    size * (p.at(0) - span.at(0)) / (span.at(1) - span.at(0)),
    size * (1 - (p.at(1) - span.at(0)) / (span.at(1) - span.at(0))),
  )
  let elements = ()
  for chain in chains {
    let points = chain.map(place-at)
    elements.push(curve.move(points.first()))
    for p in points.slice(1) { elements.push(curve.line(p)) }
    elements.push(curve.close())
  }
  place(curve(fill: fill, fill-rule: "even-odd", stroke: stroke, ..elements))
}

// Paint a raster into a `size`-square box, merging each row's consecutive lit
// pixels into one rect: 150 x 150 becomes a few hundred elements, not 22500.
#let fill-runs(pixels, width, size, color: tint) = {
  let cell = size / width
  for (r, row) in ip.rows(pixels, width).enumerate() {
    let c = 0
    while c < width {
      if row.at(c) == 1 {
        let start = c
        while c < width and row.at(c) == 1 { c += 1 }
        place(dx: start * cell, dy: r * cell, rect(
          width: (c - start) * cell,
          height: cell + 0.2pt,
          fill: color,
          stroke: none,
        ))
      } else { c += 1 }
    }
  }
}
