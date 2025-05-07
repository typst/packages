#import "@preview/polylux:0.4.0": *
#import "@preview/ez-today:0.3.0"
#import "math-utils.typ" : *

// States for basic Data
#let title-state=state("title",[])
#let author-state=state("author",[])
#let affiliation-state=state("affiliation",[])
#let date-state=state("date",[])

// Color-Schemes
#let fma = rgb(209, 63, 88)
#let fma-light = rgb(232, 159, 171)
#let fma-lighter = rgb(251, 240, 242)

// Base-Theme
#let ovgu-fma-theme(
  //aspect-ratio: "16-9",
  text-font: "Liberation Sans",
  text-lang: "de",
  text-size: 20pt,
  author:[],
  title:[],
  affiliation:[],
  date:[],
  body
) = {
  set text(
    font: text-font,
    lang: text-lang,
    size: text-size,
  )
  set par(
    justify: true,
  )
  set page(
    paper: "presentation-16-9",
    margin: (top:0em, bottom: 0em, left:0em, right: 0em),
    header: none,
    footer: none,
  )
  context {
    title-state.update(title)
    author-state.update(author)
    affiliation-state.update(affiliation)
    date-state.update(date)
  }
  body
}

/// Slide for the title
#let title-slide(
  author: none,
  date:none,
  title:none,
  subtitle:none,
) = {
  let content = context {
    set align(center+horizon)
    if text.lang == "de" {
      image("Signet_FMA_de.svg")
    } else if text.lang == "en" {
      image("Signet_FMA_en.svg")
    } else {
      image("Signet_FMA.svg")
    }
    v(-1.5em)
    rect(
      stroke: (top:fma+4pt,bottom:fma+4pt),
      inset: 1em,
      [
        #text(size: 2em)[#if title==none [*#title-state.get()*] else [#title]] \
        #text(size: 1.5em)[#subtitle]
      ]
    )
    [
      #if author == none {
        author-state.get()
      } else {
        author
      } \
      #if date == none {
        date-state.get()
      } else {
        date
      }
    ]
  }
  slide(content)
}

/// Base for the rest of the slides
#let slide-base(
  heading: none,
  show-section: true,
  body
) = {
  set page(
    margin: (top:20%,bottom: 10%),
    //HEADER
    header: context {
      let pic_size=115%
      table(
        align: horizon,
        columns: (1fr,1fr,1fr),
        rows: (1fr),
        stroke: (bottom: fma+3pt,left:0pt,right:0pt,top:0pt),
        //LEFT
        context {
          if text.lang == "de" {
            image("Signet_FMA_de.svg",height: pic_size)
          } else if text.lang == "en" {
            image("Signet_FMA_en.svg",height: pic_size)
          } else {
            image("Signet_FMA.svg",height: pic_size)
          }
        },
        //CENTER
        block(
          width: 100%,
          height: 100%
        )[
          #set align(center)
          #set text(size: 0.9em)
          *#title-state.get()*
        ],
        //RIGHT
        block(
          width: 100%,
          height: 100%,
        )[
          #set align(right+horizon)
          #set text(size: 0.7em)   
          #author-state.get() \
        ]
      )
    },
    //FOOTER
    footer: context {
      set text(
        fill: white,
        size: 0.8em
      )
      table(
        fill: fma,
        columns: (1fr,2fr,1fr),
        rows: (100%),
        stroke: fma+1pt,
        align: horizon,
        block(
          width: 100%,
          height: 100%,
        )[
          //LEFT
          #set align(left)
          #ez-today.today()
        ],
        block(
          width: 100%,
          height: 100%,
        )[
          //CENTER
          #set align(center)
          #if show-section {
            toolbox.all-sections(
              (sections,current)=>[*#current*]
            )
          }
        ],
        block(
          width: 100%,
          height: 100%,
        )[
          //RIGHT
          #set align(right)
          #toolbox.slide-number / #toolbox.last-slide-number
        ],
      )
    }
  )
  //Main-Content of the slide
  let content = {
    set par(justify: true)
    //HEADING
    if heading != none { 
      pad(
        x: 1em,
      )[
        #text(size: 1.5em)[*#heading*]
      ]
    }
    //BODY
    pad(
      x: 1em
    )[
      #body
    ]
  }
  //SLIDE
  slide(content)
}

/// Basic slide type for the main content
#let folie(
  heading: none,
  body
) = {
  let content = body
  slide-base(show-section: true,heading: heading)[#content]
}

/// Slide to show a outline
#let outline-slide(
  heading:none,
  body
)={
  let head = context {
    if text.lang == "de" {
      "Gliederung"
    } else if text.lang == "en" {
      "Outline"
    } else {
      "Outline"
    }
  }
  slide-base(
    heading: [#if heading==none [#head] else {heading}],
    show-section: false,
  )[
    #toolbox.all-sections((sections,current)=> {
      enum(
        ..sections,
        tight: false, 
        indent: 1em,
        body-indent: 1em,
        spacing: 1.5em,
      )
    })
  ]
}

/// Slide to show a outline point
#let header-slide(
  body
)={
  //Register heading in polylux environment
  toolbox.register-section(body)
  //Define the page-content
  let content = {
    set align(center+horizon)
    block(height: 90%)[
      #rect(
        stroke: (top:fma+4pt,bottom:fma+4pt),
        inset: 1em,
        heading(bookmarked: true)[#body]
      )
    ]
  }
  //Show slide
  slide-base(show-section: false, content)
}

/// Slide to show the bibliography
// #let bib-slide(
//   path_to_bib:none,
//   heading: none,
//   body
// )={
//   let head = context {
//     if text.lang == "de" {
//       "Bibliographie"
//     } else if text.lang == "en" {
//       "Bibliography"
//     } else {
//       "Bibliography"
//     }
//   }
//   slide-base(
//     heading: if heading == none [#head] else [#heading],
//     show-section: false,)[
//     #if path_to_bib != none {
//       bibliography(title: none,path_to_bib)
//     } else {
//       body
//     }
//   ]
// }