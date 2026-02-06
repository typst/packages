#import "../../common/theme/type.typ": 字体, 字号
#import "../../common/components/typography.typ": use-heading-main, use-heading-preface, use-heading-end
#import "../../common/components/header.typ": use-hit-header
#import "../../common/components/footer.typ": use-footer-preface, use-footer-main
#import "config/constants.typ": special-chapter-titles-additional, thesis-info-additional
#import "../../common/config/constants.typ": current-date, main-text-line-spacing-multiplier, single-line-spacing
#import "../../common/utils/states.typ": special-chapter-titles-state
#import "../../common/utils/states.typ": default-header-text-state, bibliography-state, thesis-info-state, digital-signature-option-state
#import "@preview/cuti:0.2.1": show-cn-fakebold
#import "@preview/i-figured:0.2.4": show-figure, reset-counters, show-equation
#import "@preview/lovelace:0.2.0": setup-lovelace
#import "pages/cover.typ": cover
#import "../../common/pages/abstract.typ": abstract-cn as abstract-cn-page, abstract-en as abstract-en-page
#import "../../common/pages/outline.typ": outline-page
#import "../../common/pages/conclusion.typ": conclusion as conclusion-page
#import "../../common/pages/bibliography.typ": bibliography-page
#import "../../common/pages/acknowledgement.typ": acknowledgement as acknowledgement-page
#import "../../common/pages/achievement.typ": achievement as achievement-page
#import "pages/declaration-of-originality.typ": declaration-of-originality

#let preface(content) = {

  [#metadata("") <preface-start>]

  context {
    let header-text = default-header-text-state.get()
    show: use-hit-header.with(header-text: header-text)
    show: use-footer-preface

    show: use-heading-preface

    set page(numbering: "I")
    counter(page).update(1)

    content
  }

}

#let main(
  content,
  figure-options: (:),
) = {

  [#metadata("") <main-start>]

  figure-options = figure-options + (
    extra-kinds: (),
    extra-prefixes: (:),
  )

  set page(numbering: "1")

  show: use-heading-main
  show: use-footer-main

  show heading: reset-counters.with(extra-kinds: ("algorithm",) + figure-options.extra-kinds)
  show figure: show-figure.with(
    numbering: "1-1",
    extra-prefixes: ("algorithm": "algo:") + figure-options.extra-prefixes,
  )
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): set figure.caption(position: top)
  show figure: set text(size: 字号.五号)

  show raw.where(block: false): box.with(
    fill: rgb("#fafafa"),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  show raw.where(block: false): text.with(
    font: 字体.代码,
    size: 10.5pt,
  )
  show raw.where(block: true): block.with(
    fill: rgb("#fafafa"),
    inset: 8pt,
    radius: 4pt,
    width: 100%,
  )
  show raw.where(block: true): text.with(
    font: 字体.代码,
    size: 10.5pt,
  )

  show math.equation: show-equation.with(numbering: "(1-1)")

  show: setup-lovelace

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

  counter(page).update(1)

  content
}


#let ending(content) = {

  [#metadata("") <ending-start>]

  show: use-heading-end

  set heading(numbering: none)

  content
}

#let ending-content(conclusion: none, achievement: none, acknowledgement: none) = {
  if conclusion != none {

    conclusion-page[
      #conclusion
    ]

    pagebreak()

  }

  bibliography-page()

  pagebreak()

  if achievement != none {
    achievement-page[
      #achievement
    ]
    pagebreak()
  }

  declaration-of-originality()

  pagebreak()

  if acknowledgement != none {
    acknowledgement-page[
      #acknowledgement
    ]
  }
}

#let doc(
  content,
  thesis-info: (:),
  abstract-cn: none,
  keywords-cn: (),
  abstract-en: none,
  keywords-en: (),
  figure-options: (:),
  bibliography: none,
  conclusion: none, 
  achievement: none, 
  acknowledgement: none,
  digital-signature-option: (:),
) = {
  set document(
    title: thesis-info.at("title-cn"),
    author: thesis-info.author,
  )

  thesis-info-state.update(current => {
    current + thesis-info-additional + thesis-info
  })

  bibliography-state.update(current => bibliography)

  default-header-text-state.update(current => "哈尔滨工业大学本科毕业论文（设计）")

  special-chapter-titles-state.update(current => current + special-chapter-titles-additional)

  digital-signature-option-state.update(current => current + digital-signature-option)

  set page(
    paper: "a4",
    margin: (top: 3.8cm, left: 3cm, right: 3cm, bottom: 3cm),
  )

  show: show-cn-fakebold

  set text(lang: "zh", region: "cn")

  cover()

  let par-spacing-base = 1.55em
  let par-spacing-multiplier = 1.25
  let leading = par-spacing-multiplier * par-spacing-base - 1em
  let spacing = par-spacing-multiplier * par-spacing-base - 1em
  set par(
    first-line-indent: (
      amount: 2em,
      all: true,
    ), 
    leading: leading, 
    justify: true, 
    spacing: spacing
  )

  set text(font: 字体.宋体, size: 字号.小四)
  
  let zh-tracking = 1.067em
  // show text.where(lang: "zh"): set text(tracking: zh-tracking - 1em)

  show: preface

  if abstract-cn != none {
    abstract-cn-page(keywords: keywords-cn, par-leading: 0.94em, par-spacing: 0.94em, text-tracking: 0.72pt)[
      #abstract-cn
    ]
  }

  if abstract-en != none {
    abstract-en-page(keywords: keywords-en, par-leading: 0.775em, par-spacing: 0.77em, text-tracking: 0.2pt, text-spacing: 4.76pt)[
      #abstract-en
    ]
  }

  outline-page(par-leading: 0.89em)

  figure-options = figure-options + (
    extra-kinds: (),
    extra-prefixes: (:),
  )

  show: main.with(figure-options: figure-options)

  content

  show: ending

  ending-content(
    conclusion: conclusion,
    achievement: achievement,
    acknowledgement: acknowledgement
  )

}