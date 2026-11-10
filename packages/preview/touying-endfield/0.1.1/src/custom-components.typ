#import "@preview/touying:0.6.3": utils

#let mini-slides(
  self: none,
  fill: rgb("000000"),
  alpha: 60%,
  display-section: false,
  display-subsection: true,
  linebreaks: true,
  spacing: .5em,
  short-heading: true,
  inline: false,
  current-slide-sym: $circle.filled$,
  other-slides-sym: $circle.stroked$,
) = (
  context {
    let headings = query(
      heading.where(level: 1).or(heading.where(level: 2)),
    ).filter(it => it.outlined)
    let sections = headings.filter(it => it.level == 1)
    if sections == () {
      return
    }
    let first-page = sections.at(0).location().page()
    headings = headings.filter(it => it.location().page() >= first-page)
    let slides = query(<touying-metadata>).filter(it => (
      utils.is-kind(it, "touying-new-slide") and it.location().page() >= first-page
    ))
    let current-page = here().page()
    let current-index = (
      sections.filter(it => it.location().page() <= current-page).len() - 1
    )
    let cols = ()
    let col = ()
    for (hd, next-hd) in headings.zip(headings.slice(1) + (none,)) {
      let next-page = if next-hd != none {
        next-hd.location().page()
      } else {
        calc.inf
      }
      if hd.level == 1 {
        if col != () {
          cols.push(align(left, col.sum()))
          col = ()
        }
        col.push({
          let body = if short-heading {
            utils.short-heading(self: self, hd)
          } else {
            hd.body
          }
          [#link(hd.location(), body)<touying-link>]
          if inline {
            h(.5em)
          } else {
            linebreak()
          }
          while (
            slides.len() > 0 and slides.at(0).location().page() < next-page
          ) {
            let slide = slides.remove(0)
            if display-section {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if (
                slide.location().page() <= current-page and current-page < next-slide-page
              ) {
                [#link(slide.location(), current-slide-sym)<touying-link>]
              } else {
                [#link(slide.location(), other-slides-sym)<touying-link>]
              }
            }
          }
          if display-section and display-subsection and linebreaks {
            linebreak()
          }
        })
      } else {
        col.push({
          while (
            slides.len() > 0 and slides.at(0).location().page() < next-page
          ) {
            let slide = slides.remove(0)
            if display-subsection {
              let next-slide-page = if slides.len() > 0 {
                slides.at(0).location().page()
              } else {
                calc.inf
              }
              if (
                slide.location().page() <= current-page and current-page < next-slide-page
              ) {
                [#link(slide.location(), current-slide-sym)<touying-link>]
              } else {
                [#link(slide.location(), other-slides-sym)<touying-link>]
              }
            }
          }
          if display-subsection and linebreaks {
            linebreak()
          } else if spacing != 0 {
            h(spacing)
          }
        })
      }
    }
    if col != () {
      cols.push(align(left, col.sum()))
      col = ()
    }
    if current-index < 0 or current-index >= cols.len() {
      cols = cols.map(body => text(fill: fill, body))
    } else {
      cols = cols
        .enumerate()
        .map(pair => {
          let (idx, body) = pair
          if idx == current-index {
            text(fill: fill, body)
          } else {
            text(fill: utils.update-alpha(fill, alpha), body)
          }
        })
    }
    set align(top)
    show: block.with(inset: (top: .5em, x: if inline { 1em } else { 2em }))
    show linebreak: it => it + v(-1em)
    set text(size: .7em)
    grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
  }
)
