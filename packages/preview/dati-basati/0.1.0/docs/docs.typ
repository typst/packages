#import "@preview/tidy:0.4.3": *
#import "style.typ"

#let modules = ("dati-basati", "attributes", "weak-entity", "custom-marks", "utils", "cardinality", "entity")

#import "../src/dati-basati.typ"
#import "../src/attributes.typ"
#import "../src/cardinality.typ"
#import "../src/entity.typ"
#import "../src/weak-entity.typ"
#import "../src/custom-marks.typ"
#import "../src/utils.typ"

#align(
  center,
  heading(
    text(size: 1.5em)[`dati-basati` documentation],
    outlined: false,
  ),
)

#set heading(numbering: none)

#let toc = outline(depth: 2)
#context box(
  height: measure(toc).height / 2,
  columns(toc),
)

#let custom-show-module(module-name) = show-module(
  parse-module(
    read("../src/" + module-name + ".typ"),
    name: module-name,
    scope: (module-name: module-name),
    preamble: "#import " + module-name + ": *\n",
  ),
  style: style,
  first-heading-level: 1,
  show-outline: false,
  show-module-name: true,
  // omit-private-definitions: true,
  // omit-private-parameters: true,
  sort-functions: none,
)

#for module in modules {
  custom-show-module(module)
}
