#import "@preview/laskutys:1.0.0": *
#import "./config.typ": config

#let data = yaml("/template/data.yaml")

#invoice(
  colors: PRESET-FOREST,
  ..config,
  data,
)
