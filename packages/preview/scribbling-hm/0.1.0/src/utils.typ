#import "@preview/glossarium:0.5.9": *

#let todo(it, draft: false) = [
  #if draft [
    #text()[#emoji.page.pencil]  #text(it, fill: red, weight: 600)
  ]
]