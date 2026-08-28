#import "@preview/pointless-size:0.1.3": zh, zihao
#import "@preview/cuti:0.4.0":*
#import "@preview/zh-kit:0.1.0": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/itemize:0.2.0" as el
#let styling(it)={
  show: show-cn-fakebold
  set page(numbering: "1")
  set text(lang: "zh", font: ("Times New Roman", "FangSong"), region: "cn", size: zh(5))

  set enum(
    numbering: numbly("{1:第一条}", "{2:（一）}", "{3:1.}", "{4:(1)}"),
    full: true,
    number-align: start,
    tight: true,
  )
  set block(breakable: true)
  set underline(offset: .2em)
  show link: underline

  show enum: el.paragraph-enum.with(
    label-width: 0em,
    line-indent: 0em,
    // label-indent: 0em,
    // body-indent: 0.5em,
    // hanging-indent: 0em,
    // indent: 2em,
    fill: (black, black, black),
    font: ("SimHei", "FangSong"),
    weight: ("bold", "thin", "thin"),
    is-full-width: false,
    body-format: (style: (font: ("SimHei", "FangSong"), weight: ("bold", "thin", "thin"))),
  )

  set figure(supplement: "图")
  set par(justify: false, first-line-indent: (amount: 2em, all: true), leading: 1.5em, spacing: 1.5em)
  it
}