#import "@preview/cetz:0.5.2": canvas, draw

// 1. دالة الورقة العادية (لا تغيير فيها)
#let ornacover-portrait(base-color: black, ornament-char: "d", font-family: "CornPop") = {
  rect(
    width: 95%, height: 95%,
    stroke: 1pt + base-color, radius: 7pt,
    inset: 3pt,
    fill: base-color, 
    rect(
      width: 100%, height: 100%, 
      stroke: 1pt + base-color, 
      radius: 1pt,
      fill: white.transparentize(17%)
    )
  ) 
  place(top + left, dx: 1.2cm, dy: 1.7cm, canvas(length: 1cm, {
    draw.content((2.4, 26.5), name: "a", scale(3.8cm, text(fill: base-color, font: font-family)[#ornament-char]))
    draw.content((18.2, 26.5), name: "b", rotate(90deg, scale(3.8cm, text(fill: base-color, font: font-family)[#ornament-char])))
    draw.content((18.2, 3), name: "c", rotate(180deg, scale(3.8cm, text(fill: base-color, font: font-family)[#ornament-char])))
    draw.content((2.4, 3), name: "d", rotate(-90deg, scale(3.8cm, text(fill: base-color, font: font-family)[#ornament-char])))  
    draw.line((to: (name: "a", anchor: "east"), rel: (2cm, 1.4)), (to: (name: "b", anchor: "west"), rel: (-2cm, 1.4)), stroke: (paint: base-color, thickness: 7pt))
    draw.line((to: (name: "d", anchor: "east"), rel: (2cm, -1.4)), (to: (name: "c", anchor: "west"), rel: (-2cm, -1.4)), stroke: (paint: base-color, thickness: 7pt))
    draw.line((to: (name: "a", anchor: "south"), rel: (-1.4cm, -1.9)), (to: (name: "d", anchor: "north"), rel: (-1.4cm, 1.9)), stroke: (paint: base-color, thickness: 7pt))
    draw.line((to: (name: "b", anchor: "south"), rel: (1.4cm, -1.9)), (to: (name: "c", anchor: "north"), rel: (1.4cm, 1.9)), stroke: (paint: base-color, thickness: 7pt))
  }))
}

// 2. دالة الورقة العرضية (لا تغيير فيها)
#let ornacover-landscape(base-color: red, ornament-char: "e", font-family: "CornPop") = {
  rect(
    width: 95%, height: 95%, 
    stroke: 1pt + base-color, radius: 7pt,
    inset: 3pt, 
    fill:base-color,
    rect(width: 100%, height: 
100%,stroke: 1pt + base-color, 
      radius: 1pt,
      fill: white.transparentize(17%))
  ) 
  place(top + left, dx: 1.6cm, dy: 1.7cm, canvas(length: 1cm, { 
    draw.content((3.4, 26.5), name: "a", scale(3.8cm, text(fill: base-color, font: font-family)[#ornament-char]))
    draw.content((27, 26.5), name: "b", rotate(90deg, scale(3.8cm, text(fill: base-color, font: font-family)[#ornament-char])))
    draw.content((27, 11.5), name: "c", rotate(180deg, scale(3.8cm, text(fill: base-color, font: font-family)[#ornament-char])))    
    draw.content((3.4, 11.5), name: "d", rotate(-90deg, scale(3.8cm, text(fill: base-color, font: font-family)[#ornament-char])))
    draw.line((to: (name: "a", anchor: "east"), rel: (2cm, 1.6)), (to: (name: "b", anchor: "west"), rel: (-2cm, 1.6)), stroke: (paint: base-color, thickness: 7pt))
    draw.line((to: (name: "d", anchor: "east"), rel: (2cm, -1.6)), (to: (name: "c", anchor: "west"), rel: (-2cm, -1.6)), stroke: (paint: base-color, thickness: 7pt))
    draw.line((to: (name: "a", anchor: "south"), rel: (-1.6cm, -1.9)), (to: (name: "d", anchor: "north"), rel: (-1.6cm, 1.9)), stroke: (paint: base-color, thickness: 7pt))
    draw.line((to: (name: "b", anchor: "south"), rel: (1.6cm, -1.9)), (to: (name: "c", anchor: "north"), rel: (1.6cm, 1.9)), stroke: (paint: base-color, thickness: 7pt))
  }))
}
