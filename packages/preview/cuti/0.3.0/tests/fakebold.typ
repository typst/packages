#import "../lib.typ": *
#set page(margin: 2cm)
#show table.cell.where(y: 0): it => {strong(it)}

// Please add `set text(font: ...)` to test how text appears in different fonts when testing typography layouts.

// Functional tests

#[
  *Regex `[aik]` Fakebold*: #regex-fakebold(reg-exp: "[aik]", lorem(10)) \
  *Fakebold based on `bold`*: #fakebold(base-weight: "bold", lorem(10)) \
]

// English

#[
  #let en-test(s) = table(
    columns: (1fr, ) * 3,
    stroke: 0.5pt,
    table.header(
      [Original],
      [Bold - Font],
      [Fakebold - `cuti`]
    ),
    s,
    strong(s),
    fakebold(s)
  )

  #en-test(lorem(30))

  #set par(justify: true)

  #en-test(lorem(30))
]

// Chinese + English

#[
  #let cn-test(s) = table(
    columns: (1fr, ) * 3,
    stroke: 0.5pt,
    table.header(
      [Original],
      [Fakebold - `cuti`],
      [zh Fakebold + en Font Bold]
    ),
    s,
    fakebold(s),
    show-cn-fakebold(strong(s))
  )

  #set par(justify: true)

  // zh-CN
  #set text(lang: "cn", region: "zh")
  #cn-test[你说得对，但是《Typst》是一款由 Typst GmbH 与众多贡献者开发的一款开放世界冒险排版游戏。游戏发生在一个被称作「typst.app」的线上世界。在这里，后面忘了——同时，逐步发掘排版的真相。Typst，启动！]

  // zh-HK
  #set text(lang: "cn", region: "hk")
  #cn-test[你說得對，但是《Typst》係一款由 Typst GmbH 同眾多貢獻者開發嘅開放世界冒險排版遊戲。遊戲發生喺一個叫做「typst.app」嘅線上世界。喺呢度，後面唔記得咗——同時，逐步發掘排版嘅真相。Typst，啟動！]

  // zh-TW
  #set text(lang: "cn", region: "tw")
  #cn-test[你說得對，但是《Typst》是一款由 Typst GmbH 與眾多貢獻者開發的開放世界冒險排版遊戲。遊戲發生在一個被稱作「typst.app」的線上世界。在這裡，後面忘記了——同時，逐步發掘排版的真相。Typst，啟動！]
]