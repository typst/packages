#import("my-outline.typ"): *
#import("my-index.typ"): *
#import("theorems.typ"): *

#let mathcal = (it) => {
  set text(size: 1.3em, font: "OPTIOriginal", fallback: false)
  it
  h(0.1em)
}

#let normalText = 1em
#let largeText = 3em
#let hugeText = 16em
#let title_main_1 = 2.5em
#let title_main_2 = 1.8em
#let title_main_3 = 2.2em
#let title1 = 2.2em
#let title2 = 1.5em
#let title3 = 1.3em
#let title4 = 1.2em
#let title5 = 1.1em

#let outlinePart = 1.5em;
#let outlineHeading1 = 1.3em;
#let outlineHeading2 = 1.1em;
#let outlineHeading3 = 1.1em;


#let nocite(citation) = {
  place(hide[#cite(citation)])
}

#let language_state = state("language_state", none)
#let main_color_state = state("main_color_state", none)
#let appendix_state = state("appendix_state", none)
#let heading_image = state("heading_image", none)
#let supplement_part_state = state("supplement_part", none)
#let part_style_state = state("part_style", 0)
#let part_state = state("part_state", none)
#let part_location = state("part_location", none)
#let part_counter = counter("part_counter")
#let part_change = state("part_change", false)


// pagebreak(to: "odd") is not working correctly
#let pagebreak_until_odd() = {
  pagebreak()
  counter(page).display(i => if calc.even(i) {
    pagebreak()
  })
}

#let part(title) = {
  pagebreak(to: "odd")
  part_change.update(x =>
    true
  )
  part_state.update(x =>
    title
  )
  part_counter.step()
  [
    #locate(loc => [
      #part_location.update(x =>
        loc
      )
    ])

    #locate(loc => [
      #let mainColor = main_color_state.at(loc)
      #let part_style = part_style_state.at(loc)
      #let supplement_part = supplement_part_state.at(loc)
      #if part_style == 0 [
        #set par(justify: false)
        #place(block(width:100%, height:100%, outset: (x: 3cm, bottom: 2.5cm, top: 3cm), fill: mainColor.lighten(70%)))
        #place(top+right, text(fill: black, size: largeText, weight: "bold", box(width: 60%, part_state.display())))
        #place(top+left, text(fill: mainColor, size: hugeText, weight: "bold", part_counter.display("I")))
      ] else if part_style == 1 [
        #set par(justify: false)
        #place(block(width:100%, height:100%, outset: (x: 3cm, bottom: 2.5cm, top: 3cm), fill: mainColor.lighten(70%)))
        #place(top+left)[
          #block(text(fill: black, size: 2.5em, weight: "bold", supplement_part + " " + part_counter.display("I")))
          #v(1cm, weak: true)
          #move(dx: -4pt, block(text(fill: mainColor, size: 6em, weight: "bold", part_state.display())))
        ]
      ]
            #align(bottom+right, my-outline-small(title, appendix_state, part_state, part_location,part_change,part_counter, mainColor, textSize1: outlinePart, textSize2: outlineHeading1, textSize3: outlineHeading2, textSize4: outlineHeading3))
    ])
      
  ]
}

#let chapter(title, image:none, l: none) = {
  pagebreak(to: "odd")
  heading_image.update(x =>
    image
  )
  if l != none [
    #heading(level: 1, title) #label(l)
  ] else [
    #heading(level: 1, title) 
  ]
  part_change.update(x =>
    false
  )
}

#let make-index(title: none) = {
  make-index-int(title:title, main_color_state: main_color_state)
}

#let appendices(title, doc) = {
  counter(heading).update(0)
  appendix_state.update(x =>
    title
  )
  set heading ( numbering: (..nums) => {
      let vals = nums.pos()
      if vals.len() == 1 {
        return str(numbering("A.1", ..vals)) + "."
      }
      else {
        locate(loc => [
        #let mainColor = main_color_state.at(loc)
        #let color = mainColor
        #if vals.len() == 4 {
          color = black
        }
        #return place(dx:-4.5cm, box(width: 4cm, align(right, text(fill: color)[#numbering("A.1", ..vals)])))
        ])
      }
    },
  )
  doc
}

#let my-bibliography(file, image:none) = {
  pagebreak_until_odd()
  counter(heading).update(0)
  heading_image.update(x =>
    image
  )
  file
}

#let theorem(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("theorem", if language=="en" {"Theorem"} else {"Teorema"},
    stroke: 0.5pt + mainColor,
    radius: 0em,
    inset: 0.65em,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", fill: mainColor, x), 
    fill: black.lighten(95%), 
    base_level: 1)(name:name, body)
  })
}

#let definition(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("definition", if language=="en" {"Definition"} else {"Definizione"},
    stroke: (left: 4pt + mainColor),
    radius: 0em,
    inset: (x: 0.65em),
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  })
}

#let corollary(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("corollary", if language=="en" {"Corollary"} else {"Corollario"},
    stroke: (left: 4pt + gray),
    radius: 0em,
    inset: 0.65em,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x),
    fill: black.lighten(95%), 
    base_level: 1)(name:name, body)
  })
}


#let proposition(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("proposition", if language=="en" {"Proposition"} else {"Proposizione"},
    radius: 0em,
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", fill: mainColor, x),
    base_level: 1)(name:name, body)
  })
}


#let notation(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("notation", if language=="en" {"Notation"} else {"Nota"},
    stroke: none,
    radius: 0em,
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  })
}

#let exercise(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("exercise", if language=="en" {"Exercise"} else {"Esercizio"},
    stroke: (left: 4pt + mainColor),
    radius: 0em,
    inset: 0.65em,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(fill: mainColor, weight: "bold", x),
    fill: mainColor.lighten(90%), 
    base_level: 1)(name:name, body)
  })
}

#let example(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("example", if language=="en" {"Example"} else {"Esempio"},
    stroke: none,
    radius: 0em,
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  })
}

#let problem(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("problem", if language=="en" {"Problem"} else {"Problema"},
    stroke: none,
    radius: 0em,
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(fill: mainColor, weight: "bold", x), 
    base_level: 1)(name:name, body)
  })
}

#let vocabulary(name: none, body) = {
  locate(loc => {
    let language = language_state.at(loc)
    let mainColor = main_color_state.at(loc)
    thmbox("vocabulary", if language=="en" {"Vocabulary"} else {"Vocabolario"},
    stroke: none,
    radius: 0em,
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => [■ #text(weight: "bold", x)], 
    base_level: 1)(name:name, body)
  })
}

#let remark(body) = {
   locate(loc => {
    let mainColor = main_color_state.at(loc)
    set par(first-line-indent: 0em)
    grid(
    columns: (1.2cm, 1fr),
    align: (center, left),
    rows: (auto),
    circle(radius: 0.3cm, fill: mainColor.lighten(70%), stroke: mainColor.lighten(30%))[
      #set align(center + horizon)
      #set text(fill: mainColor, weight: "bold")
      R
    ],
    body)
  })
}

#let book(title: "", subtitle: "", date: "", author: (), paper-size: "a4", logo: none, cover: none, imageIndex:none, body, mainColor: blue, copyright: [], lang: "en", listOfFigureTitle: none, listOfTableTitle: none, supplementChapter: "Chapter", supplementPart: "Part", fontSize: 10pt, part_style: 0) = {
  set document(author: author, title: title)
  set text(size: fontSize, lang: lang)
  set par(leading: 0.5em)
  set enum(numbering: "1.a.i.")
  set list(marker: ([•], [--], [◦]))
  show math.equation.where(block: true): e => {
    counter(math.equation).step()
    locate(loc => {
      pad(left: 1cm, {
        box(baseline: 50%, e)
        h(1fr)
        box(baseline: 50%, "(" + str(counter(heading).at(loc).at(0)) + "." + str(counter(math.equation).at(loc).first()) + ")")
      })
    })
  }

  set figure(gap: 1.3em,
  numbering: it => {
    locate(loc => {
      let chapter = counter(heading.where(level: 1)).at(loc).first()
      box[#chapter.#it]
    })
  })

  show figure: it => align(center)[
    #it
    #v(2.6em, weak: true)
  ]

  show terms: set par(first-line-indent: 0em)

  set page(
    paper: paper-size,
    margin: (x: 3cm, bottom: 2.5cm, top: 3cm),
     header: locate(loc => {
      set text(size: title5)
      let page_number = counter(page).at(loc).first()
      let odd_page = calc.odd(page_number)
      // Are we on an odd page?
      // if odd_page {
      //   return text(0.95em, smallcaps(title))
      // }

      // Are we on a page that starts a chapter? (We also check
      // the previous page because some headings contain pagebreaks.)
      let all = query(heading.where(level: 1), loc)
      if all.any(it => it.location().page() == page_number) {
        return
      }
      let appendix = appendix_state.at(loc)      
      if odd_page {
        let before = query(selector(heading.where(level: 2)).before(loc), loc)
        let counterInt = counter(heading).at(loc)
        if before != () and counterInt.len()> 2 {
          box(width: 100%, inset: (bottom: 5pt), stroke: (bottom: 0.5pt))[
            #text(if appendix != none {numbering("A.1", ..counterInt.slice(1,3)) + " " + before.last().body} else {numbering("1.1", ..counterInt.slice(1,3)) + " " + before.last().body})
            #h(1fr)
            #page_number
          ]
        }
      } else{
        let before = query(selector(heading.where(level: 1)).before(loc), loc)
        let counterInt = counter(heading).at(loc).first()
        if before != () and counterInt > 0 {
          box(width: 100%, inset: (bottom: 5pt), stroke: (bottom: 0.5pt))[
            #page_number
            #h(1fr)
            #text(weight: "bold", if appendix != none {numbering("A.1", counterInt) + ". " + before.last().body} else{before.last().supplement + " " + str(counterInt) + ". " + before.last().body})
          ]
        }
      }
    })
  )

  show cite: it  => {
    show regex("\[(\d+)"): set text(mainColor)
    it
  }

  set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      if vals.len() == 1 {
        return str(vals.first()) + "."
      }
      else if vals.len() <=4 {
        let color = mainColor
        if vals.len() == 4 {
          color = black
        }
        return place(dx:-4.5cm, box(width: 4cm, align(right, text(fill: color)[#nums.pos().map(str).join(".")])))
      }
    },
    supplement: supplementChapter
  );

  show heading: it => {
    set text(size: fontSize)
    if it.level == 1 {
      //set par(justify: false)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)
      locate(loc => {
        let img = heading_image.at(loc)
        if img != none {
          set image(width: 21cm, height: 9.4cm)
          place(move(dx: -3cm, dy: -3cm, img))
          place( move(dx: -3cm, dy: -3cm, block(width: 21cm, height: 9.4cm, align(right + bottom, pad(bottom: 1.2cm, block(
            width: 86%,
            stroke: (
                right: none,
                rest: 2pt + mainColor,
            ),
            inset: (left:2em, rest: 1.6em),
            fill: rgb("#FFFFFFAA"),
            radius: (
                right: 0pt,
                left: 10pt,
            ),
            align(left, text(size: title1, it))
          ))))))
          v(8.4cm)
      }
      else{
        move(dx: 3cm, dy: -0.5cm, align(right + top, block(
            width: 100% + 3cm,
            stroke: (
                right: none,
                rest: 2pt + mainColor,
            ),
            inset: (left:2em, rest: 1.6em),
            fill: white,
            radius: (
                right: 0pt,
                left: 10pt,
            ),
            align(left, text(size: title1, it))
          )))
        v(1.5cm, weak: true)
      }
      })
    }
    else if it.level == 2 or it.level == 3 or it.level == 4 {
      let size
      let space
      let color = mainColor
      if it.level == 2 {
        size= title2
        space = 1em
      }
      else if it.level == 3 {
        size= title3
        space = 0.9em
      }
      else {
        size= title4
        space = 0.7em
        color = black
      }
      set text(size: size)
      it
      v(space, weak: true)
    }
    else {
      it
    } 
  }

  set underline(offset: 3pt)

  // Title page.
  page(margin: 0cm, header: none)[
    #set text(fill: black)
    #language_state.update(x => lang)
    #main_color_state.update(x => mainColor)
    #part_style_state.update(x => part_style)
    #supplement_part_state.update(x => supplementPart)
    //#place(top, image("images/background2.jpg", width: 100%, height: 50%))
    #if cover != none {
      set image(width: 100%, height: 100%)
      place(bottom, cover)
    }
    #if logo != none {
        set image(width: 3cm)
        place(top + center, pad(top:1cm, logo))
    }
    #align(center + horizon, block(width: 100%, fill: mainColor.lighten(70%), height: 7.5cm, pad(x:2cm, y:1cm)[
      #par(leading: 0.4em)[
        #text(size: title_main_1, weight: "black", title)
      ]
      #v(1cm, weak: true)
      #text(size: title_main_2, subtitle)
      #v(1cm, weak: true)
      #text(size: title_main_3, weight: "bold", author)
    ]))
  ]
  if (copyright!=none){
    set text(size: 10pt)
    show link: it => [
      #set text(fill: mainColor)
      #it
    ]
    show par: set block(spacing: 2em)
    pagebreak()
    align(bottom, copyright)
  }
  
  heading_image.update(x =>
    imageIndex
  )

  my-outline(appendix_state, part_state, part_location,part_change,part_counter, mainColor, textSize1: outlinePart, textSize2: outlineHeading1, textSize3: outlineHeading2, textSize4: outlineHeading3)

  my-outline-sec(listOfFigureTitle, figure.where(kind: image), outlineHeading3)

  my-outline-sec(listOfTableTitle, figure.where(kind: table), outlineHeading3)


  // Main body.
  show par: set block(spacing: 0.5em)
  set par(
    first-line-indent: 1em,
    justify: true,
  )
  show link: set text(fill: mainColor)

  body

}

