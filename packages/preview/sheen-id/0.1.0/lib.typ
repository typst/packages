b#import "@preview/i-figured:0.2.4"
#let vcover = state("cover", "./cover-colored.png")
#let vfont = "Times New Roman"
#let vtitle = state("title", "Title")
#let vcolor = state("color", blue)
#let vchapter-image = state("chapter_image", "./chapter_image.png")
#let vfooter-image = state("footer_image", "./chapter_image.png")

#let conf(
  color: blue,
  doc
) = {
  vcolor.update(color)
  set page(
    width: 15.5cm,
    height: 23cm,
    margin: (
      top: 2.5cm,
      bottom: 2cm,
      outside: 2cm,
      inside: 3cm
    )
  )
  
  //enum
  set enum(spacing: 1.5em, indent: 7pt)
  set enum(numbering: "a.")

  //list
  set list(spacing: 1.5em, indent: 7pt)

  //figure
  set figure(supplement: "Gambar")
  show figure.caption: set text(size: 9pt, style: "italic")
  show figure: i-figured.show-figure

  //raw
  show raw.where(block: false): highlight.with(
    top-edge: 13pt,
    bottom-edge: -7pt,
    fill: luma(240),
    radius: 2pt,
  )
  show raw.where(block: true): it => block(
    fill: luma(240),
    inset: 5pt,
    radius: 5pt,
    above: 10pt,
    width: 100%,
    text(it, size: 9pt)
  )

  //math
  set math.equation(supplement: "Persamaan")
  set math.mat(delim: "[", align: center, column-gap: 0.8em)
  show math.equation: set text(size: 13pt)

  //text
  set par(spacing: 2em)
  set text(font: vfont, size: 12pt, hyphenate: false)

  //image
  set image(width: 4in)
  show image: align.with(center)

  //heading
  show heading.where(level: 1): set text(weight: "bold", size: 20pt)
  show heading.where(level: 1): set par(justify: false)
  show heading.where(level: 1): set heading(hanging-indent: 0pt)
  show heading.where(level: 2): set text(weight: "bold", size: 12pt)
  show heading.where(level: 3): set text(weight: "bold", size: 12pt)
  show heading: i-figured.reset-counters
  show heading: set block(below: 2.5em, above: 2.5em)
  show heading: it => {
    if it.level >= 4 {
      set par(first-line-indent: 0em)
      it.body
    } else {
      it
    }
  }

  //table
  show table: align.with(center)
  set table(
    stroke: none,
    gutter: 0.2em,
    row-gutter: 1em,
    fill: (x, y) => if y == 0 { gray },
    inset: (right: 1.5em),
    align: (col, row) => if row > 0 { horizon+left } else { auto },
  )
  show table.cell: set text(size: 10pt)
  show table.cell.where(y: 0): set text(fill: white, size: 10pt)
  show table.cell.where(y: 0): set par(justify: false)

  doc
}

#let set-cover(path) = {
  vcover.update(path)
}

#let set-chapter-image(path) = {
  vchapter-image.update(path)
}

#let make-cover() = context {
  set page(background: image(vcover.get(), width: 100%, height: 100%, fit: "stretch"))
  pagebreak()
  set page(background: none)
  pagebreak()
}

#let make-gray-cover() = context {
  let data = read(vcover.get(), encoding: none)

  import "@preview/grayness:0.3.0": image-grayscale
  set page(background: image-grayscale(data, width: 100%, height: 100%, fit: "stretch"))
  pagebreak()
  set page(background: none)
  pagebreak()
}

#let make-title(
  title: [title],
  author: [author],
  gap: 5in
) = {
  vtitle.update(title)
  
  align(center)[
    #v(1in)
    #text(font: vfont, size: 24pt, weight: "bold", title)
    #v(gap)
    #text(font: vfont, size: 18pt, weight: "bold", author )
  ]
  pagebreak()
}

#let make-header-footer(
  img-path: none,
  doc
) = {
  vfooter-image.update(img-path)
  let img = if img-path == none {
    []
  } else {
    image(img-path, width: 20pt)
  }
  let template(left, right) = {
    grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 0pt,
      align: top,
      left, right,
    )
  }

  import "@preview/hydra:0.6.2": hydra
  set page(
    numbering: "i",
    header:  context {
      if calc.odd(here().page()) {
        align(right, text(hydra(1), size: 9pt))
      } else {
        align(left, text(hydra(2), size: 9pt))
      }
    },
    footer: context {
      let p = here().page()
      let rm = counter(page).display()
      let title = text(vtitle.get(), size: 9pt)
      if calc.odd(p) {
        let foot = template(img, [#title - #rm])
        align(right)[#foot]
      } else {
        let foot = template([#rm - #title], img)
        align(left)[#foot]
      }
    },
  )

  doc
}

#let make-toc() = context{
  pagebreak(to: "odd", weak: true)
  set page(header: none)
  show heading.where(level: 1): set text(weight: "bold", size: 13pt, fill: vcolor.get().darken(50%))

  align(center)[= DAFTAR ISI]
  show outline.entry: it => {
    show linebreak: none
    it
  }
  outline(depth: 2, title: none)
  pagebreak()
}

#let make-toi() = context{
  pagebreak(to: "odd", weak: true)
  set page(header: none)
  show heading.where(level: 1): set text(weight: "bold", size: 13pt, fill: vcolor.get().darken(50%))


  align(center)[= DAFTAR GAMBAR]
  show outline.entry: it => {
    show linebreak: none
    it
  }
  i-figured.outline(title: none)
  pagebreak()
}

#let make-toe() = context{
  pagebreak(to: "odd", weak: true)
  set page(header: none)
  show heading.where(level: 1): set text(weight: "bold", size: 13pt, fill: vcolor.get().darken(50%))

  align(center)[= DAFTAR PERSAMAAN]
  show outline.entry: it => {
    show linebreak: none
    it
  }
  outline(target: math.equation, title: none)
  pagebreak()
}

#let make-paragraph(doc) = {
  set par(justify: true, leading: 1em, spacing: 1.5em)
  set par(first-line-indent: (amount: 2.5em, all: true))

  set page(numbering: "1")
  set heading(numbering: "1.")

  show heading.where(level: 1, outlined: true): set heading(numbering: n => "BAB " + numbering("I", n))
  show heading.where(level: 1): it => {
    set align(center)
    if it.numbering != none { counter(heading).display(it.numbering) + "\n" }
    it.body
  }
  counter(page).update(1)

  doc
}

#let chapter(
  title: [title],
  objectives: [-],
) = context [
  #import "@preview/showybox:2.0.4": showybox
  #set page(footer: none, header: none)
  #set enum(indent: 0pt)
  #show heading.where(level: 1): set text(weight: "bold", size: 20pt, fill: vcolor.get().darken(50%))

  #pagebreak(weak: true, to: "odd")


  #align(center)[
    = #title
    #v(2em)
    #image(vchapter-image.get(), width: 2in)
    #v(3em)
  ]

  #showybox(
    frame: (
      border-color: vcolor.get().darken(50%),
      title-color: vcolor.get().lighten(60%),
      body-color: vcolor.get().lighten(80%),
    ),
    title-style: (
      color: black,
      weight: "regular",
      align: center,
    ),
    shadow: (
      offset: 3pt,
    ),
    title: [Tujuan Pembelajaran],
  )[
    #v(1em)
    #objectives
    #v(1em)
  ]

  #pagebreak()
  #pagebreak()
]

#let noindent(content) = [
  #set par(first-line-indent: 0pt)
  #content
]

#let getcolor() = vcolor.get()
