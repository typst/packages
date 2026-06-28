#let solution(display, content) = block(
  if display {
    set text(fill: blue)
    set rect(stroke: blue)
    set ellipse(stroke: blue)
    set line(stroke: blue)
    set circle(stroke: blue)
    set table(stroke: blue)
    set table.cell(stroke: blue)
    content
  } else {
    hide(content)
  }
)

#let blank(display, width, content) = box(
  width: width,
  outset: (bottom: 2pt),
  stroke: (bottom: 0.5pt + black),
  align(center, solution(display, content)),
)

#let choice = sym.circle.stroked.big
#let invalid-choice = sym.times.big
#let placeholder-choice = sym.bullet
#let correct-choice(display) = if display {
  text(fill: blue, sym.circle.filled.big)
} else {
  choice
}

#let option = sym.square.stroked.big
#let invalid-option = sym.times.big
#let placeholder-option = sym.bullet
#let correct-option(display) = if display {
  text(fill: blue, sym.square.filled.big)
} else {
  option
}

#let space(scale) = block(v(3em * scale))
#let sentences(display, num, content) = context {
  let tag = text(size: 0.8em, [*#num* sent])
  place(
    right,
    dx: 1em + measure(tag).width,
    dy: -1.75em,
    box(outset: 3pt, stroke: (0.5pt + black), tag)
  )
  solution(display, content)
  space(num)
}

#let quest(
  title,
  author,
  identity: (name: none, id: none),
  paper: "us-letter",
  font: ("Fira Sans", "Lete Sans Math"),
  font-math: "Fira Math",
  font-mono: "Fira Mono",
  lang: "en",
  region: "US",
  dedent: 1.25em,
  spacing: 6em,
  body,
) = {

  set document(
    title: title,
    author: author,
  )

  set page(
    paper: paper,
    header: context if calc.odd(counter(page).get().first()) {
      grid(
        columns: (1fr,) + (auto,) * 2,
        gutter: 1em,
        text(weight: "bold", title),
        "Name: " + blank(true, 15em, identity.name),
        if "id" in identity { "ID: " + blank(true, 10em, identity.id) }
        else if "email" in identity { "Email: " + blank(true, 10em, identity.email) },
      )
    },
  )

  set enum(indent: -dedent, spacing: spacing)

  set par(
    justify: true,
    justification-limits: (tracking: (min: -0.015em, max: 0.015em)),
  )

  set text(
    font: font,
    lang: lang,
    region: region,
  )

  show math.equation: set text(font: font-math)
  show raw: set text(font: font-mono, size: 1.25em)
  show raw.where(lang: "bold"): it => {
    show regex("\*(.*?)\*"): re => {
      eval(re.text, mode: "markup")
    }
    it
  }

  body
}
