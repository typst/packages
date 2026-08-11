#import "@preview/showybox:2.0.4": showybox

// #import "@preview/t4t:0.4.3": get
// borrowed code for portability
#let all-of-type(t, ..values) = values.pos().all(v => std.type(v) == t)
#let dict-merge(..dicts) = {
  if all-of-type(dictionary, ..dicts.pos()) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if k not in c {
          c.insert(k, v)
        } else {
          let d = c.at(k)
          c.insert(k, dict-merge(d, v))
        }
      }
    }
    return c
  } else {
    return dicts.pos().last()
  }
}

#let _default-layout = (width: 210mm, height:297mm, margin:1.72cm)

#let _default-palette(base-colour: rgb(0,81,55) ) = (
  background: (
    base: luma(95%),
    light: luma(98%),
    dark: luma(90%),
  ),
  foreground: (
    base: luma(40%),
    light: luma(50%),
    dark: luma(2%),
  ),
  highlight: (
    base: base-colour,
    light: base-colour.lighten(50%),
    dark: base-colour.darken(50%),
  ),
)


#let _default-fonts(base-family: "Fira Sans") = (
  main: (
    font: base-family, 
    size: 12pt, 
    weight: 400,
    number-type: "old-style", 
    lang: "en",
    features: (onum: 1),
  ),
  title: (//size:22pt,weight: 100,fill:darkgreen
    font: "Source Sans Pro", 
    size: 48pt, 
    weight: 100
  ),
  subtitle: (
    font: "Source Sans Pro", 
    size: 22pt, 
    weight: 400, 
    features: (smcp: 1, c2sc: 1, onum: 1),
  ),
  section: (
    size: 1.2em,
    font: "Source Sans Pro",
    features: (smcp: 1, c2sc: 1, onum: 1),
    weight: 600, 
alternates: true, 
tracking: 0.5pt, 
number-type: "old-style"
  ),
  subsection: (
    font: "Source Sans Pro", 
    weight: 600, 
number-type: "old-style", 
tracking: 0.1pt,
    size: 1.1em,
    features: (smcp: 1, c2sc: 1),
  ),
  subsubsection: (
    size: 1.1em,
    font: "Source Sans Pro", 
    number-type: "old-style", 
    // features: (smcp: 1, c2sc: 1),
    weight: "bold",
  ),
  raw: (
    font: "Fira Code",
    size: 1.2em,
    tracking: -0.1pt,
    features: (onum: 1),
    weight: 400,
  ),
  math: (font: ("Fira Math", "New Computer Modern"),
  size:1em, fallback: true, ),
)


#let tuhi-labscript-vuw(
  experiment: text[murphy's l\ aws -- an investigation],
  script: "pre-lab script",
  coursetitle: none,
  coursecode: "phys345",
  date: datetime(year: 2024,month: 7, day: 3),
  teaching-period: "T2",
  illustration: none,
  fonts: _default-fonts(),
  palette: _default-palette(),
  layout: _default-layout,
  body) = {
  // Set the document's basic properties.
  set document(
    author: coursecode + teaching-period, 
    title: script + coursetitle,
    keywords: ("lab script"),
    date: date)
  
set page(..layout, background: none,   numbering: (num, total) => [#num / #total],  
   footer: [
    #set align(center)
    #set text(10pt, number-type: "old-style")
    #grid(columns: (1fr,4em,1fr), {
      set text(tracking: 0.5pt)
      show text: it => smallcaps(lower(it))
      align(left)[#date.display("[year] · ")#text[#teaching-period]]
    },  
    [#context counter(page).display((num, total) => [#set text(number-type: "lining");#num ⁄ #total], both: true)],
    [#h(1fr)#smallcaps[#coursecode.match(regex("([a-zA-Z]+)([0-9]+)")).captures.join(" ")#[#if coursetitle != none {" · " + coursetitle} else {}]] ]) 
    // adding hair space
    ],)

show "·": text(fill: palette.highlight.base,"·")
// show "⁄": text(fill: palette.highlight.base.lighten(60%),"⁄")
set text(..fonts.main)
set par(justify: true)

show raw: set text(..fonts.raw) 
show raw.where(block: true): set par(justify: false)
show raw.where(block: true): set block(width: 100%)//, stroke: 0.1pt, inset: 1em)

show figure: set block(width: auto)
show figure: set align(center)

show figure.caption: x=> {
  align(center,block(inset: 8pt)[
  #set align(left) 
  #set text(size: 0.8em)
  #x
  ])
}

show math.equation: set text(..fonts.math) 
set math.equation(numbering: "(1)", number-align: end + horizon)

show heading.where(level: 1): it => {
set text(..fonts.section)
  upper(it)
  v(0.3em)
  }

show heading.where(level: 2): it => {
set text(..fonts.subsection)
smallcaps(lower(it))
v(0.1em)}

show heading.where(level: 3): it => {
set text(..fonts.subsubsection)
it
v(0.1em, weak: false)
}

// opening page

v(1.5cm)
align(top + left)[
  #set text(..fonts.title)
#set par(leading: 0.25em)
#smallcaps[#lower[#experiment]]#v(1cm,weak: true)#text(size:0.5em)[›› ]#smallcaps[#text(..fonts.subtitle)[#script]]
#v(1.5cm,weak: true)
 #illustration#v(2cm,weak: true)
]

  // Main body

  body
}


#let labscript-setup(fonts: (:), palette: (:), layout: (:)) = {

  let layout = dict-merge(_default-layout, layout)
  let palette = dict-merge(_default-palette(), palette)

  let _default-fonts = _default-fonts() // local copy
  _default-fonts.main.fill = palette.foreground.base
  _default-fonts.title.fill = palette.highlight.base
  _default-fonts.subtitle.fill = palette.foreground.dark
  _default-fonts.section.fill = palette.highlight.base
  _default-fonts.subsection.fill = palette.highlight.base
  _default-fonts.subsubsection.fill = palette.foreground.base

  let fonts = dict-merge(_default-fonts, fonts)

  return (
    labscript: tuhi-labscript-vuw.with(fonts: fonts,
      palette: palette),
    fonts: fonts,
    palette: palette,
    layout: layout,
  )
}


// export with default settings
#let (labscript, fonts, palette, layout) = labscript-setup()

#let script(title: none, body) = {

showybox(
      title-style: (boxed-style: (:), 
      color: gray.darken(50%), stroke: red),
      title: title,
  frame: (
    title-color: gray.lighten(80%),
    border-color: gray.darken(0%),
    body-color: gray.lighten(98%)
  ),
  breakable: true,
    )[#body]
      
}
