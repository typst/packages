#import "@preview/axodendron:0.1.0" as swc

#set page(width: auto, height: auto, margin: 3mm)

#let render-file(file) = {
  let cell = swc.load(read(file, encoding: none), profile: "incf-strict")
  swc.render(
    cell,
    width: 82mm,
    height: 72mm,
    canvas-width: 820,
    canvas-height: 720,
  )
}

#grid(
  columns: (auto, auto, auto),
  gutter: 3mm,
  render-file("data/AA0109.CNG.swc"),
  render-file("data/Nr5a1-Cre_Ai14-187777-05-02-01_491392821_m.kp1.swc"),
  render-file("data/Vipr2-IRES2-Cre_Ai14-310513-05-02-01_637021223_m.CNG.swc"),
)
