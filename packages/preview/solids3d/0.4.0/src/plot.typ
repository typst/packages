// plot.typ — high-level plotting facades for projected solids.
//
// `solid-plot` is deliberately small: it composes the existing surface and
// outline commands in the same way Matplotlib composes plot_surface and
// plot_wireframe, while retaining solids3d's depth sorting and projections.

#import "picture.typ": *
#import "projection.typ": *
#import "surface.typ": *
#import "pens.typ": *

#let solid-plot(shape, size: 6cm, projection: currentprojection,
  light: currentlight, style: "none", surfacepen: none, meshpen: none,
  hatch: none, stipple: none, outline: none, m: auto, n: nslice,
  shading: "smooth", refine: true, backend: "svg") = {
  let commands = ()
  if surfacepen != none or meshpen != none or hatch != none or stipple != none {
    commands += draw(surface(shape), pen: surfacepen, meshpen: meshpen,
      hatch: hatch, stipple: stipple)
  }
  if outline != none {
    commands += draw(shape, m: m, n: n, frontpen: outline)
  }
  picture(size: size, projection: projection, light: light, style: style,
    shading: shading, refine: refine, backend: backend, ..commands)
}

// Alias with a name familiar from plotting libraries.
#let plot3d = solid-plot
