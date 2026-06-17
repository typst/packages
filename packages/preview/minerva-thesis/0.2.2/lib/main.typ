#import "@preview/subpar:0.2.2"
#import "@preview/abbr:0.3.0"
#import "states.typ": *
#import "settings.typ": *



#let add-chapter-number(numbering: none, ..num) = {
  let chapters = query(heading.where(level: 1).before(here()))
  let the-number= std.numbering(numbering, ..num)
  if chapters.len() == 0 {
    the-number
  } else if chapters.last().numbering == none {
    the-number
  } else {
    let the-chapter-number=std.numbering(chapters.last().numbering, counter(heading).get().first())
    if the-chapter-number.last()=="." {the-chapter-number+the-number} else {the-chapter-number+"."+the-number}
  }
}

#let figure-block(breakable: false, fill: auto, inset: auto, body) = context{
  let the-figure-settings=figure-settings.get().at(store.get())
  let the-fill = if fill==auto {the-figure-settings.fill} else {fill}
  let the-inset = if inset==auto {if the-fill == none {0pt} else {the-figure-settings.inset } } else {inset}
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


#let m-subpar(
  kind: image,
  outline-caption: auto,
  caption: none,
  outlined: true,
  label: none,
  breakable: false,
  fill: auto,
  inset: auto,
  show-sub: auto, 
  show-sub-caption: auto,
  numbering: auto, // should not be set!
  numbering-sub: auto,
  numbering-sub-ref: auto, // should not be set!
  breakable-sub: false,
  subfigure-caption-font: auto,
  subfigure-caption-font-size: auto,
  subfigure-caption-pos: auto,
  subfigure-caption-align: auto,
  subfigure-caption-sep: auto,
  subfigure-numbering: auto,
  subfigure-ref-numbering: auto,
  subfigure-caption-textargs: auto,
  subfigure-caption-num-textargs: auto,
  subpar-function: subpar.super,
  ..args,
) =  context {
  let the-figure

  let the-figure-settings=figure-settings.get().at(store.get())
  let the-numbering=the-figure-settings.at(str(repr(kind))+"-numbering")
  let the-numbering-function=the-figure-settings.at("numbering-function")

  
  let the-show-sub=if show-sub==auto {it => {
      set block(inset: 0pt, fill: none, breakable: breakable-sub) 
      set figure.caption(position: 
        if kind==table {top} else {        
          if subfigure-caption-pos==auto{the-figure-settings.subfigure-caption-pos} else {subfigure-caption-pos}  
        }
      )
      it
    }
  } else {show-sub} 
  
  let the-show-sub-caption=if show-sub-caption==auto {
   (num,it) => {
      set text(
        font: if subfigure-caption-font==auto {the-figure-settings.subfigure-caption-font} else {subfigure-caption-font},
        size: if subfigure-caption-font-size==auto {the-figure-settings.subfigure-caption-font-size} else {subfigure-caption-font-size}
      )
      set text(..if subfigure-caption-textargs==auto {the-figure-settings.subfigure-caption-textargs} else {subfigure-caption-textargs}) 
      set align(if subfigure-caption-align==auto{the-figure-settings.subfigure-caption-align} else {subfigure-caption-align} )
      {
        set text(..if subfigure-caption-num-textargs==auto{the-figure-settings.subfigure-caption-num-textargs} else {subfigure-caption-num-textargs}                      )
        num
        if it.body!=[] {
          if subfigure-caption-sep==auto{the-figure-settings.subfigure-caption-sep} else {subfigure-caption-sep}
        }
      }
      it.body
    }
  } else {show-sub-caption}
   
  let the-subfigure-num=if subfigure-numbering==auto{the-figure-settings.subfigure-numbering} else {subfigure-numbering}
  let the-subfigure-ref-num=if subfigure-ref-numbering==auto{the-figure-settings.subfigure-ref-numbering} else {subfigure-ref-numbering}
  
  let the-numbering=if numbering==auto { 
    if the-numbering-function!=none {the-numbering-function.with(numbering: the-numbering)} else {the-numbering}   
  } else {numbering} 
  
  let the-numbering-sub= if numbering-sub==auto {
    (..num) => std.numbering(the-subfigure-num, num.pos().last())
  } else {numbering-sub}   
  
  let the-numbering-sub-ref=if numbering-sub-ref==auto {
    (ifig, isubfig) => {
      std.numbering(the-numbering,ifig) + std.numbering(the-subfigure-ref-num, isubfig)}
  } else {numbering-sub-ref}

  set figure(placement: none) if breakable 
  if outlined and outline-caption != auto {
    {
      show figure: it => it.counter.update(v => v - 1)
      subpar-function(
        numbering: the-numbering,
        kind: kind,
        ..args,
        caption: outline-caption
      )
    } 
    the-figure = subpar-function(
      kind: kind,
      show-sub: the-show-sub, 
      show-sub-caption: the-show-sub-caption,
      numbering: the-numbering,
      numbering-sub: the-numbering-sub, 
      numbering-sub-ref: the-numbering-sub-ref,     
      ..args,
      label: label,
      caption: caption,
      outlined: false,
    )
  } else {
    the-figure = subpar-function(
      kind: kind,
      show-sub: the-show-sub, 
      show-sub-caption: the-show-sub-caption,
      numbering: the-numbering,
      numbering-sub: the-numbering-sub, 
      numbering-sub-ref: the-numbering-sub-ref,
      ..args,
      label: label,
      caption: caption)
  }
  figure-block(breakable: breakable, fill: fill, inset: inset, the-figure)
}

#let m-subpar-super=m-subpar.with(subpar-function: subpar.super)
#let m-subpar-grid=m-subpar.with(subpar-function: subpar.grid)

#let set-figures(
  base-font: none,
  base-font-size: none,
  font: auto,
  font-size: auto,
  fill: default-figure-fill, 
  inset: default-figure-inset,
  image-numbering: "1",
  table-numbering: "1",
  raw-numbering: "1",
  numbering-function: none,
  caption-font: auto,
  caption-font-size: auto,
  caption-indent: true,
  caption-align: center,
  caption-text-align: left,
  caption-separator: default-caption-separator,
  caption-textargs: (:),
  caption-num-textargs: default-caption-num-textargs,
  subfigure-caption-font: auto,
  subfigure-caption-font-size: auto,
  subfigure-caption-pos: top,
  subfigure-caption-align: left,
  subfigure-caption-sep: auto,  
  subfigure-numbering: default-subfigure-numbering,
  subfigure-ref-numbering: auto,
  subfigure-caption-textargs: auto,
  subfigure-caption-num-textargs: auto,
  ref-textargs: (:),
  store: none
) = body => {
  
  let the-caption-font=if caption-font==auto {base-font} else {caption-font}
  let the-caption-font-size=if caption-font-size==auto {default-figure-font-size*base-font-size} else {caption-font-size}
  
  
  figure-settings.update(
    it => {
      it.insert(store,(
        font: if font==auto {base-font} else {font},
        font-size: if font-size==auto {default-figure-font-size*base-font-size} else {font-size},
        fill: if fill==auto{default-figure-fill} else {fill}, 
        inset: inset,      
        image-numbering: image-numbering, 
        table-numbering: table-numbering, 
        raw-numbering: raw-numbering, 
        numbering-function: numbering-function, 
        caption-font: the-caption-font,
        caption-font-size: the-caption-font-size,
        caption-indent: caption-indent,
        caption-align: caption-align,
        caption-text-align: caption-text-align,
        caption-separator: caption-separator,
        caption-textargs: caption-textargs,
        caption-num-textargs: caption-num-textargs,
        subfigure-caption-font: if subfigure-caption-font==auto {the-caption-font} else {subfigure-caption-font},
        subfigure-caption-font-size: if subfigure-caption-font-size==auto {the-caption-font-size} else {subfigure-caption-font-size},
        subfigure-caption-pos: subfigure-caption-pos,
        subfigure-caption-align: subfigure-caption-align,
        subfigure-caption-sep: if subfigure-caption-sep==auto {caption-separator} else {subfigure-caption-sep},
        subfigure-numbering: subfigure-numbering,
        subfigure-ref-numbering: if subfigure-ref-numbering==auto {subfigure-numbering} else {subfigure-ref-numbering},
        subfigure-caption-textargs: if subfigure-caption-textargs==auto {caption-textargs} else {subfigure-caption-textargs},
        subfigure-caption-num-textargs: if subfigure-caption-num-textargs==auto {caption-num-textargs} else {subfigure-caption-num-textargs},
        ref-textargs: ref-textargs,
        )
      )
      it
    }
  )
  
  show figure.where(kind: image): set figure(numbering: if numbering-function!=none {numbering-function.with(numbering: image-numbering)} else {image-numbering})
  show figure.where(kind: table): set figure(numbering: if numbering-function!=none {numbering-function.with(numbering: table-numbering)} else {table-numbering})
  show figure.where(kind: raw): set figure(numbering: if numbering-function!=none {numbering-function.with(numbering: raw-numbering)} else {raw-numbering})

  show figure: set text(font: font) if font != auto
  show figure: set text(size: font-size) if type(font-size) == length
  
  show figure.caption: set text(font: caption-font) if caption-font!=auto
  show figure.caption: set text(size: caption-font-size) if type(caption-font-size)==length
  show figure.caption: set text(..caption-textargs) /*if type(caption-textargs)==dictionary*/

  // Caption block is by default centred in the figure block (and (thus) also the text in the caption block)
  // Uncomment if the caption block has to be left aligned in the figure block:
  show figure.caption: set align(caption-align)

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


#let part(page-number: false, title) = {
  if not page-number {show-page-number.update(false)} 
  set heading(numbering: none)
  part-number.step()
  context { // a heading for the Table of Contents only. start-at-odd-page is needed for right location in ToC
    show heading: it => {start-at-odd-page()} 
    heading[Part #part-number.display(part-num.get()) -- #title]
  }
  part-heading.update(true) // see heading show-rule
  heading(title, outlined: false, bookmarked: false) 
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
  paper: none,
  page-width: 160mm, 
  page-height: 240mm,
  page-margin: (y: 15mm, inside: 25mm, outside: 15mm),  
  font: auto,
  font-size: auto,
  chapter-title-font: auto,
  chapter-title-font-size: auto,
  chapter-number-font: auto,
  chapter-number-font-size: auto,
  chapter-number-colour: gray,
  part-numbering: "I",
  chapter-numbering: "1.1",
  appendix-numbering: "A.1",
  per-chapter-numbering: true,
  math-font: auto,
  math-font-size: auto,
  equation-left-margin: auto,
  figure-fill: none, // auto = default-figure-fill
  figure-inset: 0.5em, // default-figure-inset
  figure-font: auto,
  figure-font-size: auto, 
  caption-font: auto,
  caption-font-size: auto,
  caption-indent: true,
  caption-align: center,
  caption-text-align: left,
  caption-separator: sym.colon+sym.space, // default-caption-separator 
  caption-textargs: (:),
  caption-num-textargs: (weight: "semibold"),  // default-caption-num-textargs
  subfigure-caption-font: auto,
  subfigure-caption-font-size: auto,
  subfigure-caption-pos: top,
  subfigure-caption-align: left,
  subfigure-caption-sep: auto,
  subfigure-numbering: "a", // default-subfigure-numbering
  subfigure-ref-numbering: auto, 
  subfigure-caption-textargs: auto,
  subfigure-caption-num-textargs: auto,
  figure-ref-textargs: (:),
  body
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
  
  set text(font: font) if font!=auto
  set text(size: font-size) if type(font-size) == length

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
  

  show figure.caption: it => {
      let settings=figure-settings.get().at(store.get())
//       set text(font: settings.font, size: settings.caption-font-size )
      if settings.caption-indent {
        table(
          {set text(..settings.caption-num-textargs) 
            it.supplement
            sym.space.nobreak
            it.counter.display(it.numbering)
            it.separator
          },
          it.body,
          column-gutter: 0.15em,
          stroke: none,
          inset: 0pt,
          align: (right, left),
          columns: 2,
        )
      } else {
        box(align(settings.caption-text-align, it))
        // In the caption block itself, the text is left aligned, this can be just "it" if the caption block is left aligned in the figure block.
      }
  }
  
  part-num.update(part-numbering)
  chapter-num.update(chapter-numbering)
  appendix-num.update(appendix-numbering)
  
  show ref: it => {
      let el = it.element
//       set text(weight: "semibold") if el != none and el.func() == figure and figure-settings.get().at(store.get()).bold-ref
      set text(..figure-settings.get().at(store.get()).ref-textargs) if el != none and el.func() == figure
      it
  }

  
  context{
  
    let base-font-size=text.size
  
    show figure.where(kind: table): set figure.caption(position: top)

    
    show: set-figures(
      numbering-function: if per-chapter-numbering {add-chapter-number} else {none},
      base-font: text.font,
      base-font-size: base-font-size,
      fill: figure-fill,
      inset: figure-inset,
      font: figure-font, 
      font-size: figure-font-size,
      caption-font: caption-font,
      caption-font-size: caption-font-size,
      caption-indent: caption-indent,
      caption-align: caption-align,
      caption-text-align: caption-text-align,
      caption-separator: caption-separator,
      caption-textargs: caption-textargs,
      caption-num-textargs: caption-num-textargs,
      subfigure-caption-pos: subfigure-caption-pos,
      subfigure-caption-align: subfigure-caption-align,
      subfigure-caption-sep: subfigure-caption-sep,
      subfigure-numbering: subfigure-numbering,
      subfigure-ref-numbering: subfigure-ref-numbering,
      subfigure-caption-textargs: subfigure-caption-textargs,
      subfigure-caption-num-textargs: subfigure-caption-num-textargs,
      subfigure-caption-font: subfigure-caption-font,
      subfigure-caption-font-size: subfigure-caption-font-size,
      ref-textargs: figure-ref-textargs,   
      store: "m") 


    show math.equation: set text(font: math-font) if math-font != auto 
    show math.equation: set text(size: if math-font-size==auto {base-font-size} else {math-font-size})

    show math.equation.where(block: true): set align(left) if equation-left-margin != auto

    show math.equation.where(block: true): set block(inset: (left: equation-left-margin)) if type(equation-left-margin) in (relative, length, ratio)

    set math.equation(numbering: add-chapter-number.with(numbering:"1")) if per-chapter-numbering
    set math.equation(numbering:"(1)") if not per-chapter-numbering
    

    let addbrackets(..num) = {
      "(" + std.numbering(math.equation.numbering, ..num) + ")"
    }
    show math.equation.where(block: true): it => {
      if type(it.numbering) == function and it.numbering != addbrackets {
        counter(math.equation).update(v => v - 1)
        math.equation(block: true, numbering: addbrackets, it.body)
      } else { it }
    }

    show heading: set block(below: 1em)
  
    
    show heading.where(level: 1): it => {
      if per-chapter-numbering {
        counter(math.equation).update(0)
        counter(figure.where(kind: image)).update(0)
        counter(figure.where(kind: table)).update(0)
        counter(figure.where(kind: raw)).update(0)
      }
      start-at-odd-page()
      if show-heading.get() {
        if part-heading.get() {
          v(8mm)
          {
            set text(font: chapter-number-font) if chapter-number-font!=auto
            align(right, text(
              size: if chapter-number-font-size==auto {7.2*base-font-size} else {chapter-number-font-size},
              fill: chapter-number-colour,
              [Part ] + part-number.display(part-num.get())
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


  
    show outline: set heading(outlined: true)

    show outline.entry.where(level: 1): set block(above: 1em)

    show outline.entry: it => context {
      let pg-width=page-number-width.get()
      set box(baseline: 100%)
      let el=it.element
      let loc=el.location()
      let firstlevelheading=el.func()==heading and it.level==1 
      set text(weight:"semibold") if firstlevelheading
      let thefill=if firstlevelheading {none} else {it.fill}
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
                  thefill
                  }
                )
              },
            ))
          } else {
            it.indented(box(text(weight: "semibold", it.prefix())), box(par(
              justify: true,
              it.body()
              + [ ]
              + { if is-page-number-shown { box(baseline: 0%, width: 1fr, thefill) } },
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
//     show outline: it => {
//       if repr(it.target) == "heading" {
//         show outline.entry.where(level: 1): set text(weight: "semibold")
//         show outline.entry.where(level: 1): set outline.entry(fill: none)
//         it
//       } else {it}
//     }
// This is now implemented in outline.entry show-rule, see firstlevelheading. 
  
    set document(title: title) if title!=none
    set document(author: authors) if type(authors)==str or type(authors) == array 
    set document(keywords: keywords) if type(keywords)==str or type(keywords)==array
    set document(description: description) if description!=none
    set document(date: date) if type(date) == datetime

    store.update("m")
    
    body
  
  }
}


#let front-matter(show-headings: true, body)={

  set page(numbering: "i") 
  set heading(numbering: none)
  show-heading.update(show-headings)
  filled-outline.update(true)
  
  body
}

#let chapter(body)=context{
  show-heading.update(true)
  set page(numbering:"1")
  start-at-odd-page()
  counter(page).update(1)
  set heading(numbering: chapter-num.get())
  show heading.where(level:1): set heading(supplement: [Chapter]) 
  counter(heading).update(0) // not really necessary as front-matter headings are not numbered
  filled-outline.update(false)
  
  body
}

#let appendix(flyleaf:[Appendices], body)=context{
  set page(numbering:"1")
  show-heading.update(true)
  counter(heading).update(0)
  set heading(numbering: appendix-num.get())
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

#let back-matter(show-headings: true, body)={
  set page(numbering:"1")
  show-heading.update(show-headings)
  set heading(numbering: none)
  filled-outline.update(true)
  
  body
}
