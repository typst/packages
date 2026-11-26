// src/inline.typ
// 行內樣式函式（筆記與論文共用）

#import "fonts.typ": font-kai

// ============================================================
// § 行內樣式函式（筆記與論文共用）
// ============================================================

// 行內引用 / Example: #inquote[quoted text]
// 可填寫 font 參數以使用其他字型清單
#let inquote(content, font: font-kai) = {
  set text(font: font)
  content
}
// 重點強調(單純加粗)
#let keyword(content) = {
  set text(weight: "bold")
  content
}
