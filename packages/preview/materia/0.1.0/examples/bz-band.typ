// The Brillouin zone beside a band-path panel: the fcc BZ with the Γ–X–W–K–Γ–L
// path on the left, and — on the right — three honest tight-binding bands plotted
// against distance along that same path, with Γ/X/W/K/L ticks. The bands are
// fixed nearest-neighbour fcc dispersions E(k) ∝ Σ cos(kᵢa/2)cos(kⱼa/2), sampled
// at the exact Cartesian k-points `band-axis` returns — no external data, no
// randomness. (For real band structures, feed your own arrays to `band-panel`,
// or reach for lilaq for serious plotting.)
#import "/lib.typ": bz-figure, band-panel, band-axis
#import "@preview/scenery:0.1.0": default-theme

#set page(width: auto, height: auto, margin: 0.4cm)
#set text(font: "New Computer Modern", size: 9pt)

#let a = 3.61
#let params = (a: a)
#let seq = ("Γ", "X", "W", "K", "Γ", "L")
#let ax = band-axis("cF", params, seq, samples: 40)
#let band-theme = default-theme + (palette: (rgb("#3f5f78"),),)

// fcc nearest-neighbour structure factor at a Cartesian k = (kx, ky, kz).
#let sfac(k) = {
  let (kx, ky, kz) = k
  let s = (
    calc.cos(kx * a / 2) * calc.cos(ky * a / 2)
      + calc.cos(ky * a / 2) * calc.cos(kz * a / 2)
      + calc.cos(kz * a / 2) * calc.cos(kx * a / 2)
  )
  s
}
// Three separated cos-bands (energies in arbitrary units).
#let band1 = ax.carts.map(k => -1.0 - 0.6 * sfac(k))
#let band2 = ax.carts.map(k => 2.0 + 0.4 * sfac(k))
#let band3 = ax.carts.map(k => 4.5 - 0.3 * sfac(k))

#grid(
  columns: 2,
  column-gutter: 1.4em,
  align: horizon,
  bz-figure(params, bravais: "cF", path: seq, width: 5.2cm),
  band-panel((band1, band2, band3), ax, width: 8cm, height: 5cm, theme: band-theme),
)
