#import "../utils.typ": heading-numbering

#let is-heading-in-appendix(heading) = state("appendixes", false).at(
  heading.location(),
)

#let get-element-numbering(current-heading-numbering, element-numbering) = {
  if (current-heading-numbering.first() <= 0 or element-numbering <= 0) {
    return
  }
  let current-numbering = heading-numbering(current-heading-numbering.first())
  (current-numbering, numbering("1.1", element-numbering)).join(".")
}

#let appendix-heading(status, level: 1, body) = {
  heading(level: level)[(#status)\ #body]
}

#let appendixes(content) = {
  set heading(numbering: heading-numbering, hanging-indent: 0pt)

  show heading: set align(center)
  show heading: it => {
    assert(
      it.numbering != none,
      message: "В приложениях не может быть структурных заголовков или заголовков без нумерации",
    )
    counter("appendix").step()
    block[#upper([приложение]) #numbering(it.numbering, ..counter(heading).at(
        it.location(),
      )) \ #text(weight: "medium")[#it.body]]
  }

  show heading.where(level: 1): it => context {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)

    if query(<modern-g7-32-parameters>).first().value.add-pagebreaks {
      pagebreak(weak: true)
    }
    it
  }

  set figure(numbering: it => {
    let current-heading = counter(heading).get()
    get-element-numbering(current-heading, it)
  })

  set math.equation(numbering: it => {
    let current-heading = counter(heading).get()
    [(#get-element-numbering(current-heading, it))]
  })

  state("appendixes").update(true)
  counter(heading).update(0)
  content
}
