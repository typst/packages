// 西安电子科技大学本科毕业设计（论文）Typst 模板 — 独立版式核心
//
// 数值唯一出处：docs/本科规格.md；实现证据：xduugthesis.cls。
// 本科与硕士的页面几何、行距、页眉页码均不同，本文件不得导入 layouts/ 下的硕士版式。

#import "../utils/style.typ": 字体
#import "../utils/counters.typ": 汉字序

#let 纸张宽 = 210mm
#let 纸张高 = 297mm
#let 上边距 = 30mm
#let 下边距 = 20mm
#let 内侧 = 40mm // 手册内侧 30mm + 装订线 10mm
#let 外侧 = 20mm
#let 版心宽 = 150mm
#let 版心高 = 247mm
#let 页眉顶 = 20mm
#let 页眉基线 = 21.7mm
#let 页眉线 = 23.15mm

#let 正文号 = 12pt
// 官方类在 12pt 正文下使用 linespread=1.625；55 页实物论文相邻基线实测为 23.40pt。
// 这对应 Word 的 1.5 倍行距。Typst 的 leading 是行盒间隙，不能直接写 23.4pt。
#let 行距 = 23.4pt
#let 基线偏移(字号) = 0.88 * 字号
#let 正文上伸 = 基线偏移(正文号)
#let 行隙 = 行距 - 正文上伸

#let 附录号 = counter("xdu-bachelor-appendix")
#let 前置编号开始 = state("xdu-bachelor-front-numbering", false)

#let 章序(n) = 汉字序.at(n - 1, default: str(n))
#let 附录序(n) = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters().at(n - 1, default: str(n))

#let 纯题目(info) = if type(info.title) == str { info.title } else { info.title.join("") }

#let 单线页眉(题目, 当前标题: none) = context {
  let 页 = here().page()
  let 中间 = if calc.even(页) {
    题目
  } else if 当前标题 != none {
    当前标题
  } else {
    let 候选 = query(heading.where(level: 1)).filter(h => h.location().page() <= 页)
    if 候选.len() == 0 {
      题目
    } else {
      let h = 候选.last()
      let n = counter(heading).at(h.location()).first()
      [第#章序(n)章 #h.body]
    }
  }
  let 数字 = counter(page).display()
  box(height: 0pt, width: 100%, {
    set text(font: 字体.宋体, top-edge: "baseline", bottom-edge: "baseline")
    place(top + center, dy: 页眉基线 - 页眉顶,
      text(size: 10.5pt, 中间))
    if calc.odd(页) {
      place(top + right, dy: 页眉基线 - 页眉顶,
        text(size: 9pt, 数字))
    } else {
      place(top + left, dy: 页眉基线 - 页眉顶,
        text(size: 9pt, 数字))
    }
    place(top + left, dy: 页眉线 - 页眉顶,
      line(length: 100%, stroke: 0.75pt))
  })
}

#let 本科页面参数(题目, numbering: "i", 当前标题: none) = (
  paper: "a4",
  width: 纸张宽,
  height: 纸张高,
  margin: (top: 上边距, bottom: 下边距, inside: 内侧, outside: 外侧),
  header-ascent: 上边距 - 页眉顶,
  footer-descent: 0mm,
  header: 单线页眉(题目, 当前标题: 当前标题),
  footer: none,
  numbering: numbering,
)

#let 页面标题(标题, outlined: false, bookmarked: true) = {
  let 字号 = 16pt
  let 上伸 = 基线偏移(字号)
  v(42.8mm - 上边距 - 上伸)
  block(width: 100%, below: 25.4pt, align(center, {
    show heading: it => {
      set text(font: 字体.黑体, size: 字号, weight: "regular",
        top-edge: 上伸, bottom-edge: "baseline")
      it.body
    }
    heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, 标题)
  }))
}

#let 正文样式(body, lang: "zh", indent: true) = {
  set text(font: 字体.宋体, size: 正文号, lang: lang,
    top-edge: 正文上伸, bottom-edge: "baseline")
  set par(
    leading: 行隙,
    spacing: 行隙,
    justify: true,
    first-line-indent: if indent { (amount: 2em, all: true) } else { 0pt },
  )
  body
}

#let doc(info: (:), fonts: (:), fallback: false, lang: "zh", it) = {
  let 字体集 = 字体 + fonts
  set text(font: 字体集.宋体, size: 正文号, lang: lang, fallback: fallback,
    top-edge: 正文上伸, bottom-edge: "baseline")
  set par(leading: 行隙, spacing: 行隙, justify: true,
    first-line-indent: (amount: 2em, all: true))
  set document(title: 纯题目(info), author: info.author)
  let 默认页面 = 本科页面参数(纯题目(info)) + (
    header: context if 前置编号开始.get() { 单线页眉(纯题目(info)) },
  )
  set page(..默认页面)
  it
}
