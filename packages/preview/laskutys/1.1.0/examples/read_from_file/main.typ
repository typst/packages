#import "@preview/laskutys:1.1.0": *

#let data = yaml("data.yaml")
#let config = yaml("config.yaml")

#invoice(
  ..config,
  data,
)
