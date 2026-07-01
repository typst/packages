#import "@preview/showybox:2.0.2": showybox

#let Q(color: blue) = {
    align(right)[
        #text(fill: color.lighten(70%), size: 15pt)[$qed$]
    ]
}

#let r() = {
  [#text()[$(==>)$ #h(.25cm)]]
}

#let l() = {
  [#text()[$(<==)$ #h(.25cm)]]
}

#let ii(f) = $integral_(-infinity)^(infinity) #f$

#let B(content) = rect(stroke: 1pt, inset: 10pt, content)

#let b() = {
    [#emph(text()[Proof.])]
}

#let q(title: "", color: blue, ..body) = {
  showybox(
    frame: (
      border-color: color.darken(30%),
      title-color: color.lighten(80%),
      body-color: color.lighten(95%),
      radius: 7pt
    ),
    title-style: (
      color: black,
      weight: "semibold",
      boxed-style: (
        anchor: (
            x: left,
            y: horizon
        ),
        radius: 3pt,
      )
    ),
    spacing: (
      15pt
    ),
    title: title,
    ..body
  )
}



#let homework(
  class: "math 416h",
  author: "John Doe",
  assignment: "ILY143",
  logo: none,
  instructor: "Prof. Smith",
  semester: "Summer 1970",
  due-time: "Feb 29, 23:59",
  accent-color: rgb("#000000"),
  paper-size: "A4",
  body,
) = {

  let maybe-logo = if logo != none {
    [#box(logo, height: 46pt)]
  } else {
    []
  }
  set document(title: class + assignment, author: author)
  show math.equation: set block(breakable: true)

  set page(paper: paper-size,
  header: context {
    if counter(page).get().first() > 1 {
      [
        #author #h(1fr) #assignment
      ]
    }
  },
  footer: context {
    [
      #align(center)[
        Page #counter(page).display()
        of #counter(page).final().first()
      ]
    ]
  },
  )

  align(top)[

    #v(-.5cm)
      #box(smallcaps(strong(text(size: 28pt, fill: accent-color)[#class])), height: 40pt) 
      #h(1fr) #maybe-logo
      #align(left)[
      #v(-.7cm)
      ] 

    #text(size: 16pt)[#assignment] #h(1fr) #text(size: 16pt)[#due-time]

    #text(size: 16pt)[#author] #h(1fr) #text(size: 16pt)[#instructor]

    #v(-.2cm)

    #h(1fr) #line(start:(40%, 0%), length: 62.5%, stroke: 1pt)

    #v(.5cm)
]
  body
}