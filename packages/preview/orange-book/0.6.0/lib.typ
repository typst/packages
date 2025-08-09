#import("my-outline.typ"): *
#import("my-index.typ"): *
#import("theorems.typ"): *

#let scr(it) = text(
  features: ("ss01",),
  box($cal(it)$),
)
#let mathcal = (it) => {
  set text(size: 1.3em, font: "OPTIOriginal", fallback: false)
  it
  h(0.1em)
}

#let normal-text = 1em
#let large-text = 3em
#let huge-text = 16em
#let title-main-1 = 2.5em
#let title-main-2 = 1.8em
#let title-main-3 = 2.2em
#let title1 = 2.2em
#let title2 = 1.5em
#let title3 = 1.3em
#let title4 = 1.2em
#let title5 = 11pt

#let outline-part = 1.5em;
#let outline-heading1 = 1.3em;
#let outline-heading2 = 1.1em;
#let outline-heading3 = 1.1em;


#let nocite(citation) = {
  place(hide[#cite(citation)])
}

#let language-state = state("language-state", none)
#let main-color-state = state("main-color-state", none)
#let appendix-state = state("appendix-state", none)
#let appendix-state-hide-parent = state("appendix-state-hide-parent", none)
#let heading-image = state("heading-image", none)
#let supplement-part-state = state("supplement_part", none)
#let part-style-state = state("part-style", 0)
#let part-state = state("part-state", none)
#let part-location = state("part-location", none)
#let part-counter = counter("part-counter")
#let part-change = state("part-change", false)

#let part(title) = {
  pagebreak(to: "odd")
  part-change.update(x =>
    true
  )
  part-state.update(x =>
    title
  )
  part-counter.step()
  [
    #context{
      let her = here()
      part-location.update(x =>
        her
      )
    }

    #context{
      let main-color = main-color-state.at(here())
      let part-style = part-style-state.at(here())
      let supplement_part = supplement-part-state.at(here())
      if part-style == 0 [
        #set par(justify: false)
        #place(block(width:100%, height:100%, outset: (x: 3cm, bottom: 2.5cm, top: 3cm), fill: main-color.lighten(70%)))
        #place(top+right, text(fill: black, size: large-text, weight: "bold", box(width: 60%, part-state.get())))
        #place(top+left, text(fill: main-color, size: huge-text, weight: "bold", part-counter.display("I")))
      ] else if part-style == 1 [
        #set par(justify: false)
        #place(block(width:100%, height:100%, outset: (x: 3cm, bottom: 2.5cm, top: 3cm), fill: main-color.lighten(70%)))
        #place(top+left)[
          #block(text(fill: black, size: 2.5em, weight: "bold", supplement_part + " " + part-counter.display("I")))
          #v(1cm, weak: true)
          #move(dx: -4pt, block(text(fill: main-color, size: 6em, weight: "bold", part-state.get())))
        ]
      ]
      align(bottom+right, my-outline-small(title, appendix-state, part-state, part-location,part-change,part-counter, main-color, textSize1: outline-part, textSize2: outline-heading1, textSize3: outline-heading2, textSize4: outline-heading3))
    } 
  ]
}

#let chapter(title, image:none, l: none) = {
  heading-image.update(x =>
    image
  )
  if l != none [
    #heading(level: 1, title) #label(l)
  ] else [
    #heading(level: 1, title) 
  ]
}

#let update-heading-image(image:none) = {
  heading-image.update(x =>
    image
  )
}

#let make-index(title: none) = {
  make-index-int(title:title, main-color-state: main-color-state)
}

#let appendices(title, doc, hide-parent: false) = {
  counter(heading).update(0)
  appendix-state.update(x =>
    title
  )
  appendix-state-hide-parent.update(x =>
    hide-parent
  )
  set heading( numbering: (..nums) => {
      let vals = nums.pos()
      if vals.len() == 1 {
        return str(numbering("A.1", ..vals)) + "."
      }
      else {
        context{
          let main-color = main-color-state.at(here())
          let color = main-color
          if vals.len() == 4 {
            color = black
          }
          return place(dx:-4.5cm, box(width: 4cm, align(right, text(fill: color)[#numbering("A.1", ..vals)])))
        }
      }
    },
  )
  doc
}

#let my-bibliography(file, image:none) = {
  counter(heading).update(0)
  heading-image.update(x =>
    image
  )
  file
}

#let theorem(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("theorem", if language=="en" {"Theorem"} else {"Teorema"},
    stroke: 0.5pt + main-color,
    radius: 0em,
    inset: 0.65em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", fill: main-color, x), 
    fill: black.lighten(95%), 
    base_level: 1)(name:name, body)
  }
}

#let definition(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("definition", if language=="en" {"Definition"} else {"Definizione"},
    stroke: (left: 4pt + main-color),
    radius: 0em,
    inset: (x: 0.65em),
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  }
}

#let corollary(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("corollary", if language=="en" {"Corollary"} else {"Corollario"},
    stroke: (left: 4pt + gray),
    radius: 0em,
    inset: 0.65em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x),
    fill: black.lighten(95%), 
    base_level: 1)(name:name, body)
  }
}


#let proposition(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("proposition", if language=="en" {"Proposition"} else {"Proposizione"},
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", fill: main-color, x),
    base_level: 1)(name:name, body)
  }
}


#let notation(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("notation", if language=="en" {"Notation"} else {"Nota"},
    stroke: none,
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  }
}

#let exercise(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("exercise", if language=="en" {"Exercise"} else {"Esercizio"},
    stroke: (left: 4pt + main-color),
    radius: 0em,
    inset: 0.65em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(fill: main-color, weight: "bold", x),
    fill: main-color.lighten(90%), 
    base_level: 1)(name:name, body)
  }
}

#let example(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("example", if language=="en" {"Example"} else {"Esempio"},
    stroke: none,
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(weight: "bold", x), 
    base_level: 1)(name:name, body)
  }
}

#let problem(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("problem", if language=="en" {"Problem"} else {"Problema"},
    stroke: none,
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => text(fill: main-color, weight: "bold", x), 
    base_level: 1)(name:name, body)
  }
}

#let vocabulary(name: none, body) = {
  context{
    let language = language-state.at(here())
    let main-color = main-color-state.at(here())
    thmbox("vocabulary", if language=="en" {"Vocabulary"} else {"Vocabolario"},
    stroke: none,
    radius: 0em,
    inset: 0em,
    namefmt: x => [*--- #x.*],
    separator: h(0.2em),
    titlefmt: x => [■ #text(weight: "bold", x)], 
    base_level: 1)(name:name, body)
  }
}

#let remark(body) = {
   context{
    let main-color = main-color-state.at(here())
    set par(first-line-indent: 0em)
    grid(
    columns: (1.2cm, 1fr),
    align: (center, left),
    rows: (auto),
    circle(radius: 0.3cm, fill: main-color.lighten(70%), stroke: main-color.lighten(30%))[
      #set align(center + horizon)
      #set text(fill: main-color, weight: "bold")
      R
    ],
    body)
  }
}

#let book(title: "", subtitle: "", date: "", author: (), paper-size: "a4", logo: none, cover: none, image-index:none, body, main-color: blue, copyright: [], lang: "en", list-of-figure-title: none, list-of-table-title: none, supplement-chapter: "Chapter", supplement-part: "Part", font-size: 10pt, part-style: 0, lowercase-references: false) = {
  set document(author: author, title: title)
  set text(size: font-size, lang: lang)
  set par(leading: 0.5em)
  set enum(numbering: "1.a.i.")
  set list(marker: ([•], [--], [◦]))

  set ref(supplement: (it)=>{lower(it.supplement)}) if lowercase-references

  
  set math.equation(numbering: num =>
    numbering("(1.1)", counter(heading).get().first(), num)
  )

  set figure(numbering: num =>
    numbering("1.1", counter(heading).get().first(), num)
  )

  set figure(gap: 1.3em)

  show figure: it => align(center)[
    #it
    #if (it.placement == none){
      v(2.6em, weak: true)
    }
  ]

  show terms: set par(first-line-indent: 0em)

  set page(
    paper: paper-size,
    margin: (x: 3cm, bottom: 2.5cm, top: 3cm),
     header: context{
      set text(size: title5)
      let page_number = counter(page).at(here()).first()
      let odd_page = calc.odd(page_number)
      let part_change = part-change.at(here())
      // Are we on an odd page?
      // if odd_page {
      //   return text(0.95em, smallcaps(title))
      // }

      // Are we on a page that starts a chapter? (We also check
      // the previous page because some headings contain pagebreaks.)
      let all = query(heading.where(level: 1))
      if all.any(it => it.location().page() == page_number) or part_change {
        return
      }
      let appendix = appendix-state.at(here())      
      if odd_page {
        let before = query(selector(heading.where(level: 2)).before(here()))
        let counterInt = counter(heading).at(here())
        if before != () and counterInt.len()> 1 {
          box(width: 100%, inset: (bottom: 5pt), stroke: (bottom: 0.5pt))[
            #text(if appendix != none {numbering("A.1", ..counterInt.slice(0,2)) + " " + before.last().body} else {numbering("1.1", ..counterInt.slice(0,2)) + " " + before.last().body})
            #h(1fr)
            #page_number
          ]
        }
      } else{
        let before = query(selector(heading.where(level: 1)).before(here()))
        let counterInt = counter(heading).at(here()).first()
        if before != () and counterInt > 0 {
          box(width: 100%, inset: (bottom: 5pt), stroke: (bottom: 0.5pt))[
            #page_number
            #h(1fr)
            #text(weight: "bold", if appendix != none {numbering("A.1", counterInt) + ". " + before.last().body} else{before.last().supplement + " " + str(counterInt) + ". " + before.last().body})
          ]
        }
      }
    }
  )

  show cite: it => {
    show regex("[\w\W]"): set text(main-color)
    it
  }

  set heading(
    hanging-indent: 0pt,
    numbering: (..nums) => {
      let vals = nums.pos()
      let pattern = if vals.len() == 1 { "1." }
                    else if vals.len() <= 4 { "1.1" }
      if pattern != none { numbering(pattern, ..nums) }
    }
  )

  show heading.where(level: 1): set heading(supplement: supplement-chapter)

  show heading: it => {
    set text(size: font-size)
    if it.level == 1 {
      pagebreak(to: "odd")
      //set par(justify: false)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)
      context{
        let img = heading-image.at(here())
        if img != none {
          set image(width: 21cm, height: 9.4cm)
          place(move(dx: -3cm, dy: -3cm, img))
          place( move(dx: -3cm, dy: -3cm, block(width: 21cm, height: 9.4cm, align(right + bottom, pad(bottom: 1.2cm, block(
            width: 86%,
            stroke: (
                right: none,
                rest: 2pt + main-color,
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
                rest: 2pt + main-color,
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
      }
      part-change.update(x =>
        false
      )
    }
    else if it.level == 2 or it.level == 3 or it.level == 4 {
      let size
      let space
      let color = main-color
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
      let number = if it.numbering != none {
        set text(fill: main-color) if it.level < 4
        let num = counter(heading).display(it.numbering)
        let width = measure(num).width
        let gap = 7mm
        place(dx: -width - gap, num)
      }
      block(number + it.body)
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
    #language-state.update(x => lang)
    #main-color-state.update(x => main-color)
    #part-style-state.update(x => part-style)
    #supplement-part-state.update(x => supplement-part)
    //#place(top, image("images/background2.jpg", width: 100%, height: 50%))
    #if cover != none {
      set image(width: 100%, height: 100%)
      place(bottom, cover)
    }
    #if logo != none {
        set image(width: 3cm)
        place(top + center, pad(top:1cm, logo))
    }
    #align(center + horizon, block(width: 100%, fill: main-color.lighten(70%), height: 7.5cm, pad(x:2cm, y:1cm)[
      #par(leading: 0.4em)[
        #text(size: title-main-1, weight: "black", title)
      ]
      #v(1cm, weak: true)
      #text(size: title-main-2, subtitle)
      #v(1cm, weak: true)
      #text(size: title-main-3, weight: "bold", author)
    ]))
  ]
  if (copyright!=none){
    set text(size: 10pt)
    show link: it => [
      #set text(fill: main-color)
      #it
    ]
    set par(spacing: 2em)
    align(bottom, copyright)
  }
  
  heading-image.update(x =>
    image-index
  )

  my-outline(appendix-state, appendix-state-hide-parent, part-state, part-location,part-change,part-counter, main-color, textSize1: outline-part, textSize2: outline-heading1, textSize3: outline-heading2, textSize4: outline-heading3)

  my-outline-sec(list-of-figure-title, figure.where(kind: image), outline-heading3)

  my-outline-sec(list-of-table-title, figure.where(kind: table), outline-heading3)


  // Main body.
  set par(
    first-line-indent: 1em,
    justify: true,
    spacing: 0.5em
  )
  set block(spacing: 1.2em)
  show link: set text(fill: main-color)

  body

}

