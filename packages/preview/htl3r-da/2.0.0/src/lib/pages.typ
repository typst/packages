#import "pages/cover.typ" as cover
#import "pages/abstract.typ" as abstract
#import "pages/preamble.typ" as preamble
#import "pages/sworn-statement.typ" as sworn-statement
#import "pages/toc.typ" as toc
#import "pages/tot.typ" as tot
#import "pages/tof.typ" as tof
#import "pages/tol.typ" as tol
#import "pages/abbreviation.typ" as abbreviation
#import "pages/glossary.typ" as glossary
#import "pages/bibliography.typ" as bibliography
#import "pages/printref.typ" as printref
#import "util.typ" as util

#let create-tables() = {
  toc.create-page()
  util.insert-blank-page()
  tot.create-page()
  util.insert-blank-page()
  tof.create-page()
  util.insert-blank-page()
  tol.create-page()
}
