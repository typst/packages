#import "@preview/blockst:0.2.0": blockst, sb3

#set page(width: auto, height: auto, margin: 3mm, fill: white)

#let project = read("Mampf-Matze Lösung.sb3", encoding: none)

#stack(
  spacing: 4mm,
  sb3.render-sb3-variables(project, language: "en", show-target-headers: false),
  sb3.render-sb3-lists(project, language: "en", show-target-headers: false),
)
