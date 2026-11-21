// deck.typ — 全域簡報設定
// 用法：#show: deck.with(...)
// 注意：Typst 的 #set / #show 不會跨檔案生效，故必須包成函式，由簡報檔以 `show: deck` 套用。

#import "@preview/typslides:1.4.0": typslides
#import "palette.typ": c

#let deck(
  ratio: "16-9",
  theme: c.accent,
  font: "Noto Sans TC",
  font-size: 18pt,
  back-color: c.bg,
  link-style: "color",
  progress-height: 3pt,
  lang: "zh",
  region: "tw",
  body,
) = {
  show: typslides.with(
    ratio: ratio,
    theme: theme,
    font: font,
    font-size: font-size,
    link-style: link-style,
    show-page-numbers: true,
    show-progress: true,
    progress-height: progress-height,
    back-color: back-color,
  )
  set text(lang: lang, region: region, fill: c.text)
  set par(leading: 0.62em)
  set list(spacing: 0.7em)

  // 表格樣式
  set table(
    stroke: (x, y) => (
      bottom: if y == 0 { 1.2pt + c.accent } else { 0.5pt + c.border },
    ),
    fill: (x, y) => if y == 0 { c.accent } else if calc.even(y) { c.border-soft } else { c.surface },
    inset: (x: 7pt, y: 6pt),
    align: left + horizon,
  )
  show table.cell.where(y: 0): set text(fill: white, weight: "bold")

  body
}

// 參考文獻：只供 cite() 解析，不在頁面輸出清單。
// 注意：套件內函式收到的「路徑字串」會相對於套件資料夾解析，而非簡報檔。
// Typst 0.15 起可傳入 `path` 值，它會相對於建立它的檔案解析，並可跨套件邊界：
//   #hidden-bibliography(path("/ref.bib"))
// 也可傳入以 `read(..., encoding: none)` 讀入的位元組。
#let hidden-bibliography(source, style: "apa") = {
  assert(
    type(source) != str,
    message: "hidden-bibliography: 請傳入 path(\"…\") 或位元組，而非字串；字串路徑會相對於本套件解析",
  )
  show bibliography: none
  bibliography(source, style: style)
}
