#import "../consts.typ": *

// 字体 段落 加粗信息等设置
#let leading-space = 20pt
#let 单倍行距 = 0.25em
#let word-leading-space = leading-space - 1em
#let word-below-leading-space = leading-space - font-size.小四
#let above-leading-space(space: 0pt, word-space: word-leading-space) = {
  word-space + space
}
#let below-leading-space(space) = {
  word-below-leading-space + space
}

#let heading-1 = (
  above: 24pt,
  below: 18pt,
)

#let heading-2 = (
  above: 18pt,
  below: 6pt,
)

#let heading-3 = (
  above: 12pt,
  below: 6pt,
)

#let heading-4 = (
  above: 12pt,
  below: 6pt,
)