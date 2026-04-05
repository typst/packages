// 文稿设置，可以进行一些像页面边距这类的全局设置
#import "../utils/style.typ": show-cn-fakebold
#import "../utils/indent.typ": fake-par

#let doc(
  // documentclass 传入参数
  info: (:),
  // 其他参数
  fallback: true,  // 字体缺失时使用 fallback，不显示豆腐块
  lang: "zh",
  margin: 3cm,
  it,
) = {
  // 1.  默认参数
  info = (
    title: ("基于 Typst 的", "中国地质大学学位论文"),
    author: "张三",
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 3.  基本的样式设置
  show: show-cn-fakebold
  set text(lang: lang)
  set page(margin: margin)
  show regex("[\p{sc=Hani} 。 ； ， ： “ ”（ ） 、 ？ 《 》] [\p{sc=Hani} 。 ； ， ： “ ”（ ） 、 ？ 《 》]"): it => {
    let (a, _, b) = it.text.clusters()
    a + b
  }

  // show list: it => {
  //   it
  //   fake-par
  // }
  // show figure: it => {
  //   it
  //   fake-par
  // }
  // show enum: it => {
  //   it
  //   fake-par
  // }
  // show math.equation.where(block: true): it=>{
  //   it
  //   fake-par
  // }
  show link: it => {
    underline(text(rgb(0, 0, 255), it))
  }

  // 4.  PDF 元信息
  set document(
    title: (("",)+ info.title).sum(),
    author: info.author,
  )

  it
}