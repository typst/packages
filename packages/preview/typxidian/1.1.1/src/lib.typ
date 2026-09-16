#import "dependencies.typ": fa-icon, sentencecase, subpar

// text sizes
#let sizes = (
  chapter: 26pt,
  section: 18pt,
  subsection: 16pt,
  subsubsection: 14pt,
  subsubsubsection: 12pt,
  body: 11pt,
)

// obsidian color palette
#let colors = (
  purple: rgb("7e1dfb"),
  darkgray: rgb("6d6e6d"),
  cyan: rgb("53dfdd"),
  red: rgb("fb464c"),
  orange: rgb("e9973f"),
  green: rgb("44cf6e"),
  info: (
    title: rgb("306bf6"),
    bg: rgb("eaf0fb"),
  ),
  faq: (
    title: rgb("dd7c2e"),
    bg: rgb("fcf2ea"),
  ),
  tip: (
    title: rgb("56bcbb"),
    bg: rgb("eef8f8"),
  ),
  success: (
    title: rgb("54b651"),
    bg: rgb("eef8ec"),
  ),
  danger: (
    title: rgb("d64043"),
    bg: rgb("fbecee"),
  ),
)

// math equation block that can be used to display non-numbered equations
#let equation(content, number: false) = context {
  if number {
    content
  } else {
    set math.equation(numbering: none)
    content
  }
}

// creates blank pages that do not update the global page counter
#let blankpage(single: true) = context {
  set page(numbering: none, header: none)

  if single {
    pagebreak()
    pagebreak()
  } else {
    // this is reserved for separting chapters
    // we want at least one blank page between chapters
    // each chapter must start on an odd page
    // pagebreak()
    pagebreak(to: "odd")
  }
}


#let subfigure(prefix: auto, ..args) = {
  context {
    // if prefix is auto, we try to get the heading number.
    // if we are in the appendix, we pass the letter (e.g., "A") manually through the `prefix` value.
    let ch = if prefix != auto {
      prefix
    } else {
      let h = counter(heading.where(level: 1)).get()
      if h.len() > 0 { h.at(0) } else { 1 }
    }

    subpar.grid(
      gutter: 1.75em,
      numbering: n => [#ch.#n],
      numbering-sub-ref: (..n) => {
        let idx = n.pos().at(0)
        [#ch.#idx#numbering("a", idx)]
      },
      ..args
    )
  }
}

// paragraph function imitating LaTeX's \paragraph{}{}
#let paragraph(body, title: "", kind: "par", supplement: "Paragraph") = {
  figure(
    align(left, block(
      width: 100%,
      [
        #if title != none and title.len() > 0 {
          strong(title + ".")
          h(0.05em)
        }
        #body
      ],
    )),
    supplement: supplement,
    kind: kind,
  )
}

// obsidian-like callouts
#let callout(
  body,
  kind: "callout",
  supplement: [Callout],
  title: "Callout",
  fill: blue,
  title-color: white,
  body-color: black,
  icon: none,
) = {
  figure(
    kind: kind,
    supplement: supplement,
    caption: none, // suppress default caption,
    align(left, block(below: 1em, box(
      radius: 0.2em,
      inset: (top: 0.75em, bottom: 1em, right: 0.75em, left: 0.75em),
      width: 100%,
      fill: fill,
      clip: true,
      [
        #block(
          below: 0pt,
          text(fill: title-color, weight: "bold")[
            #if icon != none {
              icon
              h(0.15em)
            }
            #title
          ],
        )
        #block(text(fill: body-color)[#body], above: 1em)
      ],
    ))),
  )
}

// central registry for callout styles
#let callout-styles = (
  info: (
    title: "Info",
    icon: fa-icon("info-circle"),
    fill: colors.info.bg.saturate(5%),
    title-color: colors.info.title,
    supplement: [Info],
  ),
  faq: (
    title: "FAQ",
    icon: fa-icon("question-circle"),
    fill: colors.faq.bg.saturate(5%),
    title-color: colors.faq.title,
    supplement: [FAQ],
  ),
  tip: (
    title: "Tip",
    icon: fa-icon("lightbulb"),
    fill: colors.tip.bg.saturate(5%),
    title-color: colors.tip.title,
    supplement: [Tip],
  ),
  success: (
    title: "Success",
    icon: fa-icon("check-circle"),
    fill: colors.success.bg.saturate(5%),
    title-color: colors.success.title,
    supplement: [Success],
  ),
  danger: (
    title: "Danger",
    icon: fa-icon("times-circle"),
    fill: colors.danger.bg.saturate(5%),
    title-color: colors.danger.title,
    supplement: [Danger],
  ),
)

// generic function that builds a specific callout function
#let make-callout-fn = kind => {
  let style = callout-styles.at(kind)
  (body, title: style.title, icon: style.icon, supplement: style.supplement) => {
    callout(
      body,
      title: title,
      fill: style.fill,
      title-color: style.title-color,
      icon: icon,
      supplement: supplement,
      kind: str(kind),
    )
  }
}

#let info = make-callout-fn("info")
#let faq = make-callout-fn("faq")
#let tip = make-callout-fn("tip")
#let success = make-callout-fn("success")
#let danger = make-callout-fn("danger")

// definitions and theorems
#let math-callout(body, title, supplement, kind, stroke-fill, is-proof: false, of: none) = {
  figure(
    align(left, block(
      inset: (top: 0.5em, bottom: 0.5em, right: 0.75em, left: 0.75em),
      width: 100%,
      clip: true,
      stroke: (left: 2.5pt + stroke-fill),
      [
        #set par(first-line-indent: 0pt)
        #strong([
          #sentencecase(kind)
          #if is-proof {
            [of #of]
          } else {
            context counter(figure.where(kind: kind)).display()
            [ (#title)]
          }
        ])
        #h(0.15em) #emph(body)
      ],
    )),
    kind: kind,
    caption: none,
    supplement: supplement,
  )
}

#let definition(
  body,
  title: "Definition",
  supplement: [Definition.],
) = {
  math-callout(
    body,
    title,
    supplement,
    "definition",
    colors.purple,
  )
}

#let theorem(
  body,
  title: "Theorem",
  supplement: "Theorem",
) = {
  math-callout(
    body,
    title,
    "Theorem",
    "theorem",
    blue,
  )
}

#let proof(
  body,
  of,
  supplement: "Proof",
) = {
  math-callout(
    body,
    of: of,
    none,
    "Proof",
    "proof",
    colors.green,
    is-proof: true,
  )
}
