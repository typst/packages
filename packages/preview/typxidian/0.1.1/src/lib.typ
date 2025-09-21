#import "dependencies.typ": dependent-numbering, fa-icon, sentencecase, subpar

#let sizes = (
  chapter: 26pt,
  section: 16pt,
  subsection: 14pt,
  body: 10pt,
)

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

#let blankpage() =  context {
  set page(numbering: none, header: none)
  pagebreak()
  pagebreak()
  counter(page).update(n => n - 1)
}

#let subfigure(..args) = {
  subpar.grid(
    gutter: 1.5em,
    numbering: n => {
      numbering("1.1", ..counter(heading.where(level: 1)).get(), n)
    },
    numbering-sub-ref: (..n) => {
      numbering("1.1a", ..counter(heading.where(level: 1)).get(), ..n)
    },
    ..args
  )
}

#let paragraph(title, body) = {
  figure(
    align(left, block(
      width: 100%,
      [
        #text(weight: "bold", title). #h(0.05em) #body
      ],
    )),
    supplement: [Paragraph],
    kind: "paragraph",
  )
}

#let callout(
  body,
  kind: "callout",
  supplement: [Call.],
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
        #text(fill: title-color, weight: "bold", size: (sizes.body + 1pt))[
          #if icon != none {
            icon
            h(0.15em)
          }
          #title
        ]
        #block(text(fill: body-color)[#body], above: 1.2em)
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
    supplement: [Info.],
  ),
  faq: (
    title: "FAQ",
    icon: fa-icon("question-circle"),
    fill: colors.faq.bg.saturate(5%),
    title-color: colors.faq.title,
    supplement: [FAQ.],
  ),
  tip: (
    title: "Tip",
    icon: fa-icon("lightbulb"),
    fill: colors.tip.bg.saturate(5%),
    title-color: colors.tip.title,
    supplement: [Tip.],
  ),
  success: (
    title: "Success",
    icon: fa-icon("check-circle"),
    fill: colors.success.bg.saturate(5%),
    title-color: colors.success.title,
    supplement: [Succ.],
  ),
  danger: (
    title: "Danger",
    icon: fa-icon("times-circle"),
    fill: colors.danger.bg.saturate(5%),
    title-color: colors.danger.title,
    supplement: [Dang.],
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

// Definitions and Theorems
#let math-callout(body, title, supplement, kind, stroke-fill, is-proof: false, of: none) = {
  figure(
    align(left, block(
      inset: (top: 0.5em, bottom: 0.5em, right: 0.75em, left: 0.75em),
      width: 100%,
      clip: true,
      stroke: (left: 2.5pt + stroke-fill),
      [
        #strong([
          #sentencecase(kind)
          #if is-proof {
            [of #of]
          } else {
            context counter(figure.where(kind: kind)).display(dependent-numbering("1.1"))
            [ (#title)]
          }
        ])
        #h(0.15em) #emph(body)
      ],
    )),
    kind: kind,
    caption: title,
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
