// 西安电子科技大学硕士学位论文 Typst 模板 — 英文题名页
//
// 依据：docs/前置部分规格.md §3
// - 无页眉、无页脚、无页码
// - 全部西文用 Times New Roman
// - 题目区 22pt Bold（y=45.03）；中部 16pt（y=103.88 起）；尾部 16pt（y=232.54 起）
// - 行距一律固定 30pt
// - 学硕 vs 专硕：Supervisor 行数（1 行 vs 2 行），日期行顺延
//
// 「in <学科>」一行用英文学科名：优先 info.discipline-en / info.domain-en，
// 缺省时退回中文（会中西混排，但不会缺字）。

#import "../layouts/doc.typ": 基线偏移, 到内容区, 页面坐标

#let 标题Δ = 基线偏移(30pt, 22pt)
#let 正Δ = 基线偏移(30pt, 16pt)

#let title-en(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
) = {
  set page(header: none, footer: none, numbering: none)

  let TNR = ("Times New Roman",)
  let 题目列表 = if type(info.title-en) == str { (info.title-en,) } else { info.title-en }

  // 学科英文名
  let 学科英 = if degree == "professional" {
    info.at("domain-en", default: info.domain)
  } else {
    info.at("discipline-en", default: info.discipline)
  }

  let 上半 = (
    "A Thesis submitted to",
    "XIDIAN UNIVERSITY",
    "in partial fulfillment of the requirements",
    "for the degree of Master",
    "in " + 学科英,
  )

  // Supervisor 行：学硕 1 行，专硕 2 行（学校导师 + 企业导师）
  let 导师行(对) = {
    if 对 == none or 对 == () or 对.at(0) == none { return () }
    let 名字 = 对.at(0)
    let 职称 = if 对.len() >= 2 { 对.at(1) } else { "" }
    ("Supervisor: " + 名字 + " Title: " + 职称,)
  }
  let sup列表 = if degree == "professional" {
    导师行(info.supervisor-en) + 导师行(info.enterprise-supervisor-en)
  } else {
    导师行(info.supervisor-en)
  }

  let 月份英 = ("January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December")
  let 日期英 = 月份英.at(info.submit-date.month - 1) + " " + str(info.submit-date.year)

  // 尾部：By / 作者 / Supervisor… / 日期，从 253.63mm 起（学硕、专硕同起点）
  // 盲审（格式规格 §2.6）：不显示作者与导师
  let 尾部 = if blind { (日期英,) } else { sup列表 + (日期英,) }

  // 整页用页面绝对坐标（见 doc.typ 的 页面坐标）
  页面坐标({
    // 题目区 22pt Bold
    for (i, 行) in 题目列表.enumerate() {
      place(top + left, dx: 30mm, dy: 到内容区(45.03mm) + 30pt * i - 标题Δ,
        box(width: 155mm, align(center, {
          set text(font: TNR, size: 22pt, weight: "bold",
            top-edge: 标题Δ, bottom-edge: "baseline")
          行
        })))
    }

    // 中部说明 16pt
    for (i, 行) in 上半.enumerate() {
      place(top + left, dx: 30mm, dy: 到内容区(103.88mm) + 30pt * i - 正Δ,
        box(width: 155mm, align(center, {
          set text(font: TNR, size: 16pt, top-edge: 正Δ, bottom-edge: "baseline")
          行
        })))
    }

    // By / 作者名
    place(top + left, dx: 30mm, dy: 到内容区(232.54mm) - 正Δ,
      box(width: 155mm, align(center, {
        set text(font: TNR, size: 16pt, top-edge: 正Δ, bottom-edge: "baseline")
        "By"
      })))
    if not blind {
      place(top + left, dx: 30mm, dy: 到内容区(243.09mm) - 正Δ,
        box(width: 155mm, align(center, {
          set text(font: TNR, size: 16pt, top-edge: 正Δ, bottom-edge: "baseline")
          info.author-en
        })))
    }

    // Supervisor 行 + 日期
    for (i, 行) in 尾部.enumerate() {
      place(top + left, dx: 30mm, dy: 到内容区(253.63mm) + 30pt * i - 正Δ,
        box(width: 155mm, align(center, {
          set text(font: TNR, size: 16pt, top-edge: 正Δ, bottom-edge: "baseline")
          行
        })))
    }
  })
}
