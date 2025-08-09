#import "../style/font.typ": ziti, zihao
#import "../style/figures.typ": figures, preset
#import "../style/enums.typ": enums
#import "@preview/cuti:0.3.0": show-cn-fakebold

// 文稿设置，可以进行一些像页面边距这类的全局设置
#let doc(
  info: (:),
  fallback: false,
  it,
) = context {
  set page(
    margin: (top: 2.8cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
    header: context {
      box(
        width: 100%,
        stroke: (bottom: 0.5pt),
        inset: (bottom: 4pt),
        text(
          "上海大学本科毕业论文（设计）",
          font: ziti.songti.get(),
          size: zihao.wuhao,
          top-edge: 0.8em,
          bottom-edge: -0.2em,
        ),
      )
    },
    header-ascent: 0.6cm,
  )

  set text(
    font: ziti.songti.get(),
    size: zihao.xiaosi,
    top-edge: 0.8em,
    bottom-edge: -0.2em,
    fallback: fallback,
  )
  set par(
    first-line-indent: (amount: 2em, all: true),
    spacing: 0.3em,
    leading: 0.3em,
  )

  show raw: it => context {
    set text(font: ziti.dengkuan.get())
    if it.block == true {
      set par(
        first-line-indent: (amount: 0em, all: true),
        spacing: 0.3em,
        leading: 0.3em,
      )
      it
    } else {
      it
    }
  }

  show ref.where(form: "page"): set ref(supplement: [页])

  show: preset
  show: figures
  show: enums
  show: show-cn-fakebold

  set document(
    title: info.title,
    author: info.name,
  )

  it
}
