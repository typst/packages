#set page(height: auto, margin: 1cm)

#import "@preview/mephistypsteles:0.3.0": *
#let mymath = `$ d = 0.35 "m". $`.text

Flat:
#parse(mymath, flat: true)

Markup:
#parse(mymath)
