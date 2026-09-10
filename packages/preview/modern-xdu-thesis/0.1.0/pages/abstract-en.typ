// 西安电子科技大学硕士学位论文 Typst 模板 — 英文摘要 (ABSTRACT)
//
// 依据：docs/前置部分规格.md §6
// - 有页眉页脚（页眉 = 「ABSTRACT」，页码罗马）
// - 标题：Times New Roman 16pt，居中，基线 44.25mm
// - 正文：Times New Roman 12pt，固定 20 磅行距，**首行不缩进**，两端对齐
// - 正文首行基线 53.80mm（官方实测；比中文摘要的 57.61mm 高，
//   官方中文/英文摘要的标题段后不一致，此处按官方逐页实测值取，不强行统一）
// - Keywords：与正文末行空一行

#import "../layouts/doc.typ": 基线偏移, 到内容区, 行隙, 页眉, 默认页脚, 上边距, 页眉顶, 标题Δ, 页面大标题
#import "../utils/style.typ": 字体 as 字体集

#let 正文Δ = 基线偏移(20pt, 12pt)

#let abstract-en(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  body: none,
  keywords: (),
) = {
  let 字体集 = 字体集 + fonts
  let 正文 = if body != none { body } else { info.abstract-en }
  let 关键词列表 = if keywords != () { keywords } else { info.keywords-en }

  // 页眉「ABSTRACT」为纯西文，走 宋体 字体链的 TNR 分支
  set page(
    numbering: "I",
    header-ascent: 上边距 - 页眉顶,
    footer-descent: 0mm,
    header: 页眉("ABSTRACT"),
    footer: 默认页脚,
  )

  // 标题：TNR 16pt 居中，基线 44.25mm；同时登记进目录
  页面大标题("ABSTRACT")

  // 正文走文档流；首行基线 53.80mm，首行不缩进
  set text(font: 字体集.宋体, size: 12pt, lang: "en",
    top-edge: 正文Δ, bottom-edge: "baseline")
  set par(leading: 行隙, spacing: 行隙,
    justify: true, first-line-indent: 0pt)

  v(到内容区(53.80mm) - 正文Δ)
  正文

  v(20pt)
  text(weight: "bold", "Keywords: ")
  text(关键词列表.join(", "))
}
