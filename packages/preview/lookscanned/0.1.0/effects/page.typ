// Page background (paper, grain, stains) and foreground (scanner artefacts,
// dust, lighting, punch holes).
#import "../wasm.typ": texture
#import "../validate.typ": resolve

// `lookscanned.page` wraps its body between these two labels.
#let start-label = <lookscanned-page-start>
#let end-label = <lookscanned-page-end>

// Configuration for page `p`, with `lookscanned.page` overrides. Needs context.
#let cfg-at(cfg, p) = {
  let starts = query(start-label)
  if starts.len() == 0 { return cfg }
  let out = cfg
  for (s, e) in starts.zip(query(end-label)) {
    if s.location().page() <= p and p <= e.location().page() {
      out = resolve(s.value, parent: cfg)
    }
  }
  out
}

#let _tile = 40mm

// A tiling is stored once in the PDF, however many pages repeat it.
#let _tiled(kind, ..args) = rect(
  width: 100%,
  height: 100%,
  stroke: none,
  fill: tiling(size: (_tile, _tile), texture(kind, width: _tile, height: _tile, ..args)),
)

#let _layer(..items) = items.pos().filter(i => i != none).map(i => place(top + left, i)).join()

#let background(cfg) = context {
  let p = here().page()
  let c = cfg-at(cfg, p)
  let res = c.quality.resolution
  let seed = c.seed * 1000 + p
  let full = page.height != auto
  _layer(
    if full and (c.paper.grain > 0 or c.paper.aging > 0) {
      texture("paper", seed: seed, resolution: res, color: c.paper.color, grain: c.paper.grain, aging: c.paper.aging)
    } else if c.paper.color != white {
      rect(width: 100%, height: 100%, fill: c.paper.color)
    },
    if c.paper.grain > 0 or c.paper.fibers > 0 {
      let args = (seed: if c.quality.tile { c.seed + 1 } else { seed + 1 }, resolution: res, amount: c.paper.grain, fibers: c.paper.fibers)
      if c.quality.tile or not full { _tiled("grain", ..args) } else { texture("grain", ..args) }
    },
    if c.stains.amount > 0 and full {
      texture("stains", seed: seed + 2, resolution: res, color: c.stains.color, amount: c.stains.amount, min: c.stains.size.min, max: c.stains.size.max)
    },
  )
}

#let foreground(cfg) = context {
  let p = here().page()
  let c = cfg-at(cfg, p)
  let res = c.quality.resolution
  let seed = c.seed * 1000 + p
  let full = page.height != auto
  _layer(
    if c.scanner.lines > 0 and full { texture("lines", seed: seed + 4, resolution: res, amount: c.scanner.lines, axis: "h") },
    if c.scanner.bands > 0 and full { texture("lines", seed: seed + 5, resolution: res, amount: c.scanner.bands, axis: "v") },
    if (c.stains.dust > 0 or c.stains.scratches > 0) and full {
      texture("dust", seed: seed + 6, resolution: res, amount: c.stains.dust, scratches: c.stains.scratches)
    },
    if (c.edges.shadow > 0 or c.edges.vignette > 0 or c.edges.uneven > 0 or c.edges.binding) and full {
      texture("edges", seed: seed + 7, resolution: res, shadow: c.edges.shadow, vignette: c.edges.vignette, uneven: c.edges.uneven, binding: c.edges.binding)
    },
    if c.edges.punch-holes and full {
      // ISO 838: 6 mm holes, 80 mm apart, centred 12 mm from the edge.
      block(width: 100%, height: 100%, for dy in (-40mm, 40mm) {
        place(left + horizon, dx: 12mm - 3mm, dy: dy, circle(radius: 3mm, fill: luma(55), stroke: 0.6pt + luma(30)))
      })
    },
  )
}
