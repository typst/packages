#import "@preview/drafting:0.2.2": *
#import "bookly-defaults.typ": *
#import "bookly-helper.typ": *

#let tufte-content(body) = block(width: 5.05cm, body)

#let sidefigure(content, label: none, caption: none, dy: - 1.5em) = context if states.tufte.get() {
  // Check side
  let side = right
  let dxm = 0%
  if states.alt-margins.get() {
    if calc.odd(here().page()) {
      side = right
      dxm = 0%
    } else {
      side = left
      dxm = 16%
    }
  }

  margin-note( {
    show: move.with(dx: dxm)
    show figure.caption: it => {
      set align(left)
      set text(0.9em)
      let kind
      if it.supplement.text.contains("Fig") {
        kind = image
      } else if it.supplement.text.contains("Tab") {
        kind = table
      }
      tufte-content[#it.supplement #counter(figure.where(kind: kind)).display() #it.separator #it.body]
    }
    set figure.caption(position: bottom)
    [#figure(
      content,
      caption: caption
    )#label]
    }, dy: dy, side: side
  )
} else {
  [#figure(
      content,
      caption: caption
  )#label]
}

#let fullfigure(content, caption: none, label: none) = context if states.tufte.get() {
  // Check side
  let side = right
  let dxm = 0%
  if states.alt-margins.get() {
    if calc.odd(here().page()) {
      side = right
      dxm = 0%
    } else {
      side = left
      dxm = 16%
    }
  }

  fullwidth({
    set figure.caption(position: bottom)
    show figure.caption: it => margin-note(
      [
        #set text(0.9em)
        #set align(left)
        #let kind = none
        #if it.supplement.text.contains("Fig") {
          kind = image
        } else if it.supplement.text.contains("Tab") {
          kind = table
        }

        #show: move.with(dx: dxm)
        #tufte-content[#it.supplement #counter(figure.where(kind: kind)).display() #it.separator #it.body]
      ], dy: -1.75em, side: side
    )
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

// Code from tufte-memo - thanks @nogula
#let sidenote(dy: -1.5em, numbered: true, label: none, content) = context if states.tufte.get() {
  // Check side
  let side = right
  let dxm = 0%
  if states.alt-margins.get() {
    if calc.odd(here().page()) {
      side = right
      dxm = 0%
    } else {
      side = left
      dxm = 16%
    }
  }

  if numbered {
    // Create a metadata entry for the sidenote
    [#metadata("sidenote")#label]

    // Update the sidenote counter
    states.sidenotecounter.step()
    let n = states.sidenotecounter.display()

    // Display the sidenote reference + marginal content
    super(n)
    text(size: 0.9em, margin-note(move(dx: dxm, tufte-content[#super(n) #content]), side: side, dy: dy))
  } else {
    text(size: 0.9em, margin-note(move(dx: dxm, tufte-content(content)), side:side, dy: dy))
  }
} else {
  [#footnote(content)#label]
}

#let sidecite(dy: -1.5em, supplement: none, key) = context if states.tufte.get() {
  // Check side
  let side = right
  let dxm = 0%
  if states.alt-margins.get() {
    if calc.odd(here().page()) {
      side = right
      dxm = 0%
    } else {
      side = left
      dxm = 16%
    }
  }

  let elems = query(bibliography)
  if elems.len() > 0 {
    cite(key, supplement: supplement)
    margin-note(
      {
        set text(0.9em)
        move(dx: dxm, tufte-content(cite(key, form: "full", style: "resources/short_ref.csl")))
      },
      dy: dy,
      side: side
    )
  }
} else {
  show cite: it => context{
    show regex("\[|\]"): it => text(fill: black)[#it]
    text(fill: states.colors.get().primary)[#it]
  }
  cite(key, supplement: supplement)
}