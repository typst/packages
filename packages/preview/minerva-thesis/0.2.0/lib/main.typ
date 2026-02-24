#import "@preview/subpar:0.2.2"
#import "@preview/abbr:0.2.3"
#import "states.typ": *

// colours of Ghent University corporate identity
#let colour-primary = rgb("#1e64c8") // = rgb(30, 100, 200)
#let colour-secondary = rgb("#ffd200")
#let colour-tertiary = rgb("#e9f0fa")


#let add-chapter-number(style: none, ..num) = {
  let chapters = query(heading.where(level: 1).before(here()))
  let the-number= numbering(style, ..num)
  if chapters.len() == 0 {
    the-number
  } else if chapters.last().numbering == none {
    the-number
  } else {
    let the-chapter-number=numbering(chapters.last().numbering, counter(heading).get().first())
    if the-chapter-number.last()=="." {the-chapter-number+the-number} else {the-chapter-number+"."+the-number}
  }
}

#let figure-block(breakable: false, fill: auto, inset: auto, body) = context{
  let the-fill = fill
  let the-inset = inset
  let the-figure-settings=figure-settings.get().at(store.get())
  if the-fill == auto {the-fill = the-figure-settings.fill}
  if the-inset == auto {the-inset = if the-fill == none {0pt} else {the-figure-settings.inset } }
  show figure.caption: set block(breakable: false) if breakable
  if the-inset == 0pt and the-fill == none {
    show figure: set block(breakable: breakable)
    body
  } else {
    show figure: set block(breakable: breakable, fill: the-fill, inset: the-inset)
    show figure.caption: set block(fill: none, inset: 0pt) 
    show table: set block(fill: none, inset: 0pt)
    show grid: set block(fill: none, inset: 0pt)
    show image: set block(fill: none, inset: 0pt)
    body
  }
}

#let m-figure(
  outline-caption: auto,
  caption: none,
  outlined: true,
  label: none,
  breakable: false,
  fill: auto,
  inset: auto,
  ..args,
) = {
  let the-figure
  if outlined and outline-caption != auto {
    {
      show figure: it => it.counter.update(v => (
        v - 1
      )) 
      figure(..args, caption: outline-caption)
    } 
    the-figure = [#figure(..args, caption: caption, outlined: false) #label]
  } else if label != none {
    the-figure = [#figure(..args, caption: caption) #label]
  } else {
    the-figure = figure(..args, caption: caption)
  }
  figure-block(breakable: breakable, fill: fill, inset: inset, the-figure)
}


#let m-subpar-grid(
  kind: image,
  outline-caption: auto,
  caption: none,
  outlined: true,
  label: none,
  breakable: false,
  fill: auto,
  inset: auto,
  show-sub: auto, 
  numbering: auto,
  numbering-sub: auto,
  numbering-sub-ref: auto,
  ..args,
) =  context {
  let the-figure
  let the-show-sub
  let the-numbering
  let the-numbering-sub
  let the-numbering-sub-ref
  let the-figure-settings=figure-settings.get().at(store.get())
  let the-style=the-figure-settings.at(str(repr(kind)))
  let the-style-function=the-figure-settings.at("style-function")
  
  if show-sub==auto { the-show-sub = it => {
      set figure.caption(position: top)
      show figure.caption: it => align(left, it)
      set block(inset: 0pt, fill: none) 
      set figure(placement: none)
      it
    }
  } else {the-show-sub = show-sub} 
  
  if numbering==auto { 
    the-numbering = if the-style-function!=none {the-style-function.with(style: the-style)} else {the-style}   
  } else {the-numbering = numbering} 
  if numbering-sub==auto {
    the-numbering-sub= (..num) => text(weight: "semibold", std.numbering("a.", num.pos().last()))
  } else {the-numbering-sub=numbering-sub} 
  if numbering-sub-ref==auto {
    the-numbering-sub-ref= (ifig, isubfig) => {
      if the-style-function!=none {the-style-function(style: the-style,ifig)} else {std.numbering(the-style,ifig)} + std.numbering("a", isubfig)}
  } else {the-numbering-sub-ref=numbering-sub-ref}

  set figure(placement: none) if breakable 
  if outlined and outline-caption != auto {
    {
      show figure: it => it.counter.update(v => v - 1)
      subpar.grid(
        numbering: the-numbering,
        kind: kind,
        ..args,
        caption: outline-caption
      )
    } 
    the-figure = subpar.grid(
      kind: kind,
      show-sub: the-show-sub, 
      numbering: the-numbering,
      numbering-sub: the-numbering-sub, 
      numbering-sub-ref: the-numbering-sub-ref,     
      ..args,
      label: label,
      caption: caption,
      outlined: false,
    )
  } else {
    the-figure = subpar.grid(
      kind: kind,
      show-sub: the-show-sub, 
      numbering: the-numbering,
      numbering-sub: the-numbering-sub, 
      numbering-sub-ref: the-numbering-sub-ref,
      ..args,
      label: label,
      caption: caption)
  }
  figure-block(breakable: breakable, fill: fill, inset: inset, the-figure)
}


#let set-figures(
  image-style: "1",
  table-style: "1",
  raw-style: "1",
  style-function: none,
  bold-ref: false,
  tabular-caption: false,
  fill: none,
  inset: 0pt,
  store: none
) = body => context{
    
  figure-settings.update(
    it => {
      it.insert(store,(image: image-style, table: table-style, raw: raw-style, style-function: style-function, bold-ref: bold-ref, tabular-caption: tabular-caption, fill: fill, inset: inset ))
      it
    }
  )
  
  show figure.where(kind: image): set figure(numbering: if style-function!=none {style-function.with(style: image-style)} else {image-style})
  show figure.where(kind: table): set figure(numbering: if style-function!=none {style-function.with(style: table-style)} else {table-style})
  show figure.where(kind: raw): set figure(numbering: if style-function!=none {style-function.with(style: raw-style)} else {raw-style})
  
  body 
}

#let set-page-number-width(pg-width) = {
  page-number-width.update(pg-width)
}

#let hide-page-number() = {
  page-number-on-page.update(false) 
}

#let start-at-odd-page() = {
  content-switch.update(false)
  pagebreak(weak: true, to: "odd")
}

#let part-number = counter("part")


#let part(page-number: false, title) = context {
  if not page-number {show-page-number.update(false)} 
  set heading(numbering: none)
  part-number.step()
  part-heading.update(true)
  context {
    show heading: it => {start-at-odd-page()} // a heading for the Table of Contents only. start-at-odd-page is needed for right location in ToC
    heading[Part #part-number.display("I") -- #title]
  }
  heading(title, outlined: false, bookmarked: false) 
  counter(heading).update(counter(heading).get()) // restores the heading counter to value before calling part()
  part-heading.update(false)
  if not page-number {show-page-number.update(true)} 
}



#let thesis(
  authors: none,
  title: none,
  keywords: none,
  description: none,
  language: "EN", 
  faculty: none,
  supervisors: none,
  multiple-supervisors: auto,
  counsellors: none,
  multiple-counsellors: auto,
  date: none,
  font: auto,
  font-size: auto,
  math-font: auto,
  math-font-size: auto,
  figure-font: auto,
  figure-font-size: auto,
  caption-font: auto,
  caption-font-size: auto,
  chapter-title-font: auto,
  chapter-title-font-size: auto,
  chapter-number-font: auto,
  chapter-number-font-size: auto,
  chapter-number-colour: luma(150),
  equation-left-margin: auto,
  paper: none,
  page-width: 160mm, 
  page-height: 240mm,
  page-margin: (y: 15mm, inside: 25mm, outside: 15mm),
  figure-fill: none,
  figure-inset: 0.5em,
  figure-tabular-caption: false,
  figure-bold-ref: auto,
  body,
) = {
  
  abbr.config(style: it=>{it})
  
  let the-multiple-supervisors
  let the-multiple-counsellors
  
  if authors!=none {thesis-authors.update(authors)}
  if title!=none {thesis-title.update(title)}
  if description!=none {thesis-description.update(description)}
  if language!=none {thesis-language.update(language)}
  if faculty!=none {thesis-faculty.update(faculty)}
  if supervisors!=none {thesis-supervisors.update(supervisors)}
  if multiple-supervisors==auto {
    if type(supervisors) == array {the-multiple-supervisors=supervisors.len()>1}
    else {the-multiple-supervisors=false}
  } else {the-multiple-supervisors=multiple-supervisors}
  if type(the-multiple-supervisors)==bool {thesis-multiple-supervisors.update(the-multiple-supervisors)}
  if counsellors!=none {thesis-counsellors.update(counsellors)}
  if multiple-counsellors==auto {
    if type(counsellors) == array {the-multiple-counsellors=counsellors.len()>1}
    else {the-multiple-counsellors=false}
  } else {the-multiple-counsellors=multiple-counsellors}
  if type(the-multiple-counsellors)==bool {thesis-multiple-counsellors.update(the-multiple-counsellors)}
  
  if date!=none {thesis-date.update(date)}
  if keywords!=none {thesis-keywords.update(keywords)}
  
  set text(font: font) if font != auto
  set text(size: font-size) if font-size!=auto

  set par(justify: true)
  set list(indent: 0.5em)
  set enum(indent: 0.5em)
  
  set page(paper: paper) if paper != none 
  set page(width: page-width) if paper==none 
  set page(height: page-height) if paper==none
  
  set page(
    margin: page-margin,
    // set page-number-shown to (content-switch or level-1 heading on page) and (page-numbering!=none and show-page-number) 
    //                        = or-condition and and-condition
    // show-page-number has to be set before the page is made, false means no page number at all (not on the page, nor in the outline)
    header: context { 
      let or-condition-1=content-switch.get()
      let and-condition=page.numbering != none and show-page-number.get()
      // perform the query for level-1 heading on page (= the second factor of the or-condittion) only if needed. 
      if (not or-condition-1) and and-condition { 
        // only the second factor of the or-condition has to be checked as the first one is false and the and-condition is true
        page-number-shown.update( 
          query(heading.where(level: 1)) 
            .map(it => it.location().page())
            .contains(here().page())
        )
      } else {page-number-shown.update(and-condition) }
    },
    // page-number-on-page can be set on the page itself (default=true). If false no page number is set on the page itself.
    // Whether the page number is shown in the outline or not depends on page-number-shown (which is set in header)
    footer: context {
      if page-number-shown.get() {
        if page-number-on-page.get() { 
          align(
            if calc.odd(counter(page).get().first()) { right } else { left },
            counter(page).display()
          )
        }
      }
      page-number-on-page.update(true) // The default (for the next page) is true.
    },
  )

  context{
  
    let base-font-size=text.size
  
    show figure: set text(font: figure-font) if figure-font != auto
    show figure: set text(size: if figure-font-size==auto {0.9*base-font-size} else {figure-font-size})

    show figure.where(kind: table): set figure.caption(position: top)

    store.update("m")
    
    show: set-figures(
      image-style:"1",
      table-style:"1",
      raw-style:"1",
      style-function: add-chapter-number,
      tabular-caption: figure-tabular-caption,
      bold-ref: if figure-bold-ref==auto {figure-tabular-caption} else {figure-bold-ref},
      fill: if figure-fill==auto {colour-tertiary} else {figure-fill},
      inset: figure-inset,
      store: "m")

    show figure.caption: it => context {
      set text(font: caption-font)  if caption-font != auto
      set text(size: if caption-font-size==auto {0.9*base-font-size} else {caption-font-size} )
      if figure-settings.get().at(store.get()).tabular-caption {
        table(
          [*#it.supplement #it.counter.display(it.numbering)*#it.separator],
          it.body,
          column-gutter: 0.15em,
          stroke: none,
          inset: 0pt,
          align: (right, left),
          columns: 2,
        )
      } else {it}
    }
    

    show math.equation: set text(font: math-font) if math-font != auto 
    show math.equation: set text(size: if math-font-size==auto {base-font-size} else {math-font-size})

    show math.equation.where(block: true): set align(left) if equation-left-margin != auto

    show math.equation.where(block: true): set block(inset: (left: equation-left-margin)) if type(equation-left-margin) in (relative, length, ratio)

    set math.equation(numbering: add-chapter-number.with(style:"1")) 

    let addbrackets(..num) = {
      "(" + numbering(math.equation.numbering, ..num) + ")"
    }
    show math.equation.where(block: true): it => {
      if type(it.numbering) == function and it.numbering != addbrackets {
        counter(math.equation).update(v => v - 1)
        math.equation(block: true, numbering: addbrackets, it.body)
      } else { it }
    }

    show heading: set block(below: 1em)
  
    
    show heading.where(level: 1): it => {
      counter(math.equation).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      start-at-odd-page()
      if show-heading.get() {
        if part-heading.get() {
          v(8mm)
          {
            set text(font: chapter-number-font) if chapter-number-font!=auto
            align(right, text(
              size: if chapter-number-font-size==auto {7.2*base-font-size} else {chapter-number-font-size},
              fill: chapter-number-colour,
              [Part ] + part-number.display("I")
            ))
          }
          set text(font: chapter-title-font) if chapter-title-font!=auto
          align(right, 
            text(
              size: if chapter-title-font==auto {3.2*base-font-size} else {chapter-title-font-size}, 
              it.body
            )
          )
        } else {
          v(8mm)
          if it.numbering != none {
            set text(font: chapter-number-font) if chapter-number-font!=auto
            align(right, 
              text(size: if chapter-number-font-size==auto {7.2*base-font-size} else {chapter-number-font-size},
                fill: chapter-number-colour, 
                counter(heading).display(it.numbering)
              )
            )
          }
          set text(font: chapter-title-font) if chapter-title-font!=auto
          align(right, 
            text(size: if chapter-title-font==auto {3.2*base-font-size} else {chapter-title-font-size}, 
              hyphenate: false,
              it.body
            )
          )
          v(10mm)
        }
      }
      content-switch.update(true)
    }

    show ref: it => {
      let el = it.element
      set text(weight: "semibold") if el != none and el.func() == figure and figure-settings.get().at(store.get()).bold-ref
      it
    }
  
    show outline: set heading(outlined: true)

    show outline.entry.where(level: 1): set block(above: 1em)

    show outline.entry: it => context {
      set box(baseline: 100%)
      let pg-width=page-number-width.get()
      let loc = it.element.location()
      let is-page-number-shown = page-number-shown.at(loc)
      link(loc, block(
        width: 100%,
        block(
          width: 100% - pg-width, 
          if it.prefix() == none {
            box(par(
              justify: true,
              it.body()
              + [ ]
              + if is-page-number-shown {
                box(
                  baseline: 0%,
                  width: 1fr,
                  if filled-outline.at(loc) {
                    repeat(text(weight: "regular")[.], gap: 0.15em) // i.e. the default fill
                  } else {
                  it.fill
                  }
                )
              },
            ))
          } else {
            it.indented(box(text(weight: "semibold", it.prefix())), box(par(
              justify: true,
              it.body()
              + [ ]
              + { if is-page-number-shown { box(baseline: 0%, width: 1fr, it.fill) } },
            )))
          })
        + if is-page-number-shown { 
            place(bottom + right, it.page())
          }
      ))
    }

// First-level headings are set in bold and without fill in the Table of Contents
//   show outline.where(target: heading): it => {
//       show outline.entry.where(level: 1): set text(weight: "semibold")
//       show outline.entry.where(level: 1): set outline.entry(fill: none)
//       it
//   } 
// Selection via outline.where(target: heading) does not work for some reason. Therefore selection via repr(it.target)
    show outline: it => {
      if repr(it.target) == "heading" {
        show outline.entry.where(level: 1): set text(weight: "semibold")
        show outline.entry.where(level: 1): set outline.entry(fill: none)
        it
      } else {it}
    }
  
    set document(title: title) if title!=none
    set document(author: authors) if type(authors)==str or type(authors) == array 
    set document(keywords: keywords) if type(keywords)==str or type(keywords)==array
    set document(description: description) if description!=none
    set document(date: date) if type(date) == datetime

    body
  }
}


#let front-matter(show-headings: true, body)={
//   section.update("front-matter")
  set page(numbering: "i") 
  set heading(numbering: none)
  show-heading.update(show-headings)
  filled-outline.update(true)
  
  body
}

#let chapter(body)={
// Settings for Chapters:
//   section.update("chapters")
  show-heading.update(true)
  set page(numbering:"1")
  counter(page).update(0) 
  set heading(numbering: "1.1.1")
  show heading.where(level:1): set heading(supplement: [Chapter]) 
  counter(heading).update(0)
  filled-outline.update(false)
  
  body
}

#let appendix(flyleaf:[Appendices],body)={
  set page(numbering:"1")
  show-heading.update(true)
  counter(heading).update(0)
  set heading(numbering: "A.1.1")
  show heading.where(level:1): set heading(supplement: [Appendix]) 
  filled-outline.update(false)
  
  if flyleaf!=none {
    show-page-number.update(false)
    start-at-odd-page()
    set heading(numbering:none) 
    [= #flyleaf]
    show-page-number.update(true)
  }
  
  body
}

#let back-matter(show-headings: true,body)={
  set page(numbering:"1")
  show-heading.update(show-headings)
  set heading(numbering: none)
  filled-outline.update(true)
  
  body
}
