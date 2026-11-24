#import "style.typ": _main-footer, _front-footer

//---------------------------------------------|  NUMBERING  |---------------------------------------------//

// Chapter numbering, single digit if level 1
#let _chapter-numbering(.. n) = {
  let numbers = n.pos()
  
  if numbers.len() == 1 {
      numbering("1", ..numbers)
    } else {
      numbering("1.1", ..numbers)
    }
}

// Appendix numbering, single letter if level 1
#let _appendix-chapter-numbering(.. n) = {
  let numbers = n.pos()
  
  if numbers.len() == 1 {
      numbering("A", ..numbers)
    } else {
      numbering("A.1", ..numbers)
    }
}

#let _figure-numbering(n) = numbering("1.1", counter(heading).get().first(), n)
#let _equation-numbering(n) = numbering("(1.1)", counter(heading).get().first(), n)
#let _appendix-figure-numbering(n) = numbering("A.1", counter(heading).get().first(), n)
#let _appendix-equation-numbering(n) = numbering("(A.1)", counter(heading).get().first(), n)

// Function for resetting counters for new chapters. Called everytime a chapter is started with a show rule. If adding new kinds of figures, include a reset here
#let _reset-counters() = {
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(math.equation).update(0)
}

//---------------------------------------------|  LOGIC  |---------------------------------------------//

// States
#let document-state = state("doc-state", "none")

// Outline state, used for the flexCaption function
#let _in-outline = state("in-outline", false)

// Document state functions help keep the main file clean. Use for example "#show: mainmatter" to begin the main part of the document.
// Beginning of the frontmatter
#let frontmatter(body) = {
  pagebreak(weak: true, to: "odd")
  set page(numbering: "I", footer: _front-footer())
  set heading(outlined: false, bookmarked: true, numbering: none)
  document-state.update("front")
  body
}

// Beginning of the mainmatter
#let mainmatter(body) = {
  pagebreak(weak: true, to: "odd")
  set heading(numbering: _chapter-numbering, outlined: true)
  set page(header: context state("header").get(), numbering: "1", footer: _main-footer())
  counter(page).update(1)
  counter(heading).update(0)
  set math.equation(numbering: _equation-numbering)
  document-state.update("main")
  body
}

// Beginning of the backmatter (Appendix)
#let backmatter(body) = {
  pagebreak(weak: true, to: "odd")
  set heading(numbering: _appendix-chapter-numbering)
  set figure(numbering: _appendix-figure-numbering)
  set math.equation(numbering: _appendix-equation-numbering)
  show heading.where(level: 1): set heading(supplement: [Appendix])
  counter(heading).update(0)
  document-state.update("back")
  body
}