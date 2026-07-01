#import "../../common/theme/type.typ": 字体, 字号
#import "../../common/components/typography.typ": use-heading-main, use-heading-preface, use-heading-end
#import "../../common/components/header.typ": use-hit-header
#import "../../common/components/footer.typ": use-footer-preface, use-footer-main
#import "config/constants.typ": thesis-info-additional, special-chapter-titles-additional
#import "../../common/config/constants.typ": current-date, main-text-line-spacing-multiplier, single-line-spacing
#import "../../common/utils/states.typ": thesis-info-state, bibliography-state, default-header-text-state, special-chapter-titles-state, digital-signature-option-state
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
#import "pages/personal-resume.typ": personal-resume-page
#import "config/constants.typ": e-master-type
#import "utils/states.typ": master-type-state

#let preface(content) = {

  [#metadata("") <preface-start>]

  show: use-hit-header
  show: use-footer-preface

  show: use-heading-preface

  set page(numbering: "I")
  counter(page).update(1)

  content
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

#let ending-content(conclusion: none, achievement: none, acknowledgement: none, personal-resume: none) = {
  if conclusion != none {

    conclusion-page(use-same-header-text: true)[
      #conclusion
    ]

    pagebreak()

  }

  bibliography-page(use-same-header-text: true)

  pagebreak()

  if achievement != none {
    achievement-page(use-same-header-text: true)[
      #achievement
    ]
    pagebreak()
  }

  declaration-of-originality()

  pagebreak()

  if acknowledgement != none {
    acknowledgement-page(use-same-header-text: true)[
      #acknowledgement
    ]
  }

  if personal-resume != none {
    personal-resume-page()[
      #personal-resume
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
  personal-resume: none,
  master-type: none,
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

  default-header-text-state.update(current => "哈尔滨工业大学硕士学位论文")

  special-chapter-titles-state.update(current => current + special-chapter-titles-additional)

  digital-signature-option-state.update(current => current + digital-signature-option)

  if master-type != none {
    assert(
      e-master-type.values().contains(master-type), message: "master-type 需传入类型为 e-master-type 的数据"
    )
    master-type-state.update(current => master-type)
  }

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

  show: preface

  if abstract-cn != none {
    abstract-cn-page(keywords: keywords-cn, use-same-header-text: true, par-leading: 0.94em, par-spacing: 0.94em, text-tracking: 0.72pt)[
      #abstract-cn
    ]
  }

  if abstract-en != none {
    abstract-en-page(keywords: keywords-en, use-same-header-text: true, par-leading: 0.84em, par-spacing: 0.8em, text-tracking: 0.2pt, text-spacing: 4.76pt)[
      #abstract-en
    ]
  }

  outline-page(par-leading: 0.83em)

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
    acknowledgement: acknowledgement,
    personal-resume: personal-resume,
  )

}