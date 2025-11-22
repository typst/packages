//#import "../lib.typ": *
#import "@preview/grotesk-cv:0.1.0": *
#import "@preview/fontawesome:0.2.1": *


== #fa-icon("users") #h(5pt) #get-header-by-language("References", "Referencias")

#v(5pt)

#if is-english() [

  #reference-entry(
    name: [Sarah Connor, Resistance Leader],
    company: [Cyberdyne Systems],
    telephone: [+1 (555) 654-3210],
    email: [sarah.connro\@resistance.com],
  )

  #reference-entry(
    name: [Eldon Tyrell, CEO],
    company: [Tyrell Corporation],
    telephone: [+1 (555) 987-6543],
    email: [eldontyrell\@tyrellcorp.com],
  )

] else if is-spanish() [

  #reference-entry(
    name: [Sarah Connor, Líder de la Resistencia],
    company: [Cyberdyne Systems],
    telephone: [+1 (555) 654-3210],
    email: [sarah.connro\@resistance.com],
  )

  #reference-entry(
    name: [Eldon Tyrell, CEO],
    company: [Tyrell Corporation],
    telephone: [+1 (555) 987-6543],
    email: [eldontyrell\@tyrellcorp.com],
  )

]


