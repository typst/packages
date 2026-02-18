#import "utils.typ": print-section-before-chapters

#let print-acknowledgements(body) = [
  #print-section-before-chapters(title: "Acknowledgements", body)
]

#let body = [
  #lorem(120)

  #lorem(200)
]

#print-acknowledgements(body)
