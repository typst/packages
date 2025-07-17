#import "@preview/laskutys:1.1.0": *
#import "./config.typ": config

#let data = yaml("/template/data.yaml")

#invoice(
  colors: PRESET-OCEAN,
  ..config,
  data,
)
