// Print preview — one nested file box in both reading directions.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 14cm, height: 5.4cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #nested-file-text-box(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc.],
      number: "01",
      icon: image("assets/nested-file-lightbulb.png", width: 0.62cm),
      print-icon: image("assets/nested-file-lightbulb.png", width: 0.62cm),
      width: 7.5cm,
      height: 2.7cm,
      direction: ltr,
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #nested-file-text-box(
      title: [معلومة مفيدة],
      body: [تساعد هذه المساحة على ترتيب الفكرة وشرحها بوضوح، مع عنوان مختصر يسهّل تذكّرها.],
      number: "٠١",
      icon: image("assets/nested-file-lightbulb.png", width: 0.62cm),
      print-icon: image("assets/nested-file-lightbulb.png", width: 0.62cm),
      width: 7.5cm,
      height: 2.7cm,
      direction: rtl,
    )
  ]
]
