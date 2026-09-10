// 西安电子科技大学硕士学位论文 Typst 模板 — 正文（mainmatter）
//
// 依据：docs/格式规格.md §2.2 / §2.3 / §2.5、docs/正文与后置部分规格.md
//
// 职责：
//   1. 正文页面：阿拉伯页码从 1 起；奇数页页眉 = 当前章名，偶数页 = 固定标题
//   2. 标题层级样式（章 / 节 / 小节 / 四级）
//   3. 图 / 表 / 公式的分章编号（格式规格 §2.5）
//
// 标题编写约定（编号由模板生成，不要手写）：
//   = 第一章 绪论        一级：章号用汉字手写在 body 里（Typst 的 numbering 无法产出「第一章」）
//   == 研究背景          二级：numbering "1.1"
//   === 国内研究现状      三级：numbering "1.1.1"
//   ==== 第一点          四级：numbering "（1）"，不进目录
//
// 官方实测（templet.pdf）：
//   章标题 16pt 黑体居中，基线 44.25mm（页顶起始时）
//   节标题 15pt 宋体加粗，x=30.00mm（不缩进）
//   正文 12pt，固定 20 磅行距，首行缩进 2 字符，首行基线 = 章标题 + 13.36mm
//   页眉：奇数页 `第一章 <章名>`，偶数页 `西安电子科技大学硕士学位论文`

#import "doc.typ": 基线偏移, 到内容区, 页眉, 默认页脚, 上边距, 页眉顶, 行距, 正文号, 上伸, 行隙
#import "../utils/style.typ": 字体

// ============================================================
// 1. 分章编号：图 / 表 / 公式
// ============================================================

// 章计数器（每遇到一级标题 +1）；图/表/公式各自在章内从 1 起
#import "../utils/counters.typ": 章号, 图号, 表号, 公式号

// 章号的中文数字（第一章 → 一）
#let 汉字序 = ("一", "二", "三", "四", "五", "六", "七", "八", "九", "十",
  "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十")

// 图的编号显示：`4.1`（章号用阿拉伯数字）
#let 显示图号(..) = numbering("1.1", ..章号.get().first(), 图号.get().first())
#let 显示表号(..) = numbering("1.1", ..章号.get().first(), 表号.get().first())
// 公式编号：`(3-32)`，官方用连字符（格式规格 §2.5）
#let 显示公式号(..) = "(" + str(章号.get().first()) + "-" + str(公式号.get().first()) + ")"

// ============================================================
// 1b. 图 / 表的题注与分章编号
// ============================================================
//
// 官方实测（templet.pdf）：
//   图题在图的**正下方**、表题在表的**正上方**，五号（10.5pt）居中
//   题注格式：`图 4.1 插图示例` / `表 4.1 表格示例`（分章编号，格式规格 §2.5）
//   表格线统一 0.5 磅单线条（三线表）

#let 题注样式(前缀, 章, 序, 内容) = {
  set text(font: 字体.宋体, size: 10.5pt, lang: "zh",
    top-edge: 基线偏移(行距, 10.5pt), bottom-edge: "baseline")
  [#{前缀} #{章}.#{序}]
  if 内容 != none { h(1em); 内容 }
}

#let 图规则(it) = context {
  let 序 = counter(figure.where(kind: image)).at(it.location()).first()
  let 章 = 章号.at(it.location()).first()
  let 内容 = if it.caption != none { it.caption.body } else { none }
  block(width: 100%, align(center, it.body))
  v(6pt)
  block(width: 100%, align(center, 题注样式("图", 章, 序, 内容)))
  v(12pt)
}

// 公式：分章编号 `(<章>-<序>)`，序号置于该行最右边（格式规格 §2.5，官方用连字符）
//
// 注意：不要用「show 规则里手写编号文本」的写法：那样编号只是画上去的一段文本，
// 公式本体没有 numbering，正文里 `@eq:xxx` 引用会直接报
// `cannot reference equation without numbering` —— 真实论文会写「由公式(2-1)」，
// 所以必须用真正的 `numbering`。（压力测试实测发现的缺口。）
// 图表编号 `(<章>.<序>)` 的「章.序」部分。给 figure 元素设置真正的 `numbering` 有三个好处：
//   ① 题注与索引共用同一算法，不会各算各的
//   ② @fig: / @tab: 引用能拿到正确编号
//   ③ 索引里不再退回 Typst 的全局默认序号（否则「图 1.1」会变成「图 1」）
#let 图表编号(..n) = context {
  numbering("1", 章号.get().first()) + "." + numbering("1", ..n)
}

#let 公式编号(..n) = context {
  let 章 = 章号.get().first()
  text(font: ("Times New Roman",),
    "(" + str(章) + "-" + numbering("1", ..n) + ")")
}

// 正文引用：参考文献编号以右上角方括号标注（格式规格 §2.5）。
//   · .bib 模式：正文写 `#cite(<bibkey>)`，Typst 生成 `[1]`，这里提升为上标
//   · 手工条目模式：可直接写 `#引用(1)` / `#引用(2, 3)`
// 注意：`bibliography()` 只收录**被 cite 引用过**的条目；只用 `#引用()` 的话参考文献会是空的。
show cite: it => super(text(font: ("Times New Roman",), size: 0.9em, it))

// 正文引用（手工编号，配 `entries:` 使用）：右上角方括号
#let 引用(..序号) = super(text(font: ("Times New Roman",), size: 0.9em,
  "[" + 序号.pos().map(str).join(",") + "]"))

#let 表规则(it) = context {
  let 序 = counter(figure.where(kind: table)).at(it.location()).first()
  let 章 = 章号.at(it.location()).first()
  let 内容 = if it.caption != none { it.caption.body } else { none }
  block(width: 100%, align(center, 题注样式("表", 章, 序, 内容)))
  v(6pt)
  block(width: 100%, align(center, it.body))
  v(12pt)
}

// ============================================================
// 2. 页眉 / 页脚
// ============================================================

// 正文页眉：奇数页取「当前章名」，偶数页取固定标题。
// 用 query 找当前位置之前最后一个一级标题。
#let 正文页眉(固定标题) = context {
  let 页 = here().page()
  let 文字 = if calc.odd(页) {
    // 注意：页眉里的 here() 位于页面内容之前，用 selector.before() 会漏掉
    // 「章标题与本页同页」的情况（首个正文页）。改为按页号取最后一个一级标题。
    let 候选 = query(heading.where(level: 1))
      .filter(h => h.location().page() <= 页)
    // 正文首页之前可能还没有任何一级标题（首页/空白页），退回固定标题
    if 候选.len() == 0 { 固定标题 } else { 候选.last().body }
  } else {
    固定标题
  }
  页眉(文字)
}

// ============================================================
// 3. 标题样式
// ============================================================

// 章标题：黑体 16pt 居中，段前 24 磅、段后 18 磅；每章从奇数页起
//
// 注意：两个间距的写法不同，这是实测出来的：
//   · 段前用显式 v()（强间距）—— Typst 的 block(above:) 在页顶会被折叠，
//     而官方 Word/LaTeX 在章首页页顶照常保留段前（格式规格 §2.7）
//   · 段后用 block(below:)（可折叠间距）—— 用 v() 会与后续段落的 par(spacing)
//     叠加，实测章标题→正文会多出 3.68pt（0.49mm→1.19mm）
#let 章标题样式(body) = {
  // 每章从奇数页起（格式规格 §2.4）：无条件插入，已在奇数页时不产生多余空白页。
  // 正文首页也因此必然落在奇数页（与官方一致：目录 p21 → 第一章 p23）
  // weak: true —— 页面还是空的时候不产生多余空白页
  pagebreak(to: "odd", weak: true)
  v(24pt)
  block(width: 100%, below: 18pt, align(center, {
    set text(font: 字体.黑体, size: 16pt,
      top-edge: 基线偏移(行距, 16pt), bottom-edge: "baseline")
    body
  }))
}

// 节标题：宋体加粗 15pt，不缩进，段前 18 磅、段后 12 磅
// 段前/段后用 block(above/below:)（可折叠），与相邻段落的 par(spacing) 取最大值，
// 正好得到标称值；这与 格式规格 §2.7 一致（节/小节可用 block 间距）
#let 节标题样式(body, number) = block(above: 18pt, below: 12pt, {
  set text(font: 字体.宋体, size: 15pt, weight: "bold",
    top-edge: 基线偏移(行距, 15pt), bottom-edge: "baseline")
  if number != none { number; h(0.6em) }
  body
})

// 小节标题：宋体加粗 14pt，缩进 2 字符，段前 12 磅、段后 6 磅
#let 小节标题样式(body, number) = block(above: 12pt, below: 6pt, {
  set text(font: 字体.宋体, size: 14pt, weight: "bold",
    top-edge: 基线偏移(行距, 14pt), bottom-edge: "baseline")
  pad(left: 2em, {
    if number != none { number; h(0.6em) }
    body
  })
})

// 四级标题：宋体 12pt，`（1）` 形式，不进目录
#let 四级标题样式(body, number) = block(above: 6pt, below: 6pt, {
  set text(font: 字体.宋体, size: 12pt,
    top-edge: 基线偏移(行距, 12pt), bottom-edge: "baseline")
  if number != none { number; h(0.4em) }
  body
})

// ============================================================
// 4. 正文文档主函数
// ============================================================

#let mainmatter(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  header-title: "西安电子科技大学硕士学位论文",
  it,
) = {
  let 字体集 = 字体 + fonts

  // 注意：顺序很关键，实测踩过两次坑：
  //   1. `set page` / `counter.update` 不能写在 `show heading` 里 —— show 规则的
  //      作用域只覆盖它自己产出的内容，后续页拿不到设置（页眉页脚会整体消失）。
  //   2. 页码复位也不能写成「mainmatter 开头 + 章标题里再来一次」：首个章还要
  //      `pagebreak(to: "odd")`，会把复位点挤到多出来的空白页上，正文首页变成 2。
  //   正确顺序：先在目录结束后补齐空白页（正文从奇数页起），再设页面与页码 ——
  //   这样它们正好落在正文首页上。
  // 注意：这里 `here().page()` 返回的是「正文本来会落在哪一页」，不是「目录的最后一页」。
  //    实测：目录占 p21（奇数），但这里取到的是 22 —— 因为目录页函数收尾时已经越到下一页。
  //    所以要判的是「正文自然起始页是偶数 → 补一张空白页把它顶到奇数页」。
  context if calc.even(here().page()) {
    // 目录结束在奇数页时补一张空白页，使正文从奇数页起（格式规格 §2.4）。
    // 按官方习惯：空白页**保留页眉与页码** —— 官方 p24 / p34 实测都是固定页眉 + 页码。
    // 这里补的页落在偶数页 → 页眉用固定标题；页码续前置部分的罗马数字，
    // 正文的阿拉伯页码从下一页（正文首页）重新开始。
    page(numbering: "I", header: 页眉(header-title))[]
  }

  set page(
    numbering: "1",
    header-ascent: 上边距 - 页眉顶,
    footer-descent: 0mm,
    header: 正文页眉(header-title),
    footer: 默认页脚,
  )

  // 正文段落：宋体 12pt，固定 20 磅行距，首行缩进 2 字符，两端对齐
  set text(font: 字体集.宋体, size: 正文号, lang: "zh",
    top-edge: 上伸, bottom-edge: "baseline")
  set par(leading: 行隙, spacing: 行隙, justify: true, first-line-indent: (amount: 2em, all: true))
  counter(page).update(1)

  // 标题编号由模板生成，用户不要手写编号：
  //   一级 无编号（章号「第一章」手写在 body 里，Typst 的 numbering 产不出「第一章」）
  //   二级 1.1、三级 1.1.1、四级 （1）
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() <= 1 { none }
    else if n.len() == 2 { numbering("1.1", ..n) }
    else if n.len() == 3 { numbering("1.1.1", ..n) }
    else { numbering("（1）", n.last()) }
  })
  // 四级标题不进目录（格式规格 §2.4）
  show heading.where(level: 4): set heading(outlined: false)

  // 图 / 表题注与分章编号
  show figure.where(kind: image): 图规则
  show figure.where(kind: table): 表规则
  // 公式：分章编号，可被 @eq: 引用（序号由 Typst 右对齐排版）
  set math.equation(numbering: 公式编号)

  // 表格线：官方《撰写要求》「表格线统一用单线条，磅值 0.5 磅」。
  // Typst 的 table 默认线宽是 1pt，比要求粗一倍，故在此统一。
  show table: set table(stroke: 0.5pt)
  // 图 / 表：同样需要真正的 numbering，索引与引用才拿得到「章.序」
  set figure(numbering: 图表编号)

  // 章计数器：每个一级标题 +1；同时重置图/表/公式的章内计数
  show heading.where(level: 1): it => {
    // 注意：这里**不要**再插一次 `pagebreak(to: "odd")`：
    //    `章标题样式` 里已经有一次 `pagebreak(to: "odd", weak: true)`。
    //    两次叠加时前面那次（非 weak）会先执行，在「当前页本来就是空的奇数页」时
    //    白跳一页 —— 实测让模板单独使用（没有前置部分）时首个章被推到第 3 页，
    //    p1、p2 全空。有前置部分时恰好看不出来，所以这个 bug 藏了很久。
    章号.update(n => n + 1)
    图号.update(0)
    表号.update(0)
    公式号.update(0)
    counter(math.equation).update(0)
    // Typst 的 figure 计数器不会自动按章重置，必须显式归零，
    // 否则第二章的图会编成「2.27」而不是「2.1」
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    章标题样式(it.body)
  }
  show heading.where(level: 2): it => 节标题样式(it.body,
    numbering(it.numbering, ..counter(heading).at(it.location())))
  show heading.where(level: 3): it => 小节标题样式(it.body,
    numbering(it.numbering, ..counter(heading).at(it.location())))
  show heading.where(level: 4): it => 四级标题样式(it.body,
    numbering(it.numbering, ..counter(heading).at(it.location())))

  it
}
