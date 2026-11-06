#import "@preview/gb7714-bilingual:0.2.3": gb7714-bibliography
#import "./constant.typ": font-size, font-type
#import "./utils.typ": degree-text

#let append-bibliography-render(has-next: false) = {
  [= 参考文献]
  set text(size: font-size.five, font: font-type.sun)
  set par(leading: 1em, spacing: 1em, justification-limits: (
    tracking: (min: -0.01em, max: 0.02em),
  ))
  gb7714-bibliography(title: none)

  if has-next {
    pagebreak()
  }
}

#let append-achievement-render(type: "master", achievement, has-next: false) = {
  let dt = degree-text(type)

  [= #dt.zh-achievement]
  achievement

  if has-next {
    pagebreak()
  }
}

#let append-acknowledgements-render(acknowledgements, has-next: false) = {
  [= 致谢]
  acknowledgements

  if has-next {
    pagebreak()
  }
}

#let append-render(
  type: "master",
  bibliography: none,
  achievement: [],
  acknowledgements: [],
  cv: [],
  blind-review: false,
) = {
  let has-bibliography = bibliography != none
  let has-achievement = achievement != []
  let has-acknowledgements = acknowledgements != [] and not blind-review
  let has-cv = cv != [] and not blind-review

  if has-bibliography {
    append-bibliography-render(has-next: has-achievement or has-acknowledgements or has-cv)
  }

  if has-achievement {
    append-achievement-render(
      type: type,
      achievement,
      has-next: has-acknowledgements or has-cv,
    )
  }

  if has-acknowledgements {
    append-acknowledgements-render(acknowledgements, has-next: has-cv)
  }

  if has-cv {
    [= 作者简介]
    cv
  }
}
