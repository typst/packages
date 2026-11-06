#import "outline.typ": *
#import "apply-style.typ": *
#import "header-footer.typ": *
#import "front-pages.typ": *
#import "../tools/shortcuts.typ": *
#import "code-display.typ": *
#import "../tools/formatting.typ": *


= Documents


/*
Labels : 
- <title>
- <section>

*/

/*
Style :
- Numbered
- Colored
- Plain
*/

#let doc(
  lang: "fr",
  title: "Titre",
  authors: (),
  style: "numbered",
  title-page: false,
  outline: false,
  local-outline: false,
  outline-max-depth: 5,
  smallcaps: true,
  content,
) = context {
  set page(margin: 1.5cm)
  set text(lang: lang, font: "New Computer Modern")

  show: apply-style.with(style)

  let (first-real-pages, custom-outline) = get-outline(lang, smallcaps, outline-max-depth)


  if (first-real-pages.len() == 0) {
    first-real-pages.push(0)
  }


  show: header-footer.with(style, smallcaps, first-real-pages, title, authors)

  front-pages(style, smallcaps, title, title-page, authors, outline, local-outline, custom-outline)

  show: shows-shortcuts
  show: code-display

  // Pre-set

  set table(inset: 10pt, stroke: 0.4pt + text.fill.lighten(20%), align: center + horizon, fill: (x, y) => if (x == 0)
    or (y == 0) { text.fill.lighten(90%) })


  set grid(column-gutter: 10pt, align: horizon)


  show image: it => {
    align(center, it)
  }

  show table: it => {
    block(clip: true, radius: 0.75em, stroke: it.stroke, it)
  }
  // content
  set par(justify: true)

  counter(heading).update(0)


  content
}

