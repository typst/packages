#let vnum = state("vnum", 1)
#let bgs = (
  (
    title: "image/1/title.png",
    section: "image/1/section.png",
    slide: "image/1/slide.png",
    quote: "image/1/quote.png",
  ),
  (
    title: "image/2/title.png",
    section: "image/1/section.png",
    slide: "image/1/slide.png",
    quote: "image/2/quote.png",
  ),
  (
    title: "image/3/title.png",
    section: "image/1/section.png",
    slide: "image/1/slide.png",
    quote: "image/3/quote.png",
  ),
  (
    title: "image/4/title.png",
    section: "image/4/section.png",
    slide: "image/4/slide.png",
    quote: "image/4/quote.png",
  ),
  (
    title: "image/5/title.png",
    section: "image/5/section.png",
    slide: "image/5/slide.png",
    quote: "image/5/quote.png",
  ),
  (
    title: "image/6/title.png",
    section: "image/6/title.png",
    slide: "image/6/slide.png",
    quote: "image/6/quote.png",
  ),
)

#let conf(
  num: 1,
  doc,
) = [
  #vnum.update(num)
  #set page(paper: "presentation-16-9")
  #show heading.where(level: 1): set text(size: 30pt, fill: blue.darken(50%))
  #show heading.where(level: 2): set text(size: 28pt, fill: blue.darken(50%))
  #show heading.where(level: 3): set text(size: 24pt, fill: blue.darken(50%))
  #show heading.where(level: 4): set text(size: 20pt, fill: blue.darken(50%))
  #set text(size: 14pt)
  #set grid(columns: (1fr, 1fr), column-gutter: 2em)

  //raw
  #show raw.where(block: false): highlight.with(
    top-edge: 13pt,
    bottom-edge: -7pt,
    fill: luma(240),
    radius: 2pt,
  )
  #show raw.where(block: true): block.with(
    fill: luma(240),
    inset: 5pt,
    radius: 5pt,
    above: 10pt,
    width: 100%,
  )
  #doc
]

#let title(content) = context [
  #let num = vnum.get()
  #let path = bgs.at(num - 1).title
  #set page(background: image(path))
  #align(horizon)[
    #if num == 1 or num == 2 {
      show heading: set text(fill: yellow.darken(10%))
      set text(fill: white)
      content
    } else if num == 3 {
      content
    } else if num == 4 {
      show heading: set text(fill: yellow.darken(10%))
      set align(right)
      set text(fill: white)
      content
    } else if num == 5 or num == 6 {
      set align(right)
      content
    } else {
      content
    }
  ]
]

#let section(content) = context [
  #let num = vnum.get()
  #let path = bgs.at(num - 1).section
  #set page(background: image(path))
  #align(horizon)[
    #if num == 1 or num == 2 or num == 3 {
      content
    } else if num == 6 {
      set align(right)
      content
    } else {
      grid(columns: 2)[
        #h(10em)
      ][
        #content
      ]
    }
  ]
]

#let slide(content) = context [
  #let num = vnum.get()
  #let path = bgs.at(num - 1).slide
  #set page(background: image(path))
  #content
]

#let quote(content) = context [
  #let num = vnum.get()
  #let path = bgs.at(num - 1).quote
  #set page(background: image(path))

  #if num == 1 or num == 2 {
    show heading: set text(fill: yellow.darken(10%))
    set text(fill: white)
    align(center, content)
  } else if num == 3 {
    align(center, content)
  } else if num == 4 {
    show heading: set text(fill: yellow.darken(10%))
    set text(fill: white)
    v(8em)
    content
  } else if num == 6 {
    v(6em)
    align(center, content)
  } else {
    v(8em)
    content
  }
]
