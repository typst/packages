// Generic MHLW-style two-page A4 rirekisho.

#let get(data, key, fallback: "") = data.at(key, default: fallback)

#let label-cell(label) = table.cell(
  fill: luma(238),
  inset: 3.5pt,
  align(center + horizon)[#label],
)

#let portrait(photo) = {
  if photo == none {
    box(width: 34mm, height: 44mm, stroke: 0.7pt, inset: 0pt)[
      #align(center + horizon)[写真]
    ]
  } else {
    box(width: 34mm, height: 44mm, stroke: 0.7pt, inset: 0pt, clip: true)[
      #photo
    ]
  }
}

#let history-table(rows) = table(
  columns: (13mm, 10mm, 1fr),
  stroke: 0.5pt,
  inset: 3pt,
  align: (center + horizon, center + horizon, left + horizon),
  table.header([年], [月], [学歴・職歴（各別にまとめて記入）]),
  ..for row in rows {
    (get(row, "year"), get(row, "month"), get(row, "detail"))
  },
)

#let credential-table(rows) = table(
  columns: (13mm, 10mm, 1fr),
  stroke: 0.5pt,
  inset: 3pt,
  align: (center + horizon, center + horizon, left + horizon),
  table.header([年], [月], [免許・資格]),
  ..for row in rows {
    (get(row, "year"), get(row, "month"), get(row, "detail"))
  },
)

#let boxed-field(label, body, label-width: 30mm) = table(
  columns: (label-width, 1fr),
  stroke: 0.5pt,
  inset: 3.5pt,
  align: (center + horizon, left + horizon),
  label-cell(label), body,
)

#let rirekisho(data) = {
  set text(
    font: get(data, "font", fallback: "Noto Sans CJK JP"),
    size: 8.5pt,
    lang: "ja",
  )
  set page(paper: "a4", margin: (x: 13mm, y: 12mm))
  set par(leading: 0.35em)

  align(right)[#get(data, "document-date", fallback: "YYYY年MM月DD日現在")]
  grid(
    columns: (1fr, 38mm),
    gutter: 5mm,
    [
      #align(center)[#text(size: 20pt, weight: "bold")[履 歴 書]]
      #v(2mm)
      #table(
        columns: (27mm, 1fr),
        stroke: 0.5pt,
        inset: 3.5pt,
        align: (center + horizon, left + horizon),
        label-cell([ふりがな]), get(data, "name-kana", fallback: "氏名（ふりがな）"),
        label-cell([氏名]), text(size: 14pt)[#get(data, "name", fallback: "氏名")],
        label-cell([生年月日]), get(data, "birth-date", fallback: "YYYY年MM月DD日（満XX歳）"),
      )
    ],
    align(right)[#portrait(get(data, "photo", fallback: none))],
  )

  v(3mm)
  boxed-field([現住所], [〒 #get(data, "address", fallback: "都道府県・市区町村・番地") #h(1fr) #get(data, "phone", fallback: "電話番号")])
  boxed-field([連絡先], [#get(data, "secondary-contact", fallback: "現住所以外に連絡を希望する場合のみ記入")])
  v(3mm)
  history-table(get(data, "history", fallback: ()))

  pagebreak()
  align(center)[#text(size: 16pt, weight: "bold")[履 歴 書（続紙）]]
  v(3mm)
  credential-table(get(data, "qualifications", fallback: ()))
  v(3mm)
  boxed-field([志望の動機、特技、好きな学科、アピールポイントなど], [#get(data, "motivation", fallback: "応募先に合わせて記入")], label-width: 1fr)
  v(3mm)
  boxed-field([本人希望記入欄], [#get(data, "preferences", fallback: "特に給料・職種・勤務時間・勤務地などについて希望があれば記入")], label-width: 1fr)

  if get(data, "show-legacy-fields", fallback: false) {
    v(3mm)
    table(
      columns: (1fr, 1fr),
      stroke: 0.5pt,
      inset: 3.5pt,
      label-cell([通勤時間]), get(data, "commute-time", fallback: "約　時間　分"),
      label-cell([扶養家族数]), get(data, "dependents", fallback: "人（配偶者を除く）"),
      label-cell([配偶者]), get(data, "spouse", fallback: "有・無"),
      label-cell([配偶者の扶養義務]), get(data, "spouse-support", fallback: "有・無"),
    )
  }
}
