// 西安电子科技大学硕士学位论文 Typst 模板 — 缩略语对照表
//
// 依据：docs/索引部分规格.md §4
// - 页眉 / 标题：同上（25.82 / 44.25mm）
// - 三栏无表格线；表头行基线 57.61mm，数据行行距固定 20 磅
// - 官方实测列位置（页面绝对 x）：
//     表头「缩略语」34.13、「英文全称」72.25、「中文对照」114.60
//     数据        35.19 /  76.13 / 119.18
//   表头与数据列宽不同（官方如此），各用一套。
//
// 数据来源：info.abbreviations = ((缩略语, 英文全称, 中文对照), …)

#import "../layouts/doc.typ": 基线偏移, 到内容区, 页眉, 默认页脚, 上边距, 页眉顶, 页面大标题
#import "../utils/style.typ": 字体 as 字体集

#let 正文Δ = 基线偏移(20pt, 12pt)

#let abbreviations(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  title: "缩略语对照表",
  rows: none,
) = {
  let 字体集 = 字体集 + fonts
  let 数据 = if rows != none { rows } else { info.at("abbreviations", default: ()) }
  // 官方《撰写要求》：缩略语对照表「按英文单词首字母顺序排列」，此处自动排序
  let 数据 = 数据.sorted(key: 条目 => 条目.at(0))

  set page(
    numbering: "I",
    header-ascent: 上边距 - 页眉顶,
    footer-descent: 0mm,
    header: 页眉(title),
    footer: 默认页脚,
  )

  页面大标题(title)

  set text(font: 字体集.宋体, size: 12pt, lang: "zh",
    top-edge: 正文Δ, bottom-edge: "baseline")
  set par(leading: 20pt - 正文Δ, spacing: 20pt - 正文Δ)

  // 表头行：基线 57.61mm（显式定位）
  place(top + left, dx: 0mm, dy: 到内容区(57.61mm) - 正文Δ,
    pad(left: 4.13mm, box(width: 155mm, grid(
      columns: (38.12mm, 42.35mm, 1fr),   // 72.25 / 114.60 相对 34.13
      align: (left, left, left),
      [缩略语], [英文全称], [中文对照],
    ))))

  // 数据行：首行基线 64.64mm，行距固定 20 磅
  place(top + left, dx: 0mm, dy: 到内容区(64.64mm) - 正文Δ,
    pad(left: 5.19mm, box(width: 155mm, grid(
      columns: (40.94mm, 43.05mm, 1fr),
      row-gutter: 20pt - 正文Δ,
      align: (left, left, left),
      ..数据.map(((a, b, c)) => (text(a), text(b), text(c))).flatten(),
    ))))
}
