#import "@preview/panfig:0.1.0": panfig

#set page(width: auto, height: auto, margin: 12pt)

#figure(
  panfig("hydrogen.pgf", width: 8cm, height: 6cm, fit: "contain", resolve: p => path(p)),
  caption: [Hydrogen atom wavefunction probability densities $|psi_(n ell m)(r, theta, phi)|^2$.],
)
