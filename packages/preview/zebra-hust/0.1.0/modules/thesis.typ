#import "code_setup.typ": code_setup
#import "outline.typ": outline_with_sizes
#import "cover.typ": thesis-cover

#let thesis-title(title, fonts, outlined: true) = {
  set par(first-line-indent: 0pt)
  show heading: set align(center)
  show heading: set text(font: (..fonts.latin, ..fonts.hei), size: 18pt, weight: "bold")
  heading(level: 1, numbering: none, outlined: outlined, title)
}

#let thesis-abstract(body, keywords, fonts, english: false) = {
  set text(lang: if english { "en" } else { "zh" })
  thesis-title(if english { [Abstract] } else { [摘要] }, fonts)
  body
  parbreak()
  v(1em)
  block[
    #set par(first-line-indent: 0pt)
    #text(weight: "bold", if english { [Key Words: ] } else { [关键词：] })
    #keywords.join(if english { "; " } else { "；" })
  ]
  pagebreak()
}

#let thesis-body(body, fonts, heading-sizes) = {
  counter(heading).update(0)
  set heading(numbering: "1.1")
  show heading: it => {
    if it.level == 1 and it.numbering != none {
      pagebreak(weak: true)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
    }
    set align(if it.level == 1 { center } else { left })
    set text(
      font: (..fonts.latin, ..fonts.hei),
      size: heading-sizes.at(calc.min(it.level, heading-sizes.len()) - 1),
      weight: "bold",
    )
    it
  }
  set figure(numbering: number => context [#counter(heading).get().first()-#number])
  show figure.where(kind: image): set figure(supplement: [图])
  show figure.where(kind: table): set figure(supplement: [表])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: set text(font: (..fonts.latin, ..fonts.hei))
  show ref: reference => context {
    let target = reference.element
    if target != none and target.func() == figure and reference.form == "normal" {
      let location = target.location()
      let chapter = counter(heading).at(location).first()
      let number = target.counter.at(location).first()
      let supplement = if reference.supplement == auto { target.supplement } else { reference.supplement }
      if type(supplement) == function { supplement = supplement(target) }
      link(location)[#supplement #(chapter)-#number]
    } else {
      reference
    }
  }
  body
}

#let thesis-report(
  cover, outline, front-matter, statement, acknowledgments,
  fonts, layout, body,
) = {
  show: code_setup
  set text(font: (..fonts.latin, ..fonts.song), size: 12pt, lang: "zh")
  set par(first-line-indent: (amount: 2em, all: true), leading: layout.leading, justify: true)
  set page(paper: "a4", margin: layout.margin)

  thesis-cover(cover, fonts, layout.cover)

  if statement != none {
    set page(header: none, footer: none, numbering: none)
    statement
    pagebreak()
  }

  set page(
    numbering: "I",
    header: [
      #set par(first-line-indent: 0pt)
      #align(center, text(font: fonts.kai, size: 16pt, fill: rgb(192, 0, 0), tracking: 0.5em)[华中科技大学毕业设计])
      #v(2mm)
      #line(length: 100%, stroke: 0.5pt + rgb(24, 116, 205))
      #v(-0.7em)
      #line(length: 100%, stroke: 0.5pt + rgb(24, 116, 205))
    ],
    footer: context grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      line(length: 95%, stroke: 0.4pt),
      text(font: fonts.cover, size: 10.5pt, counter(page).display()),
      line(length: 95%, stroke: 0.4pt),
    ),
  )
  counter(page).update(1)
  if front-matter.abstract-zh != none {
    thesis-abstract(front-matter.abstract-zh, front-matter.keywords-zh, fonts)
  }
  if front-matter.abstract-en != none {
    thesis-abstract(front-matter.abstract-en, front-matter.keywords-en, fonts, english: true)
  }
  outline_with_sizes(
    font: (..fonts.latin, ..fonts.song),
    title-font: (..fonts.latin, ..fonts.hei),
    title-size: 18pt,
    ..outline,
  )

  set page(numbering: "1")
  counter(page).update(1)
  thesis-body(body, fonts, layout.heading-sizes)

  if acknowledgments != none {
    pagebreak()
    thesis-title([致谢], fonts)
    acknowledgments
  }
}
