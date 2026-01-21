#import "@preview/elembic:1.1.1" as e: selector
#import "model/arrow-element.typ": arrow
#import "model/element-element.typ": element
#import "model/group-element.typ": group
#import "model/molecule-element.typ": molecule
#import "model/reaction-element.typ": reaction

#let fields = e.fields
#let elembic = e
#let set-arrow = e.set_.with(arrow)
#let set-element = e.set_.with(element)
#let set-group = e.set_.with(group)
#let set-molecule = e.set_.with(molecule)
#let set-reaction = e.set_.with(reaction)
