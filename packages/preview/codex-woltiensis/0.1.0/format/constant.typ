// Marges des pages

#let a6_size = (width: 105mm, height : 148mm)

#let type = (
  "reglement" : 0,
  "officiel" : 2,
  "leekes" : 3,
  "groupe_folklorique" : 4,
  "andere_ziever" : 5,
  "index" : 0)

#let margin = (top:0.5cm, inside : 1cm, outside : 0.5cm, bottom : 0.6cm)

#let rectangle = rect(fill: black, width: 0.4cm, height: a6_size.height / type.len())
#let rectangle-line = rect(fill: black, width: 0.4cm, height: a6_size.height)

// Contenu des headers de chant 
#let header-settings = (tune : none,author : none,lyrics : none,pseudo : none, comments : none) 
#let image-settings = (path :none,position : bottom,height : auto,width : auto,alignment:center)
#let layout-info = (col1 : none,col2 : none,) 