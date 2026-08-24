#import "../src/lib.typ": *

#set page(paper: "a4", margin: 0pt, fill: white)
#set text(font: "Amiri", lang: "ar")

#show math.equation: it => {
  if it.body.fields().at("size", default: none) != "display" {
    return math.display(it)
  }
  it
}

#worksheet(mode: "normal")
