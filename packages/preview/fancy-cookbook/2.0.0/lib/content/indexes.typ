#import "../assets/fonts.typ": fonts 
#import "../i18n/i18n.typ": translate
#import "../i18n/translations.typ": i18n-words

#let indexes(recipes,custom-indexes, palette) = {
  for index in custom-indexes {
    heading(level: 2, index.title)
  
    for tag in index.tags {
      align(center)[
        #box(width:70%)[
          // Tag
          #v(0.5em)
          #text(font: fonts.header, weight: "black", fill: palette.dark, size: 0.8em, upper(tag))
          #h(1fr)
        ]
      ]
  
      let filtered = recipes.filter(r => tag in r.value.tags)
  
      for r in filtered {
        align(center)[
          // Recipe Entry
          #v(0.05em)
          #box(width: 65%)[
                #link(r.value.location)[
                  #text(font: fonts.body, size: 0.8em, r.value.title)
                  #box(width: 1fr, repeat[ #h(0.3em) #text(fill: palette.dark, size: 0.6em)[.] #h(0.3em) ])
                  #text(font: fonts.header, size: 0.8em, weight: "bold", fill: palette.dark, [#r.value.page])
                ]
              ]
          ]
      }
    }
  }
}

#let default-indexes(recipes) = {
  let all-tags = recipes.map(r => r.value.tags)
                        .flatten()
                        .dedup()
                        .sorted()
  
                        let index = (
    title: [#translate(i18n-words.index)],
    tags: all-tags
  )

  (index,)
}