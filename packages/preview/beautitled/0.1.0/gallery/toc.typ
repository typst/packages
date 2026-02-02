// Gallery renders for TOC styles
#import "@preview/beautitled:0.1.0": *

#set page(width: 10cm, height: 6.5cm, margin: 0.6cm)
#set text(font: "Linux Libertine", size: 10pt)

#let demo-toc(style-name) = {
  let primary = rgb("#2c3e50")
  let secondary = rgb("#7f8c8d")
  let accent = rgb("#2980b9")
  let fill = repeat[.]
  let indent = 1em

  if style-name == "titled" {
    block(stroke: (left: 2pt + accent), inset: (left: 0.5em))[
      #text(size: 11pt, weight: "bold", fill: primary)[Chapter 1 : Introduction #box(width: 1fr, fill) 1]
    ]
    block(inset: (left: indent))[
      #text(size: 10pt, fill: primary)[1.1 Context #box(width: 1fr, fill) 1]
    ]
    block(inset: (left: indent * 2))[
      #text(size: 9pt, fill: secondary)[1.1.1 History #box(width: 1fr, fill) 2]
    ]
  } else if style-name == "classic" {
    block[
      #text(size: 11pt, weight: "bold", fill: primary)[Chapter 1 : Introduction #box(width: 1fr, fill) 1]
      #line(length: 100%, stroke: 0.5pt + secondary)
    ]
    block(inset: (left: indent))[
      #text(size: 10pt, fill: primary)[1.1 Context #box(width: 1fr, fill) 1]
    ]
  } else if style-name == "modern" {
    block[
      #box(width: 3pt, height: 0.9em, fill: accent) #h(0.4em)
      #text(size: 11pt, weight: "bold", fill: primary)[Chapter 1 : Introduction #box(width: 1fr, fill) 1]
    ]
    block(inset: (left: indent))[
      #text(size: 10pt, fill: primary)[#text(fill: accent)[▸] 1.1 Context #box(width: 1fr, fill) 1]
    ]
  } else if style-name == "elegant" {
    block[
      #text(size: 11pt, weight: "bold", fill: primary, tracking: 0.05em)[#smallcaps[Chapter 1 : Introduction] #box(width: 1fr, repeat[#h(0.3em)·]) 1]
    ]
    block(inset: (left: indent))[
      #text(size: 10pt, fill: primary, style: "italic")[1.1 Context #box(width: 1fr, repeat[#h(0.3em)·]) 1]
    ]
  } else if style-name == "bold" {
    block(stroke: (left: 3pt + accent), inset: (left: 0.6em))[
      #text(size: 11pt, weight: "black", fill: primary)[#upper[Chapter 1 : Introduction] #box(width: 1fr, fill) 1]
    ]
    block(inset: (left: indent))[
      #text(size: 10pt, weight: "bold", fill: primary)[1.1 Context #box(width: 1fr, fill) 1]
    ]
  } else if style-name == "minimal" {
    block[
      #text(size: 11pt, fill: primary)[Chapter 1 : Introduction #h(1fr) 1]
    ]
    block(inset: (left: indent))[
      #text(size: 10pt, fill: primary)[1.1 Context #h(1fr) 1]
    ]
  } else if style-name == "scholarly" {
    block[
      #text(size: 11pt, weight: "bold", fill: primary)[Chapter 1 : Introduction #box(width: 1fr, fill) 1]
    ]
    block(inset: (left: indent))[
      #text(size: 10pt, fill: primary)[1.1 Context #box(width: 1fr, fill) 1]
    ]
  } else if style-name == "simple" {
    block[
      #text(size: 10pt, fill: primary)[1 Vector Space #box(width: 1fr, fill) 2]
    ]
    block[
      #text(size: 10pt, fill: primary)[2 Linear Dependence #box(width: 1fr, fill) 3]
    ]
    block[
      #text(size: 10pt, fill: primary)[3 Vector Norm #box(width: 1fr, fill) 7]
    ]
  }
}

#let render(style-name) = {
  box(stroke: 0.4pt + gray, inset: 0.6em, radius: 2pt, width: 100%)[
    #text(size: 9pt, weight: "bold")[#style-name]
    #v(0.3em)
    #demo-toc(style-name)
  ]
}

#render("titled")
#pagebreak()
#render("classic")
#pagebreak()
#render("modern")
#pagebreak()
#render("elegant")
#pagebreak()
#render("bold")
#pagebreak()
#render("minimal")
#pagebreak()
#render("scholarly")
#pagebreak()
#render("simple")
