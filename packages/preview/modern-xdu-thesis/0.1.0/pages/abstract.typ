// 西安电子科技大学硕士学位论文 Typst 模板 — 中文摘要
//
// 依据：docs/前置部分规格.md §5
// - 有页眉页脚（页眉 = 「摘要」，页码罗马）
// - 标题：黑体 16pt，居中，基线 44.25mm（段前 24 磅已含在这个绝对值里）
// - 正文：宋体 12pt，固定 20 磅行距，首行缩进 2 字符，两端对齐，首行基线 57.61mm
// - 关键词：宋体 12pt，与正文末行空一行（+40 磅）；「关键词」加粗

#import "../layouts/doc.typ": 基线偏移, 到内容区, 行隙, 页眉, 默认页脚, 上边距, 页眉顶, 标题Δ, 页面大标题, 前置编号开始
#import "../utils/style.typ": 字体 as 字体集

#let 正文Δ = 基线偏移(20pt, 12pt)

#let abstract(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  body: none,
  keywords: (),
) = {
  let 字体集 = 字体集 + fonts
  let 正文 = if body != none { body } else { info.abstract }
  let 关键词列表 = if keywords != () { keywords } else { info.keywords }

  // 从这一页起，前置的填充页才带页眉与罗马页码（见 doc.typ 前置编号开始）
  前置编号开始.update(true)

  // 页眉 / 页脚：前置部分，罗马页码。
  // 页眉用 doc.typ 的 页眉()（P1 验证过的零高度框写法），
  // 配 header-ascent = 上边距 − 页眉顶，页眉帧顶落在 20mm、文字基线 24.94mm。
  set page(
    numbering: "I",
    header-ascent: 上边距 - 页眉顶,
    footer-descent: 0mm,
    header: 页眉("摘要"),
    footer: 默认页脚,
  )

  // 标题：黑体 16pt 居中，基线 44.25mm；同时登记进目录
  页面大标题("摘要")

  // 正文走文档流：这样关键词能自然跟在正文末行之后。
  // 首行基线 = 30mm + v() + 正文Δ ⇒ v() = 57.61mm − 30mm − 正文Δ
  set text(font: 字体集.宋体, size: 12pt, lang: "zh",
    top-edge: 正文Δ, bottom-edge: "baseline")
  set par(leading: 行隙, spacing: 行隙,
    justify: true, first-line-indent: (amount: 2em, all: true))

  v(到内容区(57.61mm) - 正文Δ)
  正文

  // 关键词：与正文末行空一行。
  // 末行基线 → 关键词基线 = 行隙 + v() + 正文Δ，取 v() = 20pt 即 +40 磅。
  v(20pt)
  text(weight: "bold", "关键词：")
  text(关键词列表.join(", "))
}

