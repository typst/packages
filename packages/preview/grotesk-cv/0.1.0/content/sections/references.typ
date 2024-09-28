#import "../../lib.typ": *
#import "@preview/fontawesome:0.2.1": *


== #fa-icon("users") #h(5pt) #getHeaderByLanguage("References", "Referencias")

#v(5pt)

#if isEnglish() [

  #referenceEntry(
    name: [Sarah Connor, Resistance Leader],
    company: [Cyberdyne Systems],
    telephone: [+1 (555) 654-3210],
    email: [sarah.connro\@resistance.com],
  )

  #referenceEntry(
    name: [Eldon Tyrell, CEO],
    company: [Tyrell Corporation],
    telephone: [+1 (555) 987-6543],
    email: [eldontyrell\@tyrellcorp.com],
  )

] else if isSpanish() [

  #referenceEntry(
    name: [Sarah Connor, Líder de la Resistencia],
    company: [Cyberdyne Systems],
    telephone: [+1 (555) 654-3210],
    email: [sarah.connro\@resistance.com],
  )

  #referenceEntry(
    name: [Eldon Tyrell, CEO],
    company: [Tyrell Corporation],
    telephone: [+1 (555) 987-6543],
    email: [eldontyrell\@tyrellcorp.com],
  )

]


