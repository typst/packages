// Paragraph
#let para(nom, content) = context {
  grid(
    columns: 2,
    column-gutter: 3pt,
    align: left + top,
    [_#nom _ : ], content + h(100%),
  )
}

#let rq(content) = {
  para("Remarque", content)
}

#let ex(content) = {
  para("Exemple", content)
}


// List
#let arrow-list(..item) = {
  grid(
    columns: (auto, 1fr),
    align: left,
    column-gutter: 4pt,
    row-gutter: 10pt,
    ..for i in item.pos() {
      ([$-->$], i)
    }
  )
}


// Inbox
#let inbox(content) = context {
  box(
    width: 100%,
    stroke: text.fill.lighten(40%) + 0.6pt,
    fill: text.fill.lighten(90%),
    inset: 15pt,
    radius: 5pt,

    content,
  )
}

#let inbox2(content) = context {
  block(width: 100%, fill: text.fill.lighten(90%), stroke: (left: 3pt + text.fill.lighten(50%), rest: 0pt), inset: (left: 10pt, right: 10pt, rest:6pt), content)
}


#let inbox3(content) = context {
  import calc: *
  let c = block(inset: (left: 10pt, right: 10pt), content)
  

  layout(size => {
    let inbox-height = max(25pt, min(size.width * 0.15, pow(1.5, measure(c).width / size.width) * 4pt))


    box([#{
        place(line(length: inbox-height, angle: 90deg))

        align(left, line(length: inbox-height * 2))

        c

        place(line(start: (100%, 0%), length: inbox-height, angle: -90deg))
        line(start: (100% - inbox-height * 2, 0%), length: inbox-height * 2)
      }])
  })
}

#let inbox4(content) = context {
  block(stroke: (left: 1pt + text.fill, rest: 0pt), inset: (top: 2pt, bottom: 2pt,left: 10pt,), content)
}
