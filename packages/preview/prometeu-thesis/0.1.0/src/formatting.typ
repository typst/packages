#let chapter-count = counter("chapter counter")

#let part() = it => {
  set align(center + horizon)
  set text(25pt)
  pagebreak(weak: true)

  grid(
    row-gutter: 1em,
    [Part #context counter(heading).display()],
    it.body,
  )

  v(4em) // Move the part title up
}

#let chapter(top: none) = it => {
  chapter-count.step()
  pagebreak(weak: true)
  block(inset: (top: 30mm, bottom: 15mm), {
    if top != none {
      block(text(15pt, top), below: 7mm)
    }
    block(text(18pt, it.body))
  })
}

#let chapter-with-top() = chapter(top: [Chapter #context chapter-count.display()])

#let section() = it => {
  set text(16pt)
  set block(above: 2.5em, below: 1.5em)
  it
}

#let format-heading(..nums) = {
  if nums.pos().len() == 1 {
    numbering("I", ..nums) // Part
  } else if nums.pos().len() == 2 {
    numbering("1", chapter-count.get().first()) // Chapter
  } else {
    numbering("1.1", ..chapter-count.get(), ..nums.pos().slice(2)) // Section
  }
}

#let show-main-content = it => {
  // = Part
  // == Chapter
  // === Section
  show heading.where(level: 1): part()
  show heading.where(level: 2): chapter-with-top()
  show heading.where(level: 3): section()

  // Use chapter-count to number chapters and sections
  set heading(numbering: format-heading)

  it
}

#let show-appendix(content) = {
  chapter-count.update(0)
  show heading.where(level: 2): set heading(numbering: (..) => chapter-count.display("A"))
  show heading.where(level: 2): chapter(top: [Appendix #context chapter-count.display("A")])
  content
}

#let show-preamble(content) = {
  set page(numbering: "i")
  counter(page).update(1)

  // Set level 1 heading to be chapters and level 2 headings to be sections (needed because of Part support)
  show heading.where(level: 1): chapter()
  show heading.where(level: 2): section()

  // Preamble should not be included in the outline
  set heading(outlined: false)

  content

  chapter-count.update(0)
  counter(page).update(1)
}

#let show-postamble(content) = {
  show heading.where(level: 1): chapter()
  set heading(numbering: none)

  content
}
