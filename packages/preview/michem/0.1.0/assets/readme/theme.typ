// Render the exact README snippets; imports resolve through the injected scope.
#import "@preview/michem:0.1.0" as michem

#let preview(index) = {
  set page(width: auto, height: auto, margin: 12pt, fill: white)
  set text(font: "Libertinus Serif", size: 10pt)
  show raw: set text(font: "Cascadia Code")
  let source = read("../../README.md")
    .split("```typst")
    .at(index)
    .split("```")
    .first()
    .split("\n")
    .filter(line => not line.starts-with("#import "))
    .join("\n")
  eval(source, mode: "markup", scope: (michem: michem))
}
