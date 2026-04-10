// 文稿设置，可以进行一些像页面边距这类的全局设置
#import "../utils/style.typ": 字号, 字体
#import "../utils/header.typ": header-render, graduate-header-config
#import "../utils/custom-cuti.typ": show-cn-fakebold

#let doc(
  // documentclass 传入参数
  info: (:),
  doctype: "bachelor",
  degree: "academic",
  colored-cover: false,
  fonts: (:),
  // 其他参数
  fallback: false, // 字体缺失时使用 fallback，帮助诊断字体问题
  lang: "zh",
  margin: auto,
  it,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    (
      title: ("基于 Typst 的", "西北工业大学学位论文"),
      author: "张三",
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  // 2.2 设置页面边距
  let page-margin = if margin == auto {
    if doctype == "master" or doctype == "doctor" {
      // 研究生：上下2.54cm，左右2.5cm
      (top: 2.54cm, bottom: 2.54cm, left: 2.5cm, right: 2.5cm)
    } else {
      // 本科生：默认左右边距
      (x: 89pt)
    }
  } else {
    margin
  }

  // 3.  基本的样式设置
  // 启用中文伪粗体（模拟 Word 的加粗效果）
  show: show-cn-fakebold
  set text(fallback: fallback, lang: lang)
  set page(
    paper: "a4",
    margin: page-margin,
    // 研究生设置页眉基础配置
    ..(if doctype == "master" or doctype == "doctor" { graduate-header-config } else { (:) }),
  )

  // 4.  PDF 元信息
  set document(
    title: (("",) + info.title).sum(),
    author: info.author,
  )

  it
}
