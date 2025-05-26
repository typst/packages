#import "zhnumber.typ": zhnumber-lower, zhnumber-upper
#import "pinyin.typ": pinyin
#import "zhlorem.typ": zhlorem

#let setup-base-fonts(
  cjk-serif-family: (
    "思源宋体 CN",
    "LXGW WenKai SC",
    "Songti SC",
    "SimSun",
  ),
  cjk-sans-family: (
    "思源黑体 CN",
    "Inter",
    "PingFang SC",
    "SimHei"
  ),
  cjk-mono-family: (
    "霞鹜文楷 Mono",
    "JetBrains Mono",
    "Source Code Pro",
    "Noto Sans Mono CJK SC",
    "Menlo",
    "Consolas",
  ),
  latin-serif-family: (
    "Times New Roman",
    "Georgia",
  ),
  latin-sans-family: (
    "Times New Roman",
    "Georgia",
  ),
  latin-mono-family: (
    "JetBrains Mono",
    "Consolas",
    "Menlo",
  ),
  first-line-indent: 1.5em,
  doc
) = {
  let serif-family = latin-serif-family + cjk-serif-family
  let sans-family = latin-sans-family + cjk-sans-family
  let mono-family = latin-mono-family + cjk-mono-family

  set text(
    lang: "zh",
    font: serif-family
  )

  show par: it => {
    set par(first-line-indent: (amount: first-line-indent, all: true))

    // TODO: 对齐工作

    it
  }

  show heading: x => {
    set text(font: sans-family)
    x
  }

  show strong: x => {
    set text(font: sans-family)
    x
  }

  show raw: x => {
    set text(font: mono-family)
    x
  }

  doc
}