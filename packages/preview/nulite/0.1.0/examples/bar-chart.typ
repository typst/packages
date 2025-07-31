#set page(width: 200mm, height: 150mm, margin: 10mm)
#import "@preview/nulite:0.1.0" as vegalite

#vegalite.render(
  width: 100%,
  height: 100%,
  zoom: 1,
  json("spec.json")
  )