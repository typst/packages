#import "../util.typ": insert-blank-page
#import "../global.typ" as global

#let create-page() = context [
  = Glossar
  #for name in global.abbr.get().keys().sorted() [
    #let abbr = global.abbr.get().at(name)
    #let desc = abbr.at("description", default: none)
    #let long = abbr.at("long", default: none)
    #if long == none {
      panic("Long for '" + name + "' does not exist!")
    }
    #let long = long.at("singular", default: none)
    #if long == none {
      panic("Long for '" + name + "' does not exist in singular form!")
    }
    #if desc != none [
      #par(hanging-indent: 2em)[
        #strong(long): #label("ABBR_G_"+name) #desc \
      ]
      #v(0.5em)
    ]
  ]
]
