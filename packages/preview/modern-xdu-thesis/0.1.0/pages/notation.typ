// 西安电子科技大学硕士学位论文 Typst 模板 — 符号对照表
//
// 依据：docs/索引部分规格.md §3
// - 页眉 / 标题：同其余索引页（基线 25.82 / 44.25mm，双横线 27.64/28.00mm）
// - 两栏无表格线；表头行基线 57.61mm，数据行行距固定 20 磅
// - 官方实测列位置（页面绝对 x）：
//     表头「符号」35.19、「符号名称」95.54
//     数据   34.13 / 98.36
//   故表头与数据用两套列宽（官方本身就不一致），各自贴齐官方值。
//
// 数据来源：info.notation = ((符号, 符号名称), …)

#import "../layouts/doc.typ": 基线偏移, 到内容区, 页眉, 默认页脚, 上边距, 页眉顶, 页面大标题
#import "../utils/style.typ": 字体 as 字体集

#let 正文Δ = 基线偏移(20pt, 12pt)

#let notation(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  title: "符号对照表",
  rows: none,
) = {
  let 字体集 = 字体集 + fonts
  let 数据 = if rows != none { rows } else { info.at("notation", default: ()) }

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

  // 表头行：基线 57.61mm（显式定位，不依赖流式间距）
  place(top + left, dx: 0mm, dy: 到内容区(57.61mm) - 正文Δ,
    pad(left: 5.19mm, box(width: 155mm, grid(
      columns: (60.35mm, 1fr),    // 95.54 − 35.19
      align: (left, left),
      [符号], [符号名称],
    ))))

  // 数据行：首行基线 64.64mm（表头 + 20 磅），行距固定 20 磅
  place(top + left, dx: 0mm, dy: 到内容区(64.64mm) - 正文Δ,
    pad(left: 4.13mm, box(width: 155mm, grid(
      columns: (64.23mm, 1fr),    // 98.36 − 34.13
      row-gutter: 20pt - 正文Δ,    // grid 行不受 par leading 控制，需显式补偿
      align: (left, left),
      ..数据.map(((a, b)) => (text(a), text(b))).flatten(),
    ))))
}
