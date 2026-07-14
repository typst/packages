// Hero scene: a double helix assembled from fixed trigonometry, wearing all
// three pieces of annotation furniture at once — an orientation axes triad
// (bottom-left), a category legend (right) and a scalar colorbar (far right).
// Two coloured strands of shaded balls spiral up a shared axis; the rungs
// between them are tinted by height through the same colormap the colorbar
// samples. Everything is one `build-scene`, depth-sorted back-to-front.
#import "/lib.typ": sphere, seg, build-scene
#import "/lib.typ": camera, render-scene

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "New Computer Modern", size: 10pt)

#let strand-a = rgb("#4477aa") // muted blue
#let strand-b = rgb("#cc8963") // muted orange

// Height colormap, shared by the rungs and the colorbar (foot = low z).
#let heat = (rgb("#d9e2ec"), rgb("#aebfd0"), rgb("#7f9eb8"), rgb("#4f7898"))
#let heat-grad = gradient.linear(..heat)

#let rungs = 13
#let dz = 0.62
#let step = 52deg // turn per rung
#let radius = 1.25
#let top = (rungs - 1) * dz

#let prims = ()
#let prev-a = none
#let prev-b = none
#for i in range(rungs) {
  let ang = i * step
  let z = i * dz
  let a = (radius * calc.cos(ang), radius * calc.sin(ang), z)
  let b = (radius * calc.cos(ang + 180deg), radius * calc.sin(ang + 180deg), z)
  // backbone: connect each ball to its predecessor on the same strand
  if prev-a != none {
    prims.push(seg(prev-a, a, color: strand-a, w: 0.08))
    prims.push(seg(prev-b, b, color: strand-b, w: 0.08))
  }
  // rung across the pair, tinted by height
  prims.push(seg(a, b, color: heat-grad.sample(z / top * 100%), w: 0.09))
  // the base-pair balls
  prims.push(sphere(a, 0.32, color: strand-a))
  prims.push(sphere(b, 0.32, color: strand-b))
  prev-a = a
  prev-b = b
}

#let scene = build-scene(..prims)

#render-scene(
  scene,
  camera(azimuth: 35deg, elevation: 12deg),
  width: 8cm,
  axes: (vectors: ((1, 0, 0), (0, 1, 0), (0, 0, 1)), names: ($x$, $y$, $z$)),
  legend: (([strand A], strand-a), ([strand B], strand-b)),
  colorbar: (colormap: heat, range: (0, top)),
)
