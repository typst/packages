#import "../src/page-statistics.typ": page-stats

#let SLIDES_PER_SECTION = (
  (
    title: "First",
    slides: 5
  ),
  (
    title: "Second",
    slides: 6
  ),
  (
    title: "Third",
    slides: 8
  ),
  (
    title: "Fourth",
    slides: 3
  ),
)



#for section in SLIDES_PER_SECTION [
  = #section.title
  #for i in range(section.slides, ) [
    == Slide #{i + 1}
    #page-stats
  ]
]
