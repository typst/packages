#import "page.typ"
#import "heading.typ"
#import "outline.typ"
#import "cover.typ"

#let apply(doc, despair-mode: false) = {
  show: rest => page.apply(rest, despair-mode: despair-mode)
  show:  heading.apply
  show: outline.apply
  doc
}