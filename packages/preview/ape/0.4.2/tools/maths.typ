#let cpt = counter("maths")

#let breakable-or-not(min-size: 120pt, content) = context {
  layout(size => {
    let body = block(width: size.width, content)
    let (height,) = measure(
      body,
    )

    if (height < min-size) {
      block(width: size.width, breakable: false, content)
    } else {
      body
    }
  })
}


#let enclose(content) = context {
  block(
    width: 100%,
    stroke: text.fill.lighten(0%) + 0.5pt,
    inset: 10pt,
    radius: 3pt,
    content,
  )
}

#let maths-block-no-stroke(type, title, content) = context {
  cpt.step()
  let n = cpt.get().at(0) + 1

  if (title == []) {
    breakable-or-not[
      *#type #n ---* #content
    ]
  } else {
    breakable-or-not[
      *#type #n --- #title*

      #content
    ]
  }
}

#let maths-block(type, title, content) = context {
  cpt.step()
  let n = cpt.get().at(0) + 1

  if (title == []) {
    breakable-or-not(enclose[
     #block(sticky: true)[*#type #n*]

      #content
    ])
  } else {
    breakable-or-not(enclose[
      #block(sticky: true)[*#type #n --- #title*]

      #content
    ])
  }
}

// French Shortcuts....
#let def(title, content) = context maths-block("Définition", title, content)
#let prop(title, content) = context maths-block("Proposition", title, content)
#let remarque(title, content) = context maths-block-no-stroke("Remarque", title, content)
#let theorem(title, content) = context maths-block("Théorème", title, content)
#let corollaire(title, content) = context maths-block("Corollaire", title, content)
#let lemme(title, content) = context maths-block("Lemme", title, content)
#let exemple(title, content) = context maths-block-no-stroke("Exemple", title, content)
#let rappel(title, content) = context maths-block-no-stroke("Rappel", title, content)

#let demo(content) = context {
  breakable-or-not(min-size: 60pt)[
    #block(sticky: true)[*Démonstration*]
    #block(
      width: 100%,
      stroke: (left: (paint: text.fill, thickness: 0.5pt), rest: 0pt),
      inset: (top: 2pt, bottom: 2pt, left: 10pt),
      content,
    )
  ]
}
