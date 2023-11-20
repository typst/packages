#let slide-count = counter("slide")
#let slide-type = state("stype", 0)

#let define-style(color: rgb("#0328fc"), font: "IBM Plex Sans", ..args) = {
  let primary-color = color
  let secondary-color = color.lighten(20%)
  let subtle-color = color.lighten(70%)
  let dark-color = color.darken(20%)
  let font-color = luma(30)
  let font-subtle-color = luma(80)

  let color-120 = color.rotate(120deg)
  let color-240 = color.rotate(240deg)

  let accent-color = primary-color.negate()
  let accent-color-heavy = accent-color.darken(30%)
  let accent-color-light = accent-color.lighten(20%)

  // all optional parameters
  let radius = 15pt;
  if args.named().keys().contains("radius") {
    radius = args.named().at("radius")    
  }

  let dict = (
      "primary-color": color,
      "secondary-color": secondary-color,
      "subtle-color": subtle-color,
      "dark-color": dark-color,
      "accent-color": accent-color,
      "accent-color-heavy": accent-color-heavy,
      "accent-color-light": accent-color-light,
      "color-120": color-120,
      "color-240": color-240,
      "font-color": font-color,
      "font-subtle-color": font-subtle-color,
      "font": font,
      "radius": radius,
      )

  dict
}

#let default-sets(body) = {
  set underline(stroke: (cap: "round"), offset: 1.3pt)

  set image(fit: "contain")

  show raw.where(block: true): orig => block(
      fill: luma(235),
      width: 100%,
      inset: 10pt,
      radius: 8pt,
      [
      #set text(font: "Fira Code", ligatures: true)  
      #set align(right)
      #place(
          top + right,
          text(gray, orig.lang)    
      )
      #set align(left)
      #orig
      ]
  )

  show raw.where(block: false): orig => {
      box(fill:luma(230), radius: 2pt, height: 1em, inset: 0.1em)[
      #set text(font: "Fira Code", ligatures: true)  
      #orig
      ]
  }

  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
        numbering(
            el.numbering,
            ..counter(eq).at(el.location())
        )
    } else {
        it
    }
  }

  body
}

#let default-page-settings(style, title: "", description: "", body) = {
  set page(
      paper: "presentation-16-9", 
      margin: (
        left: 80pt, 
        right: 80pt,
        bottom: 0pt
        ),
      header: none,
      )

    show outline.entry: it => {
      set text(weight: "bold")
        grid(
            columns: (auto, auto),
            [#it.body],
            [#line(start: (0.2em, 0.7em), length: 100%, stroke: (dash: "loosely-dotted", cap: "round"))]
            )
        v(-35pt)
    } 

  show figure: fig => {
    box(radius: style.radius, clip: true, fill: white)[#fig]
  }

  set cite(style: "chicago-author-date")
  show figure.caption: set text(size: 13pt)

  show: default-sets.with()

  set list(indent: 0pt)

  show heading.where(level: 1): it => {
    underline(
        stroke: (paint: style.accent-color-light, thickness: 2pt, cap: "round"),
        offset: 3pt)[#it]
      v(25pt)
  }

  show heading.where(level: 2): it => {
    set text(size: 20pt)
    it.body
  }

  set text(size: 18pt, font: style.font, fill: style.font-color)

  let pageNumb(curr, total) = {
    if curr != 0 {
      place(right + bottom, dy: -28pt, dx: 40pt)[
        #set text(style.secondary-color, weight: 600)
        #curr
        #set text(fill: style.font-subtle-color)
        \/ #total
      ]
    }
  }

  set page(
      fill: luma(245),
      footer: [
        #set text(size: 9pt, fill: style.secondary-color, weight: 500)
        #locate(loc => {
          let slide = slide-count.at(loc).first()
          let tp = slide-type.at(loc)
          if slide != 0 [
            #place(left+bottom, dy: -23pt, dx: -00pt)[
            #title \
              // #h(2%)
            #let col = if tp != 1 {
              style.subtle-color
              } else {
              style.secondary-color.lighten(30%)
              }
            #set text(fill: col, weight: 500)
            #description
            ]
          ]
        })
        #slide-count.display(pageNumb, both: true)
      ]
    )

  body
}

#let set-type(num) = {
  slide-type.update(num)
}

#let default-slide(style, count: 0, body) = {
  set page(
      fill: luma(245),
      )

    set text(font: style.font, fill: style.font-color)

    slide-type.update(0)

    body
}

#let new-slide() = {
  pagebreak()
    slide-count.step()
}

#let to-string(input) = {
  if type(input) == str {
    input
  } else if type(input) == array {
    if type(input.at(0, default: "")) == str {
        input.join(", ")
      }
  }
}

#let title-slide(style: (), title: "", title-color: false, ..args) = {
  let authors = ""
  if args.named().keys().contains("author") {
    authors = to-string(args.named().at("author"))
  } else if args.named().keys().contains("authors") {
    authors = to-string(args.named().at("authors"))
  }

  page(fill: style.primary-color)[
    #set align(horizon)
    #let clr = luma(255)

    #if title-color {
      clr = style.accent-color-light
    } 

    #set text(size: 60pt, weight: 800, fill: clr)
    #title \

    #set text(size: 60pt, weight: 800, fill: luma(255))
    #if args.named().keys().contains("description") [
      #let description = args.named().at("description")

      #v(-47pt)
      #set text(size: 20pt)

      #description 

      #v(50pt)
      #set align(right)
      #place(right + bottom, dy: -60pt, dx: 20pt)[
        #set text(size: 20pt, weight: 600, fill: style.subtle-color) 
        #authors
    ]

    ] else [
      #set text(size: 30pt, weight: 600, fill: style.subtle-color) 
      #authors
    ]
  ]
}

#let accent-slide(style, body) = {
  set page(
      fill: style.subtle-color
      )

    set text(fill: style.dark-color)

    slide-type.update(1) 

    body
}

#let animated-slide(style, ..elements) = {
  let count = 0
  for len in range(elements.pos().len()) { 
    if count > 0 [
      #pagebreak()
    ]

    default-slide(style, count: count)[
      #set heading(outlined: false) if (count > 0)
      #for i in range(len + 1) [
        #elements.pos().at(i)
      ]
    ]
    
    count += 1
  }
}

#let set-style(style, title: "", description: "", body) = {
  show: default-page-settings.with(style, title: title, description: description)

  body
}

// create slides using this function:
#let slides(title-color: false, ..args, body) = {
  // default title is empty
  let title = ""
  if args.named().keys().contains("title") {
    title = args.named().at("title")
  }

  // default description is empty
  let description = ""
  if args.named().keys().contains("description") {
    description = args.named().at("description")
  }
  
  // default style is blue with IBM Plex Sans font
  let style = define-style(color: rgb("#3271a8"), font: "IBM Plex Sans")
  if args.named().keys().contains("style") {
    style = args.named().at("style")
  }

  show: default-page-settings.with(style, title: title, description: description)

  title-slide(style: style, title: title, title-color: title-color, ..args)

  body
}

