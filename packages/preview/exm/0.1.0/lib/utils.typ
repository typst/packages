#let section-counter = counter("sectioncounter")
#let section-points = state("sectionpoints", ())

#let add-points = p => {
  let section = section-counter.get().at(0) - 1

  section-points.update(it => {
    for i in range(it.len(), section + 1) {
      it.push(0)
    }

    it.at(section) += p

    return it
  })
}


// q/a
#let colorblue = rgb("#2A40E2")

#let colorcyan = rgb("6993BF")
#let colorred = rgb("DD4466")
#let colorgreen = rgb("59B279")
#let colorgrey = rgb("808C80")

#let colorlightcyan = rgb("E8EDF4")
#let colorlightred = rgb("F4E8EC")
#let colorlightgreen = rgb("E8F4EC")
#let colorlightgrey = rgb("F6F6F6")


// print, screen, sol
// print will disable syntax highlighting for code blocks
#let docmode = state("mode", "sol")

// utils
#let hstack(..items) = {
  stack(dir: ltr, spacing: 0.75cm, ..items)
}

#let boxed(color: colorblue, body) = {
  align(center, rect(stroke: stroke(thickness:0.5pt,paint:color))[#body])
}

#let callout(t, body) = {
  let color = if t == "Definition" {
    colorcyan
  } else if t == "Formula" {
    colorred
  } else if t == "Method" {
    colorgreen
  } else if t == "Example" {
    colorgrey
  } else {
    rgb("000")
  }

  let bgcolor = if t == "Definition" {
    colorlightcyan
  } else if t == "Formula" {
    colorlightred
  } else if t == "Method" {
    colorlightgreen
  } else if t == "Example" {
    colorlightgrey
  } else {
    rgb("ebebeb")
  }

  block(
    fill: bgcolor,
    stroke: (left: stroke(thickness: 2.5pt, paint: color)),
    inset: (left: 10pt, right: 8pt, top: 8pt, bottom: 8pt),
    outset: (left: -2.5pt),
    radius: 0pt,
    width: 100%,
  )[
    #if t != "" [
      #text(t, fill: color, weight: 600)
      #v(-6pt)
    ]

    #body
  ]
}

#let info(body) = callout("", body)

#let subtitle(t) = [
  #v(6pt)
  #set text(size: 11.5pt, weight: 600)
  #show raw: set text(size: 9.5pt, weight: 600)

  #t
  #v(-6pt)
] 


#let pp = subtitle("Practice Problems")

#let section(title, height: auto, number: true, points: false, content) = {
  block(height: height)[
    #if number == true [
    #section-counter.step()
    #context {
    let pts = section-points.final().at(section-counter.get().at(0) - 1, default: 0)

    let pstr = if pts == 1 { "point" } else { "points" }
    add-points(0.0)
    if points {
      text(section-counter.display("1. ") + "[" + repr(pts) + " " + pstr + "]  " + title, size: 14.5pt, weight: 500, tracking: -0.01em)
    } else {
      text(section-counter.display("1. ") + title, size: 14.5pt, weight: 500, tracking: -0.01em)
    }
  }

  ] else [
    #text(title, size: 14.5pt, weight: 500, tracking: -0.01em)
  ]

    #v(-6pt)
    #content
  ]
}

#let ans(answer) = {
  context[
    #if docmode.get() == "sol" [
      #text(fill: colorblue)[#answer]
    ]
  ]
}


#let _getheight(height, ansheight, ansbox) = {
  // NOTE: must have context when run
  let h = if docmode.get() == "sol" { 
    if ansheight == -1 {
      if ansbox { 
        if height == auto { auto }
        else { height - 12pt }
      } else {
        auto
      }
    } else { 
      if ansheight == auto { auto }
      else { ansheight - 12pt }
    }
  } else {
    if height == auto { auto }
    else { height - 12pt }
  }

  return h
}

#let _getptstr(points) = {
  return if points == 1 { "pt" } else { "pts" }
}

#let question(question, answer, 
  ansbox: false,
  height: auto, ansheight: -1,
  ansalign: horizon,
  points: "") = {
  let pstr = _getptstr(points)

  context {
    let h = _getheight(height, ansheight, ansbox)

    block(width: 100%)[
      #if points != "" [
      #context add-points(points);
      #text("[" + repr(points) + " " + pstr + "] ", weight: 500) #text(question)
    ] else [
      #question
    ]
      #v(-2pt)

      #if ansbox == true {
      box(width: 100%, stroke: stroke(thickness: 0.5pt, paint: if docmode.get() == "sol" { colorblue } else { black }), height: h, inset: (top:8.5pt, bottom:8.5pt, left: 7.5pt, right: 7.5pt))[
        #align(ansalign)[
          #ans(answer)
        ]
      ]
    } else {
      box(width: 100%, stroke: none, height: h)[
        #align(ansalign)[
          #ans(answer)
        ]
      ]
    }

      #if not ansbox { v(8pt) }
    ]
  }
}

#let mcq(question, choices, answer, 
  cols: 1,
  multi: false,
  ansbox: false,
  height: auto, ansheight: auto,
  ansalign: horizon,
  color: colorblue,
  explanation: "",
  points: "",) = {

  let length = choices.len()
  let pstr = _getptstr(points)

  let ansarr = { if type(answer) == int { (answer,) } else { answer } }

  context {
    let h = _getheight(height, ansheight, ansbox)

    let items = range(length).map(i => [
      #let fill = if docmode.get() == "sol" and ansarr.contains(i) { color } else { white }
      #let strokecolor = if docmode.get() == "sol" and ansarr.contains(i) { color } else { black }

      #box(height: 7.5pt, width: 12pt,
        align(horizon)[
          #align(left)[
            #if multi == false or multi == true {
            if multi {
            square(size: 8.75pt, stroke: stroke(thickness: 0.5pt, paint: strokecolor), fill: fill)
          } else {
            circle(radius: 4.75pt, stroke: stroke(thickness: 0.5pt, paint: strokecolor), fill: fill)
          }
          } else {
            if multi.at(i) {
            square(size: 8.75pt, stroke: stroke(thickness: 0.5pt, paint: strokecolor), fill: fill)
          } else {
            circle(radius: 4.75pt, stroke: stroke(thickness: 0.5pt, paint: strokecolor), fill: fill)
          }
          }]
        ]
      )
    ])

    set enum(numbering: (..nums, last) => [#items.at(last - 1)])

    let _cols = { if type(cols) == array { cols } else { range(cols).map(_ => 1fr) } }

    block(width: 100%)[
      #if points != "" [
      #context add-points(points);
      #text("[" + repr(points) + " " + pstr + "] ", weight: 500) #text(question)
    ] else [
      #question
    ]

    #v(-2pt)
    #grid(
      columns: _cols,
      row-gutter: 10pt,

      ..choices.enumerate().map(((i, c)) =>
        enum.item(i + 1)[#c]
      )
    )
  ]

  if ansbox == true {
  box(width: 100%, stroke: stroke(thickness: 0.5pt, paint: if docmode.get() == "sol" { colorblue } else { black }), height: h, inset: 7pt)[
    #align(ansalign)[
      #ans(explanation)
    ]
  ]
} else if explanation != "" {
  box(width: 100%, stroke: none, height: h)[
    #align(ansalign)[
      #ans(explanation)
    ]
  ]
}

  v(8pt)
}
}

#let ansbank(cols: 3, choices: ("",)) = [
  #box([
    #set enum(
      numbering: (..nums, last) => [
      #text(weight: "bold", numbering("A", last))
      #h(4pt)
    ]
    )

    #grid(columns: range(cols).map(_ => 1fr),
      row-gutter: 8pt, 

      ..choices.enumerate().map(((i, c)) =>
        enum.item(i + 1)[#c]
      )
    )], stroke: stroke(thickness: 0.5pt), inset: 6pt)
]

#let blank(width, placeholder, answer: none) = [
  #context[
    #box(width: width, stroke: (bottom: 0.5pt), outset: (y: 2pt, x: 1.5pt))[
      #align(center)[
        #text(
          baseline: -1.5pt,
          raw(if docmode.get() == "sol" and answer != none { answer } else { placeholder }))
      ]
    ]
  ]
]


#let nextpage(text: [See next page]) = {
  box(width: 100%)[
    #align(right)[#stack(dir: ltr, spacing: 5pt, smallcaps(text), [$arrow.r.long$])]
  ]
}

#let blankpage(text: [
  This page intentionally left blank

  The exam begins on the next page.
]) = {
  box(width: 100%, height: 95%)[
    #align(horizon)[#align(center)[
      #text
    ]]
  ]
}

#let bubble(content, color) = [
  #box(content, fill: color.mix(white).transparentize(65%), radius: 3pt, inset: 2.5pt, stroke: stroke(paint: color, thickness: 0.5pt), baseline: 2.5pt)
]

