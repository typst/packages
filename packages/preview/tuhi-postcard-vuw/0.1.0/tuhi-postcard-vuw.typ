
#import "@preview/codetastic:0.2.2": qrcode

#let bleed = 8.5pt
#let trim = 29.5pt
#let paper-width = 654.3pt
#let paper-height = 339.6pt
#let shift = 0.2cm

#let page-width = paper-width - 2*trim + 2*bleed
#let page-height = paper-height - 2*trim + 2*bleed
#let crop-length = 1.5cm

#let darkgrey = rgb(29, 27, 28)


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
  
}


#let page-background(overlay: none, fill: rgb(110,81,55)) = {
  if overlay == none [#rect(fill: fill,width: page-width,height: page-height)] else {
    overlay
  }
}

#let tuhi-postcard-vuw(discipline: none,
opening: none,
introduction: none,
description: none,
pitch: none,
contact: (phone: "00112233",
email: "scienceinsociety\@vuw.ac.nz",
url: "wgtn.ac.nz"),
pic: none,
logo-bytes: none,
logo-width: 4.21cm,
colours: (rgb(110,81,55), rgb(113, 135, 121)),
) = {

let phone-raw = read("telephone-fill.svg")
let phone-icon = phone-raw.replace(
  "black", // white
  colours.at(0).to-hex(),
)

let email-raw = read("envelope-at-fill.svg")
let email-icon = email-raw.replace(
  "black", // white
  colours.at(0).to-hex(),
)

let info-raw = read("info-circle-fill.svg")
let info-icon = info-raw.replace(
  "black", // white
  colours.at(0).to-hex(),
)


let bright-replace = logo-bytes.replace(
  "black", // white
  colours.at(1).to-hex(),
)
let dark-replace = logo-bytes.replace(
  "black", // white
  colours.at(0).to-hex(),
)
// image.decode(original)
let logo-bright = image(bytes(bright-replace), width: logo-width)
let logo-dark = image(bytes(dark-replace), width: logo-width)

// let logo-dark = logo
  
set page(width: paper-width, height:paper-height, margin:0pt,
background: page-background(fill: colours.at(0), overlay: none),
foreground: page-foreground)

place(dx:17.0cm,dy:1.8cm)[#logo-bright]

place(bottom + left, dx:12.2cm + shift,dy:-6.25cm)[#set par(leading: 0.15em) 
#set text(size: 42pt, fill:white)
#align(bottom)[#box[#discipline.at(1)]]]
// 
place(dx:12.2cm + shift,dy:6.6cm)[#set par(leading: 6.2pt) 
#set text(fill:white,size: 9.5pt,font: "Inter", tracking:-0.3pt, weight: 700)
#box(width: 6.8cm)[#opening]]


place(dx:19.6cm,dy:8.5cm)[#qrcode(contact.url,width:1.6cm,quiet-zone:2, 
  colors: (colours.at(0), colours.at(1)),)]


place(dx:trim - bleed,dy: trim - bleed)[#box(clip: true,height:page-height,width:auto)[ #pic ]]
 
 // verso
pagebreak(weak: false)

set page(background: page-background(fill: white,overlay: none))


place(dx:16.9cm,dy:1.9cm)[#logo-dark]


place(dx:1.8cm,dy:1.9cm)[#set par(leading: 0.15em) 
// #discipline(light: false)
#discipline.at(0)
]
// 
let contact-details = {
set text(fill:darkgrey,size: 7.5pt, tracking:0.1pt, weight: 400)
// text(font: "fontello", fill: colours.at(0), size: 11pt)[]
// octique-inline("device-mobile", color: colours.at(0), width: 1.2em)
box(baseline: 20%,image(bytes(phone-icon), width:1.2em))
h(1em)
text(font: "Inter")[#contact.phone]
v(1em, weak: true)
// text(font: "fontello", fill: colours.at(0), size: 11pt)[]
// octique-inline("mail", color: colours.at(0), width: 1.2em)
box(baseline: 20%,image(bytes(email-icon), width:1.2em))
h(1em)
text(font: "Inter")[#contact.email]
v(1em, weak: true)
// text(font: "fontello", fill: colours.at(0), size: 11pt)[]
// octique-inline("info", color: colours.at(0), width: 1.2em)
box(baseline: 20%,image(bytes(info-icon), width:1.2em))
h(1em)
text(font: "Inter")[#contact.url]}
place(dx:1.8cm,dy:4.7cm)[
  #box(width: page-width - 2.2cm)[
#columns(3, gutter: 12pt)[
#set par(leading: 6.5pt)
#set text(fill:darkgrey,size: 9.5pt,font: "Inter", tracking:-0.2pt, weight: 800)
#introduction
#colbreak(weak: true)
#set text(fill:darkgrey,size: 8pt,font: "Inter", tracking:-0.1pt, weight: 400)
#description
#colbreak(weak: true)
#pitch
#v(11pt, weak:true)
#contact-details
]
]
]
}
