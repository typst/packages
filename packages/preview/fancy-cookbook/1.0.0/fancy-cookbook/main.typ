#import "@preview/ez-today:2.1.0"
#import "themes.typ": *
#import "i18n.typ": *

// export set-theme
#let set-theme = set-theme

// Cover image
#let cover-image = image.with(
    width: 100%,
    height: 60%,
    fit: "cover"
  )
// Back cover image
#let back-cover-image = image.with(width: 60%)


// =============== Fonts and Icons =====================

#let fonts = (
  body: ("PT Serif", "New Computer Modern"),
  header: ("PT Sans", "Libertinus Serif", "Harano Aji Mincho"),

  mono: ("JetBrainsMono NF", "Courier New"),
)

// the icons are made with the given color to respect the theme
#let make-icons(color) = {
  let c = color.to-hex()
  (
    time: box(height: 0.8em, baseline: 0.1em, image(bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='" + c + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='12' cy='12' r='10'/><polyline points='12 6 12 12 16 14'/></svg>"), format: "svg")),
    yield: box(height: 0.8em, baseline: 0.1em, image(bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='" + c + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'></path><circle cx='9' cy='7' r='4'></circle><path d='M23 21v-2a4 4 0 0 0-3-3.87'></path><path d='M16 3.13a4 4 0 0 1 0 7.75'></path></svg>"), format: "svg")),
    fire: box(height: 0.8em, baseline: 0.1em, image(bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='" + c + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.1.243-2.143.5-3.143.51.758 1.573 1.7 1.5 3.143z'/></svg>"), format: "svg")),
  )
}

// =============== Main Template =====================

#let cookbook(
  title: "Recipe Collection",
  book-author: "Unknown",
  subtitle: "Ours Recipe",
  date: datetime.today(),
  paper: "a4",
  cover-image: none,
  custom-i18n: none,
  style: style.flat,
  chapter-start-right: false,
  theme: themes.grey,
  back-cover-content: none,
  back-cover-image: none,
  indexes: none,
  custom-appendices: none,
  body
) = {
  // Add custom translation if exists
  if custom-i18n != none {
    update-translation(custom-i18n)
  }

  // set the style between "flat" or "gradient"
  set-style(style)

  // set the firts theme
  set-theme(theme)

  // -------------- General Settings of the document --------------------  
  set document(title: title, author: book-author)
  
  set text(
    font: fonts.body,
    size: 11pt,
    features: (onum: 1)
  )
    
  set page(
    paper: paper,
    margin: (x: 2cm, top: 2.5cm, bottom: 2.5cm),
    header: context {

      set par(spacing: 1.2em) // to protect from changes for the content
      let p = counter(page).get().first()
      if p > 1 {
        let theme = theme-state.get()
        set text(font: fonts.header, size: 9pt, fill: theme.dark)
        
        // get the previous chapter for the header
        let headings = query(selector(heading.where(level: 1)).before(here()))
        let chapter = if headings.len() > 0 {
          headings.last().body
        } else {
          []
        }
        
        grid(
          columns: (1fr, 1fr),
          align(left, title),
          align(right, chapter)
        )
        v(-0.8em)
        line(length: 100%, stroke: 0.5pt + theme.medium)
      }
    },
    footer: context {
      let theme = theme-state.get()
      set text(font: fonts.header, size: 9pt, fill: theme.dark)
      let p = counter(page).get().first()
      line(length: 100%, stroke: 0.5pt + theme.medium)
      align(center)[— #p —]
    }
  )
    
    
  // Headings
  show heading.where(level: 1): it => {
    
    // If we want the chapter header to always be at right
    if chapter-start-right {
      pagebreak(to: "odd", weak: true)
    }
    
    
    counter(heading).step(level: 1)
    context {
      let theme = theme-state.get()
    

      set align(center + horizon)
      block(width: 100%)[
        #text(font: fonts.header, weight: "black", size: 3.5em, fill: theme.dark, it.body)
      ]
    }
  }
    
  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    block(below: 1.5em,  // ← ajustez "below" selon votre goût
      text(font: fonts.header, weight: "bold", size: 2.2em, it.body)
    )
  }

  // reference on recipe
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 2 {
      context {
        let p = counter(page).at(el.location()).first()
        [#el.body (p. #p)] 
      }
    } else {
      it
    }
  }
  
  // -------------- Cover Page --------------------
  if title != none {
    page(margin: 0pt, header: none)[
      // Optional Background Image
      #if cover-image != none {
        place(top, cover-image)
      }
      
      #place(center + horizon)[
        #block(
           width: 75%, 
           stroke: (
             top: 4pt + theme.dark, 
             bottom: if cover-image == none { 4pt + theme.dark } else { none }
           ), 
           inset: (y: 3em),
           fill: if cover-image != none { theme.light } else { none },
           outset: if cover-image != none { 1cm } else { 0cm }
        )[
          #par(leading: 0.35em)[
            #text(font: fonts.header, weight: "black", size: 4.5em, title)
          ]
          #v(1.5em)
          #text(font: fonts.body, style: "italic", size: 1.5em, fill: theme.dark, subtitle)
        ]
      ]
      #context {
        place(bottom + center)[
           #pad(bottom: 3cm, text(font: fonts.header, size: 0.8em, tracking: 3pt, fill: theme.dark, upper(ez-today.today(lang: text.lang, format: "M Y") )))
        ]
      }
    ]
  }
  
  // -------------- TOC --------------------
  page(header: none)[
    #v(3cm)
    #align(center)[
       #text(font: fonts.header, weight: "bold", size: 1.2em, tracking: 2pt, upper(translate(i18n.toc)))
       #v(1em)
       #line(length: 3cm, stroke: 0.5pt + theme.dark)
    ]
    #v(1.5cm)
    
    #show outline.entry: it => {
      context {
        if it.level == 1 {
            align(center)[
              #box(width:70%)[
              // Section / Chapter Header
              #v(1.5em)
              #text(font: fonts.header, weight: "black", fill: theme.dark, size: 1.3em, upper(it.element.body))
              #h(1fr)
              // No page number for chapters, looks cleaner
              ]
            ]
          } else {
            align(center)[
              // Recipe Entry
              #v(0.5em)
              #box(width: 65%)[
                #link(it.element.location())[
                  #text(font: fonts.body, size: 1.1em, it.element.body)
                  #box(width: 1fr, repeat[ #h(0.3em) #text(fill: theme.dark, size: 0.6em)[.] #h(0.3em) ])
                  #text(font: fonts.header, weight: "bold", fill: theme.dark, [#it.element.location().page()])
                ]
              ]
            ]
          }
      }
    }
    #outline(title: none, indent: 0pt, depth: 2)
  ]
  // ----------------- Body --------------
  
  body

  // ---------------- Annexes ------------------
  context {
    let recipes = query(selector(metadata))
                    .filter(x => x.value.kind == "recipe")
  
  
    let all-tags = recipes.map(r => r.value.tags)
                          .flatten()
                          .dedup()
                          .sorted()
                          
    // We show annexes only if there is tags or custom annexes
    if all-tags.len() > 0 or annexes!= none {
      
      set-theme(theme) // The theme from cookbook
      heading(level: 1, translate(i18n.annexes))


      if all-tags.len() > 0 {

        // ------- indexes pages ----------------

        set par(spacing: 0.5em)
        
        if indexes != none and indexes.len() > 0 {
          // custom index pages
          for index in indexes {
            heading(level: 2, index.title)

            for tag in index.tags {
              align(center)[
                #box(width:70%)[
                  // Tag
                  #v(0.5em)
                  #text(font: fonts.header, weight: "black", fill: theme.dark, size: 0.8em, upper(tag))
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
                          #box(width: 1fr, repeat[ #h(0.3em) #text(fill: theme.dark, size: 0.6em)[.] #h(0.3em) ])
                          #text(font: fonts.header, size: 0.8em, weight: "bold", fill: theme.dark, [#r.value.location.position().page])
                        ]
                      ]
                  ]
              }
            }
          }
        } else {
          // default index pages
          heading(level: 2, translate(i18n.index))
      
          for tag in all-tags {
    
            align(center)[
              #box(width:70%)[
                // Tag
                #v(0.5em)
                #text(font: fonts.header, weight: "black", fill: theme.dark, size: 0.8em, upper(tag))
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
                    #box(width: 1fr, repeat[ #h(0.3em) #text(fill: theme.dark, size: 0.6em)[.] #h(0.3em) ])
                    #text(font: fonts.header, size: 0.8em, weight: "bold", fill: theme.dark, [#r.value.location.position().page])
                  ]
                ]
              ]
            }
          }
        }
      }
      // if custom annexes
      custom-appendices
    }                        
  }
  

  // --------------- Back Cover -------------
  if back-cover-content != none or back-cover-image != none {
    pagebreak(to:"even", weak:true)
    page(margin: 5cm, header: none, footer: none)[

      #set par(spacing: 3em)
      
      #place(center + horizon)[

        // Title
        #text(font: fonts.header, weight: "bold", fill: theme.dark, size: 2em, title)

        // Back cover image
        #if back-cover-image != none {
          back-cover-image
        }
        // separation line
        #if back-cover-content != none and back-cover-image != none {
           line(length: 5cm, stroke: 0.5pt + theme.dark)
        }
        // back cover content
        #if back-cover-content != none {  
          text(font: fonts.header, size: 1em, tracking: 2pt, back-cover-content)
        }
        // author
        #par(
            text(font: fonts.header, style: "italic", fill: theme.dark, size: 1.2em, book-author)
          )
      ]
    ]
  }
}


// =============== Not a Recipe =====================

// a simple part for what is not a recipe
#let not-a-recipe(name: none, body) = {

  set par(first-line-indent: (amount: 2em, all: true))
  set list(indent: 2em, body-indent: 0.5em)
  
  if name != none {
    heading(level: 2, name)
  }
  v(4em)
  body
}



// =============== Recipe =====================
#let recipe(
  name,
  ingredients: [],
  instructions: [],
  description: none,
  image-left: none,
  image-right: none,
  servings: none,
  prep-time: none,
  cook-time: none,
  notes: none,
  notes-right: none,
  author: none,
  label: none,
  tags: ()
) = context {

  metadata((kind: "recipe", title: name, tags: tags, location: here()))

  // 1. Header Section
  let head = heading(level: 2, name)
  if label != none {
    [#head #label]     // on attache le label au heading
  } else {
    head
  }
  
  // Where we get the color theme
  let theme = theme-state.get()

  // Description & Meta row
  grid(
    columns: (1fr, auto),
    align(left + horizon, {
      if description != none {
        text(font: fonts.body, style: "italic",  description)
      }
    }),
    align(right + horizon, {
      let themed-icons = make-icons(theme.dark)
      set text(font: fonts.header, size: 0.9em, fill: black)
      let meta = ()
      if servings != none { meta.push([#themed-icons.yield #h(0.3em) #servings]) }
      if prep-time != none { meta.push([#themed-icons.time #h(0.3em) #prep-time]) }
      if cook-time != none { meta.push([#themed-icons.fire #h(0.3em) #cook-time]) }
      if meta.len() > 0 {
        meta.join(h(1.5em))
      }
    })
  )
  
  v(0.1em)
  line(length: 100%, stroke: 0.5pt + theme.medium)
  v(1em)

  // 2. Main Layout (Sidebar + Content)
  grid(
    columns: (35%, 1fr),
    gutter: 2.5em,
    
    // -- Left Column: Ingredients --
    {
      if image-left != none  {
        block(width: 100%, height: auto, clip: true, radius: 4pt, image-left)
        v(0.5em)
      }
      let style = style-state.get()

      block(
        fill: fill-ingredients(style, theme),
        inset: 1.2em,
        radius: 4pt,
        width: 100%,
        stroke: 0.5pt + theme.medium,
      )[
        #text(font: fonts.header, weight: "bold", size: 1.1em, translate(i18n.ingredients))
        
        #set list(
          marker: box(
            height: 0.8em, width: 0.8em,
            stroke: 1pt + theme.dark,
            radius: 2pt,
            baseline: 20%,
          ),
          spacing: 1.5em,
          body-indent: 0.8em
        )
        
        #v(0.8em)
        #set text(size: 0.95em)

        #if type(ingredients) == content {
            ingredients
        } else {
          // to know if ingredients is a list of groups of ingredients or a content
          let is-grouped = ingredients.len() > 0 and type(ingredients.first()) == dictionary and "items" in ingredients.first()
        
          if is-grouped {
            for group in ingredients {
              block(breakable: false, {
                // Titre du groupe
                text(font: fonts.header, weight: "bold", size: 1.1em, fill: ingredient-group-color(style, theme), group.at("title", default: ""))
                v(0.4em)
                group.at("items")       
              })
              v(0.4em) // space between groups
            }
          }
        }          
      ]
      // ---- Author
      if author != none {
        v(0.5em)
        block(breakable: false, {
          text(font: fonts.header, size: 0.9em, weight: "bold", fill: theme.dark, translate(i18n.author))
          v(0.1em)
          text(weight: "bold", size: 0.9em, author)
        })
      }

      // ---- notes
      if notes != none {
        v(0.5em)
        block(breakable: false, {
          text(font: fonts.header, size: 0.9em, weight: "bold", fill: theme.dark, translate(i18n.notes))
          v(0.1em)
          text(style: "italic", size: 0.9em, fill: theme-grey.dark, notes)
        })
      }
    },

    // -- Right Column: Instructions --    
    {
      if image-right != none {
        align(center, {
          block(width: 100%, height: auto, clip: true, radius: 4pt, image-right)
          v(0.5em)
        })
      }
      
      text(font: fonts.header, weight: "bold", size: 1.1em, translate(i18n.preparation))
      v(1em)
      
      counter("recipe-step").update(0)
      
      set enum(
        numbering: n => {
          counter("recipe-step").step()
          text(font: fonts.header, size: 1.2em, weight: "bold", fill: theme.dark,
            box(inset: (right: 0.5em), context counter("recipe-step").display()))
        }
      )
      set par(leading: 1em, justify: true)
      
      show enum.item: it => {
        pad(bottom: 0.6em, it)
      }
    
      // // to know if instructions is a list of groups of instructions or a content
      let is-grouped = (
        type(instructions) == array
        and instructions.len() > 0
        and type(instructions.first()) == dictionary
        and "steps" in instructions.first()
      )
    
      if is-grouped {
        for section in instructions {
          block(breakable: false, {
            // section title
            text(font: fonts.header, weight: "bold", size: 1.2em, fill: theme.dark,
              section.at("title", default: ""))
            v(0.5em)
            section.at("steps", default: [])
          })
          v(0.6em)
        }
      } else {
        instructions
      }

      // ---- notes right
      if notes-right != none {
        v(0.5em)
        block(breakable: false, {
          text(font: fonts.header, size: 0.9em, weight: "bold", fill: theme.dark, translate(i18n.notes))
          v(0.1em)
          text(style: "italic", size: 0.9em, fill: theme-grey.dark, notes-right)
        })
      }
    }
  )
}