#import "../src/lib.typ": source-diagram

#set page(margin: 5pt, width: auto, height: auto)

#let src = (
  "@Layout(level=0, order=1)",
  read("../exemplos/java/Animal.java"),
  "@Layout(level=1, order=2)",
  read("../exemplos/java/Cachorro.java"),
  "@Layout(level=1, order=0)",
  read("../exemplos/java/Alimentavel.java"),
  "@Layout(level=1, order=1)",
  read("../exemplos/java/Gato.java"),
).join("\n\n")

#source-diagram(src, grammar: "java")
