// 西安电子科技大学硕士学位论文 Typst 模板 — 字号 / 字体常量
//
// 依据：docs/格式规格.md §1 / §2.2、docs/版式实现.md §7.2
// - 字号表沿用 P1 之前的命名（与官方 Word「磅 / 号」对齐）
// - 字体表只保留 宋体 / 黑体 / Times New Roman 三种（格式规格 §2.2 字体要求）
//   不再包含 楷体 / 仿宋 / Arial —— 官方模板正文 0 次出现，无使用场景

// ============================================================
// 1. 字号（与 Word 中文排版字号体系一致，Typst 直接用 pt）
// ============================================================
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

// ============================================================
// 2. 字体（系统字体优先 + 完整回退链，不内置任何字体文件）
// ============================================================
// 官方学位论文全篇只需：
//   宋体（衬线） / 黑体（无衬线） / Times New Roman（西文）
// - 黑体的西文也用 TNR（格式规格 §2.2 已裁定）
// - macOS 上无 SimSun/SimHei，按回退链自动落到 Songti SC / Heiti SC
// - Linux 上落 Noto CJK / Source Han；Typst 找不到时进入 fallback
//
// 注：回退链里按平台概率排序：macOS > Windows > Linux 开源
#let 字体 = (
  宋体: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "Songti SC", "STSong", "Songti TC",
    "SimSun", "NSimSun",
    "Source Han Serif SC", "Noto Serif CJK SC",
  ),
  黑体: (
    (name: "Times New Roman", covers: "latin-in-cjk"),
    "Heiti SC", "STHeiti", "Heiti TC",
    "SimHei",
    "Source Han Sans SC", "Noto Sans CJK SC",
  ),
)
