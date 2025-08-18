// axiomst: A clean, elegant template for academic problem sets and homework assignments
#import "@preview/showybox:2.0.4": showybox

#let problemCounter = counter("problem")
#let theoremCounter = counter("theorem")
#let definitionCounter = counter("definition")
#let lemmaCounter = counter("lemma")
#let corollaryCounter = counter("corollary")
#let exampleCounter = counter("example")
#let algorithmCounter = counter("algorithm")

#let columns(
  count: 2,
  gutter: 1em,
  separator: none,
  widths: none,
  ..children,
) = {
  let content = children.pos()

  let col-widths = ()
  if widths == none {
    let available-width = 100% - gutter * (count - 1)
    let column-width = available-width / count
    col-widths = (column-width,) * count
  } else {
    col-widths = widths
  }

  if separator == "line" {
    grid(
      columns: col-widths,
      column-gutter: gutter,
      ..content.enumerate().map(((i, c)) => {
        if i < content.len() - 1 {
          (c, line(angle: 90deg, length: 100%, stroke: (thickness: 0.5pt, dash: "solid")))
        } else {
          c
        }
      }).flatten()
    )
  } else if separator != none and type(separator) == "function" {
    grid(
      columns: col-widths,
      column-gutter: gutter,
      ..content.enumerate().map(((i, c)) => {
        if i < content.len() - 1 {
          (c, separator())
        } else {
          c
        }
      }).flatten()
    )
  } else {
    grid(
      columns: col-widths,
      column-gutter: gutter,
      ..content
    )
  }
}

#let theorem-base(
  counter,
  prefix,
  title: none,
  numbered: true,
  color: blue.darken(20%),
  fill: blue.lighten(95%),
  body
) = {
  let number = if numbered { counter.step(); context(counter.display()) }

  block(
    width: 100%,
    fill: fill,
    radius: 4pt,
    stroke: color.darken(10%),
    inset: 0.6em,
  )[
    #text(weight: "bold")[#prefix #if numbered {number}]
    #if title != none [#text(style: "italic")[#title].]
    #v(0.5em)
    #body
  ]
}

#let theorem(
  title: none,
  numbered: true,
  color: blue.darken(20%),
  ..body
) = {
  theorem-base(
    theoremCounter,
    "Theorem",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

#let lemma(
  title: none,
  numbered: true,
  color: green.darken(20%),
  ..body
) = {
  theorem-base(
    lemmaCounter,
    "Lemma",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

#let definition(
  title: none,
  numbered: true,
  color: purple.darken(20%),
  ..body
) = {
  theorem-base(
    definitionCounter,
    "Definition",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

#let corollary(
  title: none,
  numbered: true,
  color: orange.darken(20%),
  ..body
) = {
  theorem-base(
    corollaryCounter,
    "Corollary",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

#let example(
  title: none,
  numbered: true,
  color: aqua.darken(20%),
  ..body
) = {
  theorem-base(
    exampleCounter,
    "Example",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

#let proof(body, qed-symbol: "■") = {
  block(body)

  let symbol = if qed-symbol == "■" {
    text(fill: gray.darken(30%), size: 1.2em, weight: "bold")[■]
  } else if qed-symbol == "□" {
    text(fill: gray.darken(30%), size: 1.2em, weight: "bold")[□]
  } else if qed-symbol == "∎" {
    text(fill: gray.darken(30%), size: 1.2em)[∎]
  } else if qed-symbol == "Q.E.D." {
    text(fill: gray.darken(30%), style: "italic")[Q.E.D.]
  } else {
    text(fill: gray.darken(30%))[#qed-symbol]
  }

  align(right, symbol)
}

#let problem(
  title: "",
  color: blue.darken(20%),
  numbered: true,
  ..body
) = {
  if numbered {
    [== Problem #problemCounter.step() #context {problemCounter.display()}]
  }

  showybox(
    frame: (
      border-color: color.darken(10%),
      title-color: color.lighten(85%),
      body-color: color.lighten(95%)
    ),
    title-style: (
      color: black,
      weight: "bold",
    ),
    title: title,
    ..body
  )
}

#let homework(
  title: "Homework Assignment",
  author: "Student Name",
  course: "Course Code",
  email: "student@school.uni",
  date: datetime.today(),
  due-date: none,
  collaborators: [],
  margin-size: 2.5cm,
  body
) = {
  set document(title: title, author: author)

  set page(
    paper: "a4",
    margin: (top: margin-size, bottom: margin-size, left: margin-size, right: margin-size),

    header: context {
      if counter(page).get().first() > 1 [
        #set text(style: "italic")
        #course #h(1fr) #author
        #if collaborators != none and type(collaborators) == array and collaborators.len() > 0 {
          [w/ #collaborators.join(", ")]
        }
        #block(line(length: 100%, stroke: 0.5pt), above: 0.6em)
      ]
    },

    footer: [
      #align(center)[Page #context counter(page).display() of #context counter(page).final().first()]
    ],
  )

  show raw.where(block: true): it => {
    block(
      width: 100% - 0.5em,
      radius: 0.3em,
      stroke: luma(50%),
      inset: 1em,
      fill: luma(98%)
    )[
      #show raw.line: l => context {
        box(
          width: measure([#it.lines.last().count]).width,
          align(right, text(fill: luma(50%))[#l.number])
        )
        h(0.5em)
        l.body
      }
      #it
    ]
  }

  show ref: it => {
    let element = it.element
    let loc = it.location()

    if element == none {
      return it
    }

    if element.func() == heading and element.level == 2 {
      [Problem #it.number]
    } else if element.func() == theorem {
      [Theorem #it.number]
    } else if element.func() == lemma {
      [Lemma #it.number]
    } else if element.func() == definition {
      [Definition #it.number]
    } else if element.func() == corollary {
      [Corollary #it.number]
    } else if element.func() == example {
      [Example #it.number]
    } else {
      it
    }
  }

  align(
    center,
    {
      text(size: 1.6em, weight: "bold")[#course -- #title \ ]

      text(size: 1.2em, weight: "semibold")[#author \ ]

      raw(email); linebreak()

      emph[#date.display("[month repr:long] [day], [year]")]

      box(line(length: 100%, stroke: 1pt))
    },
  )

  set heading(
    numbering: (..nums) => {
      nums = nums.pos()
      if nums.len() == 1 {
        [Problem #nums.at(0):]
      }
      else if nums.len() > 2 {
        [Part (#numbering("a", nums.at(1))):]
      }
    },
  )

  body
}
