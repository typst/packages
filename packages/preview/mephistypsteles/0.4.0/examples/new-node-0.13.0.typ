#set page(height: auto, margin: 1cm)

#import "@preview/mephistypsteles:0.4.0": *

#let mymath = `$ d = 0.35 "m". $`.text

Concrete:
#parse(mymath, concrete: true)

Abstract:
#parse(mymath)
