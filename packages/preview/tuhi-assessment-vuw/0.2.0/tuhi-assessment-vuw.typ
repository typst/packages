#let darkgrey = rgb(29, 27, 28)
#let darkgreen = rgb(0,81,55)
#let middlegreen = rgb(113, 135, 121)
#let lightgreen = rgb(206,220,215)

#let answer-col = rgb(173, 7, 85) 
#let answer-bg = rgb(250, 240, 245)



#let mark(x) = if x <= 1 {
  h(1fr)
  box[#strong("[" + str(x) + " mark]")]
} else {
  h(1fr)
  box[#strong("[" + str(x) + " marks]")]
}


#let submark(x) = if x <= 1 {
  h(1fr)
  box[#("[" + str(x) + " mark]")]
} else {
  h(1fr)
  box[#("[" + str(x) + " marks]")]
}

#let answer(x, visible: false) = if(visible){
  set text(fill: answer-col)

  show raw: set block(width: 100%, stroke: 0.1pt, inset: 1em, fill: answer-bg.desaturate(80%))

  set math.equation(numbering: none)
  v(0.5em,weak: true)
  block(width:100%, 
  breakable: true, 
  fill: answer-bg,
  stroke: (left: answer-col + 5pt), inset: (left: 1em, right: 1em, rest:0.8em))[#x]
  } else {box[]}

#let setup(visible: false) = {
  (answer: answer.with(visible: visible),)
}

#let tuhi-assessment-vuw(
  activity: "assignment",
  coursetitle: "experimental physics ii",
  coursecode: "phys345",
  grading: "20 points total",
  date: datetime(year: 2024,month: 7, day: 3),
  trimester: "2",
  body) = {
  // Set the document's basic properties.
  set document(
    author: coursecode, 
    title: coursetitle,
    keywords: ("assignment"),
    date: date)
  
set page(width: 210mm, height:297mm, margin:1.72cm, background: none,   numbering: (num, total) => [#num / #total],  
   footer: [
    #set align(center)
    #set text(9pt, number-type: "old-style")
    #grid(columns: (1fr ,1fr,1fr), {
      set text(tracking: 0.5pt)
      show text: it => smallcaps(lower(it))
      align(left)[#date.display("[year] · ")#text[T#trimester]]
    },
    [#context counter(page).display((num, total) => [#set text(number-type: "lining");#num ⁄ #total], both: true)],
    [#h(1fr)#smallcaps[#coursecode.match(regex("([a-zA-Z]+)([0-9]+)")).captures.join(" ")]]) 
    // adding hair space
   ],)


set text(font: "Fira Sans", size: 12pt, weight: 400, fill: luma(100), number-type: "old-style", lang: "en", )

show raw: set text(font: "Fira Code", 
                     size: 10pt, weight: "medium", tracking: -0.1pt) 

show raw: set block(width: 100%, stroke: 0.1pt, inset: 1em)

show figure: set block(width: 90%)
show figure: set align(center)
show image: set align(center)

show figure.caption: x=> {
  set align(left) 
  set text(size: 10pt)
  x
}

show math.equation: set text(font: ("Fira Math","New Computer Modern Math"),  size:12pt, fallback: true) 
set math.equation(numbering: "(1)", number-align: end + horizon)
set par(justify: true)
set enum(numbering: "1.a.i.")

// opening page

align(top + center)[
#set text(font: "Source Sans Pro", size: 18pt, 
weight: "medium", number-type: "lining")
#set par(leading: 12pt)
#smallcaps[#lower[#coursecode: #coursetitle]]
#v(0.5cm,weak: true)
#text(size:16pt)[#activity]
#v(0.5cm,weak: true)
#smallcaps(text(size:14pt)[due: #date.display()])
#v(0.5cm,weak: true)
#text(size:14pt)[#grading]
#v(1.5cm,weak: true)
]

  // Main body

  body
}
