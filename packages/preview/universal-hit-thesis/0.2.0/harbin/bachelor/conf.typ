#import "../../common/theme/type.typ": 字体, 字号
#import "components/typography.typ": main-format-heading, special-chapter-format-heading
#import "utils/numbering.typ": heading-numbering
#import "config/constants.typ": special-chapter-titles
#import "config/constants.typ": current-date
#import "utils/states.typ": thesis-info-state
#import "@preview/cuti:0.2.1": show-cn-fakebold
#import "@preview/i-figured:0.2.4": show-figure, reset-counters, show-equation

#let doc(content, thesis-info: (:)) = {
  thesis-info = (
    title-cn: "",
    title-en: "",
    author: "▢▢▢",
    student-id: "▢▢▢▢▢▢▢▢▢▢",
    supervisor: "▢▢▢ 教授",
    profession: "▢▢▢ 专业",
    collage: "▢▢▢ 学院",
    institute: "哈尔滨工业大学",
    year: current-date.year(),
    month: current-date.month(),
    day: current-date.day(),
  ) + thesis-info

  set document(
    title: thesis-info.at("title-cn"),
    author: thesis-info.author,
  )

  thesis-info-state.update(current => {
    current + thesis-info
  })


  set page(
    paper: "a4",
    margin: (top: 3.8cm, left: 3cm, right: 3cm, bottom: 3cm),
  )

  show: show-cn-fakebold

  content
}

#let preface(content) = {
  set page(header: {
    [
      #set align(center)
      #set par(leading: 0em)
      #text(font: 字体.宋体, size: 字号.小五, baseline: 6pt)[
        哈尔滨工业大学本科毕业论文（设计）
      ]
      #line(length: 100%, stroke: 2.2pt)
      #v(2.2pt, weak: true)
      #line(length: 100%, stroke: 0.6pt)
    ]
  })

  set page(numbering: "I")

  set page(footer: context [
    #align(center)[
      #counter(page).display("- I -")
    ]
  ])

  counter(page).update(1)


  show heading: it => {
    set par(first-line-indent: 0em)

    if it.level == 1 {
      align(center)[
        #special-chapter-format-heading(it: it, font: 字体.黑体, size: 字号.小二)
      ]
    } else {
      it
    }
  }


  set par(first-line-indent: 2em, leading: 1em, justify: true)

  set text(font: 字体.宋体, size: 字号.小四)

  content
}

#let main(
  content,
  extra-kinds: (),
  extra-prefixes: (:),
) = {
  set page(numbering: "1")

  set page(footer: context [
    #align(center)[
      #counter(page).display("- 1 -")
    ]
  ])

  counter(page).update(1)

  set heading(numbering: heading-numbering)

  show heading: it => {
    set par(first-line-indent: 0em)

    if it.level == 1 {
      align(center)[
        #main-format-heading(it: it, font: 字体.黑体, size: 字号.小二)
      ]
    } else if it.level == 2 {
      main-format-heading(it: it, font: 字体.黑体, size: 字号.小三)
    } else if it.level >= 3 {
      main-format-heading(it: it, font: 字体.黑体, size: 字号.小四)
    }
  }

  show heading: reset-counters.with(extra-kinds: ("algorithm",) + extra-kinds)
  show figure: show-figure.with(numbering: "1-1", extra-prefixes: ("algorithm": "algo:") + extra-prefixes)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): set figure.caption(position: top)

  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  show raw.where(block: false): text.with(
    font: 字体.代码,
    size: 10.5pt,
  )
  show raw.where(block: true): block.with(
    fill: luma(240),
    inset: 8pt,
    radius: 4pt,
    width: 100%,
  )
  show raw.where(block: true): text.with(
    font: 字体.代码,
    size: 10.5pt,
  )

  show math.equation: show-equation.with(numbering: "(1-1)")

  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      numbering(
        el.numbering,
        ..counter(eq).at(el.location()),
      )
    } else {
      // Other references as usual.
      it
    }
  }

  content
}

#let ending(content) = {
  show heading: it => {
    set par(first-line-indent: 0em)

    if it.level == 1 {
      align(center)[
        #special-chapter-format-heading(it: it, font: 字体.黑体, size: 字号.小二)
      ]
    } else {
      it
    }
  }
  set heading(numbering: none)

  content
}