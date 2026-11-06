#import "../util.typ": blank-page, insert-blank-page
#import "../global.typ" as global

#let create-page() = context [
  #global.author.update(none)
  = Abkürzungsverzeichnis
  #for name in global.abbr.get().keys() [
    #let abbr = global.abbr.get().at(name)
    #let short = abbr.at("short", default: none)
    #if short == none {
      continue
    }
    #let short = short.at("singular", default: none)
    #if short == none {
      panic("Short for '" + name + "' does not exist in singular form!")
    }
    #let long = abbr.at("long", default: none)
    #if long == none {
      panic("Long for '" + name + "' does not exist!")
    }
    #let long = long.at("singular", default: none)
    #if long == none {
      panic("Long for '" + name + "' does not exist in singular form!")
    }
    #let description = abbr.at("description", default: none)
    #block(breakable: false)[
      #par(spacing: 0pt)[
        #strong(short): #label("ABBR_DES_"+name) #long #h(1fr)
        #if description != none [
          #let page-number = (
            counter(page)
              .at(query(label("ABBR_G_" + name)).first().location())
              .first()
          )
          #link(label("ABBR_G_" + name))[#emph[Glossar (S. #page-number)]]
        ]
      ]
      // list abbr locations
      #let refs = query(label("ABBR_" + name))
      #let ref-entries = (
        refs
          .map(ref => (
            counter(page).at(ref.location()).first(),
            ref.location(),
          ))
          .dedup(key: it => it.at(0))
          .filter(it => it.at(0) > 0)
      )
      #par(
        hanging-indent: 2em,
        spacing: 6pt,
        first-line-indent: 2em,
        emph[
          #if ref-entries.len() > 0 [
            S.: #for (index, (nr, loc)) in ref-entries.enumerate() [
            #let delim = if index + 1 == ref-entries.len() {""} else {","}
            #link(loc)[#nr#delim ]
          ]
          ] else [
            Nicht Referenziert
          ]
        ],
      )
    ]
    #v(1em)
  ]
]
