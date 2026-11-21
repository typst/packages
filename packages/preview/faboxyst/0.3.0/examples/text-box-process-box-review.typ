// Visual review of one source-faithful Text Box Process component.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 14cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 10pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #text-box-process-box(
    title: [LOREM IPSUM],
    number: [01],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec non ornare dolor, non iaculis nibh. Morbi sed massa nec diam porttitor sodales. #parbreak() Vivamus molestie nisl sed erat sodales dignissim. Duis sed diam sed quam pharetra accumsan. #parbreak() Donec sit amet urna eros. Donec semper diam nec varius facilisis. Praesent varius tempus magna, quis feugiat elit eros sed euismod lacinia.],
    colour: rgb("#3E6188"),
    direction: ltr,
  )
]
