#import "@preview/tuhi-postcard-vuw:0.1.0": tuhi-postcard-vuw

#let c1= rgb(110,81,55) // dark background
#let c2= rgb(214, 221, 217) // complementary light

#let palette(c1,c2) = (c1,c2,c1.oklch().desaturate(30%).lighten(50%),c2.oklch().lighten(60%))

#let cols=palette(c1,c2)

// #let palette-draw = cols.map(c => box(inset: 1pt)[#rect(fill: c, width: 3.5em,height:1em, stroke: black + 0.2pt)])

// custom fancy title
#let make-title(col1, col2) = {
  upper[#text(fill: col1,size: 35pt, font: ("Inter", "Noto Serif CJK JP"), weight: 800, tracking:0.0pt)[ Gongfu \ Cha#h(4pt)#box(baseline:-2pt,text(size:23pt, fill: col2)[功夫茶])]]
}

// discipline has two versions
#let discipline = (
  make-title(cols.at(2),cols.at(1)), 
  make-title(cols.at(3),cols.at(2))
  )

#let opening = text[
  Discover the art and science of Gongfu Cha. Uncover the traditions and techniques behind this ancient tea ceremony, and learn how to perfect your own tea-making skills.
  ]

#let introduction = text[
  Gongfu Cha is more than just making tea—it's an art form that embodies centuries of tradition and cultural significance. Through the meticulous process that transforms simple tea leaves into a transcendent journey, you will form timeless bonds with water, air and fire, reaching a pinnacle of mindfulness and elegance.
  ]

#let description = text[
  Our Gongfu Cha course covers everything from the selection of tea leaves to the precise movements required for the ceremony. Understand the philosophy behind Gongfu Cha and its impact on mindfulness and relaxation.

You'll explore different types of leaf processing, the importance of Qi, and utensils used in Gongfu Cha. This course blends theoretical knowledge with practical sessions to unfold your tea-making skills whenever stepping into hot water leaves you dry.
]

#let pitch = text[
  Upon completing this course, you'll have a deep aversion for teabags and the expertise to conduct your own tea ceremonies. This knowledge will not only enhance your personal tea rituals but also provide transferrable skills in the spiritual path ahead of you.
  ]

#tuhi-postcard-vuw(discipline: discipline,
  opening: opening,
  introduction: introduction,
  description: description,
  pitch: pitch,
  contact: (phone: "0000 123 456",
  email: "contact@spiritedawayuniv.ac.jp",
  url: "www.spiritedawayuniv.ac.jp/gongfu-cha"),
  pic: image("images/TEAS.jpg", height: 100%),
  colours: cols,
  logo-bytes: read("images/logo.svg")
  )

