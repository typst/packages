#import "/theofig.typ": *
#set page(paper: "a6", height: auto, margin: 6mm)

#for lang in theofig-translations.keys() [
  #set text(lang: lang)
  #theorem[#lang][#lorem(5)]
]
