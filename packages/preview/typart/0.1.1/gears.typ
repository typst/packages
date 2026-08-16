// Gears: up to 3 interlocking cogs.  Import with:  #import "gears.typ": gears
//
//   #gears(([Research], [Development], ([Production], rgb("#e64553"))))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let gears(
  items,
  r: 2.6, teeth: 10,
  text-fill: rgb("#1f1f3a"), size: 15pt,
) = canvas({
  import draw: *
  let n = calc.min(items.len(), 3)
  let d = r * 1.62
  let step = 360deg / teeth
  let cog(cx, cy, fill, phase) = {
    let pts = ()
    let rin = r * 0.80
    for t in range(teeth) {
      let a = phase + t * step
      pts.push((cx + rin * calc.cos(a), cy + rin * calc.sin(a)))
      pts.push((cx + r * calc.cos(a + step * 0.25), cy + r * calc.sin(a + step * 0.25)))
      pts.push((cx + r * calc.cos(a + step * 0.5), cy + r * calc.sin(a + step * 0.5)))
      pts.push((cx + rin * calc.cos(a + step * 0.75), cy + rin * calc.sin(a + step * 0.75)))
    }
    line(..pts, close: true, fill: fill, stroke: none)
    circle((cx, cy), radius: r * 0.32, fill: white)
  }
  for (i, it) in items.slice(0, n).enumerate() {
    let cx = i * d - (n - 1) * d / 2
    cog(cx, 0, _col(it, i), if calc.rem(i, 2) == 0 { 0deg } else { step / 2 })
    content((cx, 0), box(width: r * 0.7 * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
})
