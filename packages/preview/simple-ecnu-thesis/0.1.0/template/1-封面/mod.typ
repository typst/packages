#import "../lib.typ": *

// 封面样式
#let style(doc) = {
  // 设置元素居中
  set align(center)
  doc
}

// 汉字平均分布
// https://typst-doc-cn.github.io/guide/FAQ/character-intersperse.html
#let distr(s) = {
  stack(
    dir: ltr,
    ..s.clusters().map(x => [#x]).intersperse(1fr),
  )
}

// 下划线 key
#let rect-key(s, tail: "", w: auto, stroke: none, use-distr: true) = {
  let body = s
  if use-distr {
    body = distr(s)
  }
  rect(
    height: 1.5em,
    inset: 5pt,
    width: w,
    stroke: stroke,
    stack(
      dir: ltr,
      body,
      tail,
    ),
  )
}

// 下划线 value
#let rect-value(s, w: auto, stroke: (bottom: .5pt)) = {
  rect(
    height: 1.5em,
    inset: 5pt,
    width: w,
    stroke: stroke,
    align(center, s),
  )
}

#let meta-key = rect-key.with(tail: "：", w: 5em)
#let meta-value = rect-value.with(w: 80%)
#let info-key = rect-key.with(tail: "：", w: 7em)
#let info-value = rect-value.with(w: 80%)

#let en-meta-key = rect-key.with(tail: ":", w: 10em, use-distr: false)
#let en-meta-value = rect-value.with(stroke: none, w: 80%)
#let en-info-key = rect-key.with(tail: ":", w: 10em, use-distr: false)
#let en-info-value = rect-value.with(stroke: (bottom: .5pt), w: 80%)
