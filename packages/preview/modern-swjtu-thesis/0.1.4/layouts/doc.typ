#import "../utils/style.typ": 字体

// 文稿设置，可以进行一些像页面边距这类的全局设置
#let doc(
  // documentclass 传入参数
  info: (:),
  fonts: (:),
  // 其他参数
  fallback: false,  // 字体缺失时使用 fallback，不显示豆腐块
  lang: "zh",
  margin: (x: 2.7cm, y: 2.6cm),
  it,
) = {
  // 0.  默认参数
  fonts = 字体 + fonts

  // 1.  默认参数
  info = (
    title: ("基于 Typst 的", "南京大学学位论文"),
    author: "张三",
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 3.  基本的样式设置
  set text(font: fonts.宋体, fallback: fallback, lang: lang)
  set page(margin: margin)

  // 4.  PDF 元信息
  set document(
    title: (("",)+ info.title).sum(),
    author: info.author,
  )

  // 5. 修复多个引用 cite 时的样式问题
  //    U+2013 -> U+002D
  show cite: it => {
    show "–": "-"
    it
  }

  it
}