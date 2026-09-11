#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

// 行距换算（Typst leading 为行盒之间的额外间隙，不是 Word 的"倍行距"）。
// 校准基准：LaTeX 参考实现（ctexbook 小四 + \linespread{1.5}）实测正文基线距
// 21.6pt（Songti SC 12pt），单倍（\linespread{1.0}）基线距 14.4pt。
// 模板统一 top-edge: cap-height / bottom-edge: baseline 修剪行盒，
// 小四行盒实测约 8.34pt，故：正文 leading 取约 13.26pt ≈ 1.1em；
// 单倍 leading 取约 6.06pt ≈ 0.5em。相对单位使五号等字号自动按比例缩放。
// 注意：规范"1.25倍行距"若按字面 1.25×字号仅 15pt，但 LaTeX 参考实现与
// 实际送审效果均为 21.6pt 量级，模板以参考实现为准（见 docs/CUSTOMIZE.md）。
// 标定方法：见 docs/CUSTOMIZE.md（SVG/PDF 基线法）。
#let 行距 = (
  // 单倍行距：标题等"单倍行距"场景，基线距约 1.0×ctex 单倍（14.4pt@小四）
  单倍: 0.5em,
  // 正文行距：正文/摘要/题注，基线距约 21.6pt@小四（对齐 LaTeX 参考实现）
  正文: 1.1em,
)

#let 等宽字体 = (
  // 优先使用 Typst 内置字体
  "DejaVu Sans Mono",
  // 常见系统字体
  "Courier New",
  "Courier",
  // macOS 系统字体
  "SF Mono",
  "Monaco",
  "Menlo",
  // 其他等宽字体
  "IBM Plex Mono",
  "Source Han Sans HW SC",
  "Source Han Sans HW",
  "Noto Sans Mono CJK SC",
  "SimHei",
  "Heiti SC",
  "STHeiti",
)

#let 字体组 = (
  windows: (
    宋体: ("Times New Roman", "SimSun"),
    黑体: ("Times New Roman", "SimHei"),
    楷体: ("Times New Roman", "KaiTi"),
    仿宋: ("Times New Roman", "FangSong"),
    等宽: 等宽字体,
  ),
  mac: (
    宋体: ("Times New Roman", "Songti SC"),
    黑体: ("Times New Roman", "Heiti SC"),
    楷体: ("Times New Roman", "Kaiti SC"),
    仿宋: ("Times New Roman", "STFangSong"),
    等宽: 等宽字体,
  ),
  fandol: (
    宋体: ("Times New Roman", "FandolSong"),
    黑体: ("Times New Roman", "FandolHei"),
    楷体: ("Times New Roman", "FandolKai"),
    仿宋: ("Times New Roman", "FandolFang R"),
    等宽: 等宽字体,
  ),
  adobe: (
    宋体: ("Times New Roman", "Adobe Song Std"),
    黑体: ("Times New Roman", "Adobe Heiti Std"),
    楷体: ("Times New Roman", "Adobe Kaiti Std"),
    仿宋: ("Times New Roman", "Adobe Fangsong Std"),
    等宽: 等宽字体,
  ),
)

#let get-fonts(fontset) = {
  if fontset == "windows" {
    字体组.windows
  } else if fontset == "mac" {
    字体组.mac
  } else if fontset == "adobe" {
    字体组.adobe
  } else {
    字体组.fandol
  }
}
