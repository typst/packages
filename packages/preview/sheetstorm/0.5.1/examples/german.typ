#import "@preview/sheetstorm:0.5.1": assignment, task

#set text(lang: "de")

#show: assignment.with(
  title: "Deutsches Beispiel",
  authors: "Max Mustermann",
)

#task(points: 42)[
  Es ist sehr einfach, das Template für deutschsprachige Dokumente zu benutzen.
  Es muss lediglich die Sprache umgestellt werden:
  ```typst
  #set text(lang: "de")
  ```
]

#task(lorem(1000))
