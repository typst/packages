// SPDX-License-Identifier: MIT-0
// 本檔由 barbet-slides 範本產生，可自由修改、使用與散布，無須保留本授權聲明。
// 編譯：typst compile main.typ

#import "@preview/barbet-slides:0.2.1": *

#show: deck.with()

#front-slide(
  title: [簡報標題],
  subtitle: [副標題],
  authors: [報告人],
  info: [課程名稱 | 2026/11/19],
)

#title-slide[壹、問題提出]

#slide(title: "卡片與判斷結果")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    align: top,
    card(title: [爭點], icon: "scale")[
      規範本身是否合憲？#hl[重點]以強調色標示，#case[111憲判2] 標示案名。
    ],
    card(title: [結論], icon: "court")[
      #yes[合憲] \
      #no[違憲] \
      #maybe[有爭議] \
      #partly[部分違憲]
    ],
  )
  #v(6pt)
  #note(icon: "alert")[提示區塊：補充說明或保留意見。]
  #src(cite(<zhangsan2022>))
]

#slide(title: "流程與時間軸")[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    gutter: 6pt,
    node[規範架構], rarr, node(tone: "soft")[裁判梳理], rarr, node(tone: "accent")[違憲審查],
  )
  #v(16pt)
  #timeline((
    ([2022], [憲法判決], [變更先前解釋]),
    ([2023], [法律修正]),
    ([2026], [終審判決], [採不同架構]),
  ))
  #v(10pt)
  #banner(icon: "bulb")[小結：一句話總結本頁。]
]

#hidden-bibliography(path("refs.bib"))

#focus-slide[敬請指教]
