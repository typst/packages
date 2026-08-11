// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "colors.typ": *

#let titlepage(
  title: "Title",
  subtitle: "Subtitle",
  authors: "Authors",
  logo: none,
  logo-dimensions: (auto, auto),
  toc-depth: none,
  text-size: 12pt,
  date: datetime.today(),
) = { 
  set page(
    footer: context{
      align(center)[ 1 ]
    }
  )
  
  v(30pt)

  align(center)[
    #image("assets/HM_Logo_RGB.png", width: 30%)
    #v(40pt)
    #text(title, size: 24pt, weight: "bold", fill: hm-black)
    #linebreak()
    #v(1pt)
    #text(subtitle, size: 15pt, weight: "semibold")
    #v(0pt)
    #text(authors, size: 15pt)
    #v(0pt)
    #text(date.display("[day]. [month repr:long] [year]"), size: 15pt)
    #v(30pt)
  ]

  show heading.where(level: 1): it => {
    text(size: 15pt, it)
  }
  show outline.entry.where(
    level: 1,
  ): it => {
    v(15pt, weak: true)
    strong(it)
  }
  set text(size: text-size)
  
  // TOC
  if toc-depth != none {
    outline(indent: auto, depth: toc-depth)
  }
}
