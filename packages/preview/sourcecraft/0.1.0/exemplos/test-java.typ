//#import "@preview/sourcecraft:0.1.0": source-diagram, setup-sourceuml
#import "../src/lib.typ": source-diagram, setup-sourceuml
#set page(paper: "a4", flipped: true)
//#set page(width: auto)
//#set page(width: 10cm)


= Teste Gramática: Java

#let src = (
  "@Layout(level=1, order=1)",
  read("java/Animal.java"),
  read("java/Cachorro.java"),
  read("java/Alimentavel.java"),
  "@Layout(level=0, order=1)",
  read("java/Gato.java"),
  "@Layout(level=2, order=1)",
  read("java/Coleira.java"),
  "@Layout(level=2, order=0)",
  read("java/Dono.java"),
  "@Layout(level=2, order=1)",
  read("java/Brinquedo.java"),
).join("\n\n")

#source-diagram(src, grammar: "java", max-height: 15cm)


#show: setup-sourceuml

#raw(src, block: true, lang: "source-diagram-java")
