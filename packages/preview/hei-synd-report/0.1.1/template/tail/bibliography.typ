#import "@preview/hei-synd-report:0.1.1": *

#let make_bibliography(
  bib:(
    display: true,
    path: "/tail/bibliography.bib",
    style: "ieee", //"apa", "chicago-author-date", "chicago-notes", "mla"
  ),
  title: "Bibliography",
) = {[
  #if bib.display == true {[
    #pagebreak()
    #bibliography(title: title, bib.path, style:bib.style)
  ]} else{[
    #set text(size: 0pt)
    #bibliography(title: "", bib.path, style:bib.style)
  ]}
]}
