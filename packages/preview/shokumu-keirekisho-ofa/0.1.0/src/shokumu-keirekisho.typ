// Generic Japanese employment-history template for engineering applications.

#let get(data, key, fallback: "") = data.at(key, default: fallback)

#let section-heading(title) = block(
  above: 6pt,
  below: 3pt,
  inset: (bottom: 2pt),
  stroke: (bottom: 0.9pt + rgb("1f4d5b")),
)[
  #text(weight: "bold", fill: rgb("1f4d5b"))[#title]
]

#let metadata-table(rows) = table(
  columns: (29mm, 1fr),
  stroke: 0.45pt,
  inset: 3.5pt,
  align: (center + horizon, left + horizon),
  ..for row in rows {
    (
      table.cell(fill: luma(239), align: center + horizon)[#get(row, "label")],
      get(row, "value"),
    )
  },
)

#let career-table(rows) = table(
  columns: (24mm, 34mm, 1fr),
  stroke: 0.45pt,
  inset: 3.5pt,
  align: (center + horizon, left + horizon, left + horizon),
  table.header(
    table.cell(fill: luma(239), align: center + horizon)[期間],
    table.cell(fill: luma(239), align: center + horizon)[組織・役割],
    table.cell(fill: luma(239), align: center + horizon)[担当内容・成果],
  ),
  ..for row in rows {
    (
      get(row, "period"),
      [#get(row, "organization") #get(row, "role")],
      [#get(row, "summary") #h(4pt)#text(size: 7.5pt, fill: luma(90))[使用技術：#get(row, "technologies")]],
    )
  },
)

#let project-block(project) = block(below: 4pt)[
  #text(weight: "bold")[#get(project, "title")]
  #h(1fr)#text(size: 7.5pt, fill: luma(90))[#get(project, "period")]
  #get(project, "summary") #h(4pt)#text(size: 7.5pt, fill: luma(90))[技術：#get(project, "technologies")]
]

#let shokumu-keirekisho(data) = {
  set text(
    font: get(data, "font", fallback: "Noto Sans CJK JP"),
    size: 9pt,
    lang: "ja",
  )
  set page(paper: "a4", margin: (x: 16mm, y: 14mm))
  set par(leading: 0.4em)

  align(right)[#get(data, "document-date", fallback: "YYYY年MM月DD日現在")]
  align(center)[#text(size: 18pt, weight: "bold")[職 務 経 歴 書]]
  align(right)[#get(data, "name", fallback: "氏名")]
  if get(data, "professional-links", fallback: "") != "" {
    align(right)[#text(size: 7.5pt, fill: luma(80))[#get(data, "professional-links")]]
  }

  section-heading([職務要約])
  get(data, "summary", fallback: "応募職種に関連する経験、強み、今後の貢献を簡潔に記入します。")

  section-heading([活かせるスキル・知識])
  metadata-table(get(data, "skills", fallback: ()))

  section-heading([職務経歴])
  career-table(get(data, "career", fallback: ()))

  section-heading([主なプロジェクト・研究])
  for project in get(data, "projects", fallback: ()) {
    project-block(project)
  }

  section-heading([資格・語学])
  get(data, "credentials", fallback: "資格、研修、語学力を記入します。")

  section-heading([自己PR])
  get(data, "self-pr", fallback: "応募先で活かせる強みと、具体的な貢献可能性を記入します。")
}
