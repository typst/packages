#import "@preview/codetastic:0.2.2": qrcode
#import "@preview/cetz:0.3.3"

#let scaps(body, tracking: 1pt, weight: "regular") = {
  set text(tracking: tracking, weight: weight)
  smallcaps[#lower[#body]]
}

#let caps(body, tracking: 0pt, weight: "semibold") = {
  set text(tracking: tracking, weight: weight)
  smallcaps[#lower[#body]]
}


// note: could try to use
// #import "@preview/markly:0.3.0"
// but a lot of placements in the poster assume 
// manual control of margins etc. so easier to keep it internal for now (hopefully Typst itself will have a bleed mechanism built-in soon)
// 
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


#let tuhi-course-poster-vuw(
  coursetitle: "course title",
  courseid: "rand101",
  coursemajor: none,
  courseimage : none,
  coursepoints: "15",
  coursetrimester: none,
  courselecturers: ("nature",),
  courseformat: none,
  courseprereqs: none,
  imagecredit: none,
  coursedescription: none,
  courses: none,
  contact: [address goes here],
  logo: none,
  qrcodeurl: none,
  // The main content.
  body
) =  {

let bleed = 6pt
let trim = 20.5pt
let shift = 0.14cm

//A3
let page-width = 297mm
let page-height = 420mm

let paper-width = page-width + 2*trim - 2*bleed
let paper-height = page-height + 2*trim - 2*bleed

let crop-length = 1.0cm

let (pagewidth, pageheight, bleed) = (paper-width, paper-height, bleed)
let margin-body-left = 33.5mm
let margin-shaded-top = 125mm
let margin-shaded-bottom = 55mm 
let padding-body = 0.5em

let title-top = 40mm

let details-left = 210mm
let details-top = 165mm
let details-width = 70mm
let details-height = 75mm

let schedule-width = 230mm
let schedule-spacer = 6mm
let schedule-height = 20mm

let logo-height = 2cm
let address-width = 110mm
let address-left = 126mm
let address-top = 15mm

let image-width = pagewidth - 2*margin-body-left
let image-top = 104mm
let stoke-width = 1.4pt


let image-height = 0.5*image-width
let description-top = 28pt
let content-width = 160mm
let content-height = 100mm
let content-top = 28pt

let vuwcol = rgb(0,71,48)
let darkcol = rgb("#555555") // dark text


let page-foreground = {
  // outer
  crop-marks(distance: trim - bleed, offset: 0pt,
  length: trim - bleed - 0pt, stroke: .5pt + black)

  // inner with outline
  crop-marks(distance: trim , length: trim + 2pt, stroke: 2pt + white)
  crop-marks(distance: trim , length: trim +2pt, stroke: 0.5pt + black)    
  
}

// function to draw the page background with a specific colour
let bkg(col: vuwcol) = {

place(
  dx: 0mm,
  dy: margin-shaded-top,
  rect(
  width: pagewidth,
  height: pageheight - margin-shaded-top - margin-shaded-bottom,
  fill: color.mix((col, 10%), (white, 90%)),
)
)

place(
  dx: 0mm,
  dy: margin-shaded-top,
  line(
  length: pagewidth,
  stroke: stoke-width + col,
)
)

place(
  dx: 0mm,
  dy: pageheight - margin-shaded-bottom,
  line(
  length: pagewidth,
  stroke: stoke-width + col,
)
)

// details separators
place(
  dx: details-left,
  dy: pageheight - details-top,
  line(
  length: details-width,
  stroke: stoke-width + col,
)
)

place(
  dx: details-left,
  dy: pageheight - details-top + details-height,
  line(
  length: details-width,
  stroke: stoke-width + col,
)
)

// schedule separator
place(
  dx: 0.5*(pagewidth - schedule-width),
  dy: pageheight  - margin-shaded-bottom - schedule-spacer,
  line(
  length: schedule-width,
  stroke: (thickness: 0.5*stoke-width , paint: col , dash: "dotted"),
)
)

place(
  dx: 0.5*(pagewidth - schedule-width),
  dy: pageheight - margin-shaded-bottom - 2*schedule-spacer,
  line(
  length: schedule-width,
  stroke: (thickness: 0.5*stoke-width , paint: col , dash: "dotted"),
)
)

}

// computed
let coursediscipline = courseid.slice(0,4)
let coursecode = courseid.slice(4,7)
let year = coursecode.at(0)
let courseurl = qrcodeurl + coursediscipline + "/" + coursecode
// url expected to follow this scheme: https://www.wgtn.ac.nz/courses/phys/304/2023

// colour inferred from course level
let col = (
  "1": rgb(235,157,12),
  "2": rgb(0,158,224),
  "3": rgb(86,163,38),
  "4": rgb(226,0,122),
).at(year)

// now set up page with coloured background
// set page(height: pageheight, width: pagewidth, margin: 0mm, background: bkg(col: col))

set page(width: paper-width, height:paper-height, margin:0pt,
background: bkg(col: col), foreground: page-foreground)

set text(size: 13pt)
set par(justify: false, leading: 0.2em)

// contact details
place(
  dx: address-left,
  dy:  pageheight - margin-shaded-bottom + address-top,
  box(width: address-width, height: logo-height)[
  #set align(top)
  #set par(justify: true, leading: 0.7em)
  // #rect(width:100%, height: 100%)
  #set text(weight: 200, size: 11pt, fill: vuwcol)

  #scaps(tracking: 0.2pt,weight:400)[#contact.school] \
  #scaps(tracking: 0.2pt,weight:400)[#contact.faculty] \
  #contact.university\
  #scaps(tracking: 1pt,weight:400)[p:]  #raw(contact.phone) • #scaps(tracking: 1pt,weight:400)[e:]  #raw(contact.email) • #scaps(tracking: 1pt,weight:400)[w:]  #raw(contact.website)

  ],
)

// qr code
place(
  dx: pagewidth - margin-body-left - logo-height,
  dy:  pageheight - margin-shaded-bottom + address-top,
  qrcode(courseurl, width: logo-height, ecl:"l",
         colors: (white, vuwcol), quiet-zone: 0)
)

// logo
place(
  dx: margin-body-left,
  dy:  pageheight - margin-shaded-bottom + address-top, 
  box(height: logo-height, width: auto)[#logo]  
)


// now defining coloured replacements globally
show "•": text.with(weight: "extralight", fill: col)
show "·": text.with(weight: "extralight", fill: col)
show "↯": text.with(fill: col)


// image with border
place(
  dx: margin-body-left,
  dy: image-top,
  rect(width:image-width, height:0.5*image-width, stroke: 0.5*stoke-width)
)

place(
  dx: margin-body-left,
  dy:  image-top,{
  set image(width:image-width, height:0.5*image-width)
  courseimage
  },
)

// title
let title = [
  #set align(center+bottom)
  #set par(leading: 0.4em)
  #show text : smallcaps
  #set text(size: 46pt, fill: col,  tracking: 0pt)
   #text(weight: "thin")[#coursediscipline]#h(0.042em)#text(fill: black, weight: "medium")[#coursecode]\ #text(weight: "semibold", tracking: 0pt, fill: black)[#coursetitle]
]

// title
place(
  dx: 0mm,
  dy: title-top,
  block(width:pagewidth, height:45mm, inset:1em)[#title]  
)

// description
place(
  dx: margin-body-left + padding-body,
  dy: image-top + image-height + description-top,
  block(width:image-width - padding-body, height:2*description-top)[
#set text(size: 22pt, weight: 700, fill: darkcol)
#set par(justify: false, leading: 0.6em)
#coursedescription]  
)

// course content

place(
  dx: margin-body-left + padding-body,
  dy: image-top + image-height + 2.5*description-top + content-top ,
  block(width:content-width, height:content-height)[
#set text(weight: 300, size: 18pt)
#set par(justify: false, leading: 0.52em)
// #rect(width:100%, height:100%)

// content height dictates the leading to cater for both dense and sparse course descriptions
#let sizeme(body) = context {
  let size = measure(body)
  let headingspace = if(size.height < 350pt) {1.2em} else if(size.height < 250pt) {0.6em} else {0.6em}
  let spacer = if(size.height < 260pt) {1.2em} else if(size.height < 250pt) {0.6em} else {0em}
  
  show heading: it => block(above: headingspace, below: 0.3em)[
  #set align(left)
  #set text(size: 18pt, fill: darkcol)
  #set par(justify: true, leading: 0.2em)
  #h(-0.5em)• #scaps(it.body, weight: "bold") //#size.height 
]
v(spacer)
body 
}

#sizeme(body)
]  
)


// copyright

place(
  dx: margin-body-left + image-width - 230mm, //40mm
  dy:  226mm ,
  block(width:230mm, height:10mm)[
#set text(weight: "thin", size: 8pt)
  #set align(right + top)
Image: #imagecredit]  
)


// course info
place(
  dx: 212mm,
  dy:  275mm ,
  block(width:70mm, height:10mm)[
#set par(justify: false, leading: 0.7em)
#set text(weight: 300, size: 13pt)
#set align(left + top)
#show strong: set text(weight: 400, fill: darkcol)
#let majorstring = scaps(weight: "regular")[#coursemajor] + [\ ]
#if(coursemajor != none) {show strong: scaps; majorstring ; v(0.1em)} else {}
#strong(coursepoints) points • trimester #strong(coursetrimester) \
#courseformat 

#let lect = if (courselecturers.len() == 1 ) {"Lecturer"} else {"Lecturers"}
#show strong: set text(weight: "regular")
#show courselecturers.at(0): emph.with()
#box[#text[#lect: #courselecturers.map(x => strong(x)).join(", ")]]

#show strong: scaps.with(tracking: 0pt)
_Pre-requisites:_\
#courseprereqs

]  
)

// schedule
place(
  dx: 0mm,
  dy:  pageheight - margin-shaded-bottom - schedule-spacer - 0.5*schedule-height,
  block(width:pagewidth, height:schedule-height)[
#set align(center+horizon)
#set text(weight: "extralight", size: 9pt, fill:black)
#show regex(courseid): text.with(weight: "semibold", fill: col)
#show: scaps
#table(
  columns: (auto, auto, auto, auto),
  inset: 0pt, row-gutter:7pt, column-gutter: 20pt, stroke: none,
  align: horizon,
  [#courses.Y1T1], [#courses.Y2T1], [#courses.Y3T1], [#courses.Y4T1],
  [#courses.Y1T2], [#courses.Y2T2], [#courses.Y3T2], [#courses.Y4T2],
)

])

    
} // end body

