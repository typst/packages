#let bleed = 8.5pt
#let trim = 29.5pt
#let paper-width = 595pt
#let paper-height = 842pt
#let shift = 0.2cm

#let page-width = paper-width - 2*trim + 2*bleed
#let page-height = paper-height - 2*trim + 2*bleed
#let crop-length = 1.5cm


#let darkgrey = rgb(29, 27, 28)
#let darkgreen = rgb(0,81,55)
#let middlegreen = rgb(113, 135, 121)
#let othergreen = rgb(172, 194, 180)
#let lightgreen = rgb(206,220,215)
#let vuw-yellow = rgb("FDF150")

#let braid-original = read("braid.svg")
#let green-replace = braid-original.replace(
  "black", 
  lightgreen.to-hex(),
)

#let braid-green = image(bytes(green-replace), width: 19pt)

#let pat = tiling(size: (19pt, 56pt))[
  #place(braid-green)
]

#let crop-marks(distance: 9.5pt, length: 8pt,
offset:6pt, stroke: 0.2pt + black) = {
place(bottom+left,dx:0pt,dy:0pt)[#line(start:(distance, -length + offset),
end:(distance, -offset),
  stroke: stroke,
)]
place(bottom+left,dx:0pt,dy:0pt)[#line(start:(0pt + offset,-distance),
end:(length - offset,-distance),
  stroke: stroke,
)]
place(top+left,dx:0pt,dy:0pt)[#line(start:(distance , 0pt + offset),
end:(distance, length - offset),
  stroke: stroke,
)]
place(top+left,dx:0pt,dy:0pt)[#line(start:(0pt + offset,distance),
end:(length - offset,distance),
  stroke: stroke,
)]

place(bottom+right,dx:0pt,dy:0pt)[#line(start:(-distance, -length + offset),
end:(-distance, -offset),
  stroke: stroke,
)]
place(bottom+right,dx:0pt,dy:0pt)[#line(start:(-length + offset,-distance),
end:(- offset,-distance),
  stroke: stroke,
)]
place(top+right,dx:0pt,dy:0pt)[#line(start:(-distance, length - offset),
end:(-distance,  offset),
  stroke: stroke,
)]
place(top+right,dx:0pt,dy:0pt)[#line(start:(-length + offset,distance),
end:(- offset,distance),
  stroke: stroke,
)]
}

#let page-foreground = {
  // outer
  crop-marks(distance: trim - bleed, offset: 0pt,
  length: trim - bleed - 0pt, stroke: .5pt + black)

  // inner with outline
  crop-marks(distance: trim , length: trim + 2pt, stroke: 2pt + white)
  crop-marks(distance: trim , length: trim +2pt, stroke: 0.5pt + black)    
  place(top+left, dy: trim - bleed,dx:3.3cm, rect(fill: pat, width: 19pt, height: page-height))
  
}

#let tuhi-alumni-vuw(
  name: "Rylee Halvorson",
  education : "PhD in Gongfu cha",
  job : "senior tea advocate",
  employer : "NIce Tea (Est. 2024)",
  quotation: text[Upon completing this degree, you will gain a profound understanding of Gongfu Cha, and the skills to conduct your own masterful tea ceremonies. This comprehensive knowledge will elevate your personal tea rituals, allowing you to fully sip in the cultural and meditative aspects of tea.\ Whether working in tea houses, wellness retreats, or high-stakes trading, you will be equipped to share this age-old practice with others, blending tradition with modern wellness trends.],
picture: rect(width:100%,height:100%,fill: white),
justify: true,
width: 9.5cm,
hyphenate: true,
) = {

  
let page-background(fill: (lightgreen,darkgreen,), split:2cm, line-width: 2pt) = {
 place(top+left, dx:trim - bleed,dy:trim - bleed, rect(fill: fill.at(0),width: page-width, height: split))
  place(bottom+left, dx:trim - bleed,dy:-trim + bleed, rect(fill: fill.at(1),width: page-width, height: page-height - split))
  place(top+left, dy: split + trim - bleed, line(stroke: white + line-width, length: 100%))
    
}

let picture-position = (6.6cm, 1.8cm)
let name-position = (8.6cm, 11.2cm)
let title-position = (8.6cm, 11cm)
let previously-position = (8.6cm, 11cm)
let quote-position = (8.6cm, 16.8cm)
let line-position =  4.2cm
let line-width= 2pt
let picture-radius = 3.8cm
let breather = 5mm
let font-size = 18pt
let graduate-profile = (22mm, picture-position.at(1) + 2*picture-radius - trim + bleed + 25mm)

set page(width: paper-width, height:paper-height, margin:0pt,
background: page-background(split: page-height , line-width: line-width), foreground: page-foreground)

set text(font: "Source Sans Pro", size: font-size, hyphenate: hyphenate, lang: "en")

// green rect
place(top+left, dx:trim - bleed, dy:trim - bleed, rect(fill: middlegreen,width: graduate-profile.at(0)+1cm, height: page-height))

place(top+left, dx:trim - bleed + 1cm, dy:trim - bleed + 1.3cm, rotate(-90deg,origin: top + left, reflow: true)[#smallcaps(text(fill:white,size:font-size*1.7,weight: 300, tracking: 1pt)[graduate profile])])

// white rect
place(top+left, dx:title-position.at(0) - 18mm, dy:title-position.at(1)- breather, rect(fill: white.transparentize(50%),width: page-width - title-position.at(0) + trim + 18mm, height: 3.85cm + breather))
// yellow line
place(top+left, dx:title-position.at(0) - 18mm, dy:title-position.at(1)- breather, rect(fill: vuw-yellow.transparentize(10%),width: 1mm, height: 3.85cm + breather))

// profile picture
place(top+left, dx:picture-position.at(0), dy:picture-position.at(1), box(width:2*picture-radius, height:2*picture-radius, clip: true, radius: picture-radius)[#picture])

// picture border
place(top+left, dx:picture-position.at(0), dy: picture-position.at(1), circle(stroke: darkgreen + 1.0*line-width,radius: picture-radius))

set text(fill: black)
set par(leading: 12pt, justify: justify)
place(top+left, dx:name-position.at(0), dy:name-position.at(1), {
  text(size:1.2*font-size, weight: 600, fill:darkgreen)[#name]
    v(0.6em,weak: true)
  text(size:0.9*font-size, weight: 400)[#education]
    v(0.8em,weak: true)
  text(size:font-size, weight: 600, tracking: 1.1pt, fill:darkgreen)[#smallcaps(lower(job))\ #text(size:0.9*font-size,tracking: 0pt, weight: 400, fill:black)[#employer]]
}
)

let myfont = "Liberation Mono"
place(top+left, dx:quote-position.at(0)-24.5mm, dy:quote-position.at(1) + 0.5mm, [#text(size:92pt, weight: 400,fill: darkgreen.transparentize(80%), font: myfont)["]])
place(top+left, dx:quote-position.at(0)-25mm, dy:quote-position.at(1)-0em, [#text(size:92pt, weight: 400,fill: vuw-yellow.transparentize(10%), font: myfont)["]])

place(top+left, dx:quote-position.at(0), dy:quote-position.at(1), box(width: width)[#text(size:0.9*font-size, weight: 400,fill: black)[#quotation]])

}
