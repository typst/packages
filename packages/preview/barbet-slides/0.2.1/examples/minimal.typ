// 最小範例：在 repo 根目錄執行  typst compile examples/minimal.typ --root .
// 未發佈前請先以 install.ps1 -PackageRoot 安裝到 preview 命名空間（見 README-zh.md）
#import "@preview/barbet-slides:0.2.1": *

#show: deck.with()

#front-slide(
  title: [簡報標題],
  subtitle: [副標題],
  authors: [報告人],
  info: [課程名稱 | 日期],
)

#title-slide[壹、範例]

#slide(title: "元件示範")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    card(title: [卡片], icon: "scale")[內容 #hl[重點] #chip[標籤]],
    card(title: [判斷], icon: "check")[#yes[通過] \ #no[不通過] \ #maybe[有爭議]],
  )
  #v(6pt)
  #note(icon: "alert")[強調區塊]
  #src(cite(<demo>))
]

#hidden-bibliography(path("refs.bib"))
