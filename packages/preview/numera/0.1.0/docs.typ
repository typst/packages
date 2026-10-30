#import "@preview/numera:0.1.0" as numera
#import "@preview/tidy:0.4.3"

#set document(
  title: "Numera API reference",
  author: "Moritz Hedtke",
)
#set page(numbering: "1")

= Numera

This reference is generated directly from Numera's source doc-comments with
#link("https://typst.app/universe/package/tidy/")[Tidy].

#let docs = tidy.parse-module(
  read("impl.typ"),
  name: "API reference",
  label-prefix: "numera-",
  require-all-parameters: true,
  scope: (numera: numera),
)

#let undocumented-parameters = ()
#for function-docs in docs.functions {
  for (parameter, parameter-docs) in function-docs.args {
    if parameter-docs.description == "" {
      undocumented-parameters.push(function-docs.name + "(" + parameter + ")")
    }
  }
}
#assert(
  undocumented-parameters.len() == 0,
  message: "Undocumented API parameters: " + undocumented-parameters.join(", "),
)

#tidy.show-module(
  docs,
  style: tidy.styles.default,
  first-heading-level: 2,
  show-module-name: true,
  enable-tests: true,
)
