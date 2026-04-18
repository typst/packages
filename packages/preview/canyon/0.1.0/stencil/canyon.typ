// Document-wide settings
// ----------------------

#import "SETUP/META.typ": META
#import "SETUP/CONFIG.typ": CONFIG
#import "SETUP/ELEMENTS.typ": *

#set document(
  title: (META.title, META.subtitle).join(", "),
  author: META.author,
  description: META.description,
  date: META.date,
  keywords: META.keywords,
)

// Heading settings
// ----------------

// Fancy headings use suboutline
#import "@preview/suboutline:0.3.0": *

// Show rules - headings
#show heading.where(level: 1, numbering: none): it => {
  pagebreak(to: "odd")
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  counter(figure.where(kind: "exhibit")).update(0)
  counter(figure.where(kind: "problem")).update(0)
  counter(math.equation).update(0)
  v(15mm)
  align(center)[
    #box(
      width: 100%,
      inset: (x: 1em, y: 1.66em),
      fill: gray.transparentize(25%),
    )[#text(..ELEM.text.heading.at(1))[#it]]
  ]
  v(15mm)
}

#show heading.where(level: 1, numbering: "1."): it => {
  pagebreak(to: "odd", weak: true)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  counter(figure.where(kind: "exhibit")).update(0)
  counter(figure.where(kind: "problem")).update(0)
  counter(math.equation).update(0)
  page(..ELEM.page.title)[
    #set par(..ELEM.par.bare)
    #set align(center)
    #set text(..ELEM.text.heading.at(0))
    #box(
      inset: (x: 2em, y: 1.5em),
      fill: black.transparentize(75%),
      radius: 1em
    )[#it.supplement #counter(heading).get().at(0)]
    #v(5mm)
    #it.body
    #v(12mm)
    #set align(left)
    #set par(..ELEM.par.bare)
    #set text(..ELEM.text.normal)
    #line(length: 100%, stroke: 0.6pt + black)
    #suboutline(
      title: none,
      depth: 1,
    )
    #line(length: 100%, stroke: 0.6pt + black)
  ]
}

#show heading.where(level: 1, numbering: "A.1."): it => {
  pagebreak(to: "odd", weak: true)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  counter(figure.where(kind: "exhibit")).update(0)
  counter(figure.where(kind: "problem")).update(0)
  counter(math.equation).update(0)
  page(..ELEM.page.title)[
    #set align(center)
    #set text(..ELEM.text.heading.at(0))
    #box(
      inset: 2em,
      fill: rgb(0, 0, 4, 96),
      radius: 1em
    )[#it.supplement #counter(heading).display("A")]
    #v(5mm)
    #it.body
    #v(12mm)
    #set align(left)
    #set par(..ELEM.par.bare)
    #set text(..ELEM.text.normal)
    #line(length: 100%, stroke: 0.6pt + black)
    #suboutline(
      title: none,
      depth: 1,
    )
    #line(length: 100%, stroke: 0.6pt + black)
  ]
}

#show heading.where(level: 2): it => {
  v(0.8em)
  text(..ELEM.text.heading.at(2))[#it]
  v(0.6em)
}

#show heading.where(level: 3): it => {
  v(0.4em)
  set par(..ELEM.par.bare)
  text(..ELEM.text.heading.at(3))[#it.body]
  v(0.3em)
}

#show heading.where(level: 4): it => {
  v(0.2em)
  set par(..ELEM.par.bare)
  text(..ELEM.text.heading.at(4))[#it.body]
  v(0.15em)
}

// Figure settings
// ---------------

// Settings for all figure kinds
// forum.typst.app/t/do-i-need-different-code-for-numbering-equations-and-figures/3068/3
#set figure(
  numbering: n => {
    let chp-count = counter(heading.where(level: 1)).at(here()).first()
    numbering("1" + CONFIG.num-sep.fig + "1", chp-count, n)
  }
)

// Show rules - figures
#show figure.caption: set par(justify: true)
#show figure.caption: it => context stack(
  dir: ltr,
  strong[#it.supplement #it.counter.display()~--~],
  it.body,
)

// Figure show rules by figure kind
#show figure.where(
  kind: image
): it => {
  set figure.caption(position: bottom)
  set par(..ELEM.par.bare)
  set align(center)
  set text(..ELEM.text.footnote.entry)
  set block(breakable: true)
  it
}

#show figure.where(
  kind: table
): it => {
  set figure.caption(position: top)
  set par(..ELEM.par.bare)
  set align(center)
  set text(..ELEM.text.footnote.entry)
  set block(breakable: true, sticky: true)
  it
}

#show figure.where(
  kind: "exhibit"
): it => {
  exh-count.step()
  set figure.caption(position: top)
  set par(..ELEM.par.bare)
  set align(left)
  set text(..ELEM.text.caption)
  set block(breakable: true, sticky: true)
  it
}

#show figure.where(
  kind: "problem"
): it => {
  pro-count.step()
  set par(..ELEM.par.bare)
  set align(left)
  set text(..ELEM.text.caption)
  set block(breakable: true)
  it
}

// Show rules - equations
#set math.equation(
  numbering: n => { numbering("(1" + CONFIG.num-sep.eqn + "1)", counter(heading).get().first(), n) },
  number-align: right,
)

// Miscellanea
// -----------

// Show rules - raws
#show raw: set text(..ELEM.text.raw)
#show raw.where(block: true): set par(leading: 0.5em)

// Show rules - footnotes
#show footnote: set text(..ELEM.text.footnote.mark)
#show footnote.entry: set text(..ELEM.text.footnote.entry)

// Show rules - links
#show link: set text(..ELEM.text.link)

// Nested list settings
#set list(
  marker: (
    box(width: 1.5em)[#align(center)[⁍]],
    box(width: 1.5em)[#align(center)[•]],
  )
)

// Glossarium
// ----------
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary
#show: make-glossary
#import "SETUP/GLO.typ": entry-list
#register-glossary(entry-list)

// Document Parts
// --------------

// Front Matter
#include "1-FRONT/__setup.typ"

// Body
#include "2-BODY/__setup.typ"

// Back Matter
#include "3-BACK/__setup.typ"
