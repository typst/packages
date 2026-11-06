#let default-color = blue.darken(40%)
#let header-color = default-color.lighten(75%)
#let body-color = default-color.lighten(85%)

#let layouts = (
  "small": ("height": 9cm, "space": 1.4cm),
  "medium": ("height": 10.5cm, "space": 1.6cm),
  "large": ("height": 12cm, "space": 1.8cm),
)

#let slides(
  content,
  title: none,
  subtitle: none,
  date: none,
  authors: (),
  layout: "medium",
  ratio: 4/3,
  title-color: none,
) = {

  // Parsing
  if layout not in layouts {
      panic("Unknown layout " + layout)
  }
  let (height, space) = layouts.at(layout)
  let width = ratio * height

  // Colors
  if title-color == none {
      title-color = default-color
  }

  // Setup
  set document(
    title: title,
    author: authors,
  )
  set page(
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space, bottom: 0.6 * space),
    header: context {
      let page = here().page()
      let headings = query(selector(heading.where(level: 2)))
      let heading = headings.rev().find(x => x.location().page() <= page)
      if heading != none {
        set align(top)
        set text(1.4em, weight: "bold", fill: title-color)
        v(space / 2)
        block(heading.body +
          if not heading.location().page() == page [
            #{numbering("(i)", page - heading.location().page() + 1)}
          ]
        )
      }
    },
    header-ascent: 0%,
    footer: [
      #set text(0.8em)
      #set align(right)
      #counter(page).display("1/1", both: true)
    ],
    footer-descent: 0.8em,
  )
  set outline(
    target: heading.where(level: 1),
    title: none,
  )
  set bibliography(
    title: none
  )

  // Rules
  show heading.where(level: 1): x => {
    set page(header: none, footer: none)
    set align(center + horizon)
    set text(1.2em, weight: "bold", fill: title-color)
    v(- space / 2)
    x.body
  }
  show heading.where(level: 2): pagebreak(weak: true)
  show heading: set text(1.1em, fill: title-color)

  // Title
  if (title == none) {
    panic("A title is required")
  }
  else {
    if (type(authors) != array) {
      authors = (authors,)
    }
    set page(footer: none)
    set align(horizon)
    v(- space / 2)
    block(
      text(2.0em, weight: "bold", fill: title-color, title) +
      v(1.4em, weak: true) +
      if subtitle != none { text(1.1em, weight: "bold", subtitle) } +
      if subtitle != none and date != none { text(1.1em)[ \- ] } +
      if date != none {text(1.1em, date)} +
      v(1em, weak: true) +
      align(left, authors.join(", ", last: " and "))
    )
  }

  // Content
  content
}

#let frame(content, counter: none, title: none) = {

  let header = none
  if counter == none and title != none {
    header = [*#title.*]
  }
  else if counter != none and title == none {
    header = [*#counter.*]
  }
  else {
    header = [*#counter:* #title.]
  }

  set block(width: 100%, inset: (x: 0.4em, top: 0.35em, bottom: 0.45em))
  show stack: set block(breakable: false)
  show stack: set block(breakable: false, above: 0.8em, below: 0.5em)

  stack(
    block(fill: header-color, radius: (top: 0.2em, bottom: 0cm), header),
    block(fill: body-color, radius: (top: 0cm, bottom: 0.2em), content),
  )
}

#let d = counter("definition")
#let definition(content, title: none) = {
  d.step()
  frame(counter: d.display(x => "Definition " + str(x)), title: title, content)
}

#let t = counter("theorem")
#let theorem(content, title: none) = {
  t.step()
  frame(counter: t.display(x => "Theorem " + str(x)), title: title, content)
}

#let l = counter("lemma")
#let lemma(content, title: none) = {
  l.step()
  frame(counter: l.display(x => "Lemma " + str(x)), title: title, content)
}

#let c = counter("corollary")
#let corollary(content, title: none) = {
  c.step()
  frame(counter: c.display(x => "Corollary " + str(x)), title: title, content)
}

#let a = counter("algorithm")
#let algorithm(content, title: none) = {
  a.step()
  frame(counter: a.display(x => "Algorithm " + str(x)), title: title, content)
}
