#let default-color = blue.darken(40%)

#let layouts = (
  "small": ("height": 9cm, "space": 1.4cm),
  "medium": ("height": 10.5cm, "space": 1.6cm),
  "large": ("height": 12cm, "space": 1.8cm),
)
#let layout-space = state("space", v(-0.8cm))

#let title-slide(content) = {
    set page(footer: none)
    set align(horizon)
    context layout-space.get()
    content
    pagebreak(weak: true)
}

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
  layout-space.update(v(- space / 2))

  // Colors
  if title-color == none {
    title-color = default-color
  }

  // Setup
  if title != none {
    set document(title: title, author: authors)
  }
  set page(
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space, bottom: 0.6 * space),
    header: context{
      let page = here().page()
      let headings = query(selector(heading.where(level: 2)))
      let heading = headings.rev().find(x => x.location().page() <= page)
      if heading != none {
        set align(top)
        set text(1.4em, weight: "bold", fill: title-color)
        v(space / 2)
        block(heading.body + if not heading.location().page() == page [
          #{ numbering("(i)", page - heading.location().page() + 1) }
        ])
      }
    },
    header-ascent: 0%,
    footer: [
      #set text(0.8em)
      #set align(right)
      #context counter(page).display("1/1", both: true)
    ],
    footer-descent: 0.8em,
  )
  set outline(target: heading.where(level: 1), title: none)
  set bibliography(title: none)

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
  if title != none {
    if (type(authors) != array) {
      authors = (authors,)
    }
    title-slide[
      #text(2.0em, weight: "bold", fill: title-color, title)
      #v(1.4em, weak: true)
      #if subtitle != none { text(1.1em, weight: "bold", subtitle) }
      #if subtitle != none and date != none { text(1.1em)[ \- ] }
      #if date != none { text(1.1em, date) }
      #v(1em, weak: true)
      #if subtitle != none or date != none {
        place(bottom, authors.join(", ", last: " and "))
      } else {
        align(left, authors.join(", ", last: " and "))
      }
    ]
  }

  // Content
  content
}

#let frame(content, counter: none, title: none, fill-body: none, fill-header: none, radius: 0.2em) = {
  let header = none

  if fill-header == none and fill-body == none {
    fill-header = default-color.lighten(75%)
    fill-body = default-color.lighten(85%)
  }
  else if fill-header == none {
    fill-header = fill-body.darken(10%)
  }
  else if fill-body == none {
    fill-body = fill-header.lighten(50%)
  }

  if radius == none {
    radius = 0pt
  }

  if counter == none and title != none {
    header = [*#title.*]
  } else if counter != none and title == none {
    header = [*#counter.*]
  } else {
    header = [*#counter:* #title.]
  }

  show stack: set block(breakable: false, above: 0.8em, below: 0.5em)

  stack(
    block(
      width: 100%,
      inset: (x: 0.4em, top: 0.35em, bottom: 0.45em),
      fill: fill-header,
      radius: (top: radius, bottom: 0cm),
      header,
    ),
    block(
      width: 100%,
      inset: (x: 0.4em, top: 0.35em, bottom: 0.45em),
      fill: fill-body,
      radius: (top: 0cm, bottom: radius),
      content,
    ),
  )
}

#let d = counter("definition")
#let definition(content, title: none, ..options) = {
  d.step()
  frame(
    counter: context d.display(x => "Definition " + str(x)),
    title: title,
    content,
    ..options,
  )
}

#let t = counter("theorem")
#let theorem(content, title: none, ..options) = {
  t.step()
  frame(
    counter: context t.display(x => "Theorem " + str(x)),
    title: title,
    content,
    ..options,
  )
}

#let l = counter("lemma")
#let lemma(content, title: none, ..options) = {
  l.step()
  frame(
    counter: context l.display(x => "Lemma " + str(x)),
    title: title,
    content,
    ..options,
  )
}

#let c = counter("corollary")
#let corollary(content, title: none, ..options) = {
  c.step()
  frame(
    counter: context c.display(x => "Corollary " + str(x)),
    title: title,
    content,
    ..options,
  )
}

#let a = counter("algorithm")
#let algorithm(content, title: none, ..options) = {
  a.step()
  frame(
    counter: context a.display(x => "Algorithm " + str(x)),
    title: title,
    content,
    ..options,
  )
}
