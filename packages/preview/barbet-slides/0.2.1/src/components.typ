// components.typ — 可重用版面元件
// 依賴：palette.typ（色票）、icons.typ（ic 圖示）

#import "palette.typ": c
#import "icons.typ": ic

// ───────────────────────── 版面元件 ─────────────────────────
// 一般卡片
#let card(title: none, icon: none, fill: c.surface, stroke: c.border, size: auto, body) = block(
  width: 100%,
  fill: fill,
  stroke: 1pt + stroke,
  radius: 6pt,
  inset: (x: 11pt, y: 9pt),
  breakable: false,
  {
    if title != none {
      block(below: 0.55em, text(weight: "bold", fill: c.heading)[
        #if icon != none [#ic(icon) #h(2pt)]#title
      ])
    }
    body
  },
)

// 強調卡片（accent-soft 底、accent 左框）
#let note(icon: none, body) = block(
  width: 100%,
  fill: c.accent-soft,
  stroke: (left: 3pt + c.accent),
  inset: (x: 11pt, y: 8pt),
  radius: (right: 6pt),
  breakable: false,
)[#if icon != none [#ic(icon) #h(3pt)]#body]

// 標籤
#let chip(body, fill: c.chip-bg, color: c.chip-text) = box(
  fill: fill,
  inset: (x: 5pt, y: 2.5pt),
  outset: (y: 1pt),
  radius: 4pt,
  text(size: 0.78em, fill: color, weight: "medium", body),
)
#let achip(body) = chip(body, fill: c.accent, color: white)

// 重點字
#let hl(body) = text(fill: c.accent, weight: "bold", body)
#let mute(body) = text(fill: c.muted, body)
// 深色粗體：卡片內的小標、表格中的重點
#let hd(body) = text(fill: c.heading, weight: "bold", body)
// 案名、判決字號
#let case(body) = text(fill: c.accent, weight: "medium", body)
// 小字註記
#let small(body, size: 13pt) = text(size: size, fill: c.muted, body)

// 判斷結果（形狀＋文字，不僅靠顏色）
#let yes(body) = [#ic("yes") #body]
#let no(body) = [#ic("no", color: c.subtle) #body]
#let maybe(body) = [#ic("maybe", color: c.muted) #body]
#let partly(body) = [#ic("half") #body]

// 流程箭頭
#let rarr = align(center + horizon, ic("arrow", color: c.muted, size: 1.3em))
#let darr = align(center, ic("down", color: c.muted, size: 1.1em))

// 流程方塊
#let step(title, body: none, fill: c.surface, stroke: c.border, head: c.accent) = block(
  width: 100%,
  height: 100%,
  fill: fill,
  stroke: 1pt + stroke,
  radius: 6pt,
  inset: 9pt,
  breakable: false,
)[
  #text(weight: "bold", fill: head)[#title]
  #if body != none [#v(-0.35em) #text(size: 0.9em, body)]
]

// 文獻出處（APA 文中引註），置於投影片左下角，字級刻意縮小
#let src(..items) = place(
  bottom + left,
  dy: 0.78cm,
  text(size: 8.5pt, fill: c.muted)[#items.pos().join("；")],
)

// 時間軸節點（置於 7 欄 grid 內使用；height 可依內容調整）
#let tl-node(date, title, body, result: none, emph: false, height: 6.2cm) = {
  let col = if emph { c.accent } else { c.accent-light }
  stack(
    dir: ttb,
    spacing: 6pt,
    align(center, chip(
      date,
      fill: if emph { c.accent } else { c.chip-bg },
      color: if emph { white } else { c.chip-text },
    )),
    block(width: 100%, height: 14pt, {
      place(horizon + left, line(length: 100%, stroke: 2pt + c.dot-muted))
      place(center + horizon, circle(radius: 6pt, fill: col, stroke: 2pt + c.surface))
    }),
    block(
      width: 100%,
      height: height,
      fill: c.surface,
      stroke: 1pt + if emph { c.accent } else { c.border },
      radius: 6pt,
      inset: 7pt,
    )[
      #text(weight: "bold", size: 14pt, fill: c.heading)[#title]
      #v(-0.3em)
      #text(size: 12.5pt)[#body]
      #if result != none [#v(-0.2em) #result]
    ],
  )
}

// 色調：plain（白底灰框）、soft（淡藍底）、accent（深藍底白字）、outline（白底灰字）
#let _tone(tone) = {
  assert(
    tone in ("plain", "soft", "accent", "outline"),
    message: "tone 須為 \"plain\"、\"soft\"、\"accent\" 或 \"outline\"",
  )
  if tone == "accent" { (fill: c.accent, line: c.accent, ink: white) } else if tone == "soft" {
    (fill: c.accent-soft, line: c.accent, ink: c.accent)
  } else if tone == "outline" { (fill: c.surface, line: c.muted, ink: c.subtle) } else {
    (fill: c.surface, line: c.border, ink: c.text)
  }
}

// 置中的方塊，用於流程圖、對照圖
#let node(body, tone: "plain", width: 100%, height: auto, size: 15pt) = {
  let st = _tone(tone)
  block(
    width: width,
    height: height,
    fill: st.fill,
    stroke: 1pt + st.line,
    radius: 5pt,
    inset: (x: 9pt, y: 8pt),
    breakable: false,
    align(center + horizon, {
      set par(justify: false, leading: 0.55em)
      text(size: size, fill: st.ink, body)
    }),
  )
}

// 圓形編號徽章
#let num-badge(n, radius: 13pt, tone: "accent") = {
  let st = _tone(tone)
  box(baseline: 50% - 0.7em, circle(
    radius: radius,
    fill: st.fill,
    stroke: 1pt + st.line,
    inset: 0pt,
    align(center + horizon, text(size: radius * 1.15, weight: "bold", fill: st.ink)[#n]),
  ))
}

// 引文框；source 為出處（不叫 src，以免與 src() 混淆；不叫 quote，以免遮蔽內建的 quote）
#let excerpt(body, source: none, size: 15pt) = block(
  width: 100%,
  fill: c.surface,
  stroke: (left: 3pt + c.dot-muted),
  inset: (x: 13pt, y: 8pt),
  breakable: false,
  {
    set text(size: size, fill: c.subtle)
    set par(justify: false, leading: 0.6em)
    body
    if source != none {
      v(2pt)
      align(right, text(size: 0.8em, fill: c.muted)[— #source])
    }
  },
)

// 深藍底白字的橫幅，用於小結；icon 為 ic() 的圖示名稱
#let banner(body, icon: none, size: 16pt) = block(
  width: 100%,
  fill: c.accent,
  radius: 4pt,
  inset: (x: 14pt, y: 9pt),
  breakable: false,
  {
    set par(justify: false, leading: 0.6em)
    set text(size: size, fill: white)
    if icon != none {
      grid(
        columns: (auto, 1fr),
        column-gutter: 10pt,
        align: horizon,
        ic(icon, color: white, size: 1.2em), body,
      )
    } else { align(center, body) }
  },
)

// 簡易時間軸：items 為 ((日期, 標題), (日期, 標題, 說明), …)
// 需要卡片式節點時，改用 tl-node 自行排版
#let timeline(items, date-size: 22pt, size: 14pt) = {
  let n = items.len()
  grid(
    columns: (1fr,) * n,
    row-gutter: 6pt,
    ..items.map(it => align(center, text(size: date-size, weight: "bold", fill: c.accent)[#it.at(0)])),
    ..items.map(_ => box(width: 100%, height: 18pt, {
      place(horizon + left, line(length: 100%, stroke: 2.5pt + c.dot-muted))
      place(center + horizon, circle(radius: 8pt, fill: c.accent, stroke: 3.5pt + c.bg))
    })),
    ..items.map(it => align(center, pad(x: 6pt, {
      set par(justify: false, leading: 0.55em)
      text(size: size + 1.5pt, weight: "bold", fill: c.heading)[#it.at(1)]
      if it.len() > 2 {
        linebreak()
        text(size: size, fill: c.subtle)[#it.at(2)]
      }
    }))),
  )
}
