#import "@preview/drafting:0.2.2": *
#import "bookly-defaults.typ": *
#import "bookly-helper.typ": *

#let sidefigure(content, label: none, caption: none, dy: - 1.5em) = context if states.layout.get().contains("tufte") {
  margin-note(
  context {
    show figure.caption: it => context {
      set align(left)
      set text(0.9em)
      let kind
      if it.supplement.text.contains("Fig") {
        kind = image
      } else if it.supplement.text.contains("Tab") {
        kind = table
      }
      [#it.supplement #counter(figure.where(kind: kind)).display() #it.separator #it.body]
    }
    set figure.caption(position: bottom)
    [#figure(
      content,
      caption: caption
    )#label]
    }, dy: dy
  )
} else {
  [#figure(
      content,
      caption: caption
  )#label]
}

#let fullfigure(content, caption: none, label: none) = context if states.layout.get().contains("tufte") {
  fullwidth({
    set figure.caption(position: bottom)
    show figure.caption: it => context move(dx: 37.6%, dy: -0.75em)[
      #set text(0.85em)
      #set align(left)
      #let kind = none
      #if it.supplement.text.contains("Fig") {
        kind = image
      } else if it.supplement.text.contains("Tab") {
        kind = table
      }
      #block(width: 4.5cm)[
        #it.supplement #counter(figure.where(kind: kind)).display() #it.separator #it.body
      ]
    ]
    set figure.caption(position: bottom)
    [#figure(
      content,
      caption: caption,
    )#label]
    }
  )
} else {
  [#figure(
      content,
      caption: caption,
  )#label]
}

//  Code from tufte-memo - thanks @nogula
#let sidenote(dy: -1.5em, numbered: true, content) = context if states.layout.get().contains("tufte") {
  if numbered {
    states.sidenotecounter.step()
    [ #super(context states.sidenotecounter.display())]
  }
  text(size: 0.9em, margin-note(
    if numbered {
    [#super(context states.sidenotecounter.display()) #content]
  } else {
    content
  }, dy: dy)
  )
} else {
  footnote(content)
}

#let sidecite(dy: -1.5em, supplement: none, key) = context if states.layout.get().contains("tufte") {
  let elems = query(bibliography)
  if elems.len() > 0 {
    cite(key, supplement: supplement)
    margin-note(
      {
        set text(0.9em)
        cite(key, form: "full", style: "resources/short_ref.csl")
      },
      dy: dy
    )
  }
} else {
  show cite: it => context{
    show regex("\[|\]"): it => text(fill: black)[#it]
    text(fill: states.colors.get().primary)[#it]
  }
  cite(key, supplement: supplement)
}