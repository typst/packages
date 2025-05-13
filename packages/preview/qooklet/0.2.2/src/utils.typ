#import "deps.typ": *

#let align-odd-even(odd-left, odd-right) = {
  if calc.odd(here().page()) {
    align(right, [#odd-left #h(6fr) #odd-right])
  } else {
    align(left, [#odd-right #h(6fr) #odd-left])
  }
}

#let heading-img(body, img, book: false, label: none) = {
  body = heading(level: 1, no-style-heading + body)
  if label != none {
    body = [#body #label]
  }

  context {
    if type(page.margin) != dictionary {
      return x
    }
    {
      set page(header: none)
      if book {
        pagebreak(to: "odd")
      }
    }
    let img-h = 9cm

    place(
      top,
      dy: -page.margin.top,
      dx: -book-margin(book, _ => page.margin.left, _ => page.margin.inside, _ => page.margin.outside),
      block(
        width: page.width,
        {
          image(
            img,
            width: 100%,
            height: img-h,
            fit: "cover",
          )
          place(
            bottom,
            {
              block(
                fill: luma(81.57%, 91.4%).transparentize(10%),
                stroke: 0pt,
                height: 1.5cm,
                inset: (
                  left: book-margin(book, _ => page.margin.left, _ => page.margin.inside, _ => page.margin.inside),
                ),
                width: 100%,
                align(
                  left + horizon,
                  text(14pt, body),
                ),
              )
            },
          )
        },
      ),
    )

    v(img-h - 0.7cm)
    context chapter-outline()
  }
}

#let figure-bold-caption(fig-cap, loc) = context {
  strong({
    fig-cap.supplement
    " "
    numbering(fig-cap.numbering, ..fig-cap.counter.at(loc))
    fig-cap.separator
  })
  fig-cap.body
}

// table: three-line
#let table-three-line(stroke-color) = (
  (x, y) => (
    top: if y < 2 {
      stroke-color
    } else {
      0pt
    },
    bottom: stroke-color,
  )
)

// table: grid without left border and right border
#let table-no-left-right(stroke-color) = (
  (x, y) => (
    left: if x > 2 {
      stroke-color
    } else {
      0pt
    },
    top: stroke-color,
    bottom: stroke-color,
  )
)

#let tableq(data, k, inset: 0.3em) = table(
  columns: k,
  inset: inset,
  align: center + horizon,
  stroke: table-three-line(rgb("000")),
  ..data.flatten(),
)

// text
#let ctext(body) = text(body, font: config-fonts.family.at("zh").math)

// codes: reading
#let code(text, lang: "python", breakable: true, width: 100%) = block(
  fill: rgb("#F3F3F3"),
  stroke: rgb("#DBDBDB"),
  inset: (x: 1em, y: 1em),
  outset: -.3em,
  radius: 5pt,
  spacing: 1em,
  breakable: breakable,
  width: width,
  raw(
    text,
    lang: lang,
    align: left,
    block: true,
  ),
)

// theorems
#let definition = thmbox(
  "definition",
  text(linguify("definition")),
  base_level: 1,
  separator: [#h(0.5em)],
  padding: (top: 0em, bottom: 0em),
  fill: rgb("#FFFFFF"),
  // stroke: rgb("#000000"),
  inset: (left: 0em, right: 0.5em, top: 0.2em, bottom: 0.2em),
)

#let theorem = thmbox(
  "theorem",
  text(linguify("theorem")),
  base_level: 1,
  separator: [#h(0.5em)],
  padding: (top: 0em, bottom: 0.2em),
  fill: rgb("#E5EEFC"),
  // stroke: rgb("#000000")
)

#let law = thmbox(
  "law",
  text(linguify("law")),
  base_level: 1,
  separator: [#h(0.5em)],
  padding: (top: 0em, bottom: 0.2em),
  fill: rgb("#ddf3f4"),
  // stroke: rgb("#000000")
)

#let lemma = thmbox(
  "theorem",
  text(linguify("lemma")),
  separator: [#h(0.5em)],
  fill: rgb("#EFE6FF"),
  titlefmt: strong,
)

#let corollary = thmbox(
  "corollary",
  text(linguify("corollary")),
  // base: "theorem",
  separator: [#h(0.5em)],
  titlefmt: strong,
)

#let rule = thmbox(
  "",
  text(linguify("rule")),
  base_level: 1,
  separator: [#h(0.5em)],
  fill: rgb("#f8eed3"),
  titlefmt: strong,
)

#let algo = thmbox(
  "",
  text(linguify("algorithm")),
  base_level: 1,
  separator: [#h(0.5em)],
  padding: (top: 0em, bottom: 0.2em),
  fill: rgb("#FAF2FB"),
  titlefmt: strong,
)

#let tip(title: linguify("tip"), icon: emoji.bell, ..args) = clue(
  accent-color: rgb("#e5c525e9"),
  title: title,
  icon: icon,
  ..args,
)
