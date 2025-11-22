#let script-size = 15pt
#let normal-size = 20pt
#let large-size = 30pt
#let very-large-size = 38pt
#let huge-size = 58pt

#let logo-light-image = state("logo-light-image", none)

#let section-page = state("section-page", false)

#let columns-content(..args) = {
  let slide-info = args.named()
  let bodies = args.pos()
  let colwidths = none
  let thisgutter = 1cm
  if "colwidths" in slide-info{
  colwidths = slide-info.colwidths
  if colwidths.len() != bodies.len(){
    panic("Provided colwidths must be of same length as bodies")
  }
  }
  else{
    colwidths = (1fr,) * bodies.len()
  }
  if "gutter" in slide-info{
    thisgutter = slide-info.gutter
  }
  grid(
    columns: colwidths,
    gutter: thisgutter,
    ..bodies
  )
}


#let project(
  title: [Title],
  sub-title: [sub-title],
  author: none,
  date: none,
  aspect-ratio: "16-9",
  main-color: rgb("#E30512"),
  text-color-light: white,
  text-color-dark: black,
  cover: none, 
  logo: none,
  logo-light: none,
  index-title: none,
  body
) = {
  set document(title: title, author: author)
  set text(fill: text-color-dark, size: normal-size, lang: "it")
  set underline(offset: 3pt)
  set page(
    paper: "presentation-" + aspect-ratio,
    margin: 0pt,
  )

  set list(tight:true, indent: 0.27cm ,body-indent: 0.7cm, marker: (place(center, dy: -0.25em, text(size: 1.5em, fill: main-color, "▶")), place(center, dy: -0.2em, text(size: 1.3em, fill: main-color, "■"))))

  set enum(numbering: (..args) => text(fill:main-color, numbering("1.", ..args)))


  set figure(gap: 20pt)
  show figure: it => [
    #set text(size: script-size)
    #it
  ]

  show raw: set text(size: 12pt)

  let page-number-int() = {
    let lastpage-number = context{counter(page).final(here()).at(0)}
    set align(right)
    text(size: script-size)[
      #counter(page).display("1 / 1", both: true)
    ]
  }

  let page-number() = {
     place(bottom + right)[
      #pad(bottom: 0.5cm, right: 0.5cm)[
        #let lastpage-number = context{counter(page).final(here()).at(0)}
        #set align(right)
        #text(size: script-size)[
          #counter(page).display("1 / 1", both: true)
        ]
      ]
    ]
  }

  let slide-polygon() = {
    place(top+left, polygon(
        fill: main-color,
        (0cm, 0cm),
        (0cm, 3cm),
        (0.4cm, 3cm),
        (0.4cm, 0cm),
    ))
  }

  let slide-logo(theLogo) = {
    if theLogo!= none {
    place(top + right, dx: -0.5cm, dy: 0.5cm)[
      #set image(width: 2.5cm)
        #theLogo
      ]
    }
  }

  // Display the title page.
  page(margin: 0pt)[
    #set text(fill: text-color-light)
    #if (cover != none){
      place()[
        #set image(width: 100%, height: 100%)
        #cover
        ]
    }
    #logo-light-image.update(x =>
      logo-light
    )
    #place(block(fill: rgb("000000C2"), width: 100%, height: 100% + 1pt))
    #place(
      polygon(
      fill: main-color,
      (100%, 0%),
      (55%, 0%),
      (80%, 100%),
      (100%,  100%),
    ))

    #slide-logo(logo-light)
    #pad(left: 1.5cm, right: 10cm, y: 1.5cm)[
      #v(1fr)
      #block(width: 15cm)[ #par(leading: 1cm)[
          #text(size: 62pt, weight: "regular", upper(title))
      ]]
      #v(0.5cm)      
      #text(size: 30pt, weight: "regular", sub-title)
      #v(1fr)
      #if author != none {
          text(size: normal-size)[#author]
      } --
      #if date != none {
          text(size: normal-size)[#date]
      }
    ]
  ]

  set page(
    background: context{
    if section-page.at(here()) {
      rect(width: 100%, height: 100%, fill: main-color)
      place(top,
        polygon(
        fill: white,
        (90%, 20%),
        (90% - 1.2cm, 20%),
        (90% - 1.2cm, 90%),
        (90% - 1.2cm, 20%),
        (90% - 1.2cm, 90% - 1.2cm),
        (90% - 9cm,  90% - 1.2cm),
        (90% - 9cm,  90%),
        (90%, 90%),
        (90%, 20%)
      ))

      context{
          let logo-light = logo-light-image.at(here())
          place(top + right, dx: -0.5cm, dy: 0.5cm)[
            #set image(width: 2.5cm)
            #logo-light
          ]
      }

      place(bottom + right)[
          #pad(bottom: 0.5cm, right: 0.5cm)[
            #let lastpage-number = context{counter(page).final(here()).at(0)}
            #set align(right)
            #text(fill: white, size: script-size)[
              #counter(page).display("1 / 1", both: true)
            ]
          ]
      ]
    }
    else{
      [
        #slide-logo(logo)
        #slide-polygon()
        #page-number()
      ]
    }
    },
    margin: (top:4cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)
  )

  set align(horizon)

  // Display the summary page.
  place(top + left, dy: -4cm,  block(height: 3cm, width: if logo!= none {100% - 2.5cm} else {100%}, align(horizon, text(size: very-large-size, weight: "regular", index-title))))
  context{
      let elems = query(selector(heading.where(level: 1)).after(here()))
      enum(tight: false, ..elems.map(elem => {link((page: elem.location().page() + 1, x: 0pt, y: 0pt),elem.body)}))
  }

  show link: it => [
    #set text(fill: main-color)
    #underline(it)
  ]

  show heading.where(level: 1): it => [
    #section-page.update(x =>
      true
    )
    #pagebreak(weak: true)
    #set text(huge-size, fill: white, weight: "bold")
    #move(dy: -1.5cm, place(horizon, pad(right:5cm, upper(it.body))))
  ]

  show heading.where(level: 2): it => {
    section-page.update(x =>
      false
    )
    pagebreak()
    set text(very-large-size, weight: "regular")
    place(top + left, dy: -4cm,  block(height: 3cm, width: if logo!= none {100% - 2.5cm} else {100%}, align(horizon, it.body)))
  }

  show heading.where(level: 3): it => {
    pagebreak()
    context{
        let elems = query(selector(heading.where(level: 2)).before(here()))
        let heading2 = elems.last().body
        place(top + left, dy: -4cm,  block(height: 3cm, width: if logo!= none {100% - 2.5cm} else {100%}, align(horizon, [#block(below: 0em, above: 0em, text(heading2, size: very-large-size, weight: "regular")) #block(below: 0em, above: 0.65em, text(it.body, size: normal-size, weight: "regular"))])))
    }
  }

  // Add the body.
  body
}