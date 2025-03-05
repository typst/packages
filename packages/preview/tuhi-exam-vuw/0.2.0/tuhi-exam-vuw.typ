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
  box[]
} else {
  h(1fr)
  box[#("[" + str(x) + " marks]")]
  box[]
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

#let MURPH = {
  [MUR]
box(move(
  dx: -1.0pt, dy: 2.7pt,
  box(scale(100%)[P])
));box(move(
  dx: -3.0pt, dy: 3pt,
  box(scale(80%)[H])
));h(-0.45em)
}

#let ending = align(center,[
  #v(1fr, weak: true)
  #text[\* \* \* \* \* \* \* \* \* \* \* \* \* \* \*]
  #v(1fr, weak: true)
])

#let tuhi-exam-vuw(coursetitle: "scientific basis of murphy's laws", 
             coursecode: "murph101",
             date: datetime(year: 2023,month: 8, day: 3),
             year: "2023", 
             trimester: "2",
             timeallowed: "three hours",
             openorclosed: "open book",
             permitted: "Any materials except communication via electronic devices.",
             instructions: "",
             logo: image("logo.svg", width: 80mm),
             body) = {
  // Set the document's basic properties.
  set document(author: coursecode, title: coursetitle)

set enum(numbering: (..n) => {
   let n = n.pos()
   let pat = ("1.", "(a)", "(i)").at(n.len() - 1)
   if n.len() == 3 {
   set text(weight: "regular")
     numbering(pat, n.last())
   } else {
     set text(weight: 300)
     strong(numbering(pat, n.last()))
   }
   
}, full: true)


  // show "murph": MURPH


  set page(paper:"a4",
  background: rect(width:100%,height:100%,fill: rgb(254,254,254)),
  numbering: (num, total) => [Page *#num* of *#total*],  footer: [
  #set align(center)
  #set text(12pt, number-type: "old-style")
  #grid(columns: (1fr,1fr,1fr), {
    set text(tracking: 0.5pt)
    align(left)[#smallcaps(lower(coursecode))]
  },
  [Page #context counter(page).display((num, total) => [#set text(number-type: "lining");#num ⁄ #total], both: true)],
  [])
  
],
   // background: image("template.svg", fit: "contain"), 
  margin: (left: 2.3cm, right: 2.3cm, 
           top: 2.3cm, bottom: 2.6cm),
         footer-descent:50%)

  // set page(numbering: "1", number-align: center)
  set text(font: "STIX Two Text", lang: "en", size: 12pt)
  
upper[
  #set text(weight: "black", 14pt)
  #align(center)[
    #block(logo)
    #v(0.8cm)
      #block(inset: 0em)[
      // #set text(weight: 800, 14pt)
      // #show text: upper
       EXAMINATIONS --- #year 
       #v(0.5em, weak: true)
       TRIMESTER #trimester 
       #v(0.5em, weak: true)
       FRONT PAGE
     ]#v(1.2cm, weak: true)
     
 #rect(width: 90mm, inset: 0.5cm)[
   #set par(leading: 0.7em)
   #set text(weight: 800, 14pt)
   #show text: upper
   #coursecode#v(1.2em, weak: true)
   #coursetitle#v(1em, weak: true)
   #date.display("[month repr:long] [day], [year]")
 ]

  ]
]
  set text(12pt)
  v(6.5em, weak: true)
grid(row-gutter: 2em,  columns: (3.8cm, auto),
strong[Time allowed:],strong[#upper[#timeallowed]],
strong[Permitted materials:],[
  #strong[#upper[#openorclosed]]\
          #permitted 
],
strong[Instructions:],[#instructions])

  pagebreak()
  
  // Main body.
  set par(justify: true)
  set enum(tight: true, spacing: 1.0em) 
  show heading: it => {
  it.body
  v(0.8em)
}
  body
}
