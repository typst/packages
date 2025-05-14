#import "@preview/tidy:0.3.0"
#import "@preview/mantys:0.1.4": *
#import "/src/lib.typ" as graceful-genetics

#let package = toml("/typst.toml").package
#let docs = tidy.parse-module(read("/src/impl.typ"), scope: (graceful-genetics: graceful-genetics),)

#titlepage(
  package.name,
  `graceful-genetics`, // title
  [Vulgar Fractions], //subtitle 
  none, //description, 
  package.authors,
  (package.repository,), 
  package.version,
  datetime.today(), 
  none, // abstract, 
  package.license,
  toc: false,
)

#tidy.show-module(docs, style: tidy.styles.default)