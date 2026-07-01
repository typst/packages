#import "info.typ": *
#import "font.typ": *
#import "word_spacing.typ": above-leading-space, below-leading-space
#import "@preview/cjk-spacer:0.2.0": cjk-spacer

#let common-set(info, body) = {
  set par(first-line-indent: (amount: 2em, all: true), justify: true)
  set text(region: "cn", lang: "zh", font: info.at(info-keys-private.字体).宋体, size: font-size.小四)
  // set text(top-edge: "ascender", bottom-edge: "descender")
  set text(top-edge: 0.8em, bottom-edge: -0.2em)
  set strong(delta: info.at(info-keys.加粗粗度))
  set list(indent: 2em, body-indent: 0.7em)
  set enum(indent: 2em, body-indent: 0.5em)
  show: cjk-spacer
  body
}

#let commen-space-set(body) = {
  set par(
    first-line-indent: (amount: 2em, all: true),
    justify: true,
    leading: above-leading-space(),
    spacing: above-leading-space(),
  )
  body
}

#let 其他-space-set(body) = {
  set par(leading: 1em, spacing: 1em, justify: true)
  body
}

#let noindent = context h(-par.first-line-indent.amount)

// 标记论文修改内容
// 通过 thesis 中注入的 <info> 元数据读取论文模式
// 仅在「修订模式」下将内容标红，其余模式（电子档定稿模式、打印模式）原样显示
// 用法: #revise[修改的内容]
#let revise(body) = context {
  let infos = query(<info>)
  // infos.len() > 0是因为info包含abstract，而在abstract里面可能会调用revise，此时info是空的，所以默认不标红，然后下次编译再重新设置
  let silent = if infos.len() > 0 {
    infos.first().value.at(info-keys.论文模式) != 论文模式.修订模式
  } else {
    true
  }
  if silent {
    body
  } else {
    [
      #set text(fill: red)
      #body
    ]
  }
}
