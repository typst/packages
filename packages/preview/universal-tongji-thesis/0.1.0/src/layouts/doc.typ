#import "../utils/str.typ": to-normal-str
#import "../utils/fix-cjk-linebreak.typ": fix-cjk-linebreak
#import "../utils/zh-aio.typ":*
#import "../utils/style.typ":字体, 字号
// 文稿设置，可以进行一些像页面边距这类的全局设置
#let doc(
  // documentclass 传入参数
  info: (:),
  // 其他参数
  fallback: false, // 字体缺失时使用 fallback，不显示豆腐块
  lang: "zh",
  fix-cjk: true,
  fix-cjk-debug: false,
  margin: (top: 2.54cm + 6pt, bottom: 2.54cm, left: 3.17cm, right: 3.17cm),
  it,
) = {
  set text(top-edge: "ascender", bottom-edge: "descender", region: "CN", lang: "zh", font: 字体.宋体, zh(-4))
  set par(leading: 0em, spacing: 0em, justify: true, first-line-indent: (amount: 2em, all: true))
  show:zh-format
  // show:show-cn-fakebold
  // 1.  默认参数
  // show heading.where(level: 1):it=> {
  //   set align(center)
  //   set block(below: 0em, above: 0em, spacing: 0em, stroke: red, inset: 0pt)
  //   set text(font: fonts.hei, zh(3))
  //   v(24pt)
  //   vl()
  //   strong(it)
  //   vl()
  //   v(18pt)
  // }
  //
  set page(footer: context {
    set text(size: zh(-5), font: 字体.新罗马)
    let p = counter(page).get().at(0)
    let pagealign = center
    align(pagealign, counter(page).display())
  })
  show heading:it=> block(below: 0em, above: 0em, sticky: false)[
    #if it.numbering != none [
      #counter(heading).display() #strong(it.body)
    ] else {
      it
    }
  ]
  show heading.where(level: 1):it=>block(width: 100%, below: 0em, above: 0em)[
    #{
      set align(center)
      set text(font: "SimHei", zh(3))
      v(18pt)
      vl()
      it
      vl()
      v(16pt)
    }
  ]
  show heading.where(level: 2):it=> {
    let index = counter(heading).get().at(1)
    set align(left)
    set block(below: 0em, above: 0em, spacing: 0em, inset: 0pt)
    set text(font: "SimHei", zh(-3), weight: "regular")
    if index == 1 {
      v3l()
    } else {
      // v(24pt)
      v(2 * 15.6pt + 12pt + 6pt - zh(-3))
    }
    it
    v3l()
    v(4pt)
  }
  show heading.where(level: 3):it=> {
    set align(left)
    set block(below: 0em, above: 0em, spacing: 0em, inset: 0pt)
    set text(font: "SimHei", zh(4), weight: "regular")
    v(9pt)
    v3l()
    it
    v3l()
    v(4pt)
  }
  show heading.where(level: 4):it=> {
    set align(left)
    set block(below: 0em, above: 0em, spacing: 0em, inset: 0pt)
    set text(font: "SimHei", zh(4), weight: "regular")
    v3l()
    it
    v3l()
  }
  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 3.  基本的样式设置
  set text(fallback: fallback, lang: lang)
  set page(margin: margin, paper: "a4")
  // 4.  PDF 元信息
  set document(title: to-normal-str(src: info.title.cn), author: info.author.cn)

  show: if fix-cjk {
    fix-cjk-linebreak.with(debug: fix-cjk-debug)
  } else {
    it
  }

  it
}