#import "page.typ"
#import "heading.typ"
#import "outline.typ"
#import "cover.typ"

#let apply(doc) = {
  show: page.apply
  show:  heading.apply
  show: outline.apply
  doc
}