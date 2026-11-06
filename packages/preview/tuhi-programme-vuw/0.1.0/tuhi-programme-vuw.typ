
#import "@preview/codetastic:0.2.2": qrcode

#let smcps = (x) => text(tracking: 0.8pt)[#smallcaps[#lower(x)]]

#let sentence-case(x) = text[#upper(x.at(0))#x.slice(1)]
#let darkgrey = rgb(29, 27, 28)
#let darkgreen = rgb("#005b00") 
#let middlegreen = rgb(113, 135, 121)
#let lightgreen = rgb("#cde5cc")
#let vuw-green = rgb("#005b00") 

#let intro(title: none, tagline: none, url: none) = {
  grid(columns: (0.8cm,1fr, 2cm),
[],
  grid.cell(
    rowspan: 1,
    inset: (bottom:12pt),
smallcaps[#text(size:28pt)[#title]],
  ),
  grid.cell(
    rowspan: 2,
    inset: (bottom:0pt),
    qrcode(url, width: 2cm, quiet-zone:0,min-version:1, colors: (white,black)),
  ),
[],
text[#tagline]
)
}

#let elective(body) = {
  box[
 #set text(font: "Source Sans Pro", size:12pt)
  #rect(fill:rgb("#DDDD").transparentize(60%),width:100%, height: 2cm)[#body]
]
}

#let course(topic: "phys", code: "304", points: "15", fill: rgb("#EEEE"),title: text[electromagnetism and wave optics]) = box[
 #set text(font: "Source Sans Pro", size:12pt)
  #rect(fill:fill,width:5.5cm, height: 2cm)[#smallcaps[#text(size:14pt)[#topic]#text(number-type: "lining")[*#code*]] | #text[#points points]\ #title]
]


#show grid.cell: set text(font: "Source Sans Pro", size:11pt)
#show grid.cell: set rect(fill:none,stroke:none, inset:8pt)

#let elective(body) = {
  box[
 #set text(font: "Source Sans Pro", size:12pt)
  #rect(fill:rgb("#DDDD").transparentize(60%),width:100%, height: 2cm)[#body]
]
}


#let course-details(courses: none, body, core: true, footnote: none,
show-trimester:false) = {
 let info = courses.at(body).at(0)
 let topic = body.slice(0, 4)
 let code = body.slice(4, 7)
 let points = info.points
 let title = info.title
 let T = info.trimester.join(",")
 let year = body.slice(4,5)
 let fill = if core {(
  "1": rgb(235,157,12),
  "2": rgb(0,158,224),
  "3": rgb(86,163,38),
  "4": rgb(226,0,122),
).at(year)} else {rgb("#AAAA")}

let stroke = if core { 1pt + fill} else {1pt + color.mix((rgb("#AAAA"), 15%), (white, 85%)) }
  box[
 #set text(font: "Source Sans Pro", size:12pt)
  #rect(fill:color.mix((fill, 15%), (white, 85%)), stroke: stroke,
  width:100%, height: 2cm)[#smallcaps[#text(size:14pt)[#topic#h(1pt)#text(number-type: "lining")[*#code*]]] #if show-trimester [#h(1fr) #text[Tri: #T]] else {}  #h(1fr)|  #text[#points points]\ #title #if footnote != none {text(size:9pt)[#eval(footnote, mode: "markup")]} else {}]
]
}

#let tuhi-programme-vuw(
  title: "double major example",
  author: "author",tagline : text[Recommended for careers in physics research or academia, astronomy, astrophysics],
  search-url : "", 
  course-info: none,
  course-ids: none,
  show-trimester: true,
  date: datetime(year: 2024,month: 7, day: 3),
  body ) = {
  // Set the document's basic properties
  set document(title: title, author: author)
  set page("a4", flipped: true, margin: (left:1.5cm, rest:1cm))
  set text(font: "Source Sans Pro", size:16pt,number-type: "lining")
  
  intro(title: smallcaps[#title], tagline: tagline, url: search-url)
  v(5pt, weak: true)
  show grid.cell: set text(font: "Source Sans Pro", size:11pt)
  show grid.cell: set rect(fill:none,stroke:none, inset:8pt)
  show regex("(PHYS|CHEM|MATH|SPCE|STAT|ENGR|COMP|EEEN|NWEN|DATA|GEOG|ESCI|QUAN|SCIS|BIOL|BMSC|BTEC)(\d+)"): (x) => {smallcaps(lower(x))}

set grid(columns: (0.8cm,auto,auto,auto, auto),
  rows: (auto),
  align: (x,y) => if x==0 { left + horizon} else {top + left},
  column-gutter: 3pt,
  row-gutter: (3pt,3pt,10pt,3pt,3pt,10pt,3pt,3pt))

  // body
  let header-year(x) = {
  grid.cell(
    colspan: 4,
    inset: (bottom:5pt,top:8pt),
    smallcaps(text(size:14pt)[#x]),
  )}

  let format-cell(x) = grid.cell()[
  #if "elective" in x.keys() {elective(eval(x.text, mode:"markup"))} else {course-details(courses: course-info, x.id, core: x.core, show-trimester: show-trimester, footnote: {
  if "footnote" in x.keys()  { x.footnote } else  {none} })}]
  
grid(
  [],
  header-year("year 1"),
  rect[T1],
..course-ids.Y1.T1.map(format-cell),
  rect[T2],
..course-ids.Y1.T2.map(format-cell),
  [],
  header-year("year 2"),
  rect[T1],
..course-ids.Y2.T1.map(format-cell),
  rect[T2],
..course-ids.Y2.T2.map(format-cell),
  [],
  header-year("year 3"),
  rect[T1],
..course-ids.Y3.T1.map(format-cell),
  rect[T2],
..course-ids.Y3.T2.map(format-cell),
)

  
text(font: "Source Sans Pro", size:9pt,number-type: "lining")[\*: For full details on degree requirements visit: #search-url]
}

