
#let smcps = (x) => text(tracking: 0.8pt)[#smallcaps[#lower(x)]]

#let sentence-case(x) = text[#upper(x.at(0))#x.slice(1)]

#let fmt-person(x) = text[#if(x.title != ""){x.title} #x.preferred]

#let fmt-email(x) = text[#x.first.#x.last\@vuw.ac.nz]

#let darkgrey = rgb(29, 27, 28)
#let darkgreen = oklch(40%,20%,144deg,100%)
#let middlegreen = rgb(113, 135, 121)
#let lightgreen = oklch(90%,6%,144deg,100%)

#let course-info(info, fill: lightgreen) = {

  show grid.cell.where(y: 0): strong
  show grid: block
  show grid.cell.where(y: 0): set text(size:9pt, font: "Fira Sans", weight: 200)

  set block(breakable: false)
  
  set grid(
     fill: (x, y) =>
      if y <= 0 { fill }
      else { white },
    stroke: none,
    align: (x, y) => if (y <= 0) and (x != 2 and x !=1 and x != 4) { center + top}
      else { left },
        row-gutter: 8pt,
    column-gutter: 1pt,
      columns: (55pt, 60pt, 1fr, 40pt, 24pt),
    rows: (auto,),
  )

  
  let ci = info.at(0)
  
 let tris = eval(ci.trimester.join("\\ "), mode: "markup")
 let crns = ci.crn.map(x => text[crn #x\ ]).join()
 
let course = text[#ci.course.slice(0,4) #ci.course.slice(4,7)] // inserting " "
  grid(
    rect(width: 100%,stroke:none)[#smcps[#course]],
    rect(width: 100%,stroke:none)[#smcps[#crns]],
    rect(width: 100%,stroke:none)[#smcps[#ci.title]],
    rect(width: 100%,stroke:none)[#smcps[#ci.points pts]],
    rect(width: 100%,stroke:none)[#smcps[#tris/3]],
    text(fill: darkgreen)[Prerequisites:],
    grid.cell(
      colspan: 4,
      text[#eval(ci.prerequisites, mode: "markup")],
    ),text(fill: darkgreen)[Restrictions:],
      grid.cell(
      colspan: 4,
      text[#eval(ci.restrictions, mode: "markup")],
    ),  
    grid.cell(
      colspan: 5,
      text[#eval(ci.description, mode: "markup")],
    ))
  
}
#let tuhi-booklet-vuw(
  author: "",
  school: none,
  alternate: none,
  address: none,
  phone: none,
  web: none,
  email: none,
  title: none,
  date: datetime(year: 2024,month: 7, day: 3),
  illustration: none,
  body ) = {
  // Set the document's basic properties.
  set document(
    author: author, 
    title: title,
    keywords: ("courses"),
    date: none)
    
set text(size:9pt, font: "Fira Sans", weight: 300)
set par(justify: true)

set page(width: 210mm, height:297mm, margin:1.72cm, background: rect(fill:white,width:100%,height:100%),   

   footer: [
    #set align(center)
    #set text(8pt, number-type: "old-style",weight: 400,font: "Fira Sans")
#show grid.cell.where(y: 0): set text(size:8pt, font: "Fira Sans", weight: 100)
 #set grid(
     fill: white,
    stroke: none
  )

    #grid(columns: (1fr,1fr,1fr), {
      set text(tracking: 0.5pt)
      show text: it => smallcaps(lower(it))
      align(left)[#date.display("[year]")]
    },
    align(center)[#counter(page).display((num, total) => [#set text(number-type: "lining")
    #num ⁄ #total], both: true)],align(right)[#author]
  )])

    show heading.where(level: 1): it => {
    set text(font: "Fira Sans",  size:14pt,
         weight: 700, tracking: 0.5pt, number-type: "lining", fill:  black)
     align(center,upper(it))
     line(length: 100%,stroke:0.4pt + black)
     v(1.8pt,weak: true)
     line(length: 100%,stroke:0.15pt + black)
     v(1em)}

    show heading.where(level: 2): it => {
    set text(font: "Fira Sans", size:11pt,
         weight: 600, tracking: 0.5pt, number-type: "old-style", fill:  black)
     smallcaps(lower(it))
     v(0.51em)}

    show heading.where(level: 3): it => {
    set text(font: "Fira Sans",  size:9pt,
         weight: 500, tracking: 0.5pt, number-type: "old-style", fill:  black)
     it
     v(0.1em)}

     //opening page
     
v(1.5cm)
align(top + left)[
  #set text(font: "Source Sans Pro", size: 48pt, weight: "light", fill: darkgreen)
#set par(leading: 12pt)
#text(size:26pt)[#school]#v(0.5cm,weak: true)
#smallcaps[#lower[#title]]#v(1cm,weak: true)#smallcaps[#text(size:22pt,weight: 100,fill:darkgreen)[›› ]#text(size:22pt,weight: 300, fill: darkgrey)[#date.display("[year]")]]
#v(1.5cm,weak: true)
 #illustration#v(2cm,weak: true)
#set text(font: "Source Sans Pro", size: 14pt, weight: "light", fill: black)
#v(1fr,weak: true)
#text(weight: 400)[Contact]\
#set par(leading: 9pt)
#school --- #emph(alternate)\
#address\ 
#phone\ 
#email\
#web\ 

#v(1fr,weak: true)
]

pagebreak()
     
show "PHYS": smallcaps[#text[phys]]
show "SPCE": smallcaps[#text[spce]]
show "CHEM": smallcaps[#text[chem]]
show "ENGR": smallcaps[#text[engr]]
show "STAT": smallcaps[#text[stat]]
show "MATH": smallcaps[#text[math]]  
show "COMP": smallcaps[#text[comp]]
show "EEEN": smallcaps[#text[eeen]]
show "NWEN": smallcaps[#text[nwen]]
show "DATA": smallcaps[#text[data]]

show regex("(PHYS|CHEM|MATH|SPCE|STAT|ENGR|COMP|EEEN|NWEN) \d+"): (x) => {
  // set text(red) 
  show " ": " "
  smallcaps(lower(x))}


  // Main body

  body
}

