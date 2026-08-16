#import "/src/utils.typ": i18n

#let frontmatter(doc, internal: false) = {
  if not internal {
    context [
      #let number = counter(page).at(<maincontent-start>).at(0)
      #counter(page).update(number)
    ]
  }
  
  set page(numbering: "I")
  set heading(numbering: none)

  doc
}

#let maincontent(doc) = {
  set page(numbering: "1")
  set heading(numbering: "1.1")

  pagebreak(weak: true)
  context {counter(page).update(1)}
  doc
}

#let backmatter(doc) = {
  [#metadata(none) <backmatter-start>]
  set page(numbering: "i")
  set heading(numbering: none)
  
  pagebreak(weak: true)
  context {counter(page).update(1)}
  doc
}

#let appendix(doc) = {
  pagebreak(weak: true)
  counter(heading).update(0)

  set heading(numbering: "A.1", supplement: [#i18n("appendix")])

  show heading: it => context {
    if it.level == 1 and it.numbering != none {
      counter("appendix").step()
      counter(figure.where(kind:image)).update(0)
      counter(figure.where(kind:table)).update(0)
      counter(figure.where(kind:raw)).update(0)
      [#it.supplement #counter(heading).display():]
    } else if it.numbering != none {
      [#counter(heading).display().]
    }

    h(0.3em)
    it.body
    parbreak()
  }

  show heading.where(level: 1): body => context {
    set text(fill: state("color-primary").get())
    body
  }

  show heading.where(level: 2): body => context {
    set text(fill: state("color-primary").get())
    body
  }

  set figure(
    numbering: n => {
      let hdr = counter(heading).get()
      numbering("A.1.", hdr.first(), n)
    },
    outlined: false
  )
  
  doc
}