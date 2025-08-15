#import "@submit/presentate:0.2.0": *
#import themes.default: * 

#show: template.with(
  aspect-ratio: "16-9"
)

= New Section

#slide[
  == Hello
  This is default theme slide.  
]

#empty-slide[
  #set align(center + horizon)
  `#empty-slide` is the slide with nothing, \
  even the `header` and `footer`.
]