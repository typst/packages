
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

#let mark(x) = if x <= 1 {
  h(1fr, weak: true)
  box[#strong("[" + str(x) + " mark]")]
} else {
  h(1fr, weak: true)
  box[#strong("[" + str(x) + " marks]")]
}


#let fin = align(center,[
  #v(1fr, weak: true)
  #text[\* \* \* \* \* \* \* \* \* \* \* \* \* \* \*]
  #v(1fr, weak: true)
])

#let tuhi-exam-vuw(
  coursetitle: "scientific basis of murphy's laws", 
  coursecode: "murph101",
  date: datetime(year: 2023, month: 8, day: 3),
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

  // murphy's law
  // show "murph": MURPH

  set page(paper:"a4",

   background: rect(width:100%, 
                    height:100%, fill: white),

   numbering: (num, total) => [Page *#num* of *#total*],  
  
   footer: [
    #set align(center)
    #set text(12pt, number-type: "old-style")
    #grid(columns: (1fr,1fr,1fr), {
      set text(tracking: 0.5pt)
      align(left)[#smallcaps(lower(coursecode))]
    },
    [Page #counter(page).display((num, total) => [*#num* of *#total*], both: true)],
    [])
   ],

   // testing against official template
   // background: image("template.svg", fit: "contain"), 
   margin: (left: 2.3cm, right: 2.3cm, 
            top: 2.3cm, bottom: 2.6cm),
          footer-descent:50%) // end set page
  // choice of fonts
  set text(font: "STIX Two Text", lang: "en", size: 12pt)
  show raw: set text(font: "Source Code Pro", 
                     size: 1.1em, tracking: -0.1pt) 
// -------------------------
// title block 
// -------------------------
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
  ] // rect
 ] // align center
]   // upper

// -------------------------
// exam details
// -------------------------
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

   // -------------------------
   // Main body
   // -------------------------
   set par(justify: true)
   set enum(tight: false, spacing: 2.5em)
   show heading: it => {
   it.body
   v(0.8em)
}
   body
}