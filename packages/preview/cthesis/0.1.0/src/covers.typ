#import "utils.typ": *

#let cover-font = ("Arial", "TeX Gyre Heros")

#let front-cover(
  title: str,
  subtitle: str,
  image: content,
  program: str,
  authors: array,
  department: str,
  year: int,
  gu: bool,
  type: str,
) = {
  set text(font: cover-font)
  set par(justify: false)  
  page(
    margin: (
      top: 1cm,
      bottom: 2.5cm,
      left: 2.25cm,
      right: 2.25cm,
    ),
  )[
    #align(top + center)[#box(width: 100%, height: 2.85cm)[
      #place(left + horizon, LOGO_HORIZONTAL)
      #place(bottom + center, [#line(length: 100%, stroke: 1pt)])
    ]]
      
    #align(center + horizon)[#box(width: 90%)[#image]]
      
    #align(bottom)[
      #huge(weight: "bold", hyphenate: false, title)
      #linebreak()
      #if subtitle != "" {
        v(0.25em)
        Large(subtitle)
      }
      #v(1em)
      #large[
        #THESIS_TYPE #tr("inom", "in") #program
      ]
      #v(1em)
      #Large[#upper[#authors.join(linebreak())]]
      #v(3em)
      #align(center)[#line(length: 100%, stroke: 1pt)]
      #v(-0.25em)
      #small(weight: "bold")[#department_of(department)]
      #linebreak()
      #smallcaps(CHALMERS)
      #linebreak()
      #if gu { smallcaps(GOTHENBURG_UNIVERSITY); linebreak() }
      #small[#GOTHENBURG_CITY, #year] 
      #linebreak()
      #if not gu { small(link("www.chalmers.se"))  }
    ]
  ]
}

#let back-cover(
  department: [],
  gu: bool,
) = {  
  set text(font: cover-font)
  page(
    margin: (
      top: 1cm,
      bottom: 2.5cm,
      left: 2.25cm,
      right: 2.25cm,
    ),
    numbering: none,
    footer: none,
  )[ 
    #align(top + center)[
      #box(width: 100%, height: 2.85cm)[
        #place(bottom + center, [#line(length: 100%, stroke: 1pt)])
        #align(left + horizon)[
          #small[
            #upper[*#department*] \
            #text(weight: "bold")[
              #upper[
                #CHALMERS \
                #if gu {GOTHENBURG_UNIVERSITY; linebreak()}
              ]
            ]
            #GOTHENBURG_CITY \
            #if not gu { link("www.chalmers.se") }
          ]
        ]
      ]
    ]
    #align(bottom + center)[#LOGO_VERTICAL]
  ]
}