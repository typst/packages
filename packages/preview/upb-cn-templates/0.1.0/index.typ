#import "lib.typ": *

#let upb-cn-baseline(title, author, body) = {
  set document(title: title)
  if author != none {
    set document(author: author)
  }

  set page(
    margin: (top: 1.3in, left: 1in, right: 1in, bottom: 1in),
    numbering: "1",
    footer: context {
      set align(right)
      counter(page).display()
      "/"
      numbering(page.numbering, ..counter(page).final())
    }
  )
  
  // Text size and paragraph spacing
  set text(size: 9.95pt) // Compatibility with the Latex template
  set par(leading: 0.68em, justify: true, spacing: 1.3em)
  set grid(column-gutter: 1em, row-gutter: 0.8em)

  // Headings
  set heading(numbering: "1.1")
  show heading: set text(font: heading-font, size: 0.86em)
  show heading: set block(above: 1.3em, below: 1.3em)
  show heading.where(level: 1): set text(fill: upb-colors.ultra-blue)
  show heading.where(level: 2): set text(size: 0.97em)
  show heading.where(level: 3): set text(size: 1.05em)
  show heading: it => {
    block(
      if it.numbering == none {
        it.body
      } else {
        counter(heading).display(it.numbering) + h(1em) + it.body
      }
    )
  }

  // Lists and enumerations
  set list(indent: 1em, marker: ([•], [-]))
  set enum(indent: 1em)
  set enum(numbering: "1.a.i.")

  // Tables
  set table(
    stroke: (x, y) => (
      top: if y == 0 { 1pt } else { 0pt },
      bottom: 1pt,
    ),
  )
  set table.hline(stroke: 0.5pt)
  show figure.where(kind: table): set figure.caption(position: top)

  // Colorful hyperlinks
  show link: set text(fill: upb-colors.ultra-blue)

  // Gray background for code blocks
  show raw.where(block: true): set block(fill: luma(245), width: 100%, inset: .5em)

  // Figures
  set figure(placement: top)
  show figure: set block(above: 2em, below: 2em)
  show figure.where(kind: image): set figure(gap: 1.5em)
  show figure.caption: it => context {
    strong(it.supplement + " " + it.counter.display(it.numbering) + it.separator)
    it.body
  }

  set bibliography(title: "References")
  
  body
}

#let upb-cn-report(
  title: "Title",
  author: none,
  matriculation-number: none,
  left-header: none, // defaults to title
  right-header: none, // defaults to author
  meta: none, // e.g. (([key1], [value1]), ([key2], [value2]))
  body,
) = {
  if left-header == none {
    left-header = title
  }
  if right-header == none {
    right-header = author
  }

  show: upb-cn-baseline.with(title, author)

  set page(
    header: context {
        set align(bottom)
        if(counter(page).get().at(0) == 1) {
          // First page
          set align(center)
          box(
            width: 100% + 36pt * 2,
            overlay(
              white.transparentize(50%),
              stack(
                dir: ltr,
                image("upb-logo.svg", height: 42pt),
                h(1fr),
                stack(image("upb-triangles.svg", height: 27.7pt), v(1.8pt)),
                h(3.8pt),
              ),
            ),
          )
          v(-3pt)
        } else {
          // All other pages
          left-header
          h(1fr)
          right-header
          
          v(-0.9em)
          line(length: 100%, stroke: .4pt)
          v(-.7em)
        }
    }
  )

  {
    set text(size: 1.2em)
    heading(numbering: none,  outlined: false, title)
  }

  v(-.5em)

  if author != none {
    set text(weight: "bold", font: heading-font, size: 1.2em)
    author
    if matriculation-number != none [~(#matriculation-number)]
    v(.5em)
  }

  if meta != none {
    notebox(
      grid(
        columns: 2,
        ..meta.map(((key, value)) => ([*#key:*], value)).flatten(),
      )
    )
  }

  body
}
