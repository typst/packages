// main project
#let bubble(
  title: "",
  subtitle: none,
  author: "",
  affiliation: none,
  year: none,
  class: none,
  other: none,
  date: datetime.today().display("[year] 年 [month padding:none] 月 [day padding:none] 日"),
  logo: image("assets/zju_logo_blue.svg"),
  main-color: "003F88",
  alpha: 0%,
  color-words: (),
  body,
) = {
  set document(author: author, title: title)

  // Save heading and body font families in variables.
  let body-font = "Source Han Sans SC"
  let title-font = ("Barlow", "Source Han Sans SC")
  let code-font = ("JetBrainsMonoNL NF", "LXGW WenKai Mono Screen")

  // Set colors
  let primary-color = rgb(main-color) // alpha = 100%
  // change alpha of primary color
  let secondary-color = color.mix(color.rgb(100%, 100%, 100%, alpha), primary-color, space: rgb)

  // highlight important words
  show regex(if color-words.len() == 0 { "$ " } else { color-words.join("|") }): text.with(fill: primary-color)

  // customize look of figure
  set figure.caption(separator: [ --- ])

  // customize inline raw code
  show raw.where(block: false): it => (
    h(0.5em) + box(fill: primary-color.lighten(90%), outset: 0.3em, radius: 0.3em, text(font: code-font, it)) + h(0.5em)
  )

  // customize code blocks (```)
  show raw.where(block: true): it => block(
    stroke: primary-color,
    inset: 1em,
    radius: 0.3em,
    width: 100%,
    fill: primary-color.lighten(95%),
    text(font: code-font, it),
  )

  // Set body font family.
  set text(font: body-font, 12pt)
  show heading: set text(font: title-font, fill: primary-color)

  // heading numbering
  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    // only level 1 and 2 are numbered
    let pattern = if level == 1 {
      "I."
    } else if level == 2 {
      "I.1."
    }
    if pattern != none {
      numbering(pattern, ..nums)
    }
  })

  // add space for heading
  show heading.where(level: 1): it => it + v(0.5em)

  // Set link style
  show link: it => underline(text(fill: primary-color, it))

  // numbered list colored
  set enum(indent: 1em, numbering: n => [#text(fill: primary-color, numbering("1.", n))])

  // unordered list colored
  set list(indent: 1em, marker: n => [#text(fill: primary-color, "•")])


  // display of outline entries
  show outline.entry: it => text(size: 12pt, weight: "regular", it)

  // Title page.
  // Logo at top right if given
  if logo != none {
    set image(width: 6cm)
    place(top + right, logo)
  }
  // decorations at top left
  place(top + left, dx: -35%, dy: -28%, circle(radius: 150pt, fill: primary-color))
  place(top + left, dx: -10%, circle(radius: 75pt, fill: secondary-color))

  // decorations at bottom right
  place(bottom + right, dx: 40%, dy: 30%, circle(radius: 150pt, fill: secondary-color))


  v(2fr)

  align(center, text(font: title-font, 3em, weight: 700, title))
  v(2em, weak: true)
  if subtitle != none {
    align(center, text(font: title-font, 2em, weight: 700, subtitle))
    v(2em, weak: true)
  }
  align(center, text(1.1em, date))

  v(2fr)

  // Author and other information.
  align(center)[
    #if author != "" {
      strong(author)
      linebreak()
    }
    #if affiliation != none {
      affiliation
      linebreak()
    }
    #if year != none {
      year
      linebreak()
    }
    #if class != none {
      emph(class)
      linebreak()
    }
    #if other != none {
      emph(other.join(linebreak()))
      linebreak()
    }
  ]

  pagebreak()


  // Table of contents.
  set page(
    numbering: "1 / 1",
    number-align: center,
  )


  // Main body.
  set page(
    header: [#emph()[#title #h(1fr) #author]],
  )
  set par(justify: true)

  body
}

// useful functions
// set block-quote
#let blockquote = rect.with(stroke: (left: 2.5pt + luma(170)), inset: (left: 1em))

// use primary-color and secondary-color in main
#let primary-color = rgb("003F88")
#let secondary-color = rgb(0, 63, 136, 60%)
