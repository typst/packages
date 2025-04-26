#import "@preview/hei-synd-thesis:0.1.0": *
#import "/metadata.typ": *
#pagebreak()

#let make_bibliography(
  bib:(
    display: true,
    path: "/tail/bibliography.bib",
    style: "ieee", //"apa", "chicago-author-date", "chicago-notes", "mla"
  ),
  title: i18n("bib-title", lang: option.lang),
) = {[
  #if bib.display == true {[
    #pagebreak()
    #bibliography(title: title, bib.path, style:bib.style)
  ]} else{[
    #set text(size: 0pt)
    #bibliography(title: "", bib.path, style:bib.style)
  ]}
]}
