#import "acronyms.typ": *
#import "glossar.typ": *
#import "common.typ": *

// Diese Datei exisitiert, damit man die Funktions für das Glossar und Acronyme durch einen einzigen Import in jeder Datei nutzen kann

#let todo(message) = {
  set text(white)
  rect(fill: red, radius: 4pt, [*TODO:* #message])
  set text(black)
}

#let comment(message) = {
  set text(white)
  rect(fill: blue, radius: 4pt, [Kommentar: #message])
}
