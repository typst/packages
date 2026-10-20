#import "global.typ": *

// Determines whether or not the current page has a level 1 heading
#let _has-heading() = {
  return (query(heading.where(level: 1)).any(it => it.location().page() == here().page()))
}

//---------------------------------------------|  HEADERS  |---------------------------------------------//

// A simple header style, but with alternating body between the last level 2 heading and the level 1 heading
#let _header-alternating() = {
  set text(font: font-secondary, size: size-secondary)
  let print(alignment, body) = {
    
    let direction = none
    if alignment == left {direction = ltr}
    else if alignment == right {direction = rtl}
    
    set align(alignment)
    stack(dir: direction, spacing: 1em, 
      text(counter(page).display()), 
      [|],
      text(body, style: "italic"))
  }
  context {
    if(_has-heading()){none}
    else{
      let heading1 = query(selector(heading.where(level: 1)).before(here())).last(default: none)
      let heading2 = query(
        selector(heading.where(level: 2))
        .after(heading1.location())
        .before(here()))
        .last(default: heading1)
      if calc.even(counter(page).get().first()) {
        if heading1.numbering == none {
          print(left, heading1.body)
        }
        else {
          print(left, [#heading1.supplement #counter(heading).display(at: heading1.location()). #heading1.body])
        }
      } else {
        if heading2.numbering == none {
          print(right, heading2.body)
        }
        else{
          print(right, [#counter(heading).display(at: heading2.location()) #heading2.body])
        }
      }
    }
  }
}

// Header from the original LaTeX template
#let _header-original() = {
  set par(spacing: 0pt)
  set text(font: font-secondary, size: size-secondary)
  context {
    if(_has-heading()){none}
    else{
      let heading = query(selector(heading.where(level: 1)).before(here())).last()
      if calc.even(counter(page).get().first()) {
        box(width: 100%)[
          #text(counter(page).display())
          #h(1fr)
            #text(heading.body)
            ]
      } else {
        box(width: 100%)[
            #text(heading.body)
            #h(1fr)
            #text(counter(page).display())
          ]
      }
      v(2mm)
      line()
    }
  }
}

//---------------------------------------------|  FOOTERS  |---------------------------------------------//
  
// Footer for frontmatter
#let _front-footer() = {
  set align(center)
  set text(font: font-main, size: size-secondary)
  context counter(page).display()
}

// Footer for mainmatter
#let _main-footer() = {
  set align(center)
  set text(font: font-secondary, size: size-secondary)
  context {
    if(_has-heading()){counter(page).display()}
    else{none}
  }
}
  
//---------------------------------------------|  HEADINGS  |---------------------------------------------//

// Heading style from the original LaTeX template
#let _heading-original(it) = {
  set text(
    font: font-secondary,
    hyphenate: false
  )
  set align(right)
  let has-numbering = (it.numbering != none)
  if true {
    v(size-chapter-nbr)
    block()[
      #stack(dir: ttb, spacing: 7.5mm,
        [
          #box(width: 1fr, line())
          #box([
            #if has-numbering {
              text(size: size-main, it.supplement)
            }
            #text(size: size-chapter-nbr,weight: "regular", font: font-chapter-nbr, if has-numbering {counter(heading).display(it.numbering)})
          ])
        ],
        text(size: size-heading, it.body),
        line()
      )
    ]
  }
}

// A simplified heading
#let _heading-new(it) = {
  set text(
    font: font-main,
    hyphenate: false
  )
  set par(leading: 1em)

  block(
    width: 100%,
    align(center + horizon, 
      grid(
        rows: (1cm, auto, auto),
        row-gutter: 2em,
        if it.numbering != none [#text(size: size-main)[#it.supplement #counter(heading).display(it.numbering)]],
        text(size: size-heading, it.body),
        // line(length: 10%)
      )
    )
  )
}