#import "@preview/poster-syndrome:0.1.0": *
#import "@preview/codetastic:0.2.2": qrcode

#let custom-theme = theme-helper(
  palette: (
    base: luma(10%),
    fg: black,
    bg: white,
    highlight: maroon, 
    contrast: teal,
  ), 
  fonts: (
    base: ("Source Sans Pro", "Noto Serif CJK SC"),
    raw: "Source Code Pro",
    math: ("Fira Math", "New Computer Modern Math")),
  overrides: (par:(
    // default: (justify: false),
    outlook: (justify: false),
  ),
  text: (
    default: (fill: luma(5%)),
    methods: (fill: luma(30%)),
    title: (font:"Source Sans Pro",size: 180pt, weight:100, tracking: 4pt, fill: rgb("#3A4D6Eff")))))


// retrieve frames from yVuCuVsA6v8JU76e7VOdwo
// https://www.figma.com/developers/api#files-endpoints
#let (container, frames) = figma-layout(json("figma_layout.json")) 
// or manually defined

// #let frames = (
//   methods: (x: 847, y: 60, width: 272, height: 410),
//   illustration: (x: 629, y: 479, width: 500, height: 108),
//   description: (x: 629, y: 60, width: 189, height: 403),
//   introduction: (x: 186, y: 657, width: 374, height: 200),
//   details: (x: 66, y: 660, width: 106, height: 112),
//   subtitle: (x: 66, y: 618, width: 494, height: 25),
//   title: (x: 60, y: 563, width: 500, height: 55),
//   cover-image: (x: 60, y: 60, width: 500, height: 500),
//   outlook: (x: 629, y: 601, width: 500, height: 200),
// )

// initialise with given frames
#let (poster, frame) = poster-syndrome-setup(theme: custom-theme, frames: frames)

#let page-background = {
  let padding = 1cm
  let col1 = custom-theme.palette.contrast.darken(1%).transparentize(90%)
  let col2 = custom-theme.palette.highlight.lighten(60%)
  let col3 = custom-theme.palette.highlight.lighten(98%)

  // right page
  place(right + top,
  rect(width:50%, height:100%, 
  fill: col1))
  
  // details box
  place(left + top, dx: frames.details.x*1mm - padding, dy: frames.details.y*1mm - padding,  
  rect(width: frames.details.width*1mm  + padding , stroke: (left: (thickness: 2mm, paint: col2.transparentize(40%))),
  height: frames.details.height*1mm + 2*padding, fill:col2.transparentize(100%), radius:0mm))

  //methods box
  place(left + top, dx: frames.methods.x*1mm - padding, dy: frames.methods.y*1mm - padding,  
  rect(width: frames.methods.width*1mm + 2*padding, 
  height: frames.methods.height*1mm + 1.2*padding, fill:col3, radius:5mm))
}

#show: poster.with(  
  title: text[poster title],
  subtitle: text[s · u · b · t · i · t · l · e],
  authors: text[Author 1\
   Author 2 \
   Author 3],
  affiliation: text(size:28pt)[Address],
  qr-code: block(qrcode("url.com", width: 2cm, ecl:"l",
  colors: (white, maroon), quiet-zone: 0)),
  date: datetime.today().display(),
  cover-image: square(fill:luma(95%),width:100%),
  credit: "Credit",
  background: page-background,
  foreground: _page-foreground(frames: frames),
)

#frame(tag:"introduction")[
  #columns(2)[
  #lorem(200)
  ]
]


#frame(tag:"description")[
  
== Heading

#lorem(100)

=== Sub-heading

#lorem(100)

#lorem(100)
 ]

#frame(tag:"methods")[
 #columns(2, gutter: 24pt)[
== Heading

#lorem(100)

#lorem(120)

#colbreak()

#lorem(130)

#lorem(100)
]
]

#frame(tag:"illustration")[
#let li = (insta(),)*6
#grid(columns:6*(1fr,),column-gutter: 10pt,..li)

]

#frame(tag:"outlook")[
  #columns(3)[

== Heading

Lorem ipsum dolor sit amet,

1.  consectetur adipiscing elit, sed do eiusmod tempor incididunt ut

2.  labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

3.  Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,

4.  sunt in culpa qui officia deserunt mollit anim id est laborum.

Lorem ipsum dolor sit amet, consectetur elit.

#colbreak()

== Heading

Lorem ipsum dolor sit amet, consectetur adipiscing elit,

-   Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

-   Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

-   Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Mollit anim id est laborum,

#colbreak()

== Heading

#lorem(100)
]
]