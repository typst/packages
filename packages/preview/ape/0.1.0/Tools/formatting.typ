== Paragraph
#let para(nom, contenu) = context {
  grid(
    columns: 2,
    column-gutter: 3pt,
    align: left + top,
    [_#nom _ : ], contenu + h(100%),
  )
}


#let rq(contenu) = {
  para("Remarque", contenu)
}

#let ex(contenu) = {
  para("Exemple", contenu)
}

== Inbox
#let inbox(contenu) = {
  box(
    width: 100%,
    stroke: gray.darken(30%) + 0.6pt,
    fill: gray.lighten(75%),
    inset: 15pt,
    radius: 5pt,

    contenu,
  )
}

#let inbox2(contenu) = context {
  import calc: *
  let c = block(inset: (left: 10pt, right: 10pt), contenu)


  layout(size => {
    let inbox-height = max(15pt, min(size.width * 0.15, pow(1.5, measure(c).width / size.width) * 4pt))


    box([#{
        place(line(length: inbox-height, angle: 90deg))

        align(left, line(length: inbox-height * 2))

        c

        place(line(start: (100%, 0%), length: inbox-height, angle: -90deg))
        line(start: (100% - inbox-height * 2, 0%), length: inbox-height * 2)
      }])
  })
}
