#let darkgrey = rgb(29, 27, 28)
#let darkgreen = rgb(0,81,55)
#let middlegreen = rgb(113, 135, 121)
#let lightgreen = rgb(206,220,215)

#let tuhi-labscript-vuw(
  experiment: text[murphy's l\ aws -- an investigation],
  script: "pre-lab script",
  coursetitle: "experimental physics ii",
  coursecode: "phys345",
  date: datetime(year: 2024,month: 7, day: 3),
  trimester: "2",
  illustration: none,
  body) = {
  // Set the document's basic properties.
  set document(
    author: coursecode, 
    title: coursetitle,
    keywords: ("lab script"),
    date: date)
  
set page(width: 210mm, height:297mm, margin:1.72cm, background: none,   numbering: (num, total) => [#num / #total],  
   footer: [
    #set align(center)
    #set text(10pt, number-type: "old-style")
    #grid(columns: (1fr,1fr,1fr), {
      set text(tracking: 0.5pt)
      show text: it => smallcaps(lower(it))
      align(left)[#date.display("[year] · ")#text[T#trimester]]
    },
    [#counter(page).display((num, total) => [#set text(number-type: "lining")
    #num ⁄ #total], both: true)],
    [#h(1fr)#smallcaps[#coursecode.match(regex("([a-zA-Z]+)([0-9]+)")).captures.join(" ")]]) 
    // adding hair space
   ],)

set text(font: "Fira Sans", size: 12pt, weight: 400, fill: luma(50), number-type: "old-style", lang: "en", )

show raw: set text(font: "Fira Code", 
                     size: 11pt, weight: 500, tracking: -0.1pt) 
show math.equation: set text(font: "Fira Math", weight: 400)                     
set par(justify: true)

show heading.where(level: 1): it => {set text(font: "Fira Sans", fill: darkgrey, weight: 500, alternates: true, tracking: 0.5pt, number-type: "old-style")
smallcaps(lower(it))
  v(1em)}

show heading.where(level: 2): it => {set text(font: "Fira Sans", fill: darkgreen, weight: 400, number-type: "old-style", tracking: 0.1pt)
smallcaps(lower(it))
v(0.4em)}

// opening page

v(1.5cm)
align(top + left)[
  #set text(font: "Source Sans Pro", size: 48pt, weight: "extralight", fill: darkgreen)
#set par(leading: 12pt)
#smallcaps[#lower[#experiment]]#v(1cm,weak: true)#smallcaps[#text(size:22pt,weight: 100,fill:darkgreen)[›› ]#text(size:22pt,weight: 400, fill: darkgrey)[#script]]
#v(1.5cm,weak: true)
 #illustration#v(2cm,weak: true)
]

  // Main body

  body
}
