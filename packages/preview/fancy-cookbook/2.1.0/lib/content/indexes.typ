#import "../assets/fonts.typ": fonts 
#import "../i18n/i18n.typ": translate
#import "../i18n/translations.typ": i18n-words

// Extract text from a content
#let content-to-str(c) = {
  if type(c) == str {
    c
  } else if type(c) == content {
    if c.has("text") {
      c.text
    } else if c.has("children") {
      c.children.map(content-to-str).join("")
    } else if c.has("body") {
      content-to-str(c.body)
    } else {
      ""
    }
  } else {
    ""
  }
}

// choose the right key to sort recipe by name
#let sort-key(r) = {
  let t = r.value.title
  
  // Case 1 : sort-title in priority because explicitly defined
  if r.value.sort-title != none {
    return lower(content-to-str(r.value.sort-title))
  }
  
  // Case 2 : Try to extract text from the content
  let extracted = content-to-str(t)
  if extracted != "" {
    return lower(extracted)
  }
  
  // Case 3 : last chance
  return lower(repr(t))
}


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
  
      let filtered = recipes
        .filter(r => tag in r.value.tags)
        .sorted(key: r => sort-key(r))
                            
  
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