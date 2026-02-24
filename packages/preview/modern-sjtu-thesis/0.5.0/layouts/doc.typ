#import "../utils/style.typ": ziti
#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "@preview/i-figured:0.2.4"
#import "@preview/itemize:0.1.2" as el

// 文稿设置，可以进行一些像页面边距这类的全局设置
#let doc(
  // documentclass 传入参数
  info: (:),
  doctype: "master",
  twoside: false,
  print: false,
  // 其他参数
  fallback: false, // 字体缺失时使用 fallback，不显示豆腐块
  fonts: (:),
  it,
) = {
  set page(margin: if doctype == "bachelor" {
    if print {
      (top: 2.54cm, bottom: 2.54cm, inside: 3.42cm, outside: 2.92cm)
    } else {
      (top: 2.54cm, bottom: 2.54cm, left: 3.17cm, right: 3.17cm)
    }
  } else {
    if print {
      (top: 3.5cm, bottom: 4cm, inside: 3cm, outside: 2.5cm)
    } else {
      (top: 3.5cm, bottom: 4cm, left: 2.5cm, right: 2.5cm)
    }
  })

  set text(hyphenate: false, font: ziti.songti)
  set text(lang: "zh", region: "cn")
  set par(leading: 20pt, first-line-indent: (amount: 2em, all: true))
  show: show-cn-fakebold

  show figure: set align(center)
  show table: set align(center)
  show figure.caption: set par(leading: 10pt, justify: false)

  set list(indent: 1em, body-indent: 0.65em)
  set enum(indent: 0.83em, body-indent: 0.45em)
  show: el.default-enum-list

  set document(
    title: info.title,
    author: info.name,
  )

  it
}
