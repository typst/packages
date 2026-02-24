#import "../utils/style.typ": ziti
#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "@preview/i-figured:0.2.4"

// 文稿设置，可以进行一些像页面边距这类的全局设置
#let doc(
  // documentclass 传入参数
  info: (:),
  twoside: false,
  // 其他参数
  fallback: false,  // 字体缺失时使用 fallback，不显示豆腐块
  fonts: (:),
  it,
) = {
  info = (
    title: "上海交通大学学位论文格式模板",
    author: "张三",
  ) + info

  if twoside {
    context {
      if calc.odd(counter(page).get().first()) {
        set page(margin: (top: 3.5cm, bottom: 4cm, left: 3cm, right: 2.5cm))
      } else {
        set page(margin: (top: 3.5cm, bottom: 4cm, left: 2.5cm, right: 3cm))
      }
    }
  } else {
    set page(margin: (top: 3.5cm, bottom: 4cm, left: 3cm, right: 2.5cm))
  }
  set text(hyphenate: false, font: ziti.songti)
  set par(leading: 20pt)

  show: show-cn-fakebold
  show figure: set align(center)
  show table: set align(center)

  show figure.caption: set par(leading: 10pt, justify: false)

  show heading: i-figured.reset-counters.with(extra-kinds: ("image",))
  show figure: i-figured.show-figure.with(extra-prefixes: (image: "img:"))
  show math.equation: i-figured.show-equation

  let fake-par = context {
    let b = par(box())
    b
    v(-measure(b + b).height)
  }
  show list: it => {
    it
    fake-par
  }
  show figure: it => {
    it
    fake-par
  }
  show enum: it => {
    it
    fake-par
  }

  set document(
    title: info.title,
    author: info.author,
  )

  it
}