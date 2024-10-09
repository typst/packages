#let primary_colour = rgb("#3730a3")
#let link_colour = rgb("#12348e")

#let icon(name, shift: 1.5pt) = {
  box(
    baseline: shift,
    height: 10pt,
    image("icons/" + name + ".svg")
  )
  h(3pt)
}

#let findMe(services) = {
  set text(8pt)
  let icon = icon.with(shift: 2.5pt)

  services.map(service => {
      icon(service.name)

      if "display" in service.keys() {
        link(service.link)[#{service.display}]
      } else {
        link(service.link)
      }
    }).join(h(10pt))
  [
    
  ]
}

#let term(period, location) = {
  text(9pt)[#icon("calendar") #period #h(1fr) #icon("location") #location]
}

#let max_rating = 5
#let skill(name, rating) = {
  let done = false
  let i = 1

  name

  h(1fr)

  while (not done){
    let colour = rgb("#c0c0c0")
    let strokeColor = rgb("#c0c0c0")
    let radiusValue = (left: 0em, right: 0em)

    if (i <= rating){
      colour = primary_colour
      strokeColor = primary_colour
    }

    // Add rounded corners for the first and last boxes
    if (i == 1) {
      radiusValue = (left: 2em, right: 0em)  
    } else if (i == max_rating) {
      radiusValue = (left: 0em, right: 2em) 
    }

    box(rect(
      height: 0.3em, 
      width: 1.5em, 
      stroke: strokeColor,
      fill: colour,
      radius: radiusValue
    ))

    if (max_rating == i){
      done = true
    }

    i += 1
  }

  [\ ]
}


#let styled-link(dest, content) = emph(text(
    fill: link_colour,
    link(dest, content)
  ))

#let vantage(
  name: "",
  position: "",
  links: (),
  tagline: [],
  leftSide,
  rightSide
) = {
  set document(
    title: name + "'s CV",
    author: name,
  )
  set text(9.8pt, font: "PT Sans")
  set page(
    margin: (x: 1.2cm, y: 1.2cm),
  )

  show heading.where(level: 1) : it => text(16pt,[#{it.body} #v(1pt)])

  show heading.where(
    level: 2,
  ): it => text(
      fill: primary_colour,
    [
      #{it.body}
      #v(-7pt)
      #line(length: 100%, stroke: 0.5pt + primary_colour)
    ]
  )

  show heading.where(
    level: 3
  ): it => text(it.body)
  
  show heading.where(
    level: 4
  ): it => text(
    fill: primary_colour,
    it.body
  )

  [= #name]
  text(12pt, weight: "medium",[#position])

  v(0pt)
  findMe(links)

  tagline

  grid(
    columns: (7fr, 4fr),
    column-gutter: 2em,
    leftSide,
    rightSide,
  )
}
