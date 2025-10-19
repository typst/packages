#import "@preview/lilaq:0.5.0" as lq
#import "@preview/colorful-boxes:1.4.3": colorbox, outline-colorbox

#set lq.style(stroke: 4pt) // lines & marks pick this up
#show: lq.set-spine(stroke: 2pt) // axis lines (spines)
#show: lq.set-tick(stroke: 2pt) // tick marks
#show: lq.set-grid(stroke: 2pt) // grid is independent; tune as you like

#let plot-size = (width: 100%, height: 17%)

#let boxed(content, title: none) = {
  outline-colorbox(title: title, radius: 2mm)[
    #content
  ]
}

#boxed(
  {
    lq.diagram(
      ..plot-size,
      lq.plot(
        (0.3, 0.5, 0.8, 1.2, 2.0, 3.0, 4.0, 6.0),
        (1.72, 1.35, 1.05, 0.86, 0.55, 0.38, 0.30, 0.20),
        yerr: (0.20, 0.18, 0.15, 0.14, 0.12, 0.10, 0.10, 0.08),
        stroke: blue.darken(30%),
        mark: "star",
        mark-size: 5pt,
      ),
    )
  },
  title: [1919 Eclipse: Light Deflection vs. Solar Elongation],
)

#boxed(
  lq.diagram(
    ..plot-size,
    lq.boxplot(
      stroke: blue.darken(50%),
      (-0.12, -0.05, 0.00, 0.03, 0.08, 0.15, 0.21, 0.30, 0.35, 0.48, 0.60),
      range(-1, 1),
      // Quartiles (Q1, median, Q3)
      (-0.05, 0.08, 0.30),
      // Outliers
      (-0.42, 0.72),
    ),
  ),
  title: [Deflection Measurement Variability],
)


#boxed(
  lq.diagram(
    ..plot-size,
    lq.quiver(
      lq.arange(-3, 4),
      lq.arange(-3, 4),
      (x, y) => {
        let r2 = x * x + y * y + 0.25
        (-x / r2, -y / r2)
      },
    ),
  ),
  title: [Inverse-Square Gravitational Field],
)


#boxed(
  lq.diagram(
    ..plot-size,
    lq.colormesh(
      lq.linspace(-4, 4, num: 40),
      lq.linspace(-4, 4, num: 40),
      (x, y) => -1 / (0.5 + x * x + y * y),
      map: color.map.magma,
    ),
  ),
  title: [Relativistic Time Effects],
)
