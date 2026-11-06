#import "../style/font.typ": ziti, zihao
#import "../style/figures.typ": figures
#import "../style/enums.typ": enums
#import "@preview/cuti:0.3.0": show-cn-fakebold
#import "@preview/i-figured:0.2.4"

// 文稿设置，可以进行一些像页面边距这类的全局设置
#let doc(
  // documentclass 传入参数
  info: (:),
  // 其他参数
  fallback: false, // 字体缺失时使用 fallback，不显示豆腐块
  fonts: (:),
  it,
) = {
  info = (
    (
      title: "上海大学学位论文格式模板",
      author: "张三",
    )
      + info
  )

  set page(
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
    header: context {
      box(
        width: 100%,
        stroke: (bottom: 1pt),
        inset: (bottom: 4pt),
        text(
          "上海大学本科毕业论文（设计）",
          font: ziti.songti,
          size: zihao.wuhao,
        ),
      )
    },
    header-ascent: 0.3cm,
  )

  set text(
    font: ziti.songti,
    size: zihao.xiaosi,
    top-edge: "ascender",
    bottom-edge: "descender",
  )
  set par(
    first-line-indent: (amount: 2em, all: true),
    spacing: 0.3em,
    leading: 0.3em,
  )

  show raw: it => {
    set par(
      first-line-indent: (amount: 0em, all: true),
      spacing: 0.3em,
      leading: 0.3em,
    )
    it
  }

  show: show-cn-fakebold
  show: figures
  show: enums

  set document(
    title: info.title,
    author: info.author,
  )

  it
}
