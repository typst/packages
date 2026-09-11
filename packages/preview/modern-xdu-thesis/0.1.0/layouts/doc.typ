// 西安电子科技大学硕士学位论文 Typst 模板 — 全局页面核心
//
// 依据：docs/格式规格.md §2 / §2.7、dev/probe-header-footer.typ 已验证写法
// - 上30 / 内30 / 外25 mm；版心 155 × 240.93 mm（下边界 270.93mm，见下方常量注释）
// - 固定行距 20 磅：基线偏移 Δ + 行隙 leading = 20pt
// - 页眉帧顶 = 上边距 − header-ascent；页脚帧顶 = 版心下边界
// - 双横线：两条 0.5pt、中心距 1pt、宽 = 正文宽 155mm（不外扩）
//
// 把所有度量常量都做成可导出的形式，方便 pages/ 下各页直接复用。

#import "../utils/style.typ": 字号, 字体

// ============================================================
// 1. 度量常量（可导出）
// ============================================================

// 页面
#let 纸张宽 = 210mm
#let 纸张高 = 297mm

#let 上边距 = 30mm            // 格式规格 §2.1（自内容框顶量起；等效官方 2cm + headheight 31pt）

// 版心下边界（与真实论文对照后裁定，见 docs/与真实论文对照.md §4）
//   官方 LaTeX 2024.04：2cm + headheight 31pt + \textheight 240mm = 270.93mm
//   已过检的真实论文：top 3.14cm + 240.6mm ≈ 272mm
//   官方 templet.pdf 实测「正文最底那行基线」= 270.89mm —— 与 270.93 只差 0.04mm
// 旧值 277mm（下边距 2cm / 版心 247mm）按规范文字取值，会让每页多排一行（35 行而非 34 行），
// 长文档总页数系统性偏少，故改为跟随两份官方 LaTeX 实现。
#let 版心下边界 = 270.93mm
#let 版心高 = 版心下边界 - 上边距      // = 240.93mm
#let 下边距 = 纸张高 - 版心下边界        // = 26.07mm（供 set page(margin:) 用）

#let 内侧   = 30mm            // 双面 inside = 30mm（2.5cm + 0.5cm 装订线）
#let 外侧   = 25mm
#let 版心宽 = 155mm           // 210 − 30 − 25

// place(top + left, dx:) 在文档流里默认相对**内容区**而非页面原点。
// 在文档中给定 y 时要减掉上边距；下面统一从绝对页坐标得到「相对内容区的 y」。
#let 到内容区(绝对y) = 绝对y - 上边距

// 前置部分用**页面绝对坐标**排版：规格文档里的 x 都是页面绝对坐标，
// 而 place(top + left, dx:) 相对的是内容区（奇数页左边界 = 内侧 30mm）。
// 把内容整体左移 内侧，容器原点就与页面原点对齐，dx 即可直接写绝对值，
// 同时 box(width: 155mm, align(center, …)) 仍然居中于正文区（30~185 的中心 107.5mm）。
//
// 注意：只适用于奇数页。前置部分全部从奇数页起（封面 p1 / 题名页 p3 / …），
//    偶数页内容区左边界是外侧 25mm，届时偏移量要换成 外侧。
#let 页面坐标(body) = place(
  top + left,
  dx: -内侧,
  block(width: 纸张宽, body),
)

// 页眉 / 页脚定位
#let 页眉顶 = 20mm            // 格式规格 §2.1：页眉距页顶 2cm
#let 页脚底 = 17.5mm          // 页脚距页底 1.75cm

// 前置部分「有页眉页码」的分界
//
// 前置的每个小节都从奇数页起，中间会空出偶数页（p2/p4/…/p20）。官方实测：
//   - 封面↔声明 之间的空白填充页（p2~p8）：**无页眉无页码**（与本节实现一致）
//   - 「摘要」之后的空白填充页（p10=II、p12=IV…p20=XII）：**固定页眉 + 罗马页码**
// 本模板原先这些填充页是全空的，与官方不符。用下面的 state 标出分界，
// 文档级默认页眉/页脚据此切换 —— 这样用户模板里那些 `#pagebreak(to: "odd")`
// 产生的填充页会自动继承正确样式，不需要改用户写法。
#let 前置编号开始 = state("前置编号开始", false)
#let 固定页眉文字 = "西安电子科技大学硕士学位论文"

// 行距 / 字号
#let 行距 = 20pt              // 固定行距 20 磅
#let 正文号 = 12pt            // 小四

// 汉字字身框在固定行盒内居中时，基线距行盒顶的距离
// Δ = (行盒 - 字号) / 2 + 0.88 × 字号
//   - (20-12)/2 = 4pt（几何居中）
//   - 0.88 × 12 = 10.56pt（汉字字身框自带下沉）
//   - 合计 = 14.56pt
#let 基线偏移(行盒, 字号) = (行盒 - 字号) / 2 + 0.88 * 字号

#let 上伸 = 基线偏移(行距, 正文号)   // 14.56pt
#let 行隙 = 行距 - 上伸              // 5.44pt

// 各常用字号对应的 Δ
#let 标题号 = 16pt            // 黑体三号
#let 标题Δ = 基线偏移(行距, 标题号) // 16.08pt
#let 四号Δ = 基线偏移(行距, 14pt)
#let 小四Δ = 基线偏移(行距, 12pt)
#let 五号Δ = 基线偏移(行距, 10.5pt)
#let 小五Δ = 基线偏移(行距, 9pt)
#let 三号Δ = 基线偏移(行距, 16pt)

// 页眉文字基线距页眉帧顶 = 4.94mm（10.5pt 字号在 20pt 行盒内的 Δ）
#let 页眉基线 = 基线偏移(行距, 10.5pt)

// ============================================================
// 2. 页眉 / 页脚组件
// ============================================================

// 双横线：两条 0.5pt、中心距 1pt、宽度 = 正文宽 155mm
// 必须是零高度框（height: 0pt）以保证帧顶不漂移；用两个 place 的 line
// 实现。实测：若改用 v() 在段落流里排版，间距会变成 5.94pt 而非 1pt。
#let 双横线 = box(height: 0pt, width: 100%, {
  place(top + left, line(length: 100%, stroke: 0.5pt))
  place(top + left, dy: 1pt, line(length: 100%, stroke: 0.5pt))
})

// 页眉帧：零高度，帧顶 = 上边距 − header-ascent（在 #set page 中配 header-ascent）
// - 文字字号 10.5pt（格式规格 §2.2：五号）
// - 文字下方两条 0.5pt 横线，宽度 = 正文宽（不外扩）
// - 偶数页：固定标题「西安电子科技大学硕士学位论文」
// - 奇数页：当前章节名（由 mainmatter 接入，参数在此提供）
#let 页眉(文字) = box(height: 0pt, width: 100%, {
  set text(size: 10.5pt, font: 字体.宋体,
    top-edge: "baseline", bottom-edge: "baseline")
  // 文字基线 = 页眉顶 + 五号 Δ = 20mm + 4.94mm = 24.94mm（与官方差 0.88mm）
  place(top + center, dy: 页眉基线, text(文字))
  // 双横线基线 = 文字基线 + 行距 − 五号Δ + 1pt
  // （两条 0.5pt，中心距 1pt；line 默认在基线下绘制）
  place(top + center, dy: 页眉基线 + 行距 - 上伸 + 1pt, 双横线)
})

// 页脚帧：零高度，帧顶 = 版心下边界（297mm − 下边距）
// - 页码字号 9pt（格式规格 §1 裁定：官方 Word 用小五，2024.04 LaTeX 错用五号）
// - 前置部分字体 = TNR；正文部分字体 = 宋体（通过 set text 切换）
#let 页脚(字体名前缀) = context {
  let 数字 = counter(page).display()
  let 字号 = 9pt
  box(height: 0pt, width: 100%, {
    set text(size: 字号, font: 字体.宋体,
      top-edge: "baseline", bottom-edge: "baseline")
    // 页码基线 = 纸张高 − 页脚底（格式规格 §2.1「页脚距页底 1.75cm」= 279.50mm）
    // 与真实论文（已过检）实测 279.50mm 完全一致；官方 2024.04 为 278.29mm。
    // 帧顶在版心下边界，故 dy = 279.50 − 270.93 ≈ 8.57mm（不是 9pt 字体的 Δ）
    place(top + center, dy: 纸张高 - 页脚底 - 版心下边界, text(数字))
  })
}

// 默认页脚（前置 / 正文通用）
#let 默认页脚 = 页脚("宋体")

// ============================================================
// 2b. 索引类页面共用组件
// ============================================================

// 索引页页眉：与前置部分一致（罗马页码、页眉区 20→30mm、双横线）
#let 索引页页眉(页面标题) = 页眉(页面标题)

// 前置部分页面大标题：黑体 16pt 居中，基线 44.25mm；同时登记进目录
// 官方实测：摘要 / ABSTRACT / 四个索引 / 目录 的标题基线都是 44.2x mm
//   （目录 44.33，差 0.08mm，统一取 44.25）
//
// 注意：两个坑：
//   1. Typst 默认 heading 的 show rule 会把字号按 1.4em 放大（16pt → 22.4pt）
//      并加上下文间距。这里用局部 show rule 同时压掉字号缩放和上下间距。
//   2. 目录页自己的标题不能进目录（官方目录里没有「目录」自身），故 outlined: false。
#let 页面大标题(文字, outlined: true) = place(
  top + left, dx: 0mm, dy: 到内容区(44.25mm) - 标题Δ,
  // 注意：必须套 box(width: 155mm)：place 里直接 align(center) 没有确定宽度，
  //    标题会左对齐到正文区左边界（官方是居中）
  box(width: 155mm, align(center, {
    show heading: it => block(above: 0pt, below: 0pt, {
      set text(font: 字体.黑体, size: 16pt,
        top-edge: 标题Δ, bottom-edge: "baseline")
      it.body
    })
    heading(level: 1, outlined: outlined, bookmarked: true, 文字)
  })),
)

// 兼容旧名（五个索引页在用）
#let 索引页标题 = 页面大标题

// 后置部分（参考文献 / 附录 / 致谢 / 作者简介）页眉：
// 奇数页显示本部分标题，偶数页显示固定标题（格式规格 §2.3）
#let 后置页页眉(本部分, 固定标题) = context {
  if calc.odd(here().page()) { 页眉(本部分) } else { 页眉(固定标题) }
}

// 点填充：占满剩余宽度（官方为 TNR 的点线）
// 注意：直接把 repeat 元素交给 1fr 栅格列，不要包 box(width: 100%)——
//    后者会按父容器 100% 撑开，把同一行的页码挤出正文区。
#let 点填充 = repeat([.], gap: 1.6pt)

// 一行索引条目：左内容 + 点填充 + 右对齐页码（页码右边界 185mm）
// 注意：页码列必须给**固定宽度**：auto 列会让贪婪的 repeat 把页码挤到正文区外
//    （实测：auto → 点填充撑到 185、页码消失；12mm → 点填充止于 173、页码右对齐到 185）
#let 索引条目(左内容, 页码) = grid(
  columns: (auto, 1fr, 12mm),
  column-gutter: 2mm,
  align: (left, left, right),
  左内容, 点填充, box(width: 12mm, align(right, 页码)),
)

// ============================================================
// 3. 文档主函数（被 #show: doc 调用）
// ============================================================

#let doc(
  // documentclass 传入参数
  degree: "academic",          // "academic" | "professional"
  blind: false,                 // 盲审模式
  info: (:),                    // 论文信息
  fonts: (:),                   // 字体覆盖
  // 其它
  fallback: false,
  lang: "zh",
  it,
) = {
  // 1. 默认信息（学硕 / 专硕合并默认值，字段名沿用 XDU 规范）
  info = (
    title: ("基于 Typst 的西安电子科技大学学位论文模板",),
    title-en: ("XIDIAN UNIVERSITY Thesis Template for Typst",),
    author: "张三",
    author-en: "Zhang San",
    department: "某学院",
    department-en: "School of XX",
    discipline: "电子科学与技术",      // 学硕：一级学科
    discipline-en: "Electronic Science and Technology",
    subdiscipline: "电磁场与微波技术",  // 学硕：二级学科
    domain: "人工智能",                // 专硕：领域
    domain-en: "Artificial Intelligence",
    degree-name: "工学硕士",           // 申请学位类别
    degree-name-en: "Master of Engineering",
    supervisor: ("李四", "教授"),      // 学硕 / 专硕学校导师
    supervisor-en: ("Li Si", "Professor"),
    enterprise-supervisor: (none, none), // 专硕企业导师（学硕为 none）
    enterprise-supervisor-en: (none, none),
    school-code: "10701",
    clc: "TN82",                     // 中图分类号
    student-id: "1234567890",
    secret-level: "公开",
    submit-date: (year: 2025, month: 6),
    keywords: ("关键词一", "关键词二", "关键词三"),
    keywords-en: ("Keyword One", "Keyword Two", "Keyword Three"),
    abstract: [这是一段示例中文摘要。请用真实内容替换。],
    abstract-en: [This is a sample English abstract. Replace it with real content.],
  ) + info

  // 2. 字体：用户提供覆盖，否则用 style.typ 默认
  let 字体集 = 字体 + fonts

  // 3. 全局文本 / 段落样式（行盒与基线偏移）
  set text(
    font: 字体集.宋体,
    size: 正文号,
    lang: lang,
    fallback: fallback,
    top-edge: 上伸,
    bottom-edge: "baseline",
  )
  set par(
    leading: 行隙,
    spacing: 行隙,        // 必须显式设：Typst 默认 1.2em（12pt 下 = 14.4pt）会破坏行网格
    justify: true,
    first-line-indent: (amount: 2em, all: true),
  )

  // 4. PDF 元信息
  let 标题 = if type(info.title) == str { info.title } else { info.title.join(" ") }
  set document(
    title: 标题,
    author: info.author,
  )

  // 5. 暴露关键常量给后续页面使用（通过状态变量）
  //    - 写法：#let (info, degree, blind) = doc-info
  //    - 实际为简化：pages/ 下各页直接接收参数，不依赖全局状态
  //
  // 6. 默认页面（前置部分）
  //    - 前置部分在 show rules 中再 #set page 切换页眉/页码；doc 默认提供基础页
  set page(
    paper: "a4",
    width: 纸张宽,
    height: 纸张高,
    margin: (top: 上边距, bottom: 下边距, inside: 内侧, outside: 外侧),
    header-ascent: 上边距 - 页眉顶,  // 页眉帧顶落到 20mm
    footer-descent: 0mm,             // 页脚帧顶落到版心下边界
    // 前置填充页：从「摘要」起带固定页眉 + 罗马页码，之前全空（见 前置编号开始 注释）
    header: context if 前置编号开始.get() { 页眉(固定页眉文字) },
    footer: context if 前置编号开始.get() { 默认页脚 },
    numbering: "I",
  )

  it
}
