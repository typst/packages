// ============================================================
// lib/fonts.typ: 字体探测与 CJK 回退
// ============================================================

// 西文字体回退链
#let latin-fonts = (
  "Times New Roman",
  "DejaVu Serif",
)

// CJK 宋体（正文）回退链
#let cjk-serif = (
  "SimSun",
  "NSimSun",
  "FandolSong",
  "Noto Serif CJK SC",
  "Source Han Serif SC",
)

// CJK 黑体（标题/强调）回退链
#let cjk-sans = (
  "SimHei",
  "FandolHei",
  "Noto Sans CJK SC",
  "Source Han Sans SC",
)

// CJK 楷体回退链
#let cjk-kai = (
  "KaiTi",
  "FandolKai",
)

// CJK 仿宋回退链
#let cjk-fang = (
  "FangSong",
  "FandolFang R",
)

// 辅助函数：返回可用的字体列表
#let get-latin-fonts() = latin-fonts
#let get-cjk-serif() = cjk-serif
#let get-cjk-sans() = cjk-sans
#let get-cjk-kai() = cjk-kai
#let get-cjk-fang() = cjk-fang
