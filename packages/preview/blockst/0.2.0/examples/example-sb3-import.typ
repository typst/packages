#import "@preview/blockst:0.2.0": blockst, sb3

#set page(width: 10cm, height: auto, margin: 3mm, fill: white)

#let project = read("../examples/Mampf-Matze Lösung.sb3", encoding: none)

#blockst[
  #sb3.sb3-screen-preview(project, unit: 1.5)

  #v(4mm)

  #sb3.render-sb3-scripts(
    project,
    language: "en",
    target: "Pacman",
    target-script-number: 2,
    show-headers: true,
  )
]