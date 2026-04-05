#import "@preview/glossarium:0.5.10": *
#import "@preview/datify:1.0.1": *
#import "@preview/zebraw:0.6.1": *

#let hm-color = rgb("#fb5454")

#let todo(it) = [
  #context {
    let draft = state("draft").get()
    if draft [
      #text()[#emoji.page.pencil]  #text(it, fill: hm-color, weight: 600)
    ]
  }
]

#let done() = [
  #context {
    let draft = state("draft").get()
    if draft [
      #emoji.checkmark.box
    ]
  }
]