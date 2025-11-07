#import "@preview/glossarium:0.5.9": *
#import "@preview/datify:1.0.0": *

#let todo(it) = [
  #context {
    let draft = state("draft").get()
    if draft [
      #text()[#emoji.page.pencil]  #text(it, fill: red, weight: 600)
    ]
  }
]
