// Source code for the typst-doc package


#import "styles.typ"
#import "old-parser.typ" as tidy-parse
#import "utilities.typ"
#import "testing.typ"
#import "show-example.typ" as show-example: render-examples
#import "parse-module.typ": parse-module
#import "show-module.typ": show-module
#import "helping.typ" as helping: generate-help


#let help(..args) = {
  let namespace = (
    ".": (
      read.with("/src/parse-module.typ"), 
      read.with("/src/show-module.typ"),
      read.with("/src/helping.typ"),
    )
  )
  generate-help(namespace: namespace, package-name: "tidy")(..args)
}
