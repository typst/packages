#import "../utils/style.typ": fix-smartquote

// 文稿设置，可以进行一些像页面边距这类的全局设置
#let doc(
  // documentclass 传入参数
  info: (:),
  // 其他参数
  fallback: false, // 字体缺失时使用 fallback，不显示豆腐块
  lang: "zh", // 语言设置
  margin: (left: 3cm, top: 3cm, right: 2.5cm, bottom: 2.5cm), // 页面边距
  it,
) = {
  // 1.  默认参数
  info = ((title: ("基于 Typst 的", "厦门大学学位论文"), author: "张三") + info)

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 3.  基本的样式设置
  set text(fallback: fallback, lang: lang)
  set page(margin: margin)
  show: fix-smartquote

  // 4.  PDF 元信息
  set document(title: (("",) + info.title).sum(), author: info.author)

  it
}
