#import "utils.typ": print-section-before-chapters

#let print-abstract(body) = [
  #print-section-before-chapters(title: "Abstract", body)
]

#let body = [
  #lorem(120)

  #lorem(200)
]

#print-abstract(body)
