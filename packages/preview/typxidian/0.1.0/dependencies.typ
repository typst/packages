#import "@preview/cetz:0.4.1" // drawing inspired by tikz
#import "@preview/booktabs:0.0.4": * // booktabs-like tables
#import "@preview/wrap-it:0.1.1": wrap-content, wrap-top-bottom // wrap figures around text
#import "@preview/subpar:0.2.2" // create subfigures
#import "@preview/headcount:0.1.0": *
#import "@preview/glossarium:0.5.9": gls, make-glossary, glspl, print-glossary, register-glossary
#import "@preview/fontawesome:0.6.0": fa-icon
#import "@preview/decasify:0.10.1": sentencecase
#import "colors.typ": purple

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

#let paragraph(title, body, label: none) = {
  figure(
    align(left,
      block(
          width: 100%,
          [
            #text(weight: "bold", title). #h(0.05em) #body
          ]
      )
    ),
    supplement: [Paragraph],
    kind: "paragraph",
  )
}

/*** CALLOUTS ***/

#let info-title = rgb(48, 107, 246)
#let info-bg = rgb(234, 240, 251)

#let faq-title = rgb(221, 124, 46)
#let faq-bg = rgb(252, 242, 234)

#let tip-title = rgb(86, 188, 187)
#let tip-bg = rgb(238, 248, 248)

#let success-title = rgb(84, 182, 81)
#let success-bg = rgb(238, 248, 236)

#let danger-title = rgb(214, 64, 67)
#let danger-bg = rgb(251, 236, 238)

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
    align(left,
    block(below: 1em, box(
      radius: 0.2em,
      inset: (top: 0.75em, bottom: 1em, right: 0.75em, left: 0.75em),
      width: 100%,
      fill: fill,
      clip: true,
      [
        // Title with supplement + numbering
        #text(fill: title-color, weight: "bold", size: 12.5pt)[
          #if icon != none {
            icon
            h(0.15em)
          }
          #title
        ]
        #block(text(fill: body-color)[#body], above: 1.2em)
      ],
    )),
  ))
}

// central registry for callout styles
#let callout-styles = (
  info: (
    title: "Info",
    icon: fa-icon("info-circle"),
    fill: info-bg.saturate(5%),
    title-color: info-title,
    supplement: [Info.],
  ),
  faq: (
    title: "FAQ",
    icon: fa-icon("question-circle"),
    fill: faq-bg.saturate(5%),
    title-color: faq-title,
    supplement: [FAQ.],
  ),
  tip: (
    title: "Tip",
    icon: fa-icon("lightbulb"),
    fill: tip-bg.saturate(5%),
    title-color: tip-title,
    supplement: [Tip.],
  ),
  success: (
    title: "Success",
    icon: fa-icon("check-circle"),
    fill: success-bg.saturate(5%),
    title-color: success-title,
    supplement: [Succ.],
  ),
  danger: (
    title: "Danger",
    icon: fa-icon("times-circle"),
    fill: danger-bg.saturate(5%),
    title-color: danger-title,
    supplement: [Dang.],
  ),
)

// generic function that builds a specific callout function
#let make-callout-fn = (kind) => {
  let style = callout-styles.at(kind)
  (body,
   title: style.title,
   icon: style.icon,
   supplement: style.supplement) => {
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

// define your callout functions dynamically
#let info = make-callout-fn("info")
#let faq = make-callout-fn("faq")
#let tip = make-callout-fn("tip")
#let success = make-callout-fn("success")
#let danger = make-callout-fn("danger")

// Definitions and Theorems
#let math-callout(body, title, supplement, kind, stroke-fill) = { 
  figure(
    align(left,
    block(
      inset: (top: 0.75em - 0.7em, bottom: 0.75em - 0.45em, right: 0.75em, left: 0.75em),
      width: 100%,
      clip: true,
      stroke: (left: 2.5pt + stroke-fill),
      [
        #strong([
          #sentencecase(kind)
          #context counter(figure.where(kind: kind)).display(dependent-numbering("1.1"))
          (#title)]) #h(0.15em) #emph(body)
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
    purple,
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
