#import "../maths.typ" : *
#let maths-num-state = state("maths-num")


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
  if (title == []) {
    breakable-or-not[
      *#type #get-maths-count(type) ---* #content
    ]
  } else {
    breakable-or-not[
      *#type #get-maths-count(type) --- #title*

      #content
    ]
  }
}

#let maths-block-line(title, content) = context {
  breakable-or-not(min-size: 60pt)[
    #block(sticky: true)[*#title*]
    #block(
      width: 100%,
      stroke: (left: (paint: text.fill, thickness: 0.5pt), rest: 0pt),
      inset: (top: 2pt, bottom: 2pt, left: 10pt),
      content,
    )
  ]
}

#let maths-block(type, title, content) = context {
  if (title == []) {
    breakable-or-not(enclose[
      #block(sticky: true)[*#type #get-maths-count(type)*]

      #content
    ])
  } else {
    breakable-or-not(enclose[
      #block(sticky: true)[*#type #get-maths-count(type) --- #title*]

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
#let exercice(title, content) = context maths-block("Exercice", title, content)
#let correction(content) = context maths-block-line("Correction", content)
#let demo(content) = context maths-block-line("Démonstration", content)
