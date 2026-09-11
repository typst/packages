// 3D plot canvas setup and dispatch.

#import "@preview/cetz:0.5.2" as cetz
#import "axes3d.typ": draw-axes-3d

#let plot3d(
  ..series,
  xmin: -3, xmax: 3,
  ymin: -3, ymax: 3,
  zmin: -3, zmax: 3,
  width: 10,
  height: 8,
  azimuth: 45deg,
  elevation: 30deg,
  xlabel: $x$,
  ylabel: $y$,
  zlabel: $z$,
  xtick-step: auto,
  ytick-step: auto,
  ztick-step: auto,
  show-grid: true,
  show-frame: false,
  axis-stroke: 0.6pt + black,
  grid-stroke: 0.3pt + luma(200),
  colormap: auto,
) = {
  import cetz.draw: *

  let all-series = series.pos()

  let sx = width / (xmax - xmin)
  let sy = width / (ymax - ymin)
  let sz = height / (zmax - zmin)

  cetz.canvas(length: 1cm, {
    ortho(
      x: -elevation,
      y: 0deg,
      z: -azimuth,
      sorted: true,
      cull-face: none,
      {
        scale(x: sx, y: sy, z: sz)

        draw-axes-3d(
          xmin, xmax,
          ymin, ymax,
          zmin, zmax,
          xlabel: xlabel,
          ylabel: ylabel,
          zlabel: zlabel,
          xtick-step: xtick-step,
          ytick-step: ytick-step,
          ztick-step: ztick-step,
          show-grid: show-grid,
          show-frame: show-frame,
          axis-stroke: axis-stroke,
          grid-stroke: grid-stroke,
        )

        for spec in all-series {
          if type(spec) != dictionary { continue }

          if "surface" in spec {
            let surf-fn = spec.at("surface")
            let s-samples = spec.at("samples", default: 40)
            let s-colormap = spec.at("colormap", default: colormap)
            let s-stroke = spec.at("stroke", default: 0.3pt + luma(80))
            let s-opacity = spec.at("opacity", default: 80%)

            let ramp = if s-colormap == auto {
              gradient.linear(..color.map.viridis)
            } else if type(s-colormap) == array {
              gradient.linear(..s-colormap)
            } else {
              s-colormap
            }

            let xs = range(s-samples + 1).map(i => xmin + i * (xmax - xmin) / s-samples)
            let ys = range(s-samples + 1).map(i => ymin + i * (ymax - ymin) / s-samples)

            let z-grid = xs.map(x => ys.map(y => {
              let z = surf-fn(x, y)
              if z == none or float(z).is-nan() { none } else { float(z) }
            }))

            for i in range(s-samples) {
              for j in range(s-samples) {
                let z00 = z-grid.at(i).at(j)
                let z10 = z-grid.at(i + 1).at(j)
                let z01 = z-grid.at(i).at(j + 1)
                let z11 = z-grid.at(i + 1).at(j + 1)

                if z00 == none or z10 == none or z01 == none or z11 == none { continue }

                let z-avg = (z00 + z10 + z01 + z11) / 4
                let z-norm = (z-avg - zmin) / (zmax - zmin)
                let z-norm = calc.clamp(z-norm, 0, 1)
                let face-color = ramp.sample(z-norm * 100%).transparentize(100% - s-opacity)

                let x0 = xs.at(i)
                let x1 = xs.at(i + 1)
                let y0 = ys.at(j)
                let y1 = ys.at(j + 1)

                line(
                  (x0, y0, z00), (x1, y0, z10),
                  (x1, y1, z11), (x0, y1, z01),
                  close: true,
                  fill: face-color,
                  stroke: s-stroke,
                )
              }
            }
          } else if "parametric-surface" in spec {
            let ps-fn = spec.at("parametric-surface")
            let (u0, u1) = spec.at("u-range", default: (0, 1))
            let (v0, v1) = spec.at("v-range", default: (0, 1))
            let u-n = spec.at("u-samples", default: 40)
            let v-n = spec.at("v-samples", default: 40)
            let ps-colormap = spec.at("colormap", default: colormap)
            let ps-stroke = spec.at("stroke", default: 0.3pt + luma(80))
            let ps-opacity = spec.at("opacity", default: 80%)

            let ramp = if ps-colormap == auto {
              gradient.linear(..color.map.viridis)
            } else if type(ps-colormap) == array {
              gradient.linear(..ps-colormap)
            } else {
              ps-colormap
            }

            let grid = range(u-n + 1).map(i => {
              let u = u0 + i * (u1 - u0) / u-n
              range(v-n + 1).map(j => {
                let v = v0 + j * (v1 - v0) / v-n
                let pt = ps-fn(u, v)
                if pt == none { none }
                else { (float(pt.at(0)), float(pt.at(1)), float(pt.at(2))) }
              })
            })

            for i in range(u-n) {
              for j in range(v-n) {
                let p00 = grid.at(i).at(j)
                let p10 = grid.at(i + 1).at(j)
                let p01 = grid.at(i).at(j + 1)
                let p11 = grid.at(i + 1).at(j + 1)

                if p00 == none or p10 == none or p01 == none or p11 == none { continue }

                let z-avg = (p00.at(2) + p10.at(2) + p01.at(2) + p11.at(2)) / 4
                let z-norm = calc.clamp((z-avg - zmin) / (zmax - zmin), 0, 1)
                let face-color = ramp.sample(z-norm * 100%).transparentize(100% - ps-opacity)

                line(
                  (p00.at(0), p00.at(1), p00.at(2)),
                  (p10.at(0), p10.at(1), p10.at(2)),
                  (p11.at(0), p11.at(1), p11.at(2)),
                  (p01.at(0), p01.at(1), p01.at(2)),
                  close: true,
                  fill: face-color,
                  stroke: ps-stroke,
                )
              }
            }
          } else if "parametric-curve" in spec {
            let pc-fn = spec.at("parametric-curve")
            let (t0, t1) = spec.at("t-range", default: (0, 1))
            let pc-n = spec.at("samples", default: 100)
            let pc-stroke = spec.at("stroke", default: 1.2pt + blue)

            let pts = range(pc-n + 1).map(i => {
              let t = t0 + i * (t1 - t0) / pc-n
              let pt = pc-fn(t)
              if pt == none { none }
              else { (float(pt.at(0)), float(pt.at(1)), float(pt.at(2))) }
            }).filter(p => p != none)

            if pts.len() >= 2 {
              line(
                ..pts.map(p => (p.at(0), p.at(1), p.at(2))),
                stroke: pc-stroke,
              )
            }
          } else if "quiver3d" in spec {
            let q-field = spec.at("quiver3d")
            let qx-step = spec.at("x-step", default: 1)
            let qy-step = spec.at("y-step", default: 1)
            let qz-step = spec.at("z-step", default: 1)
            let q-scale = spec.at("scale", default: auto)
            let q-pivot = spec.at("pivot", default: "center")
            let q-stroke = spec.at("stroke", default: 1pt + black)
            let q-color = spec.at("color", default: black)

            let grid-xs = ()
            let gx = calc.ceil(xmin / qx-step) * qx-step
            while gx <= xmax + 1e-9 {
              grid-xs.push(gx)
              gx += qx-step
            }
            let grid-ys = ()
            let gy = calc.ceil(ymin / qy-step) * qy-step
            while gy <= ymax + 1e-9 {
              grid-ys.push(gy)
              gy += qy-step
            }
            let grid-zs = ()
            let gz = calc.ceil(zmin / qz-step) * qz-step
            while gz <= zmax + 1e-9 {
              grid-zs.push(gz)
              gz += qz-step
            }

            let arrows = ()
            let magnitudes = ()
            for gx in grid-xs {
              for gy in grid-ys {
                for gz in grid-zs {
                  let result = q-field(gx, gy, gz)
                  let (u, v, w) = (float(result.at(0)), float(result.at(1)), float(result.at(2)))
                  if u.is-nan() or v.is-nan() or w.is-nan() { continue }
                  let mag = calc.sqrt(u * u + v * v + w * w)
                  magnitudes.push(mag)
                  arrows.push((x: gx, y: gy, z: gz, u: u, v: v, w: w, mag: mag))
                }
              }
            }

            if arrows.len() > 0 {
              let sc = if q-scale != auto {
                q-scale
              } else {
                let avg = magnitudes.sum() / magnitudes.len()
                if avg < 1e-12 { 1.0 } else {
                  let n = magnitudes.len()
                  let compensation = calc.max(4.0, calc.pow(float(n), 0.6) * 0.6)
                  1.0 / (0.54 * avg * compensation)
                }
              }

              for a in arrows {
                let su = a.u * sc
                let sv = a.v * sc
                let sw = a.w * sc

                let (ox, oy, oz) = if q-pivot == "center" { (-su / 2, -sv / 2, -sw / 2) }
                                   else if q-pivot == "end" { (-su, -sv, -sw) }
                                   else { (0, 0, 0) }

                let start = (a.x + ox, a.y + oy, a.z + oz)
                let end = (a.x + ox + su, a.y + oy + sv, a.z + oz + sw)

                if a.mag < 1e-12 {
                  circle(start, radius: 0.02, fill: q-color, stroke: none)
                } else {
                  line(start, end, stroke: q-stroke, mark: (end: ">", fill: q-color))
                }
              }
            }
          }
        }
      },
    )
  })
}
