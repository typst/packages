#import "@submit/presentate:0.2.0": *
#import themes.simple: *

#show: template.with(
  author: [Pacaunt], // change to yours!
  title: [Welcome To Presentate!],
  subtitle: [Slides Tools.],
)

= New Section

#slide[Hello][
  This is Simple theme slide.
]

#slide[
  Slide with no title will continue from the last title.
]

#focus-slide[
  This should be focus!
]

#empty-slide[
  #set align(center + horizon)
  `#empty-slide` is the slide with nothing, \
  even the `header` and `footer`.
]

