// 西安电子科技大学本科毕业设计（论文）Typst 模板 — 前置与后置页面

#import "layout.typ": *
#import "../utils/style.typ": 字体
#import "../utils/bilingual-bib.typ": 双语文献

#let 封面文字(内容, x, y, width: auto, size: 12pt, font: 字体.宋体, alignment: left, weight: "regular") = {
  place(top + left, dx: x, dy: y,
    box(width: width, align(alignment, text(font: font, size: size, weight: weight,
      top-edge: "baseline", bottom-edge: "baseline", 内容))))
}

#let cover(info: (:), fonts: (:), enabled: true) = {
  if enabled {
    let 字体集 = 字体 + fonts
    let 题目 = if type(info.title) == str { (info.title,) } else { info.title }
    let 导师 = if type(info.supervisor) == str { info.supervisor } else { info.supervisor.join("　") }
    page(
      paper: "a4", width: 纸张宽, height: 纸张高, margin: 0mm,
      header: none, footer: none, numbering: none,
    )[
      #封面文字("班　级", 129.1mm, 28.2mm, size: 12pt, font: 字体集.宋体, weight: "bold")
      #place(top + left, dx: 146mm, dy: 29.1mm, line(length: 28.8mm, stroke: 0.5pt))
      #封面文字(info.class-id, 146mm, 28.2mm, width: 28.8mm, alignment: center,
        size: 12pt, font: 字体集.宋体, weight: "bold")
      #封面文字("学　号", 129.1mm, 36.5mm, size: 12pt, font: 字体集.宋体, weight: "bold")
      #place(top + left, dx: 146mm, dy: 37.4mm, line(length: 28.8mm, stroke: 0.5pt))
      #封面文字(info.student-id, 146mm, 36.5mm, width: 28.8mm, alignment: center,
        size: 12pt, font: 字体集.宋体, weight: "bold")

      // 校名书法字与校徽取自官方封面（图片形式随包分发，保证在未装学校标准字的机器上
      // 也能正确呈现；版权归学校所有，见 docs/本科规格.md「封面」一节）。
      #place(top + left, dx: 77.7mm, dy: 49.5mm, image("assets/xdu-name.png", width: 64.5mm))
      #封面文字("本科毕业设计论文", 30mm, 84.2mm, width: 150mm, alignment: center,
        size: 42pt, font: 字体集.黑体)
      #place(top + left, dx: 89mm, dy: 107.2mm, image("assets/xdu-emblem.png", width: 42.1mm))

      // 填写横线：官方封面共 6 条 —— 题目每行一条 + 字段四行各一条，
      // 均为 x 82.1~166.8mm（宽 84.7mm），题目与字段值都居中于横线。
      #for (i, 行) in 题目.enumerate() {
        place(top + left, dx: 82.1mm, dy: 172.9mm + 16.5mm * i,
          line(length: 84.7mm, stroke: 0.5pt))
        封面文字(行, 82.1mm, 171.7mm + 16.5mm * i, width: 84.7mm, alignment: center,
          size: 16pt, font: 字体集.黑体)
      }
      #封面文字("题　　目", 53.6mm, 171.7mm, size: 16pt, font: 字体集.宋体, weight: "bold")

      #let 字段 = (
        ("学　　院", info.department),
        ("专　　业", info.major),
        ("学生姓名", info.author),
        ("导师姓名", 导师),
      )
      #for (i, (标签, 值)) in 字段.enumerate() {
        let y = 204.8mm + 16.5mm * i
        封面文字(标签, 53.6mm, y, size: 16pt, font: 字体集.宋体, weight: "bold")
        place(top + left, dx: 82.1mm, dy: y + 1.1mm,
          line(length: 84.7mm, stroke: 0.5pt))
        封面文字(值, 82.1mm, y, width: 84.7mm, alignment: center,
          size: 15pt, font: 字体集.宋体)
      }
    ]
  }
}

#let abstract(info: (:), fonts: (:), body: none, keywords: ()) = {
  let 字体集 = 字体 + fonts
  let 正文 = if body != none { body } else { info.abstract }
  let 关键词 = if keywords != () { keywords } else { info.keywords }
  set page(..本科页面参数(纯题目(info), numbering: "i", 当前标题: "摘要"))
  前置编号开始.update(true)
  页面标题([摘#h(1em)要])
  正文样式({
    正文
    parbreak()
    v(行距)
    text(font: 字体集.黑体, weight: "bold", "关键词：")
    关键词.join("　")
  })
}

#let abstract-en(info: (:), fonts: (:), body: none, keywords: ()) = {
  let 字体集 = 字体 + fonts
  let 正文 = if body != none { body } else { info.abstract-en }
  let 关键词 = if keywords != () { keywords } else { info.keywords-en }
  set page(..本科页面参数(纯题目(info), numbering: "i", 当前标题: "ABSTRACT"))
  页面标题("ABSTRACT")
  正文样式({
    set text(font: 字体集.宋体, lang: "en")
    正文
    parbreak()
    v(行距)
    text(weight: "bold", "Keywords: ")
    关键词.join("; ")
  }, lang: "en", indent: true)
}

#let outline-page(info: (:), fonts: (:), title: "目录", depth: 3) = {
  let 字体集 = 字体 + fonts
  set page(..本科页面参数(纯题目(info), numbering: "i", 当前标题: title))
  页面标题([目#h(1em)录])
  set text(font: 字体集.宋体, size: 12pt,
    top-edge: 正文上伸, bottom-edge: "baseline")
  set par(leading: 行隙, spacing: 行隙)
  show outline.entry: it => context {
    let lv = calc.min(it.level, depth)
    let loc = it.element.location()
    let 编号方式 = loc.page-numbering()
    let 页码 = if 编号方式 == none { str(loc.page()) } else { numbering(编号方式, loc.page()) }
    let nums = counter(heading).at(loc)
    // 只有真正带编号的标题才加章号/节号：附录、参考文献、致谢等后置部分
    // 的标题以 numbering: none 登记，目录条目必须与页面一致，不加任何编号。
    let 编号 = if it.element.numbering == none {
      none
    } else if lv == 1 {
      "第" + 章序(nums.first()) + "章"
    } else {
      numbering(if lv == 2 { "1.1" } else { "1.1.1" }, ..nums)
    }
    grid(
      columns: (if lv == 1 { 0mm } else if lv == 2 { 6mm } else { 16mm }, auto, 1fr, auto),
      column-gutter: 1mm,
      [],
      if 编号 == none {
        text(weight: if lv == 1 { "bold" } else { "regular" }, it.element.body)
      } else {
        text(weight: if lv == 1 { "bold" } else { "regular" }, [#编号 #it.element.body])
      },
      it.fill,
      text(页码),
    )
  }
  outline(title: none, depth: depth)
}

#let acknowledgement(info: (:), fonts: (:), body: none, title: "致谢") = {
  set page(..本科页面参数(纯题目(info), numbering: "1", 当前标题: title))
  页面标题([致#h(1em)谢], outlined: true)
  正文样式(if body != none { body } else { info.acknowledgement })
}

#let references(
  info: (:), fonts: (:), title: "参考文献", body: none, bib: none, entries: none, 双语: true,
) = {
  let 字体集 = 字体 + fonts
  let 条目 = if entries != none { entries } else { info.at("references", default: ()) }
  set page(..本科页面参数(纯题目(info), numbering: "1", 当前标题: title))
  页面标题(title, outlined: true)
  let 上伸 = 基线偏移(10.5pt)
  set text(font: 字体集.宋体, size: 10.5pt, top-edge: 上伸, bottom-edge: "baseline")
  set par(leading: 20.47pt - 上伸, spacing: 20.47pt - 上伸, justify: true)
  show bibliography: set text(font: 字体集.宋体, size: 10.5pt,
    top-edge: 上伸, bottom-edge: "baseline")
  if body != none {
    body
  } else if bib != none {
    let 文献 = bibliography(bib, style: "gb-7714-2015-numeric", title: none)
    if 双语 { 双语文献(文献) } else { 文献 }
  } else {
    set par(hanging-indent: 9mm, first-line-indent: (amount: 0pt, all: true))
    for (i, e) in 条目.enumerate() {
      [#text(font: ("Times New Roman",), "[" + str(i + 1) + "]") #e]
      parbreak()
    }
  }
}

#let 附录题注(前缀, 字母, 序, 内容) = {
  set text(font: 字体.宋体, size: 10.5pt,
    top-edge: 基线偏移(10.5pt), bottom-edge: "baseline")
  [#前缀 #字母#序]
  if 内容 != none { h(0.75em); 内容 }
}

#let 附录图规则(it, 字母, kind) = context {
  let 序 = counter(figure.where(kind: kind)).at(it.location()).first()
  let 内容 = if it.caption != none { it.caption.body } else { none }
  if kind == image {
    block(width: 100%, align(center, it.body))
    v(6pt)
    block(width: 100%, align(center, 附录题注("图", 字母, 序, 内容)))
  } else {
    block(width: 100%, align(center, 附录题注("表", 字母, 序, 内容)))
    v(6pt)
    block(width: 100%, align(center, it.body))
  }
  v(12pt)
}

#let appendix(info: (:), fonts: (:), title: none, body: none) = {
  附录号.step()
  context {
    let n = 附录号.get().first()
    let 字母 = 附录序(n)
    let 页标题 = if title == none { "附录 " + 字母 } else { "附录 " + 字母 + " " + title }
    pagebreak(to: "odd", weak: true)
    set page(..本科页面参数(纯题目(info), numbering: "1", 当前标题: 页标题))
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    set figure(numbering: (..nums) => 字母 + numbering("1", ..nums))
    set math.equation(numbering: (..nums) => "(" + 字母 + "-" + numbering("1", ..nums) + ")")
    show figure.where(kind: image): it => 附录图规则(it, 字母, image)
    show figure.where(kind: table): it => 附录图规则(it, 字母, table)
    页面标题(页标题, outlined: true)
    正文样式(if body != none { body } else { info.at("appendix", default: [请在此撰写附录内容。]) })
  }
}
