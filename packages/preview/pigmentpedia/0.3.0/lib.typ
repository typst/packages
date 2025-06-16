/*
  pigmentpedia by neuralpain
  https://github.com/neuralpain/pigmentpedia

  An extensive color library for Typst.

  Search and apply over 20k pigments across a variety of
  color standards including, but not limited to: PANTONE®,
  Natural Colour System® and DIC Digital Color Guide®.

  https://typst.app/universe/package/pigmentpedia
*/

#import "src/pigments.typ": *
#import "src/display.typ": view-pigments
#import "src/search.typ": find-pigment
#import "src/show-tree.typ": show-pigmentpedia-tree
#import "src/pigment-playground.typ": pigment-playground

#let pgmt = (
  show-all: view-pigments(pigmentpedia),
  tree: show-pigmentpedia-tree()
)
